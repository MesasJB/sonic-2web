@echo off
setlocal
rem ===== Compila Sonic 2 usando WSL (Linux) y lo abre en el navegador =====
cd /d "%~dp0"

where wsl >nul 2>&1
if errorlevel 1 (
  echo WSL no esta instalado. Abri PowerShell como administrador y ejecuta:  wsl --install -d Ubuntu
  pause
  exit /b 1
)

echo.
echo Instalando herramientas de Linux ^(solo la primera vez, sin pedir contrasena^)...
wsl -u root bash -c "apt-get update && apt-get install -y git python3 xz-utils curl build-essential"
if errorlevel 1 (
  echo.
  echo No se pudieron instalar las herramientas. Mira el error de arriba.
  pause
  exit /b 1
)

echo.
wsl --cd "%~dp0." bash compilar_wsl.sh
if errorlevel 1 (
  echo.
  echo === HUBO UN ERROR. Copia las ultimas lineas y mandalas. ===
  pause
  exit /b 1
)

echo.
echo Abriendo el juego...
call "%~dp0servir.bat"
