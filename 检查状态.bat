@echo off
tasklist /fi "imagename eq node.exe" 2>nul | find /i "node.exe" >nul
if %errorlevel% equ 0 (
    echo ✅ 服务器运行中 (http://localhost:8080/)
) else (
    echo ❌ 服务器已关闭
)
pause
