// STDBACK.PRG
// Program om data te backup met pkzip
// Copytight (c) 1998 Agricultural Data Control cc
// 10-30-98 05:20am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION stdback

   // Verklaar
   local lRetu := .t.
   local cWaar := ""
   local cCscr := savescreen(0,0,24,79)
   local nBoxc := 0
   local lLoop := .t.
   local cDriv := "A:"
   local nFlop := 0
   local nSize := 0
   local nTell := 1
   local nCopd := 0
   local nFree := 0
   local getlist := {}
   local aFile := {}
   local cFile := ""
   local cChar := ""
   local cDire := ""
   local nCoun := 1
   local nSlas := 0
   local i := 1
   private cPack := cDd()+"*.DBF"
   private cTofi := cDd()+"SM3BACK.ZIP"
   private cTodi := "SM3BACK.ZIP"

   // Skerm
   fScrOpsk()
   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   begin sequence

      // Toets of kompakteerprogram bestaan
      if !(file("pkzip.exe"))
         if cLanType() == "A"
            fScrBood( 23, "Die kompakteringsprogram is nie beskikbaar nie!" )
            fScrWait( 24, "Installeer program vanaf die oorspronklike diskette" )
         else
            fScrBood( 23, "The packing program is not available!")
            fScrWait( 24, "Install the program from the original diskettes")
         endif
         lRetu := .f.
         break
      endif

      // Open die dataleer
      cWaar := fTOpen(cDd(),"stdwaar",,,,.f.)
      if left(cWaar,1) == "f"
         lRetu := .f.
         break
      endif
      cDriv := STDWAAR->dryfle
      if cDriv $ " :  "
         cDriv := "A:"
      endif

      // Vra die dryfletter
      if cLanType() == "A"
         nBoxc := fBoxCent(11,"Disketaandrywer? xx",3,"RUGSTEUN")
      else
         nBoxc := fBoxCent(11,"Disk drive? xx",3,"BACKUP")
      endif

      // Vra die data
      lLoop := .t.
      do while lLoop

         // Skerm
         fScrBood(23,"[Esc]=Menu")
         if cLanType() == "A"
            fScrBood(24,"Tik die dryfletter waarop die rugsteun geskep moet word!")
         else
            fScrBood(24,"Type the drive letter where the backup should be created!")
         endif

         // Vraag
         if cLanType() == "A"
            @12,nBoxc say "Disketaandrywer?" get cDriv pict "!:"
         else
            @12,nBoxc say "Disk drive?" get cDriv pict "!:"
         endif
         set cursor on
         read
         set cursor off

         // Escaped
         if lastkey() == K_ESC
            lRetu := .f.
            break
         endif

         // Nothing
         if cDriv $ " :  "
            if cLanType() == "A"
               fScrBood(23,"Dryfletter is verpligtend!")
            else
               fScrBood(23,"Drive letter is compulsory!")
            endif
            fScrWait(24)
            loop
         endif

         // Slegs A en B is geldig
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
         lRetu := .f.
         break
      endif
      cCscr := savescreen(0,0,24,79)

      // Stoor die dryfletter
      STDWAAR->dryfle := cDriv
      cTodi := cDriv+"\"+cTodi
      fTClose(cWaar)

      // Kompakteer die data
      // Skrap bestaande leer
      if file(cTofi)
         filedelete(cTofi)
      endif
      clear screen
      if cLanType() == "A"
         fScrWbood( 0, "Datalˆers word gekompakteer", cColHead(), 1 )
      else
         fScrWbood( 0, "Data files being packed", cColHead(), 1 )
      endif
      @ 2, 0 say " "
      swpruncmd("pkzip -a &cTofi &cPack")        //08-20-97 06:14pm
      //swpruncmd("wzzip -yp &cTofi &cPack")        // 06-11-27 16:54

      // Toets of leer bestaan
      if !file(cTofi)
         if cLanType() == "A"
            fScrWait(24,"WAARSKUWING!!! Rugsteun is nie korrek geneem nie!")
         else
            fScrWait(24,"WARNING!!! Backup has not been created correctly!")
         endif
         restscreen(0,0,24,79,cCscr)
         lRetu := .f.
         break
      endif
      restscreen(0,0,24,79,cCscr)

      // Hernaam die bestaande leers
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Rugsteunlˆers se name word verander!")
      else
         fScrWbood(24,"Backup file names are being changed!")
      endif
      if file(cDd()+"sm3bac2.zip")
         if file(cDd()+"sm3bac3.zip")
            setfattr(cDd()+"sm3bac3.zip",0)
            filedelete(cDd()+"sm3bac3.zip")
         endif
         setfattr(cDd()+"sm3bac2.zip",0)
         frename(cDd()+"sm3bac2.zip",cDd()+"sm3bac3.zip")
         setfattr(cDd()+"sm3bac3.zip",1)
      endif

      // Hernaam die bestaande leers
      if file(cDd()+"sm3bac1.zip")
         if file(cDd()+"sm3bac2.zip")
            setfattr(cDd()+"sm3bac2.zip",0)
            filedelete(cDd()+"sm3bac2.zip")
         endif
         setfattr(cDd()+"sm3bac1.zip",0)
         frename(cDd()+"sm3bac1.zip",cDd()+"sm3bac2.zip")
         setfattr(cDd()+"sm3bac2.zip",1)
      endif

      // Hernaam die bestaande leers
      if file(cDd()+"sm3back.zip")
         if file(cDd()+"sm3bac1.zip")
            setfattr(cDd()+"sm3bac1.zip",0)
            filedelete(cDd()+"sm3bac1.zip")
         endif
         setfattr(cDd()+"sm3back.zip",0)
         frename(cDd()+"sm3back.zip",cDd()+"sm3bac1.zip")
         setfattr(cDd()+"sm3bac1.zip",1)
      endif

      lLoop := .t.
      do while lLoop

         // Skerm
         if cLanType() == "A"
            fScrBood(23,"Plaas rugsteundisket in die "+cDriv+" disketaandrywer!")
         else
            fScrBood(23,"Place backup diskette in the "+cDriv+" disk drive!")
         endif
         fScrWait(24)
         if lastkey() == K_ESC
            lRetu := .f.
            break
         endif

         // Toets of disket gereed is
         // if !diskreadyw(cDriv)
         //    if cLanType() == "A"
         //       fScrBood(23,cDriv+" disketaandrywer is nie gereed nie!")
         //    else
         //       fScrBood(23,cDriv+" disk drive is not ready!")
         //    endif
         //    fScrWait(24)
         //    if lastkey() == K_ESC
         //       lRetu := .f.
         //       break
         //    else
         //       loop
         //    endif
         // endif

         clear screen
         if cLanType() == "A"
            fScrWbood( 0, "Datalˆers word gekopieer na die disket", cColHead(), 1 )
         else
            fScrWbood( 0, "Data files being copied to the diskette", cColHead(), 1 )
         endif
         @ 2, 0 say " "
         if cDriv $ "A:zB:"
            swpruncmd("pkzip -a -es -&wv &cTodi &cPack")
         else
            //swpruncmd("pkzip -a -es &cTodi &cPack")
            //05-04-08 12:16
            //replaced to enable backup to memory sticks
            cTofi := cDriv + right(cTofi,len(cTofi)-2)

            // Added to create subdirectories on media
            // Will be stored in same directory as data drive
            cFile := cTofi
            do while !empty(cFile)
               cChar := left(cFile,1)
               cFile := right(cFile,len(cFile)-1)
               if cChar == "\"
                  nSlas++
                  if nSlas > 1
                     // Create the directory
                     o_md(cDire)
                  endif
               endif
               cDire += cChar
            enddo

            // Do the actual backup
            swpruncmd("pkzip -a -es &cTofi &cPack")

         endif
         fScrWait(maxrow())
         restscreen(0,0,24,79,cCscr)

         lLoop := .f.

      enddo

      // Maak oorspronklike toe
      if lLoop
         lRetu := .f.
         break
      endif

   end

return lRetu
