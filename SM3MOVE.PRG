// Application: StudMaster for Beef Cattle
//   File Name: SM3MOVE.PRG
// Description: Program to move data from one set to another
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-26-95      05:09:47pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3move

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nMenu := 1
   local cData := ""
   local aDriv := {}
   local nLeng := 0
   local i     := 0
   local nBoxc := 0
   local nKeus := 1
   local cToto := ""
   local cOall := "N"
   local cPrin := "Y"
   local cText := ""
   local cPrev := ""
   local cDump := "N"
   local cNeww := ""
   local cOldw := ""
   local cAllc := "Y"
   local cPria := "Y"
   local cPedi := "N"
   local cProg := "N"

   local nReco := 0
   local nCurr := 0
   local aPedi := {}
   local aProg := {}

   if cLanType() == "A"
      fScrOpsk(1, "Opsie "+cOption())
   else
      fScrOpsk(1, "Option "+cOption())
   endif

   begin sequence

      // Move which animals
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Menu" )
      endif
      nMenu := fNewMenu(nMenu,"SM3MOVE")

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

      // To which data drive
      aCdbf := fATopen(aCdbf,,"STDDRYF")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aDriv := {}
      do while !eof()
         if trim(STDDRYF->datadr)+"\" == cDd()
         else
            aadd(aDriv,trim(STDDRYF->datadr))
         endif
         skip
      enddo
      fATclose(aCdbf)
      aCdbf := asize(aCdbf,len(aCdbf)-1)

      // Check for the length
      if len(aDriv) <= 0
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geen datadrywe is beskikbaar om na te kopieer nie!")
         else
            fScrBood(maxrow(),"No data drives available to copy to!")
         endif
         fScrWait(maxrow())
         break
      endif
      // Get the longest element
      for i := 1 to len(aDriv)
         if len(aDriv[i]) > nLeng
            nLeng := len(aDriv[i])
         endif
      next
      // Display the menu
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
         nBoxc := fBoxCent(10,space(nLeng),5,"OORDRAG NA?")
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Na watter datastel moet die data oorgedra word?")
      else
         fScrOpsk( , "Option "+cOption())
         nBoxc := fBoxCent(10,space(nLeng),5,"TRANSFER TO?")
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"To which data set should the data be transferred?")
      endif
      nKeus := achoice(10,nBoxc,14,nBoxc+nLeng,aDriv)
      if nKeus > 0
         cToto := alltrim(aDriv[nKeus])
      else
         break
      endif
      if right(cToto,1) <> "\"
         cToto += "\"
      endif

      // Ask the transfer questions
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
         nBoxc := fBoxCent(9,space(55),9,"OORDRAG VAN DATA")
         fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
         fScrBood(maxrow()  ,"Tik die besonderhede soos verlang!")
         @10,nBoxc say "   Oorskryf bestaande data met nuwe data?" get cOall pict "!"
         @11,nBoxc say "           Druk verslag van veranderings?" get cPrin pict "!"
         @12,nBoxc say "Vertoon nuut bygevoegde diere in verslag?" get cPria pict "!"
         @13,nBoxc say "Verwyder eers lewende waar-is-dier kodes?" get cDump pict "!"
         @14,nBoxc say "             Toets vir alle veranderings?" get cAllc pict "!"
         @15,nBoxc say "                        Dra stamboom oor?" get cPedi pict "!"
         @16,nBoxc say "                        Dra nageslag oor?" get cProg pict "!"
      else
         fScrOpsk( , "Option "+cOption())
         nBoxc := fBoxCent(9,space(55),9,"TRANSFER DATA")
         fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
         fScrBood(maxrow()  ,"Type the required particulars!")
         @10,nBoxc say "    Overwrite existing data with new data?" get cOall pict "!"
         @11,nBoxc say "                  Print report of changes?" get cPrin pict "!"
         @12,nBoxc say "    Include newly added animals in report?" get cPria pict "!"
         @13,nBoxc say "First delete living where-is-animal codes?" get cDump pict "!"
         @14,nBoxc say "                     Test for all changes?" get cAllc pict "!"
         @15,nBoxc say "                        Transfer pedigree?" get cPedi pict "!"
         @16,nBoxc say "                 Transfer progeny summary?" get cProg pict "!"
      endif
      setcursor(1)
      read
      setcursor(0)

      // If escaped
      if lastkey() == K_ESC
         break
      endif

      // Kopieer leer na huidige datadryf
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Data word oorgedra")
      else
         fScrWbood(24,"Data being copied")
      endif

      // Get the old datasets where-is-animals codes
      //if cDump $ "JY"
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      cOldw := STDWAAR->velded
      fATclose(aCdbf)
      aCdbf := asize(aCdbf,len(aCdbf)-1)
      //endif

      // Get the new datasets where-is-animals codes
      //if cDump $ "JY"
      aCdbf := fATopen(aCdbf,cToto,"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      cNeww := STDWAAR->velded
      fATclose(aCdbf)
      aCdbf := asize(aCdbf,len(aCdbf)-1)
      //endif

      // Open the data files
      if cPrin $ "YJ"
         aCdbf := fATopen(aCdbf,cDd(),"SM3TEXT",,,,.f.)
         if !aCdbf[len(aCdbf),1]
            break
         endif
         zap
      endif
      aCdbf := fATopen(aCdbf,cToto,"SM3DATA",,,"NEW",.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif


      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"OLD")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3PICK")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // If pedigree or progeny
      if cPedi $ "JY" .or. cProg $ "JY"

         select SM3PICK
         nReco := lastrec()
         go top

         do while recno() <= nReco

            // Store the current record
            //SM3PICK->char := left(cNeww,2)
            nCurr := recno()

            // Store the pedigree
            if cPedi $ "JY"

               // Get the pedigree
               aPedi := fPedi(SM3PICK->idnr)

               // Store the pedigree
               for i := 2 to 15
                  if !empty(aPedi[i,1])
                     dbappend()
                     SM3PICK->idnr := aPedi[i,1]
                     //SM3PICK->char := "PE"
                  endif
               next

               // Go back to original record
               goto nCurr

            endif

            // Store the progeny
            if cProg $ "JY"

               // Get the progeny
               aProg := fProg(SM3PICK->idnr)

               // Store the pedigree
               if len(aProg) > 0
                  for i := 1 to len(aProg)
                     if !empty(aProg[i])
                        dbappend()
                        SM3PICK->idnr := aProg[i]
                        //SM3PICK->char := "PR"
                     endif
                  next
               endif

               // Go back to original record
               goto nCurr

            endif

            // Next record
            select SM3PICK
            skip

         enddo

      endif

      // Set relation between pick file and old database
      select SM3PICK
      dbsetrelation("OLD",{|| SM3PICK->idnr },"SM3PICK->idnr")
      go top

      // Delete all where-is-animal codes
      if cDump $ "JY"
         select NEW
         do while !eof()
            if NEW->uitkrede $ cNeww
               NEW->uitkrede := "  "
            endif
            skip
         enddo
         go top
      endif

      select SM3PICK
      go top
      // Loop to update the data
      do while !eof()

         // Activate the new file
         select NEW
         seek SM3PICK->idnr
         if eof()


            // See if the animal can be located on computer number
            // only if not empty computer number

            if val(OLD->reknr) > 0

               select NEW
               set order to 14
               seek padl(alltrim(OLD->reknr),10,"0")

               if eof()

                  select NEW
                  set order to 1
                  dbappend()
                  if cPrin $ "YJ" .and. cPria $ "YJ"
                     select SM3TEXT
                     dbappend()
                     if cLanType() == "A"
                        cText := SM3PICK->idnr+" ("+ alltrim(OLD->reknr) +") bygevoeg"
                     else
                        cText := SM3PICK->idnr+" ("+ alltrim(OLD->reknr) +") added"
                     endif
                     SM3TEXT->descri := cText
                     cPrev := SM3PICK->idnr
                  endif

               endif

            else

               select NEW
               set order to 1
               dbappend()
               if cPrin $ "YJ" .and. cPria $ "YJ"
                  select SM3TEXT
                  dbappend()
                  if cLanType() == "A"
                     cText := SM3PICK->idnr+" ("+ alltrim(OLD->reknr) +") bygevoeg"
                  else
                     cText := SM3PICK->idnr+" ("+ alltrim(OLD->reknr) +") added"
                  endif
                  SM3TEXT->descri := cText
                  cPrev := SM3PICK->idnr
               endif

            endif

         endif

         // Loop to add the data
         select NEW
         if cOall $ "YJ"

            // Overwrite all fields with not empty fields
            for i := 1 to fcount()

               if !empty(OLD->(fieldget(i)))

                  if empty(fieldget(i))
                     // Add
                     fieldput(i,OLD->(fieldget(i)))
                  elseif fieldget(i) == OLD->(fieldget(i))
                     // No change
                  else

                     // Field differs
                     if cPrin $ "YJ"

                        // Display no Id number
                        if cLanType() == "A"
                           cText := OLD->idnr+" "
                           cText += "veld "+trim(fieldname(i))+" "
                           cText += "verander van "+alltrim(transform(fieldget(i),"@!"))+" "
                           cText += "na "+alltrim(transform(OLD->(fieldget(i)),"@!"))+" "
                        else
                           cText := OLD->idnr+" "
                           cText += "field "+trim(fieldname(i))+" "
                           cText += "changed from "+alltrim(transform(fieldget(i),"@!"))+" "
                           cText += "to "+alltrim(transform(OLD->(fieldget(i)),"@!"))+" "
                        endif

                        // Add the text
                        if cAllc $ "JY"
                           // Test for all changes
                           select SM3TEXT
                           dbappend()
                           SM3TEXT->descri := cText
                           select NEW
                        else
                           // Only check for in herd animals
                           if OLD->uitkrede $ cOldw
                           else
                              cText := ""
                           endif
                           // Check only for certain changes
                           if "GESLAG" $ cText .or. ;
                                 "GEBDATUM" $ cText .or. ;
                                 "GENERASIE" $ cText .or. ;
                                 "IDVAAR" $ cText .or. ;
                                 "IDMOER" $ cText .or. ;
                                 "IND100" $ cText .or. ;
                                 "IND205" $ cText .or. ;
                                 "IND365" $ cText .or. ;
                                 "IND540" $ cText
                              select SM3TEXT
                              dbappend()
                              SM3TEXT->descri := cText
                              select NEW
                           endif

                        endif

                     endif

                     fieldput(i,OLD->(fieldget(i)))

                  endif

               endif

               // Change the where-is-animal code to a living one in new directory
               if cDump $ "JY"
                  select NEW
                  if NEW->uitkrede $ cOldw
                     NEW->uitkrede := left(cNeww,2)
                  endif
               endif

            next

         else

            // Only write empty fields
            for i := 1 to fcount()
               if empty(fieldget(i))
                  // Add
                  fieldput(i,OLD->(fieldget(i)))
               elseif empty(OLD->(fieldget(i)))
                  // Source is also empty - ignore
               else
                  if fieldget(i) == OLD->(fieldget(i))
                     // Fields the same - no changes
                  else
                     // Fields not the same - record
                     if cPrin $ "YJ"

                        if OLD->idnr == cPrev

                           // Display no Id number
                           if cLanType() == "A"
                              cText := space(12)+" "
                              cText += "veld "+trim(fieldname(i))+" "
                              cText += "verskil. Oue: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "Nuwe: "+alltrim(transform(OLD->(fieldget(i)),"@!"))+" "
                           else
                              cText := space(12)+" "
                              cText += "field "+trim(fieldname(i))+" "
                              cText += "differs. Current: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "New: "+alltrim(transform(OLD->(fieldget(i)),"@!"))+" "
                           endif

                        else

                           // Display Id number
                           cPrev := OLD->idnr

                           // Display no Id number
                           if cLanType() == "A"
                              cText := OLD->idnr+" "
                              cText += "veld "+trim(fieldname(i))+" "
                              cText += "verskil. Oue: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "Nuwe: "+alltrim(transform(OLD->(fieldget(i)),"@!"))+" "
                           else
                              cText := OLD->idnr+" "
                              cText += "field "+trim(fieldname(i))+" "
                              cText += "differs. Current: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "New: "+alltrim(transform(OLD->(fieldget(i)),"@!"))+" "
                           endif

                        endif

                        // Add the text
                        select SM3TEXT
                        dbappend()
                        SM3TEXT->descri := cText
                        select NEW

                     endif

                  endif

               endif

            next

         endif

         // Next record
         select SM3PICK
         skip

      enddo

   end

   // Display the details
   if cPrin $ "YJ"
      fDisplay()
   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)
   cOption(-1)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDisplay

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
      aadd(aVeld,{"SM3TEXT","descri"})
      aOpsk := fGetField(aVeld)

      // Move the record pointer
      select SM3TEXT
      go top

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
         fBox( nTopp, nLeft, nBott, nRigh, "VERANDERINGSVERSLAG" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "CHANGES REPORT" )
      endif
      setcolor( cColNorm() )

      // Build the browse
      oBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      oBrow:headsep := "Í"
      oBrow:colsep := "³"

      // Build the browse columns
      for i = 1 to len( aCols )
         oBrow:addColumn( aCols[i] )
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc ]=Menu")
         fScrBood(maxrow()  , "[AltP]=Druk")
      else
         fScrBood(maxrow()-1, "[Esc ]=Menu")
         fScrBood(maxrow()  , "[AltP]=Druk")
      endif

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
         cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

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
            fPrint(aOpsk)

         elseif nKeyp == K_F1
            // Help
            do help with "sm3move",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(oBrow, nKeyp)

         endif

      enddo

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aOpsk)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local i     := 0
   local nCspa := 1
   local lLoop := .t.
   local cPrnl := ""
   local cData := ""
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
      select SM3TEXT
      go top

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"VERANDERINGSVERSLAG word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Lees datalˆer veranderingsverslag."
      else
         fScrbood(maxrow(),"CHANGES REPORT being printed!  [Esc]=Stop printer.")
         cHdln := "Import data changes report."
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

         // Screen
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

         // Next record
         select SM3TEXT
         skip

         // End of page or end of file
         if prow() >= nPrnl .or. eof()
            // Bottom line
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
