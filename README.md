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

## no02: Excel とブラウザ画面編

YouTube「DuckDB 入門 #2」で使った材料です。`gen_sample.py` で作ったデータに、次の2つを足して使います。

| ファイル | 中身 |
|---|---|
| `budget.xlsx` | 営業部から届いた体の架空の予算（シート「予算」1枚。1行目に表題・2行目は空・3行目に見出し・4〜15行目に月×カテゴリの12行） |
| `gen_budget.py` | `budget.xlsx` を作るスクリプト（同じ中身の物が作れます） |

`gen_budget.py` を回す時だけ `pip install openpyxl` が要ります。`budget.xlsx` をそのまま使うだけなら要りません。`gen_sample.py` は引き続き標準ライブラリだけで動きます。

xlsx の書き出しと読み込みには DuckDB の excel 拡張を使います。最初に一度だけ次の2文を打ちます。

```sql
INSTALL excel;
LOAD excel;
```

本編で打った SQL は `queries_no02.sql` に画面に出した順で並べてあります（各文の頭に何をする文かの1行コメントつき）。`gen_sample.py` でデータを作ったフォルダに `budget.xlsx` を置き、そこで `duckdb` を起動して1つずつ貼って試せます。
