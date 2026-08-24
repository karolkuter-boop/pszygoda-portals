@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "PACKWIZ_URL=https://raw.githubusercontent.com/karolkuter-boop/pszygoda-portals/refs/heads/main/pack.toml"
set "BOOTSTRAP_JAR=%~dp0packwiz-installer-bootstrap.jar"
set "JAVA_EXE="

rem Prefer an explicit local override and the Java selected by Prism, but accept
rem either only after checking that it is Java 21.
if defined PSZYGODA_JAVA call :try_java "%PSZYGODA_JAVA%"
if defined INST_JAVA call :try_java "%INST_JAVA%"

rem Prism writes a custom per-instance JavaPath here after the user selects one.
if not defined JAVA_EXE call :try_config "%~dp0..\instance.cfg"

rem Standard and portable Prism layouts both keep instances and managed Java
rem runtimes under one data root. The script location, not the current working
rem directory, is therefore the reliable anchor.
for %%R in ("%~dp0..\..\..") do set "PRISM_ROOT=%%~fR"
if not defined JAVA_EXE call :try_config "%PRISM_ROOT%\prismlauncher.cfg"
if not defined JAVA_EXE call :try_managed_root "%PRISM_ROOT%"

rem Also cover a custom instance directory used with an installed Prism.
if not defined JAVA_EXE if defined APPDATA call :try_config "%APPDATA%\PrismLauncher\prismlauncher.cfg"
if not defined JAVA_EXE if defined APPDATA call :try_managed_root "%APPDATA%\PrismLauncher"
if not defined JAVA_EXE if defined LOCALAPPDATA call :try_config "%LOCALAPPDATA%\PrismLauncher\prismlauncher.cfg"
if not defined JAVA_EXE if defined LOCALAPPDATA call :try_managed_root "%LOCALAPPDATA%\PrismLauncher"

if not defined JAVA_EXE if defined JAVA_HOME call :try_java "%JAVA_HOME%\bin\java.exe"
if not defined JAVA_EXE for /f "delims=" %%J in ('where java.exe 2^>nul') do if not defined JAVA_EXE call :try_java "%%J"

if not defined JAVA_EXE if defined ProgramFiles for /d %%D in ("%ProgramFiles%\Eclipse Adoptium\jdk-21*" "%ProgramFiles%\Java\jdk-21*") do if not defined JAVA_EXE call :try_java "%%~fD\bin\java.exe"
if not defined JAVA_EXE if defined ProgramW6432 for /d %%D in ("%ProgramW6432%\Microsoft\jdk-21*" "%ProgramW6432%\Java\jdk-21*") do if not defined JAVA_EXE call :try_java "%%~fD\bin\java.exe"

if not defined JAVA_EXE (
    echo [Pszygoda Portals] BLAD: nie znaleziono dzialajacej Javy 21.
    echo [Pszygoda Portals] W Prism wybierz Ustawienia ^> Java ^> Automatycznie wykryj,
    echo [Pszygoda Portals] albo ustaw zmienna PSZYGODA_JAVA na java.exe z Javy 21.
    exit /b 21
)

echo [Pszygoda Portals] Java 21: "%JAVA_EXE%"
if /i "%PSZYGODA_PACKWIZ_RESOLVE_ONLY%"=="1" exit /b 0

if not exist "%BOOTSTRAP_JAR%" (
    echo [Pszygoda Portals] BLAD: brak "%BOOTSTRAP_JAR%".
    exit /b 22
)

pushd "%~dp0"
"%JAVA_EXE%" -jar "%BOOTSTRAP_JAR%" -g "%PACKWIZ_URL%"
set "PACKWIZ_EXIT=%ERRORLEVEL%"
popd
if not "%PACKWIZ_EXIT%"=="0" echo [Pszygoda Portals] Packwiz zakonczyl sie kodem %PACKWIZ_EXIT%.
exit /b %PACKWIZ_EXIT%

:try_config
if not exist "%~1" exit /b 0
for /f "usebackq tokens=1,* delims==" %%A in ("%~1") do if /i "%%A"=="JavaPath" if not defined JAVA_EXE call :try_java "%%B"
exit /b 0

:try_managed_root
if not exist "%~1\java" exit /b 0
for /d %%D in ("%~1\java\*") do if not defined JAVA_EXE call :try_java "%%~fD\bin\java.exe"
exit /b 0

:try_java
if defined JAVA_EXE exit /b 0
set "CANDIDATE=%~1"
if not defined CANDIDATE exit /b 0
if /i "%~nx1"=="javaw.exe" if exist "%~dp1java.exe" set "CANDIDATE=%~dp1java.exe"
if not exist "%CANDIDATE%" exit /b 0

set "CANDIDATE_VERSION="
set "VERSION_FILE=%TEMP%\pszygoda-java-version-%RANDOM%-%RANDOM%.txt"
"%CANDIDATE%" -version >"%VERSION_FILE%" 2>&1
for /f "tokens=3" %%V in ('findstr /i /c:"version" "%VERSION_FILE%"') do if not defined CANDIDATE_VERSION set "CANDIDATE_VERSION=%%~V"
del /q "%VERSION_FILE%" >nul 2>&1
if not defined CANDIDATE_VERSION exit /b 0

set "CANDIDATE_MAJOR="
for /f "tokens=1 delims=." %%M in ("%CANDIDATE_VERSION%") do set "CANDIDATE_MAJOR=%%M"
if "%CANDIDATE_MAJOR%"=="1" for /f "tokens=2 delims=." %%M in ("%CANDIDATE_VERSION%") do set "CANDIDATE_MAJOR=%%M"
if not "%CANDIDATE_MAJOR%"=="21" exit /b 0

for %%J in ("%CANDIDATE%") do set "JAVA_EXE=%%~fJ"
exit /b 0
