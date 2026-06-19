@echo off
echo [正在停止服务器...]
taskkill /f /im node.exe >nul 2>&1
if errorlevel 0 (
    echo [成功] 服务器已停止
) else (
    echo [提示] 服务器未运行
)
pause
