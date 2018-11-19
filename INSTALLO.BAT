echo off
if %1t==t A:INSTALL A: C: \INS_SYS
%1
if %2t==t %1INSTALL %1 C: \INS_SYS
if %3t==t %1INSTALL %1 %2 \INS_SYS
%2
md %3
cd %3

rem Unzip install.exe
cls
echo Installation program being prepared...
echo Installeringsprogram word voorberei...
%1\prepare.exe -o
if errorlevel 50 goto err50
if errorlevel 4 goto err4
if errorlevel 0 goto inst
goto err1

:inst
   rem Run die install.exe
   cls
   echo Installation program being loaded into memory...
   echo Installeringsprogram word in geheue gelaai...
   install.exe %1
   goto end

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
   goto end

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
   goto end

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
   goto end

:end
  %2
  cd\
  del %2%3\install.exe
  del %2%3\install.ini
  del %2%3\*.dbf
  del %2%3\*.bat
  rd %3
  %1
