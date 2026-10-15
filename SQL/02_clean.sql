-- 02_clean.sql
-- 数据清洗SQL

-- 说明：实际清洗在Python中完成，这里保留核心清洗逻辑供参考

-- 1. 渠道去空格+大写
UPDATE orders SET channel = UPPER(TRIM(channel));

-- 2. 城市去“市”字
UPDATE users SET city = REPLACE(TRIM(city), '市', '');

-- 3. 日期格式标准化（SQLite中日期以文本存储，Python已处理）
-- 4. 衍生字段已通过Python写入wide_table

-- 验证清洗结果
SELECT DISTINCT channel FROM orders;
SELECT DISTINCT city FROM users WHERE city LIKE '%市%';