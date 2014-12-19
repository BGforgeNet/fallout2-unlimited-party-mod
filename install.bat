@echo off
echo Unlimited party mod for Fallout 2
echo Version 6
echo This mod allows you to recruit companions regardless of your Charisma stat
echo Please direct feedback to http://github.com/burner1024/fallout2-unlimited-party-mod/issues
pause
echo Prosessing scripts...
call :process_files 2>tools/logs/install.log
echo ...done
echo Cleaning up...
call :cleanup >tools/logs/install.log 2>&1
echo ...done
pause
exit

:process_files
pushd ..
set "game_dir=%CD%"
popd
set "tools_dir=tools"
set "backup_dir=%tools_dir%\backup"
set "scripts_dir=%game_dir%\data\Scripts"
set "tmp_dir=%tools_dir%\tmp"
set "PATH=%tools_dir%\ruby\usr\local\bin;%tools_dir%\gema;%PATH%"

FOR %%S in ( 
  cck9
  dcvic
  ecdogmet
  epac10
  epac11
  epac12
  gclenny
  hcmarcus
  kcsulik
  mcdavin
  mcmiria
  nhmyron
  ocgoris
  vccasidy
  scrobo
  wcbrnbot
) DO (
  IF EXIST "%scripts_dir%\%%S.int" ( 
    echo "%%S"
    copy /y "%scripts_dir%\%%S.int" "%backup_dir%"
    copy /y "%scripts_dir%\%%S.int" "%tmp_dir%"
    ruby "%tools_dir%/compiler/decompile" "%tmp_dir%\%%S.int"
    gema -line -nobackup -p "((op_metarule(16, 0) - 1) \>\= (#))=((op_metarule(16, 0) - 1) >= 99" -in "%tmp_dir%\%%S.ssl" -out "%tmp_dir%\%%S.ssl.tmp"
    gema -line -nobackup -p "((op_metarule(16, 0) - 1) \>\= *)=((op_metarule(16, 0) - 1) >= 99)" -in "%tmp_dir%\%%S.ssl.tmp" -out "%tmp_dir%\%%S.ssl"
    ruby -i.bak -pe "gsub /\(op_get_critter_stat\(op_dude_obj\(\), 3\) \<\= 1\)/, '(op_get_critter_stat(op_dude_obj(), 3) <= -99)'" "%tmp_dir%\%%S.ssl"
    ruby -i.bak -pe "gsub /\(op_get_critter_stat\(op_dude_obj\(\), 3\) \=\= 1\)/, '(op_get_critter_stat(op_dude_obj(), 3) <= -99)'" "%tmp_dir%\%%S.ssl"
    ruby "%tools_dir%\compiler\compile" "%tmp_dir%\%%S.ssl"
  )
)
goto: eof

:cleanup
move /y "%tmp_dir%"\*.int "%scripts_dir%"
del /f /q /s "%tmp_dir%"\*.*
goto: eof
