// Application: StudMaster for Beef Cattle
//   File Name: SM3PALR.PRG
// Description: Function to read palmtop remarks
//   Copyright: (c) 2002 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 03-02-28 10:47

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3palr

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local nBoxc := 0
   local lBrea := .f.
   local cIcar := ""
   local aDbfs := {}
   local cData := ""
   local cResu := ""

   begin sequence

      // Variables

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Funksie "+cOption())
      else
         fScrOpsk( ,"Function "+cOption())
      endif

      // Ask the location of the palmtop file
      cPath := padr(cPalmDir()+"\R"+cIcar+alltrim(substr(cTotNaam(),125,4))+".PTS",50)

      do while .t.

         if cLanType() = "A"
            fScrOpsk( ,"Funksie "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"LEES PALMTOP OPMERKINGS")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik volledige lˆernaam bv. '"+cPath+"lˆernaam.ubr'")
         else
            fScrOpsk( ,"Function "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"IMPORT BIRTHS REMARKS")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow(),"Type full file name e.g. '"+cPath+"filename.ext'")
         endif

         @ 12,nboxc GET cPath
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // Escaped
         if lastkey() == K_ESC
            lBrea := .t.
            exit
         endif

         if !(file(alltrim(cPath)))
            // File does not exist
            if cLanType() = "A"
               fScrBood(maxrow()-1,"Die lˆer "+alltrim(cPath)+" bestaan nie ?")
               fScrWait(maxrow())
            else
               fScrBood(MAXROW()-1,"The file "+alltrim(cPath)+" does not exist ?")
               fScrWait(MAXROW())
            endif
         else
            // File exist
            exit
         endif

      enddo

      if lBrea
         lRetu := .f.
         break
      endif

      cPath := alltrim(cPath)

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3PALR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      zap
      append from &(cPath) delimited

      // Rename and move source palm file
      if right(cPath,4) == ".PTS"

         // Rename existing files

         // Remove the extention
         cPath := left(cPath,len(cPath)-4)

         if file(cPath+".005")
            // Delete the file
            ferase(cPath+".005")
         endif
         if file(cPath+".004")
            // Rename the file
            frename(cPath+".004",cPath+".005")
         endif
         if file(cPath+".003")
            // Rename the file
            frename(cPath+".003",cPath+".004")
         endif
         if file(cPath+".002")
            // Rename the file
            frename(cPath+".002",cPath+".003")
         endif
         if file(cPath+".001")
            // Rename the file
            frename(cPath+".001",cPath+".002")
         endif
         frename(cPath+".PTS",cPath+".001")

      endif

      go top

      // Skakel data om
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Data word omgeskakel")
      else
         fScrWbood(maxrow(),"Data being converted")
      endif
      do while !eof()

         // Id number
         //cData := alltrim(substr(SM3PALR->palmid,5,4))
         //cData += substr(SM3PALR->palmid,9,2)+"-"
         //cData += padl(ltrim(str(val(substr(SM3PALR->palmid,11,4)))),3,"0")
         //SM3PALR->idnr := cData
         SM3PALR->idnr := SM3PALR->palmid

         // Next record
         select SM3PALR
         skip

      enddo
      go top

      // Display the data on the screen
      fDisplay(cPath)

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDisplay(cPath)

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

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aSend)
         aadd(aSend,{"SM3PALR","idnr"     })
         aadd(aSend,{"SM3PALR","remark"   })
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
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Screen
      fScrOpsk()
      if cLanType() == "A"
         cOpsk := iif(empty(cOpsk),"OPMERKINGS VANAF PALMTOP",cOpsk)
      else
         cOpsk := iif(empty(cOpsk),"REMARKS FROM PALMTOP",cOpsk)
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
         fScrBood(maxrow()-1,"[Esc ]=Menu             ")
         fScrBood(maxrow()  ,"[AltT]=Bewaar opmerkings")
      else
         fScrBood(maxrow()-1,"[Esc ]=Menu            ")
         fScrBood(maxrow()  ,"[AltT]=Transfer remarks")
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

         if nKeyp == K_ALT_T
            // Transfer data to main file
            fTransfer(cPath)
            //lRetu := .t.
            //nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "sm3palr",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fTransfer(cPath)

   // Declare variables
   local lRetu := .t.
   local aCscr := fASaveScr()
   local cData := ""
   local cFild := ""
   local nChoi := 1
   local cFiel := ""

   begin sequence

      // Menu where to save the masses
      nChoi := fNewMenu(nChoi,"SM3PALR")
      do case

         case nChoi == 1
            // Temporary remark
            cFiel := "toggle1"

         case nChoi == 2
            // Own use 1
            cFiel := "divers"

         case nChoi == 3
            // Own use 2
            cFiel := "divert"

         case nChoi == 4
            // Remark special
            cFiel := "remark"

         otherwise
            // Return
            lRetu := .f.
            break

      endcase

      // Screen message
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow()-1,"Opmerkings word oorgedra")
      else
         fScrWbood(maxrow()-1,"Remarks being transferred")
      endif

      // Palmtop file delete instruction file
      //cFild := alltrim(cPath)
      //cFild := left(cFild,len(cFild)-3)
      //cFild += "DEL"

      // Loop each animal to do the transfer
      select SM3PALR
      go top
      do while !eof()

         // Look if animal does exist
         select SM3DATA
         go top
         seek SM3PALR->idnr
         if !(found())
            SM3DATA->idnr := cData
            select SM3PALR
            skip
            loop
         endif

         do while !rlock()
         enddo
         SM3DATA->&cFiel. := SM3PALR->remark

         // Create the palmtop weight delete instruction
         // Open the text file
         //set alternate to (cFild) additive
         //set alternate on
         //set console off
         // Write the data
         //?? SM3PALR->palmid
         //?
         // Close the file
         //set console on
         //set alternate off
         //set alternate to

         // Next record
         select SM3PALR
         skip

      enddo
      go top

   end

   fARestScr(aCscr)

return lRetu
