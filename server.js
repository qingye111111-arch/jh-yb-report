const http = require("http");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
const os = require("os");

const PORT = 8080;
const ROOT = "D:\\光大环境投标报告";

function getIP() {
  var ifs = os.networkInterfaces();
  for (var n of Object.keys(ifs))
    for (var i of ifs[n])
      if (i.family === "IPv4" && !i.internal) return i.address;
  return "127.0.0.1";
}

const srv = http.createServer((req, res) => {
  var p = req.url.split("?")[0].split("#")[0];
  var pDecode;
  try { pDecode = decodeURIComponent(p); } catch(e) { pDecode = p; }
  if (pDecode === "/") { pDecode = "/index.html"; }

  // Refresh: run script and return immediately
  if (pDecode === "/refresh") {
    // Log refresh start
    var msg = new Date().toISOString() + " - Refresh triggered\n";
    fs.appendFileSync(path.join(ROOT, "refresh.log"), msg);

    // Spawn script (no waiting, no lock, no nothing)
    var ps = spawn("powershell.exe", [
      "-ExecutionPolicy", "Bypass",
      "-File", path.join(ROOT, "check_ebid.ps1"), "-SkipPush"
    ], {
      cwd: ROOT,
      
      stdio: ["ignore", "pipe", "pipe"]
    });
    
    // Log output to file
    var logStream = fs.createWriteStream(path.join(ROOT, "refresh.log"), { flags: "a" });
    ps.stdout.pipe(logStream);
    ps.stderr.pipe(logStream);
    ps.unref();
    ps.on("error", function(e) { fs.appendFileSync(path.join(ROOT, "refresh.log"), "SPAWN ERROR: " + e.message + "`n"); });

    // Return simple page immediately
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-cache, no-store, must-revalidate" });
    res.write("<!DOCTYPE html><html><head><meta charset='utf-8'>");
    res.write("<title>\u5237\u65b0\u4e2d</title>");
    res.write("<style>body{font-family:sans-serif;text-align:center;padding:60px 20px;background:#f0f2f5}h2{color:#1a5276}.spinner{border:4px solid #e0e0e0;border-top:4px solid #1a5276;border-radius:50%;width:40px;height:40px;margin:20px auto;animation:spin 1s linear infinite}@keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}</style>");
    res.write("</head><body>");
    res.write("<h2>\u{1F33E} \u5149\u5927\u6295\u6807\u7ba1\u5bb6</h2>");
    res.write("<div class='spinner'></div>");
    res.write("<p style='font-size:16px;color:#333'><strong>\u6b63\u5728\u5237\u65b0\u6570\u636e...</strong></p>");
    res.write("<p style='font-size:13px;color:#666'>\u6570\u636e\u91c7\u96c6\u9700\u8981 1-3 \u5206\u949f</p>");
    res.write("<p style='margin-top:30px'><a href='/' style='color:#2980b9'><strong>\u8fd4\u56de\u9996\u9875</strong></a></p>");
    res.write("</body></html>");
    res.end();
    return;
  }

  // Serve static files
  var fp = path.join(ROOT, pDecode);
  if (!fp.startsWith(ROOT)) { res.writeHead(403); res.end("Forbidden"); return; }
  
  var ext = path.extname(fp).toLowerCase();
  var MIME = {
    ".html": "text/html; charset=utf-8",
    ".json": "application/json",
    ".pdf": "application/pdf",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".css": "text/css",
    ".js": "text/javascript"
  };
  
  fs.readFile(fp, function(err, data) {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("404 - " + pDecode);
      return;
    }
    res.writeHead(200, { "Content-Type": MIME[ext] || "application/octet-stream" });
    res.end(data);
  });
});

var ip = getIP();
srv.listen(PORT, "0.0.0.0", function() {
  console.log("");
  console.log("==========================================");
  console.log("  \u5149\u5927\u6295\u6807\u62a5\u544a\u670d\u52a1\u5668");
  console.log("==========================================");
  console.log("");
  console.log("  \u7535\u8111\u8bbf\u95ee:  http://localhost:" + PORT);
  console.log("  \u624b\u673a\u8bbf\u95ee:  http://" + ip + ":" + PORT);
  console.log("  (\u624b\u673a\u9700\u8fde\u540c\u4e00\u4e2aWiFi)");
  console.log("");
});


