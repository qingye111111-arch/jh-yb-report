const fs = require("fs");
const path = require("path");
const stripBOM = s => s.charCodeAt(0) === 0xFEFF ? s.slice(1) : s;
const dir = __dirname;

// Read ALL data files and merge
const files = fs.readdirSync(dir).filter(f => f.startsWith("data_") && f.endsWith(".json") && !f.includes("_merged")).sort();
if (files.length === 0) { console.log("No data files"); process.exit(0); }

var allItems = {};
var latestDate = "";

files.forEach(function(f) {
    try {
        var raw = fs.readFileSync(path.join(dir, f), "utf-8");
        var clean = stripBOM(raw);
        var data = JSON.parse(clean);
        if (!latestDate) latestDate = data.date || "";
        ["core", "maybe", "no"].forEach(function(cat) {
            (data[cat] || []).forEach(function(item) {
                var id = (item.pi || item.ti) + "_" + cat;
                if (!allItems[id] || (item.co && !allItems[id].item.co)) {
                    allItems[id] = { item: item, cat: cat };
                }
            });
        });
    } catch(e) {}
});

var merged = { date: latestDate, time: new Date().toISOString().replace("T", " ").substring(0, 16), core: [], maybe: [], no: [] };
Object.keys(allItems).forEach(function(id) { merged[allItems[id].cat].push(allItems[id].item); });
merged.cc = merged.core.length;
merged.mc = merged.maybe.length;
merged.nc = merged.no.length;
merged.total = merged.core.length + merged.maybe.length + merged.no.length;

var json = JSON.stringify(merged, null, 4);
var template = fs.readFileSync(path.join(dir, "template.html"), "utf-8");
var html = template.replace("//__DATA__", json);
fs.writeFileSync(path.join(dir, "index.html"), html, "utf-8");
console.log("OK: merged " + files.length + " files, " + merged.total + " items");
