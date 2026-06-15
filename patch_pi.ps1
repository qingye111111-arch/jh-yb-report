# 快速补丁：为已有数据的 no 项目添加 pi
$OutputDir = "$env:USERPROFILE\Desktop\光大\光大环境投标报告"
$today = Get-Date -Format "yyyy-MM-dd"
Write-Host "正在爬取列表页提取项目编号..."

$all = @()
for ($p = 1; $p -le 30; $p++) {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = [System.Text.Encoding]::UTF8
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        $html = $wc.DownloadString("https://zcpt.cebenvironment.com.cn/cms/category/iframe.html?dates=300&categoryId=2&tabName=%E6%8B%9B%E6%A0%87%E5%85%AC%E5%91%8A&page=" + $p)
        $m = [regex]::Matches($html, '<a href="(https://zcpt\.cebenvironment\.com\.cn/ebi_bulletin/[^"]+)"\s+title="([^"]+)"[^>]*>')
        if ($m.Count -eq 0) { break }
        foreach ($x in $m) {
            $u = $x.Groups[1].Value
            $ti = $x.Groups[2].Value
            $pi = ""
            $z = [regex]::Match($u, "/([^/]+)$")
            if ($z.Success) { $pi = $z.Groups[1].Value }
            $all += @{ti = $ti; pi = $pi}
        }
        Write-Host "  第${p}页: $($m.Count)条"
        Start-Sleep -Milliseconds 500
    } catch { break }
}

Write-Host "共获取 $($all.Count) 条项目"

# 构建 title→pi 映射
$map = @{}
foreach ($x in $all) { $map[$x.ti] = $x.pi }

# 读取现有 JSON
$jsonFile = Join-Path $OutputDir ("data_" + $today + ".json")
$json = Get-Content $jsonFile -Encoding UTF8 -Raw

# 去除 BOM
if ($json[0] -eq 0xFEFF) { $json = $json.Substring(1) }
$data = $json | ConvertFrom-Json

# 为 no 项目添加 pi
$patched = 0
foreach ($x in $data.no) {
    $pi = $map[$x.ti]
    if ($pi) { 
        $x | Add-Member -NotePropertyName "pi" -NotePropertyValue $pi -Force
        $patched++
    }
}
Write-Host "已为 $patched 个项目补充编号"

# 保存 JSON
$data | ConvertTo-Json -Depth 3 | Out-File $jsonFile -Encoding UTF8
Write-Host "✅ JSON 已更新"
