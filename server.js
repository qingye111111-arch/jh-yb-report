const http = require("http");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
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
    res.write("<html><head><meta charset='utf-8'><title>\u5237\u65b0\u4e2d</title>");
    res.write("<meta http-equiv='refresh' content='180;url=/index.html'>");
    res.write("<style>body{font-family:sans-serif;text-align:center;padding:40px}h2{color:#1a5276}.ok{color:green}.fail{color:red}</style>");
    res.write("</head><body><h2>\u{1F33E} \u5149\u5927\u6295\u6807\u7ba1\u5bb6</h2>");
    res.write("<p>\u6b63\u5728\u5237\u65b0\u6570\u636e\uff0c\u8bf7\u8010\u5fc3\u7b49\u5f85...</p><pre>");

    // spawn instead of exec: avoids cmd.exe code-page mangling of Chinese path
    var psScript = path.join(ROOT, 'check_ebid.ps1');
    var ps = spawn('powershell.exe', ['-ExecutionPolicy', 'Bypass', '-File', psScript], { cwd: ROOT });
    var psTimer = setTimeout(function() { try { ps.kill(); } catch(e) {} }, 180000);
    ps.stdout.on('data', function(data) { res.write(data.toString()); });
    ps.stderr.on('data', function(data) { res.write(data.toString()); });
    ps.on('close', function(code) {
      clearTimeout(psTimer);
      res.write("\n\u2716 \u8fdb\u7a0b\u9000\u51fa\u7801: " + code + "\n");
      var nodeScript = path.join(ROOT, 'generate_html.js');
      var nd = spawn('node.exe', [nodeScript], { cwd: ROOT });
      nd.stdout.on('data', function(data) { res.write(data.toString()); });
      nd.stderr.on('data', function(data) { res.write(data.toString()); });
      nd.on('close', function(code2) {
        if (code2 === 0) {
          res.write("<span class='ok'>\u2705 \u5237\u65b0\u5b8c\u6210\uff01</span>\n");
        } else {
          res.write("<span class='fail'>HTML\u751f\u6210\u5931\u8d25 (exit: " + code2 + ")</span>\n");
        }
        res.write("</pre><p><a href='/index.html'>\u8fd4\u56de\u9996\u9875</a></p></body></html>");
        res.end();
      });
    });
    ps.on('error', function(e) {
      clearTimeout(psTimer);
      res.write("<span class='fail'>\u2716 \u542f\u52a8\u5931\u8d25: " + e.message + "</span>\n");
      res.write("</pre><p><a href='/index.html'>\u8fd4\u56de\u9996\u9875</a></p></body></html>");
      res.end();
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
