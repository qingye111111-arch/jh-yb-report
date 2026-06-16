const fs = require("fs");
const path = require("path");
const stripBOM = s => s.charCodeAt(0) === 0xFEFF ? s.slice(1) : s;
const dir = __dirname;

// Find latest data file
const files = fs.readdirSync(dir).filter(f => f.startsWith("data_") && f.endsWith(".json")).map(function(f) {
  return {name: f, mtime: fs.statSync(path.join(dir, f)).mtime};
}).sort(function(a, b) { return b.mtime - a.mtime; });
if (files.length === 0) { console.log("No data files"); process.exit(0); }

const latestFile = files[0].name;
const jsonData = fs.readFileSync(path.join(dir, latestFile), "utf-8");
const template = fs.readFileSync(path.join(dir, "template.html"), "utf-8");

// Replace marker with JSON data (strip BOM from data)
const html = template.replace("//__DATA__", stripBOM(jsonData).trim());
fs.writeFileSync(path.join(dir, "index.html"), html, "utf-8");
console.log("HTML generated: " + latestFile);
