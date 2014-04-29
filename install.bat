@echo off

call :process_files > tools/logs/install.log 2>&1
goto :exit


:process_files
@echo on
pushd ..
set game_dir=%CD%
popd
set tools_dir=tools
set backup_dir=%tools_dir%\backup
set scripts_dir=%game_dir%\data\Scripts
set tmp_dir=%tools_dir%\tmp
set PATH=%tools_dir%\ruby\usr\local\bin;%tools_dir%\gema;%PATH%

FOR %%S in (cck9 dcvic ecdogmet epac10 epac11 epac12 gclenny hcmarcus kcsulik mcdavin mcmyria nhmyron ocgoris vccasidy scrobo wcbrnbot) DO (
	copy /y %scripts_dir%\%%S.int %backup_dir%
	copy /y %scripts_dir%\%%S.int %tmp_dir%
	ruby "%tools_dir%/compiler/decompile" %tmp_dir%\%%S.int
	gema -line -nobackup -p "((op_metarule(16, 0) - 1) >\= (#))=((op_metarule(16, 0) - 1) \>\= 99" -in %tmp_dir%\%%S.ssl -out %tmp_dir%\%%S.ssl.tmp
	gema -line -nobackup -p "((op_metarule(16, 0) - 1) >\= *)=((op_metarule(16, 0) - 1) \>\= 99)" -in %tmp_dir%\%%S.ssl.tmp -out %tmp_dir%\%%S.ssl
	ruby "%tools_dir%\compiler\compile" %tmp_dir%\%%S.ssl
)

move /y %tmp_dir%\*.int %scripts_dir%
del /f /q /s %tmp_dir%\*.*
@echo off


:exit
