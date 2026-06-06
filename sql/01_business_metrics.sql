/*
Проєкт:     Olist E-Commerce SQL Analytics
Файл:       01_business_metrics.sql
Автор:      Oleksandr Kiichenko
*/

-- Місячний Revenue з MoM Growth Rate
-- Бізнес-питання: Як змінюється виручка місяць до місяця і де знаходяться точки гальмування зростання?

WITH month_rev AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS month
        ,ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)

SELECT
    month
    ,revenue
    ,LAG(revenue) OVER (ORDER BY month) AS revenue_prev_month
    ,ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
    2) AS mom_growth_pct
FROM month_rev
ORDER BY month;

-- Примітки:
-- Дані до 2017 виключені з висновків: Olist знаходився на стадії запуску
-- Серпень 2018 — неповний місяць, останній рядок виключається з аналізу MoM
-- Листопад 2017 (+52.4% MoM) — Black Friday ефект, очікуваний сезонний сплеск
-- Грудень 2017 (-26.5%) — нормальна post-holiday корекція, не сигнал проблеми
-- Місяці з від'ємним MoM поза сезонністю (квіт/черв 2017, лют/черв 2018)
--   потребують аудиту маркетингових витрат за відповідні періоди


-- ============================================================


-- Топ-10 категорій товарів за Revenue з AOV
-- Бізнес-питання: Які категорії генерують найбільший дохід
--                 і який середній чек у кожній?


WITH cat_rnk AS (
    SELECT
        p.product_category_name
        ,COUNT(o.order_id) AS cnt_orders
        ,ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue
        ,RANK() OVER (ORDER BY SUM(oi.price) DESC) AS rnk
    FROM orders o
    JOIN order_items oi ON o.order_id    = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)

SELECT
    product_category_name
    ,cnt_orders
    ,revenue
    ,ROUND(revenue / cnt_orders, 2) AS aov
FROM cat_rnk
WHERE rnk <= 10
ORDER BY revenue DESC;

-- Примітки:
-- freight_value виключено з виручки: price вимірює дохід від продажу товару;
--   вартість доставки — логістичний витрат, а не дохід платформи
-- beleza_saude: лідер по revenue ($1.23M), збалансований обсяг і AOV ($130)
-- relogios_presentes: найвищий AOV ($199) при мінімальній кількості замовлень — premium сегмент
-- cama_mesa_banho: найбільша кількість замовлень (10,953) але найнижчий AOV ($93) — масовий сегмент
-- cool_stuff: 4-й по AOV ($164) але лише 8-й по revenue — недомасштабована категорія
