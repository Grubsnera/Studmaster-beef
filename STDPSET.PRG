// Application: StudMaster for Beef Cattle
//   File Name: STDPSET.PRG
// Description: Program to display different printers
//   Copyright: (c) 1997 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-23-97      04:34:25pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdpset(nTopp,nLeft,nBott,aVeld,nFind)

   // Declare
   local lRetu := ""
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lClea := .f.
   local aOpsk := {}
   local i     := 1
   local nScrl := 1
   local cHead := ""
   local aCols := {}
   local nRigh := 0
   local bBrow := NIL
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 1
   local cCoun := ""

   begin sequence

      // Paint the heading
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif

      // Test if screen must be cleaned
      if empty(nTopp)
         lClea := .t.
      endif

      // Parameters
      nTopp := if(nTopp==NIL,         3,nTopp)
      nLeft := if(nLeft==NIL,         2,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)
      aVeld := if(aVeld==NIL,        {},aVeld)
      nFind := if(nFind==NIL,         1,nFind)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         if cLanType() == "A"
            aadd(aVeld,{"STDDRUK","prnaam"})
         else
            aadd(aVeld,{"STDDRUK","prname"})
         endif
      endif
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"STDDRUK",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Move the record pointer
      if nFind > 0
         goto nFind
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
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
         else
            fScrOpsk(,"Option "+cOption())
         endif
      else
         if cLanType() == "A"
            fScrOpsk(1,"Opsie "+cOption())
         else
            fScrOpsk(1,"Option "+cOption())
         endif
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "DRUKKERS" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "PRINTERS" )
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
         fScrBood(maxrow()-1, "[Esc  ]=Menu [Ins ]=Nuwe drukker     [Del ]=Skrap                 ")
         fScrBood(maxrow()  , "[Enter]=Kies [AltE]=Verander drukker [AltP]=Toetsdruk [AltR]=Reset")
      else
         fScrBood(maxrow()-1, "[ Esc ]=Menu   [Ins ]=New printer  [Del]=Delete                 ")
         fScrBood(maxrow()  , "[Enter]=Choose [AltE]=Edit printer [AltP]=TestPrint [AltR]=Reset")
      endif

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

            // Update the statics
            nPrnCode(recno())
            nPrnLptp(STDDRUK->prlptp)
            cPrnInit(alltrim(STDDRUK->prinit))
            cPrnNorm(alltrim(STDDRUK->prncc))
            nPrnLine(STDDRUK->prnlin)
            nPrnLeng(STDDRUK->prnpal)
            nPrnPrnl(STDDRUK->prnprl)
            nPrnWidt(STDDRUK->prnwid)
            cPrnCond(alltrim(STDDRUK->prccc))
            nPrnCwid(STDDRUK->prcwid)
            nPrcLeng(STDDRUK->prcpal)
            nPrcPrnl(STDDRUK->prcprl)
            cPrn8lpi(alltrim(STDDRUK->pr8lpi))
            cPrn6lpi(alltrim(STDDRUK->pr6lpi))
            cPrnStar(alltrim(STDDRUK->prstar))
            nPrnWait(STDDRUK->prwait)

            // Update the init file
            dbselectarea("STDWAAR")
            do while !rlock()
            enddo
            STDWAAR->prcode := STDDRUK->(recno())
            STDWAAR->prlptp := STDDRUK->prlptp
            STDWAAR->prinit := STDDRUK->prinit
            STDWAAR->prnorm := STDDRUK->prncc
            STDWAAR->prline := STDDRUK->prnlin
            STDWAAR->prleng := STDDRUK->prnpal
            STDWAAR->prprnl := STDDRUK->prnprl
            STDWAAR->prwidt := STDDRUK->prnwid
            STDWAAR->prcond := STDDRUK->prccc
            STDWAAR->prcwid := STDDRUK->prcwid
            STDWAAR->prcpal := STDDRUK->prcpal
            STDWAAR->prcprl := STDDRUK->prcprl
            STDWAAR->pr8lpi := STDDRUK->pr8lpi
            STDWAAR->pr6lpi := STDDRUK->pr6lpi
            STDWAAR->prstar := STDDRUK->prstar
            STDWAAR->prwait := STDDRUK->prwait

            // Escape
            lRetu := .t.
            nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "STDPSET",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_ALT_R
            // Alt Reset means read values from .tdb file
            if fReset()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddDruk()
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fAddDruk(recno())
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_P
            // Alt P means print
            fPrint()

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
      cBood := "Moet bogenoemde DRUKKER geskrap word?"
   else
      cBood := "Should above-mentioned PRINTER be deleted?"
   endif
   fScrBood(maxrow()-1,trim(fieldget(15))+" - "+trim(fieldget(14)))
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
STATIC FUNCTION fReset

   // Function to read values from the .tdb file

   // Declare
   local aCdbf := fATopen()
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local lRetu := .f.
   local cBood := ""
   local i     := 1

   begin sequence

      // Open the .tdb file
      aCdbf := fATopen(aCdbf,,"STDDRUK",,"tdb","TDBDRUK")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1)
         fScrWbood(maxrow(),"Drukkerkodes word herstel")
      else
         fScrBood(maxrow()-1)
         fScrWbood(maxrow(),"Printer codes being reset")
      endif

      // Delete all the current entries
      select STDDRUK
      go top
      do while !(eof())
         if rlock()
            delete
            dbUnlock()
            lRetu := .t.
         endif
         skip
      enddo
      pack

      // Add new entries from the temp file
      select TDBDRUK
      go top
      do while !(eof())

         // Add a new record
         select STDDRUK
         dbappend()
         for i := 1 to fcount()
            fieldput(i,TDBDRUK->(fieldget(i)))
         next

         // Next record
         select TDBDRUK
         skip

      enddo

      // Reset
      fARestScr(aCscr)
      fATclose(aCdbf)

      // Go first
      select STDDRUK
      dbgotop()

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fAddDruk(nReko)

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

   begin sequence

      // Values
      nReko := iif(empty(nReko),0,nReko)

      // Get the fields
      asize(aSend,0)
      aadd(aSend,{"STDDRUK","prnaam"})
      aadd(aSend,{"STDDRUK","prname"})
      aadd(aSend,{"STDDRUK","prinit"})
      aadd(aSend,{"STDDRUK","prlptp"})
      aadd(aSend,{"STDDRUK","prnlin"})
      aadd(aSend,{"STDDRUK","prnpal"})
      aadd(aSend,{"STDDRUK","prnprl"})
      aadd(aSend,{"STDDRUK","prnwid"})
      aadd(aSend,{"STDDRUK","prcwid"})
      aadd(aSend,{"STDDRUK","prncc"})
      aadd(aSend,{"STDDRUK","prccc"})
      aadd(aSend,{"STDDRUK","prcpal"})
      aadd(aSend,{"STDDRUK","prcprl"})
      aadd(aSend,{"STDDRUK","pr8lpi"})
      aadd(aSend,{"STDDRUK","pr6lpi"})
      aadd(aSend,{"STDDRUK","prstar"})
      aadd(aSend,{"STDDRUK","prwait"})
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE DRUKKER")
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW PRINTER")
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER DRUKKERINLIGTING")
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT PRINTER INFORMATION")
         endif
      endif

      // The get
      lLoop := .t.
      do while lLoop

         if lClea

            // Get the current values
            if nReko == 0

               // Insert a new record
               if lRepe
                  lRepe := .f.
                  aRecv := fFillBlank(aRecv)
               else
                  aRecv := fFillBlank(aRecv)
               endif

            else

               // Edit a record by filling the array with current values
               for i := 1 to len(aRecv)
                  select select(strtran(aRecv[i,1],"->",""))
                  aRecv[i,14] := fieldget(aRecv[i,13])
               next

            endif

         else

            // Clear the get array
            lClea := .t.

         endif

         // Vertoon en get velde
         @nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
            pict aRecv[ 1,FLD_PICT]
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT]
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT];
            valid(fVinit(getlist,aRecv))
         @nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
            pict aRecv[ 4,FLD_PICT];
            valid(fVlptp(getlist,aRecv))
         @nLine+ 5,nBoxc say aRecv[ 5,FLD_DESC] get aRecv[ 5,FLD_CARG] ;
            pict aRecv[ 5,FLD_PICT];
            valid(fVnlin(getlist,aRecv))
         @nLine+ 6,nBoxc say aRecv[ 6,FLD_DESC] get aRecv[ 6,FLD_CARG] ;
            pict aRecv[ 6,FLD_PICT];
            valid(fVnpal(getlist,aRecv))
         @nLine+ 7,nBoxc say aRecv[ 7,FLD_DESC] get aRecv[ 7,FLD_CARG] ;
            pict aRecv[ 7,FLD_PICT];
            valid(fVnprl(getlist,aRecv))
         @nLine+ 8,nBoxc say aRecv[ 8,FLD_DESC] get aRecv[ 8,FLD_CARG] ;
            pict aRecv[ 8,FLD_PICT];
            valid(fVnwid(getlist,aRecv))
         @nLine+ 9,nBoxc say aRecv[ 9,FLD_DESC] get aRecv[ 9,FLD_CARG] ;
            pict aRecv[ 9,FLD_PICT];
            valid(fVcwid(getlist,aRecv))
         @nLine+10,nBoxc say aRecv[10,FLD_DESC] get aRecv[10,FLD_CARG] ;
            pict aRecv[10,FLD_PICT];
            valid(fVncc(getlist,aRecv))
         @nLine+11,nBoxc say aRecv[11,FLD_DESC] get aRecv[11,FLD_CARG] ;
            pict aRecv[11,FLD_PICT];
            valid(fVccc(getlist,aRecv))
         @nLine+12,nBoxc say aRecv[12,FLD_DESC] get aRecv[12,FLD_CARG] ;
            pict aRecv[12,FLD_PICT];
            valid(fVcpal(getlist,aRecv))
         @nLine+13,nBoxc say aRecv[13,FLD_DESC] get aRecv[13,FLD_CARG] ;
            pict aRecv[13,FLD_PICT];
            valid(fVcprl(getlist,aRecv))
         @nLine+14,nBoxc say aRecv[14,FLD_DESC] get aRecv[14,FLD_CARG] ;
            pict aRecv[14,FLD_PICT];
            valid(fV8lpi(getlist,aRecv))
         @nLine+15,nBoxc say aRecv[15,FLD_DESC] get aRecv[15,FLD_CARG] ;
            pict aRecv[15,FLD_PICT];
            valid(fV6lpi(getlist,aRecv))
         @nLine+16,nBoxc say aRecv[16,FLD_DESC] get aRecv[16,FLD_CARG] ;
            pict aRecv[16,FLD_PICT]
         @nLine+17,nBoxc say aRecv[17,FLD_DESC] get aRecv[17,FLD_CARG] ;
            pict aRecv[17,FLD_PICT]

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
               if "STDDRUK" $ aRecv[i,DBF_NAME]
                  fieldput(aRecv[i,13],aRecv[i,14])
               endif
            next

            dbunlock()
            dbcommit()

            // Select the active file
            select STDDRUK

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
STATIC FUNCTION fVinit(aGets,aRecv)
   // Validate the contents of the initialization code
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prinit")
   begin sequence
      if empty(aRecv[nFiel,FLD_CARG])
         //aRecv[nFiel,FLD_CARG] := padr("chr(27)+[@]",aRecv[nFiel,FLD_LENG])
         //aGets[nFiel]:display()
      elseif "DOT" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(12)",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "LASER" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&l0H]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "INKJET" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&l0H]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVlptp(aGets,aRecv)
   // Validate the contents of the printer port
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prlptp")
   begin sequence
      if empty(aRecv[nFiel,FLD_CARG])
         aRecv[nFiel,FLD_CARG] := 1
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVnlin(aGets,aRecv)
   // Validate the contents of the starting printer line
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prnlin")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 0 .or. aRecv[nFiel,FLD_CARG] > 20
         aRecv[nFiel,FLD_CARG] := 1
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVnpal(aGets,aRecv)
   // Validate the contents of the page length
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prnpal")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 1 .or. aRecv[nFiel,FLD_CARG] > 100
         aRecv[nFiel,FLD_CARG] := 66
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVnprl(aGets,aRecv)
   // Validate the contents of the page length
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prnprl")
   local nPage := fEnum(aRecv,"prnpal")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 1 .or. aRecv[nFiel,FLD_CARG] > 100
         aRecv[nFiel,FLD_CARG] := aRecv[nPage,FLD_CARG] - 8
         aGets[nFiel]:display()
      endif
      if aRecv[nFiel,FLD_CARG] > aRecv[nPage,FLD_CARG]
         aRecv[nFiel,FLD_CARG] := aRecv[nPage,FLD_CARG] - 8
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVnwid(aGets,aRecv)
   // Validate the contents of the page length
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prnwid")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 1 .or. aRecv[nFiel,FLD_CARG] > 129
         aRecv[nFiel,FLD_CARG] := 79
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVcwid(aGets,aRecv)
   // Validate the contents of the page length
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prcwid")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 1 .or. aRecv[nFiel,FLD_CARG] > 189
         aRecv[nFiel,FLD_CARG] := 129
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVncc(aGets,aRecv)
   // Validate the contents of the normal code
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prncc")
   begin sequence
      if empty(aRecv[nFiel,FLD_CARG])
         aRecv[nFiel,FLD_CARG] := padr("chr(18)",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "DOT" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(18)",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "LASER" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&k0S]+chr(27)+[&k11.30H]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "INKJET" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&k0S]+chr(27)+[&k11.30H]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVccc(aGets,aRecv)
   // Validate the contents of the condensed code
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prccc")
   begin sequence
      if empty(aRecv[nFiel,FLD_CARG])
         aRecv[nFiel,FLD_CARG] := padr("chr(15)",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "DOT" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(15)",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "LASER" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&k2S]+chr(27)+[&k6.60H]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "INKJET" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&k2S]+chr(27)+[&k6.60H]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVcpal(aGets,aRecv)
   // Validate the contents of the page length
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prcpal")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 1 .or. aRecv[nFiel,FLD_CARG] > 120
         aRecv[nFiel,FLD_CARG] := 88
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fVcprl(aGets,aRecv)
   // Validate the contents of the page length
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"prcprl")
   local nPage := fEnum(aRecv,"prcpal")
   begin sequence
      if aRecv[nFiel,FLD_CARG] < 1 .or. aRecv[nFiel,FLD_CARG] > 100
         aRecv[nFiel,FLD_CARG] := aRecv[nPage,FLD_CARG] - 8
         aGets[nFiel]:display()
      endif
      if aRecv[nFiel,FLD_CARG] > aRecv[nPage,FLD_CARG]
         aRecv[nFiel,FLD_CARG] := aRecv[nPage,FLD_CARG] - 8
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fV8lpi(aGets,aRecv)
   // Validate the contents of the 8 lines per inch
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"pr8lpi")
   begin sequence
      if empty(aRecv[nFiel,FLD_CARG])
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[0]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "DOT" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[0]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "LASER" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&l8D]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "INKJET" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&l8D]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fV6lpi(aGets,aRecv)
   // Validate the contents of the 6 lines per inch
   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"pr6lpi")
   begin sequence
      if empty(aRecv[nFiel,FLD_CARG])
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[2]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "DOT" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[2]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "LASER" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&l6D]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      elseif "INKJET" $ trim(upper(aRecv[nFiel,FLD_CARG]))
         aRecv[nFiel,FLD_CARG] := padr("chr(27)+[&l6D]",aRecv[nFiel,FLD_LENG])
         aGets[nFiel]:display()
      endif
   end
return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint

   local aCscr := fASaveScr()
   Local nLine   := 1
   Local cCond   := ""
   Local cNorm   := ""
   Local cMsgN   := IIF(cLanType() == "A", "Normale druk lyn nommer : ","Normal print line number : ")
   Local cMsgC   := IIF(cLanType() == "A", "Klein druk lyn nommer : ","Condense print line number : ")

   IF cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   ELSE
      fScrOpsk( , "Option "+cOption())
   ENDIF

   fScrBood( MAXROW()-1)
   fScrBood( MAXROW())

   BEGIN SEQUENCE

      //Toets of drukker gereed is
      if fPrnReady() == K_ESC
         break
      endif

      IF cLanType() == "A"
         fScrBood( MAXROW(), "Druk lyn nommers om bladsy lengtes te bepaal" )
      ELSE
         fScrBood( MAXROW(), "Print line numbers in order to determine page length" )
      ENDIF

      cNorm := cPrnNorm()
      cCond := cPrnCond()

      //Skakel die drukker aan
      fPrnOn()
      fPrnCod( cNorm )
      SETPRC( 0, 0 )
      nLine := 1
      @ PROW(),0 SAY cMsgN+ALLTRIM(STR(nLine,4,0))

      FOR nLine := 2 TO 110
         @ PROW()+1,0 SAY cMsgN+ALLTRIM(STR(nLine,4,0))
      NEXT

      @ PROW()+1,0 SAY "                                                                                                   1         1         1         "
      @ PROW()+1,0 SAY "         1         2         3         4         5         6         7         8         9         0         1         2         "
      @ PROW()+1,0 SAY "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
      fPrnEjec()
      fPrnCod( cCond )
      fprnCod(cPrn8lpi())
      nLine := 1
      @ PROW(),0 SAY cMsgC+ALLTRIM(STR(nLine,4,0))

      FOR nLine := 2 TO 110
         @ PROW()+1,0 SAY cMsgC+ALLTRIM(STR(nLine,4,0))
      NEXT

      @ PROW()+1,0 SAY "                                                                                                   1         1         1         1         1         1         1         1"
      @ PROW()+1,0 SAY "         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7"
      @ PROW()+1,0 SAY "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"

      fprnCod(cPrn6lpi())

      fPrnEjec()

   END

   // Printer off
   fPrnOff()
   fARestScr(aCscr)

RETURN NIL
