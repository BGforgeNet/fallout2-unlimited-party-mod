@echo off

call :restore > tools/logs/uninstall.log 2>&1
goto :exit


:restore
@echo on
pushd ..
set game_dir=%CD%
popd
set backup_dir=tools\backup
set scripts_dir=%game_dir%\data\Scripts
copy /y %backup_dir%\*.int %scripts_dir%
@echo off

:exit
