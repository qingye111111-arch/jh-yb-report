const fs = require("fs");
const path = require("path");
const stripBOM = s => s.charCodeAt(0) === 0xFEFF ? s.slice(1) : s;
const dir = __dirname;

// Find latest data file with valid contact info
const allFiles = fs.readdirSync(dir).filter(f => f.startsWith("data_") && f.endsWith(".json"));
if (allFiles.length === 0) { console.log("No data files"); process.exit(0); }

// Score each file: prefer files with non-empty "co" values
const scored = allFiles.map(function(f) {
  var fp = path.join(dir, f);
  var stat = fs.statSync(fp);
  var raw = fs.readFileSync(fp, "utf-8");
  var clean = stripBOM(raw);
  var hasCo = (clean.match(/"co":\s*"[^"]/g) || []).length;
  try {
    var data = JSON.parse(clean);
    var cc = data.cc || 0;
    return {name: f, mtime: stat.mtime, hasCo: hasCo, cc: cc};
  } catch(e) {
    return {name: f, mtime: stat.mtime, hasCo: 0, cc: 0};
  }
});

// Sort: hasCo descending, then cc descending, then mtime descending
scored.sort(function(a, b) {
  if (a.hasCo !== b.hasCo) return b.hasCo - a.hasCo;
  if (a.cc !== b.cc) return b.cc - a.cc;
  return b.mtime - a.mtime;
});

const latestFile = scored[0].name;
console.log("Using: " + latestFile + " (hasCo:" + scored[0].hasCo + " cc:" + scored[0].cc + ")");

const jsonData = fs.readFileSync(path.join(dir, latestFile), "utf-8");
const template = fs.readFileSync(path.join(dir, "template.html"), "utf-8");

// Replace marker with JSON data (strip BOM from data)
const html = template.replace("//__DATA__", stripBOM(jsonData).trim());
fs.writeFileSync(path.join(dir, "index.html"), html, "utf-8");
console.log("HTML generated: " + latestFile);
