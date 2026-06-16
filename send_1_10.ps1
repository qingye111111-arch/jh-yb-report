$key = "SCT364802TDswGUcy8Xz8fdXXIXSVLMZlu"
$localIP = ""
$ipInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.PrefixOrigin -ne "WellKnown" -and $_.IPAddress -notlike "169.*" }
if ($ipInfo) { $localIP = ($ipInfo | Select-Object -First 1).IPAddress }
$serverUrl = "http://" + $localIP + ":8080"
if (-not $localIP) { $serverUrl = "http://localhost:8080" }

$content = "电脑访问：" + [char]10
$content += "http://localhost:8080/" + [char]10 + [char]10
$content += "手机访问（同WiFi）：" + [char]10
$content += $serverUrl + [char]10 + [char]10
$content += "GitHub Pages：" + [char]10
$content += "https://qingye111111-arch.github.io/jh-yb-report/"

$body = @{title="光大投标 · 每日报告 2026-06-15"; desp=$content}
$resp = Invoke-RestMethod -Uri "https://sctapi.ftqq.com/$key.send" -Method Post -Body $body
