@echo off

cls
echo Make a backup of old zip file
xcopy sm4.zip \dev\backup /v

cls
echo Make a new backup
del sm4.zip
pkzip -a -rP -o sm4.zip @backup.lst

rem if %1t==t goto stiffie

rem cls
rem echo Transfer backup to Server
rem xcopy sm4.zip %1\sm4 /v

rem :stiffie
rem echo Transfer backup to Diskette
rem xcopy sm4.zip a: /v
pause
