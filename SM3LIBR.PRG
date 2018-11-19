// Application: StudMaster for Beef Cattle
//   File Name: SM3LIBR.PRG
// Description: Program to run libra scales
//   Copyright: (c) 1998 A van Rensburg
//      Author: Albert van Rensburg
//  Created on: 02-26-98 11:11am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION sm3libr

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 1
   local nChoi := 1

   begin sequence

      // Test for the scale program
      if !file("dataread.exe")
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
            nBoxc := fBoxCent(10,space(50),7,"LIBRA KOPPELINGSPROGRAM!!!")
            @11, nBoxc say "Die Libra skaal koppelingsprogram genaamd"
            @12, nBoxc say "DATAREAD.EXE is nie beskikbaar nie."
            @13, nBoxc say "Die program is by die skaalverskaffer beskikbaar."
            @14, nBoxc say "Kopieer die program na dieselfde subgids op die"
            @15, nBoxc say "as waarin SM3.EXE (StoetMeester) is."
         else
            fScrOpsk(,"Option "+cOption())
            nBoxc := fBoxCent(10,space(50),6,"LIBRA COUPLING PROGRAM!!!")
            @11, nBoxc say "The Libra scale coupling program named"
            @12, nBoxc say "DATAREAD.EXE is not available."
            @13, nBoxc say "This program is available at the scale supplier."
            @14, nBoxc say "Copy this program to the StudMaster directory."
         endif
         fScrBood(maxrow()-1)
         fScrWait(maxrow()  )
         lRetu := .f.
         break
      endif

      fDownload()

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDownload

   // Function to download trutest data

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local aDire := {}
   local aFile := {}
   local cFile := ""
   local nChoi := 1
   local aDbfs := {}
   local dDate := ctod("")
   local i     := 0
   local nBoxc := 0
   local cMode := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      // Build the mode string
      cMode := "mode com"
      cMode += alltrim(str(nScPort(),1,0))+":,"
      cMode += alltrim(str(nScBaud(),5,0))+","
      cMode += alltrim(cScPari())+","
      cMode += alltrim(str(nScBits(),1,0))+","
      cMode += alltrim(str(nScStop(),1,0))+",p"

      // Activate the scale
      //if swpruncmd("mode com1:9600,n,8,1,p",200)
      //if swpruncmd(cMode,200)
      //else
      //   if cLanType() == "A"
      //      fScrBood(maxrow()-1,"Mode fout: "+str(swperrmaj())+", "+str(swperrmin()))
      //   else
      //      fScrBood(maxrow()-1,"Mode error: "+str(swperrmaj())+", "+str(swperrmin()))
      //   endif
      //   fScrWait(maxrow())
      //   lRetu := .f.
      //   break
      //endif

      // Activate the scale
      if swpruncmd("dataread "+alltrim(str(nScPort(),1,0))+" "+cDd()+"libra.txt")
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Skaalprogramfout: "+str(swperrmaj())+", "+str(swperrmin()))
         else
            fScrBood(maxrow()-1,"Scale program error: "+str(swperrmaj())+", "+str(swperrmin()))
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      // Array of files
      if !file(cDd()+"libra.txt")
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geen skaal massalˆers kon gevind word nie!")
         else
            fScrBood(maxrow()-1,"Geen skaal massalˆers kon gevind word nie!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      cFile := cDd()+"libra.txt"

      // Create a temporary trutest file
      aDbfs := {}
      aadd(aDbfs,{"SKAALID","C",12,0})
      aadd(aDbfs,{"MASS"   ,"N", 6,1})
      aadd(aDbfs,{"COND"   ,"N", 4,0})
      aadd(aDbfs,{"HEIG"   ,"N", 4,0})
      ferase("libra.dbf")
      dbcreate("libra.dbf",aDbfs)

      // Append the file
      aCdbf := fATopen(aCdbf,,"LIBRA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      append from &(cFile) delimited
      go top

      // Check for date
      if "/"$LIBRA->skaalid
         dDate := ctod(LIBRA->skaalid)
         delete
         skip
      endif

      // Ask the weighing date
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Tik die datum waarop die diere geweeg is!")
         nBoxc := fBoxCent(11,"Weegdatum? xx/xx/xx",3)
         @12,nBoxc say "Weegdatum?" get dDate
      else
         fScrOpsk( ,"Option "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Type the weighing date of the animals!")
         nBoxc := fBoxCent(11,"Weighing date? xx/xx/xx",3)
         @12,nBoxc say "Weighing date?" get dDate
      endif
      setcursor(1)
      read
      setcursor(0)

      // Break if no date
      if lastkey() == K_ESC .or. empty(dDate)
         lRetu := .f.
         break
      endif

      // Open the handheld mass file
      aCdbf := fATopen(aCdbf,cDd(),"SM3MASH",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      zap

      // Loop the original read file
      select LIBRA
      go top
      do while !eof()

         // Skip if deleted
         if deleted()
            skip
            loop
         endif

         // Skip if no mass
         if empty(LIBRA->mass)
            skip
            loop
         endif

         // Save the data
         select SM3MASH
         dbappend()
         SM3MASH->skaalid := LIBRA->skaalid
         SM3MASH->mass    := LIBRA->mass
         SM3MASH->date    := dDate

         // Convert fullstops to dashes in the id number
         SM3MASH->skaalid := strtran(SM3MASH->skaalid,".","-",1,1)

         // Next record
         select LIBRA
         skip

      enddo

      // Close the files
      select LIBRA
      dbclosearea()
      ferase("libra.dbf")
      select SM3MASH
      dbclosearea()
      aCdbf := asize(aCdbf,len(aCdbf)-2)

      // Do the actual transfer to the studmaster files
      if sm3mash()

         // Delete the ascii file
         ferase(cFile)

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCdbf)

return lRetu
