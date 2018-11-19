// Application: StudMaster for Beef Cattle
//   File Name: SM3VOOR
// Description: Program to calculate animal presence
//   Copyright: (c) 1998 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 12-17-98 09:11am
// Modified on:

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3voor

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aStam := {}
   local nMenu := 1
   local cData := ""
   local i     := 1
   local nCoun := 0
   local nTota := 0
   local nHigh := 0
   local nAver := 0

   if cLanType() == "A"
      fScrOpsk(1, "Opsie "+cOption())
   else
      fScrOpsk(1, "Option "+cOption())
   endif

   begin sequence

      // Calculate which animals
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Menu" )
      endif
      nMenu := fNewMenu(nMenu,"SM3VOOR")

      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption(nMenu))
      else
         fScrOpsk( ,"Option "+cOption(nMenu))
      endif

      do case
         case nMenu == 1
            // All animals
            if !sm3pick("ALL",,"SM3DATA")
               break
            endif

         case nMenu == 2
            // Index group
            cData := sm3indg(4)
            if empty(cData)
               break
            endif
            if !sm3pick("IND",cData)
               break
            endif

         case nMenu == 3
            // Phase group
            cData := sm3fasg(4)
            if empty(cData)
               break
            endif
            if !sm3pick("PHA",cData)
               break
            endif

         case nMenu == 4
            // Group
            cData := sm3groe()
            if empty(cData)
               break
            endif
            if !sm3pick("GRP",cData)
               break
            endif

         case nMenu == 5
            // Selection group
            cData := sm3selg()
            if empty(cData)
               break
            endif
            if !sm3pick("SEL",cData)
               break
            endif

         case nMenu == 6
            // Previous group
            if !sm3pick()
               break
            endif

         otherwise
            // Exit
            break
      endcase

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3PICK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VOOR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Delete all records in influence file
      zap

      // Restore the menu screen
      fARestScr(aCscr)

      // Loop all the animals in the selected file
      select SM3PICK
      do while !eof()

         // Display the percentage completed
         fScrBood(maxrow()-1,SM3PICK->idnr)
         if cLanType() == "A"
            fScrBood(maxrow(),fPercent(recno(),lastrec())+"% Voltooi")
         else
            fScrBood(maxrow(),fPercent(recno(),lastrec())+"% Completed")
         endif

         // Build an array with pedigree data
         aStam := fStamboom(SM3PICK->idnr)

         // Count animals
         for i := 2 to len(aStam)
            if !empty(aStam[i,1])
               select SM3VOOR
               seek aStam[i,1]
               if eof()
                  dbappend()
                  SM3VOOR->idnr := aStam[i,1]
               endif
               if i >= 2 .and. i <= 3
                  SM3VOOR->aantal += 1
                  SM3VOOR->aantab += 1
               elseif i >= 4 .and. i <= 7
                  SM3VOOR->aantal += 1
                  SM3VOOR->aantac += 1
               elseif i >=8 .and. i <= 15
                  SM3VOOR->aantal += 1
                  SM3VOOR->aantad += 1
               endif
            endif
         next

         // Next record
         select SM3PICK
         skip

      enddo

      // Calculate the actual totals
      select SM3VOOR
      go top
      nCoun := 1

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Totale word bereken")
      else
         fScrBood(maxrow()-1,"Totals being calculated")
      endif
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Voltooi")
         else
            fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Completed")
         endif

         // No divide
         SM3VOOR->invloe := (SM3VOOR->aantab*16.6)+;
            (SM3VOOR->aantac*8.3)+;
            (SM3VOOR->aantad*4.2)

         // Total
         nTota += SM3VOOR->invloe

         // Next record
         select SM3VOOR
         skip
         nCoun++

      enddo

      // Calculate the actual percentages
      select SM3VOOR
      go top
      nCoun := 1

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow()-1,"Persentasies word bereken")
      else
         fScrWbood(maxrow()-1,"Percentages being calculated")
      endif

      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Voltooi")
         else
            fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Completed")
         endif

         // Divide by highest * 100
         if nTota > 0
            if SM3VOOR->invloe / nTota <= 999.999
               SM3VOOR->persen := SM3VOOR->invloe / nTota
            endif
         endif

         // Next record
         select SM3VOOR
         skip
         nCoun++

      enddo

      // Move to the top of the file
      select SM3VOOR
      dbsetorder("SM3VOOS")
      set relation to idnr into sm3data
      go top

      // Display the results

      fDisplay(nTota)

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)
   cOption(-1)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDisplay(nTota)

   // Declare variables
   local lRetu := .t.
   local aSend := {}
   local aRecv := {}
   local i     := 0
   local nScrl := 0
   local aCols := {}
   local nTopp := 3
   local nLeft := 2
   local nBott := maxrow()-4
   local nRigh := maxcol()-3
   local bBrow := NIL
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 0
   local cCoun := ""
   local cHead := ""
   local cOpsk := ""
   local lAver := .f.
   local oCols := NIL
   local lFilt := .f.
   local lSort := .f.

   begin sequence

      // Turn cursor off
      setcursor(0)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aSend)
         aadd(aSend,{"SM3VOOR","idnr"     })
         aadd(aSend,{"SM3DATA","geslag"   })
         aadd(aSend,{"SM3VOOR","invloe"   })
         aadd(aSend,{"SM3VOOR","persen"   })
         aadd(aSend,{"SM3VOOR","aantab"   })
         aadd(aSend,{"SM3VOOR","aantac"   })
         aadd(aSend,{"SM3VOOR","aantad"   })
      endif
      aRecv := fGetField(aSend)

      // Calculate window width
      for i = 1 to len(aRecv)
         // Length
         nScrl := nScrl+aRecv[i,FLD_LENG]+3
         // Columns
         cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         aadd(aCols,TBColumnNew(cHead,fieldwblock(aRecv[i,FLD_NAME],select(strtran(aRecv[i,DBF_NAME],"->","")))))
      next

      // Calculate right hand column
      //nLeft := if(nRigh-nScrl<3,3,nRigh-nScrl)
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Screen
      fScrOpsk()
      if cLanType() == "A"
         cOpsk := iif(empty(cOpsk),"DIERINVLOED PERSENTASIES",cOpsk)
      else
         cOpsk := iif(empty(cOpsk),"ANIMAL INFLUENCE PERCENTAGES",cOpsk)
      endif

      // Draw the box
      fBox(nTopp,nLeft,nBott,nRigh,cOpsk)
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
         fScrBood(maxrow()-1,"[Esc]=Menu  [AltT]=Totale  [AltS]=SorteerId  [AltF]=Filter  [AltP]=Druk")
         fScrBood(maxrow()  ,+D_ENTER+"=Bewaar dierinvloed persentasies in die hooflˆer")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu  [AltT]=Totals  [AltS]=SortId  [AltF]=Filter  [AltP]=Print")
         fScrBood(maxrow()  ,+D_ENTER+"=Update animal influence percentages in the main file")
      endif

      // Freeze
      // bBrow:freeze := 1

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
         cCoun := padl("["+ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount()))+"]",12,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means update main file
            fUpdate()
            lRetu := .t.
            nKeyp := K_ESC

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint(aRecv,lAver)
               bBrow:refreshall()
            endif

         elseif nKeyp == K_ALT_S
            // Alt S means sort
            if lSort
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"[Esc]=Menu  [AltT]=Totale  [AltS]=SorteerId  [AltF]=Filter  [AltP]=Druk")
               else
                  fScrBood(maxrow()-1,"[Esc]=Menu  [AltT]=Totals  [AltS]=SortId  [AltF]=Filter  [AltP]=Print")
               endif
               lSort := .f.
               dbsetorder("SM3VOOS")
               go top
            else
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"[Esc]=Menu  [AltT]=Totale  [AltS]=SorteerInvloed  [AltF]=Filter  [AltP]=Druk")
               else
                  fScrBood(maxrow()-1,"[Esc]=Menu  [AltT]=Totals  [AltS]=SortInfluence  [AltF]=Filter  [AltP]=Print")
               endif
               lSort := .t.
               dbsetorder("SM3VOOR")
               go top
            endif
            bBrow:refreshall()

         elseif nKeyp == K_ALT_T
            // Alt T means toggle totals and averages
            if lAver
               lAver := .f.
               // Remove all the column footings
               for i := 1 to len(aRecv)
                  oCols := bBrow:getcolumn(i)
                  oCols:footsep := ""
                  oCols:footing := ""
               next
            else
               lAver := .t.
               // Do the actual calculation
               fAverage(aRecv,bBrow)
            endif
            bBrow:configure()

         elseif nKeyp == K_ALT_F
            // Alt F means set a filter
            if lFilt
               lFilt := .f.
               cmclrfilter()
               if lAver
                  fAverage(aRecv,bBrow)
                  bBrow:configure()
               endif
               bBrow:refreshall()
            else
               if fFilter()
                  lFilt := .t.
                  if lAver
                     fAverage(aRecv,bBrow)
                     bBrow:configure()
                  endif
                  bBrow:refreshall()
               endif
            endif

         elseif nKeyp == K_F1
            // Help
            do help with "sm3voor",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fUpdate()

   // Function to update the main file with animal influence percentages

   // Declare
   local nCoun := 1

   // Break the relation
   select SM3VOOR
   set relation to

   // First delete the current percentages
   select SM3DATA
   go top
   if cLanType() == "A"
      fScrBood(maxrow()-1,"Bestaande dierinvloed persentasies word geskrap!")
   else
      fScrBood(maxrow()-1,"Existing animal influence percentages being deleted!")
   endif
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Voltooi")
      else
         fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Completed")
      endif

      // The action
      do while !rlock()
      enddo
      SM3DATA->invloe := 0

      // Next record
      select SM3DATA
      skip
      nCoun++

   enddo
   select SM3VOOR
   go top
   nCoun := 1

   // Update the percentages
   if cLanType() == "A"
      fScrBood(maxrow()-1,"Dierinvloed persentasies word bewaar!")
   else
      fScrBood(maxrow()-1,"Animal influence percentages being updated!")
   endif
   do while !eof()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Voltooi")
      else
         fScrBood(maxrow(),fPercent(nCoun,lastrec())+"% Completed")
      endif

      // Seek the record in the main file
      select SM3DATA
      seek SM3VOOR->idnr
      if found()
         do while !rlock()
         enddo
         SM3DATA->invloe := SM3VOOR->persen
      endif

      // Next record
      select SM3VOOR
      skip
      nCoun++

   enddo

return NIL

/******************************************************************************/
STATIC FUNCTION fAverage(aRecv,bBrow)

   // Function to calculate averages

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local nReko := recno()
   local i     := 0
   local oCols := NIL
   local cEbvf := ""
   local cEbvp := ""
   local cEbvc := ""

   // Build the ebv fields variable
   cEbvf := "BIRDIR"
   cEbvf += ",BIRMAT"
   cEbvf += ",WEADIR"
   cEbvf += ",WEAMAT"
   cEbvf += ",WEACOM"
   cEbvf += ",YEADIR"
   cEbvf += ",M18DIR"
   cEbvf += ",OEKDIR"
   cEbvf += ",TKPDIR"
   //cEbvf += ",EOCDIR"
   //cEbvf += ",EOCMAT"
   cEbvf += ",ADGDIR"
   cEbvf += ",PCFCRD"
   cEbvf += ",KLEDIR"
   cEbvf += ",SCRDIR"
   cEbvf += ",HGTDIR"
   cEbvf += ",LGTDIR"
   cEbvf += ",FINDIR"
   cEbvf += ",MCWDIR"
   cEbvf += ",CARDIR"
   cEbvf += ",RIBDIR"

   begin sequence

      // Loop through all the columns to clear totals etc.
      for i := 1 to len(aRecv)
         aRecv[i,FLD_COUN] := 0
         aRecv[i,FLD_TOTA] := 0
      next

      // Set the data file
      go top

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Totale en gemiddeldes word bereken")
      else
         fScrWbood(maxrow(),"Totals and averages being calculated")
      endif

      // Loop through the file
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrbood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
         else
            fScrbood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
         endif

         // Loop through all the columns
         for i := 1 to len(aRecv)
            if aRecv[i,FLD_TYPE] == "N"
               select select(strtran(aRecv[i,1],"->",""))
               //if fieldget(aRecv[i,FLD_NUMB]) > 0
               //   aRecv[i,FLD_COUN]++
               //   aRecv[i,FLD_TOTA] += fieldget(aRecv[i,FLD_NUMB])
               //endif
               if strtran(aRecv[i,DBF_NAME],"->","") == "SM3DATA" .and. aRecv[i,FLD_NAME] $ cEbvf
                  if !empty(SM3DATA->analdate)
                     aRecv[i,FLD_COUN]++
                     aRecv[i,FLD_TOTA]+= fieldget(aRecv[i,FLD_NUMB])
                  endif
               elseif fieldget(aRecv[i,FLD_NUMB]) <> 0
                  aRecv[i,FLD_COUN]++
                  aRecv[i,FLD_TOTA]+= fieldget(aRecv[i,FLD_NUMB])
               else
               endif
            endif
         next

         // Next record
         select SM3VOOR
         skip

      enddo

      goto nReko

      // Add all the column footings
      for i := 1 to len(aRecv)
         oCols := bBrow:getcolumn(i)
         oCols:footsep := "Í"
         if i == 1
            // First column to show headings
            if cLanType() == "A"
               oCols:footing := padl("Gemiddeld:",aRecv[i,FLD_LENG])+";"+;
                  padl("Totaal:",aRecv[i,FLD_LENG])
            else
               oCols:footing := padl("Average:",aRecv[i,FLD_LENG])+";"+;
                  padl("Total:",aRecv[i,FLD_LENG])
            endif
         elseif aRecv[i,FLD_TYPE] == "N"
            // Calc the average for all numeric cols
            oCols:footing := transform(zer(aRecv[i,FLD_TOTA],aRecv[i,FLD_COUN]),aRecv[i,FLD_PICT])+";"+;
               transform(aRecv[i,FLD_TOTA],aRecv[i,FLD_PICT])
         else
            // Fill footings with spaces for all other cols
            oCols:footing := space(aRecv[i,FLD_LENG])+";"+;
               space(aRecv[i,FLD_LENG])
         endif
      next

   end

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fFilter

   // Function to display only selected records

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local cTest := ""

   begin sequence

      cTest += sm3selg()

      // If no search
      if empty(cTest)
         break
      endif

      // Remove the last and from the search string
      if right(cTest,5) == ".and."
         cTest := left(cTest,len(cTest)-5)
      endif

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere word uitgesoek")
      else
         fScrWbood(maxrow(),"Animals being selected")
      endif

      // Set the filter
      lRetu := .t.
      cmfilter(cTest)
      go top

   end

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aRecv,lAver)

   // Function to print

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nReko := recno()
   local aSend := {}
   local i     := 0
   local cPrnl := ""
   local cData := ""
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

      // Screen - fields to print
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Drukuitleg word bepaal")
      else
         fScrBood(maxrow(),"Print outlay being determined")
      endif
      if empty(aRecv)
         aadd(aSend,{"SM3VOOR","idnr"     })
         aadd(aSend,{"SM3DATA","geslag"   })
         aadd(aSend,{"SM3VOOR","invloe"   })
         aadd(aSend,{"SM3VOOR","persen"   })
         aadd(aSend,{"SM3VOOR","aantab"   })
         aadd(aSend,{"SM3VOOR","aantac"   })
         aadd(aSend,{"SM3VOOR","aantad"   })
         aRecv := fGetField(aSend)
      endif

      // Determine the print width
      for i := 1 to len(aRecv)
         nWidt += aRecv[i,FLD_LENG] + nCspa
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

      if lAver
         nPrnl -= 3
      endif

      // Select the dfata file
      go top

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"DIERINVLOEDPERSENTASIES word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Dierinvloed Persentasies."
      else
         fScrbood(maxrow(),"ANIMAL INFLUENCE PERCENTAGES being printed!  [Esc]=Stop printer.")
         cHdln := "Animal Influence Percentages."
      endif

      // Switch printer on
      fPrnOn()

      // The loop
      do while !eof()


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
            for i = 1 to len(aRecv)
               cPrnl += padr(trim(aRecv[i,7]),aRecv[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 2nd heading line
            cPrnl := ""
            for i = 1 to len(aRecv)
               cPrnl += padr(trim(aRecv[i,8]),aRecv[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 3rd heading line
            cPrnl := ""
            for i = 1 to len(aRecv)
               cPrnl += padr(trim(aRecv[i,9]),aRecv[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 4th heading line
            cPrnl := ""
            for i = 1 to len(aRecv)
               cPrnl += repl("-",aRecv[i,4]) + space(nCspa)
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
         for i = 1 to len(aRecv)
            cData := aRecv[i,1] + aRecv[i,2]
            if aRecv[i,3] == "D"
               cPrnl += dtoc(&(cData)) + space(nCspa)
            elseif aRecv[i,3] == "N"
               cPrnl += str(&(cData),aRecv[i,4],aRecv[i,5]) + space(nCspa)
            else
               cPrnl += &(cData) + space(nCspa)
            endif
         next
         @prow()+1,1 say left(cPrnl,nWidt)

         // Next record
         select SM3VOOR
         skip

         // End of page or end of file
         if prow() >= nPrnl .or. eof()

            // Averages and totals
            if lAver .and. eof()
               // Bottom line
               cPrnl := ""
               for i = 1 to len(aRecv)
                  cPrnl += repl("-",aRecv[i,4]) + space(nCspa)
               next
               @prow()+1,1 say left(cPrnl,nWidt)

               // Averages
               cPrnl := ""
               for i := 1 to len(aRecv)
                  if aRecv[i,FLD_TYPE] == "N"
                     if aRecv[i,FLD_COUN] > 0
                        cPrnl += transform((aRecv[i,FLD_TOTA]/aRecv[i,FLD_COUN]),aRecv[i,FLD_PICT])
                     else
                        cPrnl += space(aRecv[i,FLD_LENG])
                     endif
                  else
                     cPrnl += space(aRecv[i,FLD_LENG])
                  endif
                  cPrnl += space(nCspa)
               next
               if cLanType() == "A"
                  cPrnl := strtran(cPrnl,space(len("Gemiddeldes:")),"Gemiddeldes:",1,1)
               else
                  cPrnl := strtran(cPrnl,space(len("Averages:")),"Averages:",1,1)
               endif
               @prow()+1,1 say left(cPrnl,nWidt)

               // Totals
               cPrnl := ""
               for i := 1 to len(aRecv)
                  if aRecv[i,FLD_TYPE] == "N"
                     if aRecv[i,FLD_TOTA] > 0
                        cPrnl += transform(aRecv[i,FLD_TOTA],aRecv[i,FLD_PICT])
                     else
                        cPrnl += space(aRecv[i,FLD_LENG])
                     endif
                  else
                     cPrnl += space(aRecv[i,FLD_LENG])
                  endif
                  cPrnl += space(nCspa)
               next
               if cLanType() == "A"
                  cPrnl := strtran(cPrnl,space(len("Totale:")),"Totale:",1,1)
               else
                  cPrnl := strtran(cPrnl,space(len("Totals:")),"Totals:",1,1)
               endif
               @prow()+1,1 say left(cPrnl,nWidt)

            endif

            // Bottom line
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++
         endif

      enddo

      fPrnOff()

      goto nReko

   end

   // Reset
   fARestScr(aCscr)

return lRetu
