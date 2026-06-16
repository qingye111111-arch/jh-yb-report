const http = require("http");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
const os = require("os");
const url = require("url");

const PORT = 8080;
const ROOT = "D:\\光大环境投标报告";
const MIME = {".html":"text/html; charset=utf-8",".json":"application/json",".pdf":"application/pdf",".png":"image/png",".jpg":"image/jpeg",".css":"text/css",".js":"text/javascript"};
const FRESH_WINDOW_MS = 600000; // 10 minutes: consider data "fresh" if updated within this window

function getIP(){var ifs=os.networkInterfaces();for(var n of Object.keys(ifs))for(var i of ifs[n])if(i.family==="IPv4"&&!i.internal)return i.address;return "127.0.0.1"}

function isIndexFresh() {
  try {
    var stat = fs.statSync(path.join(ROOT, 'index.html'));
    return (Date.now() - stat.mtimeMs) < FRESH_WINDOW_MS;
  } catch(e) { return false; }
}

function sendRefreshPage(res, justStarted) {
  res.writeHead(200, {"Content-Type":"text/html; charset=utf-8"});
  var statusText = justStarted
    ? "<p style='font-size:16px;color:#333'><strong>\u6b63\u5728\u5237\u65b0\u6570\u636e\uff0c\u8bf7\u8010\u5fc3\u7b49\u5f85...</strong></p>"
    : "<h3>\u526f\u672c\u6b63\u5728\u540e\u53f0\u6267\u884c\uff0c\u7a0d\u5019\u81ea\u52a8\u5237\u65b0...</h3>";
  res.write("<!DOCTYPE html><html lang='zh-CN'><head><meta charset='utf-8'>");
  res.write("<title>\u5237\u65b0\u4e2d...</title>");
  res.write("<meta http-equiv='refresh' content='8;url=/refresh'>");
  res.write("<style>body{font-family:sans-serif;text-align:center;padding:60px 20px;background:#f0f2f5}h2{color:#1a5276}.spinner{border:4px solid #e0e0e0;border-top:4px solid #1a5276;border-radius:50%;width:40px;height:40px;margin:20px auto;animation:spin 1s linear infinite}@keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}.note{color:#666;font-size:13px;margin-top:20px}a{color:#2980b9}</style>");
  res.write("</head><body>");
  res.write("<h2>\u{1F33E} \u5149\u5927\u6295\u6807\u7ba1\u5bb6</h2>");
  res.write("<div class='spinner'></div>");
  res.write(statusText);
  res.write("<p class='note'>\u6570\u636e\u91c7\u96c6\u901a\u5e38\u9700\u8981 1-3 \u5206\u949f\uff0c\u9875\u9762\u5c06\u5728\u5b8c\u6210\u540e\u81ea\u52a8\u8fd4\u56de\u9996\u9875</p>");
  res.write("<p style='margin-top:20px'><a href='/'>\u8fd4\u56de\u9996\u9875</a></p>");
  res.write("</body></html>");
  res.end();
}

const srv = http.createServer((req, res) => {
  try{var p = decodeURIComponent(url.parse(req.url).pathname)}catch(e){var p = url.parse(req.url).pathname}
  if (p === "/") { p = "/index.html"; }

  // Refresh endpoint
  if (p === "/refresh") {
    var lockFile = path.join(ROOT, "refresh.lock");
    var isRunning = false;
    try { 
      if (fs.existsSync(lockFile)) {
        var stat = fs.statSync(lockFile);
        // Stale detection: if lock is older than 10 min, treat as stale
        if (Date.now() - stat.mtimeMs > FRESH_WINDOW_MS) {
          fs.unlinkSync(lockFile);
          isRunning = false;
        } else {
          isRunning = true;
        }
      }
    } catch(e) {}

    if (isRunning) {
      // Script still running - show progress page
      sendRefreshPage(res, false);
    } else if (isIndexFresh()) {
      // No lock and index is fresh - refresh just finished, redirect to home
      res.writeHead(302, {"Location": "/"});
      res.end();
    } else {
      // No lock, stale data - start a new refresh
      fs.writeFileSync(lockFile, new Date().toISOString());
      var psScript = path.join(ROOT, 'check_ebid.ps1');
      spawn('powershell.exe', ['-ExecutionPolicy', 'Bypass', '-File', psScript], {
        cwd: ROOT, detached: true, stdio: 'ignore'
      }).unref();
      sendRefreshPage(res, true);
    }
    return;
  }

  // Serve static files
  var fp = path.join(ROOT, p);
  if (!fp.startsWith(ROOT)) { res.writeHead(403); res.end("Forbidden"); return; }
  fs.readFile(fp, (err, data) => {
    if (err) { res.writeHead(404, {"Content-Type":"text/plain; charset=utf-8"}); res.end("404 - " + p); return; }
    var ext = path.extname(fp).toLowerCase();
    res.writeHead(200, {"Content-Type": MIME[ext] || "application/octet-stream"});
    res.end(data);
  });
});

var ip = getIP();
srv.listen(PORT, "0.0.0.0", () => {
  console.log("");
  console.log("==========================================");
  console.log("  \u5149\u5927\u6295\u6807\u62a5\u544a\u670d\u52a1\u5668");
  console.log("==========================================");
  console.log("");
  console.log("  \u7535\u8111\u8bbf\u95ee:  http://localhost:" + PORT);
  console.log("  \u624b\u673a\u8bbf\u95ee:  http://" + ip + ":" + PORT);
  console.log("  (\u624b\u673a\u9700\u8fde\u540c\u4e00\u4e2aWiFi)");
  console.log("  \u5237\u65b0\u63a5\u53e3:  http://localhost:" + PORT + "/refresh");
  console.log("");
  console.log("==========================================");
});
