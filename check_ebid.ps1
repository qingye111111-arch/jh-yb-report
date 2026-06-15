param([string]$OutputDir = "$env:USERPROFILE\Desktop\光大\光大环境投标报告")
$OutputDir = $OutputDir.TrimEnd('\')
$script:today = Get-Date -Format "yyyy-MM-dd"
$pdfDir = Join-Path $OutputDir "附件"
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
if (-not (Test-Path $pdfDir)) { New-Item -ItemType Directory -Path $pdfDir -Force | Out-Null }
Write-Host "=== 光大环境投标筛选 | $script:today ==="
$core_kw = @(
  "热电偶","热电阻","温度计","双金属温度计","温度变送器","温度仪表","温度开关",
  "压力表","压力变送器","差压变送器","压力开关","隔膜压力表","膜盒压力表","电接点压力表","不锈钢压力表","真空压力表","防爆压力表","压力校验仪",
  "流量计","电磁流量计","涡街流量计","转子流量计","超声波流量计","质量流量计","涡轮流量计","孔板流量计","热式流量计","磁浮子流量计",
  "液位计","液位变送器","磁翻板液位计","雷达液位计","超声波液位计","浮球液位计","玻璃管液位计","液位开关","料位计","界面计",
  "数显仪表","调节仪","显示仪表","智能数显仪","巡检仪","配电器","隔离器","温度控制仪",
  "变送器","传感器","温度传感器","压力传感器","液位传感器","流量传感器",
  "执行机构","电动执行器","气动执行器","电动执行机构","调节阀","气动调节阀","电动调节阀",
  "CEMS","烟气分析仪","烟气","气体分析仪","气体检测仪","气体报警仪","分析仪","氨逃逸","粉尘仪","烟气在线监测","烟气排放",
  "DCS","PLC","模块","控制器","PLC控制","DCS控制","可编程","IO模块","卡件","控制系统","CPU模块",
  "安全阀","截止阀","球阀","蝶阀","闸阀","电磁阀","止回阀","减压阀","疏水阀","隔膜阀","旋塞阀","针型阀","排气阀","放空阀","低温阀",
  "电仪","仪控","仪表","仪器","自动化","电气仪表","仪控备件",
  "控制电缆","补偿导线","电线电缆","屏蔽电缆","信号电缆","电力电缆",
  "变频器","软启动","配电箱","开关柜","称重","汽车衡","电子秤","地磅",
  "PH计","电导率","溶解氧","余氯","浊度","水质分析","在线分析",
  "检定","校验","校准"
)
$maybe_kw = @("备品备件","备件","阀类","阀门","密封件","管件","法兰","紧固件","滤芯","密封垫","机务备件","水处理备件","加工件","管材","钢材","五金","电气","维修","检修","改造","安装","调试","维护","保养","更换","电动头","执行器","气动头","定位器","阀门配件","密封垫片")
function Test-Instrument($title){foreach($kw in $core_kw){if($title.IndexOf($kw)-ge 0){return "core"}}foreach($kw in $maybe_kw){if($title.IndexOf($kw)-ge 0){return "maybe"}}return "no"}
function Safe-Download($url,[int]$retries=3){for($i=0;$i-lt$retries;$i++){try{$wc=New-Object System.Net.WebClient;$wc.Encoding=[System.Text.Encoding]::UTF8;$wc.Headers.Add("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");return [System.Text.Encoding]::UTF8.GetString($wc.DownloadData($url))}catch{if($i-lt$retries-1){Start-Sleep -Milliseconds 2000}else{return $null}}}}
function Safe-DownloadFile($url,$path,[int]$retries=3){for($i=0;$i-lt$retries;$i++){try{$wc=New-Object System.Net.WebClient;$wc.Headers.Add("User-Agent","Mozilla/5.0");$wc.DownloadFile($url,$path);return $true}catch{if($i-lt$retries-1){Start-Sleep -Milliseconds 2000}else{return $false}}}}
function Get-Items{$all=@();for($p=1;$p-le30;$p++){$html=Safe-Download("https://zcpt.cebenvironment.com.cn/cms/category/iframe.html?dates=300&categoryId=2&tabName=%E6%8B%9B%E6%A0%87%E5%85%AC%E5%91%8A&page="+$p);if([string]::IsNullOrEmpty($html)){break};$m=[regex]::Matches($html,'<a href="(https://zcpt\.cebenvironment\.com\.cn/ebi_bulletin/[^"]+)"\s+title="([^"]+)"[^>]*>');if($m.Count-eq0){break};foreach($x in $m){$all+=@{url=$x.Groups[1].Value;title=$x.Groups[2].Value}};Write-Host("  第"+$p+"页: "+$m.Count+"条");Start-Sleep -Milliseconds 500};return $all}
function Get-Detail($url){$html=Safe-Download $url;if([string]::IsNullOrEmpty($html)){return @{p="";b="";c="";ph="";f="";dl=""}};$o=[System.Text.RegularExpressions.RegexOptions]::Singleline;$r=@{p="";b="";c="";ph="";f="";dl=""};$z=[regex]::Match($html,'\[([A-Za-z0-9-]+)\]',$o);if($z.Success){$r.p=$z.Groups[1].Value};$lb=@("招标人","联系人","联系电话");$fk=@("b","c","ph");for($i=0;$i-lt3;$i++){$pt='<th>'+$lb[$i]+'</th>(?:\s*)<td[^>]*>([^<]+)</td>';$z=[regex]::Match($html,$pt,$o);if($z.Success){$r[$fk[$i]]=$z.Groups[1].Value.Trim()}};$z=[regex]::Match($html,'openFileById%26id%3D([a-f0-9]+)',$o);if($z.Success){$r.f=$z.Groups[1].Value};$tz=[regex]::Match($html,'报价截止|截止时间|报价截止时间|投标截止',$o);if($tz.Success){$ctx=$html.Substring([Math]::Max(0,$tz.Index-30),[Math]::Min(180,$html.Length-[Math]::Max(0,$tz.Index-30)));$dz=[regex]::Match($ctx,'(\d{4}[-/年]\d{1,2}[-/月]\d{1,2})');if($dz.Success){$r.dl=$dz.Groups[1].Value.Trim()}};return $r}
function DnPdf($id,$proj,$title){if([string]::IsNullOrEmpty($id)){return $null};$sn=$title;if($sn.Length-gt40){$sn=$sn.Substring(0,40)};$sn=$sn-replace'[<>:"/\\|?*]','';$fn=$proj+"_"+$sn+".pdf";$fp=Join-Path $pdfDir $fn;if(Test-Path $fp){return $fn};if(Safe-DownloadFile "https://zcpt.cebenvironment.com.cn/dzzb/cgUploadController.do?openFileById&id=$id" $fp){Write-Host "    ↓ PDF: $fn";return $fn};return $null}
Write-Host "正在获取公告列表..."
$all=Get-Items
Write-Host ("共 "+$all.Count+" 条公告")
$c=@();$m=@();$n=@()
foreach($x in $all){switch(Test-Instrument $x.title){"core"{$c+=$x};"maybe"{$m+=$x};"no"{$n+=$x}}}
Write-Host ("[推荐投标] $($c.Count)  [需核实] $($m.Count)  [不相关] $($n.Count)")
$cd=@();$i=0
foreach($x in $c){$i++;Write-Host("  [$i/$($c.Count)] ")-NoNewline;$d=Get-Detail $x.url;Write-Host $d.p -NoNewline;$pf=DnPdf $d.f $d.p $x.title;$cd+=@{ti=$x.title;pi=$d.p;bu=$d.b;co=$d.c;ph=$d.ph;pf=$pf;dl=$d.dl};Start-Sleep -Milliseconds 300}
$md=@()
foreach($x in $m){$d=Get-Detail $x.url;$pf=DnPdf $d.f $d.p $x.title;$md+=@{ti=$x.title;pi=$d.p;bu=$d.b;co=$d.c;ph=$d.ph;pf=$pf;dl=$d.dl}}
$json=@{date=$script:today;time=(Get-Date -Format "yyyy-MM-dd HH:mm");total=$all.Count;cc=$c.Count;mc=$m.Count;nc=$n.Count;core=$cd;maybe=$md}|ConvertTo-Json -Depth 3
$json|Out-File (Join-Path $OutputDir ("data_"+$script:today+".json")) -Encoding UTF8
Write-Host "JSON 已保存"

# 生成带数据嵌入的 HTML 报告页面
& "node" "generate_html.js" 2>&1 | Out-Null
Write-Host "✅ HTML 报告已生成"

# --- Server酱微信推送（含手机访问链接）---
$sendKey = "SCT364802TDswGUcy8Xz8fdXXIXSVLMZlu"
$jsonFile = Join-Path $OutputDir ("data_" + $script:today + ".json")
if (Test-Path $jsonFile) {
    $jsonData = Get-Content $jsonFile -Encoding UTF8 | ConvertFrom-Json
    # 获取本机局域网 IP
    $localIP = ""
    $ipInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.PrefixOrigin -ne "WellKnown" -and $_.IPAddress -notlike "169.*" }
    if ($ipInfo) { $localIP = ($ipInfo | Select-Object -First 1).IPAddress }
    $serverUrl = "http://" + $localIP + ":8080"
    $titleMsg = "金湖仪表光大投标日报 " + $jsonData.date
    $contentMsg = ""
    $contentMsg += "总公告：" + $jsonData.total + " 条"
    $contentMsg += " | 推荐：" + $jsonData.cc + " 项"
    $contentMsg += " | 核实：" + $jsonData.mc + " 项`n`n"
    $contentMsg += "━━━ 推荐投标 ━━━`n"
    if ($jsonData.core.Count -gt 0) {
        $count = [Math]::Min(10, $jsonData.core.Count)
        for ($i = 0; $i -lt $count; $i++) {
            $item = $jsonData.core[$i]
            $num = $i + 1
            $contentMsg += "  " + $num + ". " + $item.ti + "`n"
        }
    }
    if ($jsonData.maybe.Count -gt 0) {
        $contentMsg += "`n── 需核实 " + $jsonData.mc + " 项 ──`n"
        $mcount = [Math]::Min(5, $jsonData.maybe.Count)
        for ($i = 0; $i -lt $mcount; $i++) {
            $contentMsg += "  - " + $jsonData.maybe[$i].ti + "`n"
        }
    }
    $contentMsg += "`n━━━━━━━━━━━━━━━━`n"
    $contentMsg += "📱 手机查看完整报告（含PDF）:`n"
    $contentMsg += $serverUrl + "`n"
    $contentMsg += "（手机须连同一个WiFi）"
    try {
        $body = @{title=$titleMsg; desp=$contentMsg}
        $resp = Invoke-RestMethod -Uri "https://sctapi.ftqq.com/$sendKey.send" -Method Post -Body $body
        if ($resp.code -eq 0) { Write-Host "✅ 微信推送成功" }
        else { Write-Host "⚠️ 推送失败" }
    } catch { Write-Host "⚠️ 推送出错" }
}
