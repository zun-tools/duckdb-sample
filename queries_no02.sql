-- DuckDB 入門 #2（Excel とブラウザ画面編）で打った SQL（画面に出した順）
-- gen_sample.py でデータを作ったフォルダに budget.xlsx も置き、そこで duckdb を起動して1つずつ貼って試せます。
-- 1・2・4・5 は先に excel 拡張が要ります: INSTALL excel; LOAD excel;  （書き出しは自動では読み込まれません）

INSTALL excel;
LOAD excel;

-- 1. CSV 3本と JSON をつないだカテゴリ別の売上を、xlsx にして書き出す
COPY (
  SELECT p.category, p.name,
         count(s.order_id) AS order_count,
         sum(s.quantity)   AS total_qty,
         sum(s.amount)     AS total_revenue
  FROM 'sales_2026_*.csv' s
  JOIN 'products.json' p ON s.product_id = p.product_id
  GROUP BY p.category, p.name
  ORDER BY total_revenue DESC
) TO 'report.xlsx' (FORMAT xlsx, HEADER true);

-- 2. 明細から社内用の列（secret_memo）を外して、シート名「1-3月」の xlsx にして渡す
COPY (SELECT * EXCLUDE (secret_memo) FROM 'sales_2026_*.csv')
  TO 'sales_q1.xlsx' (FORMAT xlsx, HEADER true, SHEET '1-3月');

-- 3. 予算の xlsx（表題と空行つき）を range で読み、売上と突き合わせて達成率の低い順に3行見る
SELECT b.月, b.カテゴリ, b.予算,
       sum(s.amount) AS 実績,
       round(sum(s.amount) / b.予算 * 100, 1) AS 達成率
FROM read_xlsx('budget.xlsx', range = 'A3:C15') b
JOIN 'products.json' p ON p.category = b.カテゴリ
JOIN 'sales_2026_*.csv' s ON s.product_id = p.product_id
                         AND strftime(s.order_date, '%Y-%m') = b.月
GROUP BY b.月, b.カテゴリ, b.予算
ORDER BY 達成率
LIMIT 3;

-- 4. 予実を xlsx にして返す（中身は 3 の SELECT から LIMIT を外し、月・カテゴリ順にした物）
COPY (
  SELECT b.月, b.カテゴリ, b.予算,
         sum(s.amount) AS 実績,
         round(sum(s.amount) / b.予算 * 100, 1) AS 達成率
  FROM read_xlsx('budget.xlsx', range = 'A3:C15') b
  JOIN 'products.json' p ON p.category = b.カテゴリ
  JOIN 'sales_2026_*.csv' s ON s.product_id = p.product_id
                           AND strftime(s.order_date, '%Y-%m') = b.月
  GROUP BY b.月, b.カテゴリ, b.予算
  ORDER BY b.月, b.カテゴリ
) TO 'yojitsu.xlsx' (FORMAT xlsx, HEADER true, SHEET '予実');

-- 5. HEADER を付けずに書き出す（見出しの行が無い xlsx になる。読み戻すと列名が A1・B1…）
COPY (FROM 'sales_2026_01.csv' LIMIT 5) TO 'noheader.xlsx' (FORMAT xlsx);
FROM 'noheader.xlsx';

-- 6. duckdb -ui のブラウザ画面のセルに貼る予実（4 の中の SELECT と同じ）
SELECT b.月, b.カテゴリ, b.予算,
       sum(s.amount) AS 実績,
       round(sum(s.amount) / b.予算 * 100, 1) AS 達成率
FROM read_xlsx('budget.xlsx', range = 'A3:C15') b
JOIN 'products.json' p ON p.category = b.カテゴリ
JOIN 'sales_2026_*.csv' s ON s.product_id = p.product_id
                         AND strftime(s.order_date, '%Y-%m') = b.月
GROUP BY b.月, b.カテゴリ, b.予算
ORDER BY b.月, b.カテゴリ;
