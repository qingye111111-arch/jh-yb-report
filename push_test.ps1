$sendKey = "SCT364802TDswGUcy8Xz8fdXXIXSVLMZlu"
$jsonData = Get-Content "C:\Users\Administrator\Desktop\光大\光大环境投标报告\data_2026-06-15.json" -Encoding UTF8 | ConvertFrom-Json
$titleMsg = "【测试】金湖仪表光大投标日报 " + $jsonData.date
$contentMsg = "📋 总公告：" + $jsonData.total + " | ✅ 推荐：" + $jsonData.cc + " | ⚠️ 核实：" + $jsonData.mc + "`n`n"
if ($jsonData.core.Count -gt 0) {
    $contentMsg += "【推荐投标】`n"
    $count = [Math]::Min(5, $jsonData.core.Count)
    for ($i = 0; $i -lt $count; $i++) {
        $num = $i + 1
        $contentMsg += "  " + $num + ". " + $jsonData.core[$i].ti + "`n"
    }
}
$contentMsg += "`n━━━━━━━━━━━━━`n📱 https://qingye111111-arch.github.io/jh-yb-report/"
$body = @{title=$titleMsg; desp=$contentMsg}
$resp = Invoke-RestMethod -Uri "https://sctapi.ftqq.com/$sendKey.send" -Method Post -Body $body
if ($resp.code -eq 0) { Write-Host "✅ 推送成功" }
