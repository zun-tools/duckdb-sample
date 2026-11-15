#!/usr/bin/env python3
"""DuckDB 入門の本編で使うサンプルデータを、実行したフォルダに作る（架空のデータ・個人情報なし）"""
import csv
import json
import os
import random
from datetime import date, timedelta

random.seed(20261114)

WORK_DIR = "."  # 実行したフォルダにファイルを作る
os.makedirs(WORK_DIR, exist_ok=True)

# 1. 商品マスター JSON（ネストした構造を含む）
products = [
    {
        "product_id": "P001",
        "name": "メカニカルキーボード 60%",
        "category": "PC周辺機器",
        "base_cost": 12000,
        "tags": ["ハードウェア", "人気", "静音赤軸"],
        "spec": {"switch": "silent-red", "wireless": True, "battery_hours": 40},
    },
    {
        "product_id": "P002",
        "name": "トラックボールマウス",
        "category": "PC周辺機器",
        "base_cost": 8500,
        "tags": ["ハードウェア", "エルゴノミクス"],
        "spec": {"sensor": "optical", "wireless": True, "battery_hours": 120},
    },
    {
        "product_id": "P003",
        "name": "ウルトラワイドモニター 34型",
        "category": "ディスプレイ",
        "base_cost": 58000,
        "tags": ["大型", "IPS", "USB-PD"],
        "spec": {"resolution": "3440x1440", "refresh_rate": 144, "usb_c_pd": 90},
    },
    {
        "product_id": "P004",
        "name": "ノイズキャンセリングヘッドセット",
        "category": "オーディオ",
        "base_cost": 24000,
        "tags": ["マイク", "ANC", "Bluetooth"],
        "spec": {"anc_level": "high", "weight_g": 250},
    },
    {
        "product_id": "P005",
        "name": "USB-C デスク用ドック 12-in-1",
        "category": "アクセサリ",
        "base_cost": 15000,
        "tags": ["ハブ", "4K60Hz", "10Gbps"],
        "spec": {"ports": 12, "host_interface": "USB-C 3.2 Gen2"},
    },
]

with open(f"{WORK_DIR}/products.json", "w", encoding="utf-8") as f:
    json.dump(products, f, ensure_ascii=False, indent=2)

# 2. 月別売上 CSV（2026年1月〜3月、各 2,000 件）
months = [
    ("2026_01", date(2026, 1, 1), 31),
    ("2026_02", date(2026, 2, 1), 28),
    ("2026_03", date(2026, 3, 1), 31),
]

customer_types = ["一般会員", "プレミアム", "法人", "ゲスト"]
notes = ["通常発送", "置き配指定", "日時指定", "特急便", "ギフト包装", ""]

for m_label, start_d, days in months:
    fname = f"{WORK_DIR}/sales_{m_label}.csv"
    with open(fname, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "order_id", "order_date", "product_id", "quantity",
            "unit_price", "amount", "customer_type", "secret_memo", "note"
        ])
        for i in range(1, 2001):
            p = random.choice(products)
            q = random.randint(1, 5) if p["category"] != "法人" else random.randint(5, 20)
            unit_price = int(p["base_cost"] * random.uniform(1.1, 1.35))
            amount = q * unit_price
            order_date = start_d + timedelta(days=random.randint(0, days - 1))
            secret_memo = f"INTERNAL_LOG_{random.randint(1000, 9999)}"
            writer.writerow([
                f"ORD-{m_label}-{i:04d}",
                order_date.isoformat(),
                p["product_id"],
                q,
                unit_price,
                amount,
                random.choice(customer_types),
                secret_memo,
                random.choice(notes),
            ])

# 3. 落とし穴検証用: 型推論破綻 CSV（数値列への文字列混入・欠損）
corrupted_file = f"{WORK_DIR}/sales_corrupted.csv"
with open(corrupted_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["order_id", "order_date", "product_id", "quantity", "unit_price", "amount"])
    for i in range(1, 101):
        if i == 42:
            writer.writerow([f"ORD-BAD-{i:03d}", "2026-04-01", "P001", "3", "12000", "N/A"])
        elif i == 75:
            writer.writerow([f"ORD-BAD-{i:03d}", "2026-04-02", "P002", "1", "未定", "未定"])
        else:
            writer.writerow([f"ORD-BAD-{i:03d}", "2026-04-01", "P001", "2", "12000", "24000"])

# 4. 落とし穴検証用: Shift_JIS エンコーディング CSV
sjis_file = f"{WORK_DIR}/sales_sjis.csv"
with open(sjis_file, "w", newline="", encoding="shift_jis", errors="replace") as f:
    writer = csv.writer(f)
    writer.writerow(["注文番号", "商品名", "区分", "金額"])
    writer.writerow(["S001", "日本語メカニカルキーボード", "通販", "15000"])
    writer.writerow(["S002", "静音マウスパッド", "店舗", "2500"])
    writer.writerow(["S003", "有線LANアダプタ", "法人", "3800"])

print("All sample files generated successfully in", WORK_DIR)
