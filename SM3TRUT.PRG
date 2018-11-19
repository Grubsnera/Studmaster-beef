// Application: StudMaster for Beef Cattle
//   File Name: SM3TRUT.PRG
// Description: Program to run trutest scales
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 09-07-95      08:45:50am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION sm3trut

   	// Declare
   	local lRetu := .t.
   	local aCscr := fASaveScr()
   	local aCdbf := fATopen()
   	local nBoxc := 1
   	local nChoi := 1

   	begin sequence

      	// Test for the scale program
      	if !file("aglinker.exe")
         	if cLanType() == "A"
				fScrOpsk(,"Opsie "+cOption())
            	nBoxc := fBoxCent(10,space(50),7,"TRUTEST KOPPELINGSPROGRAM!!!")
            	@11, nBoxc say "Die Trutest skaal koppelingsprogram genaamd"
            	@12, nBoxc say "AGLINKER.EXE is nie beskikbaar nie."
            	@13, nBoxc say "Die program is by die skaalverskaffer beskikbaar."
            	@14, nBoxc say "Kopieer die program na dieselfde subgids op die"
            	@15, nBoxc say "as waarin SM3.EXE (StoetMeester) is."
         	else
				fScrOpsk(,"Option "+cOption())
            	nBoxc := fBoxCent(10,space(50),6,"TRUTEST COUPLING PROGRAM!!!")
            	@11, nBoxc say "The Trutest scale coupling program named"
            	@12, nBoxc say "AGLINKER.EXE is not available."
            	@13, nBoxc say "This program is available at the scale supplier."
            	@14, nBoxc say "Copy this program to the StudMaster directory."
         	endif
         	fScrBood(maxrow()-1)
         	fScrWait(maxrow()  )
         	lRetu := .f.
         	break
      	endif

      	// Menu to see what to do
      	nChoi := fNewMenu(nChoi,"SM3TRU1")

  		if cLanType() == "A"
			fScrOpsk(1,"Opsie "+cOption(nChoi))
		else
			fScrOpsk(1,"Option "+cOption(nChoi))
		endif

      	do case
         	case nChoi == 1
            	// Download data
            	fDownload()

         	case nChoi == 2
            	// Scale setup
            	fSetup()

      	endcase

		cOption(-1)
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

   begin sequence

      // Screen
  	  if cLanType() == "A"
	     fScrOpsk( ,"Opsie "+cOption())
	  else
		 fScrOpsk( ,"Option "+cOption())
	  endif

      // Activate the scale
      if swpruncmd("aglinker de")
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
      aDire := directory("*.asc")
      if len(aDire) < 1
         fScrBood(maxrow()-1,"Geen skaal massalˆers kon gevind word nie!")
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Choose a file to download
      for i = 1 to len(aDire)
         aadd(aFile,padr(aDire[i,F_NAME],12))
      next

      // Display menu of files
      fScrBood(maxrow()-1,"[Esc]=Menu")
      if cLanType() == "A"
         fScrBood(maxrow(),"Kies die lˆer vanwaar data gelees moet word!")
         fBox(3,61,maxrow()-4,maxcol()-3,"Lˆers",cColMenu())
      else
         fScrBood(maxrow(),"Choose the files from where data should be read!")
         fBox(3,61,maxrow()-4,maxcol()-3,"Files",cColMenu())
      endif
      nChoi := achoice(4,63,maxrow()-5,maxcol()-4,aFile)
      if nChoi == 0
         lRetu := .f.
         break
      endif
      cFile := alltrim(aFile[nChoi])

      // Create a temporary trutest file
      aDbfs := {}
      aadd(aDbfs,{"SKAALID","C", 8,0})
      aadd(aDbfs,{"MASS"   ,"N", 6,2})
      aadd(aDbfs,{"COND"   ,"N", 4,0})
      ferase("trutest.dbf")
      dbcreate("trutest.dbf",aDbfs)

      // Append the file
      aCdbf := fATopen(aCdbf,,"TRUTEST",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      append from &(cFile) delimited
      go top

      // Check for date
      if "/"$TRUTEST->skaalid
         dDate := ctod(TRUTEST->skaalid)
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
      select TRUTEST
      go top
      do while !eof()

         // Skip if deleted
         if deleted()
            skip
            loop
         endif

         // Skip if no mass
         if empty(TRUTEST->mass)
            skip
            loop
         endif

         // Save the data
         select SM3MASH
         dbappend()
         SM3MASH->skaalid := TRUTEST->skaalid
         SM3MASH->mass    := TRUTEST->mass
         SM3MASH->date    := dDate

         // Next record
         select TRUTEST
         skip

      enddo

      // Close the files
      select TRUTEST
      dbclosearea()
      ferase("trutest.dbf")
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

/******************************************************************************/
STATIC FUNCTION fSetup

   // Function to set up trutest scale

   // Declare
   local lRetu := .t.

   begin sequence

      // Screen
  	  if cLanType() == "A"
	     fScrOpsk( ,"Opsie "+cOption())
	  else
		 fScrOpsk( ,"Option "+cOption())
	  endif

      // Activate the scale
      if swpruncmd("aglinker se")
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

   end

   // Reset

return lRetu
