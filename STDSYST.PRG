//STDSYST.PRG
//Program om stelselinligting te vertoon
//Kopiereg (c) 1993 A van Rensburg
//07-02-93 04:53am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
PROCEDURE stdsyst

   //Verklaar
   local nBoxc := 0

   //Skerm
    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   if cLanType() == "A"
      nBoxc := fBoxCent(4,space(60),17,"Stelselinligting")
      @ 4,nBoxc say "Weergawe............ "+left(filetime("sm3.exe"),5)
      @ 5,nBoxc say "Reeksnommer......... "+cReeNomm()
      if cputype() == 0
         @row()+1,nBoxc say "SVE tipe............ "+"8088"
      elseif cputype() == 1
         @row()+1,nBoxc say "SVE tipe............ "+"8086"
      elseif cputype() == 2
         @row()+1,nBoxc say "SVE tipe............ "+"V20"
      elseif cputype() == 3
         @row()+1,nBoxc say "SVE tipe............ "+"V30"
      elseif cputype() == 4
         @row()+1,nBoxc say "SVE tipe............ "+"80188"
      elseif cputype() == 5
         @row()+1,nBoxc say "SVE tipe............ "+"80186"
      elseif cputype() == 6
         @row()+1,nBoxc say "SVE tipe............ "+"80286"
      elseif cputype() == 7
         @row()+1,nBoxc say "SVE tipe............ "+"80386"
      elseif cputype() == 8
         @row()+1,nBoxc say "SVE tipe............ "+"80486"
      else
         @row()+1,nBoxc say "SVE tipe............ "+"Unknown"
      endif
      @row()+1,nBoxc say "DOS weergawe........ "+osver()
      @row()+1,nBoxc say "Totale geheue....... "+ltrim(str(memsize(.f.)))
      @row()+1,nBoxc say "Beskikbare geheue... "+ltrim(str(memory(0)))
      @row()+1,nBoxc say "Files bevel......... "+ltrim(str(numfiles()))
      @row()+1,nBoxc say "Buffers bevel....... "+ltrim(str(numbuffers()))
      @row()+1,nBoxc say "Lˆers maksimum...... "+ltrim(str(filesmax()))
      @row()+1,nBoxc say "Lˆers beskikbaar.... "+ltrim(str(filesfree()))
      @row()+1,nBoxc say "Disketaandrywers.... "+ltrim(str(numdiskf()))
      @row()+1,nBoxc say "Hardeskywe.......... "+ltrim(str(numdiskh()))
      @row()+1,nBoxc say "Logiese drywe....... "+ltrim(str(numdiskl()))
      @row()+1,nBoxc say "Volume reeksnommer.. "+ltrim(str(volserial()))
      @row()+1,nBoxc say "Totale spasie....... "+ltrim(str(disktotal()))
      @row()+1,nBoxc say "Beskikbare spasie... "+ltrim(str(diskfree()))
      @row()+1,nBoxc say "Clipper stellings... "+trim(getenv("CLIPPER"))
   else
      nBoxc := fBoxCent(4,space(60),17,"System information")
      @ 4,nBoxc say "Version............. "+left(filetime("sm3.exe"),5)
      @ 5,nBoxc say "Serial number....... "+cReeNomm()
      if cputype() == 0
         @row()+1,nBoxc say "CPU type............ "+"8088"
      elseif cputype() == 1
         @row()+1,nBoxc say "CPU type............ "+"8086"
      elseif cputype() == 2
         @row()+1,nBoxc say "CPU type............ "+"V20"
      elseif cputype() == 3
         @row()+1,nBoxc say "CPU type............ "+"V30"
      elseif cputype() == 4
         @row()+1,nBoxc say "CPU type............ "+"80188"
      elseif cputype() == 5
         @row()+1,nBoxc say "CPU type............ "+"80186"
      elseif cputype() == 6
         @row()+1,nBoxc say "CPU type............ "+"80286"
      elseif cputype() == 7
         @row()+1,nBoxc say "CPU type............ "+"80386"
      elseif cputype() == 8
         @row()+1,nBoxc say "CPU type............ "+"80486"
      else
         @row()+1,nBoxc say "CPU type............ "+"Unknown"
      endif
      @row()+1,nBoxc say "DOS version......... "+osver()
      @row()+1,nBoxc say "Conventional memory. "+ltrim(str(memsize(.f.)))
      @row()+1,nBoxc say "Available memory.... "+ltrim(str(memory(0)))
      @row()+1,nBoxc say "Files command....... "+ltrim(str(numfiles()))
      @row()+1,nBoxc say "Buffers command..... "+ltrim(str(numbuffers()))
      @row()+1,nBoxc say "Files maximum....... "+ltrim(str(filesmax()))
      @row()+1,nBoxc say "Files free.......... "+ltrim(str(filesfree()))
      @row()+1,nBoxc say "Floppy drives....... "+ltrim(str(numdiskf()))
      @row()+1,nBoxc say "Hard drives......... "+ltrim(str(numdiskh()))
      @row()+1,nBoxc say "Logical drives...... "+ltrim(str(numdiskl()))
      @row()+1,nBoxc say "Volume serial....... "+ltrim(str(volserial()))
      @row()+1,nBoxc say "Total space......... "+ltrim(str(disktotal()))
      @row()+1,nBoxc say "Free space.......... "+ltrim(str(diskfree()))
      @row()+1,nBoxc say "Clipper settings.... "+trim(getenv("CLIPPER"))
   endif
   fScrWait(24)

   //Herstel
return

