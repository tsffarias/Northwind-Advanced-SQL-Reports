-- Projeto: sales_accumulated_monthly_mv
-- Motivação: Este conjunto de comandos SQL define uma ETL (Extração, Transformação e Carregamento) para gerar um relatório de vendas acumuladas mensais. A ETL consiste em uma visualização materializada chamada sales_accumulated_monthly_mv e duas triggers que garantem que a visualização seja atualizada sempre que houver alterações nas tabelas order_details e orders.

CREATE MATERIALIZED VIEW sales_accumulated_monthly_mv AS
SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS accumulated_sales
FROM
    order_details od
JOIN
    orders o ON o.order_id = od.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date)
ORDER BY
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date);


-- Function
CREATE OR REPLACE FUNCTION refresh_sales_accumulated_monthly_mv()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW sales_accumulated_monthly_mv;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER trg_refresh_sales_accumulated_monthly_mv_order_details
AFTER INSERT OR UPDATE OR DELETE ON order_details
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_sales_accumulated_monthly_mv();

CREATE TRIGGER trg_refresh_sales_accumulated_monthly_mv_orders
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_sales_accumulated_monthly_mv();