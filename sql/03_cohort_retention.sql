/*
Проєкт:     Olist E-Commerce SQL Analytics
Файл:       03_cohort_retention.sql
Автор:      Sasha
Призначення: Місячний когортний аналіз retention — відстеження частки клієнтів
             які повертаються в наступні місяці після першої покупки.
             Виявляє структурну поведінку one-time buyers по всіх когортах.
*/


-- ============================================================
-- ЗАПИТ: Місячний когортний Retention
-- Бізнес-питання: Який відсоток клієнтів повертається
--                 в місяці після першої покупки?
-- ============================================================

WITH cohorts AS (
    -- Крок 1: Визначаємо когорту кожного клієнта як місяць першої покупки
    SELECT
        c.customer_unique_id,
        MIN(DATE_TRUNC('month', o.order_purchase_timestamp)::DATE) AS cohort_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),

activities AS (
    -- Крок 2: Отримуємо всі місяці покупок кожного клієнта (не тільки першу)
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),

cohort_size AS (
    -- Крок 3: Рахуємо кількість унікальних клієнтів у кожній когорті
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_users
    FROM cohorts
    GROUP BY 1
),

retention AS (
    -- Крок 4: З'єднуємо когорти з активністю і рахуємо month_number
    -- month_number = 0 означає місяць самої когорти (перша покупка)
    SELECT
        c.cohort_month,
        (EXTRACT(YEAR  FROM a.order_month) - EXTRACT(YEAR  FROM c.cohort_month)) * 12
        + EXTRACT(MONTH FROM a.order_month) - EXTRACT(MONTH FROM c.cohort_month) AS month_number,
        COUNT(DISTINCT c.customer_unique_id)                                      AS active_users
    FROM cohorts c
    JOIN activities a ON c.customer_unique_id = a.customer_unique_id
    GROUP BY 1, 2
)

SELECT
    r.cohort_month,
    cs.total_users,
    r.month_number,
    r.active_users,
    ROUND(r.active_users::NUMERIC / cs.total_users * 100, 1) AS retention_pct
FROM retention r
JOIN cohort_size cs ON r.cohort_month = cs.cohort_month
ORDER BY 1, 3;

-- Примітки:
-- customer_unique_id використовується для відстеження реальних клієнтів
--   (один клієнт може мати кілька customer_id в Olist)
-- month_number = 0: місяць когорти (retention = 100% за визначенням)
-- Пропуски в послідовності month_number (наприклад 0, 6, 9, 11) підтверджують
--   що більшість клієнтів не повертається — структурна one-time buyer поведінка
-- Retention < 1% по всіх когортах починаючи з місяця 1
-- Частково пояснюється marketplace-моделлю Olist:
--   повторні клієнти можуть реєструватись з новим customer_id через іншого продавця
-- Результат: 97% з 93,358 клієнтів зробили тільки одну покупку
