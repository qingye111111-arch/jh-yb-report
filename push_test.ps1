$sendKey = "SCT364802TDswGUcy8Xz8fdXXIXSVLMZlu"
$githubPagesUrl = "https://qingye111111-arch.github.io/jh-yb-report/"
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.PrefixOrigin -ne "WellKnown" -and $_.IPAddress -notlike "169.*" } | Select-Object -First 1).IPAddress
$localUrl = "http://" + $localIP + ":8080"
$titleMsg = "【测试】金湖仪表 · 光大投标日报"
$contentMsg = "电脑查看完整报告：`n" + $localUrl + "`n`n"
$contentMsg += "手机查看完整报告：`n" + $githubPagesUrl
$body = @{title=$titleMsg; desp=$contentMsg}
Invoke-RestMethod -Uri "https://sctapi.ftqq.com/$sendKey.send" -Method Post -Body $body
