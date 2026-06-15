$OutputDir = "$env:USERPROFILE\Desktop\光大\光大环境投标报告"
$today = "2026-06-15"
$jsonFile = Join-Path $OutputDir "data_$today.json"

Write-Host "=== 为 no 项目补充真实编号 ==="

# Step 1: 爬取列表页，获取所有项目的 URL→标题 映射
Write-Host "第1步：爬取列表页..."
$urlMap = @{}
for ($p = 1; $p -le 30; $p++) {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = [System.Text.Encoding]::UTF8
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        $html = $wc.DownloadString("https://zcpt.cebenvironment.com.cn/cms/category/iframe.html?dates=300&categoryId=2&tabName=%E6%8B%9B%E6%A0%87%E5%85%AC%E5%91%8A&page=$p")
        $m = [regex]::Matches($html, '<a href="(https://zcpt\.cebenvironment\.com\.cn/ebi_bulletin/[^"]+)"\s+title="([^"]+)"[^>]*>')
        if ($m.Count -eq 0) { break }
        foreach ($x in $m) {
            $urlMap[$x.Groups[2].Value] = $x.Groups[1].Value
        }
        Write-Host "  第${p}页: $($m.Count)条"
        Start-Sleep -Milliseconds 400
    } catch { break }
}
Write-Host "共获取 $($urlMap.Count) 条 URL"

# Step 2: 读取 JSON
Write-Host "第2步：读取现有数据..."
$json = Get-Content $jsonFile -Encoding UTF8 -Raw
if ($json[0] -eq 0xFEFF) { $json = $json.Substring(1) }
$data = $json | ConvertFrom-Json

# Step 3: 为每个 no 项目抓取详情页提取编号
Write-Host "第3步：抓取详情页提取编号..."
$total = $data.no.Count
$found = 0
$i = 0
foreach ($x in $data.no) {
    $i++
    $ti = $x.ti
    $url = $urlMap[$ti]
    if (-not $url) { continue }
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = [System.Text.Encoding]::UTF8
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        $detail = $wc.DownloadString($url)
        $z = [regex]::Match($detail, '\[([A-Za-z0-9-]+)\]')
        if ($z.Success) {
            $x | Add-Member -NotePropertyName "pi" -NotePropertyValue $z.Groups[1].Value -Force
            $found++
        }
        Start-Sleep -Milliseconds 200
    } catch { }
    if ($i % 20 -eq 0) { Write-Host "  $i/$total ... (已找到 $found 个编号)" }
}
Write-Host "✅ 已为 $found / $total 个项目提取到真实编号"

# Step 4: 保存
$data | ConvertTo-Json -Depth 3 | Out-File $jsonFile -Encoding UTF8
Write-Host "✅ JSON 已保存"
