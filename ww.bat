:: ww - The multiple-workspace batch script
::
:: Minimum folder structure for an environment:
:: - env_number
::     - aa_conf
::         - aasimar10.conf
::     - envs
::     - Projects
::     - tmp
::
:: Environment variables that can be previously defined (suggestion: define them as system variables)
::
:: WW_SHARED_DIR:      point to PATH of Shared used by aa. Default: D:\Shared
:: WW_PROJECTS_SUBDIR: subdirectory of workspace where projects are clones. Default: Projects
:: WW_QUIET:           if defined, ww will not print normal messages (only error ones).
:: WW_CREATE:          if defined, ww will create every PATH it tries to access (but not the root one)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal
goto PARSE_ARGS


if [%1] equ [] if [%WW_CURRENT_WORKSPACE%] == [] goto USAGE
if [%1] equ [] goto SHOW_CURRENT_WORKSPACE
goto SETUP_WORKSPACE

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SETUP_WORKSPACE

if "%WW_SHARED_DIR%"=="" set WW_SHARED_DIR=D:\Shared
if "%WW_PROJECTS_SUBDIR%"=="" set WW_PROJECTS_SUBDIR=Projects

set _WW_WORKSPACE=%1
if not exist %_WW_WORKSPACE%\ if exist D:\%_WW_WORKSPACE%\ set _WW_WORKSPACE=D:\%_WW_WORKSPACE%
if not exist %_WW_WORKSPACE%\ if exist C:\%_WW_WORKSPACE%\ set _WW_WORKSPACE=C:\%_WW_WORKSPACE%
if not exist %_WW_WORKSPACE%\ goto PATH_ERROR

:: Change WW_CURRENT_WORKSPACE to absolute PATH, if it is still relative
for /F "tokens=* delims=\" %%i in ("%_WW_WORKSPACE%") do set "WW_CURRENT_WORKSPACE=%%~fi"

if not defined WW_QUIET echo Initializing workspace %WW_CURRENT_WORKSPACE%...

set WW_PROJECTS_DIR=%WW_CURRENT_WORKSPACE%\%WW_PROJECTS_SUBDIR%

if defined WW_CREATE mkdir %WW_PROJECTS_DIR% 2> NUL

:: Temporary folder will be overriden
set TMP=%WW_CURRENT_WORKSPACE%\tmp
set TEMP=%TMP%
if not defined WW_QUIET echo TMP and TEMP variables have been updated!
if defined WW_CREATE mkdir %TMP% 2> NUL

:: Aasimar uses this configuration file to keep track of some env variables, so we need to make
:: sure it won't use any global configuration file
if defined WW_CREATE mkdir %WW_CURRENT_WORKSPACE%\aa_conf 2> NUL
set AA_CONFIG_FILE=%WW_CURRENT_WORKSPACE%\aa_conf\aasimar10.conf
if not exist %AA_CONFIG_FILE% (
    (
        echo [system]
        echo flags = LIST:conda
        echo platform = STRING:win64
        echo projects_dir = PATH:%WW_PROJECTS_DIR%
        echo shared_dir = PATH:%WW_SHARED_DIR%
    ) > %AA_CONFIG_FILE%
)
if not defined WW_QUIET echo AA_CONFIG_FILE variable have been updated!

:: Update global conda envs path variable so that we isolate the workspace environment
set CONDA_ENVS_PATH=%WW_CURRENT_WORKSPACE%\envs
if defined WW_CREATE mkdir %CONDA_ENVS_PATH% 2> NUL
if not defined WW_QUIET echo CONDA_ENVS_PATH variable have been updated!

:: Isolate conda configuration file
set "CONDARC=%WW_CURRENT_WORKSPACE%\.condarc"

:: Create it copying from the root, if it doesn't already exist
if not exist "%CONDARC%" for /F %%i in ('conda info --root') do copy "%%i\.condarc" "%CONDARC%" > NUL

where RenameTab > NUL 2>&1
if not errorlevel 1 call RenameTab [%WW_CURRENT_WORKSPACE%]

:: That's it :)
if not defined WW_QUIET echo Ready to work!

:: Export variables
endlocal & (
    set WW_CURRENT_WORKSPACE=%WW_CURRENT_WORKSPACE%
    set TMP=%TMP%
    set TEMP=%TEMP%
    set WW_PROJECTS_DIR=%WW_PROJECTS_DIR%
    set AA_CONFIG_FILE=%AA_CONFIG_FILE%
    set CONDA_ENVS_PATH=%CONDA_ENVS_PATH%
    set CONDARC=%CONDARC%
)

cd /d %WW_PROJECTS_DIR%

goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PATH_ERROR
echo Could not find path %_WW_WORKSPACE% (or variants)
exit /b 1

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SHOW_CURRENT_WORKSPACE
echo Current workspace: %WW_CURRENT_WORKSPACE%
conda info
mu status
goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:USAGE
echo Usage: %0 workspace_path_or_number
echo Example: %0 C:\1
echo Example: %0 2
goto :eof
