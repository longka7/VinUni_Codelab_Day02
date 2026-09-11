# Student Guide — Lab 02: AI Product Scoping

`README.md` là hướng dẫn đầy đủ cho việc setup môi trường, cấu hình Gemini API key, workflow Git và quy trình nộp bài. Hãy đọc file đó trước khi làm bài.

## Cấu trúc chính

- `starter-code/prompt_prototype.py`: file thực hành Python.
- `01-worksheet.md`: worksheet scoping và Problem Statement.
- `02-deliverable-example.md`: ví dụ bài nộp.
- `03-inspiration-kit.md`: gợi ý tìm problem.
- `requirements.txt`: thư viện Python cần cài.
- `autograder/autograder.py`: kiểm tra file và prototype.

## Cài đặt nhanh trên Windows PowerShell

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

Nếu PowerShell chặn kích hoạt môi trường:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

## Chạy kiểm tra

```powershell
python -m py_compile starter-code/prompt_prototype.py
python autograder/autograder.py --section-a
```

## File cần nộp

- `01-problem-scan.md`
- `02-deep-dive-report.md`
- `03-ai-log.md`
- `04-workflow-diagram.png` hoặc `.pdf`

Điền tên nhóm, họ tên và email thành viên ở đầu mỗi file trước khi nộp. Mỗi thành viên commit trên branch cá nhân; không merge file `.py` vào `main`.
