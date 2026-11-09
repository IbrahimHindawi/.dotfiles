@echo off
rem New-machine entry point: elevate, install git + nu, clone the dotfiles, run setup.nu.
rem Download this one file and run it; arguments go to setup.nu (e.g. bootstrap.bat --remote).
rem Safe to re-run: installs are skipped when present, an existing clone is fast-forwarded.
setlocal

rem --- elevate (setup.nu installs software and writes machine-wide settings)
net session >nul 2>&1
if errorlevel 1 (
    echo Requesting administrator rights...
    if "%~1"=="" (
        powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    ) else (
        powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0' -ArgumentList '%*'"
    )
    exit /b
)

set "WINGET=winget install -e --silent --accept-source-agreements --accept-package-agreements --id"

rem --- git
set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not exist "%GIT%" (
    echo Installing Git...
    %WINGET% Git.Git || goto :fail
)

rem --- nushell (winget installs it per-user or machine-wide depending on version)
set "NU=%LOCALAPPDATA%\Programs\nu\bin\nu.exe"
if not exist "%NU%" set "NU=%ProgramFiles%\nu\bin\nu.exe"
if not exist "%NU%" (
    echo Installing Nushell...
    %WINGET% Nushell.Nushell || goto :fail
    set "NU=%LOCALAPPDATA%\Programs\nu\bin\nu.exe"
)
if not exist "%NU%" set "NU=%ProgramFiles%\nu\bin\nu.exe"
if not exist "%NU%" (
    echo Nushell installed but nu.exe was not found; open a new terminal and re-run.
    goto :fail
)

rem --- dotfiles (public repo; https so it works before any SSH key exists)
set "DOT=%USERPROFILE%\.dotfiles"
if exist "%DOT%\.git" (
    echo Updating %DOT%...
    "%GIT%" -C "%DOT%" pull --ff-only || echo Could not fast-forward; continuing with the existing checkout.
) else (
    echo Cloning dotfiles...
    "%GIT%" clone https://github.com/IbrahimHindawi/.dotfiles "%DOT%" || goto :fail
)

rem --- setup
"%NU%" "%DOT%\setup.nu" %*
if errorlevel 1 goto :fail
echo.
echo Done. Open a new terminal to pick up PATH and config changes.
pause
exit /b 0

:fail
echo.
echo Bootstrap failed (see above).
pause
exit /b 1
