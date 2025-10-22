-- ==========================================
-- View: project_variance_dashboard
-- Purpose: Summarize project-level spend vs budget across years
-- ==========================================

CREATE OR REPLACE VIEW project_variance_dashboard AS
SELECT 
    p.project_id,
    p.project_name,
    p.project_type,
    SUM(b.budget_amount)       AS total_budget,
    SUM(a.actual_amount)       AS total_actuals,
    SUM(a.actual_amount - b.budget_amount) AS total_variance,
    ROUND(((SUM(a.actual_amount) - SUM(b.budget_amount)) / NULLIF(SUM(b.budget_amount),0)) * 100, 2) AS total_variance_percent,
    CASE 
        WHEN SUM(a.actual_amount) > SUM(b.budget_amount) THEN 'Over Budget'
        ELSE 'Under Budget'
        
    END AS status
FROM projects p
JOIN budget b 
    ON p.project_id = b.project_id
JOIN actuals a 
    ON p.project_id = a.project_id 
   AND b.fiscal_year = a.fiscal_year
GROUP BY p.project_id, p.project_name, p.project_type;

