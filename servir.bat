@echo off
setlocal
rem ===== Abre el juego en http://localhost:8000 =====
cd /d "%~dp0wasm" 2>nul
if not exist index.html (
  echo No encuentro wasm\index.html. Primero ejecuta compilar.bat
  pause
  exit /b 1
)

rem Busca un Python que funcione (el "python" de la Microsoft Store no cuenta)
set "PYCMD="
python --version >nul 2>&1 && set "PYCMD=python"
if not defined PYCMD ( py --version >nul 2>&1 && set "PYCMD=py" )
if not defined PYCMD (
  for %%R in ("D:\emsdk\python" "%USERPROFILE%\emsdk\python" "C:\emsdk\python" "%~dp0emsdk\python") do (
    for /d %%D in ("%%~R\*") do (
      if not defined PYCMD if exist "%%D\python.exe" set "PYCMD=%%D\python.exe"
    )
  )
)

start "" http://localhost:8000
if defined PYCMD (
  echo Servidor en http://localhost:8000  - cerra esta ventana para apagarlo
  "%PYCMD%" -m http.server 8000
) else (
  echo No encontre Python. Pruebo con Node.js...
  npx --yes http-server -p 8000 -c-1
)
