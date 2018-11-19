// Application: StudMaster for Beef Cattle
//   File Name: SM3OORD.PRG
// Description: Function to print transfer certificates
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 09-19-95      07:54:14am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3oord(nTopp,nLeft,nBott,aVeld,cFind)

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
         aadd(aVeld,{"SM3OORD","idnr"     })
         aadd(aVeld,{"SM3DATA","geslag"   })
         aadd(aVeld,{"SM3DATA","uitkdatum"})
         aadd(aVeld,{"SM3OORD","datepr"   })
         aadd(aVeld,{"SM3KLIE","naam"     })
         aadd(aVeld,{"SM3VERK","adreskode"})
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      dbsetrelation("SM3KLIE",{|| SM3VERK->adreskode },"SM3VERK->adreskode")
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3OORD",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      dbsetrelation("SM3DATA",{|| SM3OORD->idnr }     ,"SM3OORD->idnr"     )
      dbsetrelation("SM3VERK",{|| SM3OORD->idnr }     ,"SM3OORD->idnr"     )

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
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "OORDRAGTE" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "TRANSFERS" )
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
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=Nuwe oordrag      [Del]=Skrap  [AltF]=Disket")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [AltE]=Verander oordrag  [A-Z]=Vind   [AltP]=Druk  ")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=New transfer   [Del]=Delete  [AltF]=Diskette")
         fScrBood(maxrow()  , "[F1 ]=Help  [AltE]=Edit transfer  [A-Z]=Find    [AltP]=Print   ")
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
            do help with "SM3OORD",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fOordAddEdit()
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fOordAddEdit(recno())
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_ALT_F
            // Alt F means transfer to diskette
            if fFile()
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
      cBood := "Moet bogenoemde dier se OORDRAGBESONDERHEDE geskrap word?"
   else
      cBood := "Should animal's TRANSFER INFORMATION be deleted?"
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
   cKeyp += space(11)
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
STATIC FUNCTION fPrint

   // Function to print transfer certificates

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aMenu := {}
   local nWhic := 1
   local nReko := 0
   local cData := ""
   local aAdre := {}
   local cOpsk := ""
   local nCoun := 1
   local nCrec := 1
   local cBood := ""
   local cRasn := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0

   begin sequence

      // Printer ready
      if fPrnReady() == K_ESC
         lRetu := .f.
         break
      endif

      // Condense Printing
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl()
      else
         nPrnl := nPrcPrnl()
      endif
      nMidc := nWidt - 29

      // Get the breed name
      cOpsk := fRasNaam(substr(cTotNaam(),149,3),"HEADTL")
      if empty(cOpsk)
         cRasn := fRasNaam(substr(cTotNaam(),149,3))
         if cLanType() == "A"
            cOpsk := "die "+cRasn+" Beestelersgenootskap van S.A."
         else
            cOpsk := "the "+cRasn+" Cattle Breeders Society of S.A."
         endif
      endif


      // Build a menu
      if cLanType() == "A"
         aadd(aMenu,{"",padr("A - Ongedrukte oordragte",52),trim("Druk alle ongedrukte oordragte."),0,0})
         aadd(aMenu,{"",padr("B - Oordragte voorheen gedruk op "+dtoc(SM3OORD->datepr),52),trim("Druk alle oordragte voorheen gedruk op "+dtoc(SM3OORD->datepr)+"."),0,0})
         aadd(aMenu,{"",padr("C - Ongedrukte oordragte van "+trim(SM3VERK->adreskode),52),trim("Druk alle ongedrukte van "+trim(SM3KLIE->naam)+"."  ),0,0})
         aadd(aMenu,{"",padr("D - Oordragte voorheen gedruk op "+dtoc(SM3OORD->datepr)+" van "+trim(SM3VERK->adreskode),52),trim("Druk alle oordragte voorheen gedruk op "+dtoc(SM3OORD->datepr)+" van "+trim(SM3KLIE->naam)+"."),0,0})
         aMenu[1,1] := "DRUK OORDRAGTE"          // Menu heading
      else
         aadd(aMenu,{"",padr("A - Unprinted transfers",52),trim("Print all unprinted transfers."),0,0})
         aadd(aMenu,{"",padr("B - Transfers previously printed on "+dtoc(SM3OORD->datepr),52),trim("Print all transfers previously printed on "+dtoc(SM3OORD->datepr)+"."),0,0})
         aadd(aMenu,{"",padr("C - Unprinted transfers for "+trim(SM3VERK->adreskode),52),trim("Print all unprinted transfers for "+trim(SM3KLIE->naam)+"."  ),0,0})
         aadd(aMenu,{"",padr("D - Transfers previously printed on "+dtoc(SM3OORD->datepr)+" for "+trim(SM3VERK->adreskode),52),trim("Print all transfers previously printed on "+dtoc(SM3OORD->datepr)+" for "+trim(SM3KLIE->naam)+"."),0,0})
         aMenu[1,1] := "PRINT TRANSFERS"         // Menu heading
      endif

      // Menu coordinates
      aMenu[1,4] := 12 - int(len(aMenu)/2)       // Menu line
      aMenu[1,5] := 39 - int(len(aMenu[1,2])/2)  // Menu column

      // Display the menu
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Kies 'n opsie met "+D_UPARR+D_DNARR+" en druk "+D_ENTER+". [Esc]=Oordragte")
      else
         fScrBood(maxrow()-1,"Choose with "+D_UPARR+D_DNARR+" and press "+D_ENTER+". [Esc]=Transfers")
      endif
      nWhic := fNewMenu(nWhic,,,aMenu)
      do case
         case nWhic >= 1 .and. nWhic <= 4
         otherwise
            // Break
            lRetu := .f.
            break
      endcase

      // Update the file with buyers
      select SM3OORD
      nReko := recno()
      go top
      do while !eof()
         SM3OORD->kode := SM3VERK->adreskode
         skip
      enddo
      goto nReko

      // Set filters
      select SM3OORD
      ordsetfocus("SM3OORK")
      do case
         case nWhic == 1
            // All unprinted transfers
            cmfilter("empty(SM3OORD->datepr)")
         case nWhic == 2
            // Reprint all on specific date
            cmfilter("SM3OORD->datepr==ctod('"+dtoc(SM3OORD->datepr)+"')")
         case nWhic == 3
            // All unprinted for specific breeder
            cmfilter("SM3OORD->kode=='"+SM3OORD->kode+"'.and.empty(SM3OORD->datepr)")
         case nWhic == 4
            // Reprint all for specific breeder
            cmfilter("SM3OORD->kode=='"+SM3OORD->kode+"'.and.SM3OORD->datepr==ctod('"+dtoc(SM3OORD->datepr)+"')")
         otherwise
            // Break
            lRetu := .f.
            break
      endcase
      go top

      // See if it found animals
      if cmkeycount() <= 0
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geen diere gevind om te druk!")
         else
            fScrBood(maxrow()-1,"No animals found to print!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrbood(maxrow(),"Oordragvorm word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(maxrow(),"Transfer form being printed!  [Esc]=Stop printer.")
      endif

      // Printer on
      fPrnOn()

      // The print
      do while !eof()

         // Get the next buyers details
         if cData <> SM3KLIE->kode
            cData := SM3KLIE->kode
            aAdre := {}
            aadd(aAdre,SM3KLIE->kode)
            aadd(aAdre,SM3KLIE->naam)
            aadd(aAdre,SM3KLIE->adr1)
            aadd(aAdre,SM3KLIE->adr2)
            aadd(aAdre,SM3KLIE->adr3)
            aadd(aAdre,SM3KLIE->posk)
         endif

         // Heading
         if prow() = 0

            fPrnCod( cPcod )

            if cLanType() == "A"
               @prow()+nTopl,(nWidt/2)-len(cOpsk)/2 say upper(cOpsk)
               @prow()+1,    1 say cGebNaam()
               @prow()  , nMidc say "             Verslag: " + cOption()
               @prow()+1,    1 say upper("Oordragvorm en deksertifikaat.")
               @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
               @prow()+1,    1 say repl("=",nWidt)
               @prow()+1,    1 say "                                     G G                D e k k i n g s                                                          "
               @prow()+1,    1 say "    Verkoop                          e e  -------------------------------------------                                            "
               @prow()+1,    1 say "### datum    Id nommer    Reg.Nr.    s n  Bulnommer    Reg.Nr.    V Datums            Dokumente aangeheg                         "
               @prow()+1,    1 say "--- -------- ------------ ---------- - -- ------------ ---------- - ----------------- -------------------------------------------"
               //                   1   5        14           27         3840 43           56         6769                87
            else
               @prow()+nTopl,(nWidt/2)-len(cOpsk)/2 say upper(cOpsk)
               @prow()+1,    1 say cGebNaam()
               @prow()  , nMidc say "              Report: " + cOption()
               @prow()+1,    1 say upper("Transfer form and mating certificate.")
               @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
               @prow()+1,    1 say repl("=",nWidt)
               @prow()+1,    1 say "                                     S G                M a t i n g s                                                            "
               @prow()+1,    1 say "    Date                             e e  -------------------------------------------                                            "
               @prow()+1,    1 say "### sold     Id number    Reg.No.    x n  Bull number    Reg.No.  V Dates             Documents attached                         "
               @prow()+1,    1 say "--- -------- ------------ ---------- - -- ------------ ---------- - ----------------- -------------------------------------------"
               //                   1   5        14           27         3840 43           56         6769                87
            endif
         endif

         // Stop the printer
         if fPrnStop() = K_ESC
            lRetu := .f.
            break
         endif

         //Data
         @prow()+1,       1 say str(nCoun,3,0)
         nCoun++
         @prow()  ,pcol()+1 say SM3DATA->uitkdatum
         @prow()  ,pcol()+1 say SM3OORD->idnr
         if substr(cTotNaam(),149,3) == "213"
            @prow()  ,pcol()+1 say if(!empty(SM3DATA->kalfbnr),SM3DATA->kalfbnr+"  ",SM3DATA->reknr)
         else
            @prow()  ,pcol()+1 say SM3DATA->reknr
         endif
         @prow()  ,pcol()+1 say SM3DATA->geslag
         @prow()  ,pcol()+1 say SM3DATA->generasie
         @prow()  ,pcol()+1 say SM3DATA->bulid
         if SM3DATA->bulid <> space(12)
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            if SM3DATA->kalfbnr == space(8)
               @prow()  ,pcol()+1 say SM3DATA->reknr
            else
               @prow()  ,pcol()+1 say SM3DATA->kalfbnr+"  "
            endif
            goto nCrec
            select SM3OORD
         else
            @prow()  ,pcol()+1 say space(10)
         endif
         @prow()  ,pcol()+1 say SM3DATA->tipede
         @prow()  ,pcol()+1 say SM3DATA->dekdat
         @prow()  , 87      say "|"

         @prow()+1,  1 say repl( "-",  nWidt )

         // Screen
         // if cmkeycount() > 0
         //    fPrnOff()
         //    setcolor( cColBott() )
         //    if cLanType() == "A"
         //       @ 23, 30 say fPercent(cmkeyno()/cmkeycount())+"% Voltooi"
         //    else
         //       @ 23, 30 say fPercent(cmkeyno()/cmkeycount())+"% Completed"
         //    endif
         //    setcolor( cColNorm() )
         //    fPrnOn()
         // endif

         // Next record
         select SM3OORD
         skip

         // Page end
         if prow() >= (nPrnl - 6) .or. eof() .or. cData <> SM3KLIE->kode

            // Bottom line
            @prow()  ,  1 say repl( "=",  nWidt )

            if cLanType() == "A"
               @prow()+1,  1 say "Verkoper: " + cGebNaam()
               @prow()  , 65 say "Koper   : " + aAdre[2]
               @prow()+1,  1 say "Adres   : " + substr(cTotNaam(),1,40)
               @prow()  , 65 say "Adres   : " + aAdre[3]
               @prow()+1,  1 say "        : " + substr(cTotNaam(),41,40)
               @prow()  , 65 say "        : " + aAdre[4]
               @prow()+1,  1 say "        : " + substr(cTotNaam(),81,40)
               @prow()  , 65 say "        : " + aAdre[5]
               @prow()+1,  1 say "Poskode : " + substr(cTotNaam(),121,4)
               @prow()  , 65 say "Poskode : " + aAdre[6]
            else
               @prow()+1,  1 say "Seller  : " + cGebNaam()
               @prow()  , 65 say "Buyer   : " + aAdre[2]
               @prow()+1,  1 say "Address : " + substr(cTotNaam(),1,40)
               @prow()  , 65 say "Address : " + aAdre[3]
               @prow()+1,  1 say "        : " + substr(cTotNaam(),41,40)
               @prow()  , 65 say "        : " + aAdre[4]
               @prow()+1,  1 say "        : " + substr(cTotNaam(),81,40)
               @prow()  , 65 say "        : " + aAdre[5]
               @prow()+1,  1 say "Postcode: " + substr(cTotNaam(),121,4)
               @prow()  , 65 say "Postcode: " + aAdre[6]
            endif

            fPrnEjec()
            //fPrnOff()

            // New buyer
            if cData <> SM3KLIE->kode
               nCoun := 1
            endif

         endif

      enddo

      fPrnOff()

      // Ask if printed correctly
      if cLanType() == "A"
         cBood := "Het die oordragvorms korrek uitgedruk?"
      else
         cBood := "Were the transfer forms correctly printed?"
      endif
      if fJaNee(maxrow(),cBood)
         // Save the printed date
         select SM3OORD
         go top
         do while !eof()
            SM3OORD->datepr := dAppDate()
            skip
         enddo
      endif

   end

   // Reset
   cmfilter()
   go top
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fFile

   // Function to transfer animals to a file

   // Declare
   local getlist := {}
   local nBoxc := 0
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aMenu := {}
   local nWhic := 1
   local nReko := 0
   local cDriv := ""
   local i     := 1
   local j     := 1
   local aStru := {}
   local lPedi := .f.
   local lProg := .f.
   local cBood := ""
   local aPedi := {}
   local aProg := {}
   local cPath := ""
   local lLoop := .t.

   begin sequence

      // Build a menu
      if cLanType() == "A"
         aadd(aMenu,{"",padr("A - Alle oordragte aan "+trim(SM3VERK->adreskode),52),trim("Skep 'n disket met alle diere oorgedra aan "+trim(SM3KLIE->naam)+"."  ),0,0})
         aadd(aMenu,{"",padr("B - Oordragte op "+dtoc(SM3OORD->datepr)+" aan "+trim(SM3VERK->adreskode),52),trim("Skep 'n disket diere oorgedra op "+dtoc(SM3OORD->datepr)+" aan "+trim(SM3KLIE->naam)+"."),0,0})
         aMenu[1,1] := "DISKET MET OORDRAGTE"    // Menu heading
      else
         aadd(aMenu,{"",padr("A - All transfers to "+trim(SM3VERK->adreskode),52),trim("Create a diskette with all transfers to "+trim(SM3KLIE->naam)+"."  ),0,0})
         aadd(aMenu,{"",padr("B - Transfers on "+dtoc(SM3OORD->datepr)+" to "+trim(SM3VERK->adreskode),52),trim("Create a diskette with animals transferred on "+dtoc(SM3OORD->datepr)+" to "+trim(SM3KLIE->naam)+"."),0,0})
         aMenu[1,1] := "DISKETTE WITH TRANSFERS" // Menu heading
      endif

      // Menu coordinates
      aMenu[1,4] := 12 - int(len(aMenu)/2)       // Menu line
      aMenu[1,5] := 39 - int(len(aMenu[1,2])/2)  // Menu column

      // Display the menu
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Kies 'n opsie met "+D_UPARR+D_DNARR+" en druk "+D_ENTER+". [Esc]=Oordragte")
      else
         fScrBood(maxrow()-1,"Choose with "+D_UPARR+D_DNARR+" and press "+D_ENTER+". [Esc]=Transfers")
      endif
      nWhic := fNewMenu(nWhic,,,aMenu)
      do case
         case nWhic >= 1 .and. nWhic <= 2
         otherwise
            // Break
            lRetu := .f.
            break
      endcase
      fARestScr(aCscr)

      // Ask which drive
      //cDriv := stddriv(.t.)
      //if empty(cDriv)
      //   // Break
      //   lRetu := .f.
      //   break
      //endif

      // Ask to where
      cPath := padr("A:\OORDATA.DBF",50)

      do while lLoop

         if cLanType() = "A"
            fScrOpsk( ,"Opsie "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"OORDRAGTELˆER")
            fScrBood(MAXROW()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(MAXROW(),"Tik volledige lˆer naam bv. A:\OORDATA.DBF")
         ELSE
            fScrOpsk( ,"Option "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"TRANSFERS FILE")
            fScrBood(MAXROW()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(MAXROW(),"Type full file name e.g. A:\OORDATA.DBF")
         ENDIF

         @ 12,nboxc GET cPath PICT "@!"
         SET(_SET_CURSOR,1)
         READ
         SET(_SET_CURSOR,0)

         if lastkey() == K_ESC
            lRetu := .f.
            break
         endif

         lLoop := .f.

      enddo

      // Update the file with buyers
      select SM3OORD
      nReko := recno()
      go top
      do while !eof()
         SM3OORD->kode := SM3VERK->adreskode
         skip
      enddo
      goto nReko

      // Set filters
      select SM3OORD
      ordsetfocus("SM3OORK")
      do case
         case nWhic == 1
            // All unprinted for specific breeder
            cmfilter("SM3OORD->kode=='"+SM3OORD->kode+"'.and.empty(SM3OORD->datepr)")
         case nWhic == 2
            // Reprint all for specific breeder
            cmfilter("SM3OORD->kode=='"+SM3OORD->kode+"'.and.SM3OORD->datepr==ctod('"+dtoc(SM3OORD->datepr)+"')")
         otherwise
            // Break
            lRetu := .f.
            break
      endcase
      go top

      // See if it found animals
      if cmkeycount() <= 0
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geen diere gevind om oor te plaas na disket!")
         else
            fScrBood(maxrow()-1,"No animals found to transfer to the diskette!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Screen to ask if pedigrees must also be transferred
      if cLanType() == "A"
         cBood := "Moet 'n dier se stamboomdata ook oorgedra word?"
      else
         cBood := "Should an animal's pedigree also be transferred?"
      endif
      lPedi := fJaNee(maxrow(),cBood)

      // Screen to ask if progeny summaries must also be transferred
      if cLanType() == "A"
         cBood := "Moet 'n dier se nageslagdata ook oorgedra word?"
      else
         cBood := "Should an animal's progeny also be transferred?"
      endif
      lProg := fJaNee(maxrow(),cBood)

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere word oorgedra na die disket.")
      else
         fScrWbood(maxrow(),"Animals being transferred to the diskette.")
      endif

      // Create the diskette file
      select SM3DATA
      aStru := dbstruct()
      select SM3OORD
      dbcreate(cDd()+"oordata.dbf",aStru)

      // Open the new
      aCdbf := fATopen(aCdbf,cDd(),"OORDATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The print
      select SM3OORD
      do while !eof()

         // Copy each record
         select OORDATA
         dbappend()
         for i := 1 to fcount()
            fieldput(i,SM3DATA->(fieldget(i)))
         next
         i := fieldpos("UITKREDE")
         fieldput(i,"  ")
         i := fieldpos("UITKDATUM")
         fieldput(i,ctod(""))

         // Copy the pedigree
         if lPedi
            aPedi := fStamboom(SM3OORD->idnr)
            select SM3DATA
            nReko := recno()
            for j := 2 to len(aPedi)
               if !empty(aPedi[j,1])
                  select SM3DATA
                  seek aPedi[j,1]
                  if found()
                     // Copy each record
                     select OORDATA
                     dbappend()
                     for i := 1 to fcount()
                        fieldput(i,SM3DATA->(fieldget(i)))
                     next
                     i := fieldpos("UITKREDE")
                     fieldput(i,"  ")
                     i := fieldpos("UITKDATUM")
                     fieldput(i,ctod(""))
                  endif
               endif
            next
            select SM3DATA
            goto nReko
         endif

         // Copy the progeny summary
         if lProg
            aProg := fSeuns(SM3OORD->idnr)
            select SM3DATA
            nReko := recno()
            for j := 1 to len(aProg)
               if !empty(aProg[j])
                  select SM3DATA
                  seek aProg[j]
                  if found()
                     // Copy each record
                     select OORDATA
                     dbappend()
                     for i := 1 to fcount()
                        fieldput(i,SM3DATA->(fieldget(i)))
                     next
                     i := fieldpos("UITKREDE")
                     fieldput(i,"  ")
                     i := fieldpos("UITKDATUM")
                     fieldput(i,ctod(""))
                  endif
               endif
            next
            select SM3DATA
            goto nReko
         endif

         // Screen
         select SM3OORD
         if cmkeycount() > 0
            setcolor( cColBott() )
            if cLanType() == "A"
               @ 23, 30 say fPercent(cmkeyno()/cmkeycount())+"% Voltooi"
            else
               @ 23, 30 say fPercent(cmkeyno()/cmkeycount())+"% Completed"
            endif
            setcolor( cColNorm() )
         endif

         // Next record
         select SM3OORD
         skip

      enddo

      // Close the diskette file
      select OORDATA
      dbclosearea()
      aCdbf := asize(aCdbf,len(aCdbf)-1)
      select SM3OORD

      // Copy the file to the drive
      //copy file (cDd()+"OORDATA.DBF") to (cDriv+"\OORDATA.DBF")
      copy file (cDd()+"OORDATA.DBF") to (alltrim(cPath))

      // Test file existance
      if file(alltrim(cPath))
         // Delete the temp file
         ferase(cDd()+"OORDATA.DBF")
      else
         // Message that disk file was not created
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Lˆer met oordragte is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"File with transfers was not created!")
         endif
         fScrWait(maxrow())
      endif

   end

   // Reset
   cmfilter()
   go top
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fOordAddEdit(nReko)

   // Declare
   local getlist := {}
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
   begin sequence

      // Values
      nReko := iif(empty(nReko),0,nReko)

      // Ask which animals
      if nReko == 0
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Verkope" )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Sales" )
         endif
         nMenu := fNewMenu(nMenu,"ADDOORD")
         fARestScr(aCscr)
         do case

            case nMenu == 1
               // Single animals

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
      endif

      // Get the fields
      asize(aSend,0)
      aadd(aSend,{"SM3OORD","idnr"     })
      aadd(aSend,{"SM3VERK","adreskode"})
      aadd(aSend,{"SM3DATA","uitkrede" })
      aadd(aSend,{"SM3DATA","uitkdatum"})
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE OORDRAGTE" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW TRANSFERS" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER OORDRAG" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT TRANSFER" )
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
                  aRepe := {}
                  aadd(aRepe,"adreskode")
                  aadd(aRepe,"uitkrede" )
                  aadd(aRepe,"uitkdatum")
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

            endif

         else

            // Clear the get array
            lClea := .t.

         endif

         // Vertoon en get velde
         @nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
            pict aRecv[ 1,FLD_PICT] ;
            when(fWidnr(nReko,nMenu)) ;
            valid(fVidnr(getlist,aRecv,nReko))
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT]+"@K" ;
            when(fWadreskode()) ;
            valid(fVadreskode(getlist,aRecv))
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT]+"@K" ;
            when(fWuitkrede()) ;
            valid(fVuitkrede(getlist,aRecv))
         @nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
            pict aRecv[ 4,FLD_PICT]+"@K" ;
            when(fWuitkdatum()) ;
            valid(fVuitkdatum(getlist,aRecv))

         // The get
         set cursor on
         read
         set cursor off

         // Reset the database
         fATclose(aCdbf)

         // The actions
         if lastkey() == K_ENTER

            lRetu := .t.

            if nMenu == 1

               // Single animal

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
                  if "SM3OORD" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next
               dbunlock()
               dbcommit()

               // Update the main file
               select SM3DATA
               seek SM3OORD->idnr
               if eof()
                  dbappend()
                  SM3DATA->idnr := SM3OORD->idnr
               else
                  do while !rlock()
                  enddo
               endif
               for i := 1 to len(aRecv)
                  if "SM3DATA" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next
               dbunlock()
               dbcommit()

               // Update the sales file
               select SM3VERK
               seek SM3OORD->idnr
               if eof()
                  dbappend()
                  SM3VERK->idnr := SM3OORD->idnr
               else
                  do while !rlock()
                  enddo
               endif
               for i := 1 to len(aRecv)
                  if "SM3VERK" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next
               dbunlock()
               dbcommit()

            else

               // Selection of animals

               // Open the pick list
               aCdbf := fATopen(aCdbf,cDd(),"SM3PICK")
               if !aCdbf[len(aCdbf),1]
                  lRetu := .f.
                  break
               endif

               // Screen
               if cLanType() == "A"
                  fScrWbood(maxrow(),"Diere se verkoopsinligting word bewaar")
               else
                  fScrWbood(maxrow(),"Saving sales information")
               endif

               // Loop the animals in the pick list
               do while !eof()

                  // Screen
                  fScrBood(maxrow()-1,SM3PICK->idnr)

                  // Update the sales file
                  select SM3OORD
                  seek SM3PICK->idnr
                  if eof()
                     dbappend()
                     SM3OORD->idnr := SM3PICK->idnr
                  else
                     do while !rlock()
                     enddo
                  endif
                  for i := 2 to len(aRecv)
                     if "SM3OORD" $ aRecv[i,DBF_NAME]
                        fieldput(aRecv[i,13],aRecv[i,14])
                     endif
                  next
                  dbunlock()
                  dbcommit()

                  // Update the main file
                  select SM3DATA
                  seek SM3PICK->idnr
                  if eof()
                     dbappend()
                     SM3DATA->idnr := SM3PICK->idnr
                  else
                     do while !rlock()
                     enddo
                  endif
                  for i := 1 to len(aRecv)
                     if "SM3DATA" $ aRecv[i,DBF_NAME]
                        fieldput(aRecv[i,13],aRecv[i,14])
                     endif
                  next
                  dbunlock()
                  dbcommit()

                  // Update the transfers file if new record
                  select SM3VERK
                  seek SM3PICK->idnr
                  if eof()
                     dbappend()
                     SM3VERK->idnr := SM3PICK->idnr
                  else
                     do while !rlock()
                     enddo
                  endif
                  for i := 1 to len(aRecv)
                     if "SM3VERK" $ aRecv[i,DBF_NAME]
                        fieldput(aRecv[i,13],aRecv[i,14])
                     endif
                  next
                  dbunlock()
                  dbcommit()

                  // Next
                  select SM3PICK
                  skip

               enddo

               // Close the file
               select SM3PICK
               dbclosearea()
               aCdbf := asize(aCdbf,len(aCdbf)-1)

            endif

            // Select the active file
            select SM3OORD

            // Store the current record number
            nPrev := recno()

            // Next new record
            if nReko == 0 .and. nMenu == 1

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
STATIC FUNCTION fWidnr(nReko,nMenu)

   // Function to control entry to the id number field

   // Declare
   local lRetu := .t.

   // If an edit
   if nReko > 0 .or. nMenu > 1
      lRetu := .f.
   else
      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van lewende diere")
         fScrBood(maxrow()  ,"Tik die ID NOMMER van die verkoopte dier!")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of living animals")
         fScrBood(maxrow()  ,"Type the ID NUMBER of the sold animal!")
      endif

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
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         if cLanType() == "A"
            cData := sm3idnu(3,,,"LEWENDE DIERE","SM3YDAT",aGets[nFiel]:varget())
         else
            cData := sm3idnu(3,,,"LIVING ANIMALS","SM3YDAT",aGets[nFiel]:varget())
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
      select SM3OORD
      seek aGets[nFiel]:varget()
      if eof()

         // Animal not in file - allow

         // Test for animal in main file
         select SM3DATA
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dier bestaan nie in die hooflˆer nie!")
            else
               fScrBood(maxrow()-1,"Animal does not exist in the main file!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break
         else

            // Fill with data from the main file
            if SM3DATA->uitkrede $ cWaarisd()
            else
               aGets[fEnum(aRecv,"uitkrede")]:varput(SM3DATA->uitkrede)
               aGets[fEnum(aRecv,"uitkdatum")]:varput(SM3DATA->uitkdatum)
            endif

         endif

      else

         // Animal is in file - do not allow

         // Move the pointer in the main file
         select SM3DATA
         seek aGets[nFiel]:varget()

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
            fScrBood(maxrow()-1,"Dier bestaan reeds in die OORDRAGTE lˆer!")
         else
            fScrBood(maxrow()-1,"Animal does exist in the TRANSFER file!")
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
STATIC FUNCTION fWadreskode

   // Function to control entry to the buyer

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van kopers")
      fScrBood(maxrow()  ,"Tik die ADRESKODE van die koper van die dier dier!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of buyers")
      fScrBood(maxrow()  ,"Type the ADDRESS CODE of the buyer of the animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVadreskode(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := fEnum(aRecv,"adreskode")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         cData := sm3klie(10,,,,aGets[nFiel]:varget())
         if !empty(cData)
            aGets[nFiel]:varput(cData)
            aGets[nFiel]:updatebuffer()
            if lastkey() == K_ESC
               lRetu := .f.
            endif
         else
            lRetu := .f.
            break
         endif

      elseif empty(aGets[nFiel]:varget())

         // No number given - allow

      else

         // See if code is valid
         select SM3KLIE
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"ADRESKODE van koper is onbekend!")
            else
               fScrBood(maxrow()-1,"ADDRESS CODE of buyer is unknown!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break
         endif

      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWuitkrede

   // Function to control entry to the reason

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van waar-is-dier kodes")
      fScrBood(maxrow()  ,"Tik die REDE waarom die dier verkoop is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of where-is-animal codes")
      fScrBood(maxrow()  ,"Type the REASON why an animal was sold!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitkrede(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := fEnum(aRecv,"uitkrede")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3WAAR")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         cData := sm3waar(11,,,,aGets[nFiel]:varget())
         if !empty(cData)
            aGets[nFiel]:varput(cData)
            aGets[nFiel]:updatebuffer()
            if lastkey() == K_ESC
               lRetu := .f.
            endif
         else
            lRetu := .f.
            break
         endif

      elseif empty(aGets[nFiel]:varget())

         // No number given - allow
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dit is wel voordelig om 'n REDE verkoop te verskaf!")
         else
            fScrBood(maxrow()-1,"It is better to supply a REASON why animal was sold!")
         endif
         fScrWait(maxrow())

      else

         // See if code is valid
         select SM3WAAR
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"REDE waarom dier verkoop is, is onbekend!")
            else
               fScrBood(maxrow()-1,"REASON why animal was sold is unknown!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break
         endif

      endif

      // Code may not indicate living animal
      if !empty(aGets[nFiel]:varget())
         if aGets[nFiel]:varget() $ cWaarisd()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"REDE uit kan nie 'n lewende dier aandui nie!")
            else
               fScrBood(maxrow()-1,"REASON out cannot indicate a living animal!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break
         endif
      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWuitkdatum

   // Function to control entry to the date

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die DATUM waarop die dier verkoop is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the DATE on which the animal was sold!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitkdatum(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nFiel := fEnum(aRecv,"uitkdatum")

   begin sequence

      if empty(aGets[nFiel]:varget())

         // No number given - allow
         if cLanType() == "A"
            fScrBood(maxrow()-1,"DATUM waarop dier verkoop is, is verpligtend!")
         else
            fScrBood(maxrow()-1,"DATE on which animal was sold is compulsory!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)

return lRetu
