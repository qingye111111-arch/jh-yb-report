# 光大投标 - PDF 自动清理（删除超过7天的附件）
$pdfDir = "D:\光大环境投标报告\附件"
$daysOld = 7
$cutoff = (Get-Date).AddDays(-$daysOld)
$count = 0
$size = 0

if (Test-Path $pdfDir) {
    $files = Get-ChildItem -Path $pdfDir -Filter "*.pdf" -File | Where-Object { $_.LastWriteTime -lt $cutoff }
    foreach ($f in $files) {
        $size += $f.Length
        Remove-Item -Path $f.FullName -Force
        $count++
    }
    $savedMB = [math]::Round($size / 1MB, 1)
    Write-Host "已删除 $count 个过期PDF，释放 $savedMB MB 空间"
} else {
    Write-Host "附件目录不存在"
}