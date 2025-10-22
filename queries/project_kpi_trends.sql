-- Project 2: KPI Trend Dashboard
-- Purpose: Compute yearly and cumulative budget vs actual performance KPIs.
CREATE OR REPLACE VIEW project_kpi_trends AS
SELECT 
    p.project_name,
    b.fiscal_year,
    SUM(b.budget_amount) AS budget_amount,
    SUM(a.actual_amount) AS actual_amount,
    ROUND(((SUM(a.actual_amount) - SUM(b.budget_amount)) / NULLIF(SUM(b.budget_amount),0)) * 100, 2) AS variance_percent,
    SUM(SUM(a.actual_amount)) OVER (PARTITION BY p.project_name ORDER BY b.fiscal_year) AS running_actuals,
    SUM(SUM(b.budget_amount)) OVER (PARTITION BY p.project_name ORDER BY b.fiscal_year) AS running_budget,
    ROUND(
        ((SUM(SUM(a.actual_amount)) OVER (PARTITION BY p.project_name ORDER BY b.fiscal_year))
        -
        (SUM(SUM(b.budget_amount)) OVER (PARTITION BY p.project_name ORDER BY b.fiscal_year)))
        /
        NULLIF(SUM(SUM(b.budget_amount)) OVER (PARTITION BY p.project_name ORDER BY b.fiscal_year),0)
        *100,2
    ) AS cumulative_variance_percent
FROM projects p
JOIN budget b ON p.project_id = b.project_id
JOIN actuals a ON p.project_id = a.project_id AND b.fiscal_year = a.fiscal_year
GROUP BY p.project_name, b.fiscal_year;
