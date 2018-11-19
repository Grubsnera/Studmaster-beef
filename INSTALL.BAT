echo off
if %1t==t A:INSTALL A: C: \SM3
%1
if %2t==t %1INSTALL %1 C: \SM3
if %3t==t %1INSTALL %1 %2 \SM3
%2
md %3
cd %3

rem Verander lˆername
cls
rename *.tmp *.tdb

rem Kopieer die leers
cls
echo Program files being copied - please wait...
echo Programlˆers word gekopieer - wag asseblief...
copy %1\*.*
if errorlevel 50 goto err50
if errorlevel 4 goto err4
if errorlevel 0 goto inst
goto err1

:inst
   rem Berei die datalˆers voor
   cls
   echo Program files being prepared...
   echo Programlˆers word voorberei...
   if exist smasys.exe goto sma
   if exist smasys.zip goto smaz
   if exist smesys.exe goto sme
   if exist smesys.zip goto smez
   goto nofile

:sma
   smasys -o
   if errorlevel 50 goto err50
   if errorlevel 4 goto err4
   if errorlevel 0 goto end

:smaz
   rename smasys.zip smasys.exe
   goto sma

:sme
   smesys -o
   if errorlevel 50 goto err50
   if errorlevel 4 goto err4
   if errorlevel 0 goto end

:smez
   rename smesys.zip smesys.exe
   goto sme

:err1
   cls
   echo Problem!
   echo Program was not installed for an unknown reason.
   echo Do the installation again. If this message should be repeated,
   echo please phone for more information. Thank you.
   echo .
   echo Probleem!
   echo Program is vir 'n onbekende rede nie ge‹nstalleer nie.
   echo Doen die installering weer. Indien hierdie boodskap weer vertoon,
   echo skakel asseblief vir meer inligting. Baie dankie.
   goto finish

:err4
   cls
   echo Problem!
   echo Program was not installed because of insufficient memory.
   echo Do the installation again. If this message should be repeated,
   echo please phone for more information. Thank you.
   echo .
   echo Probleem!
   echo Program is nie ge‹nstalleer nie a.g.v. onvoeldoende geheue.
   echo Doen die installering weer. Indien hierdie boodskap weer vertoon,
   echo skakel asseblief vir meer inligting. Baie dankie.
   goto finish

:err50
   cls
   echo Problem!
   echo Program was not installed because of insufficient hard disk space.
   echo Do the installation again. If this message should be repeated,
   echo please phone for more information. Thank you.
   echo .
   echo Probleem!
   echo Program is nie ge‹nstalleer nie a.g.v. onvoeldoende hardeskyfspasie.
   echo Doen die installering weer. Indien hierdie boodskap weer vertoon,
   echo skakel asseblief vir meer inligting. Baie dankie.
   goto finish

:nofile
   cls
   echo Problem!
   echo Program was not installed because one of the program files are missing.
   echo Do the installation again. If this message should be repeated,
   echo please phone for more information. Thank you.
   echo .
   echo Probleem!
   echo Program is nie ge‹nstalleer nie omdat een van die programlˆers verlore is.
   echo Doen die installering weer. Indien hierdie boodskap weer vertoon,
   echo skakel asseblief vir meer inligting. Baie dankie.
   goto finish

:end
  del %2%3\install.bat
  del %2%3\sm?sys.exe
  cls
  echo StudMaster was succesfully installed in %2%3
  echo StoetMeester is suksesvol ge‹nstalleer op %2%3
  echo .
  echo .
  echo To activate the program, type SM3 and press Enter or,
  echo create a shortcut to the program in Windows 95 and 98.
  echo See the manual on how to create a shortcut in Windows.
  echo To return to Windows, type EXIT and press Enter.
  echo .
  echo Tik SM3 en druk Enter om die program te aktiveer of,
  echo skep 'n kortpad na die program in Windows 95 en 98.
  echo Sien die handleiding oor hoe om 'n kortpad te skep in Windows.
  echo Tik EXIT en druk Enter om na Windows terug te keer.

:finish
