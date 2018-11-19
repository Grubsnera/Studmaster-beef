// Application: StudMaster for Beef Cattle
//   File Name: SM3MASH
// Description: Program to store masses read from scale
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 08-12-95      11:56:07am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3mash(nTopp,nLeft,nBott,aVeld,cFind)

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lClea := .f.
   local aOpsk := {}
   local i     := 0
   local nScrl := 0
   local cHead := ""
   local aCols := {}
   local nRigh := 0
   local bBrow := NIL
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 1
   local cCoun := ""
   local nMenu := 1
   local nIdtp := 1

   begin sequence

      // Test if screen must be cleaned
      if empty(nTopp)
         lClea := .t.
      endif

      // Parameters
      nTopp := if(nTopp==NIL,         3,nTopp)
      nLeft := if(nLeft==NIL,         2,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)
      aVeld := if(aVeld==NIL,        {},aVeld)
      cFind := if(cFind==NIL,        "",cFind)

      // Skerm
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      // Vra op watter nommer diere gelink moet word
      nMenu := fNewMenu(nMenu,"SM3MASN")
      do case
         case nMenu == 1
            // Skaalnommer
         case nMenu == 2
            // Microschip number
         case nMenu == 3
            // Id number
         otherwise
            // Return
            lRetu := .f.
            break
      endcase
      nIdtp := nMenu

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd(aVeld,{"SM3MASH","skaalid"})
         aadd(aVeld,{"SM3DATA","idnr"   })
         aadd(aVeld,{"SM3MASH","mass"   })
         aadd(aVeld,{"SM3MASH","date"   })
         aadd(aVeld,{"SM3MASH","mark"   })
         aadd(aVeld,{"SM3MASH","type"   })
         aadd(aVeld,{"SM3MASH","ownu"   })
      endif

      // Build the get array
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3MASH",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Set the correct relation
      if nMenu == 2
         // Microchip number
         select SM3DATA
         ordsetfocus("SM3ZZST")
         select SM3MASH
         dbsetrelation("SM3DATA",{|| SM3MASH->skaalid },"SM3MASH->skaalid")
      elseif nMenu == 3
         // Id number
         select SM3DATA
         ordsetfocus("SM3DATA")
         select SM3MASH
         dbsetrelation("SM3DATA",{|| SM3MASH->skaalid },"SM3MASH->skaalid")
      else
         // Skaalnommer
         select SM3DATA
         ordsetfocus("SM3ZZSC")
         select SM3MASH
         dbsetrelation("SM3DATA",{|| left(SM3MASH->skaalid,6) },"left(SM3MASH->skaalid,6)")
      endif

      // Move the record pointer
      if !empty(cFind)
         set soft on
         seek cFind
         set soft off
         if eof()
            go top
         endif
      else
         go top
      endif

      // Calculate window width
      for i = 1 to len( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,4] + 1
         // Columns
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         if "FUNCTION" $ aOpsk[i,1]
            aadd(aCols,TBColumnNew(cHead,&("{||"+aOpsk[i,2]+"}")))
         else
            aadd(aCols,TBColumnNew(cHead,fieldwblock(aOpsk[i,2],select(strtran(aOpsk[i,1],"->","")))))
         endif
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Clear the screen
      if lClea
         fScrOpsk()
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "SKAALMASSAS" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "SCALE MASSES" )
      endif
      setcolor( cColNorm() )

      // Build the browse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Build the browse columns
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Screen
      if nIdtp == 3
         if cLanType() == "A"
            fScrBood(maxrow()-1, "[ Esc ]=Menu           [Del]=Skrap      [AltP]=Druk     ")
            fScrBood(maxrow()  , "[Enter]=Bewaar massas  [AltE]=Verander  [AltI]=SkepDiere")
         else
            fScrBood(maxrow()-1, "[Esc]=Menu           [Del]=Delete   [AltP]=Print        ")
            fScrBood(maxrow()  , "[Enter]=Save masses  [AltE]=Change  [AltI]=CreateAnimals")
         endif
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1, "[ Esc ]=Menu           [Del]=Skrap                 ")
            fScrBood(maxrow()  , "[Enter]=Bewaar massas  [AltE]=Verander  [AltP]=Druk")
         else
            fScrBood(maxrow()-1, "[Esc]=Menu           [Del]=Delete               ")
            fScrBood(maxrow()  , "[Enter]=Save masses  [AltE]=Change  [AltP]=Print")
         endif
      endif

      // Freeze
      //bBrow:freeze := 1

      // Main loop
      do while nKeyp <> K_ESC

         // Stabilize
         FullStabilize(bBrow)
         if lMove
            do while recno() <> nCurr
               bBrow:up()
               FullStabilize(bBrow)
            enddo
            lMove := .f.
         endif

         // Display the record number
         cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            if fSave(nIdtp)
               lRetu := .t.
               nKeyp := K_ESC
            endif

         elseif nKeyp == K_F1
            // Help
            do help with "SM3MASH",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               bBrow:refreshall()
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fAddMash(recno())
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_P
            //Alt P means print
            fPrint(aOpsk)
            bBrow:refreshall()

         elseif nKeyp == K_ALT_I .and. nIdtp == 3
            // Alt I means create animals in main file
            select SM3MASH
            go top
            do while !eof()
               if SM3DATA->(eof())
                  // Add the animal
                  select SM3DATA
                  dbappend()
                  SM3DATA->idnr := SM3MASH->skaalid
                  SM3DATA->uitkrede := left(cWaarisd(),2)
               endif
               // Next record
               select SM3MASH
               skip
            enddo
            select SM3MASH
            go top
            bBrow:refreshall()

         else

            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDelete

   // Function to delete records

   // Declare
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local lRetu := .f.
   local cBood := ""

   // Screen
   if cLanType() == "A"
      cBood := "Moet bogenoemde dier se MASSA geskrap word?"
   else
      cBood := "Should above-mentioned animal's MASS be deleted?"
   endif
   fScrBood(maxrow()-1,trim(fieldget(1)))
   if fJaNee(maxrow(),cBood,,.f. )
      if rlock()
         delete
         dbUnlock()
         skip
         if eof()
            go bottom
         endif
         lRetu := .t.
      endif
   endif

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fLocate(cKeyp)

   // Function to locate any record

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nBoxc := 0

   // Field length
   cKeyp += space(5)
   keyboard chr(K_RIGHT)

   // Ask the data to locate
   fScrBood(maxrow()-1)
   if cLanType() == "A"
      fScrBood(maxrow(),"Tik die ID NOMMER van die dier waarna gesoek word!")
      nBoxc := fBoxCent(maxrow()/2,"Vind? "+space(len(cKeyp)),1)
      @maxrow()/2, nBoxc say "Vind?" get cKeyp pict "@!"
   else
      fScrBood(maxrow(),"Type the ID NUMBER of the animal being searched for!")
      nBoxc := fBoxCent(maxrow()/2,"Find?"+space(len(cKeyp)),1)
      @maxrow()/2, nBoxc say "Find?" get cKeyp pict "@!"
   endif

   // Read
   set cursor on
   read
   set cursor off

   fARestScr(aCscr)

   // To do
   if lastkey() == K_ESC
      lRetu := .f.
   else
      cmclrfilter()
      ordsetfocus(1)
      set soft on
      seek cKeyp
      set soft off
      if eof()
         go top
      endif
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fSave

   // Function to save the masses

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nChoi := 1
   local cBrep := ""

   begin sequence

      cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

      // Menu where to save the masses
      if cBrep $ "JYjy"
         nChoi := fNewMenu(nChoi,"SM3MASHp")
      else
         nChoi := fNewMenu(nChoi,"SM3MASH")
      endif
      do case

         case nChoi == 1
            // Prewean
            lRetu := fPrewean()

         case nChoi == 2
            // Wean
            lRetu := fWean()

         case nChoi == 3
            // Year
            lRetu := fYear()

         case nChoi == 4
            // 18 months
            lRetu := fEighteen()

         case nChoi == 5
            // Phase D starting
            lRetu := fStart()

         case nChoi == 6
            // Phase D fortnightly
            lRetu := fFortnightly()

         case nChoi == 7
            // Regular masses
            lRetu := fRegular()

         otherwise
            // Return
            lRetu := .f.

      endcase

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrewean

   // Function to save prewean masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"Voorspeenmassas word bewaar")
   else
      fScrWbood(maxrow(),"Prewean masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      SM3DATA->mas100 := SM3MASH->mass
      SM3DATA->dat100 := SM3MASH->date
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWean

   // Function to save wean masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"Speenmassas word bewaar")
   else
      fScrWbood(maxrow(),"Wean masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      SM3DATA->mas205 := SM3MASH->mass
      SM3DATA->dat205 := SM3MASH->date
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fYear

   // Function to save year masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"Jaarmassas word bewaar")
   else
      fScrWbood(maxrow(),"Year masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      SM3DATA->mas365 := SM3MASH->mass
      SM3DATA->dat365 := SM3MASH->date
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fEighteen

   // Function to save eighteen masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"18 Maande massas word bewaar")
   else
      fScrWbood(maxrow(),"18 Month masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      SM3DATA->mas540 := SM3MASH->mass
      SM3DATA->dat540 := SM3MASH->date
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fStart

   // Function to save phase d starting masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"Fase D beginmassas word bewaar")
   else
      fScrWbood(maxrow(),"Phase D starting masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      SM3DATA->begmassa := SM3MASH->mass
      SM3DATA->begdatum := SM3MASH->date
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fFortnightly

   // Function to save phase d fortnightly masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"Fase D tweeweeklikse massas word bewaar")
   else
      fScrWbood(maxrow(),"Phase D fortnightly masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      SM3DATA->vormassa := SM3DATA->einmas
      SM3DATA->vordatum := SM3DATA->eindat
      SM3DATA->einmas := SM3MASH->mass
      SM3DATA->eindat := SM3MASH->date
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fRegular

   // Function to save regular masses

   // Declare
   local lRetu := .t.
   local lIdnr := .f.                            // No id number toggle
   local lLarg := .f.                            // Mass too large

   // File
   select SM3MASH
   go top
   if cLanType() == "A"
      fScrWbood(maxrow(),"Gereelde massas word bewaar")
   else
      fScrWbood(maxrow(),"Regular masses being saved")
   endif

   // The loop
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
      endif

      // No link to main file
      if empty(SM3DATA->idnr)
         lRetu := .f.
         lIdnr := .t.
         select SM3MASH
         skip
         loop
      endif

      // Too large mass
      if SM3MASH->mass <= 0 .or. SM3MASH->mass > 999
         lRetu := .f.
         lLarg := .t.
         select SM3MASH
         skip
         loop
      endif

      // Update the main file
      select SM3DATA
      if !empty(SM3MASH->mark)
         SM3DATA->toggle1 := alltrim(SM3MASH->mark)
      endif
      if !empty(SM3MASH->ownu)
         SM3DATA->divers := left(alltrim(SM3MASH->ownu),6)
      endif

      // Update the regular weighings file
      select SM3WEEG
      seek SM3DATA->idnr+dtos(SM3MASH->date)
      if eof()
         dbappend()
         SM3WEEG->idnr := SM3DATA->idnr
         SM3WEEG->weegdatum := SM3MASH->date
      endif
      SM3WEEG->massa := SM3MASH->mass

      // Next
      select SM3MASH
      skip

   enddo

   // Display message if no relation
   if lIdnr
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere waarvoor geen Id nommers beskikbaar is nie!")
      else
         fScrBood(maxrow()-1,"Animals exist with no Id numbers!")
      endif
      fScrWait(maxrow())
   endif

   // Display message if too large masses
   if lLarg
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Daar bestaan diere met geen of te groot massas!")
      else
         fScrBood(maxrow()-1,"Animals exist with no or too large masses!")
      endif
      fScrWait(maxrow())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fAddMash(nReko)

   // Declare
   local getList := {}
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aSend := {}
   local aRecv := {}
   local nLine := 0
   local nBoxc := 0
   local lLoop := .t.
   local lClea := .t.
   local lRepe := .f.
   local i     := 0
   local nPrev := 1
   local cMess := ""
   local nData := 0
   local aRepe := {}
   local nMenu := 1
   local cData := ""
   local nDeel := 1
   local nFiel := 1
   local nMain := 0
   begin sequence

      // Values
      nReko := iif(empty(nReko),0,nReko)

      // Get the fields
      asize(aSend,0)
      aadd(aSend,{"SM3MASH","skaalid"})
      //aadd(aSend,{"SM3MASH","idnr"   })
      aadd(aSend,{"SM3MASH","date"   })
      aadd(aSend,{"SM3MASH","mass"   })
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE MASSA" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW MASS" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER SKAALINLIGTING" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT SCALE INFORMATION" )
         endif
      endif

      // The get
      lLoop := .t.
      do while lLoop

         // Clean the get
         if lClea

            // Get the current values
            if nReko == 0

               // Insert a new record
               if lRepe
                  lRepe := .f.
                  aRepe := {}
                  aadd(aRepe,"date")
                  aRecv := fFillBlank(aRecv,aRepe)
               else
                  aRecv := fFillBlank(aRecv)
               endif

            else

               // Edit a record by filling the array with current values
               for i := 1 to len(aRecv)
                  select select(strtran(aRecv[i,1],"->",""))
                  aRecv[i,14] := fieldget(aRecv[i,13])
               next

               // Update the id number field from the main file
               //aRecv[fEnum(aRecv,"idnr"),14] := SM3DATA->idnr

            endif

         else

            // Clear the get array
            lClea := .t.

         endif

         // Vertoon en get velde
         //@nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
         //   pict aRecv[ 1,FLD_PICT] ;
         //   when(fWskaalid(nReko))
         //@nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
         //   pict aRecv[ 2,FLD_PICT] ;
         //   when(fWidnr(nReko)) ;
         //   valid(fVidnr(getlist,aRecv,nReko))
         //@nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
         //   pict aRecv[ 3,FLD_PICT] ;
         //   when(fWdate())
         //@nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
         //   pict aRecv[ 4,FLD_PICT] ;
         //   when(fWdate())

         @nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
            pict aRecv[ 1,FLD_PICT] ;
            when(fWskaalid(nReko))
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT] ;
            when(fWdate())
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT] ;
            when(fWdate())

         // The get
         set cursor on
         read
         set cursor off

         // Reset the database
         fATclose(aCdbf)

         // The actions
         if lastkey() == K_ENTER

            lRetu := .t.

            // Add or edit record in the sales file
            if nReko == 0
               // Add
               dbappend()
            else
               // Edit
               do while !rlock()
               enddo
            endif
            for i := 1 to len(aRecv)
               if "SM3MASH" $ aRecv[i,DBF_NAME]
                  fieldput(aRecv[i,13],aRecv[i,14])
               endif
            next
            dbunlock()
            dbcommit()

            // Update the main file
            //select SM3DATA
            //seek SM3MASH->skaalid
            //do while !eof()
            //   SM3DATA->skaalid := space(6)
            //   seek SM3MASH->skaalid
            //enddo
            //ordsetfocus("SM3DATA")
            //seek SM3MASH->idnr
            //do while !rlock()
            //enddo
            //SM3DATA->skaalid := SM3MASH->skaalid
            //dbunlock()
            //dbcommit()
            //ordsetfocus("SM3ZZSC")

            // Select the active file
            select SM3MASH

            // Store the current record number
            nPrev := recno()

            // Next new record
            if nReko == 0

               // Repeat the previous data
               lRepe := .t.

               loop

            endif

         else

            // Activate the correct previous record
            if !empty(nPrev)
               goto nPrev
            endif

            // Escaped
            if updated()

               // Warn that data will be lost
               if cLanType() == "A"
                  cMess := "Kan veranderings verlore gaan?"
               else
                  cMess := "Ok to lose changes?"
               endif
               if !fJaNee(maxrow(),cMess)
                  lClea := .f.
                  loop
               endif

            endif

         endif

         lLoop := .f.

      enddo

   end

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWskaalid(nReko)

   // Function to control entry to the scale number field

   // Declare
   local lRetu := .t.

return lRetu

/******************************************************************************/
STATIC FUNCTION fWidnr(nReko)

   // Function to control entry to the id number field

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Massas  "+D_DNARR+"=Lys van diere")
      fScrBood(maxrow()  ,"Tik die ID NOMMER van die geweegde dier!")
   else
      fScrBood(maxrow()-1,"[Esc]=Masses  "+D_DNARR+"=List of animals")
      fScrBood(maxrow()  ,"Type the ID NUMBER of the weighed animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVidnr(aGets,aRecv,nReko)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local i     := 1
   local aDisp := aclone(aRecv)
   local nFiel := fEnum(aRecv,"idnr")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         if cLanType() == "A"
            cData := sm3idnu(3,,,,,aGets[nFiel]:varget())
         else
            cData := sm3idnu(3,,,,,aGets[nFiel]:varget())
         endif
         if !empty(cData)
            aGets[nFiel]:varput(cData)
            aGets[nFiel]:updatebuffer()
         else
            lRetu := .f.
            break
         endif

      elseif empty(aGets[nFiel]:varget())

         // No number given - exit to browse
         keyboard chr(K_ESC)
         lRetu := .f.
         break

      endif

      // Locate data
      select SM3DATA
      seek aGets[nFiel]:varget()
      if eof()

         // Animal not in file - do not allow

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dier bestaan nie in die hooflˆer nie!")
         else
            fScrBood(maxrow()-1,"Animal does not exist in the main file!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWdate

   // Function to control entry to the date field

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Massas")
      fScrBood(maxrow()  ,"Tik die DATUM waarop die dier geweeg is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Masses")
      fScrBood(maxrow()  ,"Type the WEIGHING DATE of the animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWmass

   // Function to control entry to the mass field

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Massas")
      fScrBood(maxrow()  ,"Tik die MASSA van die dier op die weegdatum!")
   else
      fScrBood(maxrow()-1,"[Esc]=Masses")
      fScrBood(maxrow()  ,"Type the MASS of the animal on the weighing date!")
   endif

return lRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Skerm
   fScrBood(23)

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"SM3MASH","skaalid"})
      aadd(aSend,{"SM3DATA","idnr"   })
      aadd(aSend,{"SM3MASH","mass"   })
      aadd(aSend,{"SM3MASH","date"   })
      aadd(aSend,{"SM3MASH","mark"   })
      aadd(aSend,{"SM3MASH","ownu"   })
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Skuif die databasis
   select SM3MASH
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Bepaal die drukwydte
   nWidt := 0
   for nI = 1 to len(aRecv)
      nWidt+= aRecv[nI][4]+1
   next

   if nWidt <= nPrnWidt()
      // Normal
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      // Condense
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl()
         nPagl := nPrnLeng()
      else
         nPrnl := nPrcPrnl()
         nPagl := nPrcLeng()
      endif
   endif

   nMidc := nWidt - 29

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Weeglyste word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("Elektroniese Weeglys.")
   else
      fScrbood(24,"Weighing lists being printed!  [Esc]=Stop printer.")
      cHdln := upper("Electronic Weighing List.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := .t.
   do while lLoop

      //Opskrifte
      if prow() = 0

         fPrnCod( cPcod )
         if cLanType() == "A"
            @prow()+nTopl, 1 say upper( cGebNaam() )
            @prow()  , nMidc say "             Verslag: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
         else
            @prow()+nTopl, 1 say upper( cGebNaam() )
            @prow()  , nMidc say "              Report: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "    Herd Designation: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
         endif
         @prow()+1,  1 say repl( "=",  nWidt )

         //1e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //2e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //3e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //4e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + repl("-",aRecv[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Data
      cData := ""
      for nI = 1 to len( aRecv )
         do case
            case aRecv[nI][3] == "C"
               //Character
               cData+= fieldget(aRecv[nI,13]) + " "
            case aRecv[nI][3] == "N"
               //Numeric
               cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
            case aRecv[nI][3] == "D"
               //Date
               cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI][4])+" "
         endcase
      next
      @prow()+1,1 say padr(cData, nWidt)

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()
         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   //Herstel
   fPrnOff()

   select SM3MASH
   go top

return NIL

