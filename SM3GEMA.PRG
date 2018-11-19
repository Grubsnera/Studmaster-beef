// Application: StudMaster for Beef Cattle
//   File Name: SM3GEMA.PRG
// Description: Program to print regular weighings
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 04-17-95      08:15:38am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3gema

   // Declare
   local lRetu  := .t.
   local aCscr  := fASaveScr()
   local aCdbf  := fATopen()
   local nChoi  := 1
   local cTest  := ""
   local nBoxc  := 0
   local lLoop  := .t.
   local dDa1a  := ctod("")
   local dDa2a  := ctod("")
   local cInku  := " "
   local cWeeg  := " "
   local cDaee  := " "
   local cToaf  := " "
   local cGdtt  := " "
   local lStar  := .f.
   local lEndd  := .f.
   local aDates := {}
   local aDate  := {}
   local aMass  := {}
   local i      := 0
   local n      := 0
   local cIdnr  := ""
   local nReko  := 0
   local nDate  := 0
   local nMass  := 0
   local nData  := 0
   local nNumb  := 0
   local getlist := {}
   begin sequence

      // Display menu to ask which group of animals
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
         fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Menu")
      else
         fScrOpsk(1,"Option "+cOption())
         fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Menu")
      endif

      nChoi := fNewMenu(nChoi,"SM3GEMA")
      cOption(nChoi)

      // The choices
      if nChoi == 1

         // All of them

      elseif nChoi == 2

         // Index group
         cTest := sm3indg(4)
         if empty(cTest)
            if cLanType() == "A"
               fScrWait(maxrow(),"Geen indeksgroep is gekies nie!")
            else
               fScrWait(maxrow(),"No index group was selected!")
            endif
            break
         endif

      elseif nChoi == 3

         // Phase group
         cTest := sm3fasg(4)
         if empty(cTest)
            if cLanType() == "A"
               fScrWait(maxrow(),"Geen fasegroep is gekies nie!")
            else
               fScrWait(maxrow(),"No phase group was selected!")
            endif
            break
         endif

      elseif nChoi == 4

         // Group
         cTest := sm3groe()
         if empty(cTest)
            if cLanType() == "A"
               fScrWait(maxrow(),"Geen groep is gekies nie!")
            else
               fScrWait(maxrow(),"No group was selected!")
            endif
            break
         endif

      elseif nChoi == 5

         // Selection group
         cTest := sm3selg()
         if empty(cTest)
            if cLanType() == "A"
               fScrWait(maxrow(),"Geen seleksiegroep is gekies nie!")
            else
               fScrWait(maxrow(),"No selection group was selected!")
            endif
            break
         endif

      else

         // Exit
         break

      endif

      // Ask the data to be printed
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
         nBoxc := fBoxCent(7,space(50),10,"GEREELDE WEGING MASSAS")
      else
         fScrOpsk(,"Option "+cOption())
         nBoxc := fBoxCent(7,space(50),10,"REGULAR WEIGHING MASSES")
      endif

      lLoop := .t.
      do while lLoop
         if cLanType() == "A"
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow()  ,"Tik die besonderhede soos verlang!")

            @ 8,nBoxc say "           Sluit massas in geneem vanaf" get dDa1a
            @ 9,nBoxc say "                                    tot" get dDa2a

            @11,nBoxc say "Vertoon slegs in kudde (lewende) diere?" get cInku pict "!"
            @12,nBoxc say "      Vertoon weegdatum by elke weging?" get cWeeg pict "!"
            @13,nBoxc say "            Vertoon dae tussen wegings?" get cDaee pict "!"
            @14,nBoxc say "          Vertoon massa toename/afname?" get cToaf pict "!"
            @15,nBoxc say "            Vertoon gdt tussen wegings?" get cGdtt pict "!"

         else

            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow()  ,"Type the required particulars!")

            @ 8,nBoxc say "             Include masses taken from" get dDa1a
            @ 9,nBoxc say "                                    to" get dDa2a

            @11,nBoxc say "Display only in herd (living) animals?" get cInku pict "!"
            @12,nBoxc say "     Display weighing dates on report?" get cWeeg pict "!"
            @13,nBoxc say "       Display days between weighings?" get cDaee pict "!"
            @14,nBoxc say "               Display mass gain/loss?" get cToaf pict "!"
            @15,nBoxc say "        Display adg between weighings?" get cGdtt pict "!"

         endif
         setcursor(1)
         read
         setcursor(0)

         // If escaped
         if lastkey() == K_ESC
            break
         endif

         // Tests
         if (! EMPTY(dDa1a) .AND. ! EMPTY(dDa2a))
            if dDa1a > dDa2a
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"Begindatum moet vroe‰r as die einddatum wees!")
               else
                  fScrBood(maxrow()-1,"First date should be earlier than the last date!")
               endif
               fScrWait(maxrow())
               loop
            endif
         endif

         lLoop := .f.

      enddo

      // Open the data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ferase(cDd()+"SM3FASM"+ordbagext())
      aCdbf := fATopen(aCdbf,cDd(),"SM3FASM",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap
      aCdbf := fATopen(aCdbf,cDd(),"SM3FAST",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap

      // Build file with animals
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere word uitgesoek")
      else
         fScrWbood(maxrow(),"Animals being selected")
      endif
      if nChoi == 2
         // Index group
         DBSELECTAREA("SM3DATA")
         ordsetfocus(3)
         seek cTest
         do while SM3DATA->indekskode == cTest
            setcolor(cColBott())
            @maxrow()-1,30 say SM3DATA->idnr
            setcolor(cColNorm())
            if upper(cInku) $ "YJ"
               if SM3DATA->uitkrede $ cWaarisd()
                  DBSELECTAREA("SM3FASM")
                  dbappend()
                  SM3FASM->idnr := SM3DATA->idnr
                  SM3FASM->sortee := "1"
                  SM3FASM->dispid := SM3FASM->idnr
                  SM3FASM->descri := "Mass"
               endif
            else
               DBSELECTAREA("SM3FASM")
               dbappend()
               SM3FASM->idnr := SM3DATA->idnr
               SM3FASM->sortee := "1"
               SM3FASM->dispid := SM3FASM->idnr
               SM3FASM->descri := "Mass"
            endif
            // Next record
            DBSELECTAREA("SM3DATA")
            DBSKIP()
         enddo

      elseif nChoi == 3
         // Phase group
         DBSELECTAREA("SM3DATA")
         ordsetfocus(2)
         seek cTest
         do while SM3DATA->fasekode == cTest
            setcolor(cColBott())
            @maxrow()-1,30 say SM3DATA->idnr
            setcolor(cColNorm())
            if upper(cInku) $ "YJ"
               if SM3DATA->uitkrede $ cWaarisd()
                  DBSELECTAREA("SM3FASM")
                  dbappend()
                  SM3FASM->idnr := SM3DATA->idnr
                  SM3FASM->sortee := "1"
                  SM3FASM->dispid := SM3FASM->idnr
                  SM3FASM->descri := "Mass"
               endif
            else
               DBSELECTAREA("SM3FASM")
               dbappend()
               SM3FASM->idnr := SM3DATA->idnr
               SM3FASM->sortee := "1"
               SM3FASM->dispid := SM3FASM->idnr
               SM3FASM->descri := "Mass"
            endif
            // Next record
            DBSELECTAREA("SM3DATA")
            DBSKIP()
         enddo

      elseif nChoi == 4 .or. nChoi == 5
         // Groups and selection groups
         DBSELECTAREA("SM3DATA")
         if upper(cInku) $ "YJ"
            ordsetfocus(7)
         else
            ordsetfocus(1)
         endif
         DBGOTOP()
         do while !eof()
            setcolor(cColBott())
            @maxrow()-1,30 say SM3DATA->idnr
            setcolor(cColNorm())
            if &(cTest)
               DBSELECTAREA("SM3FASM")
               dbappend()
               SM3FASM->idnr := SM3DATA->idnr
               SM3FASM->sortee := "1"
               SM3FASM->dispid := SM3FASM->idnr
               SM3FASM->descri := "Mass"
            endif
            // Next record
            DBSELECTAREA("SM3DATA")
            DBSKIP()
         enddo

      else
         // All animals
         DBSELECTAREA("SM3DATA")
         if upper(cInku) $ "YJ"
            ordsetfocus(7)
         else
            ordsetfocus(1)
         endif
         DBGOTOP()
         do while !eof()
            setcolor(cColBott())
            @maxrow()-1,30 say SM3DATA->idnr
            setcolor(cColNorm())
            DBSELECTAREA("SM3FASM")
            dbappend()
            SM3FASM->idnr := SM3DATA->idnr
            SM3FASM->sortee := "1"
            SM3FASM->dispid := SM3FASM->idnr
            SM3FASM->descri := "Mass"
            // Next record
            DBSELECTAREA("SM3DATA")
            DBSKIP()
         enddo

      endif
      DBSELECTAREA("SM3DATA")
      ordsetfocus(1)
      DBGOTOP()

      // Locate the animals with masses
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere met massas word uitgesoek")
      else
         fScrWbood(maxrow(),"Animals with masses being selected")
      endif
      DBSELECTAREA("SM3FASM")
      DBGOTOP()
      do while ! EOF()

         // Screen
         setcolor(cColBott())
         @maxrow()-1,30 say SM3FASM->idnr
         setcolor(cColNorm())

         // See if mass exist
         lStar := .f.
         lEndd := .f.
         if empty(dDa1a) .and. empty(dDa2a)
            DBSELECTAREA("SM3WEEG")

            if SM3WEEG->(DBSEEK(SM3FASM->idnr))
               lStar := .t.
               lEndd := .t.
               do while SM3WEEG->idnr == SM3FASM->idnr
                  DBSELECTAREA("SM3FAST")
                  DBAPPEND()
                  SM3FAST->idnr      := SM3WEEG->idnr
                  SM3FAST->weegdatum := SM3WEEG->weegdatum
                  SM3FAST->massa     := SM3WEEG->massa

                  IF ASCAN(aDates,SM3WEEG->weegdatum) = 0
                     aadd(aDates,SM3WEEG->weegdatum)
                  ENDIF

                  DBSELECTAREA("SM3WEEG")
                  DBSKIP()
               enddo
            endif
         elseif ! empty(dDa1a) .and. empty(dDa2a)
            DBSELECTAREA("SM3WEEG")

            if SM3WEEG->(DBSEEK(SM3FASM->idnr))
               lEndd := .t.
               do while SM3WEEG->idnr == SM3FASM->idnr
                  if SM3WEEG->weegdatum >= dDa1a
                     lStar := .t.
                     DBSELECTAREA("SM3FAST")
                     DBAPPEND()
                     SM3FAST->idnr      := SM3WEEG->idnr
                     SM3FAST->weegdatum := SM3WEEG->weegdatum
                     SM3FAST->massa     := SM3WEEG->massa

                     IF ASCAN(aDates,SM3WEEG->weegdatum) = 0
                        aadd(aDates,SM3WEEG->weegdatum)
                     ENDIF

                     DBSELECTAREA("SM3WEEG")
                  endif

                  DBSKIP()
               enddo
            endif
         elseif empty(dDa1a) .and. ! empty(dDa2a)
            DBSELECTAREA("SM3WEEG")

            if SM3WEEG->(DBSEEK(SM3FASM->idnr))
               lStar := .t.
               do while SM3WEEG->idnr == SM3FASM->idnr
                  if SM3WEEG->weegdatum <= dDa2a
                     lEndd := .t.
                     DBSELECTAREA("SM3FAST")
                     DBAPPEND()
                     SM3FAST->idnr      := SM3WEEG->idnr
                     SM3FAST->weegdatum := SM3WEEG->weegdatum
                     SM3FAST->massa     := SM3WEEG->massa

                     IF ASCAN(aDates,SM3WEEG->weegdatum) = 0
                        aadd(aDates,SM3WEEG->weegdatum)
                     ENDIF

                     DBSELECTAREA("SM3WEEG")
                  endif

                  DBSKIP()
               enddo
            endif
         else
            DBSELECTAREA("SM3WEEG")

            if SM3WEEG->(DBSEEK(SM3FASM->idnr))
               do while SM3WEEG->idnr == SM3FASM->idnr
                  if SM3WEEG->weegdatum >= dDa1a .and. SM3WEEG->weegdatum <= dDa2a
                     lStar := .t.
                     lEndd := .t.
                     DBSELECTAREA("SM3FAST")
                     DBAPPEND()
                     SM3FAST->idnr      := SM3WEEG->idnr
                     SM3FAST->weegdatum := SM3WEEG->weegdatum
                     SM3FAST->massa     := SM3WEEG->massa

                     IF ASCAN(aDates,SM3WEEG->weegdatum) = 0
                        aadd(aDates,SM3WEEG->weegdatum)
                     ENDIF

                     DBSELECTAREA("SM3WEEG")
                  endif

                  DBSKIP()
               enddo
            endif
         endif

         DBSELECTAREA("SM3FASM")
         // Delete if false
         if ! lStar .or. ! lEndd
            DBDELETE()
         endif

         DBSKIP()
      enddo

      ASORT(aDates,,, { |x,y| x < y })

      IF LEN(aDates) > 18
         n := LEN(aDates) - 18
         FOR i := 1 TO 18
            aDates[i] := aDates[i+n]
         NEXT

         ASIZE(aDates,18)                        // Retain only 1st 18 weight dates
      ENDIF

      DBSELECTAREA("SM3FASM")
      DBGOTOP()
      do while ! EOF() .AND. SM3FASM->sortee == "1" //!eof()

         // Screen
         setcolor(cColBott())
         @maxrow()-1,30 say SM3FASM->idnr
         setcolor(cColNorm())

         // Empty array
         aDate := {}
         aMass := {}

         DBSELECTAREA("SM3FAST")
         IF ! SM3FAST->(DBSEEK(SM3FASM->idnr))
            DBSELECTAREA("SM3FASM")
            DBDELETE()
            DBSKIP()
            LOOP
         ENDIF

         DO WHILE ! EOF() .AND. SM3FAST->idnr == SM3FASM->idnr
            AADD(aDate,SM3FAST->weegdatum)
            AADD(aMass,SM3FAST->massa)
            DBSKIP()
         ENDDO

         // Add mass to masses file
         DBSELECTAREA("SM3FASM")
         SM3FASM->recnum := ++nNumb
         for i := 1 to len(aMass)
            n := ASCAN(aDates,aDate[i])
            if n != 0
               fieldput(n+1,str(aMass[i],5,0))
            endif
         next
         nReko := recno()
         cIdnr := SM3FASM->idnr

         // Add weighing dates to masses file
         if cWeeg $ "YJ"
            dbappend()
            SM3FASM->idnr := cIdnr
            SM3FASM->sortee := "2"
            SM3FASM->recnum := nNumb
            if cLanType() == "A"
               SM3FASM->descri := "Datu"
            else
               SM3FASM->descri := "Date"
            endif
            for i := 1 to len(aDates)
               fieldput(i+1,left(dtoc(aDates[i]),5))
            next
         endif

         // Add dates between weighings to masses file
         if cDaee $ "YJ"
            dbappend()
            SM3FASM->idnr := cIdnr
            SM3FASM->sortee := "3"
            SM3FASM->recnum := nNumb
            if cLanType() == "A"
               SM3FASM->descri := "Dae"
            else
               SM3FASM->descri := "Days"
            endif
            for i := 1 to len(aDate)
               if i == 1
                  fieldput(i+1,padl("0",5))
               else
                  nData := aDate[i] - aDate[i-1]
                  n := ASCAN(aDates,aDate[i])
                  if n != 0
                     fieldput(n+1,padl(alltrim(str(nData)),5))
                  endif
               endif
            next
         endif

         // Add mass gain between weighings to masses file
         if cToaf $ "YJ"
            dbappend()
            SM3FASM->idnr := cIdnr
            SM3FASM->sortee := "4"
            SM3FASM->recnum := nNumb
            if cLanType() == "A"
               SM3FASM->descri := "Toen"
            else
               SM3FASM->descri := "Gain"
            endif
            for i := 1 to len(aMass)
               if i == 1
                  fieldput(i+1,padl("0",5))
               else
                  nData := aMass[i] - aMass[i-1]
                  n := ASCAN(aDates,aDate[i])
                  if n != 0
                     fieldput(n+1,padl(alltrim(str(nData)),5))
                  endif
               endif
            next
         endif

         // Add adg between weighings to masses file
         if cGdtt $ "YJ"
            dbappend()
            SM3FASM->idnr := cIdnr
            SM3FASM->sortee := "5"
            SM3FASM->recnum := nNumb
            if cLanType() == "A"
               SM3FASM->descri := "Gdt"
            else
               SM3FASM->descri := "Adg"
            endif
            for i := 1 to len(aMass)
               if i == 1
                  fieldput(i+1,padl("0",5))
               else
                  nDate := aDate[i] - aDate[i-1]
                  nMass := (aMass[i]-aMass[i-1])*1000
                  nData := zer(nMass,nDate)
                  n := ASCAN(aDates,aDate[i])
                  if n != 0
                     fieldput(n+1,padl(alltrim(str(nData,5,0)),5))
                  endif
               endif
            next
         endif

         // Add a blank line to the file
         if cWeeg $ "YJ" .or. cDaee $ "YJ" .or. cToaf $ "YJ" .or. cGdtt $ "YJ"
            dbappend()
            SM3FASM->idnr := cIdnr
            SM3FASM->sortee := "6"
            SM3FASM->recnum := nNumb
         endif

         // Next record
         goto nReko
         DBSELECTAREA("SM3FASM")
         DBSKIP()

      enddo
      pack
      DBGOTOP()

      // Build an index for the file
      index on SM3FASM->idnr+SM3FASM->sortee to SM3FASM

      fDisplay(nNumb)

   end

   // Reset
   cOption(-1)
   fATclose(aCdbf)
   fARestScr(aCscr)

   // Delete the index file
   if file(cDd()+"SM3FASM"+ordbagext())
      ferase(cDd()+"SM3FASM"+ordbagext())
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fDisplay(nNumb)

   // Function to display the data

   // Declare
   local aVeld := {}                             // Send array
   local aOpsk := {}                             // Fields array
   local nScrl := 0                              // Screen length
   local cHead := ""                             //Heading of tbrowse
   local aCols := {}                             // Columns array
   local nTopp := 3                              // Top margin
   local nLeft := 2                              // Left margin
   local nBott := maxrow()-4                     // Bottom margin
   local nRigh := maxcol()-3                     // Right column
   local oBrow := NIL                            // Browse object
   local nKeyp := 1                              // Keypress
   local lMove := .f.                            // .T. if index key moved
   local nCurr := 1                              // Current record number
   local cCoun := ""                             // Counter display
   local i     := 1                              // Counter
   local cRetu := ""                             // Return value
   local cData := ""
   local oCols := NIL
   begin sequence

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      aadd(aVeld,{"SM3FASM","dispid"})
      aadd(aVeld,{"SM3FASM","descri"})
      aadd(aVeld,{"SM3FASM","mass01"})
      aadd(aVeld,{"SM3FASM","mass02"})
      aadd(aVeld,{"SM3FASM","mass03"})
      aadd(aVeld,{"SM3FASM","mass04"})
      aadd(aVeld,{"SM3FASM","mass05"})
      aadd(aVeld,{"SM3FASM","mass06"})
      aadd(aVeld,{"SM3FASM","mass07"})
      aadd(aVeld,{"SM3FASM","mass08"})
      aadd(aVeld,{"SM3FASM","mass09"})
      aadd(aVeld,{"SM3FASM","mass10"})
      aadd(aVeld,{"SM3FASM","mass11"})
      aadd(aVeld,{"SM3FASM","mass12"})
      aadd(aVeld,{"SM3FASM","mass13"})
      aadd(aVeld,{"SM3FASM","mass14"})
      aadd(aVeld,{"SM3FASM","mass15"})
      aadd(aVeld,{"SM3FASM","mass16"})
      aadd(aVeld,{"SM3FASM","mass17"})
      aadd(aVeld,{"SM3FASM","mass18"})
      aOpsk := fGetField(aVeld)

      // Move the record pointer
      DBSELECTAREA("SM3FASM")
      DBGOTOP()

      // Calculate averages
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"GEMIDDELDES word bereken")
      else
         fScrWbood(maxrow(),"AVERAGES being calculated")
      endif
      do while !eof()
         if SM3FASM->sortee == "1"
            for i = 1 to len(aOpsk)
               cData := aOpsk[i,1] + aOpsk[i,2]
               if val(&(cData)) > 0
                  aOpsk[i,11]++
                  aOpsk[i,12] += val(&(cData))
               endif
            next
         endif
         DBSKIP()
      enddo
      DBGOTOP()

      // Calculate window width
      for i = 1 to len( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,4] + 1
         // Columns
         //cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         aadd( aCols, TBColumnNew( cHead, fieldwblock(aOpsk[i,2],select(strtran(aOpsk[i,1],"->","")))))
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Draw the box
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, "GEREELDE WEGINGS" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "REGULAR WEIGHINGS" )
      endif
      setcolor( cColNorm() )

      // Build the browse
      oBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      oBrow:headsep := "Í"
      oBrow:colsep := "³"
      oBrow:footsep := "Í"

      // Build the browse columns
      for i = 1 to len( aCols )
         oBrow:addColumn( aCols[i] )

         // Add the averages
         oCols := oBrow:getcolumn(i)
         if i == 1
            if cLanType() == "A"
               oCols:footing := "Gemiddeldes"
            else
               oCols:footing := "Averages"
            endif
         else
            if aOpsk[i][11] > 0
               oCols:footing := str(aOpsk[i][12]/aOpsk[i][11],aOpsk[i][4],aOpsk[i][5])
            else
               oCols:footing := ""
            endif
         endif
         oBrow:setcolumn(i,oCols)
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc ]=Menu")
         fScrBood(maxrow()  , "[AltP]=Druk")
      else
         fScrBood(maxrow()-1, "[Esc ]=Menu")
         fScrBood(maxrow()  , "[AltP]=Druk")
      endif

      // Freeze
      oBrow:freeze := 2

      // Main loop
      do while nKeyp <> K_ESC

         // Stabilize
         FullStabilize(oBrow)
         if lMove
            do while recno() <> nCurr
               oBrow:up()
               FullStabilize(oBrow)
            enddo
            lMove := .f.
         endif

         // Display the record number
         cCoun := padl(ltrim(str(SM3FASM->recnum))+"/"+ltrim(str(nNumb)),10,chr(205))
         @nBott,nLeft+2 say cCoun

         // Wait for keypress
         if oBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            cRetu := fieldget(1)
            nKeyp := K_ESC

         elseif nKeyp == K_ALT_P
            // Alt P means print a record
            fPrint(aOpsk,nNumb)

         elseif nKeyp == K_F1
            // Help
            do help with "sm3gema",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(oBrow, nKeyp)

         endif

      enddo

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aOpsk,nNumb)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local i     := 0
   local nCspa := 1
   local lLoop := .t.
   local cPrnl := ""
   local nTota := 0
   local cData := ""
   local nReko := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local nLine := 0
   local nPrev := 0

   begin sequence

      // Test availability of printer
      if fPrnReady(maxrow()-1) == K_ESC
         break
      endif

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
      DBSELECTAREA("SM3FASM")
      DBGOTOP()
      nTota := lastrec()

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"MASSAVERSLAG word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Gereelde wegings massaverslag."
      else
         fScrbood(maxrow(),"MASS REPORT being printed!  [Esc]=Stop printer.")
         cHdln := "Regular weighings mass report."
      endif

      // Switch printer on
      fPrnOn()

      // The loop
      lLoop := .t.
      do while lLoop

         if nLine < VAL(SM3FASM->sortee)
            nLine := VAL(SM3FASM->sortee)
         endif

         // Headings
         if prow() = 0
            fPrnCod( cPcod)

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

         nPrev := VAL(SM3FASM->sortee)
         // Next record
         DBSELECTAREA("SM3FASM")
         DBSKIP()

         // End of page or end of file
         if eof()
            // Bottom line
            @prow()+1, 1 say repl("-",nWidt)

            for i := 1 to len(aOpsk)
               if i == 1
                  cPrnl := padr(ltrim(str(nNumb))+" Dier(e)",aOpsk[i,4])+space(nCspa)
               else
                  if aOpsk[i,11] > 0
                     cPrnl += str(aOpsk[i,12]/aOpsk[i,11],aOpsk[i,4],aOpsk[i,5]) + space(nCspa)
                  else
                     cPrnl += space(aOpsk[i,4]) + space(nCspa)
                  endif
               endif
            next
            @prow()+1,1 say left(cPrnl,nWidt)
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++

            // End of file
            lLoop := .f.
         else
            if nPrev = nLine .AND. PROW()+nLine >= nPrnl
               // Bottom line
               @prow()+1, 1 say repl("-",nWidt)
               @prow()+1, 1 say cAppName()
               fPrnEjec()
               //fPrnOff()
               nBlad++
            endif
         endif

      enddo

      fPrnOff()

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
