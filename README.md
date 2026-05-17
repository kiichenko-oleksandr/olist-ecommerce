# 🇧🇷 Brazilian E-Commerce (Olist) — Exploratory Data Analysis

Full EDA of the Brazilian e-commerce marketplace Olist: **98,666 orders** from **95,420 customers** through **3,095 sellers** across **73 product categories** (Sep 2016 — Aug 2018).

## Key Findings

- **Growth plateau:** Revenue grew 8x in 2017 ($146K → $1.2M/mo), then flatlined in 2018. Growth was entirely acquisition-driven — AOV stayed flat at $160–180.
- **Retention crisis:** 97% of customers never return. Repeat rate is 3.1%. Cohort analysis confirms: no cohort retains even 1% after month one. No improvement between 2017 and 2018 cohorts.
- **Delivery → ratings → retention chain:** 7.9% of orders arrive late. Late orders score 2.55 vs 4.15 for on-time (–1.6 points). Delivery time ranges from 8 days (São Paulo) to 28 days (Roraima) — a 3.4x gap driven by geography.
- **Geographic concentration:** Top 5 states = 73.1% of revenue. São Paulo alone = 37.4%.
- **Pareto in sellers:** 18.1% of sellers generate 80% of revenue.

## Recommendations

1. **Retention program** — email reminders, loyalty program, personalized recommendations. Target: 3% → 8–10% repeat rate in 6 months.
2. **Delivery optimization** — regional logistics partners or intermediate warehouses for northern states. Target: reduce remote delivery from 25+ to 15 days.
3. **Seller development** — targeted support for mid-tier sellers to reduce revenue concentration.
4. **NPS research** — survey returning vs one-time customers to understand barriers.

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 9 CSV files:

| Table | Rows | Description |
|-------|------|-------------|
| orders | 99,441 | Order timestamps, status, delivery dates |
| items | 112,650 | Products in each order, prices, freight |
| payments | 103,886 | Payment method, installments, value |
| customers | 99,441 | Customer location (city, state) |
| reviews | 99,224 | Review scores and comments |
| sellers | 3,095 | Seller location |
| products | 32,951 | Product attributes, category |
| geolocation | 1,000,163 | Zip code coordinates |
| categories | 71 | Category name translations (PT → EN) |

## Project Structure

```
├── README.md
├── Project_1.ipynb          # Full analysis notebook
├── REPORT.docx              # Executive Summary (SCR format)
└── data/                    # Raw CSV files (not tracked)
```

## Analysis Structure

| # | Section | What it covers |
|---|---------|---------------|
| 1 | Import & Preparation | Merge 9 tables, clean missing data, create revenue column |
| 2 | Big Picture | Business scale, monthly revenue trend, AOV analysis |
| 3 | Customer Analysis | New vs returning (3.1%), state distribution, cohort retention |
| 4 | Product Analysis | Top categories by revenue/orders/AOV, monthly trends |
| 5 | Delivery Analysis | Avg delivery time, late orders (7.9%), speed by state |
| 6 | Review Analysis | Rating distribution, delivery ↔ rating correlation |
| 7 | Payment Analysis | Payment methods, installment usage |
| 8 | Seller Analysis | Pareto distribution (18.1% → 80% revenue) |
| 9 | Executive Summary | SCR: Situation, Complication, Recommendations, Limitations |

## Tech Stack

- **Python 3** (Google Colab)
- **Pandas** — data manipulation, groupby, pivot tables, merge
- **NumPy** — numerical operations
- **Matplotlib** — revenue trends, bar charts
- **Seaborn** — cohort retention heatmap

## How to Run

1. Download dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Place CSV files in the same directory as the notebook
3. Open `Project_1.ipynb` in Google Colab or Jupyter
4. Run all cells

## Author

**Sasha** — aspiring Data / Product Analyst. This is Project 1 in a portfolio series covering EDA, SQL analytics, A/B testing, and modern data stack (dbt + Airflow).
