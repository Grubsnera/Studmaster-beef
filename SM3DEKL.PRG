//SM3DEKL.PRG
//Program om deklyste te vertoon en te druk
//Kopiereg (c) 1992 A van Rensburg
//10:27pm Sep 28,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "fileio.ch"


//**************************************************************************/
FUNCTION sm3dekl(nTop,nLeft,nBottom,aSend,cFind)

   //Veranderlikes

   local cBrep := ""


   local cFile   := ""                           //Status of opened file
   local aRecv   := {}                           //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nRight  := 77                           //Regterkantste lyn
   local bBrowse := NIL                          //Browse object
   local aColumn := {}                           //Kolomme array
   local i       := 0                            //Counter
   local lMore   := .t.                          //Logical looper
   local nKey    := 0                            //Keypress
   local cToFile := cDd()+"sm3tydi.dbf"
   local cLocate := ""
   local cLocScr := ""
   local nBoxCoor := 0
   local getlist := {}

   private cData := ""                           //Column data fields for tbrowse
   private cHead := ""                           //Heading of tbrowse

   //Skerm
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop    == NIL, 3, nTop )
   nLeft   := if( nLeft   == NIL, 2, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )

   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3dekk","idvaar"})
      aadd(aSend,{"sm3dekk","idmoer"})
      aadd(aSend,{"sm3dekk","vaarkode"})
      aadd(aSend,{"sm3dekk","datumin"})
      aadd(aSend,{"sm3dekk","datumuit"})
      aadd(aSend,{"sm3dekk","dragtig"})
      aadd(aSend,{"sm3dekk","insem"})
      aadd(aSend,{"sm3dekk","opmerk"})
      aadd(aSend,{"sm3dekk","donor"})
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open die stdmenu.tdb - gaan verander - use exclusive
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cFile := fTOpen(cDd(),"sm3dekk",,,,.t.,.f.)
   if left( cFile, 1 ) == "f"
      return NIL
   endif
   set order to 3

   //Skuif die databasis
   if cFind == NIL
      if cLanType() == "A"
         fScrBood(23,"Kalfseisoen onbekend!")
      else
         fScrBood(23,"Calving season unknown!")
      endif
      fScrWait(24)
      fTClose(cFile)
      return NIL
   else
      seek cFind
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Geen inligting vir die kalfseisoen kon gevind word nie!")
         else
            fScrBood(23,"No information could be found for the calving season!")
         endif
         fScrWait(24)
         fTClose(cFile)
         return NIL
      endif
   endif

   //Soek diere
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kalfseisoen se dekkings word uitgesoek!")
   else
      fScrWbood(24,"Calving season matings being sorted!")
   endif
   copy to (cToFile) while SM3DEKK->teelgroep == cFind

   //Sluit leer en open tydelike leer
   fTClose(cFile)
   cFile := fTOpen(cDd(),"sm3tydi",,,"sm3dekk",.t.,.f.)
   if left( cFile, 1 ) == "f"
      return NIL
   endif

   //Kry die breedte van venster
   for i = 1 to len( aRecv )

      //Lengte
      nScrLen := nScrLen + aRecv[i,4] + 3

      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 77, 77, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "Kalfseisoen "+trim(cFind)+" deklys" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "Calving season "+trim(cFind)+" mating list" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrowse := TBrowseDB( nTop+1, nLeft+2, nBottom-1, nRight-2 )
   bBrowse:headsep := "Í"
   bBrowse:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      bBrowse:addColumn( aColumn[i] )
   next

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "            [A - Z]=Vind bul     [AltE]=Excel             " )
         fScrBood( 24, "[Esc]=Menu  [Alt P]=Druk deklys  [AltF]=VersendElektronies" )
      else
         fScrBood( 23, "            [A - Z]=Find bull          [AltE]=Excel               " )
         fScrBood( 24, "[Esc]=Menu  [Alt P]=Print mating list  [AltF]=SubmitElectronically" )
      endif

      //Vries
      bBrowse:freeze := 1

      // Stabilize the display until it's stable or a key is pressed
      nKey := 0
      do while nKey == 0 .and. .not. bBrowse:stable
         bBrowse:stabilize()
         nKey := InKey()
      enddo

      if bBrowse:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrowse:refreshCurrent()
         ForceStable(bBrowse)
         // Everything's done -- just wait for a key
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKey == K_ALT_P
         //Means print mating list
         fPrint(aRecv,cFind)
         bBrowse:refreshall()

   elseif nKey == K_ALT_E

      // Alt E means create electronic notofication in excel
      cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

      if cBrep $ "JYjy"

         // Breedplan format
         if fDiskBrem()
            bBrowse:refreshall()
         endif

      else

         // Iris matings
         // Added 13-04-25 07:34 (From Downloads/Studbook/EDH20130424.PDF)
         if fCsvIris()
            bBrowse:refreshall()
         endif

            endif

      elseif nKey == K_ALT_F

         // Alt F means create electronic notofication
         cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

         if cBrep $ "JYjy"

            // Breedplan format
            if fDiskBrem()
               bBrowse:refreshall()
            endif

         else

            // Iris matings
            // Added 13-04-25 07:34 (From Downloads/Studbook/EDH20130424.PDF)
            if fDiskIris()
               bBrowse:refreshall()
            endif

         endif


      elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122
         //Means locate a record
         cLocate := upper( chr( nKey ) ) + space(11)
         cLocScr := savescreen( 0, 0, 24, 79 )
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 11, "Vind watter bul? xxxxxxxxxxxx", 3 )
            @12, nBoxCoor say "Vind watter bul?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 11, "Find which bull? xxxxxxxxxxxx", 3 )
            @12, nBoxCoor say "Find which bull?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            go top
            locate for trim(cLocate) $ SM3DEKK->idvaar
            if eof()
               go top
            endif
            bBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrowse, nKey)

      endif

   enddo

   //Herstel
   fTClose(cFile)
return NIL

//***************************************************************************/
STATIC FUNCTION fPrint(aRecv,cFind)

   // Funksie om deklyste te druk

   // Verklaar
   local nRecno  := recno()
   local nTotaal := 1
   local aSend   := {}
   local lLoop   := .t.
   local nI      := 1
   local nRekord := 1
   local nBulnr  := 1
   local cBulnr  := ""
   local cHdln   := ""
   local cPcod   := ""
   local nMidc   := 0
   local nWidt   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local nPagl   := 0
   local nBlad   := 1

   // Verstekwaardes
   cFind := if(cFind==NIL,"",cFind)

   // Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   // Databasis
   go top
   nTotaal := lastrec()

   // Printer
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
   nMidc := nWidt - 29

   // Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif
   // Kry die velde benodig
   if aRecv == NIL
      asize( aSend, 0 )
      aadd(aSend,{"sm3dekk","idvaar"})
      aadd(aSend,{"sm3dekk","idmoer"})
      aadd(aSend,{"sm3dekk","vaarkode"})
      aadd(aSend,{"sm3dekk","datumin"})
      aadd(aSend,{"sm3dekk","datumuit"})
      aadd(aSend,{"sm3dekk","insem"})
      aadd(aSend,{"sm3dekk","opmerk"})
      aadd(aSend,{"sm3dekk","donor"})
      aRecv := fGetField( aSend )
   endif

   // Skerm
   if cLanType() == "A"
      fScrbood(24,"Deklyste word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Mating lists being printed!  [Esc]=Stop printer." )
   endif

   // Skakel die drukker aan
   fPrnOn()

   // Doen die loop
   lLoop := .t.
   do while lLoop

      fPrnCod( cPcod )

      // Opskrifte
      if prow() = 0
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
            cHdln := "DEKLYS VAN DIE BUL "+trim(SM3DEKK->idvaar)+" VIR DIE "+trim(cFind)+" KALFSEISOEN."
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
            cHdln := "MATING LIST FOR THE BULL "+trim(SM3DEKK->idvaar)+" FOR THE "+trim(cFind)+" CALVING SEASON."
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
         endif
         @prow()+1,  1 say repl( "=",nWidt )

         // 1e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say ""
               @prow()  ,       6 say padr( trim( aRecv[nI,7] ), aRecv[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,7] ), aRecv[nI,4] )
            endif
         next

         // 2e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say ""
               @prow()  ,       6 say padr( trim( aRecv[nI,8] ), aRecv[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,8] ), aRecv[nI,4])
            endif
         next

         // 3e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say "####"
               @prow()  ,       6 say padr( trim( aRecv[nI,9] ), aRecv[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,9] ), aRecv[nI,4])
            endif
         next

         // 4e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say "----"
               @prow()  ,       6 say repl( "-", aRecv[nI,4] )
            else
               @prow()  ,pcol()+1 say repl( "-", aRecv[nI,4] )
            endif
         next
      endif

      // Toets of drukker moet stop
      If fPrnStop() = K_ESC
         goto nRecno
         return NIL
      endif

      // Data
      for nI = 1 to len( aRecv )
         if nI == 1
            @prow()+1,       1 say ltrim(str(nBulnr))
            @prow()  ,       6 say fieldget(aRecv[nI][13])
         else
            @prow()  ,pcol()+1 say fieldget(aRecv[nI][13])
         endif
      next

      // Volgende rekord
      nBulnr++
      cBulnr := SM3DEKK->idvaar
      skip

      // Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof() .or. SM3DEKK->idvaar <> cBulnr

         // Print onderste lyn
         @prow()+1,  1 say repl( "=",nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         nBlad++

         // Indien volgende vaar
         if SM3DEKK->idvaar <> cBulnr
            nBulnr  := 1
            nBlad   := 1
         endif

         // Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   // Herstel
   goto nRecno

return NIL

/******************************************************************************/
STATIC FUNCTION fDiskBrem

   // Program to create diskettes with performance data for Breedplan
   // Breedplan data collection formats Version 4.1 dated 16 March 2000
   // Marcus O'Sullivan Bloemfontein Brahman December 2001

   // Declare
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nSire := 0
   local lRetu := .t.
   local nBoxc := 0
   local nMfil := 0
   local cStr := ""
   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Set the relationship
      select SM3DEKK
      set relation to IDMOER into SM3DATA
      go top

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dekkingslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Mating file being prepared")
      endif

      // Open the file
      if file(cFile)
         set alternate to (cFile) additive
         set alternate on
         set console off
      else
         set alternate to (cFile)
         set alternate on
         set console off
      endif

      // Write the data
      select SM3DEKK
      go top

      do while !eof()

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,fPercent(recno(),lastrec())+"% Completed"      )
         endif
         set cons off
         set alternate on

         nSire := 0
         nSire := val(fAnimData(SM3DEKK->idvaar,"REKNR"))

         /*********************************************************************/
         // The actual write of the animal itself

         ?? "N"                                  // Always N

         ?? substr(cTotNaam(),152,7)             // Soc ident of herd

         ?? padr(fId(SM3DEKK->idmoer,.f.),19)    // Id number

         set cent on
         ??  strtran(dtoc(SM3DEKK->datumin),"/","") // Date in
         set cent off

         if SM3DEKK->vaarkode $ "34"             // Service code
            ?? "A"
         else
            ?? "N"
         endif

         ?? padr(fId(SM3DEKK->idvaar,.f.),19)    // Id number

         set century on
         if empty(SM3dekk->datumuit)
            ??  strtran(dtoc(SM3DEKK->datumin),"/","") // Date out same as date in
         else
            ??  strtran(dtoc(SM3DEKK->datumuit),"/","") // Date out same as date in
         endif
         set century off

         if empty(SM3DEKK->idnr)                 // Mating result
            ?? "F"
         else
            ?? "S"
         endif

         // Carriage return etc
         ?

         // Next
         select SM3DEKK
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dekkingslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Mating file was not created!")
         endif
      else

         // Display note on the screen
         //if cLanType() == "A"
         //   nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
         //   if left(cFile,1) $ "AB"
         //      // Disk
         //      //             "         0         0         0         0         0"
         //      @11, nBoxc say "'n Lˆer met die naam M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
         //      @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
         //      @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
         //      @14, nBoxc say "die betrokke Registrerende Owerheid."
         //   else
         //      // File
         //      //             "         0         0         0         0         0"
         //       @11, nBoxc say "'n Lˆer met die naam M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is in die"
         //       @12, nBoxc say cMailTar()+" subgids op die"
         //       @13, nBoxc say "hardeskyf geskryf!"
         //       @14, nBoxc say "Heg asseblief hierdie lˆer aan 'n epos boodskap"
         //       @15, nBoxc say "gerig aan die betrokke Registrerende Owerheid."
         //    endif
         //    fScrBood(maxrow()-1,"Dekkingslˆer is suksesvol geskep!")
         // else
         //    nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
         //    if left(cFile,1) $ "AB"
         //       // Disk
         //       //             "         0         0         0         0         0"
         //       @11, nBoxc say "A file with the name M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
         //       @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
         //       @13, nBoxc say "Package this diskette properly and post to the"
         //       @14, nBoxc say "the relative Registering Authority."
         //    else
         //       // File
         //       //             "         0         0         0         0         0"
         //       @11, nBoxc say "A file with the name M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created in the"
         //       @12, nBoxc say cMailTar()+" subdirectory of the"
         //       @13, nBoxc say "hard disk!"
         //       @14, nBoxc say "Attach this file to an email message addressed"
         //       @15, nBoxc say "to the relative Registering Authority."
         //    endif
         //    fScrBood(maxrow()-1,"File containing matings was succesfully created!")
         // endif

         // Display note on the screen for removable medium
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Dekkingslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name M"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing matings was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Dekkings epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Mating email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Dekkingskennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Dekkingskennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile + chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van dekkings vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Mating Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Mating Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic mating notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt")

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskIris

   // Program to create electronic matings file for Iris
   // According to EDV20130424.PDF at Downloads/Studbook
   // 13-04-25 10:08

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nHdel := 0
   local cStr  := ""
   local cData := ""
   local i     := 0
   local nLen  := 0
   local cIcar := ""
   local nBoxc := 0
   local nMfil := 0
   local nSeqn := 0
   local cSeqn := ""

   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      nSeqn := STDWAAR->elecsq + 1
      if nSeqn > 999
         nSeqn := 1
      endif
      do while !rlock()
      enddo
      STDWAAR->elecsq := nSeqn
      cSeqn := right("00"+alltrim(str(nSeqn)),3)

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Set the relationship
      select SM3DEKK
      //set relation to IDMOER into SM3DATA
      go top

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dekkingslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Matings file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Dekkingslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create matings file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Dekkingslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to matings file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Start writing the data to the file

      // Write the data
      select SM3DEKK
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Header
         cStr := "M"                             //1
         cStr += substr(alltrim(cIcar),1,3)      // Breed code
         cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cStr += "S"
         cStr += cSeqn
         cStr += padr("SM"+alltrim(cVersion()),10) // Version number
         cStr += "SERV"                          // Document code
         cStr += "C"                             // Action type

         // Header replaced on 14-02-11 09:14
         // Header
         //cStr := padl(dtos(date())+substr(time(),1,2)+substr(time(),4,2),15,"0") //Batch number
         //cStr += padr("SM"+cVersion(),10)        // Version number
         //cStr += "SERV"                          // Document code
         //cStr += "C"                             // Action type

         // Service Type
         if SM3DEKK->vaarkode $ "34"             // Service code
            cStr += "A"                          // Action type
         else
            cStr += "N"                          // Action type
         endif

         // Dam participant number
         cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cStr += alltrim(cIcar)                  // Breed code

         // Seek the cow in main file
         Select SM3DATA
         seek SM3DEKK->idmoer

         // Dam computer number
         cStr += padl(alltrim(SM3DATA->reknr),10,"0") // Computer number

         // Dam Id number
         cStr += alltrim(cIcar)                  // Breed code
         cStr += "F"
         cStr += fId(SM3DATA->idnr,.t.)

         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar

            cStr += space(10)                    // Participant number
            cStr += space(10)                    // Computer number
            cStr += space(14)                    // Id number

         else

            // Sire participant number
            cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
            cStr += alltrim(cIcar)               // Breed code

            // Seek the sire in main file
            Select SM3DATA
            seek SM3DEKK->idvaar

            // Sire computer number
            cStr += padl(alltrim(SM3DATA->reknr),10,"0") // Computer number

            // Sire Id number
            cStr += alltrim(cIcar)               // Breed code
            cStr += "M"
            cStr += fId(SM3DATA->idnr,.t.)

         endif

         // Select mating file
         Select SM3DEKK

         // Date in
         cData := dtos(SM3DEKK->datumin)
         cStr += right(cData,2)
         cStr += substr(cData,5,2)
         cStr += left(cData,4)

         // Date out
         if SM3DEKK->vaarkode $ "34"             // Service code
            cStr += space(8)
         else
            if empty(SM3DEKK->datumuit)
               cData := dtos(SM3DEKK->datumin)
            else
               cData := dtos(SM3DEKK->datumuit)
            endif
            cStr += right(cData,2)
            cStr += substr(cData,5,2)
            cStr += left(cData,4)
         endif

         // End of line
         cStr += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStr)

         if nLen != len(cStr)
            fScrWBood(maxrow(),"File Write Error : "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3DEKK
         skip

      enddo

      // Close the file
      fclose(nHdel)

      // Test if file was created
      if !file(cFile)

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dekkingslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Matings file was not created!")
         endif

      else

         // Display note on the screen for removable medium
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Dekkingslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing matings was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Dekkings epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Matings email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Dekkings Kennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Dekkings Kennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile + chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van dekkings vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Matings Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Matings Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic mating notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fCsvIris

   // Program to create electronic matings file for Iris
   // According to EDV20130424.PDF at Downloads/Studbook
   // 15-04-02 11:32

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nHdel := 0
   local cStr  := ""
   local cData := ""
   local i     := 0
   local nLen  := 0
   local cIcar := ""
   local nBoxc := 0
   local nMfil := 0
   local nSeqn := 0
   local cSeqn := ""

   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      nSeqn := STDWAAR->elecsq + 1
      if nSeqn > 999
         nSeqn := 1
      endif
      do while !rlock()
      enddo
      STDWAAR->elecsq := nSeqn
      cSeqn := right("00"+alltrim(str(nSeqn)),3)

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Set the relationship
      select SM3DEKK
      //set relation to IDMOER into SM3DATA
      go top

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".CSV"
      else
         cFile := cMailTar()+"M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".CSV"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dekkingslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Matings file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Dekkingslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create matings file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Dekkingslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to matings file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Start writing the data to the file

      // Write the data
      select SM3DEKK
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Header
         cStr := "M"                             //1
         cStr += "," + substr(alltrim(cIcar),1,3)      // Breed code
         cStr += "," + padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cStr += "," + "S"
         cStr += "," + cSeqn
         cStr += "," + padr("SM"+alltrim(cVersion()),10) // Version number
         cStr += "," + "SERV"                          // Document code
         cStr += "," + "C"                             // Action type

         // Header replaced on 14-02-11 09:14
         // Header
         //cStr := padl(dtos(date())+substr(time(),1,2)+substr(time(),4,2),15,"0") //Batch number
         //cStr += padr("SM"+cVersion(),10)        // Version number
         //cStr += "SERV"                          // Document code
         //cStr += "C"                             // Action type

         // Service Type
         if SM3DEKK->vaarkode $ "34"             // Service code
            cStr += "," + "A"                          // Action type
         else
            cStr += "," + "N"                          // Action type
         endif

         // Dam participant number
         cStr += "," + padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cStr += "," + alltrim(cIcar)                  // Breed code

         // Seek the cow in main file
         Select SM3DATA
         seek SM3DEKK->idmoer

         // Dam computer number
         cStr += "," + padl(alltrim(SM3DATA->reknr),10,"0") // Computer number

         // Dam Id number
         cStr += "," + alltrim(cIcar)                  // Breed code
         cStr += "," + "F"
         cStr += "," + fId(SM3DATA->idnr,.t.)

         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar

            cStr += "," + space(10)                    // Participant number
            cStr += "," + space(10)                    // Computer number
            cStr += "," + space(14)                    // Id number

         else

            // Sire participant number
            cStr += "," + padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
            cStr += "," + alltrim(cIcar)               // Breed code

            // Seek the sire in main file
            Select SM3DATA
            seek SM3DEKK->idvaar

            // Sire computer number
            cStr += "," // + padl(alltrim(SM3DATA->reknr),10,"0") // Computer number

            // Sire Id number
            cStr += "," + alltrim(cIcar)               // Breed code
            cStr += "," + "M"
            cStr += "," + fId(SM3DATA->idnr,.t.)

         endif

         // Select mating file
         Select SM3DEKK

         // Date in
         cData := dtos(SM3DEKK->datumin)
         cStr += "," + right(cData,2)
         cStr += "," + substr(cData,5,2)
         cStr += "," + left(cData,4)

         // Date out
         if SM3DEKK->vaarkode $ "34"             // Service code
            cStr += "," + space(8)
         else
            if empty(SM3DEKK->datumuit)
               cData := dtos(SM3DEKK->datumin)
            else
               cData := dtos(SM3DEKK->datumuit)
            endif
            cStr += "," + right(cData,2)
            cStr += "," + substr(cData,5,2)
            cStr += "," + left(cData,4)
         endif

         // End of line
         cStr += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStr)

         if nLen != len(cStr)
            fScrWBood(maxrow(),"File Write Error : "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3DEKK
         skip

      enddo

      // Close the file
      fclose(nHdel)

      // Test if file was created
      if !file(cFile)

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dekkingslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Matings file was not created!")
         endif

      else

         // Display note on the screen for removable medium
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Dekkingslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name M"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing matings was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Dekkings epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Matings email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Dekkings Kennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Dekkings Kennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile + chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van dekkings vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Matings Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Matings Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic mating notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
