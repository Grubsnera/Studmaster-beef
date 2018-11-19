//SM3DEKV.PRG
//Program om dekinligting te verander
//Kopiereg (c) 1992 A van Rensburg
//14:40 28 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION sm3dekv(nTop,nLeft,nBottom,aSend,cFind)

   //Veranderlikes
   local cFile   := ""                           //Status of opened file
   local cHoof   := ""
   local aRecv   := {}                           //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nRight  := 77                           //Regterkantste lyn
   local bBrowse := NIL                          //Browse object
   local aColumn := {}                           //Kolomme array
   local i       := 0                            //Counter
   local lMore   := .t.                          //Logical looper
   local nKey    := 0                            //Keypress
   local cResult := cFind                        //Return value
   local cLocate := ""
   local cLocScr := ""
   local nBoxCoor := 0
   local getlist := {}
   local cBrep := ""

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
      aadd(aSend,{"sm3dekk","idmoer"})
      aadd(aSend,{"sm3dekk","teelgroep"})
      aadd(aSend,{"sm3dekk","vaarkode"})
      aadd(aSend,{"sm3dekk","idvaar"})
      aadd(aSend,{"sm3dekk","datumin"})
      aadd(aSend,{"sm3dekk","datumuit"})
      aadd(aSend,{"sm3dekk","dragtig"})
      aadd(aSend,{"sm3dekk","dragwe"})
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
   cHoof := fTOpen(cDd(),"sm3data", , , , .t., .f. )
   if left( cHoof, 1 ) == "f"
      return cResult
   endif
   cFile := fTOpen(cDd(),"sm3dekk", , , , .t., .f. )
   if left( cFile, 1 ) == "f"
      fTClose(cHoof)
      return cResult
   endif

   //Skuif die databasis
   if cFind == NIL
   else
      seek cFind
      if eof()
         go top
      endif
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
      fBox( nTop, nLeft, nBottom, nRight, "VERANDER DEKINLIGTING" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "EDIT MATING INFORMATION" )
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
         fScrBood( 23, "[Esc]  [Alt E ]  [Del]  [A-Z]  [F1]" )
         fScrBood( 24, " Menu  Verander  Skrap   Vind  Hulp" )
      else
         fScrBood( 23, "[Esc]  [Alt E]  [Del ]  [A-Z]  [F1]" )
         fScrBood( 24, " Menu   Edit    Delete   Find  Help" )
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

      elseif nKey == K_ALT_E
         //Alt E means change a record
         if fACdekv()
            bBrowse:refreshall()
         endif

      elseif nKey == K_ALT_F
         // Alt F means create electronic notofication
         cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
         if cBrep $ "JYjy"
            // Breedplan format
            if fDiskBrem()
               bBrowse:refreshall()
            endif
         endif

      elseif nKey == K_DEL
         //Delete means delete a record
         if fDelete()
            bBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3dekv",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122 .or. nKey >= 48 .and. nKey <= 57
         //Means locate a record
         cLocate := upper( chr( nKey ) ) + space(11)
         cLocScr := savescreen( 0, 0, 24, 79 )
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 11, "Vind watter koei? xxxxxxxxxxxx", 3 )
            @12, nBoxCoor say "Vind watter koei?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 11, "Find which cow? xxxxxxxxxxxx", 3 )
            @12, nBoxCoor say "Find which cow?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            set soft on
            seek cLocate
            if eof()
               go top
            endif
            set soft off
            bBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrowse, nKey)

      endif

   enddo

   //Herstel
   fTClose(cFile)
   fTClose(cHoof)
return cResult

/*************************************************************************/
STATIC FUNCTION fACdekv(aData)

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxCoor := 0
   local aSend    := {}
   local lLoop    := .t.
   local lReturn  := .f.
   local i        := 0
   local nLoop    := 0
   local nRekord  := 0
   local aDbfs    := {}
   local cSearch  := ""
   local nLine    := 0

   //Kry die velde benodig
   if aData == NIL
      asize( aSend, 0 )
      aadd(aSend,{"sm3dekk","idmoer"})
      aadd(aSend,{"sm3dekk","teelgroep"})
      aadd(aSend,{"sm3dekk","vaarkode"})
      aadd(aSend,{"sm3dekk","idvaar"})
      aadd(aSend,{"sm3dekk","datumin"})
      aadd(aSend,{"sm3dekk","datumuit"})
      aadd(aSend,{"sm3dekk","insem"})
      aadd(aSend,{"sm3dekk","opmerk"})
      aadd(aSend,{"sm3dekk","donor"})
      aData := fGetField( aSend )
   endif

   //Bou veranderlikes
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent(  4, space(60),  11, "NUWE VELD" )
      else
         nBoxCoor := fBoxCent(  4, space(60),  11, "NEW FIELD" )
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent(  4, space(60),  11, "VERANDER DEKINLIGTING" )
      else
         nBoxCoor := fBoxCent(  4, space(60),  11, "EDIT MATING INFORMATION" )
      endif
   endif

   //Vul met data en vertoon
   nLine := 4
   for i = 1 to len( aData )
      aData[i][14] := fieldget( aData[i][13] )
   next

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Vra die velde
            //Skerm
            //Read
            @nLine+ 1,nBoxCoor say aData[ 1][6] get aData[ 1][14] pict aData[ 1][10] valid(fIdmoer(aData))
            @nLine+ 2,nBoxCoor say aData[ 2][6] get aData[ 2][14] pict aData[ 2][10] valid(fKalfs(aData))
            @nLine+ 3,nBoxCoor say aData[ 3][6] get aData[ 3][14] pict aData[ 3][10] valid(aData[3][14]$"1234")
            @nLine+ 4,nBoxCoor say aData[ 4][6] get aData[ 4][14] pict aData[ 4][10] valid(fIdvaar(aData))
            @nLine+ 5,nBoxCoor say aData[ 5][6] get aData[ 5][14] pict aData[ 5][10] valid(fDatin(aData))
            @nLine+ 6,nBoxCoor say aData[ 6][6] get aData[ 6][14] pict aData[ 6][10] valid(fDatuit(aData)) when(if(aData[3][14]$"12",.t.,.f.))
            @nLine+ 7,nBoxCoor say aData[ 7][6] get aData[ 7][14] pict aData[ 7][10]
            @nLine+ 8,nBoxCoor say aData[ 8][6] get aData[ 8][14] pict aData[ 8][10]
            @nLine+ 9,nBoxCoor say aData[ 9][6] get aData[ 9][14] pict aData[ 9][10] valid(fIdsken(aData)) when(if(aData[3][14]$"4",.t.,.f.))
            set cursor on
            read
            set cursor off
            lReturn := .t.
            //Wat nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         otherwise
            //Bewaar rekord

            //Verwyder onnodige data
            if aData[3][14] $ "34"
               //Maak datuit selfde as datin
               aData[6][14] := aData[5][14]
            endif
            if aData[3][14] $ "123"
               //Verwyder skenker igv 123
               aData[9][14] := space(12)
            endif

            //Gaan na rekord
            if nRekord > 0
               goto nRekord
               //Toets besonderhede in hoofleer
               select SM3DATA
               seek aData[1][14]
               if !eof()
                  if SM3DATA->dekdat    == SM3DEKK->datumin   .and. ;
                        SM3DATA->tipede    == SM3DEKK->vaarkode  .and. ;
                        SM3DATA->bulid     == SM3DEKK->idvaar    .and. ;
                        SM3DATA->teelgroep == SM3DEKK->teelgroep
                     do while !rlock()
                     enddo
                     //Vervang met nuwe waardes
                     SM3DATA->dekdat    := aData[5][14]
                     SM3DATA->tipede    := aData[3][14]
                     SM3DATA->bulid     := aData[4][14]
                     SM3DATA->teelgroep := aData[2][14]
                  endif
               endif
               select SM3DEKK
            else
               dbAppend()
            endif
            //Lock
            do while !rlock()
            enddo
            //Bewaar
            for i = 1 to len( aData )
               //Bewaar die data
               fieldput( aData[i][13], aData[i][14] )
            next
            commit
            if nRekord == 0
               nRekord := recno()
               //Maak rekord skoon
               go bottom
               skip
               for i = 1 to len( aData )
                  aData[i][14] := fieldget( aData[i][13] )
               next
               goto nRekord
               nRekord := 0
               nLoop := 1
            else
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen( 0, 0, 24, 79, cCurSke )
return lReturn

//*************************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   if cLanType() == "A"
      fScrBood(23,trim(fieldget(1)))
      cBood := "Moet bogenoemde inskrywing geskrap word?"
   else
      fScrBood(23,trim(fieldget(2)))
      cBood := "Should above-mentioned entry be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
      do while !rlock()
      enddo
      delete
      skip
      if eof()
         go top
      endif
      lReturn := .t.
   endif

return lReturn

//*************************************************************************/
STATIC FUNCTION fIdmoer(aTest)

   //Toets die koeinommer

   //Verklaar
   local lRetu := .t.
   local cCurs := savescreen(23,0,24,79)

   //Id nommer moet bestaan
   if aTest[1][14] == space(12)
      if cLanType() == "A"
         fScrBood(23,"Koei id nommer is verpligtend!")
      else
         fScrBood(23,"Cow id number is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   else
      //Hoofdataleer
      select SM3DATA
      seek aTest[1][14]
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Koei id nommer is onbekend!")
         else
            fScrBood(23,"Cow id number is unknown!")
         endif
         fScrWait(24)
         lRetu := .f.
      else
         if SM3DATA->geslag <> "1"
            if cLanType() == "A"
               fScrBood(23,"Koei is op rekenaar as 'n manlike dier!")
            else
               fScrBood(23,"Cow is on computer as a male animal!")
            endif
            fScrWait(24)
            lRetu := .f.
         endif
      endif
      select SM3DEKK
   endif

   //Herstel
   restscreen(23,0,24,79)
return lRetu

//*************************************************************************/
STATIC FUNCTION fIdvaar(aTest)

   //Toets die bulnommer

   //Verklaar
   local lRetu := .t.
   local cCurs := savescreen(23,0,24,79)

   //Id nommer moet bestaan
   if aTest[4][14] == space(12)
      if cLanType() == "A"
         fScrBood(23,"Bul id nommer is verpligtend!")
      else
         fScrBood(23,"Bull id number is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   else
      //Hoofdataleer
      select SM3DATA
      seek aTest[4][14]
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Bul id nommer is onbekend!")
         else
            fScrBood(23,"Bull id number is unknown!")
         endif
         fScrWait(24)
         lRetu := .f.
      else
         if SM3DATA->geslag <> "2"
            if cLanType() == "A"
               fScrBood(23,"Bul is op rekenaar as 'n vroulike dier!")
            else
               fScrBood(23,"Bull is on computer as a female animal!")
            endif
            fScrWait(24)
            lRetu := .f.
         endif
      endif
      select SM3DEKK
   endif

   //Herstel
   restscreen(23,0,24,79)
return lRetu

//*************************************************************************/
STATIC FUNCTION fKalfs(aTest)

   //Toets die kalfseisoen

   //Verklaar
   local lRetu := .t.
   local cCurs := savescreen(23,0,24,79)
   local cFile := fTOpen()
   local cTeeg := ""

   //Id nommer moet bestaan
   if aTest[2][14] == space(6)
      if cLanType() == "A"
         fScrBood(23,"Kalfseisoen is verpligtend!")
      else
         fScrBood(23,"Calving season is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   else
      //Kalfseisoenleer
      cTeeg := fTOpen( cDd(), "sm3teeg", , "dbf", , .t., .f. )
      if left( cTeeg, 1 ) == "f"
      else
         seek aTest[2][14]
         if eof()
            if cLanType() == "A"
               fScrBood(23,"Kalfseisoen is onbekend!")
            else
               fScrBood(23,"Calving season is unknown!")
            endif
            fScrWait(24)
            lRetu := .f.
         endif
         select SM3DEKK
         fTClose(cTeeg)
      endif

   endif

   //Herstel
   fTClose(cFile)
   restscreen(23,0,24,79)
return lRetu

//*************************************************************************/
STATIC FUNCTION fDatin(aTest)

   //Toets die datum in

   //Verklaar
   local lRetu := .t.
   local cCurs := savescreen(23,0,24,79)

   //Id nommer moet bestaan
   if aTest[5][14] == ctod("")
      if cLanType() == "A"
         fScrBood(23,"Datum in / KI datum / Inovulasiedatum is verpligtend!")
      else
         fScrBood(23,"Date in / AI date / Inovulation date is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   endif

   //Herstel
   restscreen(23,0,24,79)
return lRetu

//*************************************************************************/
STATIC FUNCTION fDatuit(aTest)

   //Toets die datum uit

   //Verklaar
   local lRetu := .t.
   local cCurs := savescreen(23,0,24,79)

   //Id nommer moet bestaan
   if aTest[6][14] == ctod("") .and. aTest[3][14] $ "12"
      if cLanType() == "A"
         fScrBood(23,"Datum uit is verpligtend!")
      else
         fScrBood(23,"Date out is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   endif

   if aTest[6][14] <> ctod("") .and. aTest[3][14] $ "12" .and. aTest[6][14] < aTest[5][14]
      if cLanType() == "A"
         fScrBood(23,"Datum moet later as die datum in wees!")
      else
         fScrBood(23,"Date must be after the date in!")
      endif
      fScrWait(24)
      lRetu := .f.
   endif

   //Herstel
   restscreen(23,0,24,79)
return lRetu

//*************************************************************************/
STATIC FUNCTION fIdsken(aTest)

   //Toets die skenkerkoei

   //Verklaar
   local lRetu := .t.
   local cCurs := savescreen(23,0,24,79)

   //Id nommer moet bestaan
   if aTest[9][14] == space(12)
      if cLanType() == "A"
         fScrBood(23,"Skenker koei id nommer is verpligtend!")
      else
         fScrBood(23,"Donor cow id number is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   else
      //Hoofdataleer
      select SM3DATA
      seek aTest[9][14]
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Skenker koei id nommer is onbekend!")
         else
            fScrBood(23,"Donor cow id number is unknown!")
         endif
         fScrWait(24)
         lRetu := .f.
      else
         if SM3DATA->geslag <> "1"
            if cLanType() == "A"
               fScrBood(23,"Skenker koei is op rekenaar as 'n manlike dier!")
            else
               fScrBood(23,"Donor cow is on computer as a male animal!")
            endif
            fScrWait(24)
            lRetu := .f.
         endif
         if aTest[9][14] == aTest[1][14]
            if cLanType() == "A"
               fScrBood(23,"Skenker koei en ontvanger koei kan nie dieselfde wees nie!")
            else
               fScrBood(23,"Donor cow and recipient cow may not be the same animal!")
            endif
            fScrWait(24)
            lRetu := .f.
         endif
      endif
      select SM3DEKK
   endif

   //Herstel
   restscreen(23,0,24,79)
return lRetu

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
   local lRetu := .t.
   local nSire := 0
   local nMfil := 0
   local cStr := ""
   local nBoxc := 0
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

         // Test if there is data
         if val(SM3DATA->reknr) < 1 .or. empty(SM3DEKK->datumin) .or. nSire < 1
            // Next
            select SM3DEKK
            skip
            loop
         endif

         /*********************************************************************/
         // The actual write of the animal itself
         ?? "N"                                  // Always N
         ?? padr(ltrim(str(val(alltrim(substr(cTotNaam(),152,10))))),7) // Soc ident of herd

         // ?? padr(ltrim(str(val(SM3DATA->reknr))),19) // Computer number
         // 02-04-23 09:24

         ?? padr(fId(SM3DATA->idnr,.f.),19)  // Id number

         set cent on
         ??  strtran(dtoc(SM3DEKK->datumin),"/","") // Date in
         set cent off
         if SM3DEKK->vaarkode $ "34"             // Service code
            ?? "A"
         else
            ?? "N"
         endif

         // ?? padr(ltrim(str(nSire)),19) // Soc ident of herd
         // 02-04-23 09:27

         ?? padr(fId(SM3DEKK->idvaar,.f.),19)  // Id number

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
            fScrBood(maxrow()-1,"Dekkingsdatalˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Mating data file was not created!")
         endif
      else
         //if cLanType() == "A"
         //   fScrBood(maxrow()-1,"Dekkingsdata is suksesvol geskep!")
         //else
         //   fScrBood(maxrow()-1,"Mating data file was created succesfully!")
         //endif

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
      //fScrWait(maxrow())

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
