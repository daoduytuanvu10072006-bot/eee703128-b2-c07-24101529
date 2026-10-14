#!/usr/bin/env python3
"""Đọc metrics.json của LibreLane và in ra các chỉ số chính."""
import json
import sys

with open(sys.argv[1]) as f:
    d = json.load(f)

keys = [
    ("design__instance__count",       "So cell"),
    ("design__instance__area",        "Dien tich (um^2)"),
    ("design__core__area",            "Dien tich core (um^2)"),
    ("design__instance__count__stdcell", "So std cell"),
    ("timing__setup__ws",             "Setup WS (ns)"),
    ("timing__setup__tns",            "Setup TNS (ns)"),
    ("timing__hold__ws",              "Hold WS (ns)"),
    ("power__total",                  "Tong cong suat (W)"),
    ("power__internal__total",        "Cong suat dong (W)"),
    ("power__leakage__total",         "Cong suat ro (W)"),
]

for k, label in keys:
    v = d.get(k, "(khong co)")
    print(f"{label}: {v}")
