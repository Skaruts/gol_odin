@echo off

echo compiling...

if "%1" == "" 	goto :run_mode
if "%1" == "?" 	goto :help
if "%1" == "h" 	goto :help
if "%1" == "c" 	goto :clean_up
if "%1" == "n"  goto :build_mode_normal
if "%1" == "d" 	goto :build_mode_debug
if "%1" == "r" 	goto :build_mode_release

set err="%1"
goto :error


:recompile_question
	cls
	echo 	main.exe doesn't exist. Recompile?
	echo 	y/d/r - yes   (default debug mode)
	echo 	n     - no
	set /p answer=""
	if "%answer%" == "y" goto :build_mode_debug
	if "%answer%" == "d" goto :build_mode_debug
	if "%answer%" == "r" goto :build_mode_release
	if "%answer%" == "n" goto :end
	echo invalid answer '%answer%'
	goto :recompile_question


::------------------------------------------------------------------------------
::		CLEAN MODE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:clean_up
	del *.exe
	del *.exp
	del *.lib
	del *.pdb
	goto :end


::------------------------------------------------------------------------------
::		RUN MODE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:run_mode
	echo running
	if exist main.exe (
		call main.exe
	) else (
		goto :recompile_question
	)
	goto :end


::------------------------------------------------------------------------------
::		NORMAL MODE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:build_mode_normal
	if "%2" == ""   goto :normal_build_do
	set err="%2"
	goto :error

:normal_build_do
	cls
	echo normal build
	odin run . -out:main.exe
	goto :end


::------------------------------------------------------------------------------
::		DEBUG MODE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:build_mode_debug
	if "%2" == ""   goto :debug_build_do
	set err="%2"
	goto :error

:debug_build_do
	cls
	echo debug build
	odin run . -out:main.exe -debug
	goto :end


::------------------------------------------------------------------------------
::		RELEASE MODE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:build_mode_release
	if "%2" == ""    goto :release_build_do
	set err="%2"
	goto :error

:release_build_do
	cls
	echo release build
	odin run . -out:main.exe -o:speed
	goto :end


::------------------------------------------------------------------------------
::		RUN MODE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:help
	echo.
	echo    Usage: run [mode]
	echo.
	echo    If parameter is ommited, it will attempt to run the app. If no executable
	echo    exists, you'll be prompted to compile one.
	echo.
	echo        Parameters:
	echo            h/?     this help information
	echo            d       debug mode
	echo            n       normal mode
	echo            r       release mode
	echo.
	echo.
	echo.
	goto :end


::------------------------------------------------------------------------------
::		ERRORS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:error
	echo.
	echo    ERROR: Invalid parameter %err%.
	echo.
	echo    Type 'run [?/h]' for help.
	echo.
	goto :end


:end
