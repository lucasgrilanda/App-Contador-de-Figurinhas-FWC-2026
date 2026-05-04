@echo off
cd /d "%~dp0"
title FigurinhaOp — Copa 2026
cls

echo.
echo   =========================================
echo    ^⚽  FigurinhaOp — Copa do Mundo 2026
echo   =========================================
echo.

:: Mata servidor antigo na porta 8080
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":8080 "') do (
  taskkill /f /pid %%p >nul 2>&1
)
timeout /t 1 /nobreak >nul

:: Inicia servidor via PowerShell (sem precisar instalar nada)
echo   Iniciando servidor...
start /min powershell -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "%~dp0servidor.ps1"
timeout /t 2 /nobreak >nul

:: Tenta abrir no Chrome primeiro, senão abre no navegador padrao
set URL=http://localhost:8080/FigurinhaOp_v8.html
set CHROME=
for %%P in (
  "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
  "%LocalAppData%\Google\Chrome\Application\chrome.exe"
) do (
  if exist %%P set CHROME=%%P
)

if defined CHROME (
  start "" %CHROME% "%URL%"
) else (
  start "" "%URL%"
  echo.
  echo   ATENCAO: Chrome nao encontrado.
  echo   Para o microfone funcionar, abra o link no Chrome:
  echo   %URL%
)

echo.
echo   App aberto! Deixe esta janela minimizada.
echo   Feche esta janela para encerrar o servidor.
echo.
pause >nul
