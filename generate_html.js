const fs = require("fs");
const path = require("path");
const stripBOM = s => s.charCodeAt(0) === 0xFEFF ? s.slice(1) : s;
const dir = __dirname;
const files = fs.readdirSync(dir).filter(f => f.startsWith("data_") && f.endsWith(".json") && !f.includes("_merged")).sort();
if (files.length === 0) { process.exit(0); }

var ekw = ["维修","检修"];
var allItems = {}, catMap = {}, latestDate = "";

files.forEach(function(f) {
    try {
        var raw = fs.readFileSync(path.join(dir, f), "utf-8");
        var clean = stripBOM(raw);
        var data = JSON.parse(clean);
        if (!latestDate) latestDate = data.date || "";
        ["core","maybe","no"].forEach(function(cat) {
            (data[cat]||[]).forEach(function(item) {
                var id = item.pi || item.ti;
                var targetCat = cat;
                // Exclude check - if repair, force "no"
                for (var k = 0; k < ekw.length; k++) {
                    if (item.ti.indexOf(ekw[k]) >= 0) { targetCat = "no"; break; }
                }
                // Always store if new, or force exclude, or prefer co
                if (!allItems[id] || targetCat === "no" || (item.co && !allItems[id].co)) {
                    allItems[id] = item;
                    catMap[id] = targetCat;
                }
            });
        });
    } catch(e) {}
});

var merged = { date: latestDate, time: new Date().toISOString().replace("T"," ").substring(0,16), core:[], maybe:[], no:[] };
Object.keys(allItems).forEach(function(id) { merged[catMap[id]].push(allItems[id]); });
merged.cc = merged.core.length; merged.mc = merged.maybe.length; merged.nc = merged.no.length;
merged.total = merged.core.length + merged.maybe.length + merged.no.length;

var template = fs.readFileSync(path.join(dir, "template.html"), "utf-8");
fs.writeFileSync(path.join(dir, "index.html"), template.replace("//__DATA__", JSON.stringify(merged,null,4)), "utf-8");
console.log("OK: merged " + files.length + " files, " + merged.total + " items, cc=" + merged.cc);
