#DB Browser 写SQL
#宽表视图
SELECT COUNT(*) FROM wide_table;
#整体核心指标
SELECT 
  COUNT(*) AS 订单量,
  COUNT(DISTINCT order_id) AS 去重订单量,
  ROUND(SUM(amount), 2) AS GMV,
  ROUND(SUM(net_amount), 2) AS 净收入,
  ROUND(SUM(net_amount) / COUNT(DISTINCT order_id), 2) AS 客单价,
  SUM(CASE WHEN order_status = '已退款' THEN 1 ELSE 0 END) AS 退款订单数,
  ROUND(SUM(CASE WHEN order_status = '已退款' THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS 退款率百分比,
  SUM(CASE WHEN order_status = '已取消' THEN 1 ELSE 0 END) AS 取消订单数,
  ROUND(SUM(CASE WHEN order_status = '已取消' THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS 取消率百分比
FROM wide_table;
#按月看净收入
SELECT 
  month AS 月份,
  COUNT(*) AS 订单量,
  ROUND(SUM(net_amount), 2) AS 净收入,
  ROUND(SUM(net_amount) / COUNT(DISTINCT order_id), 2) AS 客单价
FROM wide_table
GROUP BY month
ORDER BY month;
#按渠道看
SELECT 
  channel AS 渠道,
  COUNT(*) AS 订单量,
  ROUND(SUM(net_amount), 2) AS 净收入,
  ROUND(SUM(net_amount) / COUNT(DISTINCT order_id), 2) AS 客单价
FROM wide_table
GROUP BY channel
ORDER BY 净收入 DESC;
#按品类看
SELECT 
  product_name AS 品类,
  COUNT(*) AS 订单量,
  ROUND(SUM(net_amount), 2) AS 净收入,
  ROUND(SUM(net_amount) / COUNT(DISTINCT order_id), 2) AS 客单价
FROM wide_table
GROUP BY product_name
ORDER BY 净收入 DESC;
#全年目标达成率
SELECT 
  ROUND(SUM(w.net_amount), 2) AS 全年净收入,
  ROUND(SUM(t.target_revenue), 2) AS 全年目标,
  ROUND(SUM(w.net_amount) / SUM(t.target_revenue) * 100, 2) AS 全年达成率百分比
FROM wide_table w
LEFT JOIN daily_targets t ON DATE(w.order_date) = DATE(t.date);
#月度目标达成率
SELECT 
  w.month AS 月份,
  ROUND(SUM(w.net_amount), 2) AS 实际净收入,
  ROUND(SUM(t.target_revenue), 2) AS 目标收入,
  ROUND(SUM(w.net_amount) / SUM(t.target_revenue) * 100, 2) AS 达成率
FROM wide_table w
LEFT JOIN daily_targets t ON DATE(w.order_date) = DATE(t.date)
GROUP BY w.month
ORDER BY w.month;

#修正后的全年目标达成率（笛卡尔积问题）
SELECT 
  ROUND(SUM(actual), 2) AS 全年净收入,
  ROUND(SUM(target), 2) AS 全年目标,
  ROUND(SUM(actual) / SUM(target) * 100, 2) AS 全年达成率
FROM (
  SELECT 
    DATE(w.order_date) AS d,
    SUM(w.net_amount) AS actual,
    MAX(t.target_revenue) AS target
  FROM wide_table w
  LEFT JOIN daily_targets t ON DATE(w.order_date) = DATE(t.date)
  GROUP BY DATE(w.order_date)
) tmp;
#修正后的月度目标达成率（笛卡尔积问题）
SELECT 
  month AS 月份,
  ROUND(SUM(actual), 2) AS 实际净收入,
  ROUND(SUM(target), 2) AS 目标收入,
  ROUND(SUM(actual) / SUM(target) * 100, 2) AS 达成率
FROM (
  SELECT 
    w.month AS month,
    DATE(w.order_date) AS d,
    SUM(w.net_amount) AS actual,
    MAX(t.target_revenue) AS target
  FROM wide_table w
  LEFT JOIN daily_targets t ON DATE(w.order_date) = DATE(t.date)
  GROUP BY w.month, DATE(w.order_date)
) tmp
GROUP BY month
ORDER BY month;
