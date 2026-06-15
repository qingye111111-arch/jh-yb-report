const http = require("http");
const fs = require("fs");
const path = require("path");
const os = require("os");
const url = require("url");

const PORT = 8080;
const ROOT = "C:\\Users\\Administrator\\Desktop\\光大\\光大环境投标报告";
const MIME = {
  ".html": "text/html; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".pdf": "application/pdf",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".ico": "image/x-icon",
  ".svg": "image/svg+xml",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8"
};

function getLocalIP() {
  const ifs = os.networkInterfaces();
  for (const name of Object.keys(ifs)) {
    for (const iface of ifs[name]) {
      if (iface.family === "IPv4" && !iface.internal) return iface.address;
    }
  }
  return "127.0.0.1";
}

const server = http.createServer((req, res) => {
  let p = url.parse(req.url).pathname;
  if (p === "/") p = "/index.html";
  const fp = path.join(ROOT, p);

  // Security: ensure file is within ROOT
  if (!fp.startsWith(ROOT)) {
    res.writeHead(403); res.end("Forbidden");
    return;
  }

  fs.readFile(fp, (err, data) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("404 - 文件未找到: " + p);
      return;
    }
    const ext = path.extname(fp).toLowerCase();
    const ct = MIME[ext] || "application/octet-stream";
    res.writeHead(200, { "Content-Type": ct });
    res.end(data);
  });
});

const localIP = getLocalIP();
server.listen(PORT, "0.0.0.0", () => {
  console.log("");
  console.log("===================================");
  console.log("  金湖仪表 · 光大投标报告服务器");
  console.log("===================================");
  console.log("");
  console.log("  电脑上访问:");
  console.log("  http://localhost:" + PORT);
  console.log("");
  console.log("  手机上访问（同WiFi下）:");
  console.log("  http://" + localIP + ":" + PORT);
  console.log("");
  console.log("  手机查看PDF可直接点击项目旁的PDF链接");
  console.log("===================================");
  console.log("  按 Ctrl+C 停止服务器");
});