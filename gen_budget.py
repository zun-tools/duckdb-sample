#!/usr/bin/env python3
"""架空の予算 Excel（budget.xlsx）を作る。実行: python3 gen_budget.py（要 pip install openpyxl）。
カレントディレクトリに budget.xlsx を書く。シートは「予算」の1枚だけ。"""
import openpyxl

wb = openpyxl.Workbook()
ws = wb.active
ws.title = "予算"
ws["A1"] = "2026年 第1四半期 カテゴリ別予算（営業部）"
ws.append([])
ws.append(["月", "カテゴリ", "予算"])
b = {"PC周辺機器": 30000000, "アクセサリ": 21000000, "オーディオ": 36000000, "ディスプレイ": 88000000}
for m in ["2026-01", "2026-02", "2026-03"]:
    for k, v in b.items():
        ws.append([m, k, v])
wb.save("budget.xlsx")
print("wrote budget.xlsx")
