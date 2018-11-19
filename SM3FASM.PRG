// Application: StudMaster for Beef Cattle
//   File Name: SM3FASM.PRG
// Description: Program to print Phase D masses
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 04-06-95      06:03:55am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3fasm

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cFasg := ""
   local nCoun := 0
   local aHead[20]
   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif

      // Get the phase group
      cFasg := sm3fasg(4)
      if empty(cFasg)
         if cLanType() == "A"
            fScrWait(maxrow(),"Geen fasegroep is gekies nie!")
         else
            fScrWait(maxrow(),"No phase group was selected!")
         endif
         break
      endif

      // Data files being opened
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrOpsk(,"Option "+cOption())
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

      // Fill the masses file with data
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere en massas word uitgesoek")
      else
         fScrWbood(maxrow(),"Animals and masses being selected")
      endif
      select SM3DATA
      ordsetfocus(2)
      seek cFasg
      do while SM3DATA->fasekode == cFasg

         // Screen
         fScrBood(maxrow()-1,SM3DATA->idnr)

         // Add the animal
         select SM3FASM
         dbappend()
         SM3FASM->idnr := SM3DATA->idnr
         aHead[1] := ""

         // Add the starting date and mass
         SM3FASM->mass01 := padl(trim(str(SM3DATA->begmassa)),5)
         aHead[2] := left(dtoc(SM3DATA->begdatum),5)

         // Loop to add all the middle weights
         nCoun := 3
         select SM3WEEG
         seek SM3DATA->idnr
         do while SM3WEEG->idnr == SM3DATA->idnr .and. !eof()
            if SM3WEEG->weegdatum > SM3DATA->begdatum .and. ;
                  SM3WEEG->weegdatum < SM3DATA->eindat
               select SM3FASM
               fieldput(nCoun,padl(trim(str(SM3WEEG->massa)),5))
               aHead[nCoun] := left(dtoc(SM3WEEG->weegdatum),5)
               nCoun++
               select SM3WEEG
               if nCoun == 20
                  go bottom
               endif
            endif
            // Next record
            select SM3WEEG
            skip
         enddo

         // Add the final weight
         select SM3FASM
         fieldput(nCoun,padl(trim(str(SM3DATA->einmas)),5))
         aHead[nCoun] := left(dtoc(SM3DATA->eindat),5)

         // Next record
         select SM3DATA
         skip

      enddo
      ordsetfocus(1)

      // Test if data exist
      select SM3FASM
      if lastrec() <= 0
         if cLanType() == "A"
            fScrWait(maxrow(),"Geen Fase D diere is gevind nie!")
         else
            fScrWait(maxrow(),"No Phase D animals were found!")
         endif
         break
      endif

      // Display the data
      fDisplay(cFasg,aHead)

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDisplay(cFasg,aHead)

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
      aadd(aVeld,{"SM3FASM","idnr"     })
      for i := 2 to len(aHead)
         if !empty(aHead[i])
            aadd(aVeld,{"SM3FASM","mass"+padl(ltrim(str(i-1,2,0)),2,"0")})
         endif
      next
      aOpsk := fGetField(aVeld)

      // Move the record pointer
      select SM3FASM
      go top

      // Calculate averages
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"GEMIDDELDES word bereken")
      else
         fScrWbood(maxrow(),"AVERAGES being calculated")
      endif
      do while !eof()
         for i = 1 to len(aOpsk)
            cData := aOpsk[i,1] + aOpsk[i,2]
            if val(&(cData)) > 0
               aOpsk[i,11]++
               aOpsk[i,12] += val(&(cData))
            endif
         next
         skip
      enddo
      go top

      // Calculate window width
      for i = 1 to len( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,4] + 1
         // Columns
         //cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aHead[i]
         aadd( aCols, TBColumnNew( cHead, fieldwblock(aOpsk[i,2],select(strtran(aOpsk[i,1],"->","")))))
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Draw the box
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, "FASEGROEP "+trim(cFasg)+" MASSAS" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "PHASE GROUP "+trim(cFasg)+" MASSES" )
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
      oBrow:freeze := 1

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
         cCoun := padr(ltrim(str(recno()))+"/"+ltrim(str(lastrec())),10,chr(205))
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
            fPrint(cFasg,aHead,aOpsk)

         elseif nKeyp == K_F1
            // Help
            do help with "sm3fasm",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(oBrow, nKeyp)

         endif

      enddo

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fPrint(cFasg,aHead,aOpsk)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local i     := 0
   local nCspa := 1
   local lLoop := .t.
   local cPrnl := ""
   local nTota := 0
   local cData := ""
   local nCoun := 1
   local nReko := 1
   local nDrag := 0
   local nOpen := 0
   local nChoi := 1
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

      // Determine the print width
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,4] + nCspa
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

      // Select the dfata file
      select SM3FASM
      go top
      nTota := lastrec()

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"MASSAVERSLAG word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Massaverslag vir die "+trim(cFasg)+" Fase D groep."
      else
         fScrbood(maxrow(),"MASS REPORT being printed!  [Esc]=Stop printer.")
         cHdln := "Mass report for the "+trim(cFasg)+" Phase D group."
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
               cPrnl += padr(trim(aHead[i]),aOpsk[i,4]) + space(nCspa)
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
         nCoun++

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
         select SM3FASM
         skip

         // End of page or end of file
         if prow() >= nPrnl .or. eof()

            if eof()
               // Bottom line
               @prow()+1, 1 say repl("-",nWidt)

               for i := 1 to len(aOpsk)
                  if i == 1
                     cPrnl := padr(ltrim(str(nTota))+" Dier(e)",aOpsk[i,4])+space(nCspa)
                  else
                     if aOpsk[i,11] > 0
                        cPrnl += str(aOpsk[i,12]/aOpsk[i,11],aOpsk[i,4],aOpsk[i,5]) + space(nCspa)
                     else
                        cPrnl += space(aOpsk[i,4]) + space(nCspa)
                     endif
                  endif
               next
               @prow()+1,1 say left(cPrnl,nWidt)
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

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
