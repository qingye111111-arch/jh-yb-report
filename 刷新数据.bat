@echo off
chcp 65001 >nul
cd /d "C:\Users\Administrator\Desktop\光大\光大环境投标报告"
echo ========================================
echo   金湖仪表 · 光大投标筛选
echo   正在刷新数据...
echo ========================================
powershell -ExecutionPolicy Bypass -File "check_ebid.ps1"
echo.
echo 正在生成报告页面...
node generate_html.js
echo.
echo ✅ 数据刷新完成！
start "" "index.html"
echo.
pause
