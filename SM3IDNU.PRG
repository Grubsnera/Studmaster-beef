// Application: StudMaster for Beef Cattle
//   File Name: SM3IDNU.PRG
// Description: Program to display list of id numbers
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-19-95      02:50:56pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3idnu(nTopp,nLeft,nBott,cHead,cInde,cFind)

   // Declare
   local cRetu := ""
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lClea := .f.
   local aSend := {}
   local aRecv := {}
   local i     := 0
   local nScrl := 0
   local nRigh := 0
   local bBrow := NIL
   local aCols := {}
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 0
   local cCoun := ""
   begin sequence

      // Turn cursor off
      setcursor(0)

      // Test if screen must be cleaned
      if empty(nTopp)
         lClea := .t.
      endif

      // Default values
      nTopp := iif(empty(nTopp),3          ,nTopp)
      nLeft := iif(empty(nLeft),maxcol()-26,nLeft)
      nBott := iif(empty(nBott),maxrow()-4 ,nBott)
      if cLanType() == "A"
         cHead := iif(empty(cHead),"ID NOMMER",cHead)
      else
         cHead := iif(empty(cHead),"ID NUMBER",cHead)
      endif
      cInde := iif(empty(cInde),"SM3DATA"  ,cInde)
      cFind := iif(empty(cFind),space(12)  ,cFind)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aSend)
         aadd(aSend,{"SM3DATA","idnr"     })
         aadd(aSend,{"SM3DATA","geslag"   })
         aadd(aSend,{"SM3DATA","uitkrede" })
      endif
      aRecv := fGetField(aSend)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Datalˆers word geopen")
      else
         fScrBood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(cInde)
      go top

      // Move the record pointer
      if !empty(cFind)
         set soft on
         seek cFind
         set soft off
         if eof()
            go top
         endif
      endif

      // Calculate window width
      for i = 1 to len( aRecv )
         // Length
         nScrl := nScrl + aRecv[i,4] + 3
         // Columns
         // cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         // aadd( aCols, TBColumnNew( cHead, fieldwblock(aRecv[i,2],select(strtran(aRecv[i,1],"->","")))))
         aadd( aCols, TBColumnNew( ,fieldwblock(aRecv[i,2],select(strtran(aRecv[i,1],"->","")))))
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Clear the screen
      if lClea
         fScrOpsk()
      endif

      // Draw the box
      fBox(nTopp,nLeft,nBott,nRigh,cHead)
      setcolor( cColNorm() )

      // Build the browse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      //bBrow:headsep := "Í"
      bBrow:colsep := " ³ "

      // Build the browse columns
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"[Esc]=Vorige skerm  "+D_ENTER+"=Kies  [A-Z]=Vind")
      else
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"[Esc]=Previous screen  "+D_ENTER+"=Choose  [A-Z]=Find")
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
         cCoun := padl("["+ltrim(str(cmxkeyno()))+"/"+ltrim(str(cmxkeycount()))+"]",12,chr(205))
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
            do help with "sm3idnu",1,"oorsig"

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            //if fLocate(upper(chr(nKeyp)))
            //   lMove := .t.
            //   nCurr := recno()
            //   bBrow:refreshall()
            //endif

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
