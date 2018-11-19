// Application: StudMaster for Beef Cattle
//   File Name: SM3BESI.PRG
// Description: Program to diplay the diseases for each treatment
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-13-95 09:45am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION SM3BESI(nTopp,nLeft,cBeha,cBesk)

   // Declare
   local cRetu := ""
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
   local nBott := maxrow()-4
   local aVeld := {}
   local cData := ""
   local aView := {}

   begin sequence

      // Test if screen must be cleaned
      if empty(nTopp)
         lClea := .t.
      endif

      // Parameters
      nTopp := if(nTopp==NIL,         3,nTopp)
      nLeft := if(nLeft==NIL,         2,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      aadd(aVeld,{"SM3SIBE","siek"})
      aadd(aVeld,{"SM3SIEK","besk"})
      aOpsk := fGetField(aVeld)

      // Screen - data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIBE")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus("SM3BEHA")
      cmfilter("SM3SIBE->beha=='"+cBeha+"'")
      dbsetrelation("SM3SIEK",{|| SM3SIBE->siek },"SM3SIBE->siek")
      go top

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
         fBox(nTopp, nLeft, nBott, nRigh, "BEHANDELING VIR")
      else
         fBox( nTopp, nLeft, nBott, nRigh, "TREATMENT FOR")
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
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins]=Voeg 'n siekte by        ")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [Del]=Skrap die verligte siekte")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins]=Add a disease                 ")
         fScrBood(maxrow()  , "[F1 ]=Help  [Del]=Delete the highlighted disease")
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
         cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            cRetu := fieldget(1)
            nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "SM3BESI",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            aView := {}
            aadd(aView,{"SM3SIEK","kode"})
            aadd(aView,{"SM3SIEK","besk"})
            nCurr := recno()
            cData := sm3siek(5,42,,aView)
            if !empty(cData)
               select SM3SIBE
               dbappend()
               SM3SIBE->siek := cData
               SM3SIBE->beha := cBeha
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
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

return cRetu

/******************************************************************************/
STATIC FUNCTION fDelete

   // Function to delete records

   // Declare
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local lRetu := .f.
   local cBood := ""

   // Screen
   if cLanType() == "A"
      cBood := "Moet bogenoemde SIEKTE geskrap word?"
   else
      cBood := "Should above-mentioned DISEASE be deleted?"
   endif
   fScrBood(maxrow()-1,trim(SM3SIEK->(fieldget(1)))+" - "+trim(SM3SIEK->(fieldget(2))))
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
