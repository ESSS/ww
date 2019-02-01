@echo off
REM ww - The multiple-workspace batch script

REM Minimum folder structure for an environment:
REM - env_number
REM     - envs
REM     - Projects
REM     - tmp
REM     - ww_actitave.bat

REM If ww_activate.bat is present, it is executed after the workspace is ready.

REM -----------------------------------------------------------------------------------------------
setlocal
call :DEFINE_GLOBAL_VARIABLES
goto PARSE_ARGS


REM -----------------------------------------------------------------------------------------------
:USAGE
REM Environment variables that can be previously defined (suggestion: define them as system variables)
REM For more information, see :DEFINE_GLOBAL_VARIABLES function in this file.
echo Usage: %0 [OPTION] workspace_path_or_number
echo ww - The multiple-workspace batch script
echo.
echo You can configure the following environment variables, if needed:
echo WW_DEFAULT_VOLUMES:  Volumes to be used in ww.
echo     Default = W
echo     Current = %WW_DEFAULT_VOLUMES%
echo WW_PROJECTS_SUBDIR:  Subdirectory of workspace where projects are cloned.
echo     Default = Projects
echo     Current = %WW_PROJECTS_SUBDIR%
echo WW_QUIET:            If defined, ww will not print normal messages (only error ones).
echo     Default undefined
echo     Current = %WW_QUIET%
echo.
echo ^-c, --create       Create a new workspace folder structure in the given ^<number^> or ^<full-directory^>
echo ^-h, --help         Show this help
echo.
echo Examples:
echo %0 -c 99
echo %0 9
echo.
goto :eof


REM -----------------------------------------------------------------------------------------------
:PARSE_ARGS
REM if no args and no current workspace, Show help
if "%1" equ "" if "%WW_CURRENT_WORKSPACE%" == "" goto USAGE

REM if args == --help or args == -h, Show help
if "%1" equ "--help" goto USAGE
if "%1" equ "-h" goto USAGE

REM if args == --create <env_number> or args == -c <env_number>, createn env
if "%1" equ "--create" goto CREATE_ENV
if "%1" equ "-c" goto CREATE_ENV

REM No args: Show current env
if "%1" equ "" goto SHOW_CURRENT_WORKSPACE

REM Finally, has args and are none of the above, assume that have passed the workspace as argument
goto SETUP_WORKSPACE


REM -----------------------------------------------------------------------------------------------
:DEFINE_GLOBAL_VARIABLES
if not defined WW_PROJECTS_SUBDIR set WW_PROJECTS_SUBDIR=Projects
if not defined WW_DEFAULT_VOLUMES set WW_DEFAULT_VOLUMES=W
set _FIRST_VOLUME=%WW_DEFAULT_VOLUMES:,=&rem.%

exit /b 0


REM -----------------------------------------------------------------------------------------------
:CREATE_ENV

if "%2" equ "" (
    echo Expected workspace as second parameter. Example: %0% --create 99
    exit /b 1
)

REM Check if it has a ':', in this case assumes it is already the complete PATH
REM (the following assignment is needed because string replacement doesn't work with batch arguments)
set _ARG2=%2
if [%_ARG2::=%] NEQ [%_ARG2%] set _NEW_WORKSPACE=%2
if not defined _NEW_WORKSPACE set _NEW_WORKSPACE=%_FIRST_VOLUME%:\%2%

if exist %_NEW_WORKSPACE% (
    echo Workspace %_NEW_WORKSPACE% already exist. To activate it, run %0 %2%
    exit /b 1
)

set _PROJECTS_DIR=%_NEW_WORKSPACE%\%WW_PROJECTS_SUBDIR%
set _TMP_DIR=%_NEW_WORKSPACE%\tmp
set _CONDA_ENVS_PATH_DIR=%_NEW_WORKSPACE%\envs

mkdir %_NEW_WORKSPACE% 2> NUL
mkdir %_PROJECTS_DIR% 2> NUL
mkdir %_TMP_DIR% 2> NUL
mkdir %_CONDA_ENVS_PATH_DIR% 2> NUL

echo :: ww Activate Script > %_NEW_WORKSPACE%\ww_activate.bat
echo :: This script is called by ww script after loading the workspace >> %_NEW_WORKSPACE%\ww_activate.bat
echo :: you can put environment variable initialization for specific environment here. >> %_NEW_WORKSPACE%\ww_activate.bat
echo :: For example, set ESSS_DEBUG=python could be done. >> %_NEW_WORKSPACE%\ww_activate.bat
echo. >> %_NEW_WORKSPACE%\ww_activate.bat
echo @echo off >> %_NEW_WORKSPACE%\ww_activate.bat
echo echo Don^'t forget to configure %_NEW_WORKSPACE%\ww_activate.bat >> %_NEW_WORKSPACE%\ww_activate.bat

if not defined WW_QUIET echo Success! New workspace created in %_NEW_WORKSPACE%

goto :eof


REM -----------------------------------------------------------------------------------------------
:SETUP_WORKSPACE

set _WW_WORKSPACE=%1
for %%i in (%WW_DEFAULT_VOLUMES%) do (
    if not exist %_WW_WORKSPACE%\%WW_PROJECTS_SUBDIR% (
        if exist %%i:\%_WW_WORKSPACE%\%WW_PROJECTS_SUBDIR% (
            set _WW_WORKSPACE=%%i:\%_WW_WORKSPACE%
        )
    )
)
if not exist %_WW_WORKSPACE%\%WW_PROJECTS_SUBDIR% (
    echo Couldn't find the workspace %1 in any volume in list (%WW_DEFAULT_VOLUMES%^)
    echo You can try creating a new one using %0 -c %1
    exit /b 1
)
REM Change WW_CURRENT_WORKSPACE to absolute PATH, if it is still relative
for /F "tokens=* delims=\" %%i in ("%_WW_WORKSPACE%") do set "WW_CURRENT_WORKSPACE=%%~fi"

if not defined WW_QUIET echo Initializing workspace %WW_CURRENT_WORKSPACE%...

set WW_PROJECTS_DIR=%WW_CURRENT_WORKSPACE%\%WW_PROJECTS_SUBDIR%

REM Temporary folder will be overriden
set TMP=%WW_CURRENT_WORKSPACE%\tmp
set TEMP=%TMP%
if not defined WW_QUIET echo TMP and TEMP variables have been updated!

REM Update global conda envs path variable so that we isolate the workspace environment
set CONDA_ENVS_PATH=%WW_CURRENT_WORKSPACE%\envs
if not defined WW_QUIET echo CONDA_ENVS_PATH variable have been updated!

REM Isolate conda configuration file
set "CONDARC=%WW_CURRENT_WORKSPACE%\.condarc"

REM Create it copying from the root, if it doesn't already exist
if not exist "%CONDARC%" for /F %%i in ('conda info --root') do copy "%%i\.condarc" "%CONDARC%" > NUL

REM conda 4.2 does not respect CONDA_ENVS_PATH anymore: https://github.com/conda/conda/issues/3469
call conda config --file "%CONDARC%" --add envs_dirs "%CONDA_ENVS_PATH%" 2> NUL
REM In some version conda added a configuration to override the packages cache.
REM If not set it default to the root cache.
call conda config --file "%CONDARC%" --add pkgs_dirs "%CONDA_ENVS_PATH%\.pkgs" 2> NUL

where RenameTab > NUL 2>&1
if not errorlevel 1 call RenameTab [%WW_CURRENT_WORKSPACE%]

REM That's it :)
if not defined WW_QUIET echo Ready to work!

REM Export variables
endlocal & (
    set WW_CURRENT_WORKSPACE=%WW_CURRENT_WORKSPACE%
    set TMP=%TMP%
    set TEMP=%TEMP%
    set WW_PROJECTS_DIR=%WW_PROJECTS_DIR%
    set CONDA_ENVS_PATH=%CONDA_ENVS_PATH%
    set CONDARC=%CONDARC%
)

cd /d %WW_PROJECTS_DIR%

if exist %WW_CURRENT_WORKSPACE%\ww_activate.bat (
    call %WW_CURRENT_WORKSPACE%\ww_activate.bat
)

goto :eof

REM -----------------------------------------------------------------------------------------------
:PATH_ERROR
echo Could not find path %_WW_WORKSPACE% (or variants)
exit /b 1

REM -----------------------------------------------------------------------------------------------
:SHOW_CURRENT_WORKSPACE
echo Current workspace:   %WW_CURRENT_WORKSPACE%
echo WW_DEFAULT_VOLUMES:  %WW_DEFAULT_VOLUMES%
echo WW_PROJECTS_SUBDIR:  %WW_PROJECTS_SUBDIR%
echo WW_QUIET:            %WW_QUIET%
echo.
conda info
mu status
goto :eof
