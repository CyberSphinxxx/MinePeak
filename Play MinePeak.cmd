@echo off
setlocal
cd /d "%~dp0"
if not exist ".runtime\launch-paths.cmd" (
  echo MinePeak needs its local installation. Read PLAY.md.
  pause
  exit /b 1
)
call ".runtime\launch-paths.cmd"
tasklist /FI "IMAGENAME eq PEAK.exe" /NH 2>nul | findstr /I /B "PEAK.exe" >nul
if not errorlevel 1 (
  echo PEAK is already running. Close it normally, then launch MinePeak again.
  pause
  exit /b 1
)
tasklist /FI "IMAGENAME eq javaw.exe" /NH 2>nul | findstr /I /B "javaw.exe" >nul
if not errorlevel 1 (
  echo A Minecraft or Java window is still running. Close it normally before updating MinePeak.
  pause
  exit /b 1
)
if not exist "%MINEPEAK_STEAM%" goto missing
if not exist "%MINEPEAK_LAUNCHER%" goto missing
if not exist ".runtime\PEAK\BepInEx\plugins\aeironnarmiento.PeakCraft.dll" goto missing
if exist "dist\MinePeak\aeironnarmiento.PeakCraft.dll" (
  copy /Y "dist\MinePeak\aeironnarmiento.PeakCraft.dll" ".runtime\PEAK\BepInEx\plugins\aeironnarmiento.PeakCraft.dll" >nul
  if errorlevel 1 goto missing
)
if exist "dist\MinePeak\skycraft-0.1.2.jar" (
  copy /Y "dist\MinePeak\skycraft-0.1.2.jar" ".runtime\minecraft\mods\skycraft-0.1.2.jar" >nul
  if errorlevel 1 goto missing
)
start "" "%MINEPEAK_LAUNCHER%"
start "" "%MINEPEAK_STEAM%" -applaunch 3527290 --doorstop-enabled true --doorstop-target-assembly "%~dp0.runtime\PEAK\BepInEx\core\BepInEx.Preloader.dll" -screen-fullscreen 0 -screen-width 1280 -screen-height 720
echo.
echo In Minecraft Launcher, select MinePeak and click Play.
echo In PEAK, choose Play Solo. Minecraft's window will hide when connected.
echo Start with normal PEAK controls. Press F6 to switch to Minecraft.
echo Close PEAK to save and stop the linked Minecraft instance.
echo Full guide: PLAY.md
pause
exit /b 0
:missing
echo A required game or mod file is missing. Read PLAY.md.
pause
exit /b 1
