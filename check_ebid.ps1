param([string]$OutputDir = "D:\鍏夊ぇ鐜鎶曟爣鎶ュ憡")
. .\deploy_config.ps1
$OutputDir = $OutputDir.TrimEnd('\')
$script:today = Get-Date -Format "yyyy-MM-dd"
$pdfDir = Join-Path $OutputDir "闄勪欢"
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
if (-not (Test-Path $pdfDir)) { New-Item -ItemType Directory -Path $pdfDir -Force | Out-Null }
Write-Host "=== 鍏夊ぇ鐜鎶曟爣绛涢€?| $script:today ==="
$core_kw = @(
  "鐑數鍋?,"鐑數闃?,"娓╁害璁?,"鍙岄噾灞炴俯搴﹁","娓╁害鍙橀€佸櫒","娓╁害浠〃","娓╁害寮€鍏?,
  "鍘嬪姏琛?,"鍘嬪姏鍙橀€佸櫒","宸帇鍙橀€佸櫒","鍘嬪姏寮€鍏?,"闅旇啘鍘嬪姏琛?,"鑶滅洅鍘嬪姏琛?,"鐢垫帴鐐瑰帇鍔涜〃","涓嶉攬閽㈠帇鍔涜〃","鐪熺┖鍘嬪姏琛?,"闃茬垎鍘嬪姏琛?,"鍘嬪姏鏍￠獙浠?,
  "娴侀噺璁?,"鐢电娴侀噺璁?,"娑¤娴侀噺璁?,"杞瓙娴侀噺璁?,"瓒呭０娉㈡祦閲忚","璐ㄩ噺娴侀噺璁?,"娑¤疆娴侀噺璁?,"瀛旀澘娴侀噺璁?,"鐑紡娴侀噺璁?,"纾佹诞瀛愭祦閲忚",
  "娑蹭綅璁?,"娑蹭綅鍙橀€佸櫒","纾佺炕鏉挎恫浣嶈","闆疯揪娑蹭綅璁?,"瓒呭０娉㈡恫浣嶈","娴悆娑蹭綅璁?,"鐜荤拑绠℃恫浣嶈","娑蹭綅寮€鍏?,"鏂欎綅璁?,"鐣岄潰璁?,
  "鏁版樉浠〃","璋冭妭浠?,"鏄剧ず浠〃","鏅鸿兘鏁版樉浠?,"宸℃浠?,"閰嶇數鍣?,"闅旂鍣?,"娓╁害鎺у埗浠?,
  "鍙橀€佸櫒","浼犳劅鍣?,"娓╁害浼犳劅鍣?,"鍘嬪姏浼犳劅鍣?,"娑蹭綅浼犳劅鍣?,"娴侀噺浼犳劅鍣?,
  "鎵ц鏈烘瀯","鐢靛姩鎵ц鍣?,"姘斿姩鎵ц鍣?,"鐢靛姩鎵ц鏈烘瀯","璋冭妭闃€","姘斿姩璋冭妭闃€","鐢靛姩璋冭妭闃€",
  "CEMS","鐑熸皵鍒嗘瀽浠?,"鐑熸皵","姘斾綋鍒嗘瀽浠?,"姘斾綋妫€娴嬩华","姘斾綋鎶ヨ浠?,"鍒嗘瀽浠?,"姘ㄩ€冮€?,"绮夊皹浠?,"鐑熸皵鍦ㄧ嚎鐩戞祴","鐑熸皵鎺掓斁",
  "DCS","PLC","妯″潡","鎺у埗鍣?,"PLC鎺у埗","DCS鎺у埗","鍙紪绋?,"IO妯″潡","鍗′欢","鎺у埗绯荤粺","CPU妯″潡",
  "瀹夊叏闃€","鎴闃€","鐞冮榾","铦堕榾","闂搁榾","鐢电闃€","姝㈠洖闃€","鍑忓帇闃€","鐤忔按闃€","闅旇啘闃€","鏃嬪闃€","閽堝瀷闃€","鎺掓皵闃€","鏀剧┖闃€","浣庢俯闃€",
  "鐢典华","浠帶","浠〃","浠櫒","鑷姩鍖?,"鐢垫皵浠〃","浠帶澶囦欢",
  "鎺у埗鐢电紗","琛ュ伩瀵肩嚎","鐢电嚎鐢电紗","灞忚斀鐢电紗","淇″彿鐢电紗","鐢靛姏鐢电紗",
  "鍙橀鍣?,"杞惎鍔?,"閰嶇數绠?,"寮€鍏虫煖","绉伴噸","姹借溅琛?,"鐢靛瓙绉?,"鍦扮",
  "PH璁?,"鐢靛鐜?,"婧惰В姘?,"浣欐隘","娴婂害","姘磋川鍒嗘瀽","鍦ㄧ嚎鍒嗘瀽",
  "妫€瀹?,"鏍￠獙","鏍″噯",
  "鍙戠數鏈?,"鍙戠數鏈虹粍","鐢靛姩鏈?,"鍙樺帇鍣?,"姹借疆鏈?,"椋庢満","姘存车","鍘嬬缉鏈?,"楂樹綆鍘嬫煖","楂樹綆鍘嬪紑鍏虫煖","鎺у埗鏌?
)
$maybe_kw = @("澶囧搧澶囦欢","澶囦欢","闃€绫?,"闃€闂?,"瀵嗗皝浠?,"绠′欢","娉曞叞","绱у浐浠?,"婊よ姱","瀵嗗皝鍨?,"鏈哄姟澶囦欢","姘村鐞嗗浠?,"鍔犲伐浠?,"绠℃潗","閽㈡潗","浜旈噾","鐢垫皵","鐢靛姩澶?,"鎵ц鍣?,"姘斿姩澶?,"瀹氫綅鍣?,"闃€闂ㄩ厤浠?,"瀵嗗皝鍨墖")
function Test-Instrument($title){foreach($kw in $core_kw){if($title.IndexOf($kw)-ge 0){return "core"}}foreach($kw in $maybe_kw){if($title.IndexOf($kw)-ge 0){return "maybe"}}return "no"}
function Safe-Download($url,[int]$retries=3){for($i=0;$i-lt$retries;$i++){try{$wc=New-Object System.Net.WebClient;$wc.Encoding=[System.Text.Encoding]::UTF8;$wc.Headers.Add("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");return [System.Text.Encoding]::UTF8.GetString($wc.DownloadData($url))}catch{if($i-lt$retries-1){Start-Sleep -Milliseconds 2000}else{return $null}}}}
function Safe-DownloadFile($url,$path,[int]$retries=3){for($i=0;$i-lt$retries;$i++){try{$wc=New-Object System.Net.WebClient;$wc.Headers.Add("User-Agent","Mozilla/5.0");$wc.DownloadFile($url,$path);return $true}catch{if($i-lt$retries-1){Start-Sleep -Milliseconds 2000}else{return $false}}}}
function Get-Items{$all=@();for($p=1;$p-le30;$p++){$html=Safe-Download("https://zcpt.cebenvironment.com.cn/cms/category/iframe.html?dates=300&categoryId=2&tabName=%E6%8B%9B%E6%A0%87%E5%85%AC%E5%91%8A&page="+$p);if([string]::IsNullOrEmpty($html)){break};$m=[regex]::Matches($html,'<a href="(https://zcpt\.cebenvironment\.com\.cn/ebi_bulletin/[^"]+)"\s+title="([^"]+)"[^>]*>');if($m.Count-eq0){break};foreach($x in $m){$u=$x.Groups[1].Value;$pt="";$z2=[regex]::Match($u,"/ebi_bulletin/(\d{4}-\d{2}-\d{2})/");if($z2.Success){$pt=$z2.Groups[1].Value};$all+=@{url=$u;title=$x.Groups[2].Value;pt=$pt}};Write-Host("  绗?+$p+"椤? "+$m.Count+"鏉?);Start-Sleep -Milliseconds 500};return $all}
function Get-Detail($url){$html=Safe-Download $url;if([string]::IsNullOrEmpty($html)){return @{p="";b="";c="";ph="";f="";dl=""}};$o=[System.Text.RegularExpressions.RegexOptions]::Singleline;$r=@{p="";b="";c="";ph="";f="";dl=""};$z=[regex]::Match($html,'\[([A-Za-z0-9-]+)\]',$o);if($z.Success){$r.p=$z.Groups[1].Value};$lb=@("鎷涙爣浜?,"鑱旂郴浜?,"鑱旂郴鐢佃瘽");$fk=@("b","c","ph");for($i=0;$i-lt3;$i++){$pt='<th>'+$lb[$i]+'</th>(?:\s*)<td[^>]*>([^<]+)</td>';$z=[regex]::Match($html,$pt,$o);if($z.Success){$r[$fk[$i]]=$z.Groups[1].Value.Trim()}};$z=[regex]::Match($html,'openFileById%26id%3D([a-f0-9]+)',$o);if($z.Success){$r.f=$z.Groups[1].Value};$tz=[regex]::Match($html,'鎶ヤ环鎴|鎴鏃堕棿|鎶ヤ环鎴鏃堕棿|鎶曟爣鎴',$o);if($tz.Success){$ctx=$html.Substring([Math]::Max(0,$tz.Index-30),[Math]::Min(180,$html.Length-[Math]::Max(0,$tz.Index-30)));$dz=[regex]::Match($ctx,'(\d{4}[-/骞碷\d{1,2}[-/鏈圿\d{1,2})');if($dz.Success){$r.dl=$dz.Groups[1].Value.Trim()}}  # 鎻愬彇鍙戝竷鏃堕棿
  $pz = [regex]::Match($html,'鍙戝竷[鏃ユ湡鏃堕棿]+[锛?]\s*(\d{4}[-/骞碷\d{1,2}[-/鏈圿\d{1,2})',$o)
  if (-not $pz.Success) { $pz = [regex]::Match($html,'鍏憡鏃ユ湡[锛?]\s*(\d{4}[-/骞碷\d{1,2}[-/鏈圿\d{1,2})',$o) }
  if (-not $pz.Success) { $pz = [regex]::Match($html,'(\d{4}[-/骞碷\d{1,2}[-/鏈圿\d{1,2})',$o) }
  if ($pz.Success) { $r.pt = $pz.Groups[1].Value.Trim() }
  return $r}
function DnPdf($id,$proj,$title){if([string]::IsNullOrEmpty($id)){return $null};$sn=$title;if($sn.Length-gt40){$sn=$sn.Substring(0,40)};$sn=$sn-replace'[<>:"/\\|?*]','';$fn=$proj+"_"+$sn+".pdf";$fp=Join-Path $pdfDir $fn;if(Test-Path $fp){return $fn};if(Safe-DownloadFile "https://zcpt.cebenvironment.com.cn/dzzb/cgUploadController.do?openFileById&id=$id" $fp){Write-Host "    鈫?PDF: $fn";return $fn};return $null}
Write-Host "姝ｅ湪鑾峰彇鍏憡鍒楄〃..."
$all=Get-Items
Write-Host ("鍏?"+$all.Count+" 鏉″叕鍛?)
$c=@();$m=@();$n=@()
foreach($x in $all){switch(Test-Instrument $x.title){"core"{$c+=$x};"maybe"{$m+=$x};"no"{$n+=$x}}}
Write-Host ("[鎺ㄨ崘鎶曟爣] $($c.Count)  [闇€鏍稿疄] $($m.Count)  [涓嶇浉鍏砞 $($n.Count)")
$cd=@();$i=0
foreach($x in $c){$i++;Write-Host("  [$i/$($c.Count)] ")-NoNewline;$d=Get-Detail $x.url;Write-Host $d.p -NoNewline;if($d.f){$pf=DnPdf $d.f $d.p $x.title}else{$pf=""};$cd+=@{ti=$x.title;pi=$d.p;bu=$d.b;co=$d.c;ph=$d.ph;pf=$pf;dl=$d.dl;pt=$x.pt};Start-Sleep -Milliseconds 300}
$md=@()
foreach($x in $m){$d=Get-Detail $x.url;if($d.f){$pf="https://zcpt.cebenvironment.com.cn/dzzb/cgUploadController.do?openFileById&id="+$d.f}else{$pf=""};$md+=@{ti=$x.title;pi=$d.p;bu=$d.b;co=$d.c;ph=$d.ph;pf=$pf;dl=$d.dl;pt=$x.pt}}
$nd=@();foreach($x in $n){$d=Get-Detail $x.url;$nd+=@{ti=$x.title;pt=$x.pt;pi=$d.p}}
$json=@{date=$script:today;time=(Get-Date -Format "yyyy-MM-dd HH:mm");total=$all.Count;cc=$c.Count;mc=$m.Count;nc=$n.Count;core=$cd;maybe=$md;no=$nd}|ConvertTo-Json -Depth 3
$json|Out-File (Join-Path $OutputDir ("data_"+$script:today+".json")) -Encoding UTF8
Write-Host "JSON 宸蹭繚瀛?

# 鐢熸垚甯︽暟鎹祵鍏ョ殑 HTML 鎶ュ憡椤甸潰
& "node" "generate_html.js" 2>&1 | Out-Null
Write-Host "鉁?HTML 鎶ュ憡宸茬敓鎴?

# --- 鎺ㄩ€佸埌 GitHub Pages ---
Write-Host "姝ｅ湪鎺ㄩ€佸埌 GitHub..."
$remoteUrl = "https://${gitHubUser}:${gitHubToken}@github.com/${gitHubUser}/${gitHubRepo}.git"
git remote add origin $remoteUrl 2>$null
git remote set-url origin $remoteUrl
git add -A
git commit -m "姣忔棩鏇存柊 $script:today" --allow-empty 2>$null
git push origin main 2>&1
Write-Host "鉁?GitHub Pages 宸叉洿鏂?

# --- Server閰卞井淇℃帹閫侊紙鍚墜鏈鸿闂摼鎺ワ級---
$sendKey = $serverChanKey
$jsonFile = Join-Path $OutputDir ("data_" + $script:today + ".json")
if (Test-Path $jsonFile) {
    $jsonData = Get-Content $jsonFile -Encoding UTF8 | ConvertFrom-Json
    # 鑾峰彇鏈満灞€鍩熺綉 IP
    $localIP = ""
    $ipInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.PrefixOrigin -ne "WellKnown" -and $_.IPAddress -notlike "169.*" }
    if ($ipInfo) { $localIP = ($ipInfo | Select-Object -First 1).IPAddress }
    $serverUrl = "http://" + $localIP + ":8080"
    $titleMsg = "閲戞箹浠〃鍏夊ぇ鎶曟爣鏃ユ姤 " + $jsonData.date
    $contentMsg = ""
    $contentMsg += "鎬诲叕鍛婏細" + $jsonData.total + " 鏉?
    $contentMsg += " | 鎺ㄨ崘锛? + $jsonData.cc + " 椤?
    $contentMsg += " | 鏍稿疄锛? + $jsonData.mc + " 椤筦n`n"
    $contentMsg += "鈹佲攣鈹?鎺ㄨ崘鎶曟爣 鈹佲攣鈹乣n"
    if ($jsonData.core.Count -gt 0) {
        $count = [Math]::Min(10, $jsonData.core.Count)
        for ($i = 0; $i -lt $count; $i++) {
            $item = $jsonData.core[$i]
            $num = $i + 1
            $contentMsg += "  " + $num + ". " + $item.ti + "`n"
        }
    }
    if ($jsonData.maybe.Count -gt 0) {
        $contentMsg += "`n鈹€鈹€ 闇€鏍稿疄 " + $jsonData.mc + " 椤?鈹€鈹€`n"
        $mcount = [Math]::Min(5, $jsonData.maybe.Count)
        for ($i = 0; $i -lt $mcount; $i++) {
            $contentMsg += "  - " + $jsonData.maybe[$i].ti + "`n"
        }
    }
    $contentMsg += "`n鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣`n"
    $contentMsg += "馃摫 鎵嬫満鏌ョ湅瀹屾暣鎶ュ憡锛堝惈PDF锛?`n"
    $contentMsg += $serverUrl + "`n"
    $contentMsg += "锛堟墜鏈洪』杩炲悓涓€涓猈iFi锛?
    try {
        $body = @{title=$titleMsg; desp=$contentMsg}
        $resp = Invoke-RestMethod -Uri "https://sctapi.ftqq.com/$sendKey.send" -Method Post -Body $body
        if ($resp.code -eq 0) { Write-Host "鉁?寰俊鎺ㄩ€佹垚鍔? }
        else { Write-Host "鈿狅笍 鎺ㄩ€佸け璐? }
    } catch { Write-Host "鈿狅笍 鎺ㄩ€佸嚭閿? }
}



















