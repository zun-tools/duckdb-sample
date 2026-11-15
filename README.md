# duckdb-sample

YouTube「DuckDB 入門」（ずんだもん）の本編で使ったサンプルデータと SQL です。データはすべて架空で、個人情報は含みません。

## 使い方

Python 3 が要ります（標準ライブラリだけで動きます）。

```sh
mkdir duckdb-trial && cd duckdb-trial
python3 /path/to/gen_sample.py
duckdb
```

`gen_sample.py` は実行したフォルダに次のファイルを作ります。乱数の種を固定しているので、何度作っても同じ中身になります。

| ファイル | 中身 |
|---|---|
| `sales_2026_01.csv`〜`sales_2026_03.csv` | 3か月分の売上（計 6,000 行・合計 513,894,610） |
| `products.json` | 商品マスター（タグの配列やスペックの入れ子を含む） |
| `sales_corrupted.csv` | 単価や金額の列に `N/A` や `未定` が混じった CSV（100 行） |
| `sales_sjis.csv` | Shift_JIS で保存した CSV |

本編で打った SQL は `queries.sql` に画面に出した順で並べてあります。
