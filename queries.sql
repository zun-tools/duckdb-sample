-- DuckDB 入門の本編で打った SQL（画面に出した順）
-- gen_sample.py でデータを作ったフォルダで duckdb を起動し、1つずつ貼って試せます。

-- 1. CSV をそのまま読む
SELECT order_id, order_date, product_id, quantity, amount FROM 'sales_2026_01.csv' LIMIT 5;

-- 2. 3か月分の CSV をワイルドカードで一度に
SELECT count(*) AS total_rows, sum(amount) AS total_sales FROM 'sales_2026_*.csv';

-- 3. JSON の元の形を覗く／ネストした中身を列として読む
.shell head -17 products.json
SELECT product_id, name, category, tags[1] AS first_tag, spec.battery_hours AS battery FROM 'products.json';

-- 4. CSV と JSON を JOIN
SELECT p.category, p.name,
       count(s.order_id) AS order_count,
       sum(s.quantity)   AS total_qty,
       sum(s.amount)     AS total_revenue
FROM 'sales_2026_*.csv' s
JOIN 'products.json' p ON s.product_id = p.product_id
GROUP BY p.category, p.name
ORDER BY total_revenue DESC;

-- 5. 書き方を短くする（SELECT 省略・DESCRIBE・SUMMARIZE）
FROM 'sales_2026_01.csv' LIMIT 3;
DESCRIBE FROM 'sales_2026_01.csv';
SUMMARIZE 'sales_2026_01.csv';

-- 6. GROUP BY ALL
SELECT customer_type, product_id, count(*) AS count, sum(amount) AS total_amount
FROM 'sales_2026_01.csv'
GROUP BY ALL
ORDER BY total_amount DESC
LIMIT 5;

-- 7. PIVOT（月 × カテゴリ）
PIVOT (
  SELECT strftime(s.order_date, '%Y-%m') AS month, p.category, s.amount
  FROM 'sales_2026_*.csv' s
  JOIN 'products.json' p ON s.product_id = p.product_id
)
ON category USING sum(amount)
GROUP BY month
ORDER BY month;

-- 8. CSV 3本を Parquet 1本へ
COPY (FROM 'sales_2026_*.csv')
  TO 'sales_all.parquet' (FORMAT parquet, COMPRESSION zstd);
.shell ls -lh sales_2026_*.csv sales_all.parquet
SELECT count(*), sum(amount) FROM 'sales_all.parquet';
SELECT count(*), sum(amount) FROM 'sales_2026_*.csv';
SELECT customer_type, count(*) AS orders, sum(amount) AS total FROM 'sales_all.parquet' GROUP BY ALL ORDER BY total DESC;

-- 9. 型がおかしい CSV（N/A や 未定 が混じる）
SUMMARIZE 'sales_corrupted.csv';
SELECT sum(amount) FROM 'sales_corrupted.csv';  -- エラーになる
DESCRIBE FROM read_csv('sales_corrupted.csv', nullstr = ['N/A', '未定']);
SELECT count(*) AS rows, sum(amount) AS total FROM read_csv('sales_corrupted.csv', nullstr = ['N/A', '未定']);

-- 10. Shift_JIS の CSV
FROM 'sales_sjis.csv';  -- エラーになる
FROM read_csv('sales_sjis.csv', encoding = 'shift_jis');  -- 拡張なしではエラー
INSTALL encodings; LOAD encodings;  -- 初回だけネットから取得
FROM read_csv('sales_sjis.csv', encoding = 'shift_jis');
