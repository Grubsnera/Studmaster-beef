@echo off

if %1t==t goto syntax
if %1t==At goto afrikaans
if %1t==Et goto english
if %1t==at goto afrikaans
if %1t==et goto english

:afrikaans

  cls
  pkunzip -o tdbafr.bat

  cls
  copy newdryf.bat newdryf.tdb
  del stdreek.tdb
  del sm3seri.tdb
  fd *.bat /d /t04:42:26
  fd *.dbv /d /t04:42:26
  fd *.exe /d /t04:42:26
  fd *.ovl /d /t04:42:26
  fd *.tdb /d /t04:42:26

  cls
  echo Nuwe ZIP lêers word geskep...
  pkzip -a -ex Smasys @compzip.lst
  fd Smasys.zip /d /t04:42:26
  del newdryf.tdb
  xcopy smasys.zip x:\msdos\prepare\sma /v /y
  goto end

:english

  cls
  pkunzip -o tdbeng.bat

  cls
  copy newdryf.bat newdryf.tdb
  del stdreek.tdb
  del sm3seri.tdb
  fd *.bat /d /t04:42:26
  fd *.dbv /d /t04:42:26
  fd *.exe /d /t04:42:26
  fd *.ovl /d /t04:42:26
  fd *.tdb /d /t04:42:26

  cls
  echo New ZIP files being created...
  pkzip -a -ex Smesys @compzip.lst
  fd smesys.zip /d /t04:42:26
  del newdryf.tdb
  xcopy smesys.zip x:\msdos\prepare\sme /v /y
  goto end

:syntax
   cls
   echo Syntax is ... "COMPZIP <cLanguage (A)frikaans (E)nglish>"
   echo ________________________________________________________
   goto finish

:end
   cls
   echo Einde van roetine om StoetMeester program.zip te skep!
   echo .
   goto finish

:finish
