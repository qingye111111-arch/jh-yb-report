const fs = require("fs");
const path = require("path");
const dir = __dirname;

// Find latest data file
const files = fs.readdirSync(dir).filter(f => f.startsWith("data_") && f.endsWith(".json")).sort();
if (files.length === 0) { console.log("No data files"); process.exit(0); }

const latestFile = files[files.length - 1];
const jsonData = fs.readFileSync(path.join(dir, latestFile), "utf-8");
const template = fs.readFileSync(path.join(dir, "template.html"), "utf-8");

// Replace marker with JSON data
const html = template.replace("//__DATA__", jsonData.trim());
fs.writeFileSync(path.join(dir, "index.html"), html, "utf-8");
console.log("HTML generated: " + latestFile);
