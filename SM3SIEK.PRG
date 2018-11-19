// Application: StudMaster for Beef Cattle
//   File Name: SM3SIEK.PRG
// Description: Program to enter diseases
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 09-28-95      01:47:06pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3siek(nTopp,nLeft,nBott,aVeld,cFind)

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
   local lAver := .f.
   local oCols := NIL
   local nAver := 0
   local nTell := 1
   local lFilt := .f.

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

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

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd(aVeld,{"SM3SIEK","kode"})
         aadd(aVeld,{"SM3SIEK","besk"})
      endif
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         break
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
         if cLanType() == "A"
            fScrOpsk( , "Opsie "+cOption())
         else
            fScrOpsk( , "Option "+cOption())
         endif
      else
         if cLanType() == "A"
            fScrOpsk( 1, "Opsie "+cOption())
         else
            fScrOpsk( 1, "Option "+cOption())
         endif
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "SIEKTES" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "DISEASES" )
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
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=Nuwe siekte      [Del]=Skrap  [AltP]=Druk        ")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [AltE]=Verander siekte  [A-Z]=Vind   [AltB]=Behandelings")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=New disease   [Del]=Delete  [AltP]=Druk      ")
         fScrBood(maxrow()  , "[F1 ]=Help  [AltE]=Edit disease  [A-Z]=Find    [AltB]=Treatments")
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
            do help with "SM3SIEK",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddSiek()
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fAddSiek(recno())
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_B
            // Alt S means show treatments
            sm3sibe(4,15,fieldget(1),fieldget(2))

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint()
               bBrow:refreshall()
            endif

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               lMove := .t.
               nCurr := recno()
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
   fScrBood(maxrow()-1,trim(fieldget(1))+" - "+trim(fieldget(2)))
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
   cKeyp += space(3)
   keyboard chr(K_RIGHT)

   // Ask the data to locate
   fScrBood(maxrow()-1)
   if cLanType() == "A"
      fScrBood(maxrow(),"Tik die SIEKTEKODE waarna gesoek word!")
      nBoxc := fBoxCent(maxrow()/2,"Vind? "+space(len(cKeyp)),1)
      @maxrow()/2, nBoxc say "Vind?" get cKeyp pict "@!"
   else
      fScrBood(maxrow(),"Type the DISEASE CODE being searched for!")
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
      set soft on
      seek cKeyp
      set soft off
      if eof()
         go top
      endif
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fAddSiek(nReko)

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
      aadd(aSend,{"SM3SIEK","kode"})
      aadd(aSend,{"SM3SIEK","besk"})
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE SIEKTE")
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW DISEASE")
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER SIEKTEINLIGTING")
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT DISEASE INFORMATION")
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
                  // Do not clean certain fields
                  // aRepe := {}
                  // aadd(aRepe,"adreskode")
                  // aRecv := fFillBlank(aRecv,aRepe)
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
            pict aRecv[ 1,FLD_PICT] ;
            when(fWkode(nReko)) ;
            valid(fVkode(getlist,aRecv,nReko))
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT]

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
               if "SM3SIEK" $ aRecv[i,DBF_NAME]
                  fieldput(aRecv[i,13],aRecv[i,14])
               endif
            next

            dbunlock()
            dbcommit()

            // Select the active file
            select SM3SIEK

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
STATIC FUNCTION fWkode(nReko)

   // Function to control entry to the code field

   // Declare
   local lRetu := .t.

   // If an edit
   if nReko > 0
      //lRetu := .f.
   else
      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Tik 'n SIEKTEKODE waarmee die siekte ge‹dentifiseer sal word!")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Type a DISEASE CODE to identify the disease!")
      endif

   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVkode(aGets,aRecv,nReko)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local i     := 1
   local aDisp := aclone(aRecv)
   local nFiel := fEnum(aRecv,"kode")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if empty(aGets[nFiel]:varget())

         // No number given - exit to browse
         keyboard chr(K_ESC)
         lRetu := .f.
         break

      endif

      // Locate data
      select SM3SIEK
      seek aGets[nFiel]:varget()
      if eof()

         // Record not in file - allow

      else

         // Record the same as the one being deleted - accept
         if nReko > 0 .and. nReko == SM3SIEK->(recno())
            break
         endif

         // Record is in file - do not allow

         // Display the found data
         for i := 1 to len(aRecv)
            select select(strtran(aRecv[i,DBF_NAME],"->",""))
            aGets[i]:varput(fieldget(aRecv[i,FLD_NUMB]))
            if aGets[i]:hasfocus()
               aGets[i]:updatebuffer()
            else
               aGets[i]:display()
            endif
         next

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"SIEKTE bestaan reeds in die siekteslˆer!")
         else
            fScrBood(maxrow()-1,"DISEASE does exist in the diseases file!")
         endif
         fScrWait(maxrow())

         // Restore the original data
         for i := 1 to len(aRecv)
            aGets[i]:varput(aDisp[i,FLD_CARG])
            if aGets[i]:hasfocus()
               aGets[i]:updatebuffer()
            else
               aGets[i]:display()
            endif
         next

         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aOpsk)

   // Function to print

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local cHead := ""
   local i     := 0
   local cData := ""
   local lPrin := .t.
   local cPrnl := ""
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
      if empty(aOpsk)
         aadd(aVeld,{"SM3SIEK","kode"})
         aadd(aVeld,{"SM3SIEK","besk"})
         aadd(aVeld,{"SM3BEHA","kode"})
         aadd(aVeld,{"SM3BEHA","besk"})
         aadd(aVeld,{"SM3BEHA","pdos"})
         aadd(aVeld,{"SM3BEHA","meth"})
         aOpsk := fGetField(aVeld)
      endif

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3BEHA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIBE")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus("SM3SIEK")
      dbsetrelation("SM3BEHA",{|| SM3SIBE->beha },"SM3SIBE->beha")
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      dbsetrelation("SM3SIBE",{|| SM3SIEK->kode },"SM3SIEK->kode")
      go top

      // Determine the print width
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,FLD_LENG] + nCspa
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
      go top

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"SIEKTES word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Siektes met hulle behandelings."
      else
         fScrbood(maxrow(),"DISEASES being printed!  [Esc]=Stop printer.")
         cHdln := "Diseases with their treatments."
      endif

      // Switch printer on
      fPrnOn()

      // The loop
      do while SM3SIEK->(!eof())


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
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,7]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 2nd heading line
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,8]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 3rd heading line
            cPrnl := "####" + space(nCspa)
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,9]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 4th heading line
            cPrnl := "----" + space(nCspa)
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
         if lPrin
            cPrnl := padl(alltrim(str(cmkeyno())),4) + space(nCspa)
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
         endif

         // Screen
         select SM3SIEK
         // fPrnOff()
         // if cmkeycount() > 0
         //    setcolor( cColBott() )
         //    if cLanType() == "A"
         //       fScrBood(maxrow()-1,str((cmkeyno()/cmkeycount())*100,4,0)+" % Voltooi")
         //    else
         //       fScrBood(maxrow()-1,str((cmkeyno()/cmkeycount())*100,4,0)+" % Completed")
         //    endif
         //    setcolor( cColNorm() )
         // endif
         // fPrnOn()

         // Print the treatments
         select SM3SIBE
         skip
         if eof() .or. SM3SIBE->siek <> SM3SIEK->kode

            // Next record
            lPrin := .t.
            select SM3SIEK
            skip

         else

            // Data
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               cData := aOpsk[i,1] + aOpsk[i,2]
               if upper(cData) == "SM3SIEK->KODE" .or. ;
                     upper(cData) == "SM3SIEK->BESK"
                  cPrnl += space(aOpsk[i,4]) + space(nCspa)
               else
                  if aOpsk[i,3] == "D"
                     cPrnl += dtoc(&(cData)) + space(nCspa)
                  elseif aOpsk[i,3] == "N"
                     cPrnl += str(&(cData),aOpsk[i,4],aOpsk[i,5]) + space(nCspa)
                  else
                     cPrnl += &(cData) + space(nCspa)
                  endif
               endif
            next
            @prow()+1,1 say left(cPrnl,nWidt)
            lPrin := .f.

         endif

         // End of page or end of file
         if prow() >= nPrnl .or. SM3SIEK->(eof())
            // Bottom line
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++

         endif

      enddo

      fPrnOff()

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu
