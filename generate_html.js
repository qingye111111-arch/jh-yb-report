const fs = require("fs");
const path = require("path");
const stripBOM = s => s.charCodeAt(0) === 0xFEFF ? s.slice(1) : s;
const dir = __dirname;
const files = fs.readdirSync(dir).filter(f => f.startsWith("data_") && f.endsWith(".json")).sort().reverse();
if (files.length === 0) { console.log("No data files"); process.exit(0); }
const jsonData = fs.readFileSync(path.join(dir, files[0]), "utf-8");
const template = fs.readFileSync(path.join(dir, "template.html"), "utf-8");
const html = template.replace("//__DATA__", stripBOM(jsonData).trim());
fs.writeFileSync(path.join(dir, "index.html"), html, "utf-8");
console.log("OK: " + files[0]);
