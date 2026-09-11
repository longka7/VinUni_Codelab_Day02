Add-Type -AssemblyName System.Drawing

$width = 1800
$height = 980
$bitmap = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.Color]::FromArgb(246, 248, 252))

$titleFont = New-Object System.Drawing.Font('Segoe UI', 30, [System.Drawing.FontStyle]::Bold)
$subtitleFont = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Regular)
$stepFont = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$bodyFont = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Regular)
$smallFont = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Regular)
$boldSmallFont = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)

$darkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(25, 39, 63))
$mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 94, 116))
$whiteBrush = [System.Drawing.Brushes]::White
$blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 100, 210))
$redBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(205, 45, 65))
$orangeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 135, 30))
$greenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(32, 145, 100))
$cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(198, 208, 224), 2)
$arrowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 88, 118), 5)
$arrowPen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(7, 9)

$graphics.DrawString('CURRENT-STATE WORKFLOW', $titleFont, $darkBrush, 60, 42)
$graphics.DrawString('Xanh SM — Xử lý sự cố xe có mức pin tới hạn', $subtitleFont, $mutedBrush, 62, 94)
$graphics.DrawString('Baseline giả định cần xác minh bằng log vận hành', $smallFont, $orangeBrush, 62, 127)

$steps = @(
    @{X=55;   Title='1. Báo sự cố'; Actor='Tài xế'; Lines=@('Gọi/nhắn điều phối', 'Mô tả tình trạng xe'); Time='1 phút'; Color=$blueBrush},
    @{X=395;  Title='2. Xác minh'; Actor='Điều phối viên'; Lines=@('GPS, mức pin', 'Xe và hành khách'); Time='2 phút'; Color=$blueBrush},
    @{X=735;  Title='3. Tra cứu'; Actor='Điều phối viên'; Lines=@('Trạm sạc gần nhất', 'Đội hỗ trợ phù hợp'); Time='3 phút'; Color=$redBrush; Bottleneck=$true},
    @{X=1075; Title='4. Đánh giá'; Actor='Điều phối viên'; Lines=@('So sánh phương án', 'Kiểm tra an toàn'); Time='2 phút'; Color=$redBrush; Bottleneck=$true},
    @{X=1415; Title='5. Chuyển yêu cầu'; Actor='Điều phối viên'; Lines=@('Soạn hướng dẫn', 'Gửi đội hỗ trợ'); Time='2 phút'; Color=$greenBrush}
)

$cardY = 235
$cardW = 275
$cardH = 390

foreach ($step in $steps) {
    $rect = New-Object System.Drawing.Rectangle($step.X, $cardY, $cardW, $cardH)
    $graphics.FillRectangle($cardBrush, $rect)
    $graphics.DrawRectangle($borderPen, $rect)
    $graphics.FillRectangle($step.Color, $step.X, $cardY, $cardW, 62)
    $graphics.DrawString($step.Title, $stepFont, $whiteBrush, $step.X + 18, $cardY + 16)
    $graphics.DrawString('ACTOR', $boldSmallFont, $mutedBrush, $step.X + 20, $cardY + 88)
    $graphics.DrawString($step.Actor, $bodyFont, $darkBrush, $step.X + 20, $cardY + 116)
    $graphics.DrawString('HOẠT ĐỘNG', $boldSmallFont, $mutedBrush, $step.X + 20, $cardY + 168)
    $lineY = $cardY + 199
    foreach ($line in $step.Lines) {
        $graphics.DrawString("• $line", $bodyFont, $darkBrush, $step.X + 20, $lineY)
        $lineY += 34
    }
    $graphics.FillRectangle($step.Color, $step.X + 20, $cardY + 314, $cardW - 40, 48)
    $graphics.DrawString("THỜI GIAN: $($step.Time)", $boldSmallFont, $whiteBrush, $step.X + 36, $cardY + 326)
    if ($step.Bottleneck) {
        $graphics.DrawString('BOTTLENECK', $boldSmallFont, $redBrush, $step.X + 80, $cardY + 370)
    }
}

for ($i = 0; $i -lt 4; $i++) {
    $startX = $steps[$i].X + $cardW + 8
    $endX = $steps[$i + 1].X - 12
    $midY = $cardY + 190
    $graphics.DrawLine($arrowPen, $startX, $midY, $endX, $midY)
}

$graphics.FillRectangle($orangeBrush, 320, 665, 250, 42)
$graphics.DrawString('HANDOFF 1', $boldSmallFont, $whiteBrush, 393, 676)
$graphics.DrawString('Tài xế → Điều phối', $smallFont, $mutedBrush, 365, 717)

$graphics.FillRectangle($orangeBrush, 1320, 665, 250, 42)
$graphics.DrawString('HANDOFF 2', $boldSmallFont, $whiteBrush, 1393, 676)
$graphics.DrawString('Điều phối → Tài xế/Đội hỗ trợ', $smallFont, $mutedBrush, 1325, 717)

$graphics.FillRectangle($darkBrush, 55, 800, 1665, 105)
$graphics.DrawString('TỔNG THỜI GIAN GIẢ ĐỊNH', $boldSmallFont, $whiteBrush, 90, 823)
$graphics.DrawString('10 phút / lượt', $titleFont, $whiteBrush, 90, 846)
$graphics.DrawString('Bottleneck: Tra cứu + đánh giá phương án = 5 phút', $stepFont, $whiteBrush, 720, 840)
$graphics.DrawString('Cần đo thật: thời gian từng bước • tỷ lệ dữ liệu thiếu • tỷ lệ escalation • tỷ lệ phương án phải sửa', $smallFont, $whiteBrush, 720, 876)

$outputPath = Join-Path $PSScriptRoot '04-workflow-diagram.png'
$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$bitmap.Dispose()
$titleFont.Dispose()
$subtitleFont.Dispose()
$stepFont.Dispose()
$bodyFont.Dispose()
$smallFont.Dispose()
$boldSmallFont.Dispose()
$darkBrush.Dispose()
$mutedBrush.Dispose()
$blueBrush.Dispose()
$redBrush.Dispose()
$orangeBrush.Dispose()
$greenBrush.Dispose()
$cardBrush.Dispose()
$borderPen.Dispose()
$arrowPen.Dispose()

Write-Output $outputPath
