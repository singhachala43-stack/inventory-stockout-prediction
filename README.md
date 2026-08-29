[README.md](https://github.com/user-attachments/files/31598387/README.md)
# inventory-stockout-prediction
ML pipeline predicting inventory stockout risk and revenue at risk using SQL, Python, and Power BI
# Inventory & Stockout Prediction + Demand Analysis

## Business Problem

A retailer selling thousands of SKUs across multiple warehouses loses real revenue whenever a
fast-moving product runs out of stock before the next supplier shipment arrives. This project
builds an early-warning system that answers two connected questions for every product:

1. **How much demand should we expect** over the next few days?
2. **How likely is this product to stock out** before resupply — and how much revenue is at risk
   if it does?

Rather than stopping at a model accuracy score, the project translates risk into a business
metric a manager can act on directly: **Revenue at Risk**.

## Headline Result

> Across a 3-month test period, the model identified **approximately ₹525 Crore in revenue at
> risk** from predicted stockouts, concentrated heavily in the Electronics category — a finding
> confirmed independently through SQL analysis, visualization, and machine learning feature
> importance.

## Tech Stack

 Layer                      |            Tools      

 Data generation & cleaning | Python (pandas, numpy) 
 Database                   | MySQL 
 Exploratory analysis       | Python (matplotlib, seaborn) 
 Machine learning           | scikit-learn (Linear Regression, Random Forest, Logistic Regression) 
 Dashboard                  | Power BI      

## Project Structure

```
Inventory_Stockout_Project/
├── data/               # Raw and cleaned datasets, saved models
├── notebooks/          # Numbered Jupyter notebooks, one per pipeline stage
├── sql/                # Business-question SQL queries
├── dashboard/          # Power BI (.pbix) file
└── reports/            # Daily documentation of the build process
```

## Pipeline Overview

1. **Data generation** — Since no single public dataset combines product, warehouse, supplier,
   lead time, promotions, seasonality, and inventory in one place, a synthetic dataset (50
   products, 2 years of daily data, ~36,500 rows) was generated in Python with realistic seasonal
   demand, promotions, and a supplier reorder/lead-time simulation.
2. **Cleaning & feature engineering** — Validated the dataset (duplicates, nulls, logical
   consistency) and engineered rolling demand averages, days-of-stock-remaining, and
   lead-time-adjusted expected demand.
3. **SQL analysis** — Loaded into MySQL; answered which products, warehouses, and suppliers
   contribute most to stockouts and revenue loss.
4. **Exploratory analysis** — Visualized seasonal demand, warehouse risk, lead-time correlation,
   and a correlation heatmap of engineered features.
5. **Demand forecasting** — Compared Linear Regression against Random Forest using a
   time-based (non-shuffled) train/test split to avoid leaking future information into training.
6. **Stockout prediction** — Built a Random Forest classifier to predict stockout probability,
   evaluated on precision/recall (not just accuracy) given the business cost of a missed
   stockout versus a false alarm, then combined probability × expected demand × price into a
   Revenue at Risk score per product.
7. **Dashboard** — A two-page Power BI report: an Inventory Overview (headline KPIs, category
   and warehouse breakdowns, trend over time) and a High-Risk Products page (ranked table and
   top-10 chart).

## Key Findings

- **Supplier lead time is the dominant driver of stockout risk** — confirmed independently via
  SQL aggregation, a visual chart, and ML feature importance (lead-time-related features
  accounted for over half the classifier's decision weight).
- **Frequency of stockouts and financial impact are different questions.** Clothing and Toys
  stocked out most *often*, but Electronics accounted for the overwhelming majority of revenue
  at risk due to its much higher price point.
- **One warehouse (WH_South) is a clear outlier**, losing roughly 3.4x more units than the
  best-performing warehouse — a signal worth investigating operationally, separate from
  product-level demand patterns.
- **Revenue at risk is not constant over time** — it spikes noticeably heading into the holiday
  season, suggesting reorder policy should flex seasonally rather than stay static year-round.

## Modeling Notes (Engineering Decisions Worth Highlighting)

- **Time-based train/test split**, not random shuffling, since randomly shuffling time-ordered
  data would let the model "learn from the future" — unrealistic for a real deployment.
- **Deliberate feature exclusion to avoid data leakage.** Inventory-derived features
  (`Current_Inventory`, `Days_Stock_Remaining`, etc.) were excluded from the *demand* model since
  they are downstream consequences of demand, not causes of it — but were correctly *included*
  in the *stockout* model, where they are a genuine predictive cause. An earlier version of the
  stockout classifier scored a suspicious 1.000 across every metric; this was diagnosed via model
  coefficients and traced to `Stockout_Flag` being mathematically derived from
  `Current_Inventory`, which was still present in the feature set.
- **Model choice driven by business cost, not accuracy alone.** Random Forest was chosen over
  Logistic Regression for stockout classification because it achieved substantially higher recall
  (70% vs. 46%) at a modest precision cost — appropriate here since a missed stockout is more
  costly to the business than a false alarm.

## Deployment Notes

This pipeline is structured to run as a **scheduled batch job**, not a real-time system, since
inventory and demand data update on a daily cadence in most retail operations:

- A daily or weekly scheduled script would re-run the SQL load, feature engineering, and both
  models (`joblib`-serialized) against the latest data, writing fresh predictions back to a
  `high_risk_products` table.
- Power BI would refresh from that table on the same schedule (Power BI Desktop supports
  scheduled refresh when published to the Power BI Service).
- In a production setting, this would likely be orchestrated with a simple scheduler (cron,
  Windows Task Scheduler, or Airflow for a larger deployment) rather than manual notebook
  execution.

## Possible Future Improvements

- Extend demand forecasting to dedicated time-series methods (e.g. Prophet, ARIMA) and compare
  against the current Random Forest baseline.
- Add per-warehouse root-cause investigation (staffing, local supplier relationships) to explain
  the WH_South outlier rather than only flagging it.
- Deploy the stockout model as a lightweight API so it could plug directly into an ordering
  system rather than a periodic batch report.

## About the Data

The dataset used in this project is **synthetically generated** to match the exact fields this
business problem requires (no single public dataset combines all of them). Seasonal patterns,
promotions, and stockout dynamics were deliberately designed to be realistic, and validated
through independent statistical checks and correlation analysis throughout the project.
