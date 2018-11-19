//STDREST.PRG
//Program om backups te herstel
//Kopiereg (c) 1993 A van Rensburg
//05-03-93 09:59pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//***************************************************************************/
FUNCTION stdrest

   // Veranderlikes
   local cDriv := "A:"
   local cCscr := ""
   local cWaar := ""
   local lRetu := .t.
   local aMenu := {}
   local aWith := {}
   local nBoxc := ""
   local nKeus := 1
   local nLeng := 0
   local nTell := 1
   local lLoop := .t.
   local i     := 0
   local getlist := {}

   private cFile := ""
   private cTofi := ""

   // Skerm
   fSCrOpsk()

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   //Toets of pkunzip bestaan
   if !(file("pkunzip.exe"))
      if cLanType() == "A"
         fScrBood( 23, "Die kompakteringsprogram is nie beskikbaar nie!" )
         fScrWait( 24, "Installeer program vanaf die oorspronklike diskette" )
      else
         fScrBood( 23, "The packing program is not available!")
         fScrWait( 24, "Install the program from the original diskettes")
      endif
      return .f.
   endif

   //Open die dataleer
   cWaar := fTOpen(cDd(),"stdwaar",,,,.f.)
   if left(cWaar,1) == "f"
      return .f.
   endif
   cDriv := STDWAAR->dryfle
   if cDriv $ " :  "
      cDriv := "A:"
   endif

   //Kry die menu
   if file(cDd()+"sm3bac1.zip")
      if cLanType() == "A"
         aadd(aMenu,"Rugsteun geskep op "+dtoc(filedate(cDd()+"sm3bac1.zip"))+" om "+filetime(cDd()+"sm3bac1.zip"))
      else
         aadd(aMenu,"Backup created on "+dtoc(filedate(cDd()+"sm3bac1.zip"))+" at "+filetime(cDd()+"sm3bac1.zip"))
      endif
      aadd(aWith,"A")
   endif

   if file(cDd()+"sm3bac2.zip")
      if cLanType() == "A"
         aadd(aMenu,"Rugsteun geskep op "+dtoc(filedate(cDd()+"sm3bac2.zip"))+" om "+filetime(cDd()+"sm3bac2.zip"))
      else
         aadd(aMenu,"Backup created on "+dtoc(filedate(cDd()+"sm3bac2.zip"))+" at "+filetime(cDd()+"sm3bac2.zip"))
      endif
      aadd(aWith,"B")
   endif

   if file(cDd()+"sm3bac3.zip")
      if cLanType() == "A"
         aadd(aMenu,"Rugsteun geskep op "+dtoc(filedate(cDd()+"sm3bac3.zip"))+" om "+filetime(cDd()+"sm3bac3.zip"))
      else
         aadd(aMenu,"Backup created on "+dtoc(filedate(cDd()+"sm3bac3.zip"))+" at "+filetime(cDd()+"sm3bac3.zip"))
      endif
      aadd(aWith,"C")
   endif

   if cLanType() == "A"
      aadd(aMenu,"Herstel rugsteun vanaf rugsteunmedium")
   else
      aadd(aMenu,"Restore backup from backup device    ")
   endif
   aadd(aWith,"D")

   //Bepaal langste array element
   for i := 1 to len(aMenu)
      if len(aMenu[i]) > nLeng
         nLeng := len(aMenu[i])
      endif
   next

   //Vertoon die menu
   fScrBood(23,"[Esc]=Menu")
   if cLanType() == "A"
      fScrBood(24, "Kies die rugsteun wat herstel moet word met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + "." )
      nBoxc := fBoxCent(12-(len(aMenu)/2),space(nLeng),len(aMenu),"HERSTEL RUGSTEUN",cColMenu())
   else
      fScrBood(24, "Choose the backup which should be restored with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + "." )
      nBoxc := fBoxCent(12-(len(aMenu)/2),space(nLeng),len(aMenu),"RESTORE BACKUP",cColMenu())
   endif
   nKeus := achoice(12-(len(aMenu)/2),nBoxc,(12-(len(aMenu)/2))+len(aMenu),nBoxc+nLeng,aMenu)

   //Escaped
   if nKeus == 0
      return .f.
   endif

   //Die keuses
   do case
      case aWith[nKeus] == "A"
         cFile := cDd()+"sm3bac1.zip"
      case aWith[nKeus] == "B"
         cFile := cDd()+"sm3bac2.zip"
      case aWith[nKeus] == "C"
         cFile := cDd()+"sm3bac3.zip"
      case aWith[nKeus] == "D"

         //Herstel vanaf disket

         //Vra watter aandrywer
         fScrOpsk()
         if cLanType() == "A"
            nBoxc := fBoxCent(11,"Disketaandrywer? xx",3,"HERSTEL RUGSTEUN")
         else
            nBoxc := fBoxCent(11,"Disk drive? xx",3,"RESTORE BACKUP")
         endif

         //Vra die data
         lLoop := .t.
         do while lLoop

            //Skerm
            fScrBood(23,"[Esc]=Menu")
            if cLanType() == "A"
               fScrBood(24,"Tik die dryfletter vanwaar rugsteun herstel moet word!")
            else
               fScrBood(24,"Type the drive letter from where the backup should be restored!")
            endif

            //Vraag
            if cLanType() == "A"
               @12,nBoxc say "Disketaandrywer?" get cDriv pict "!:"
            else
               @12,nBoxc say "Disk drive?" get cDriv pict "!:"
            endif
            set cursor on
            read
            set cursor off

            //Escaped
            if lastkey() == K_ESC
               exit
            endif

            //Nothing
            if cDriv $ " :  "
               if cLanType() == "A"
                  fScrBood(23,"Dryfletter is verpligtend!")
               else
                  fScrBood(23,"Drive letter is compulsory!")
               endif
               fScrWait(24)
               loop
            endif

            //Slegs A en B is geldig
            // 05-07-18 07:51 Removed
            //if cDriv $ "A:zB:"
            //else
            //   if cLanType() == "A"
            //      fScrBood(23,"Slegs disketaandrywer A: of B: is geldig!")
            //   else
            //      fScrBood(23,"Only disk drive A: or B: is valid!")
            //   endif
            //   fScrWait(24)
            //   loop
            //endif

            lLoop := .f.

         enddo
         if lLoop
            return .f.
         endif

         //Stoor die dryfletter
         STDWAAR->dryfle := cDriv
         fTClose(cWaar)

         //Lees die diskette

         // See which file is on the disk

         // Stiffy
         if cDriv $ "A:zB:"

            if file(cDriv+"\sm3back.001")
               cFile := cDriv+"\sm3back.001"
            elseif file(cDriv+"\sm3back.zip")
               cFile := cDriv+"\sm3back.zip"
            else
               // No files on disk
               if cLanType() == "A"
                  fScrBood(23,"Geen rugsteunlˆers kon op die disket gevind word!")
               else
                  fScrBood(23,"No backup files could be found on the disk!")
               endif
               fScrWait(24)
               return .f.
            endif

         else

            // Other drives than A or B

            if file(cDriv+right(cDd(),len(cDd())-2)+"sm3back.zip")
               cFile := cDriv+right(cDd(),len(cDd())-2)+"sm3back.zip"
            else
               // No files on disk
               if cLanType() == "A"
                  fScrBood(23,"Geen rugsteunlˆers kon op die disket gevind word!")
               else
                  fScrBood(23,"No backup files could be found on the disk!")
               endif
               fScrWait(24)
               return .f.
            endif


         endif

         // cTofi := cDd()+"sm3back.zip"
         // lLoop := .t.
         // do while lLoop
         //
         //    //Skerm
         //    if cLanType() == "A"
         //       fScrBood(23,"Plaas rugsteundisket #"+padl(ltrim(str(nTell,3,0)),3,"0")+" in die "+cDriv+" disketaandrywer!")
         //    else
         //       fScrBood(23,"Place backup diskette #"+padl(ltrim(str(nTell,3,0)),3,"0")+" in the "+cDriv+" disk drive!")
         //    endif
         //    fScrWait(24)
         //    if lastkey() == K_ESC
         //       exit
         //    endif
         //
         //    //Toets of die regte disket in is
         //    if file(cDriv+"\sm3back."+padl(ltrim(str(nTell,3,0)),3,"0"))
         //    else
         //       //Vertoon disket wat wel in is
         //       if cLanType() == "A"
         //          fScrBood(23,"'n Verkeerde disket is tans in die "+cDriv+" disketaandrywer!")
         //       else
         //          fScrBood(23,"Incorrect diskette is currently in the "+cDriv+" disk drive!")
         //       endif
         //       fScrWait(24)
         //       loop
         //    endif
         //
         //    //Lees die disket
         //    cFile := cDriv+"\sm3back."+padl(ltrim(str(nTell,3,0)),3,"0")
         //    fScrBood(23)
         //    if cLanType() == "A"
         //       fScrWbood(24,"Rugsteundisket #"+padl(ltrim(str(nTell,3,0)),3,"0")+" word gelees")
         //    else
         //       fScrWbood(24,"Backup diskette #"+padl(ltrim(str(nTell,3,0)),3,"0")+" being read")
         //    endif
         //    fileappend(cFile,cTofi)
         //
         //    //Toets of daar nog diskette is
         //    if diskfree(cDriv) == 0
         //       //Vra volgende disket
         //       nTell++
         //       loop
         //    else
         //       if file(cDd()+"sm3back.zip")
         //          cFile := cDd()+"sm3back.zip"
         //          lLoop := .f.
         //       else
         //          if cLanType() == "A"
         //             fScrBood(23,"WAARSKUWING!!! Rugsteun is nie herstel vanaf die diskette nie!")
         //          else
         //             fScrBood(23,"WARNING!!! Backup from the diskette has not been restored!")
         //          endif
         //          fScrWait(24)
         //          exit
         //       endif
         //    endif
         //
         // enddo
         //if lLoop
         //   return .f.
         //endif

      otherwise
         return .f.
   endcase

   // Doen die unzip
   setcolor(cColNorm())
   cCscr := savescreen(0,0,24,79)
   clear screen

   if cLanType() == "A"
      fScrWbood( 0, "Datalˆers word genormaliseer", cColHead(), 1 )
   else
      fScrWbood( 0, "Data files being unpacked", cColHead(), 1 )
   endif
   @ 1, 0 say " "
   cTofi := left(cDd(),len(cDd())-1)
   swpruncmd("pkunzip -o &cFile &cTofi",0,"","")
   restscreen(0,0,24,79,cCscr)

   if cLanType() == "A"
      fScrWait(24,"Datalˆer strukture en indekslˆers sal nou geskep word")
   else
      fScrWait(24,"Data file structure and index files will now be created")
   endif

return lRetu
