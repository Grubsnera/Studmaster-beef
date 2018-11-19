//SM3DEKU.PRG
//Program om volledige deklyste te druk
//Kopiereg (c) 1992 A van Rensburg
//13:23 10 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

//**************************************************************************/
FUNCTION sm3deku(nTop,nLeft,nBott,aSend,cFind)

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cDeku := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := NIL
   local cFilt := ""
   local cTGrp := ""
   local cIdnr := ""

   private cData := ""
   private cHead := ""

   //Verklaar - private standaardveranderlikes
   private nOudeer := 365
   private nRustyd := 30
   private nNordra := 274
   private nMindra := 266
   private nMakdra := 308
   private nSiklus := 21
   private nDaedra := 60
   private cKalfst := "01"
   private cKalfge := "09"
   private cIdenti := "16  "
   private cSubafd := "  "
   private cTipies := "  "
   private cBreekk := "-"

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   //Dekwaardes word opgesoek
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Standaardwaardes word gelees")
   else
      fScrWbood(24,"Default values being read")
   endif
   cDeku := fTOpen(cDd(),"sm3rass",,,,.t.,.f.)
   if left(cDeku,1) == "f"
      return NIL
   endif
   locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
   if !eof()
      nOudeer := SM3RASS->oudeer
      nRustyd := SM3RASS->rustyd
      nNordra := SM3RASS->nordra
      nMindra := SM3RASS->mindra
      nMakdra := SM3RASS->makdra
      nSiklus := SM3RASS->siklus
      nDaedra := SM3RASS->daedra
      cKalfst := SM3RASS->kalfst
      cKalfge := SM3RASS->kalfge
      cIdenti := SM3RASS->identi
      cSubafd := SM3RASS->subafd
      cTipies := SM3RASS->tipies
      cBreekk := SM3RASS->breekk
   endif
   fTClose(cDeku)

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3deku","merkkk"})
      if cLanType() == "A"
         aadd(aSend,{"sm3deku","beskry"})
      else
         aadd(aSend,{"sm3deku","descri"})
      endif
      if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
         aadd(aSend,{"sm3deku","sortee"})
         aadd(aSend,{"sm3deku","verand"})
      endif
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cDeku := fTOpen(,"sm3deku",,"tdb",,.f.,.f.)
   if left( cDeku, 1 ) == "f"
      return cRetu
   endif

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "KUDDE DEKKINGS AKTIWITEITE" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "HERD MATING ACTIVITIES" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu  [+]=Merk een  [-]=Verwyder een merk  [Alt P]=Druk gemerktes")
         fScrBood( 24, "[Enter]=Vertoon  [*]=Merk almal  [/]=Verwyder alle merke  [Alt-F]=Filter ")
      else
         fScrBood( 23, "[ Esc ]=Menu  [+]=Mark one  [-]=Remove one mark  [Alt-P]=Print all marked")
         fScrBood( 24, "[Enter]=Display  [*]=Mark all    [/]=Remove all marks   [Alt-F]=Filter   ")
      endif

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ENTER
         //Enter means display
         //Create file with animals selected
         if cLanType() == "A"
            if !fCreate(SM3DEKU->beskry,SM3DEKU->verand,SM3DEKU->sortee,cFilt)
               fScrBood(23,"Geen diere is gevind om te vertoon nie!")
               fScrWait(24)
               loop
            endif
            //Vertoon diere
            fDisplay(SM3DEKU->beskry,cTGrp,cIdnr)
         else
            if !fCreate(SM3DEKU->descri,SM3DEKU->verand,SM3DEKU->sortee,cFilt)
               fScrBood(23,"No animals found to display!")
               fScrWait(24)
               loop
            endif
            //Vertoon diere
            fDisplay(SM3DEKU->descri,cTGrp,cIdnr)
         endif

      elseif nKeyp == K_PLUS
         //Plus means mark
         if SM3DEKU->merkkk == " "
            SM3DEKU->merkkk := chr(251)
         else
            SM3DEKU->merkkk := " "
         endif
         bBrow:refreshcurrent()

      elseif nKeyp == K_MINUS
         //Minus means unmark
         if SM3DEKU->merkkk == " "
         else
            SM3DEKU->merkkk := " "
         endif
         bBrow:refreshcurrent()

      elseif nKeyp == K_MULTIPLY
         //Multiply means mark all
         replace all SM3DEKU->merkkk with chr(251)
         go top
         bBrow:refreshall()

      elseif nKeyp == K_DIVIDE
         //Minus means unmark all
         replace all SM3DEKU->merkkk with " "
         go top
         bBrow:refreshall()

      elseif nKeyp == K_INS .and. (upper(left(cGebNaam(), 16)) == "6003295079089JNR" .or. ;
            upper(left(cGebNaam(), 16)) == "5302265054085SSC")
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fACdeku()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E .and. (upper(left(cGebNaam(), 16)) == "6003295079089JNR" .or. ;
            upper(left(cGebNaam(), 16)) == "5302265054085SSC")
         //Alt E means change a record
         if fACdeku()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL .and. (upper(left(cGebNaam(), 16)) == "6003295079089JNR" .or. ;
            upper(left(cGebNaam(), 16)) == "5302265054085SSC")
         //Delete means delete a record
         if fDelete(aRecv)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_F
         // Alt F means set a filter
         fFilter(@cFilt,@cTGrp,@cIdnr)
         bBrow:refreshall()

      elseif nKeyp == K_ALT_P
         //Alt P means print
         go top
         do while !eof()

            //Net gemerkte diere
            if SM3DEKU->merkkk == chr(251)
            else
               select SM3DEKU
               skip
               loop
            endif

            if cLanType() == "A"
               //Create file with animals selected
               if !fCreate(SM3DEKU->beskry,SM3DEKU->verand,SM3DEKU->sortee,cFilt)
                  select SM3DEKU
                  skip
                  loop
               endif

               //Open files and print
               if !fPrepare(SM3DEKU->beskry,cTGrp,cIdnr)
                  select SM3DEKU
                  go bottom
               endif
            else
               //Create file with animals selected
               if !fCreate(SM3DEKU->descri,SM3DEKU->verand,SM3DEKU->sortee,cFilt)
                  select SM3DEKU
                  skip
                  loop
               endif

               //Open files and print
               if !fPrepare(SM3DEKU->descri,cTGrp,cIdnr)
                  select SM3DEKU
                  go bottom
               endif
            endif

            //Volgende
            select SM3DEKU
            skip

         enddo
         go top
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cDeku)
   fTClose(cCdbf)
return cRetu

/*************************************************************************/
STATIC FUNCTION fACdeku(aRecv)

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxc    := 0
   local aSend    := {}
   local lLoop    := .t.
   local lReturn  := .f.
   local i        := 0
   local nLoop    := 0
   local nRekord  := 0
   local aDbfs    := {}
   local cSearch  := ""
   local nLine    := 0

   private aData
   private cData

   //Kry die velde benodig
   if aRecv == NIL
      aadd(aSend,{"sm3deku","merkkk"})
      aadd(aSend,{"sm3deku","beskry"})
      aadd(aSend,{"sm3deku","descri"})
      aadd(aSend,{"sm3deku","sortee"})
      aadd(aSend,{"sm3deku","verand"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE AKSIE")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW ACTION")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER AKSIE")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT ACTION")
      endif
   endif

   //Vul met data en vertoon

   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i][13] )
   next

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Vra die velde
            //Skerm
            //Read
            @nLine+ 1,nBoxc say aRecv[ 1][6] get aRecv[ 1][14] pict aRecv[ 1][10]
            @nLine+ 2,nBoxc say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10]
            @nLine+ 3,nBoxc say aRecv[ 3][6] get aRecv[ 3][14] pict aRecv[ 3][10]
            @nLine+ 4,nBoxc say aRecv[ 4][6] get aRecv[ 4][14] pict aRecv[ 4][10]
            @nLine+ 5,nBoxc say aRecv[ 5][6] get aRecv[ 5][14] pict aRecv[ 5][10]
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
            //Gaan na rekord
            if nRekord > 0
               goto nRekord
            else
               dbAppend()
            endif
            //Lock
            do while !rlock()
            enddo
            //Bewaar
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i][13], aRecv[i][14] )
            next
            commit
            if nRekord == 0
               nRekord := recno()
               //Maak rekord skoon
               go bottom
               skip
               for i = 1 to len( aRecv )
                  aRecv[i][14] := fieldget( aRecv[i][13] )
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
   restscreen(0,0,24,79,cCurSke)
return lReturn

//*************************************************************************/
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde "+alltrim(aRecv[2][6])+" geskrap word?"
   else
      cBood := "Should above-mentioned "+alltrim(aRecv[2][6])+" be deleted?"
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

/******************************************************************************/
STATIC FUNCTION fFilter (cFilter,cTGrp,cIdnr)

   // Function to display only selected records

   // Declare
   LOCAL lRetu := FALSE
   LOCAL aCscr := fASaveScr()
   LOCAL nBoxc := 0
   LOCAL getlist := {}

   BEGIN SEQUENCE

      cFilter := ""
      cTGrp := SPACE(6)
      cIdnr := SPACE(12)

      // The screen
      IF cLanType() == "A"
         nBoxc := fBoxCent(10,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",4,"Filter")
         @11,nBoxc SAY "              Kalfseisoen ?" get cTGrp pict "@!"
         @12,nBoxc SAY "Gedek deur bul (Id nommer)?" get cIdnr pict "@!"
      ELSE
         nBoxc := fBoxCent(10,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",4,"Filter")
         @11,nBoxc SAY "      Calving season ?" get cTGrp pict "@!"
         @12,nBoxc SAY "Served by bull (Idnr)?" get cIdnr pict "@!"
      ENDIF

      // The read
      setcursor(1)
      read
      setcursor(0)

      // Escaped
      IF LASTKEY() == K_ESC
         BREAK
      ENDIF

      // Build the search array
      IF !EMPTY(cTGrp)
         cFilter += "ALLTRIM(SM3DATA->teelgroep) == '"+UPPER(ALLTRIM(cTGrp))+"' .AND. "
      ENDIF

      IF !EMPTY(cIdnr)
         cFilter += "ALLTRIM(SM3DATA->bulid) == '"+UPPER(ALLTRIM(cIdnr))+"' .AND. "
      ENDIF

      // If no search
      IF EMPTY(cFilter)
         BREAK
      ENDIF

      // Remove the last and from the search string
      IF right(cFilter,7) == " .AND. "
         cFilter := LEFT(cFilter,LEN(cFilter)-7)
      ENDIF

      // Set the filter
      lRetu := TRUE
   END

   // Reset
   fARestScr(aCscr)

RETURN lRetu

//***************************************************************************/
STATIC FUNCTION fcreate(cBood,cVera,cSort,cFilter)

   //Funksie om leer te skep met die nodige diere

   //Verklaar
   local lRetu := .t.
   local cCscr := savescreen(23,0,24,79)
   local cCdbf := fTOpen()
   local cFile := ""
   local cHoof := ""
   local cIndf := cDd()+"sm3tydd"+ordbagext()
   local nData := 0
   local bTest := NIL
   private cTest := alltrim(cVera)
   private cInde := alltrim(cSort)

   //Waardes
   if !empty(cVera)
      bTest := &("{||"+cVera+"}")
   else
      bTest := &("{||!empty(SM3DATA->idnr)}")
   endif

   if EMPTY(cInde)
      cInde := "teelgroep+idnr"
   endif

   ferase(cDd()+"sm3tydd"+ordbagext())

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif

   //Open die hoofleer
   cHoof := fTOpen(cDd(),"sm3data")
   if left(cHoof,1) == "f"
      lRetu := .f.
      fTClose(cCdbf)
      restscreen(23,0,24,79,cCscr)
      return lRetu
   endif
   ordsetfocus("SM3ZVRO")

   //Open die tydelike leer
   cFile := fTOpen(cDd(),"sm3tydd",,,,.f.)
   if left(cFile,1) == "f"
      lRetu := .f.
      fTClose(cHoof)
      fTClose(cCdbf)
      restscreen(23,0,24,79,cCscr)
      return lRetu
   endif

   //Clear file
   zap

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,alltrim(cBood)+" word uitgesoek")
   else
      fScrWbood(24,alltrim(cBood)+" being sorted")
   endif
   select SM3DATA
   go top
   do while !eof()
      if eval(bTest)
         if ! EMPTY(cFilter)
            if &cFilter
               select SM3TYDD
               append blank
               SM3TYDD->idnr      := SM3DATA->idnr
               SM3TYDD->teelgroep := SM3DATA->teelgroep

               //Bereken ouderdom in maande
               nData := (dAppDate() - SM3DATA->gebdatum) / 30.4375
               if nData > 0 .and. nData <= 9999
                  SM3TYDD->ouderd := nData
               endif

               //Bereken dae laas gedek
               nData := dAppDate() - SM3DATA->dekdat
               if nData > 0 .and. nData <= 9999
                  SM3TYDD->daedek := nData
               endif

               //Bereken dae laas gelam
               nData := dAppDate() - SM3DATA->lkalfdatum
               if nData > 0 .and. nData <= 9999
                  SM3TYDD->daelam := nData
               endif

               //Bereken verwagte kalfdatums
               if SM3DATA->dekdat <> ctod("")
                  SM3TYDD->siklus := SM3DATA->dekdat + nSiklus
                  SM3TYDD->onders := SM3DATA->dekdat + nDaedra
                  SM3TYDD->lamdat := SM3DATA->dekdat + nNordra
               endif

               select SM3DATA
            endif
         else
            select SM3TYDD
            append blank
            SM3TYDD->idnr      := SM3DATA->idnr
            SM3TYDD->teelgroep := SM3DATA->teelgroep

            //Bereken ouderdom in maande
            nData := (dAppDate() - SM3DATA->gebdatum) / 30.4375
            if nData > 0 .and. nData <= 9999
               SM3TYDD->ouderd := nData
            endif

            //Bereken dae laas gedek
            nData := dAppDate() - SM3DATA->dekdat
            if nData > 0 .and. nData <= 9999
               SM3TYDD->daedek := nData
            endif

            //Bereken dae laas gelam
            nData := dAppDate() - SM3DATA->lkalfdatum
            if nData > 0 .and. nData <= 9999
               SM3TYDD->daelam := nData
            endif

            //Bereken verwagte kalfdatums
            if SM3DATA->dekdat <> ctod("")
               SM3TYDD->siklus := SM3DATA->dekdat + nSiklus
               SM3TYDD->onders := SM3DATA->dekdat + nDaedra
               SM3TYDD->lamdat := SM3DATA->dekdat + nNordra
            endif

            select SM3DATA
         endif
      endif
      skip

   enddo
   go top
   select SM3TYDD

   //Kyk of daar diere bestaan
   if lastrec() <= 0
      lRetu := .f.
   else
      //Sorteer
      if len(cInde) > 0
         index on &cInde to (cIndf)
         set inde to (cIndf)
      endif
   endif

   //Herstel
   fTClose(cFile)
   fTClose(cHoof)
   fTClose(cCdbf)
   restscreen(23,0,24,79,cCscr)

return lRetu

//***************************************************************************/
STATIC FUNCTION fdisplay(cBood,cTGrp,cIdnr)

   //Funksie om leer met uitgesoekte diere te vertoon

   //Verklaar
   local lRetu := .t.
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cFile := ""
   local cHoof := ""
   local cIndf := cDd()+"sm3tydd"+ordbagext()

   //Verklaar skerm
   local aSend := {}
   local aRecv := {}
   local i     := 1
   local cHead := ""
   local aCols := {}
   local bBrow := NIL
   local lMore := .t.
   local nKeyp := 0
   LOCAL nRigh := 0
   LOCAL nLeft := 4
   LOCAL nTopp := 4
   LOCAL nBott := MAXROW()-4
   LOCAL cCoun := ""
   LOCAL nScrl := 0
   private cData := ""

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aadd(aSend,{"sm3tydd","idnr"})
   aadd(aSend,{"sm3data","geslag"})
   aadd(aSend,{"sm3data","generasie"})
   aadd(aSend,{"sm3data","dekdat"})
   aadd(aSend,{"sm3data","tipede"})
   aadd(aSend,{"sm3data","teelgroep"})
   aadd(aSend,{"sm3data","bulid"})
   aadd(aSend,{"sm3data","dragda"})
   aadd(aSend,{"sm3data","dragti"})
   aadd(aSend,{"sm3data","lkalfdatum"})
   aadd(aSend,{"sm3data","lkalfn"})
   aadd(aSend,{"sm3tydd","daelam"})
   aadd(aSend,{"sm3tydd","siklus"})
   aadd(aSend,{"sm3tydd","lamdat"})
   aRecv := fGetField( aSend )

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif

   //Open die hoofleer
   cHoof := fTOpen(cDd(),"sm3data")
   if left(cHoof,1) == "f"
      lRetu := .f.
      fTClose(cCdbf)
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Open die tydelike leer
   cFile := fTOpen(cDd(),"sm3tydd",,,,.f.)
   if left(cFile,1) == "f"
      lRetu := .f.
      fTClose(cHoof)
      fTClose(cCdbf)
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Set relation
   set relation to SM3TYDD->idnr into SM3DATA

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      nScrl := nScrl + aRecv[i,FLD_LENG] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   // Calculate right hand column
   nRigh := IF(nLeft+nScrl > MAXCOL()-3, MAXCOL()-3, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox(nTopp, nLeft, nBott, nRigh, alltrim(cBood))
   else
      fBox(nTopp, nLeft, nBott, nRigh, alltrim(cBood))
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   // Calculate right hand column
   nRigh := IF(nLeft+nScrl > MAXCOL()-3, MAXCOL()-3, nLeft+nScrl )

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood(23)
         fScrBood(24,"[Esc]=Vorige skerm  [Alt P]=Druk" )
      else
         fScrBood(23)
         fScrBood(24,"[Esc]=Previous screen  [Alt P]=Print" )
      endif

      //Freeze
      bBrow:freeze := 2

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      // Display the record number
      cCoun := PADL(LTRIM(STR(CMXKEYNO()))+"/"+LTRIM(STR(CMXKEYCOUNT())),15,CHR(205))
      @nBott,nRigh-(LEN(cCoun)+1) SAY cCoun

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecv,cBood,cTGrp,cIdnr)
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   fTClose(cFile)
   fTClose(cHoof)
   fTClose(cCdbf)
   restscreen(0,0,24,79,cCscr)
return lRetu

//***************************************************************************/
STATIC FUNCTION fPrepare(cBood,cTGrp,cIdnr)

   //Funksie om leers te open

   //Verklaar
   local lRetu := .t.
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cFile := ""
   local cHoof := ""
   local cIndf := cDd()+"sm3tydd"+ordbagext()
   local aSend := {}
   local aRecv := {}

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aadd(aSend,{"sm3tydd","idnr"})
   aadd(aSend,{"sm3data","geslag"})
   aadd(aSend,{"sm3data","generasie"})
   aadd(aSend,{"sm3data","dekdat"})
   aadd(aSend,{"sm3data","tipede"})
   aadd(aSend,{"sm3data","teelgroep"})
   aadd(aSend,{"sm3data","bulid"})
   aadd(aSend,{"sm3data","dragda"})
   aadd(aSend,{"sm3data","dragti"})
   aadd(aSend,{"sm3data","lkalfdatum"})
   aadd(aSend,{"sm3data","lkalfn"})
   aadd(aSend,{"sm3tydd","daelam"})
   aadd(aSend,{"sm3tydd","siklus"})
   aadd(aSend,{"sm3tydd","lamdat"})
   aRecv := fGetField( aSend )

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")

   endif

   //Open die hoofleer
   cHoof := fTOpen(cDd(),"sm3data")
   if left(cHoof,1) == "f"
      lRetu := .f.
      fTClose(cCdbf)
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Open die tydelike leer
   cFile := fTOpen(cDd(),"sm3tydd",,,,.f.)
   if left(cFile,1) == "f"
      lRetu := .f.
      fTClose(cHoof)
      fTClose(cCdbf)
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Set relation
   set relation to SM3TYDD->idnr into SM3DATA

   //Druk die groep
   if !fPrint(aRecv,cBood,cTGrp,cIdnr)
      lRetu := .f.
   endif

   //Herstel
   fTClose(cFile)
   fTClose(cHoof)
   fTClose(cCdbf)
   restscreen(0,0,24,79,cCscr)
return lRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aRecv,cHdln,cTGrp,cIdnr)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local lRetu := .t.
   local cText := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local cHdl2 := ""

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      lRetu := .f.
      return lRetu
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   select SM3TYDD
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3tydd","idnr"})
      aadd(aSend,{"sm3data","generasie"})
      aadd(aSend,{"sm3data","gebdatum"})
      aadd(aSend,{"sm3tydd","ouderd"})
      aadd(aSend,{"sm3data","dekdat"})
      aadd(aSend,{"sm3data","tipede"})
      aadd(aSend,{"sm3data","teelgroep"})
      aadd(aSend,{"sm3data","bulid"})
      aadd(aSend,{"sm3tydd","daedek"})
      aadd(aSend,{"sm3data","lkalfdatum"})
      aadd(aSend,{"sm3data","lkalfn"})
      aadd(aSend,{"sm3tydd","daelam"})
      aadd(aSend,{"sm3tydd","lamdat"})
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Bepaal die drukgrootte
   nWidt := 0
   for nI = 1 to len(aRecv)
      nWidt+= aRecv[nI][4]+1
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
   cHdln := UPPER(ALLTRIM(cHdln))

   //Skerm
   if cLanType() == "A"
      fScrbood(24,alltrim(cHdln)+" word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,alltrim(cHdln)+" being printed!  [Esc]=Stop printer.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := .t.
   do while lLoop

      //Opskrifte
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
            if ! EMPTY(cTGrp)
               cHdl2 := "Kalfseisoen: "+ALLTRIM(cTGrp)
               @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
            endif
            if ! EMPTY(cIdnr)
               cHdl2 := "Gedek deur bul: "+ALLTRIM(cIdnr)
               @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
            endif

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
            if ! EMPTY(cTGrp)
               cHdl2 := "Calving season: "+ALLTRIM(cTGrp)
               @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
            endif
            if ! EMPTY(cIdnr)
               cHdl2 := "Served by bull: "+ALLTRIM(cIdnr)
               @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
            endif
         endif

         @prow()+1,  1 say repl( "=",  nWidt )

         //1e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //2e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //3e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //4e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + repl("-",aRecv[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lRetu := .f.
         lLoop := .f.
         exit
      endif

      //Data

      cData := ""
      for nI = 1 to len( aRecv )
         //Kies die regte leer
         cText := aRecv[nI][1]
         cText := strtran(cText,"->")
         cText := alltrim(cText)
         select select(cText)
         //Berei data voor
         do case
            case aRecv[nI][3] == "C"
               //Character
               cData+= fieldget(aRecv[nI,13]) + " "
            case aRecv[nI][3] == "N"
               //Numeric
               cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
            case aRecv[nI][3] == "D"
               //Date
               cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI][4])+" "
         endcase
      next
      @prow()+1,1 say padr(cData, nWidt)
      select SM3TYDD

      //Skerm
      // fPrnOff()
      // if nTota > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
      //    else
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
      //    endif
      //    setcolor( cColNorm() )
      //    nReko++
      // endif
      // fPrnOn()

      //Volgende rekord
      select SM3TYDD
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         if EOF()
            @prow()+1,  1 say repl( "-",  nWidt )
            if cLanType() == "A"
               @prow()+1,1 SAY "Diere in groep = "+ALLTRIM(STR(nTota))
            else
               @prow()+1,1 SAY "Animals in group = "+ALLTRIM(STR(nTota))
            endif
         endif

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         nBlad++

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   go top
return lRetu

