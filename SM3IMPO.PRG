//SM3IMPO.PRG
//Program om data te lees vanaf disket
//Kopiereg (c) 1993 A van Rensburg
//08-16-93 04:25pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3impo(nTop,nLeft,nBott,aSend,cFind)

   // Veranderlikes
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFrom  := 1
   local cFrom  := ""                            //From file name
   local cToto  := "NUWEDATA"                    //File to convert and import
   local aStru  := {}
   local cData  := ""
   local nData := 0
   local cHoof := ""
   local i     := 0
   local cPrin := " "
   local cCliv := " "
   local cCall := " "
   local cOall := " "
   local nBoxc := 0
   local cPrev := ""
   local cText := ""
   local lComp := .f.
   local getlist := {}

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   begin sequence

      // Vra vanwaar data gelees moet word dmv menu
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      endif
      nFrom := fNewMenu(nFrom,"SM3IMPO")

      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption(nFrom))
      else
         fScrOpsk( 1, "Option "+cOption(nFrom))
      endif

      do case
         case nFrom == 1
            // Hardeskyf
            cFrom := fHardDisk()
         case nFrom == 2
            // Floppy
            cFrom := fFlopDisk()
         case nFrom == 3
            // Mass Breeding Values
            // sm3blpi() replaced on 12-06-06 12:53
            sm3blp2()
            break
         case nFrom == 4
            // Breedplan
            sm3brei()
            break
         case nFrom == 5
            // Iris historic import
            sm3iges()
            // sm3ihis() replaced on 10-10-24 09:05
            break
         case nFrom == 6
            // Iris registration numbers
            sm3ireg()
            break
         case nFrom == 7
            // Iris performance data
            sm3iper()
            break
         case nFrom == 8
            // Iris birth list
            sm3ibir()
            break
         otherwise
            break
      endcase

      // Kyk of enige leer gevind is
      if empty(cFrom)
         if cLanType() == "A"
            fScrBood(23,"Geen oordraagbare data is gevind nie!")
         else
            fScrBood(23,"No transferable data was found!")
         endif
         fScrWait(24)
         break
      else
         //fScrWait(24,cFrom)
      endif

      // Questions
      if cLanType() == "A"
         fScrOpsk(  , "Opsie "+cOption())
         nBoxc := fBoxCent(9,space(50),6,"LEES DATALˆERS")
         fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
         fScrBood(maxrow()  ,"Tik die besonderhede soos verlang!")
         @10,nBoxc say "   Verwyder lewende waar-is-dier kodes?" get cCliv pict "!"
         @11,nBoxc say "      Verwyder alle waar-is-dier kodes?" get cCall pict "!"
         @12,nBoxc say " Oorskryf bestaande data met nuwe data?" get cOall pict "!"
         @13,nBoxc say "         Druk verslag van veranderings?" get cPrin pict "!"
      else
         fScrOpsk(  , "Option "+cOption())
         nBoxc := fBoxCent(9,space(50),6,"IMPORT DATA FILES")
         fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
         fScrBood(maxrow()  ,"Type the required particulars!")
         @10,nBoxc say "   Remove living where-is-animal codes?" get cCliv pict "!"
         @11,nBoxc say "      Remove all where-is-animal codes?" get cCall pict "!"
         @12,nBoxc say " Overwrite existing data with new data?" get cOall pict "!"
         @13,nBoxc say "               Print report of changes?" get cPrin pict "!"
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
         fScrWbood(24,"Oordraagbare data word gekopieer")
      else
         fScrWbood(24,"Transferable data being copied")
      endif
      copy file (cFrom) to (cDd()+cToto+".DBF")

      // Open the data files
      if cPrin $ "YJ"
         aCdbf := fATopen(aCdbf,cDd(),"SM3TEXT",,,,.f.)
         if !aCdbf[len(aCdbf),1]
            break
         endif
         zap
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aStru := dbstruct()

      // Toets struktuur
      if cLanType() == "A"
         if !stdconv(cDd(),cToto,"DBF",aStru,"Oordraagbara data")
            fScrBood(23,"Oordraagbara data kon nie omgeskakel word nie!")
            fScrWait(24)
            break
         endif
      else
         if !stdconv(cDd(),cToto,"DBF",aStru,"Transferable data")
            fScrBood(23,"Transferable data could not be converted!")
            fScrWait(24)
            break
         endif
      endif

      // Clean out existing living where-is-animal codes
      if cCall $ "YJ" .or. cCliv $ "YJ"
         if cCall $ "YJ"
            cCliv := "N"
         endif
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Waar-is-dier kodes word geskrap!")
         else
            fScrWbood(24,"Where-is-animal codes being deleted!")
         endif
         do while !eof()

            // All codes
            if cCall $ "YJ"
               SM3DATA->uitkrede := "  "
            elseif cCliv $ "YJ"
               if SM3DATA->uitkrede $ cWaarisd()
                  SM3DATA->uitkrede := "  "
               endif
            endif

            // Next record
            skip

         enddo
      endif
      go top

      // Open die nuwe leer met data
      dbusearea(.t.,,cDd()+cToto+".DBF")

      // Gaan deur leer en bewaar data
      if cLanType() == "A"
         fScrWbood(24,"Data word gelees")
      else
         fScrWbood(24,"Data being read")
      endif
      do while !eof()

         // Skerm
         if cLanType() == "A"
            fScrBood(23,NUWEDATA->idnr+" ("+fPercent(recno()/lastrec())+"% Voltooi)")
         else
            fScrBood(23,NUWEDATA->idnr+" ("+fPercent(recno()/lastrec())+"% Completed)")
         endif

         // Hoofleer
         lComp := .f.
         select SM3DATA
         dbsetorder(1)
         seek NUWEDATA->idnr
         if eof()

            // Soek eers vir die rekenaarnommer
            nData := val(NUWEDATA->reknr)
            if empty(nData)
               cData := ""
            else
               cData := alltrim(str(nData))
            endif
            if empty(cData)
            else
               dbsetorder(14)
               seek padl(cData,10,"0")
            endif

            if eof()
               dbsetorder(1)
               dbappend()
               SM3DATA->idnr := NUWEDATA->idnr
               if cPrin $ "YJ"
                  select SM3TEXT
                  dbappend()
                  if cLanType() == "A"
                     cText := NUWEDATA->idnr+" bygevoeg"
                  else
                     cText := NUWEDATA->idnr+" added"
                  endif
                  SM3TEXT->descri := cText
                  cPrev := NUWEDATA->idnr
               endif
               select SM3DATA
            else
               lComp := .t.
               dbsetorder(1)
            endif

         endif

         do while !rlock()
         enddo

         // Bewaar slegs lee velde
         if cOall $ "YJ"

            // Overwrite all fields with not empty fields
            for i := 2 to fcount()

               if !empty(NUWEDATA->(fieldget(i)))

                  if empty(fieldget(i))
                     // Add
                     fieldput(i,NUWEDATA->(fieldget(i)))

                  elseif fieldget(i) == NUWEDATA->(fieldget(i))
                     // No change

                  else

                     // Field differs
                     if cPrin $ "YJ"

                        if NUWEDATA->idnr == cPrev

                           // Display no Id number
                           if cLanType() == "A"
                              cText := space(12)+" "
                              cText += "veld "+trim(fieldname(i))+" "
                              cText += "verander van "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "na "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           else
                              cText := space(12)+" "
                              cText += "field "+trim(fieldname(i))+" "
                              cText += "changed from "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "to "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           endif

                        else

                           // Display Id number
                           cPrev := NUWEDATA->idnr

                           // Display no Id number
                           if cLanType() == "A"
                              cText := NUWEDATA->idnr+" "
                              cText += "veld "+trim(fieldname(i))+" "
                              cText += "verander van "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "na "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           else
                              cText := NUWEDATA->idnr+" "
                              cText += "field "+trim(fieldname(i))+" "
                              cText += "changed from "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "to "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           endif

                        endif

                        // Add the text
                        select SM3TEXT
                        dbappend()
                        SM3TEXT->descri := cText
                        select SM3DATA

                     endif

                     fieldput(i,NUWEDATA->(fieldget(i)))

                  endif

               endif

            next

         else

            // Only write empty fields
            for i := 2 to fcount()

               if empty(fieldget(i))
                  fieldput(i,NUWEDATA->(fieldget(i)))
               else

                  if fieldget(i) == NUWEDATA->(fieldget(i))
                     // Fields the same - no changes
                  else
                     // Fields not the same - record
                     if cPrin $ "YJ"

                        if NUWEDATA->idnr == cPrev

                           // Display no Id number
                           if cLanType() == "A"
                              cText := space(12)+" "
                              cText += "veld "+trim(fieldname(i))+" "
                              cText += "verskil. Oue: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "Nuwe: "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           else
                              cText := space(12)+" "
                              cText += "field "+trim(fieldname(i))+" "
                              cText += "differs. Current: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "New: "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           endif

                        else

                           // Display Id number
                           cPrev := NUWEDATA->idnr

                           // Display no Id number
                           if cLanType() == "A"
                              cText := NUWEDATA->idnr+" "
                              cText += "veld "+trim(fieldname(i))+" "
                              cText += "verskil. Oue: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "Nuwe: "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           else
                              cText := NUWEDATA->idnr+" "
                              cText += "field "+trim(fieldname(i))+" "
                              cText += "differs. Current: "+alltrim(transform(fieldget(i),"@!"))+" "
                              cText += "New: "+alltrim(transform(NUWEDATA->(fieldget(i)),"@!"))+" "
                           endif

                        endif

                        // Add the text
                        select SM3TEXT
                        dbappend()
                        SM3TEXT->descri := cText
                        select SM3DATA

                     endif

                  endif

               endif

            next

         endif

         // Volgende
         select NUWEDATA
         skip

      enddo

      // Display the details
      if cPrin $ "YJ"
         fDisplay()
      endif

   end

   // Herstel
   cOption(-1)
   fARestScr(aCscr)
   fATclose(aCdbf)
   ferase(cDd()+cToto+".DBF")

return NIL

/******************************************************************************/
STATIC FUNCTION fHardDisk

   // Funksie om oordragdata op te spoor op hardeskyf

   // Verklaar
   local cCscr := savescreen(0,0,24,79)
   local aFoun := {}
   local cSeek := "OORDATA.DBF"
   local cFrom := ""
   local cData := ""
   local i     := 0
   local nLeng := 0
   local nKeus := 1
   local nBoxc := 0
   begin sequence

      // Maak datadryfleer oop
      dbusearea(.t.,,"stddryf.dbf")
      if neterr()
         break
      endif

      // Gaan deur leer en bou array van datadrywe waar data is
      do while !eof()
         // Bou leersoek parameters
         cData := trim(STDDRYF->datadr)
         if right(cData,1) <> "\"
            cData += "\"
         endif
         cData += cSeek
         // Kyk of leer bestaan
         if file(cData)
            // Voeg by array
            aadd(aFoun,cData)
         endif
         skip
      enddo
      // Close file
      dbclosearea()

      // Kyk of enige oordragdata gevind is
      if empty(aFoun)
         break
      endif

      // Indien slegs een lank - neem outomaties
      if len(aFoun) == 1
         cFrom := aFoun[1]
         break
      endif

      // Bepaal die langste array element
      for i := 1 to len(aFoun)
         if len(aFoun[i]) > nLeng
            nLeng := len(aFoun[i])
         endif
      next

      // Maak array elemente dieselfde lengte
      for i := 1 to len(aFoun)
         aFoun[i] := padr(aFoun[i],nLeng)
      next

      // Vertoon die menu om te kies
      if cLanType() == "A"
         fScrOpsk(  , "Opsie "+cOption())
         nBoxc := fBoxCent(10,space(nLeng),5,"OORDRAG VANAF?")
      else
         fScrOpsk(  , "Option "+cOption())
         nBoxc := fBoxCent(10,space(nLeng),5,"TRANSFER FROM?")
      endif
      nKeus := achoice(10,nBoxc,14,nBoxc+nLeng,aFoun)
      if nKeus > 0
         cFrom := aFoun[nKeus]
      endif

   end

   // Herstel
   restscreen(0,0,24,79,cCscr)
return cFrom

/***************************************************************************/
STATIC FUNCTION fFlopDisk

   // Funksie om disketaandrywer te vra

   // Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cFrom := ""
   local cDriv := "A:"
   local nBoxc := 0
   local getlist := {}
   begin sequence

      // Vra watter dryf
      if cLanType() == "A"
         fScrOpsk(  , "Opsie "+cOption())
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Vanaf watter datamedium moet die data gelees word? (Bv. A: of E:)")
         nBoxc := fBoxCent(11,"Datamedium? xx",3)
         @12,nBoxc say "Datamedium?" get cDriv pict "!:" // valid(cDriv$"A:zB:z :z  ")
      else
         fScrOpsk(  , "Option "+cOption())
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"From which data medium should the data be read? (Ex. A: or E:)")
         nBoxc := fBoxCent(11,"Data medium? xx",3)
         @12,nBoxc say "Data medium?" get cDriv pict "!:" // valid(cDriv$"A:zB:z :z  ")
      endif
      set cursor on
      read
      set cursor off
      if lastkey() == K_ESC .or. cDriv $ " :  "
         break
      endif

      // Leernaam
      cFrom := cDriv + "\OORDATA.DBF"

      // Plaas disket in dryf
      if cLanType() == "A"
         fScrBood(23,"Plaas medium met data in "+cDriv+" asseblief!")
      else
         fScrBood(23,"Please place medium with data in "+cDriv+"!")
      endif
      fScrWait(24)

      // Kyk of dataleer bestaan
      if file(cFrom)
      else
         cFrom := ""
      endif

   end

   // Herstel
   restscreen(0,0,24,79,cCscr)

return cFrom

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
            do help with "sm3impo",1,"oorsig"

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
   local aVeld := {}
   local i     := 0
   local lLoop := .t.
   local cPrnl := ""
   local cData := ""
   local nDrag := 0
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local nCspa := 1

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
