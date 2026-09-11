"""
Renders 04-workflow-diagram.png — Current-State Workflow for
"Vinmec: Soan tom tat ho so xuat vien" (longkhanh's individual Deep-Dive).

Run: python3 scripts/render_workflow_diagram.py
"""

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.lines import Line2D

steps = [
    {
        "title": "Bước 1",
        "desc": "Bệnh nhân đủ\nđiều kiện\nxuất viện",
        "actor": "Điều dưỡng/BS",
        "time": "2 phút",
        "flag": None,
    },
    {
        "title": "Bước 2",
        "desc": "Bác sĩ tổng hợp\nhồ sơ (chẩn đoán,\nthuốc, chỉ định)",
        "actor": "Bác sĩ điều trị",
        "time": "10 phút",
        "flag": "bottleneck",
    },
    {
        "title": "Bước 3",
        "desc": "Soạn tóm tắt\nxuất viện\nbằng tay",
        "actor": "Bác sĩ điều trị",
        "time": "15 phút",
        "flag": "bottleneck",
    },
    {
        "title": "Bước 4",
        "desc": "Ký duyệt",
        "actor": "Bác sĩ điều trị",
        "time": "3 phút",
        "flag": None,
    },
    {
        "title": "Bước 5",
        "desc": "Bàn giao cho\nbệnh nhân/\nkhoa khác",
        "actor": "Bác sĩ → BN/khoa",
        "time": "2 phút",
        "flag": "handoff",
    },
]

fig, ax = plt.subplots(figsize=(16, 5))
ax.set_xlim(0, 16)
ax.set_ylim(0, 5)
ax.axis("off")

box_w, box_h = 2.6, 3.0
gap = 0.55
start_x = 0.3
y0 = 1.0

colors = {
    None: ("#eef2f7", "#37424a"),
    "bottleneck": ("#fdeaea", "#c0392b"),
    "handoff": ("#eaf3fd", "#1f618d"),
}

centers = []
for i, step in enumerate(steps):
    x = start_x + i * (box_w + gap)
    face, edge = colors[step["flag"]]
    box = FancyBboxPatch(
        (x, y0), box_w, box_h,
        boxstyle="round,pad=0.06,rounding_size=0.08",
        linewidth=2, edgecolor=edge, facecolor=face,
    )
    ax.add_patch(box)
    cx = x + box_w / 2
    centers.append((x, cx, y0 + box_h))

    ax.text(cx, y0 + box_h - 0.35, step["title"], ha="center", va="top",
             fontsize=13, fontweight="bold", color=edge)
    ax.text(cx, y0 + box_h - 0.85, step["desc"], ha="center", va="top",
             fontsize=10, color="#1a1a1a", linespacing=1.4)
    ax.text(cx, y0 + 0.55, f"Ai: {step['actor']}", ha="center", va="center",
             fontsize=8.5, color="#444444")
    ax.text(cx, y0 + 0.2, f"Time: {step['time']}", ha="center", va="center",
             fontsize=9.5, fontweight="bold", color=edge)

    if step["flag"] == "bottleneck":
        ax.text(cx, y0 + box_h + 0.28, "BOTTLENECK", ha="center",
                 fontsize=9.5, color="#c0392b", fontweight="bold")
    if step["flag"] == "handoff":
        ax.text(cx, y0 + box_h + 0.28, "HANDOFF", ha="center",
                 fontsize=9.5, color="#1f618d", fontweight="bold")

for i in range(len(steps) - 1):
    _, cx1, _ = centers[i]
    x2, _, _ = centers[i + 1]
    arrow = FancyArrowPatch(
        (cx1 + box_w / 2 - 1.15, y0 + box_h / 2),
        (x2, y0 + box_h / 2),
        arrowstyle="-|>", mutation_scale=18, linewidth=2, color="#555555",
    )
    ax.add_patch(arrow)

ax.text(8, 0.35,
        "Tổng thời gian xử lý thủ công ước tính: ~30 phút/ca  |  Bottleneck chính: Bước 2-3 (tổng hợp + soạn thảo, 25 phút)",
        ha="center", fontsize=10.5, color="#333333")

ax.set_title(
    "Current-State Workflow — Vinmec: Soạn tóm tắt hồ sơ xuất viện\n(longkhanh — Individual Deep-Dive, Lab 02)",
    fontsize=14, fontweight="bold", pad=18,
)

plt.tight_layout()
plt.savefig("04-workflow-diagram.png", dpi=200, facecolor="white")
print("Saved 04-workflow-diagram.png")
