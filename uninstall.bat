@echo off
echo Uninstall Fallout 2 unlimited party mod? (ctrl-c to cancel)
pause
call :restore >tools/logs/uninstall.log 2>&1
echo Uninstalled!
pause
goto :exit


:restore
pushd ..
set "game_dir=%CD%"
popd
set "backup_dir=tools\backup"
set "scripts_dir=%game_dir%\data\Scripts"
move /y "%backup_dir%"\*.int "%scripts_dir%"

:exit
