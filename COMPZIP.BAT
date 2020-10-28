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
  fd *.bat /d /t04:42:28
  fd *.dbv /d /t04:42:28
  fd *.exe /d /t04:42:28
  fd *.ovl /d /t04:42:28
  fd *.tdb /d /t04:42:28

  cls
  echo Nuwe ZIP lêers word geskep...
  pkzip -a -ex smasys @compzip.lst
  fd smasys.zip /d /t04:42:28
  del newdryf.tdb
  xcopy smasys.zip x:\prepare\sma /v /y
  goto end

:english

  cls
  pkunzip -o tdbeng.bat

  cls
  copy newdryf.bat newdryf.tdb
  del stdreek.tdb
  del sm3seri.tdb
  fd *.bat /d /t04:42:28
  fd *.dbv /d /t04:42:28
  fd *.exe /d /t04:42:28
  fd *.ovl /d /t04:42:28
  fd *.tdb /d /t04:42:28

  cls
  echo New ZIP files being created...
  pkzip -a -ex smesys @compzip.lst
  fd smesys.zip /d /t04:42:28
  del newdryf.tdb
  xcopy smesys.zip x:\prepare\sme /v /y
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
