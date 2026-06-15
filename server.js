const http = require("http");
const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");
const os = require("os");
const url = require("url");

const PORT = 8080;
const ROOT = "D:\\光大环境投标报告";
const MIME = {".html":"text/html; charset=utf-8",".json":"application/json",".pdf":"application/pdf",".png":"image/png",".jpg":"image/jpeg",".css":"text/css",".js":"text/javascript"};

function getIP(){var ifs=os.networkInterfaces();for(var n of Object.keys(ifs))for(var i of ifs[n])if(i.family==="IPv4"&&!i.internal)return i.address;return "127.0.0.1"}

const srv = http.createServer((req, res) => {
  try{var p = decodeURIComponent(url.parse(req.url).pathname)}catch(e){var p = url.parse(req.url).pathname}
  if (p === "/") { p = "/index.html"; }

  // Refresh endpoint
  if (p === "/refresh") {
    res.writeHead(200, {"Content-Type":"text/html; charset=utf-8"});
    res.write("<html><head><meta charset='utf-8'><title>刷新中</title><meta http-equiv='refresh' content='3;url=/index.html'><style>body{font-family:sans-serif;text-align:center;padding:40px}h2{color:#1a5276}.ok{color:green}.fail{color:red}</style></head><body>");
    res.write("<h2>🌾 金湖仪表 · 光大投标</h2><p>正在刷新数据，请稍候...</p><pre>");

    exec('powershell -ExecutionPolicy Bypass -File "' + ROOT + '\\check_ebid.ps1"', {cwd:ROOT, timeout:180000}, (err, stdout, stderr) => {
      res.write(stdout + "\n");
      if (err) { res.write("<span class='fail'>❌ 刷新失败</span>\n"); }
      else {
        // Generate HTML
        exec('node "' + ROOT + '\\generate_html.js"', {cwd:ROOT}, (err2, so2, se2) => {
          res.write(so2 + "\n");
          if (!err2) res.write("<span class='ok'>✅ 刷新完成！</span>\n");
          else res.write("<span class='fail'>HTML生成失败</span>\n");
          res.write("</pre><p>3秒后自动返回...</p>");
          res.write("<p><a href='/index.html' style='color:#2980b9'>立即返回</a></p>");
          res.write("</body></html>");
          res.end();
        });
      }
    });
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
  console.log("  金湖仪表 · 光大投标报告服务器");
  console.log("==========================================");
  console.log("");
  console.log("  电脑访问:  http://localhost:" + PORT);
  console.log("  手机访问:  http://" + ip + ":" + PORT);
  console.log("  (手机需连同一个WiFi)");
  console.log("  刷新接口:  http://localhost:" + PORT + "/refresh");
  console.log("");
  console.log("==========================================");
});


