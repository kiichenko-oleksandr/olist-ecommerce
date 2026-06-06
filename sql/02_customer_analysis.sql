/*
Проєкт:     Olist E-Commerce SQL Analytics
Файл:       02_customer_analysis.sql
Автор:      Oleksandr Kiichenko
*/


-- Repeat Purchase Rate (частка клієнтів з повторними покупками)
-- Бізнес-питання: Яка частка клієнтів зробила більше однієї покупки?


WITH customer_orders AS (
    SELECT
        c.customer_unique_id
        ,COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
    ,COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_unique_id END) AS repeat_customers
    ,ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_unique_id END)::NUMERIC
        / COUNT(DISTINCT customer_unique_id) * 100,
    1) AS repeat_rate_pct
FROM customer_orders;

-- Примітки:
-- Використовується customer_unique_id замість customer_id:
--   один реальний клієнт може мати кілька customer_id в Olist
-- Результат: 97% клієнтів — one-time buyers (repeat rate = 3%)
-- Низький repeat rate частково структурний: Olist — marketplace,
--   клієнт може повернутись через іншого продавця з новим customer_id


-- ============================================================


-- RFM-сегментація клієнтів
-- Бізнес-питання: Як класифікувати клієнтів за поведінкою
--                 для пріоритизації retention та реактивації?


WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        ,MAX(o.order_purchase_timestamp)::DATE AS last_order
        ,COUNT(o.order_id) AS total_orders
        ,SUM(oi.price + oi.freight_value) AS total_expenses
        ,'2018-08-29'::DATE - MAX(o.order_purchase_timestamp)::DATE AS recency
    FROM customers c
    JOIN orders o ON c.customer_id  = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),

rfm_scores AS (
    SELECT
        customer_unique_id
        ,last_order
        ,total_orders
        ,total_expenses
        ,NTILE(4) OVER (ORDER BY recency ASC) AS recency_score
        ,NTILE(4) OVER (ORDER BY total_orders DESC) AS total_orders_score
        ,NTILE(4) OVER (ORDER BY total_expenses DESC) AS total_expenses_score
    FROM rfm_base
),

segments AS (
    SELECT
        customer_unique_id
        ,CASE
            WHEN recency_score = 4
             AND total_orders_score = 4
             AND total_expenses_score = 4  THEN 'champion'
            WHEN total_orders_score >= 3   THEN 'loyal'
            WHEN recency_score = 4
             AND total_orders_score <= 2   THEN 'recent'
            WHEN recency_score <= 2
             AND total_orders_score >= 3   THEN 'at_risk'
            WHEN recency_score = 1         THEN 'lost'
            ELSE 'others'
        END AS segment
    FROM rfm_scores
)

SELECT
    segment
    ,COUNT(customer_unique_id) AS cnt_users
    ,ROUND(COUNT(customer_unique_id)::NUMERIC / SUM(COUNT(customer_unique_id)) OVER () * 100, 1) AS pct_of_base
FROM segments
GROUP BY 1
ORDER BY 2 DESC;

-- Примітки:
-- freight_value включено в total_expenses: відображає реальні витрати клієнта
-- Референсна дата '2018-08-29' = остання дата в датасеті
-- RFM-пороги на основі квартилів (NTILE), не валідованих бізнес-значень —
--   сегменти є відправною точкою для гіпотез, не фінальною класифікацією
-- Champions (1.7%): конвертація 5% Loyal у Champions = +2,250 VIP клієнтів
-- Lost (12.5%): реактивація 10% = +1,170 повернень при нульовому CAC
