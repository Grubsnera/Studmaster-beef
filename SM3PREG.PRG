// Application: StudMaster for Beef Cattle
//   File Name: SM3PREG.PRG
// Description: Program to enter pregnancies
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 02-16-95      01:32:47pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3preg(nTopp,nLeft,nBott)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local aOpsk := {}
   local cTeeg := ""
   local cData := ""
   local i     := 0
   local nScrl := 0
   local cHead := ""
   local aCols := {}
   local nRigh := 0
   local bBrow := NIL
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 0
   local cCoun := ""
   local dDate := ctod("")
   local dDat1 := ctod("")
   local nData := 0
   local cOudeer := 365
   local cRustyd := 60
   local cNordra := 283
   local cMindra := 274
   local cMakdra := 308
   local cSiklus := 21
   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif

      // Parameters
      nTopp := if(nTopp==NIL,         3,nTopp)
      nLeft := if(nLeft==NIL,         2,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)

      // Read the standard mating values
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dekkings standaardwaardes word gelees")
      else
         fScrWbood(maxrow(),"Mating standard values being read")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS")
      if !aCdbf[len(aCdbf),1]
      else
         locate for SM3RASS->raskod == substr(cTotNaam(),149,3)
         if !eof()
            cOudeer := SM3RASS->oudeer
            cRustyd := SM3RASS->rustyd
            cNordra := SM3RASS->nordra
            cMindra := SM3RASS->mindra
            cMakdra := SM3RASS->makdra
            cSiklus := SM3RASS->siklus
         endif
      endif
      fATclose(aCdbf)
      asize(aCdbf,len(aCdbf)-1)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd( aVeld, { "SM3PREG", "idnr"       })
         // aadd( aVeld, { "SM3DATA", "teelgroep"  })
         aadd( aVeld, { "SM3DATA", "dekdat"     })
         aadd( aVeld, { "SM3DATA", "tipede"     })
         aadd( aVeld, { "SM3DATA", "bulid"      })
         aadd( aVeld, { "SM3DATA", "dragda"     })
         aadd( aVeld, { "SM3DATA", "dragti"     })
         aadd( aVeld, { "SM3DATA", "dragwe"     })
         aadd( aVeld, { "SM3PREG", "verwag"     })
         aadd( aVeld, { "SM3PREG", "vertkp"     })
      endif
      aOpsk := fGetField(aVeld)

      // Get the mating season
      cTeeg := sm3teeg()
      if empty(cTeeg)
         lRetu := .f.
         break
      endif

      // Screen
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      else
         fScrOpsk(1,"Option "+cOption())
      endif

      // Get the pd date
      dDate := fDate()
      if empty(dDate)
         lRetu := .f.
         break
      endif

      // Open the data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3PREG",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      ordsetfocus("SM3ZVRO")
      aCdbf := fATopen(aCdbf,cDd(),"SM3DEKK",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      // Set order to season+cowid
      ordsetfocus(2)

      // See if mating season exist
      seek cTeeg
      if eof()
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Vind geen kalfseisoen "+trim(cTeeg)+" koeie nie!")
         else
            fScrBood(maxrow()-1,"Found no "+trim(cTeeg)+" calving season cows")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Remove all records from the temporary file
      select SM3PREG
      zap

      // Loop to add cows to the temp file
      select SM3DEKK
      do while !eof() .and. SM3DEKK->teelgroep == cTeeg

         // Add the cow
         if cData # SM3DEKK->idmoer
            cData := SM3DEKK->idmoer
            select SM3DATA
            seek cData
            if found()
               select SM3PREG
               append blank
               SM3PREG->idnr := SM3DEKK->idmoer
               if SM3DATA->dragti $ "YJ"
                  if !empty(SM3DATA->dekdat)
                     SM3PREG->verwag := SM3DATA->dekdat+cNordra
                  endif
                  if !empty(SM3DATA->lkalfdatum) .and. !empty(SM3PREG->verwag)
                     nData := SM3PREG->verwag - SM3DATA->lkalfdatum
                     if nData > 0 .and. nData <= 9999
                        SM3PREG->vertkp := nData
                     endif
                  endif
               endif
            endif
         else
            // Correct the cow
         endif

         // Next record
         select SM3DEKK
         skip

      enddo

      // Put main file back to order 1
      select SM3DATA
      ordsetfocus(1)

      // Go to top of selected list
      select SM3PREG
      set relation to SM3PREG->idnr into SM3DATA
      go top

      // Calculate window width
      for i = 1 to len( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,4] + 1
         // Columns
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         aadd(aCols,TBColumnNew(cHead,fieldwblock(aOpsk[i,2],select(strtran(aOpsk[i,1],"->","")))))
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Screen
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      else
         fScrOpsk(1,"Option "+cOption())
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "DRAGTIGHEIDSONDERSOEKE VIR DIE "+trim(cTeeg)+" KALFSEISOEN" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "PREGNANCY DIAGNOSIS FOR THE "+trim(cTeeg)+" CALVING SEASON" )
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
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc]=Menu [J123456789]=Dragtig    [AltS]=Statistiek     [AltP]=Druk   ")
         fScrBood(maxrow()  , "[F1 ]=Hulp [    N0    ]=NieDragtig [AltO]=Ondersoekdatum               ")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu [Y123456789]=Pregnant    [AltS]=Statistics    [AltP]=Print")
         fScrBood(maxrow()  , "[F1 ]=Help [    N0    ]=NotPregnant [AltO]=DiagnosisDate             ")
      endif

      // Freeze
      bBrow:freeze := 1

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
         cCoun := padl(ltrim(str(recno()))+"/"+ltrim(str(lastrec())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            // nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "SM3PREG",1,"oorsig"

         elseif upper(chr(nKeyp)) $ " JYN1234567890"
            // Means enter pd for group
            if upper(chr(nKeyp)) $ " JYN"
               if fYesNo(upper(chr(nKeyp)),dDate,cTeeg,cMakdra,cNorDra)
                  keyboard chr(K_DOWN)
                  bBrow:refreshcurrent()
               endif
            else
               if fWeeks(upper(chr(nKeyp)),dDate,cTeeg,cMakdra,cNorDra)
                  keyboard chr(K_DOWN)
                  bBrow:refreshcurrent()
               endif
            endif

         elseif nKeyp == K_ALT_O
            // Alt O means change the pd date
            dDat1 := fDate(dDate)
            if !empty(dDat1)
               dDate := dDat1
            endif

         elseif nKeyp == K_ALT_S
            // Alt S means calculate and display statistics
            fStatistic()

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint(dDate,cTeeg,cNordra)
               bBrow:refreshall()
            endif

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
STATIC FUNCTION fDate(dDate)

   // Function to return a date

   // Declare
   local dRetu := ctod("")
   local aCscr := fASaveScr()
   local nBoxc := 0
   local getlist := {}

   // Values
   if !empty(dDate)
      dRetu := dDate
   endif

   // The get
   if cLanType() == "A"
      nBoxc := fBoxCent(11,"Dragtigheid ondersoekdatum? xx/xx/xx",3)
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die datum waarop die dragtigheidsondersoeke gedoen is!")
      @12,nBoxc say "Dragtigheid ondersoekdatum?" get dRetu
   else
      nBoxc := fBoxCent(11,"Pregnancy diagnosis date? xx/xx/xx",3)
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the date on which the pregnancy diagnosis were done!")
      @12,nBoxc say "Pregnancy diagnosis date?" get dRetu

   endif
   setcursor(1)
   read
   setcursor(0)

   // If escaped
   if lastkey() == K_ESC
      dRetu := ctod("")
   endif

   // Reset
   fARestScr(aCscr)

return dRetu

/******************************************************************************/
STATIC FUNCTION fYesNo(cKeyp,dDate,cTeeg,cMakdra,cNorDra)

   // Function to enter yes no pd

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local cBull := ""
   local dDekd := ctod("")
   local cTipe := ""
   local nData := 0

   begin sequence

      if cKeyp $ "JY123456"

         // Pregnant

         // Pd date must be after mating date
         if dDate <= SM3DATA->dekdat
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen voor die dekdatum!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done before the mating date!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Pd date must be before the end of the period
         if dDate > SM3DATA->dekdat+cMakdra
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen na die maksimum dragtigheidstydperk!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done after the maximum gestation period!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Update the matings file
         select SM3DEKK
         seek cTeeg+SM3PREG->idnr
         do while SM3DEKK->teelgroep+SM3DEKK->idmoer == cTeeg+SM3PREG->idnr

            // Lock the file
            do while !rlock()
            enddo

            // Save the mark with the first mating
            if empty(cBull)

               // Save the pd
               SM3DEKK->dragtig := cKeyp
               SM3DEKK->dragwe  := round((dDate-SM3DEKK->datumin)/7,1)
               SM3DEKK->dragda  := dDate

               // Save the values
               cBull := SM3DEKK->idvaar
               dDekd := SM3DEKK->datumin
               cTipe := SM3DEKK->vaarkode

            else

               // Clean out the rest of the mating file
               SM3DEKK->dragtig := " "
               SM3DEKK->dragwe  := 0
               SM3DEKK->dragda  := ctod("")

            endif

            // Next record
            dbunlock()
            select SM3DEKK
            skip

         enddo

         // Update the main file
         SM3DATA->dragti    := cKeyp
         SM3DATA->dragda    := dDate
         SM3DATA->teelgroep := cTeeg
         SM3DATA->bulid     := cBull
         SM3DATA->dekdat    := dDekd
         SM3DATA->tipede    := cTipe
         SM3DATA->dragwe    := round((dDate-dDekd)/7,1)

         // Update the temp file
         SM3PREG->verwag := dDekd + cNordra
         if !empty(SM3DATA->lkalfdatum) .and. !empty(SM3PREG->verwag)
            nData := SM3PREG->verwag - SM3DATA->lkalfdatum
            if nData > 0 .and. nData <= 9999
               SM3PREG->vertkp := nData
            endif
         endif

      elseif cKeyp $ "N0"

         // Not pregnant

         // Pd date must be after mating date
         if dDate <= SM3DATA->dekdat
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen voor die dekdatum!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done before the mating date!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Pd date must be before the end of the period
         if dDate > SM3DATA->dekdat+cMakdra
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen na die maksimum dragtigheidstydperk!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done after the maximum gestation period!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Update the matings file
         select SM3DEKK
         seek cTeeg+SM3PREG->idnr
         do while SM3DEKK->teelgroep+SM3DEKK->idmoer == cTeeg+SM3PREG->idnr

            // Lock the file
            do while !rlock()
            enddo

            // Save the mark with the first mating
            if empty(cBull)

               // Save the pd
               SM3DEKK->dragtig := cKeyp
               SM3DEKK->dragwe  := 0
               SM3DEKK->dragda  := dDate

               // Save the values
               cBull := SM3DEKK->idvaar
               dDekd := SM3DEKK->datumin
               cTipe := SM3DEKK->vaarkode

            else

               // Clean out the rest of the mating file
               SM3DEKK->dragtig := " "
               SM3DEKK->dragwe  := 0
               SM3DEKK->dragda  := ctod("")

            endif

            // Next record
            dbunlock()
            select SM3DEKK
            skip

         enddo

         // Update the main file
         SM3DATA->dragti    := cKeyp
         SM3DATA->dragda    := dDate
         SM3DATA->dragwe    := 0
         SM3DATA->teelgroep := cTeeg
         SM3DATA->bulid     := cBull
         SM3DATA->dekdat    := dDekd
         SM3DATA->tipede    := cTipe

         // Update the temp file
         SM3PREG->verwag := ctod("")
         SM3PREG->vertkp := 0

      else

         // Clear the pd status

         // Update the matings file
         select SM3DEKK
         seek cTeeg+SM3PREG->idnr
         do while SM3DEKK->teelgroep+SM3DEKK->idmoer == cTeeg+SM3PREG->idnr

            // Lock the file
            do while !rlock()
            enddo

            // Save
            SM3DEKK->dragtig := " "
            SM3DEKK->dragwe  := 0
            SM3DEKK->dragda  := ctod("")

            // Next record
            dbunlock()
            select SM3DEKK
            skip

         enddo

         // Update the main file
         SM3DATA->dragti := " "
         SM3DATA->dragda := ctod("")
         SM3DATA->dragwe := 0

         // Update the temp file
         SM3PREG->verwag := ctod("")
         SM3PREG->vertkp := 0

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWeeks(cKeyp,dDate,cTeeg,cMakdra,cNorDra)

   // Function to enter yes no pd

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local nBoxc := 0
   local nWeek := 0
   local dMate := 0
   local cBull := ""
   local dDekd := ctod("")
   local cTipe := ""
   local nData := 0
   local getlist := {}

   begin sequence

      // Ask the number of weeks pregnant
      keyboard cKeyp
      nBoxc := fBoxCent(11,"12345678901234567890 123456789012",4)
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Lys van diere")
         fScrBood(maxrow()  ,"Tik die aantal weke dragtig op die ondersoekdatum!")
         @12,nBoxc say "           Id nommer"
         @13,nBoxc say " Aantal weke dragtig" get nWeek pict "99.9"
      else
         fScrBood(maxrow()-1,"[Esc]=List of aanimals")
         fScrBood(maxrow()  ,"Type the number of weeks pregnant on the diagnosis date!")
         @12,nBoxc say "           Id number"
         @13,nBoxc say "      Weeks pregnant" get nWeek pict "99.9"
      endif
      setcolor(cColInve())
      @12,nBoxc+21 say SM3PREG->idnr
      setcolor(cColNorm())
      setcursor(1)
      read
      setcursor(0)

      // If escaped
      if lastkey() == K_ESC
         lRetu := .f.
         break
      endif

      // Values
      dMate := dDate - int(nWeek*7)

      if nWeek > 0

         // Pregnant

         // Pd date must be after mating date
         if dDate <= SM3DATA->dekdat
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen voor die dekdatum!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done before the mating date!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Pd date must be before the end of the period
         if dDate > SM3DATA->dekdat+cMakdra
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen na die maksimum dragtigheidstydperk!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done after the maximum gestation period!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Update the matings file
         select SM3DEKK
         seek cTeeg+SM3PREG->idnr
         do while SM3DEKK->teelgroep+SM3DEKK->idmoer == cTeeg+SM3PREG->idnr

            // Lock the file
            do while !rlock()
            enddo

            // Find the correct mating
            if empty(cBull) .and. dMate >= SM3DEKK->datumin-10 .and. dMate <= SM3DEKK->datumuit+10
               cBull := SM3DEKK->idvaar
               cTipe := SM3DEKK->vaarkode
               if cLanType() == "A"
                  SM3DEKK->dragtig := "J"
               else
                  SM3DEKK->dragtig := "Y"
               endif
               SM3DEKK->dragwe := nWeek
               SM3DEKK->dragda := dDate
               cBull := SM3DEKK->idvaar
               if SM3DEKK->vaarkode $ " 12"
                  dDekd := dMate
               else
                  dDekd := SM3DEKK->datumin
               endif
               cTipe := SM3DEKK->vaarkode
            else
               SM3DEKK->dragtig := " "
               SM3DEKK->dragwe  := 0
               SM3DEKK->dragda  := ctod("")
            endif

            // Next record
            dbunlock()
            select SM3DEKK
            skip

         enddo

         // If mating was not found
         if empty(cBull)

            // Update the matings file
            select SM3DEKK
            seek cTeeg+SM3PREG->idnr

            // Lock the file
            do while !rlock()
            enddo

            // Save the pd
            if cLanType() == "A"
               SM3DEKK->dragtig := "J"
            else
               SM3DEKK->dragtig := "Y"
            endif
            SM3DEKK->dragwe := nWeek
            SM3DEKK->dragda := dDate

            // Save the values
            cBull := SM3DEKK->idvaar
            dDekd := SM3DEKK->datumin
            cTipe := SM3DEKK->vaarkode

         endif

         // Update the main file
         if cLanType() == "A"
            SM3DATA->dragti := "J"
         else
            SM3DATA->dragti := "Y"
         endif
         SM3DATA->dragda    := dDate
         SM3DATA->dragwe    := nWeek
         SM3DATA->teelgroep := cTeeg
         SM3DATA->bulid     := cBull
         SM3DATA->dekdat    := dDekd
         SM3DATA->tipede    := cTipe

         // Update the temp file
         SM3PREG->verwag := dMate + cNordra
         if !empty(SM3DATA->lkalfdatum) .and. !empty(SM3PREG->verwag)
            nData := SM3PREG->verwag - SM3DATA->lkalfdatum
            if nData > 0 .and. nData <= 9999
               SM3PREG->vertkp := nData
            endif
         endif

      else

         // Not pregnant

         // Pd date must be after mating date
         if dDate <= SM3DATA->dekdat
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen voor die dekdatum!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done before the mating date!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Pd date must be before the end of the period
         if dDate > SM3DATA->dekdat+cMakdra
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dragtigheidondersoek is gedoen na die maksimum dragtigheidstydperk!")
            else
               fScrBood(maxrow()-1,"Pregnancy diagnosis was done after the maximum gestation period!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Update the matings file
         select SM3DEKK
         seek cTeeg+SM3PREG->idnr
         do while SM3DEKK->teelgroep+SM3DEKK->idmoer == cTeeg+SM3PREG->idnr

            // Lock the file
            do while !rlock()
            enddo

            // Save the mark with the first mating
            if empty(cBull)

               // Save the pd
               SM3DEKK->dragtig := "N"
               SM3DEKK->dragwe  := 0
               SM3DEKK->dragda  := ctod("")

               // Save the values
               cBull := SM3DEKK->idvaar
               dDekd := SM3DEKK->datumin
               cTipe := SM3DEKK->vaarkode

            else

               // Clean out the rest of the mating file
               SM3DEKK->dragtig := " "
               SM3DEKK->dragwe  := 0
               SM3DEKK->dragda  := ctod("")

            endif

            // Next record
            dbunlock()
            select SM3DEKK
            skip

         enddo

         // Update the main file
         SM3DATA->dragti    := "N"
         SM3DATA->dragda    := dDate
         SM3DATA->dragwe    := 0
         SM3DATA->teelgroep := cTeeg
         SM3DATA->bulid     := cBull
         SM3DATA->dekdat    := dDekd
         SM3DATA->tipede    := cTipe

         // Update the temp file
         SM3PREG->verwag := ctod("")
         SM3PREG->vertkp := 0

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fStatistic

   // Function to calculate and display statistics

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nPreg := 0
   local nOpen := 0
   local nBoxc := 0
   begin sequence

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dragtigheids statistieke word bereken")
      else
         fScrWbood(maxrow(),"Pregnancy statistics being calculated")
      endif

      // Select the database
      select SM3PREG
      go top

      // The loop to count
      do while !eof()

         // Screen
         setcolor(cColBott())
         if cLanType() == "A"
            @maxrow()-1,26 say SM3PREG->idnr+" "+fPercent(recno(),lastrec())+"% Voltooi"
         else
            @maxrow()-1,26 say SM3PREG->idnr+" "+fPercent(recno(),lastrec())+"% Completed"
         endif
         setcolor(cColNorm())

         // The calculation
         if SM3DATA->dragti $ "JY*123456"
            nPreg++
         elseif SM3DATA->dragti $ "N0"
            nOpen++
         else
         endif

         // Next record
         select SM3PREG
         skip

      enddo

      // Display the data
      if cLanType() == "A"
         nBoxc := fBoxCent(8,"Nie-dragtig  ----  ---",9)
         @ 9,nBoxc say "             Aant   % "
         @10,nBoxc say "             ----  ---"
         @11,nBoxc say "    Dragtig  "
         @11,col() say str(nPreg,4)+"  "
         @11,col() say padl(fPercent(nPreg,lastrec()),3)
         @12,nBoxc say "Nie-dragtig  "
         @12,col() say str(nOpen,4)+"  "
         @12,col() say padl(fPercent(nOpen,lastrec()),3)
         @13,nBoxc say "      Ander  "
         @13,col() say str(lastrec()-nPreg-nOpen,4)+"  "
         @13,col() say padl(fPercent(lastrec()-nPreg-nOpen,lastrec()),3)
         @14,nBoxc say "             ====  ==="
         @15,nBoxc say "     Totaal  "
         @15,col() say str(lastrec(),4)+"  "
         @15,col() say padl(fPercent(lastrec(),lastrec()),3)
      else
         nBoxc := fBoxCent(8,"Pregnant  ----  ---",9)
         @ 9,nBoxc say "          Aant   % "
         @10,nBoxc say "          ----  ---"
         @11,nBoxc say "Pregnant  "
         @11,col() say str(nPreg,4)+"  "
         @11,col() say padl(fPercent(nPreg,lastrec()),3)
         @12,nBoxc say "    Open  "
         @12,col() say str(nOpen,4)+"  "
         @12,col() say padl(fPercent(nOpen,lastrec()),3)
         @13,nBoxc say "   Other  "
         @13,col() say str(lastrec()-nPreg-nOpen,4)+"  "
         @13,col() say padl(fPercent(lastrec()-nPreg-nOpen,lastrec()),3)
         @14,nBoxc say "          ====  ==="
         @15,nBoxc say "   Total  "
         @15,col() say str(lastrec(),4)+"  "
         @15,col() say padl(fPercent(lastrec(),lastrec()),3)
      endif

      // Screen
      fScrBood(maxrow()-1)
      fScrWait(maxrow())

   end
   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(dDate,cTeeg,cNordra)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local aOpsk := {}
   local i     := 0
   local lLoop := .t.
   local cPrnl := ""
   local nTota := 0
   local cData := ""
   local nReko := 1
   local nDrag := 0
   local nOpen := 0
   local nChoi := 1
   local nCspa := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   begin sequence

      // Test availability of printer
      if fPrnReady(maxrow()-1) == K_ESC
         break
      endif

      // Ask in which order
      nChoi := fNewMenu(nChoi,"SM3PREP")
      fARestScr(aCscr)

      // Sort the field
      if nChoi == 2
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            fScrWbood(maxrow(),"Sorteer data in verwagte kalfdatum volgorde")
         else
            fScrWbood(maxrow(),"Sort data in expected calving date order")
         endif
         index on dtos(SM3PREG->verwag) to sm3preg
      endif


      // Screen - fields to print
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Drukuitleg word bepaal")
      else
         fScrBood(maxrow(),"Print outlay being determined")
      endif
      if empty(aOpsk)
         aadd(aVeld,{"SM3PREG" ,"idnr"      })
         // aadd(aVeld,{"SM3DATA" ,"teelgroep" })
         aadd(aVeld,{"SM3DATA" ,"dekdat"    })
         aadd(aVeld,{"SM3DATA" ,"tipede"    })
         aadd(aVeld,{"SM3DATA" ,"bulid"     })
         aadd(aVeld,{"SM3DATA" ,"dragda"    })
         aadd(aVeld,{"SM3DATA" ,"dragti"    })
         aadd(aVeld,{"SM3DATA" ,"dragwe"    })
         aadd(aVeld,{"SM3PREG" ,"verwag"    })
         aadd(aVeld,{"SM3DATA" ,"lkalfdatum"})
         aadd(aVeld,{"SM3PREG" ,"vertkp"    })
      endif
      aOpsk := fGetField(aVeld)

      // Determine the print width
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,4] + nCspa
      next

      if nWidt <= nPrnWidt()
         // Normal
         cPcod := cPrnNorm()
         nWidt := nPrnWidt()
         nTopl := nPrnLine()
         nPrnl := nPrnPrnl() - 2
         nPagl := nPrnLeng()
      else
         // Condense
         cPcod := cPrnCond()
         nWidt := nPrnCwid()
         nTopl := nPrnLine()
         if nPrnLptp() < 8
            nPrnl := nPrnPrnl() - 2
            nPagl := nPrnLeng()
         else
            nPrnl := nPrcPrnl() - 2
            nPagl := nPrcLeng()
         endif
      endif

      nMidc := nWidt - 29

      // Select the dfata file
      select SM3PREG
      go top
      nTota := lastrec()

      // Sort the field
      if nChoi == 2
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            fScrWbood(maxrow(),"Sorteer data in verwagte kalfdatum volgorde")
         else
            fScrWbood(maxrow(),"Sort data in expected calving date order")
         endif
         index on dtos(SM3PREG->verwag) to sm3preg for !empty(SM3PREG->verwag)
         set index to sm3preg
         go top
         nTota := cmxkeycount()
      endif

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"DRAGTIGHEIDSONDERSOEKLYS word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Dragtigheidsondersoeke vir die "+trim(cTeeg)+" kalfseisoen."
      else
         fScrbood(maxrow(),"PREGNANCY DIAGNOSIS LIST being printed!  [Esc]=Stop printer.")
         cHdln := "Pregnancy diagnosis report for the "+trim(cTeeg)+" calving season."
      endif

      // Switch printer on
      fPrnOn()

      // The loop
      lLoop := .t.
      do while lLoop


         // Headings
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
            @prow()+1,  1 say repl( "=", nWidt )

            // 1st heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,7]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 2nd heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,8]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 3rd heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,9]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 4th heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += repl("-",aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)
         endif

         // Stop printer
         if fPrnStop() = K_ESC
            lRetu := .f.
            break
         endif

         // Data
         cPrnl := ""
         for i = 1 to len(aOpsk)
            cData := aOpsk[i,1] + aOpsk[i,2]
            if aOpsk[i,3] == "D"
               cPrnl += dtoc(&(cData)) + space(nCspa)
            elseif aOpsk[i,3] == "N"
               cPrnl += str(&(cData),aOpsk[i,4],aOpsk[i,5]) + space(nCspa)
            else
               cPrnl += &(cData) + space(nCspa)
            endif
         next
         @prow()+1,1 say left(cPrnl,nWidt)

         // Count
         if SM3DATA->dragti $ "JY"
            nDrag++
         elseif SM3DATA->dragti == "N"
            nOpen++
         endif

         // Screen
         // fPrnOff()
         // if nTota > 0
         //    setcolor( cColBott() )
         //    if cLanType() == "A"
         //       fScrBood(maxrow()-1,str((nReko/nTota)*100,4,0)+" % Voltooi")
         //    else
         //       fScrBood(maxrow()-1,str((nReko/nTota)*100,4,0)+" % Completed")
         //    endif
         //    setcolor( cColNorm() )
         //    nReko++
         // endif
         // fPrnOn()

         // Next record
         select SM3PREG
         skip

         // End of page or end of file
         if prow() >= nPrnl .or. eof()

            if eof()
               // Bottom line
               @prow()+1, 1 say repl("-",nWidt)

               @prow()+1, 1 say "Totaal: "+ltrim(str(nTota))+" (100%)"
               if nDrag > 0
                  @prow(),pcol()+2 say "Dragtig: "+ltrim(str(nDrag))
                  @prow(),pcol()+1 say "("+fPercent(nDrag,nTota)+"%)"
               endif
               if nOpen > 0
                  @prow(),pcol()+2 say "Nie-dragtig: "+ltrim(str(nOpen))
                  @prow(),pcol()+1 say "("+fPercent(nOpen,nTota)+"%)"
               endif
               if nDrag+nOpen # nTota
                  @prow(),pcol()+2 say "Ander: "+ltrim(str(nTota-(nDrag+nOpen)))
                  @prow(),pcol()+1 say "("+fPercent(nTota-(nDrag+nOpen),nTota)+"%)"
               endif
            endif

            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++

            // End of file
            if eof()
               lLoop := .f.
            endif

         endif

      enddo

      fPrnOff()

   end

   // Delete the index file
   if nChoi == 2
      select SM3PREG
      set index to
      ferase("SM3PREG"+ordbagext())
   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
