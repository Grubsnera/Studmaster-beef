//SM3VEIL.PRG
//Program om veilingskatalogus te druk
//Kopiereg (c) 1993 A van Rensburg
//20:20 22 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

#define CORMK 1
#define COWNP 2
#define COWNN 3
#define COWND 4
#define COWNM 5
#define COWNX 6
#define COWNK 7
#define COWNA 8
#define COWNB 9
#define COWNC 10
#define CSIRP 11
#define CSIRN 12
#define CSIRK 13
#define CSIRA 14
#define CSIRB 15
#define CSIRC 16
#define CDAMP 17
#define CDAMN 18
#define CDAMK 19
#define CDAMA 20
#define CDAMB 21
#define CDAMC 22

/****************************************************************************/
FUNCTION sm3veil( nTop, nLeft, nBott, aSend, nAuct )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local aCdbf := fATOpen()
   local nWatt := 1
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := TRUE
   local nKeyp := 0
   local nReko := 0
   local lIdnr := FALSE
   local nBoxc := 0
   local cAuct := ""
   local cCoun := ""
   local lBlup := .f.
   local lRegn := .t.
   local getlist := {}

   private cTest := ""
   private cData := ""
   private cHead := ""

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,21, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3veil","lotnom"   })
      aadd(aSend,{"sm3veil","idnr"     })
      aadd(aSend,{"sm3veil","katalo"   })
      aadd(aSend,{"sm3veil","geslag"   })
      aadd(aSend,{"sm3veil","gebdatum" })
      aadd(aSend,{"sm3data","generasie"})
      aadd(aSend,{"sm3data","idvaar"   })
      aadd(aSend,{"sm3data","idmoer"   })
      aadd(aSend,{"sm3veil","opmerk"   })
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

   aCdbf := fATOpen(aCdbf,cDd(),"SM3DATA",,,,FALSE)

   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      RETU NIL
   ENDIF

   // Activate catalogue data file
   DBSELECTAREA("SM3VEIL")
   ORDSETFOCUS(1)
   cAuct := PADL(ALLTRIM(STR(nAuct,5,0)),5,'0')
   CMFILTER("SM3VEIL->auctnumb == '"+cAuct+"'")
   SET RELATION TO SM3VEIL->idnr INTO SM3DATA
   DBGOTOP()

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

   //Skerm
   //Teken die box
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
      fBox( nTop, nLeft, nBott, nRigh, "VEILING No. "+ALLTRIM(STR(nAuct))+" KATALOGUS" )
   else
      fScrOpsk( ,"Option "+cOption())
      fBox( nTop, nLeft, nBott, nRigh, "SALE No. "+ALLTRIM(STR(nAuct))+" CATALOGUE" )
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

   // Freeze
   bBrow:freeze := 3

   // Main loop
   lMore := TRUE
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[Esc]=Menu   [Ins]=Nuwe       [A-Z]=Vind           [AltP]=Druk" )
         fScrBood( 24, "[Del]=Skrap  [AltE]=Verander  [AltR]=LotHernommer  [AltF]=Lˆer" )
      else
         fScrBood( 23, "[Esc]=Menu    [Ins]=New    [A-Z]=Find          [AltP]=Print" )
         fScrBood( 24, "[Del]=Delete  [AltE]=Edit  [AltR]=LotRenumber  [AltF]=File " )
      endif

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      // Display the record number
      cCoun := PADL(LTRIM(STR(CMKEYNO()))+"/"+LTRIM(STR(CMKEYCOUNT())),15,CHR(205))
      @nBott,nRigh-(LEN(cCoun)+1) SAY cCoun

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         //Indien dier gevra moet word
         if lIdnr
            lIdnr := FALSE
            keyboard chr(K_INS)
         endif
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := FALSE

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         if fAddAnim(cAuct)
            DBGOTOP()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fACveil(RECNO(),cAuct)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_F
         // Alt F means create file
         if fFile()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_R
         // Alt R means renumber lots
         if fLotReNumber()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete(aRecv)
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         if fPrintSelect()
            bBrow:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fATClose(aCdbf)
   cOption(-1)

return NIL

/******************************************************************************/
STATIC FUNCTION fACveil(nReko,cAuct)

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxc    := 0
   local nPos     := 0
   local aSend    := {}
   local aRecv    := {}
   local lReturn  := FALSE
   local i        := 0
   local nLoop    := 0
   local nLine    := 0
   local cGeslag  := ""
   local cGebdat  := ""

   private aData
   private cData

   nReko := IIF(EMPTY(nReko),0,nReko)

   //Kry die velde benodig
   aadd(aSend,{"sm3veil","idnr"    })
   aadd(aSend,{"sm3veil","lotnom"  })
   aadd(aSend,{"sm3veil","katalo"  })
   aadd(aSend,{"sm3veil","opmerk"  })
   aadd(aSend,{"sm3veil","headin"  })
   aRecv := fGetField(aSend)

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)

   if nReko = 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE VEILINGSDIER")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW AUCTION ANIMAL")
      endif

      //Vul met data en vertoon
      aRecv := fFillBlank(aRecv)
   else
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER VEILINGSDIER")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT AUCTION ANIMAL")
      endif

      //Vul met data en vertoon
      for i = 1 to len( aRecv )
         aRecv[i,14] := fieldget( aRecv[i,13] )
      next
   endif

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Vra die velde
            select SM3DATA
            if nReko = 0
               //Vul met data en vertoon
               aRecv := fFillBlank(aRecv)
               aRecv[1,14] := sm3idnr(aRecv[1,14],nLine+1,nBoxc,,,,,)
            else
               @nLine+1,nBoxc say aRecv[1,6]
               @nLine+1,nBoxc+LEN(aRecv[1,6])+1 say aRecv[1,14]
            endif

            do case
               case left(aRecv[1,14],9) == "CANCELLED"
                  select SM3VEIL
                  set relation to SM3VEIL->idnr into SM3DATA
                  nLoop := 0
                  loop
               case left(aRecv[1,14],3) == "NOT"
                  select SM3VEIL
                  set relation to SM3VEIL->idnr into SM3DATA
                  nLoop := 0
                  loop
               otherwise
                  //Toets of dier in kudde is
                  if SM3DATA->uitkrede $ cWaarisd()
                  else
                     if cLanType() == "A"
                        fScrBood(23,"Dier is nie meer in die kudde nie!")
                     else
                        fScrBood(23,"Animal is no longer in the herd!")
                     endif
                     fScrWait(24)
                     select SM3VEIL
                     set relation to SM3VEIL->idnr into SM3DATA
                     fScrBood(MAXROW()-1)
                     fScrBood(MAXROW())
                     if nReko = 0
                        loop
                     endif

                  endif

                  cGeslag := SM3DATA->geslag
                  cGebdat := SM3DATA->gebdatum

                  //Bepaal die katalogustipe
                  if aRecv[3,14] == " "
                     aRecv[3,14] := fKatalo(SM3DATA->geslag,SM3DATA->dragti,SM3DATA->lkalfn,SM3DATA->dekdat)
                  endif

                  select SM3VEIL
                  set relation to SM3VEIL->idnr into SM3DATA
                  //Kyk of data bestaan of nie
                  locate for SM3VEIL->idnr == aRecv[1,14]
                  if eof()
                     //Bestaan nie - gaan voort
                     if nReko > 0
                        goto nReko
                     endif
                  else
                     //Bestaan
                     if nReko > 0 .and. nReko == recno()
                        //Dieselfde rekord - gaan voort
                     else
                        //Bestaan reeds - vertoon bestaande
                        if cLanType() == "A"
                           fScrBood(23,"Dier bestaan reeds in veilingskatalogus!")
                        else
                           fScrBood(23,"Animal already entered in sales catalogue!")
                        endif
                        fScrWait(24)
                        if nReko > 0
                           goto nReko
                        else
                           go bottom
                           skip
                        endif
                        aRecv[1,14] := SM3VEIL->idnr
                        loop
                     endif
                  endif
                  //Read
                  @nLine+ 2,nBoxc say aRecv[ 2,6] get aRecv[ 2,14] pict aRecv[ 2,10]
                  @nLine+ 3,nBoxc say aRecv[ 3,6] get aRecv[ 3,14] pict aRecv[ 3,10] valid(fVKatal(aRecv))
                  @nLine+ 4,nBoxc say aRecv[ 4,6] get aRecv[ 4,14] pict aRecv[ 4,10]
                  @nLine+ 5,nBoxc say aRecv[ 5,6] get aRecv[ 5,14] pict aRecv[ 5,10]
                  set cursor on
                  read
                  set cursor off
                  lReturn := TRUE
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
            endcase

         otherwise
            //Bewaar rekord
            //Gaan na rekord
            if nReko > 0
               goto nReko
            else
               dbAppend()
               SM3VEIL->auctnumb := cAuct
               SM3VEIL->geslag   := cGeslag
               SM3VEIL->gebdatum := cGebdat
            endif
            //Lock
            do while ! rlock()
            enddo
            //Bewaar
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i,13], aRecv[i,14] )
            next

            commit

            if nReko == 0
               //Vul met data en vertoon
               aRecv := fFillBlank(aRecv)
               nLoop := 1
            else
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen(0,0,24,79,cCurSke)

return lReturn

/******************************************************************************/
STATIC FUNCTION fLotReNumber

   // Function to renumber lots

   // Declare
   local lRetu := TRUE
   local aCscr := fASaveScr()
   local nRecn := 0
   local lOldn := FALSE
   local cMsg1 := ""
   local cMsg2 := ""

   begin sequence

      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Ou lotte word bewaar")
         cMsg1 := "Hernommer- "
         cMsg2 := "(J)a = skrap ou nommers. (N)ee = gebruik ou nommers."
      else
         fScrWbood(maxrow(),"Old lot numbers being saved")
         cMsg1 := "Renumber- "
         cMsg2 := "(Y)es = delete old numbers. (N)o = use old numbers"
      endif

      DBSELECTAREA("SM3VEIL")
      ORDSETFOCUS(0)
      DBGOTOP()

      // Save old numbers
      do while ! eof()

         // Screen
         setcolor(cColBott())
         @maxrow()-1,30 say SM3VEIL->idnr
         setcolor(cColNorm())

         IF SM3VEIL->lotnom != 9999 .AND. SM3VEIL->lotnom != 0
            lOldn := TRUE
         ENDIF

         SM3VEIL->oldlot := SM3VEIL->lotnom
         DBSKIP()
      enddo

      if lOldn
         fScrBood(MAXROW()-1)
         if fJaNee(MAXROW(), cMsg1,,FALSE,,cMsg2 )
            ORDSETFOCUS(3)
         else
            ORDSETFOCUS(4)
         endif
      else
         ORDSETFOCUS(3)
      endif

      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Lotte word hernommer")
      else
         fScrWbood(maxrow(),"Lot numbers being renumbered")
      endif

      DBGOTOP()

      // Do the renumber
      do while ! eof()

         // Screen
         setcolor(cColBott())
         @maxrow()-1,30 say SM3VEIL->idnr
         setcolor(cColNorm())

         // The replace
         SM3VEIL->lotnom := ++nRecn
         DBSKIP()
      enddo

      ordsetfocus(1)
      DBGOTOP()

   end

   // Reset
   fARestScr(aCscr)

return lRetu

//*************************************************************************/
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := FALSE
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde "+alltrim(aRecv[2,6])+" geskrap word?"
   else
      cBood := "Should above-mentioned "+alltrim(aRecv[2,6])+" be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,FALSE )
      do while !rlock()
      enddo
      delete
      skip
      if eof()
         go top
      endif
      lReturn := TRUE
   endif

return lReturn

//*************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := FALSE
   local cData := ""
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cData := upper(chr(nKeyp)) + space(aRecv[2,4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[2,4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[2,4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[2,6] get cData pict aRecv[2,10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cData == space(aRecv[2,4])
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   locate for SM3VEIL->idnr == cData
   //set softseek on
   //seek cData
   //set softseek off
   if eof()
      go top
   endif
   lRetu := TRUE

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/******************************************************************************/
STATIC FUNCTION fPrintSelect

   // Function to decide which sales catalogue to print

   // Delcare
   local lRetu := TRUE
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lBlup := .f.
   local lRegn := .t.
   local nCh   := 1
   local nBl   := 1
   local nRe   := 1

   begin sequence

      // Display menu to choose
      nCh := fNewMenu( nCh, "SM3SALE" )

      // Restore the screen
      fARestScr(aCscr)

      // Display menu to choose blup of nie
      nBl := fNewMenu( nBl, "SM3SALEB" )
      if nBl == 1
         lBlup := .t.
      endif

      // Display menu to choose registration numbers or not
      nRe := fNewMenu( nRe, "SM3SALER" )
      if nRe == 1
         lRegn := .t.
      else
         lRegn := .f.
      endif

      // Restore the screen
      fARestScr(aCscr)

      // Make only the current sale active
      select SM3VEIL

      if nCh == 1

         // Catalogue in graphic style
         if !fPrintGraphic(lBlup,lRegn)
            lRetu := FALSE
         endif

      elseif nCh == 2
         // Catalogue in pedigree format
         if !fPrintPedigreeSale(lBlup)
            lRetu := FALSE
         endif

      else
         lRetu := FALSE
      endif

   end

   // Reset
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrintGraphic(lBlup,lRegn)

   // Declare
   local lRetu := TRUE
   local cType := ""
   local nCrec := 0
   local nData := 0
   local cLkal := ""
   local cData := ""
   local cVaar := ""
   local cCond := ""
   local cNorm := ""
   local nMidc := 0
   local nWidt := 0
   local nWidN := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local cHead := ""
   local nI    := 0

   begin sequence

      // Test printer ready
      if fPrnReady() == K_ESC
         lRetu := FALSE
         break
      endif

      cNorm := cPrnNorm()
      cCond := cPrnCond()
      nWidN := nPrnWidt()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()

      // 06-03-06 14:00 Added
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl() - 6
         nPagl := nPrnLeng()
      else
         nPrnl := nPrcPrnl() - 6
         nPagl := nPrcLeng()
      endif

      // 06-03-06 14:00 Removed
      // nPrnl := nPrnPrnl() - 6
      // nPagl := nPrnLeng()

      // Top of file
      select SM3VEIL
      go top
      cHead := alltrim(SM3VEIL->headin)

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Veilingskatalogus word gedruk!  [Esc]=Stop drukker.")
      else
         fScrWbood(maxrow(),"Sales catalogue being printed!  [Esc]=Stop printer.")
      endif

      // Printer on
      fPrnOn()

      // The loop
      do while !eof()

         // Headings
         if prow() = 0

            if cLanType() == "A"

               if SM3VEIL->katalo == "A"
                  // Dragtige verse
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "OOP VERSE"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                      |     Vaar     |          Moer                       |  Loop met bul"
                  @prow()+1,  1 say "                              Speen   Jaar    18 mde  | ------------ | ----------------------------------- | ---------------"
                  @prow()+1,  1 say "                  G           205 dae 365 dae 540 dae |              |              Oud (j:m) Gemidd. Tkp  |              G "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte ------- ------- ------- | IdNr         | IdNr         (Aantal   speenin ---- | IdNr         e "
                  @prow()+1,  1 say "nomm RegNr        n  datum    Ind-Tyd Ind-Tyd Ind-Tyd | RegNr        | RegNr        kalwers)  (kalwe) Oek  | RegNr        n "
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  //                          1         2         3         4         5         6         7         8         9         0         1         2
                  //                 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  //                 1    6            19 22       31  35  39  43  47  51  5557           7072           85        95     103105          118

               elseif SM3VEIL->katalo == "B"
                  // Dragtige verse
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "DRAGTIGE VERSE"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                      |     Vaar     |          Moer                       |   Dragtig van bul  "
                  @prow()+1,  1 say "                              Speen   Jaar    18 mde  | ------------ | ----------------------------------- | -------------------"
                  @prow()+1,  1 say "                  G           205 dae 365 dae 540 dae |              |              Oud (j:m) Gemidd. Tkp  |              G     "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte ------- ------- ------- | IdNr         | IdNr         (Aantal   speenin ---- | IdNr         e  Mnd"
                  @prow()+1,  1 say "nomm RegNr        n  datum    Ind-Tyd Ind-Tyd Ind-Tyd | RegNr        | RegNr        kalwers)  (kalwe) Oek  | RegNr        n  Dra"
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  //                 1    6            19 22       31  35  39  43  47  51  5557           7072           85        95     103105          118

               elseif SM3VEIL->katalo == "C"
                  // Dragtige koeie
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "OOP KOEIE"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                     |     Vaar        |     Moer     |  Loop met bul  "
                  @prow()+1,  1 say "                                                     | --------------- | ------------ | ---------------"
                  @prow()+1,  1 say "                  G           Oud (j:m) Gemidd. Tkp  |              G  |              |              G "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte (Aantal   speenin ---- | IdNr         e  | IdNr         | IdNr         e "
                  @prow()+1,  1 say "nomm RegNr        n  datum    kalwers)  (Kalwe) Oek  | RegNr        n  | RegNr        | RegNr        n "
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  //                 1    6            19 22       31        41      4951           64 6769           8284           97

               elseif SM3VEIL->katalo == "D"
                  // Dragtige koeie
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "DRAGTIGE KOEIE"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                     |     Vaar        |     Moer     |   Dragtig van bul  "
                  @prow()+1,  1 say "                                                     | --------------- | ------------ | -------------------"
                  @prow()+1,  1 say "                  G           Oud (j:m) Gemidd. Tkp  |              G  |              |              G     "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte (Aantal   speenin ---- | IdNr         e  | IdNr         | IdNr         e  Mnd"
                  @prow()+1,  1 say "nomm RegNr        n  datum    kalwers)  (Kalwe) Oek  | RegNr        n  | RegNr        | RegNr        n  Dra"
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  //                 1    6            19 22       31        41      4951           64 6769           8284           97

               elseif SM3VEIL->katalo == "E"
                  // Koeie met kalwers
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "OOP KOEIE MET KALWERS"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                              Oud (j:m)      |    Vaar    |    Moer    |              Kalf                     |  Loop met bul  "
                  @prow()+1,  1 say "                              (Kalwers) Tkp  |------------|------------|---------------------------------------| ---------------"
                  @prow()+1,  1 say "                  G           --------- ---- |            |            |             G G                       |              G "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte Gem. 205d      |IdNr        |IdNr        |IdNr         e e  VaarIdNr     Geb     | IdNr         e "
                  @prow()+1,  1 say "nomm RegNr        n  datum    (Kalwers) Oek  |RegNr       |RegNr       |RegNr        s n  VaarRegNr    datum   | RegNr        n "
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  //                          1         2         3         4         5         6         7         8         9         0         1         2
                  //                 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  // Nuwe            1    6            19 22       31        41  4647         5960         7273           8688 91           104    112114          127
                  // Oue             1    6            19 22       31        4143           5658           7173           8688 91           104     112115          128

               elseif SM3VEIL->katalo == "F"
                  // Koeie met kalwers
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "DRAGTIGE KOEIE MET KALWERS (3 in 1)"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                              Oud (j:m)      |    Vaar    |    Moer    |              Kalf                     | Dragtig van bul"
                  @prow()+1,  1 say "                              (Kalwers) Tkp  |------------|------------|---------------------------------------| ---------------"
                  @prow()+1,  1 say "                  G           --------- ---- |            |            |             G G                       |                "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte Gem. 205d      |IdNr        |IdNr        |IdNr         e e  VaarIdNr     Geboorte| IdNr         Ge"
                  @prow()+1,  1 say "nomm RegNr        n  datum    (Kalwers) Oek  |RegNr       |RegNr       |RegNr        s n  VaarRegNr    datum   | RegNr        MD"
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  //                 1    6            19 22       31        4143           5658           7173           8688 91           104     112115          128

               else
                  // Bulle
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "BULLE"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                 Spn            Gdt  Gdo  Klb               |    Vaar      |               Moer                 "
                  @prow()+1,  1 say "                                 205 F          365  540  Ind               | ------------ | -----------------------------------"
                  @prow()+1,  1 say "                  G              --- a          ---- ---- ---          Len  |              |              Oud(j:m)  Gemidd.     "
                  @prow()+1,  1 say "Lot  IdNr         e  Geboorte Gb Mas s  Tyd Ein Gdt  Gdo  VOm Skr Vel  Hoo  | IdNr         | IdNr         (Aantal   speenin Rep "
                  @prow()+1,  1 say "nomm RegNr        n  datum    ma Ind e  gen mas Ind  Ind  Ind tum dik  L:H  | RegNr        | RegNr        kalwers)  (Kalwe) Ind "
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  //                 1    6            19 22       31 34  38 41  45  49   54   59  63  67   72   7779           9294           107       117     125
               endif

            else

               if SM3VEIL->katalo == "A"
                  // Pregnant heifers
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "OPEN HEIFERS"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                      |     Sire     |           Dam                  |  Ran with bull "
                  @prow()+1,  1 say "                              Wean    Year    18 mnth | ------------ | ------------------------------ | ---------------"
                  @prow()+1,  1 say "                  G           205 day 365 day 540 day |              |              Age (y:m) Average |              G "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    ------- ------- ------- | IdNr         | IdNr         (No of    weanind | IdNr         e "
                  @prow()+1,  1 say "no.  RegNo        n  date     Ind Con Ind Con Ind Con | RegNo        | RegNo        calves)   (calves)| RegNo        n "
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"

               elseif SM3VEIL->katalo == "B"
                  // Pregnant heifers
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "PREGNANT HEIFERS"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                      |     Sire     |           Dam                  |       Bull bred to      "
                  @prow()+1,  1 say "                              Wean    Year    18 mnth | ------------ | ------------------------------ | ------------------------"
                  @prow()+1,  1 say "                  G           205 day 365 day 540 day |              |              Age (y:m) Average |              G          "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    ------- ------- ------- | IdNr         | IdNr         (No of    weanind | IdNr         e  Months  "
                  @prow()+1,  1 say "no.  RegNo        n  date     Ind Con Ind Con Ind Con | RegNo        | RegNo        calves)   (calves)| RegNo        n  Pregnant"
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"

               elseif SM3VEIL->katalo == "C"
                  // Pregnant cows
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "OPEN COWS"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                |     Sire        |     Dam      |  Ran with bull "
                  @prow()+1,  1 say "                                                | --------------- | ------------ | ---------------"
                  @prow()+1,  1 say "                  G           Age (y:m) Average |              G  |              |              G "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    (No. of   weanind | IdNr         e  | IdNr         | IdNr         e "
                  @prow()+1,  1 say "no.  RegNo        n  date     calves)   (calves)| RegNo        n  | RegNo        | RegNo        n "
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"

               elseif SM3VEIL->katalo == "D"
                  // Pregnant cows
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "PREGNANT COWS"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                                |     Sire        |     Dam      |      Bull bred to       "
                  @prow()+1,  1 say "                                                | --------------- | ------------ | ------------------------"
                  @prow()+1,  1 say "                  G           Age (y:m) Average |              G  |              |              G          "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    (No. of   weanind | IdNr         e  | IdNr         | IdNr         e  Months  "
                  @prow()+1,  1 say "no.  RegNo        n  date     calves)   (calves)| RegNo        n  | RegNo        | RegNo        n  Pregnant"
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"

               elseif SM3VEIL->katalo == "E"
                  // Cows with calf at foot
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "OPEN COWS WITH CALVES"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                              Age (y:m) |     Sire     |     Dam      |               Calf                      |  Ran with bull "
                  @prow()+1,  1 say "                              (# calves)| ------------ | ------------ | --------------------------------------- | ---------------"
                  @prow()+1,  1 say "                  G           --------- |              |              |              S G                        |              G "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    Ave. 205d | IdNr         | IdNr         | IdNr         e e  Sire Id no.  Birth    | IdNr         e "
                  @prow()+1,  1 say "no.  RegNo        n  date     (Calves)  | RegNo        | RegNo        | RegNo        x n  Sire calfbn. date     | RegNo        n "
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"

               elseif SM3VEIL->katalo == "F"
                  // Cows with calf at foot
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "PREGNANT COWS WITH CALVES (3 in 1)"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                              Age (y:m) |     Sire     |     Dam      |               Calf                      |  Bull bred to  "
                  @prow()+1,  1 say "                              (# calves)| ------------ | ------------ | --------------------------------------- | ---------------"
                  @prow()+1,  1 say "                  G           --------- |              |              |              S G                        |                "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    Ave. 205d | IdNr         | IdNr         | IdNr         e e  Sire Id no.  Birth    | IdNr         Ge"
                  @prow()+1,  1 say "no.  RegNo        n  date     (Calves)  | RegNo        | RegNo        | RegNo        x n  Sire calfbn. date     | RegNo        MP"
                  @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"

               else
                  // Bulls
                  fPrnCod( cNorm )
                  if empty(cHead)
                     @prow()+nTopl,1 say "BULLS"
                  else
                     @prow()+nTopl,1 say cHead
                  endif
                  fPrnCod( cCond )
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
                  @prow()+1,  1 say "                                 Wea P          Adg  Ada  Klb               |    Sire      |                Dam                 "
                  @prow()+1,  1 say "                                 205 h          365  540  Ind               | ------------ | -----------------------------------"
                  @prow()+1,  1 say "                  G              --- a          ---- ---- ---          Len  |              |              Age(y:m)  AvgWInd     "
                  @prow()+1,  1 say "Lot  IdNr         e  Birth    Bi Mas s  Con End Adg  Ada  FCv Scr Ski  Hei  | IdNr         | IdNr         (# Calf)  (#Calf) Rep "
                  @prow()+1,  1 say "no.  RegNo        n  date     ma Ind e  tem mas Ind  Ind  Ind tum thi  L:H  | RegNo        | RegNo        Age 1stC   A.C.I. Ind "
                  @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
               endif
            endif
         endif

         // Stop printer
         if fPrnStop() = K_ESC
            lRetu := FALSE
            break
         endif

         // Data
         if SM3VEIL->katalo $ "AB"               // Heifers & Pregnant heifers
            // First line
            @prow()+1,       1 say padr(ltrim(str(int(SM3VEIL->lotnom))),4)
            @prow()  ,pcol()+1 say SM3VEIL->idnr
            @prow()  ,pcol()+1 say SM3DATA->generasie
            @prow()  ,pcol()+1 say SM3DATA->gebdatum
            @prow()  ,pcol()+1 say SM3DATA->ind205
            //@prow()  ,pcol()   say padr( "-" + alltrim(str(SM3DATA->aan205)) , 4)
            @prow()  ,pcol()+1 say space(3)
            @prow()  ,pcol()+1 say SM3DATA->ind365
            //@prow()  ,pcol()   say padr( "-" + alltrim(str(SM3DATA->aan365)) , 4)
            @prow()  ,pcol()+1 say space(3)
            @prow()  ,pcol()+1 say SM3DATA->ind540
            //@prow()  ,pcol()   say padr( "-" + alltrim(str(SM3DATA->aan540)) , 4)
            @prow()  ,pcol()+1 say space(3)

            @prow()  ,55       say "|"
            @prow()  ,pcol()+1 say SM3DATA->idvaar

            @prow()  ,70       say "|"
            @prow()  ,pcol()+1 say SM3DATA->idmoer

            // Ouderdom aantal kalwers
            select SM3DATA
            nCrec := recno()
            cData := ""

            if SM3DATA->(DBSEEK(SM3DATA->idmoer))
               if ! EMPTY(SM3DATA->gebdatum) .and. ! EMPTY(SM3DATA->lkalfdatum)
                  cData := fCalAge(SM3DATA->lkalfdatum - SM3DATA->gebdatum)
               endif
               cData += "("+alltrim(str(SM3DATA->kalfaantal,2,0))+")"
               @prow()  ,pcol()+1 say padl(cData,9)
               cData := ltrim(str(SM3DATA->gemspeeni,3,0))+"("
               cData += ltrim(str(SM3DATA->gemspeena,2,0))+")"
               @prow()  ,pcol()+1 say padl(cData,7)
               if SM3DATA->gemkalfin > 0
                  @prow()  ,pcol()+1 say padr(alltrim(str(SM3DATA->gemkalfin)),4)
               else
                  @prow()  ,pcol()+1 say space(4)
               endif

            endif
            goto nCrec
            select SM3VEIL

            @prow()  ,108      say "|"
            @prow()  ,pcol()+1 say SM3DATA->bulid

            //Bul generasie
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            @prow()  ,pcol()+1 say SM3DATA->generasie
            goto nCrec
            select SM3VEIL

            //Maande dragtig
            if ! EMPTY(SM3DATA->dekdat) .and. SM3VEIL->katalo == "B" // Pregnant heifers
               @prow(),125 say str((SM3AUCT->auctdate - SM3DATA->dekdat) / 30.4375,2,0)
            endif

            //Tweede lyn
            @prow()+1,  1 say num2alpha(remdec(SM3VEIL->lotnom))
            if lRegn
               @prow()  ,  6 say SM3DATA->reknr
            endif
            @prow()  , 55 say "|"
            if lRegn
               @prow()  , 57 say fVaarData("reknr")
            endif
            @prow()  , 70 say "|"
            if lRegn
               @prow()  , 72 say fMoerData("reknr")
            endif
            @prow()  ,103 say fMoerData("oudekalf")

            //Bul generasie
            @prow()  ,108 say "|"
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            if lRegn
               @prow()  ,110 say SM3DATA->reknr
            endif
            goto nCrec
            select SM3VEIL

            //Derde lyn
            if ! empty(SM3VEIL->opmerk)
               @prow()+1,006 say SM3VEIL->opmerk
            endif

            // Print breeding values
            if lBlup
               if cLanType() == "A"
                  @prow()+1, 6 say "EBV: GmD("+ltrim(str(SM3DATA->birdir))+")"
                  @prow()  ,pcol()+1 say "GmM("+ltrim(str(SM3DATA->birmat))+")"
                  @prow()  ,pcol()+1 say "SpD("+ltrim(str(SM3DATA->weadir))+")"
                  @prow()  ,pcol()+1 say "SpM("+ltrim(str(SM3DATA->weamat))+")"
                  @prow()  ,pcol()+1 say "Jr("+ltrim(str(SM3DATA->yeadir))+")"
                  @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                  @prow()  ,pcol()+1 say "Gdt("+ltrim(str(SM3DATA->adgdir))+")"
                  @prow()  ,pcol()+1 say "Vov("+ltrim(str(SM3DATA->pcfcrd))+")"
                  @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                  @prow()  ,pcol()+1 say "Skr("+ltrim(str(SM3DATA->scrdir))+")"
                  @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                  @prow()  ,pcol()+1 say "Kte("+ltrim(str(SM3DATA->eocdir))+")"
               else
                  @prow()+1, 6 say "EBV: BmD("+ltrim(str(SM3DATA->birdir))+")"
                  @prow()  ,pcol()+1 say "BmM("+ltrim(str(SM3DATA->birmat))+")"
                  @prow()  ,pcol()+1 say "WnD("+ltrim(str(SM3DATA->weadir))+")"
                  @prow()  ,pcol()+1 say "WnM("+ltrim(str(SM3DATA->weamat))+")"
                  @prow()  ,pcol()+1 say "Yr("+ltrim(str(SM3DATA->yeadir))+")"
                  @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                  @prow()  ,pcol()+1 say "Adg("+ltrim(str(SM3DATA->adgdir))+")"
                  @prow()  ,pcol()+1 say "Fcr("+ltrim(str(SM3DATA->pcfcrd))+")"
                  @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                  @prow()  ,pcol()+1 say "Scr("+ltrim(str(SM3DATA->scrdir))+")"
                  @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                  @prow()  ,pcol()+1 say "Cra("+ltrim(str(SM3DATA->eocdir))+")"
               endif
            endif

         elseif SM3VEIL->katalo $ "CD"           // Open & Pregnant cows
            // First line
            @prow()+1,       1 say padr(ltrim(str(int(SM3VEIL->lotnom))),4)
            @prow()  ,pcol()+1 say SM3VEIL->idnr
            @prow()  ,pcol()+1 say SM3DATA->generasie
            @prow()  ,pcol()+1 say SM3DATA->gebdatum

            //Ouderdom aantal kalwers
            cData := ""

            if ! EMPTY(SM3DATA->gebdatum) .and. ! EMPTY(SM3DATA->lkalfdatum)
               cData := fCalAge(SM3DATA->lkalfdatum - SM3DATA->gebdatum)
            endif

            cData += "("+alltrim(str(SM3DATA->kalfaantal,2,0))+")"
            @prow()  ,pcol()+1 say padl(cData,9)
            cData := ltrim(str(SM3DATA->gemspeeni,3,0))+"("
            cData += ltrim(str(SM3DATA->gemspeena,2,0))+")"
            @prow()  ,pcol()+1 say padl(cData,7)
            if SM3DATA->gemkalfin > 0
               @prow()  ,pcol()+1 say padr(alltrim(str(SM3DATA->gemkalfin)),4)
            else
               @prow()  ,pcol()+1 say space(4)
            endif

            @prow()  ,54 say "|"
            @prow()  ,pcol()+1 say SM3DATA->idvaar
            @prow()  ,pcol()+1 say fVaardata("generasie")

            @prow()  ,72 say "|"
            @prow()  ,pcol()+1 say SM3DATA->idmoer

            @prow()  ,87 say "|"
            @prow()  ,pcol()+1 say SM3DATA->bulid

            //Bul generasie
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            @prow()  ,pcol()+1 say SM3DATA->generasie
            goto nCrec
            select SM3VEIL

            //Maande dragtig
            if ! EMPTY(SM3DATA->dekdat) .and. SM3VEIL->katalo == "D" // Pregnant cows
               @prow(),108 say str((SM3AUCT->auctdate - SM3DATA->dekdat) / 30.4375,2,0)
            endif

            //Tweede lyn
            @prow()+1,  1 say num2alpha(remdec(SM3VEIL->lotnom))
            if lRegn
               @prow()  ,  6 say SM3DATA->reknr
            endif
            @prow()  , 49 say SM3DATA->oudekalf
            @prow()  , 54 say "|"
            if lRegn
               @prow()  , 56 say fVaarData("reknr")
            endif
            @prow()  , 72 say "|"
            if lRegn
               @prow()  , 74 say fMoerData("reknr")
            endif
            @prow()  , 87 say "|"
            //Bul generasie
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            if lRegn
               @prow()  , 89 say SM3DATA->reknr
            endif
            goto nCrec
            select SM3VEIL

            //Derde lyn
            if ! empty(SM3VEIL->opmerk)
               @prow()+1,06 say SM3VEIL->opmerk
            endif

            // Print breeding values
            if lBlup
               if cLanType() == "A"
                  @prow()+1, 6 say "EBV: GmD("+ltrim(str(SM3DATA->birdir))+")"
                  @prow()  ,pcol()+1 say "GmM("+ltrim(str(SM3DATA->birmat))+")"
                  @prow()  ,pcol()+1 say "SpD("+ltrim(str(SM3DATA->weadir))+")"
                  @prow()  ,pcol()+1 say "SpM("+ltrim(str(SM3DATA->weamat))+")"
                  @prow()  ,pcol()+1 say "Jr("+ltrim(str(SM3DATA->yeadir))+")"
                  @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                  @prow()  ,pcol()+1 say "Gdt("+ltrim(str(SM3DATA->adgdir))+")"
                  @prow()  ,pcol()+1 say "Vov("+ltrim(str(SM3DATA->pcfcrd))+")"
                  @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                  @prow()  ,pcol()+1 say "Skr("+ltrim(str(SM3DATA->scrdir))+")"
                  @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                  @prow()  ,pcol()+1 say "Kte("+ltrim(str(SM3DATA->eocdir))+")"
               else
                  @prow()+1, 6 say "EBV: BmD("+ltrim(str(SM3DATA->birdir))+")"
                  @prow()  ,pcol()+1 say "BmM("+ltrim(str(SM3DATA->birmat))+")"
                  @prow()  ,pcol()+1 say "WnD("+ltrim(str(SM3DATA->weadir))+")"
                  @prow()  ,pcol()+1 say "WnM("+ltrim(str(SM3DATA->weamat))+")"
                  @prow()  ,pcol()+1 say "Yr("+ltrim(str(SM3DATA->yeadir))+")"
                  @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                  @prow()  ,pcol()+1 say "Adg("+ltrim(str(SM3DATA->adgdir))+")"
                  @prow()  ,pcol()+1 say "Fcr("+ltrim(str(SM3DATA->pcfcrd))+")"
                  @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                  @prow()  ,pcol()+1 say "Scr("+ltrim(str(SM3DATA->scrdir))+")"
                  @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                  @prow()  ,pcol()+1 say "Cra("+ltrim(str(SM3DATA->eocdir))+")"
               endif
            endif

         elseif SM3VEIL->katalo $ "EF"           // Open & Pregnant cows with calves

            // First line
            @prow()+1,       1 say padr(ltrim(str(int(SM3VEIL->lotnom))),4)
            @prow()  ,pcol()+1 say SM3VEIL->idnr
            @prow()  ,pcol()+1 say SM3DATA->generasie
            @prow()  ,pcol()+1 say SM3DATA->gebdatum

            // Ouderdom aantal kalwers
            cData := ""
            if ! EMPTY(SM3DATA->gebdatum) .and. ! EMPTY(SM3DATA->lkalfdatum)
               cData := fCalAge(SM3DATA->lkalfdatum - SM3DATA->gebdatum)
            endif
            cData += "("+alltrim(str(SM3DATA->kalfaantal,2,0))+")"
            @prow()  ,pcol()+1 say padl(cData,9)
            if SM3DATA->gemkalfin > 0
               @prow()  ,pcol()+1 say padr(alltrim(str(SM3DATA->gemkalfin)),4)
            else
               @prow()  ,pcol()+1 say space(4)
            endif
            @prow()  ,pcol()+1 say "|"
            @prow()  ,pcol()   say SM3DATA->idvaar
            @prow()  ,pcol()   say "|"
            @prow()  ,pcol()   say SM3DATA->idmoer
            @prow()  ,pcol()   say "|"
            cLkal := SM3DATA->lkalfn

            // Kalfdata
            select SM3DATA
            nCrec := recno()
            if dbseek(SM3DATA->lkalfn) .and. ;
                  sm3data->uitkrede $ cWaarisd() .and. ;
                  SM3DATA->mas205 = 0 .and. ;
                  (SM3AUCT->auctdate - SM3DATA->gebdatum) <= 270

               @prow()  ,pcol()   say cLKal
               @prow()  ,pcol()+1 say SM3DATA->geslag
               @prow()  ,pcol()+1 say SM3DATA->generasie
               @prow()  ,pcol()+1 say SM3DATA->idvaar
               cVaar := SM3DATA->idvaar
               @prow()  ,pcol()+1 say SM3DATA->gebdatum

            else

               cVaar := ""
               if empty(SM3DATA->idnr)
                  if cLanType() == "A"
                     @prow()  ,pcol()+1 say "Kalf is onbekend!"
                  else
                     @prow()  ,pcol()+1 say "Calf is unknown!"
                  endif
               elseif SM3DATA->mas205 > 0
                  if cLanType() == "A"
                     //@prow()  ,pcol()+1 say "Kalf is reeds gespeen!"
                     @prow()  ,pcol()+1 say ""
                  else
                     @prow()  ,pcol()+1 say "Calf is already weaned!"
                  endif
               elseif (SM3AUCT->auctdate - SM3DATA->gebdatum) > 270
                  if cLanType() == "A"
                     @prow()  ,pcol()+1 say "Kalf reeds ouer as 270 dae!"
                  else
                     @prow()  ,pcol()+1 say "Calf already older than 270 days!"
                  endif
               else
                  if cLanType() == "A"
                     @prow()  ,pcol()+1 say "Kalf is onbekend!"
                  else
                     @prow()  ,pcol()+1 say "Calf is unknown!"
                  endif
               endif
            endif

            select SM3DATA
            goto nCrec
            select SM3VEIL

            @prow()  ,112 say "|"
            @prow()  ,pcol()+1 say SM3DATA->bulid

            // Bul generasie
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            @prow()  ,pcol()+1 say SM3DATA->generasie
            select SM3DATA
            goto nCrec
            select SM3VEIL

            // Tweede lyn
            @prow()+1,  1 say num2alpha(remdec(SM3VEIL->lotnom))
            if lRegn
               @prow()  ,  6 say SM3DATA->reknr
            endif
            cData := ltrim(str(SM3DATA->gemspeeni,3,0))+"("
            cData += ltrim(str(SM3DATA->gemspeena,2,0))+")"
            @prow()  , 33 say padl(cData,7)
            @prow()  , 41 say SM3DATA->oudekalf
            @prow()  , 46 say "|"
            if lRegn
               @prow()  , 47 say fVaarData("reknr")
            endif
            @prow()  , 59 say "|"
            if lRegn
               @prow()  , 60 say fMoerData("reknr")
            endif
            @prow()  , 72 say "|"

            // Kalf rek nommer
            select SM3DATA
            nCrec := recno()
            if dbseek(SM3DATA->lkalfn) .and. ;
                  sm3data->uitkrede $ cWaarisd() .and. ;
                  SM3DATA->mas205 = 0 .and. ;
                  (SM3AUCT->auctdate - SM3DATA->gebdatum) <= 270
               if lRegn
                  @prow()  , 73 say SM3DATA->reknr
               endif

               //
               select SM3DATA
               goto nCrec
               select SM3VEIL

               // Kalf vaar rek nommer
               select SM3DATA
               nCrec := recno()
               seek cVaar
               if lRegn
                  @prow()  , 91 say SM3DATA->reknr
               endif
               select SM3DATA
               goto nCrec
               select SM3VEIL
               //

            endif

            select SM3DATA
            goto nCrec
            select SM3VEIL

            // Bul generasie

            @prow()  ,112 say "|"
            select SM3DATA
            nCrec := recno()
            seek SM3DATA->bulid
            if lRegn
               @prow()  ,114 say SM3DATA->reknr
            endif
            select SM3DATA
            goto nCrec
            select SM3VEIL


            //Maande dragtig
            if ! EMPTY(SM3DATA->dekdat) .and. SM3VEIL->katalo == "F" // Pregnant cows with calfs
               @prow(),127 say str((SM3AUCT->auctdate - SM3DATA->dekdat) / 30.4375,2,0)
            endif

            //Derde lyn
            if ! empty(SM3VEIL->opmerk)
               @prow()+1,006 say SM3VEIL->opmerk
               //@prow()  ,113 say "|"
            endif

            // Print breeding values
            if lBlup
               if cLanType() == "A"
                  @prow()+1, 6 say "EBV: GmD("+ltrim(str(SM3DATA->birdir))+")"
                  @prow()  ,pcol()+1 say "GmM("+ltrim(str(SM3DATA->birmat))+")"
                  @prow()  ,pcol()+1 say "SpD("+ltrim(str(SM3DATA->weadir))+")"
                  @prow()  ,pcol()+1 say "SpM("+ltrim(str(SM3DATA->weamat))+")"
                  @prow()  ,pcol()+1 say "Jr("+ltrim(str(SM3DATA->yeadir))+")"
                  @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                  @prow()  ,pcol()+1 say "Gdt("+ltrim(str(SM3DATA->adgdir))+")"
                  @prow()  ,pcol()+1 say "Vov("+ltrim(str(SM3DATA->pcfcrd))+")"
                  @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                  @prow()  ,pcol()+1 say "Skr("+ltrim(str(SM3DATA->scrdir))+")"
                  @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                  @prow()  ,pcol()+1 say "Kte("+ltrim(str(SM3DATA->eocdir))+")"
               else
                  @prow()+1, 6 say "EBV: BmD("+ltrim(str(SM3DATA->birdir))+")"
                  @prow()  ,pcol()+1 say "BmM("+ltrim(str(SM3DATA->birmat))+")"
                  @prow()  ,pcol()+1 say "WnD("+ltrim(str(SM3DATA->weadir))+")"
                  @prow()  ,pcol()+1 say "WnM("+ltrim(str(SM3DATA->weamat))+")"
                  @prow()  ,pcol()+1 say "Yr("+ltrim(str(SM3DATA->yeadir))+")"
                  @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                  @prow()  ,pcol()+1 say "Adg("+ltrim(str(SM3DATA->adgdir))+")"
                  @prow()  ,pcol()+1 say "Fcr("+ltrim(str(SM3DATA->pcfcrd))+")"
                  @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                  @prow()  ,pcol()+1 say "Scr("+ltrim(str(SM3DATA->scrdir))+")"
                  @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                  @prow()  ,pcol()+1 say "Cra("+ltrim(str(SM3DATA->eocdir))+")"
               endif
            endif

         else                                    // Bulls

            // First line
            @prow()+1,       1 say padr(ltrim(str(int(SM3VEIL->lotnom))),4)
            @prow()  ,pcol()+1 say SM3VEIL->idnr
            @prow()  ,pcol()+1 say SM3DATA->generasie
            @prow()  ,pcol()+1 say SM3DATA->gebdatum
            @prow()  ,pcol()+1 say SM3DATA->gebmassa
            @prow()  ,pcol()+1 say SM3DATA->gma205
            if "D" $ SM3DATA->fasekode
               @prow()  ,pcol()+1 say "D "
               @prow()  ,pcol()+1 say SM3DATA->tydgen
               @prow()  ,pcol()+1 say SM3DATA->einmas
               @prow()  ,pcol()+1 say SM3DATA->gdtgdt
               @prow()  ,pcol()+1 say SM3DATA->gdogdo
               if empty(SM3DATA->kleiber) .and. !empty(SM3DATA->voeromset)
                  do while !SM3DATA->(rlock())
                  enddo
                  SM3DATA->kleiber := SM3DATA->voeromset
                  SM3DATA->voeromset := 0
                  SM3DATA->(dbunlock())
               endif
               @prow()  ,pcol()+1 say "   "      //SM3DATA->kleiber
               if !empty(SM3DATA->gekskr)
                  @prow()  ,pcol()+1 say SM3DATA->gekskr
               else
                  @prow()  ,pcol()+1 say SM3DATA->mateskrot
               endif
               @prow()  ,pcol()+1 say SM3DATA->veldikte
               if !empty(SM3DATA->geklen)
                  @prow()  ,pcol()+1 say str(SM3DATA->geklen,4,0)
               else
                  @prow()  ,pcol()+1 say str(SM3DATA->matelengte,4,0)
               endif
            elseif "C" $ SM3DATA->fasekode
               @prow()  ,pcol()+1 say "C "
               @prow()  ,pcol()+1 say SM3DATA->tydgen
               @prow()  ,pcol()+1 say SM3DATA->einmas
               @prow()  ,pcol()+1 say SM3DATA->gdtgdt
               @prow()  ,pcol()+1 say SM3DATA->gdogdo
               @prow()  ,pcol()+1 say str(SM3DATA->voeromset,3,1)
               if !empty(SM3DATA->gekskr)
                  @prow()  ,pcol()+1 say SM3DATA->gekskr
               else
                  @prow()  ,pcol()+1 say SM3DATA->mateskrot
               endif
               @prow()  ,pcol()+1 say SM3DATA->veldikte
               if !empty(SM3DATA->geklen)
                  @prow()  ,pcol()+1 say str(SM3DATA->geklen,4,0)
               else
                  @prow()  ,pcol()+1 say str(SM3DATA->matelengte,4,0)
               endif
            else
               @prow()  ,pcol()+1 say "B "
               @prow()  ,pcol()+1 say SM3DATA->aan540
               @prow()  ,pcol()+1 say SM3DATA->gma540
               @prow()  ,pcol()+1 say SM3DATA->gdo365
               @prow()  ,pcol()+1 say SM3DATA->gdo540
               @prow()  ,pcol()+1 say str(SM3DATA->voeromset,3,1)
               if !empty(SM3DATA->gekskr)
                  @prow()  ,pcol()+1 say SM3DATA->gekskr
               else
                  @prow()  ,pcol()+1 say SM3DATA->mateskrot
               endif
               @prow()  ,pcol()+1 say SM3DATA->veldikte
               if !empty(SM3DATA->geklen)
                  @prow()  ,pcol()+1 say str(SM3DATA->geklen,4,0)
               else
                  @prow()  ,pcol()+1 say str(SM3DATA->matelengte,4,0)
               endif
            endif

            @prow()  ,pcol()+1 say "|"
            @prow()  ,pcol()+1 say SM3DATA->idvaar

            @prow()  ,pcol()+1 say "|"
            @prow()  ,pcol()+1 say SM3DATA->idmoer

            //Ouderdom aantal kalwers
            select SM3DATA
            nCrec := recno()
            cData := ""

            if SM3DATA->(DBSEEK(SM3DATA->idmoer))
               if ! EMPTY(SM3DATA->gebdatum) .and. ! EMPTY(SM3DATA->lkalfdatum)
                  cData := fCalAge(SM3DATA->lkalfdatum - SM3DATA->gebdatum)
               endif

               cData += "("+alltrim(str(SM3DATA->kalfaantal,2,0))+")"
               @prow()  ,pcol()+1 say padl(cData,9)
               cData := ltrim(str(SM3DATA->gemspeeni,3,0))+"("
               cData += ltrim(str(SM3DATA->gemspeena,2,0))+")"
               @prow()  ,pcol()+1 say padl(cData,7)
               @prow()  ,pcol()+1 say SM3DATA->repind
            endif

            select SM3DATA
            goto nCrec
            select SM3VEIL

            //Tweede lyn
            if lRegn
               @prow()+1,  6 say SM3DATA->reknr
            else
               @prow()+1,  6 say ""
            endif
            @prow()  , 34 say SM3DATA->ind205

            if "D" $ SM3DATA->fasekode
               @prow()  , 49 say str(SM3DATA->gdtind,4,0)
               @prow()  , 54 say str(SM3DATA->gdoind,4,0)
               if empty(SM3DATA->kleiberi) .and. !empty(SM3DATA->voeromseti)
                  do while !SM3DATA->(rlock())
                  enddo
                  SM3DATA->kleiberi := SM3DATA->voeromseti
                  SM3DATA->voeromseti := 0
                  SM3DATA->(dbunlock())
               endif
               @prow()  , 59 say ltrim(str(SM3DATA->kleiberi))
               if !empty(SM3DATA->gekhoo)
                  @prow()  , 72 say str(SM3DATA->gekhoo,4,0)
               else
                  @prow()  , 72 say str(SM3DATA->mateskouer,4,0)
               endif

            elseif "C" $ SM3DATA->fasekode
               @prow()  , 49 say str(SM3DATA->gdtind,4,0)
               @prow()  , 54 say str(SM3DATA->gdoind,4,0)
               @prow()  , 59 say ltrim(str(SM3DATA->voeromseti))
               if !empty(SM3DATA->gekhoo)
                  @prow()  , 72 say str(SM3DATA->gekhoo,4,0)
               else
                  @prow()  , 72 say str(SM3DATA->mateskouer,4,0)
               endif
            else
               @prow()  , 49 say str(SM3DATA->ind365,4,0)
               @prow()  , 54 say str(SM3DATA->ind540,4,0)
               @prow()  , 59 say ""              // str(SM3DATA->voeromseti,4,0)
               @prow()  , 72 say ""              // str(SM3DATA->matelengte,4,0)
            endif
            @prow()  , 77 say "|"
            if lRegn
               @prow()  , 79 say fVaarData("reknr")
            endif
            @prow()  , 92 say "|"
            if lRegn
               @prow()  , 94 say fMoerData("reknr")
            endif
            nI := fMoerData("oudekalf","N")
            @prow()  ,111 say IIF(nI > 0, STR(nI,2,0)+IIF(cLanType() = "A","mde","mth"), "")
            nI := fMoerData("gemkalfin","N")
            @prow()  ,120 say IIF(nI > 0, STR(nI,4,0), "")

            // Derde Lyn
            if "C" $ SM3DATA->fasekode .or. "D" $ SM3DATA->fasekode
               if empty(SM3VEIL->opmerk)
                  @prow()+1,00 say ""
               else
                  @prow()+1,06 say SM3VEIL->opmerk
               endif
               @prow(),72 say STR(SM3DATA->hoolen)
               @prow()  , 77 say "|"
               @prow()  , 92 say "|"
               // Print breeding values
               if lBlup
                  if cLanType() == "A"
                     @prow()+1, 6 say "EBV: GmD("+ltrim(str(SM3DATA->birdir))+")"
                     @prow()  ,pcol()+1 say "GmM("+ltrim(str(SM3DATA->birmat))+")"
                     @prow()  ,pcol()+1 say "SpD("+ltrim(str(SM3DATA->weadir))+")"
                     @prow()  ,pcol()+1 say "SpM("+ltrim(str(SM3DATA->weamat))+")"
                     @prow()  ,pcol()+1 say "Jr("+ltrim(str(SM3DATA->yeadir))+")"
                     @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                     @prow()  ,pcol()+1 say "Gdt("+ltrim(str(SM3DATA->adgdir))+")"
                     @prow()  ,pcol()+1 say "Vov("+ltrim(str(SM3DATA->pcfcrd))+")"
                     @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                     @prow()  ,pcol()+1 say "Skr("+ltrim(str(SM3DATA->scrdir))+")"
                     @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                     @prow()  ,pcol()+1 say "Kte("+ltrim(str(SM3DATA->eocdir))+")"
                  else
                     @prow()+1, 6 say "EBV: BmD("+ltrim(str(SM3DATA->birdir))+")"
                     @prow()  ,pcol()+1 say "BmM("+ltrim(str(SM3DATA->birmat))+")"
                     @prow()  ,pcol()+1 say "WnD("+ltrim(str(SM3DATA->weadir))+")"
                     @prow()  ,pcol()+1 say "WnM("+ltrim(str(SM3DATA->weamat))+")"
                     @prow()  ,pcol()+1 say "Yr("+ltrim(str(SM3DATA->yeadir))+")"
                     @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                     @prow()  ,pcol()+1 say "Adg("+ltrim(str(SM3DATA->adgdir))+")"
                     @prow()  ,pcol()+1 say "Fcr("+ltrim(str(SM3DATA->pcfcrd))+")"
                     @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                     @prow()  ,pcol()+1 say "Scr("+ltrim(str(SM3DATA->scrdir))+")"
                     @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                     @prow()  ,pcol()+1 say "Cra("+ltrim(str(SM3DATA->eocdir))+")"
                  endif
               endif
            else
               if ! empty(SM3VEIL->opmerk)
                  @prow()+1,06 say SM3VEIL->opmerk
                  @prow()  ,77 say "|"
                  @prow()  ,92 say "|"
               endif
               // Print breeding values
               if lBlup
                  if cLanType() == "A"
                     @prow()+1, 6 say "EBV: GmD("+ltrim(str(SM3DATA->birdir))+")"
                     @prow()  ,pcol()+1 say "GmM("+ltrim(str(SM3DATA->birmat))+")"
                     @prow()  ,pcol()+1 say "SpD("+ltrim(str(SM3DATA->weadir))+")"
                     @prow()  ,pcol()+1 say "SpM("+ltrim(str(SM3DATA->weamat))+")"
                     @prow()  ,pcol()+1 say "Jr("+ltrim(str(SM3DATA->yeadir))+")"
                     @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                     @prow()  ,pcol()+1 say "Gdt("+ltrim(str(SM3DATA->adgdir))+")"
                     @prow()  ,pcol()+1 say "Vov("+ltrim(str(SM3DATA->pcfcrd))+")"
                     @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                     @prow()  ,pcol()+1 say "Skr("+ltrim(str(SM3DATA->scrdir))+")"
                     @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                     @prow()  ,pcol()+1 say "Kte("+ltrim(str(SM3DATA->eocdir))+")"
                  else
                     @prow()+1, 6 say "EBV: BmD("+ltrim(str(SM3DATA->birdir))+")"
                     @prow()  ,pcol()+1 say "BmM("+ltrim(str(SM3DATA->birmat))+")"
                     @prow()  ,pcol()+1 say "WnD("+ltrim(str(SM3DATA->weadir))+")"
                     @prow()  ,pcol()+1 say "WnM("+ltrim(str(SM3DATA->weamat))+")"
                     @prow()  ,pcol()+1 say "Yr("+ltrim(str(SM3DATA->yeadir))+")"
                     @prow()  ,pcol()+1 say "18m("+ltrim(str(SM3DATA->m18dir))+")"
                     @prow()  ,pcol()+1 say "Adg("+ltrim(str(SM3DATA->adgdir))+")"
                     @prow()  ,pcol()+1 say "Fcr("+ltrim(str(SM3DATA->pcfcrd))+")"
                     @prow()  ,pcol()+1 say "Klb("+ltrim(str(SM3DATA->kledir))+")"
                     @prow()  ,pcol()+1 say "Scr("+ltrim(str(SM3DATA->scrdir))+")"
                     @prow()  ,pcol()+1 say "Hgt("+ltrim(str(SM3DATA->hgtdir))+")"
                     @prow()  ,pcol()+1 say "Cra("+ltrim(str(SM3DATA->eocdir))+")"
                  endif
               endif
            endif

         endif

         // Next record
         select SM3VEIL
         cType := SM3VEIL->katalo
         skip

         // End of page
         if prow() >= nPrnl+4 .or. eof() .or. SM3VEIL->katalo # cType

            fPrnCod( cCond )

            // Change heading
            if SM3VEIL->katalo # cType
               cHead := SM3VEIL->headin
            endif

            if cType $ "AB"
               @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
            elseif cType $ "CD"
               @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
            elseif cType $ "EF"
               @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
            else
               @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
            endif
            // Print bottom line
            if (nBlad % 2) > 0
               @prow()+(nPagl-4-prow())  ,  1 say ""
               fPrnCod( cNorm )
               @prow(),1 say cAppName()
               if cLanType() == "A"
                  @prow(),nWidn-len("Bladsy "+alltrim(str(nBlad))) say "Bladsy "+alltrim(str(nBlad))
               else
                  @prow(),nWidn-len("Page "+alltrim(str(nBlad))) say "Page "+alltrim(str(nBlad))
               endif
            else
               @prow()+(nPagl-4-prow())  ,  1 say ""
               fPrnCod( cNorm )
               if cLanType() == "A"
                  @prow(),1 say "Bladsy "+ltrim(str(nBlad))
               else
                  @prow(),1 say "Page "+ltrim(str(nBlad))
               endif
               @prow(),nWidn-len(cAppName()) say cAppName()
            endif

            fPrnEjec()
            //fPrnOff()
            nBlad++
         else
            if cType $ "AB"
               @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
            elseif cType $ "CD"
               @prow()+1,  1 say "---------------------------------------------------------------------------------------------------------------------------------"
            elseif cType $ "EF"
               @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
            else
               @prow()+1,  1 say "--------------------------------------------------------------------------------------------------------------------------------"
            endif
         endif

      enddo

      fPrnOff()

   end

   // Reset
   select SM3VEIL
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrintPedigreeSale

   // Function to print pedigree sales catalogues

   // Declare
   local lRetu := TRUE
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local aStam := {}
   local aOptnA[22]
   local aOptnB[22]
   local aOptnC[22]
   local aOptnD[22]
   local aOptnE[22]
   local aOptnF[22]
   local aOptnG[22]
   local nOptn    := 0
   local lOnePage := FALSE
   local cKatalo  := " "
   local cData    := ""
   local cPcod    := ""
   local nMidc    := 0
   local nWidt    := 0
   local nTopl    := 0
   local nPrnl    := 0
   local nPagl    := 0
   local nIdFirst := 1

   begin sequence

      // Test if animals
      if lastrec() <= 0
         lRetu := FALSE
         break
      endif

      // Test printer
      if fPrnReady() == K_ESC
         lRetu := FALSE
         break
      endif

      // Display menu to choose
      nIdFirst := fNewMenu( nIdFirst, "SM3VEILI" )

      // Restore the screen
      fARestScr(aCscr)

      // Normal Printing
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()

      // Ask what to print
      if ! fGetOptn("OOP VERSE (Groep A)","OPEN HEIFERS (Group A)",aOptnA)
         break
      endif

      // Ask what to print
      if ! fGetOptn("DRAGTIGE VERSE (Groep B)","PREGNANT HEIFERS (Group B)",aOptnB)
         break
      endif

      // Ask what to print
      if ! fGetOptn("OOP KOEIE (Groep C)","OPEN COWS (Group C)",aOptnC)
         break
      endif

      // Ask what to print
      if ! fGetOptn("DRAGTIGE KOEIE (Groep D)","PREGNANT COWS (Group D)",aOptnD)
         break
      endif

      // Ask what to print
      if ! fGetOptn("OOP KOEIE MET KALWERS (Groep E)","OPEN COWS WITH CALVES (Group E)",aOptnE)
         break
      endif

      // Ask what to print
      if ! fGetOptn("DRAGTIGE KOEIE MET KALWERS (Groep F)","PREGNANT COWS WITH CALVES (Group F)",aOptnF)
         break
      endif

      // Ask what to print
      if ! fGetOptn("BULLE (Groep G)","BULLS (Group G)",aOptnG)
         break
      endif

      // Move the data file
      select SM3VEIL
      go top

      // Start printing
      fPrnOn()
      fPrnCod( cPcod )

      // Loop to print each animal
      do while !eof()

         // Screen
         //if cLanType() == "A"
         //   fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
         //   fScrWbood(maxrow(),trim(SM3VEIL->idnr)+" se veilingsinskrywing word gedruk")
         //else
         //   fScrBood(maxrow()-1,fPercent(cmxkeyno(),cmxkeycount())+"% Completed")
         //   fScrWbood(maxrow(),trim(SM3VEIL->idnr)+" sales entry being printed")
         //endif

         // Determine whether more than one animal could be printed per page
         IF SM3VEIL->katalo != cKatalo
            cKatalo  := SM3VEIL->katalo
            lOnePage := FALSE

            DO CASE
               CASE cKatalo == "A"
                  nOptn := fCntOptn(aOptnA)
               CASE cKatalo == "B"
                  nOptn := fCntOptn(aOptnB)
               CASE cKatalo == "C"
                  nOptn := fCntOptn(aOptnC)
               CASE cKatalo == "D"
                  nOptn := fCntOptn(aOptnD)
               CASE cKatalo == "E"
                  nOptn := fCntOptn(aOptnE)
               CASE cKatalo == "F"
                  nOptn := fCntOptn(aOptnF)
               CASE cKatalo == "G"
                  nOptn := fCntOptn(aOptnG)
            ENDCASE

            IF nOptn > 6
               lOnePage := TRUE
            ENDIF
         ENDIF

         // Get the animals pedigree
         aStam := fStamboom(SM3VEIL->idnr)
         if empty(aStam)
            // Next record
            select SM3VEIL
            skip
            loop
         endif

         // Start printing
         // fPrnOn()
         // fPrnCod( cPcod )

         // Lot number
         if SM3VEIL->lotnom > 0
            cData := "LOT "+ltrim(str(SM3VEIL->lotnom))
            @prow()+1, 1 say cData
            @prow()+1, 1 say repl("-",len(cData))
         endif

         // Heading details
         if cLanType() == "A"
            @prow()+1, 1 say SM3VEIL->idnr
            @prow()  ,nWidt-23 say "    Reg.No.: "+trim(SM3DATA->reknr)
            @prow()+1, 1 say SM3DATA->idnaam
            @prow()  ,nWidt-23 say "  Geb.Datum: "+dtoc(SM3DATA->gebdatum)
            @prow()+1, 1 say repl("-",nWidt-1)
         else
            @prow()+1, 1 say SM3VEIL->idnr
            @prow()  ,nWidt-23 say "    Reg.Nr.: "+trim(SM3DATA->reknr)
            @prow()+1, 1 say SM3DATA->idnaam
            @prow()  ,nWidt-23 say " Birth date: "+dtoc(SM3DATA->gebdatum)
            @prow()+1, 1 say repl("-",nWidt-1)
         endif

         if nIdFirst = 1

            // Pedigree itself id number first
            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[ 8,1])+" ("+trim(aStam[ 8,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 4,1])+" ("+trim(aStam[ 4,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[ 9,1])+" ("+trim(aStam[ 9,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space((nWidt/3)*0)+"- "+trim(aStam[ 2,1])+" ("+trim(aStam[ 2,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[10,1])+" ("+trim(aStam[10,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 5,1])+" ("+trim(aStam[ 5,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[11,1])+" ("+trim(aStam[11,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            @prow()+1, 1 say ""

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[12,1])+" ("+trim(aStam[12,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 6,1])+" ("+trim(aStam[ 6,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[13,1])+" ("+trim(aStam[13,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space((nWidt/3)*0)+"- "+trim(aStam[ 3,1])+" ("+trim(aStam[ 3,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[14,1])+" ("+trim(aStam[14,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 7,1])+" ("+trim(aStam[ 7,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[15,1])+" ("+trim(aStam[15,2])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            @prow()+1, 1 say repl("-",20)
            cData := ""

         else

            // Pedigree itself name first
            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[ 8,2])+" ("+trim(aStam[ 8,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 4,2])+" ("+trim(aStam[ 4,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[ 9,2])+" ("+trim(aStam[ 9,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space((nWidt/3)*0)+"- "+trim(aStam[ 2,2])+" ("+trim(aStam[ 2,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[10,2])+" ("+trim(aStam[10,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 5,2])+" ("+trim(aStam[ 5,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[11,2])+" ("+trim(aStam[11,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            @prow()+1, 1 say ""

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[12,2])+" ("+trim(aStam[12,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 6,2])+" ("+trim(aStam[ 6,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[13,2])+" ("+trim(aStam[13,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space((nWidt/3)*0)+"- "+trim(aStam[ 3,2])+" ("+trim(aStam[ 3,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[14,2])+" ("+trim(aStam[14,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*1)-10)+"- "+trim(aStam[ 7,2])+" ("+trim(aStam[ 7,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            cData := space(((nWidt/3)*2)-10)+"- "+trim(aStam[15,2])+" ("+trim(aStam[15,1])+")"
            @prow()+1, 1 say left(cData,nWidt-1)

            @prow()+1, 1 say repl("-",20)
            cData := ""

         endif


         // Animal Remarks
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CORMK] $ "JY"
                  cData := fRemarks(SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own performance records
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNP] $ "JY"
                  cData := fOwnPerformance(SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own body
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNM] $ "JY"
                  cData := fOwnBody(SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own progeny records
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNN] $ "JY"
                  cData := fOwnProgeny(SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own mating particulars
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNX] $ "JY"
                  cData := fOwnMatings(SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own calvings
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWND] $ "JY"
                  cData := fOwnCalving(SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own Kleiber values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNK] $ "JY"
                  cData := fKleiber(1,SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own Phase-A breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNA] $ "JY"
                  cData := fPBVPhA(1,SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own Phase-B breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNA] $ "JY"
                  cData := fPBVPhB(1,SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Own Phase-C & D breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[COWNA] $ "JY"
                  cData := fPBVPhC(1,SM3VEIL->idnr)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Sire performance records
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CSIRP] $ "JY"
                  cData := fSirePerformance(SM3DATA->idvaar)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Sire progeny records
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CSIRN] $ "JY"
                  cData := fSireProgeny(SM3DATA->idvaar)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Sire Kleiber values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CSIRK] $ "JY"
                  cData := fKleiber(2,SM3DATA->idvaar)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Sire Phase-A breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CSIRA] $ "JY"
                  cData := fPBVPhA(2,SM3DATA->idvaar)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Sire Phase-B breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CSIRB] $ "JY"
                  cData := fPBVPhB(2,SM3DATA->idvaar)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Sire Phase-C & D breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CSIRC] $ "JY"
                  cData := fPBVPhC(2,SM3DATA->idvaar)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Dam performance records
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CDAMP] $ "JY"
                  cData := fDamPerformance(SM3DATA->idmoer)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Dam progeny records
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CDAMN] $ "JY"
                  cData := fDamProgeny(SM3DATA->idmoer)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Dam Kleiber values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CDAMK] $ "JY"
                  cData := fKleiber(3,SM3DATA->idmoer)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Dam Phase-A breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CDAMA] $ "JY"
                  cData := fPBVPhA(3,SM3DATA->idmoer)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Dam Phase-B breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CDAMB] $ "JY"
                  cData := fPBVPhB(3,SM3DATA->idmoer)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Dam Phase-C & D breeding values
         DO CASE
            CASE SM3VEIL->katalo == "A"
               if aOptnA[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "B"
               if aOptnB[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "C"
               if aOptnC[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "D"
               if aOptnD[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "E"
               if aOptnE[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "F"
               if aOptnF[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
            CASE SM3VEIL->katalo == "G"
               if aOptnG[CDAMC] $ "JY"
                  cData := fPBVPhC(3,SM3DATA->idmoer)
               endif
         ENDCASE

         if !empty(cData)
            @prow()+1, 1 say left(cData,nWidt-1)
            cData := ""
         endif

         // Line at end
         @prow()+1, 1 say repl("-",nWidt-1)

         // Next record
         select SM3VEIL
         skip

         if eof() .or. lOnePage .or. SM3VEIL->katalo != cKatalo
            if prow() > 0
               @prow()+1, 1 say cAppName()
               fPrnEjec()
            endif
         else
            // Line and page breaks
            if prow() >= int(nPrnl / 2)
               // Skip to next page
               @prow()+1, 1 say cAppName()
               fPrnEjec()
            else
               // Skip to middle of page
               @prow()+((nPrnl / 2)-prow()),1 say ""
            endif
         endif

         // Printer off
         //fPrnOff()

      enddo

      // Printer off
      fPrnOff()


   end
   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fStamboom(cId)

   // Function to lookup on animals pedigree

   // Declare
   local aStam := {}
   local aCdbf := fATopen()
   local i     := 0
   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Values
      for i = 1 to 15
         aadd(aStam,{space(12),space(35),space(10)," "})
      next

      // Locate the animal
      select SM3DATA
      ordsetfocus(1)

      //Dier self
      aStam[1,1] := cId

      for i = 1 to 15

         if empty(aStam[i,1])

            // Do not locate

         else

            // Locate
            seek aStam[i,1]
            if found()

               aStam[i,2] := SM3DATA->idnaam
               aStam[i,3] := SM3DATA->reknr

               do case

                  case i==1
                     aStam[i+1,1] := SM3DATA->idvaar
                     aStam[i+2,1] := SM3DATA->idmoer
                     aStam[i+1,4] := "2"
                     aStam[i+2,4] := "1"

                  case i==2
                     aStam[i+2,1] := SM3DATA->idvaar
                     aStam[i+3,1] := SM3DATA->idmoer
                     aStam[i+2,4] := "2"
                     aStam[i+3,4] := "1"

                  case i==3
                     aStam[i+3,1] := SM3DATA->idvaar
                     aStam[i+4,1] := SM3DATA->idmoer
                     aStam[i+3,4] := "2"
                     aStam[i+4,4] := "1"

                  case i==4
                     aStam[i+4,1] := SM3DATA->idvaar
                     aStam[i+5,1] := SM3DATA->idmoer
                     aStam[i+4,4] := "2"
                     aStam[i+5,4] := "1"

                  case i==5
                     aStam[i+5,1] := SM3DATA->idvaar
                     aStam[i+6,1] := SM3DATA->idmoer
                     aStam[i+5,4] := "2"
                     aStam[i+6,4] := "1"

                  case i==6
                     aStam[i+6,1] := SM3DATA->idvaar
                     aStam[i+7,1] := SM3DATA->idmoer
                     aStam[i+6,4] := "2"
                     aStam[i+7,4] := "1"

                  case i==7
                     aStam[i+7,1] := SM3DATA->idvaar
                     aStam[i+8,1] := SM3DATA->idmoer
                     aStam[i+7,4] := "2"
                     aStam[i+8,4] := "1"

               endcase

            else

               // Animal unknown

            endif

         endif

      next

   end
   // Reset
   fATclose(aCdbf)

return aStam

/******************************************************************************/
STATIC FUNCTION fRemarks(cIdnr)

   // Function to get the animal's own Remarks

   // Declare
   local cRetu := ""

   begin sequence

      if cLanType() == "A"
         cRetu := padl("Opmerking: ",11)+ALLTRIM(SM3VEIL->opmerk)
      else
         cRetu := padl("Remark: ",11)+ALLTRIM(SM3VEIL->opmerk)
      endif

      // Make NIL if only heading
      if len(cRetu) < 12
         cRetu := ""
      endif

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fOwnPerformance(cIdnr)

   // Function to get the animal's own performance

   // Declare
   local cRetu := ""
   begin sequence

      if cLanType() == "A"
         cRetu := padl("Eie pres:",10)
      else
         cRetu := padl("Own perf:",10)
      endif

      // Prewean
      if SM3DATA->ind100 > 0
         if cLanType() == "A"
            cRetu += " "+padr("VspInd:"+ltrim(str(SM3DATA->ind100)),10)
         else
            cRetu += " "+padr("PreInd:"+ltrim(str(SM3DATA->ind100)),10)
         endif
      endif

      // Wean
      if SM3DATA->ind205 > 0
         if cLanType() == "A"
            cRetu += " "+padr("SpnInd:"+ltrim(str(SM3DATA->ind205)),10)
         else
            cRetu += " "+padr("WeaInd:"+ltrim(str(SM3DATA->ind205)),10)
         endif
      endif

      // If female
      if SM3DATA->geslag $ " 1FVKC"

         // Year
         if SM3DATA->ind365 > 0
            if cLanType() == "A"
               cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->ind365)),10)
            else
               cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->ind365)),10)
            endif
         endif

         // 18 month
         if SM3DATA->ind540 > 0
            cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->ind540)),10)
         endif

      else

         if "D" $ SM3DATA->fasekode

            // Phase D

            // Gdt
            if SM3DATA->gdtind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gdtind)),10)
               else
                  cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gdtind)),10)
               endif
            endif

            // Gdo
            if SM3DATA->gdoind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gdoind)),10)
               else
                  cRetu += " "+padr("AdaInd:"+ltrim(str(SM3DATA->gdoind)),10)
               endif
            endif

            // Kleiber
            if SM3DATA->kleiberi > 0
               cRetu += " "+padr("KlbInd:"+ltrim(str(SM3DATA->kleiberi)),10)
            endif

         elseif "C" $ SM3DATA->fasekode

            // Phase C

            // Gdt
            if SM3DATA->gdtind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gdtind)),10)
               else
                  cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gdtind)),10)
               endif
            endif

            // Gdo
            if SM3DATA->gdoind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gdoind)),10)
               else
                  cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gdoind)),10)
               endif
            endif

            // Voeromset
            if SM3DATA->voeromseti > 0
               if cLanType() == "A"
                  cRetu += " "+padr("VovInd:"+ltrim(str(SM3DATA->voeromseti)),10)
               else
                  cRetu += " "+padr("FcoInd:"+ltrim(str(SM3DATA->voeromseti)),10)
               endif
            endif

         else

            // Year
            if SM3DATA->ind365 > 0
               if cLanType() == "A"
                  cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->ind365)),10)
               else
                  cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->ind365)),10)
               endif
            endif

            // 18 month
            if SM3DATA->ind540 > 0
               cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->ind540)),10)
            endif

         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fOwnBody(cIdnr)

   // Function to get the animal's own body measurements

   // Declare
   local cRetu := ""
   begin sequence

      if cLanType() == "A"
         cRetu := padl("Eie ligg:",10)
      else
         cRetu := padl("Own body:",10)
      endif

      if SM3DATA->geslag $ "2MO" .and. !empty(SM3DATA->fasekode)

         // Height
         if SM3DATA->gekhoo > 0
            if cLanType() == "A"
               cRetu += " "+padr("Hoogte:"+ltrim(str(SM3DATA->gekhoo)),10)
            else
               cRetu += " "+padr("Height:"+ltrim(str(SM3DATA->gekhoo)),10)
            endif
         endif

         // Length
         if SM3DATA->geklen > 0
            if cLanType() == "A"
               cRetu += " "+padr("Lengte:"+ltrim(str(SM3DATA->geklen)),10)
            else
               cRetu += " "+padr("Length:"+ltrim(str(SM3DATA->geklen)),10)
            endif
         endif

         // Skrotum
         if SM3DATA->gekskr > 0
            if cLanType() == "A"
               cRetu += " "+padr("Skrotu:"+ltrim(str(SM3DATA->gekskr)),10)
            else
               cRetu += " "+padr("Scrotu:"+ltrim(str(SM3DATA->gekskr)),10)
            endif
         elseif SM3DATA->mateskrot > 0
            if cLanType() == "A"
               cRetu += " "+padr("Skrotu:"+ltrim(str(SM3DATA->mateskrot)),10)
            else
               cRetu += " "+padr("Scrotu:"+ltrim(str(SM3DATA->mateskrot)),10)
            endif
         elseif SM3DATA->skr365 > 0
            if cLanType() == "A"
               cRetu += " "+padr("Skrotu:"+ltrim(str(SM3DATA->skr365)),10)
            else
               cRetu += " "+padr("Scrotu:"+ltrim(str(SM3DATA->skr365)),10)
            endif
         elseif SM3DATA->skr540 > 0
            if cLanType() == "A"
               cRetu += " "+padr("Skrotu:"+ltrim(str(SM3DATA->skr540)),10)
            else
               cRetu += " "+padr("Scrotu:"+ltrim(str(SM3DATA->skr540)),10)
            endif
         endif

         // Skin
         if SM3DATA->gekvel > 0
            if cLanType() == "A"
               cRetu += " "+padr("Veldik:"+ltrim(str(SM3DATA->gekvel)),10)
            else
               cRetu += " "+padr("Skinth:"+ltrim(str(SM3DATA->gekvel)),10)
            endif
         endif

      else

         // Skrotum
         if SM3DATA->skr365 > 0
            if cLanType() == "A"
               cRetu += " "+padr("Skrotu:"+ltrim(str(SM3DATA->skr365)),10)
            else
               cRetu += " "+padr("Scrotu:"+ltrim(str(SM3DATA->skr365)),10)
            endif
         elseif SM3DATA->skr540 > 0
            if cLanType() == "A"
               cRetu += " "+padr("Skrotu:"+ltrim(str(SM3DATA->skr540)),10)
            else
               cRetu += " "+padr("Scrotu:"+ltrim(str(SM3DATA->skr540)),10)
            endif
         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fOwnMatings(cIdnr)

   // Function to get the animal's own mating particulars

   // Declare
   local cRetu := ""
   begin sequence

      if cLanType() == "A"
         cRetu := padl("Eie dekk:",10)
      else
         cRetu := padl("Own mati:",10)
      endif

      // If female
      if SM3DATA->geslag $ " 1FVKC"

         // Bull
         if empty(SM3DATA->bulid) .or. empty(SM3DATA->dekdat)
         else
            if SM3DATA->tipede $ " 12"
               if cLanType() == "A"
                  cRetu += " Gedek deur bul "+trim(SM3DATA->bulid)+" op "+dtoc(SM3DATA->dekdat)
               else
                  cRetu += " Mated by bull "+trim(SM3DATA->bulid)+" on "+dtoc(SM3DATA->dekdat)
               endif
            elseif SM3DATA->tipede == "3"
               if cLanType() == "A"
                  cRetu += " Kunsmatig ge‹nsemineer met bul "+trim(SM3DATA->bulid)+" op "+dtoc(SM3DATA->dekdat)
               else
                  cRetu += " Artificially inseminated with bull "+trim(SM3DATA->bulid)+" on "+dtoc(SM3DATA->dekdat)
               endif
            endif
         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fOwnProgeny(cIdnr)

   // Function to get the animal's own progeny summary

   // Declare
   local cRetu := ""
   begin sequence

      if cLanType() == "A"
         cRetu := padl("Eie nage:",10)
      else
         cRetu := padl("Own prog:",10)
      endif

      // Number of calves
      cRetu += " "+padr("Number:"+ltrim(str(SM3DATA->kalfaantal)),10)

      // If female
      if SM3DATA->geslag $ " 1FVKC"

         // Average ICP
         if SM3DATA->gemkalfin > 0
            if cLanType() == "A"
               cRetu += " "+padr("GemTKP:"+ltrim(str(SM3DATA->gemkalfin)),10)
            else
               cRetu += " "+padr("AveICP:"+ltrim(str(SM3DATA->gemkalfin)),10)
            endif
         endif

      endif

      // Average prewean
      if SM3DATA->gem100 > 0
         if cLanType() == "A"
            cRetu += " "+padr("VspInd:"+ltrim(str(SM3DATA->gem100)),10)
         else
            cRetu += " "+padr("PreInd:"+ltrim(str(SM3DATA->gem100)),10)
         endif
      endif

      // Average wean
      if SM3DATA->gemspeeni > 0
         if cLanType() == "A"
            cRetu += " "+padr("SpnInd:"+ltrim(str(SM3DATA->gemspeeni)),10)
         else
            cRetu += " "+padr("WeaInd:"+ltrim(str(SM3DATA->gemspeeni)),10)
         endif
      endif

      // Average Year
      if SM3DATA->gem365 > 0
         if cLanType() == "A"
            cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->gem365)),10)
         else
            cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->gem365)),10)
         endif
      endif

      // Average 18 m
      if SM3DATA->gem540 > 0
         if cLanType() == "A"
            cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->gem540)),10)
         else
            cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->gem540)),10)
         endif
      endif

      // Average adg
      if SM3DATA->gegdti > 0
         if cLanType() == "A"
            cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gegdti)),10)
         else
            cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gegdti)),10)
         endif
      endif

      // Average ada
      if SM3DATA->gegdoi > 0
         if cLanType() == "A"
            cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gegdoi)),10)
         else
            cRetu += " "+padr("AdaInd:"+ltrim(str(SM3DATA->gegdoi)),10)
         endif
      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset

return cRetu

/******************************************************************************/
STATIC FUNCTION fOwnCalving(cIdnr)

   // Function to get the animal's own calving dates

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()
   begin sequence

      if cLanType() == "A"
         cRetu := padl("Eie kald:",10)
      else
         cRetu := padl("Own cald:",10)
      endif

      // Open the data file
      fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus("SM3MDAT")
      go top

      // If female
      if SM3DATA->geslag $ " 1FVKC"

         seek cIdnr
         do while SM3DATA->idmoer == cIdnr
            if empty(SM3DATA->gebdatum)
               cRetu += " "+"XX/XX"
            else
               cRetu += " "+right(dtoc(SM3DATA->gebdatum),5)
            endif
            skip
         enddo

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fSirePerformance(cIdnr)

   // Function to get the sire's own performance

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()
   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the sire
      seek cIdnr

      if found()

         if cLanType() == "A"
            cRetu := padl("Vaar pres:",10)
         else
            cRetu := padl("Sire perf:",10)
         endif

         // Prewean
         if SM3DATA->ind100 > 0
            if cLanType() == "A"
               cRetu += " "+padr("VspInd:"+ltrim(str(SM3DATA->ind100)),10)
            else
               cRetu += " "+padr("PreInd:"+ltrim(str(SM3DATA->ind100)),10)
            endif
         endif

         // Wean
         if SM3DATA->ind205 > 0
            if cLanType() == "A"
               cRetu += " "+padr("SpnInd:"+ltrim(str(SM3DATA->ind205)),10)
            else
               cRetu += " "+padr("WeaInd:"+ltrim(str(SM3DATA->ind205)),10)
            endif
         endif

         if "D" $ SM3DATA->fasekode

            // Phase D

            // Gdt
            if SM3DATA->gdtind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gdtind)),10)
               else
                  cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gdtind)),10)
               endif
            endif

            // Gdo
            if SM3DATA->gdoind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gdoind)),10)
               else
                  cRetu += " "+padr("AdaInd:"+ltrim(str(SM3DATA->gdoind)),10)
               endif
            endif

            // Kleiber
            if SM3DATA->kleiberi > 0
               cRetu += " "+padr("KlbInd:"+ltrim(str(SM3DATA->kleiberi)),10)
            endif

         elseif "C" $ SM3DATA->fasekode

            // Phase C

            // Gdt
            if SM3DATA->gdtind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gdtind)),10)
               else
                  cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gdtind)),10)
               endif
            endif

            // Gdo
            if SM3DATA->gdoind > 0
               if cLanType() == "A"
                  cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gdoind)),10)
               else
                  cRetu += " "+padr("AdaInd:"+ltrim(str(SM3DATA->gdoind)),10)
               endif
            endif

            // Voeromset
            if SM3DATA->voeromseti > 0
               if cLanType() == "A"
                  cRetu += " "+padr("VovInd:"+ltrim(str(SM3DATA->voeromseti)),10)
               else
                  cRetu += " "+padr("FcoInd:"+ltrim(str(SM3DATA->voeromseti)),10)
               endif
            endif

         else

            // Year
            if SM3DATA->ind365 > 0
               if cLanType() == "A"
                  cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->ind365)),10)
               else
                  cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->ind365)),10)
               endif
            endif

            // 18 month
            if SM3DATA->ind540 > 0
               cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->ind540)),10)
            endif

         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fSireProgeny(cIdnr)

   // Function to get the sire's own progeny

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()
   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the sire
      seek cIdnr

      if found()

         if cLanType() == "A"
            cRetu := padl("Vaar nage:",10)
         else
            cRetu := padl("Sire prog:",10)
         endif

         // Number of calves
         //if SM3DATA->kalfaantal > 0
         if cLanType() == "A"
            cRetu += " "+padr("Aantal:"+ltrim(str(SM3DATA->kalfaantal)),10)
         else
            cRetu += " "+padr("Number:"+ltrim(str(SM3DATA->kalfaantal)),10)
         endif
         //endif

         // Prewean
         if SM3DATA->gem100 > 0
            if cLanType() == "A"
               cRetu += " "+padr("VspInd:"+ltrim(str(SM3DATA->gem100)),10)
            else
               cRetu += " "+padr("PreInd:"+ltrim(str(SM3DATA->gem100)),10)
            endif
         endif

         // Average wean
         if SM3DATA->gemspeeni > 0
            if cLanType() == "A"
               cRetu += " "+padr("SpnInd:"+ltrim(str(SM3DATA->gemspeeni)),10)
            else
               cRetu += " "+padr("WeaInd:"+ltrim(str(SM3DATA->gemspeeni)),10)
            endif
         endif

         // Average Year
         if SM3DATA->gem365 > 0
            if cLanType() == "A"
               cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->gem365)),10)
            else
               cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->gem365)),10)
            endif
         endif

         // Average 18 m
         if SM3DATA->gem540 > 0
            cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->gem540)),10)
         endif

         // Average adg
         if SM3DATA->gegdti > 0
            if cLanType() == "A"
               cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gegdti)),10)
            else
               cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gegdti)),10)
            endif
         endif

         // Average ada
         if SM3DATA->gegdoi > 0
            if cLanType() == "A"
               cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gegdoi)),10)
            else
               cRetu += " "+padr("AdaInd:"+ltrim(str(SM3DATA->gegdoi)),10)
            endif
         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fDamPerformance(cIdnr)

   // Function to get the dam's own performance

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()
   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the sire
      seek cIdnr

      if found()

         if cLanType() == "A"
            cRetu := padl("Moer pres:",10)
         else
            cRetu := padl("Dam perf:",10)
         endif


         // Prewean
         if SM3DATA->ind100 > 0
            if cLanType() == "A"
               cRetu += " "+padr("VspInd:"+ltrim(str(SM3DATA->ind100)),10)
            else
               cRetu += " "+padr("PreInd:"+ltrim(str(SM3DATA->ind100)),10)
            endif
         endif

         // Wean
         if SM3DATA->ind205 > 0
            if cLanType() == "A"
               cRetu += " "+padr("SpnInd:"+ltrim(str(SM3DATA->ind205)),10)
            else
               cRetu += " "+padr("WeaInd:"+ltrim(str(SM3DATA->ind205)),10)
            endif
         endif

         // Year
         if SM3DATA->ind365 > 0
            if cLanType() == "A"
               cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->ind365)),10)
            else
               cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->ind365)),10)
            endif
         endif

         // 18 month
         if SM3DATA->ind540 > 0
            cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->ind540)),10)
         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fDamProgeny(cIdnr)

   // Function to get the dam's own progeny

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()
   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the sire
      seek cIdnr

      if found()

         if cLanType() == "A"
            cRetu := padl("Moer nage:",10)
         else
            cRetu := padl("Dam prog:",10)
         endif

         // Number of calves
         //if SM3DATA->kalfaantal > 0
         if cLanType() == "A"
            cRetu += " "+padr("Aantal:"+ltrim(str(SM3DATA->kalfaantal)),10)
         else
            cRetu += " "+padr("Number:"+ltrim(str(SM3DATA->kalfaantal)),10)
         endif
         //endif

         // Average ICP
         if SM3DATA->gemkalfin > 0
            if cLanType() == "A"
               cRetu += " "+padr("GemTKP:"+ltrim(str(SM3DATA->gemkalfin)),10)
            else
               cRetu += " "+padr("AveICP:"+ltrim(str(SM3DATA->gemkalfin)),10)
            endif
         endif

         // Prewean
         if SM3DATA->gem100 > 0
            if cLanType() == "A"
               cRetu += " "+padr("VspInd:"+ltrim(str(SM3DATA->gem100)),10)
            else
               cRetu += " "+padr("PreInd:"+ltrim(str(SM3DATA->gem100)),10)
            endif
         endif

         // Average wean
         if SM3DATA->gemspeeni > 0
            if cLanType() == "A"
               cRetu += " "+padr("SpnInd:"+ltrim(str(SM3DATA->gemspeeni)),10)
            else
               cRetu += " "+padr("WeaInd:"+ltrim(str(SM3DATA->gemspeeni)),10)
            endif
         endif

         // Average Year
         if SM3DATA->gem365 > 0
            if cLanType() == "A"
               cRetu += " "+padr("JaaInd:"+ltrim(str(SM3DATA->gem365)),10)
            else
               cRetu += " "+padr("YeaInd:"+ltrim(str(SM3DATA->gem365)),10)
            endif
         endif

         // Average 18 m
         if SM3DATA->gem540 > 0
            cRetu += " "+padr("18mInd:"+ltrim(str(SM3DATA->gem540)),10)
         endif

         // Average adg
         if SM3DATA->gegdti > 0
            if cLanType() == "A"
               cRetu += " "+padr("GdtInd:"+ltrim(str(SM3DATA->gegdti)),10)
            else
               cRetu += " "+padr("AdgInd:"+ltrim(str(SM3DATA->gegdti)),10)
            endif
         endif

         // Average ada
         if SM3DATA->gegdoi > 0
            if cLanType() == "A"
               cRetu += " "+padr("GdoInd:"+ltrim(str(SM3DATA->gegdoi)),10)
            else
               cRetu += " "+padr("AdaInd:"+ltrim(str(SM3DATA->gegdoi)),10)
            endif
         endif

      endif

      // Make NIL if only heading
      if len(cRetu) == 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fKleiber(n,cIdnr)

   // Function to get an animal's progeny

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()

   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the sire
      seek cIdnr

      if found()

         do case
            case n = 1
               if cLanType() == "A"
                  cRetu := padl("Eie kleib:",10)
               else
                  cRetu := padl("Own kleib:",10)
               endif
            case n = 2
               if cLanType() == "A"
                  cRetu := padl("Vaar klei:",10)
               else
                  cRetu := padl("Sire klei:",10)
               endif
            case n = 3
               if cLanType() == "A"
                  cRetu := padl("Moer klei:",10)
               else
                  cRetu := padl("Dam kleib:",10)
               endif
         endcase

         // Number of calves
         if SM3DATA->kleiber > 0
            if cLanType() == "A"
               cRetu += " "+padr("Verh:"+ltrim(str(SM3DATA->kleiber)),14)
            else
               cRetu += " "+padr("Ratio:"+ltrim(str(SM3DATA->kleiber)),14)
            endif
         endif

         // Average ICP
         if SM3DATA->kleiberi > 0
            if cLanType() == "A"
               cRetu += " "+padr("Indeks:"+ltrim(str(SM3DATA->kleiberi)),10)
            else
               cRetu += " "+padr("Index:"+ltrim(str(SM3DATA->kleiberi)),10)
            endif
         endif
      endif

      // Make NIL if only heading
      if len(cRetu) <= 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fPBVPhA(n,cIdnr)

   // Function to get an animal's Phase A Breeding values

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()

   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the animal
      if SM3DATA->(DBSEEK(cIdnr))

         do case
            case n = 1
               if cLanType() == "A"
                  cRetu := padl("EieEBV-A:",10)
               else
                  cRetu := padl("OwnEBV-A:",10)
               endif
            case n = 2
               if cLanType() == "A"
                  cRetu := padl("SireEBV-A:",10)
               else
                  cRetu := padl("SireEBV-A:",10)
               endif
            case n = 3
               if cLanType() == "A"
                  cRetu := padl("MoerEBV-A:",10)
               else
                  cRetu := padl("DamEBV-A:",10)
               endif
         endcase

         if SM3DATA->biracc > 10

            // Birth mass direct
            if cLanType() == "A"
               cRetu += " "+padr("GebD:"+ltrim(str(SM3DATA->birdir)),10)
            else
               cRetu += " "+padr("BrtD:"+ltrim(str(SM3DATA->birdir)),10)
            endif

            // Birth mass maternaal
            if cLanType() == "A"
               cRetu += " "+padr("GebM:"+ltrim(str(SM3DATA->birmat)),10)
            else
               cRetu += " "+padr("BrtM:"+ltrim(str(SM3DATA->birmat)),10)
            endif

            // Birth mass accuracy
            if cLanType() == "A"
               cRetu += " "+padr("GebA:"+ltrim(str(SM3DATA->biracc)),8)
            else
               cRetu += " "+padr("BrtA:"+ltrim(str(SM3DATA->biracc)),8)
            endif
         endif

         if SM3DATA->weaacc > 10

            // Wean mass direct
            if cLanType() == "A"
               cRetu += " "+padr("SpnD:"+ltrim(str(SM3DATA->weadir)),10)
            else
               cRetu += " "+padr("WeaD:"+ltrim(str(SM3DATA->weadir)),10)
            endif

            // Wean mass maternaal
            if !(empty(SM3DATA->weamat))
               if cLanType() == "A"
                  cRetu += " "+padr("SpnM:"+ltrim(str(SM3DATA->weamat)),10)
               else
                  cRetu += " "+padr("WeaM:"+ltrim(str(SM3DATA->weamat)),10)
               endif
            endif

            // Wean mass combined
            if !(empty(SM3DATA->weacom))
               if cLanType() == "A"
                  cRetu += " "+padr("SpnM:"+ltrim(str(SM3DATA->weacom)),10)
               else
                  cRetu += " "+padr("WeaM:"+ltrim(str(SM3DATA->weacom)),10)
               endif
            endif

            // Wean mass accuracy
            if cLanType() == "A"
               cRetu += " "+padr("SpnA:"+ltrim(str(SM3DATA->weaacc)),8)
            else
               cRetu += " "+padr("WeaA:"+ltrim(str(SM3DATA->weaacc)),8)
            endif

         endif
      endif

      // Make NIL if only heading
      if len(cRetu) <= 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fPBVPhB(n,cIdnr)

   // Function to get an animal's Phase B breeding values

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()

   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the animal
      if SM3DATA->(DBSEEK(cIdnr))

         do case
            case n = 1
               if cLanType() == "A"
                  cRetu := padl("EieEBV-B:",10)
               else
                  cRetu := padl("OwnEBV-B:",10)
               endif
            case n = 2
               if cLanType() == "A"
                  cRetu := padl("VaarEBV-B:",10)
               else
                  cRetu := padl("SireEBV-B:",10)
               endif
            case n = 3
               if cLanType() == "A"
                  cRetu := padl("MoerEBV-B:",10)
               else
                  cRetu := padl("DamEBV-B:",10)
               endif
         endcase

         if SM3DATA->yeaacc > 10
            // Year mass direct
            if cLanType() == "A"
               cRetu += " "+padr("JaaD:"+ltrim(str(SM3DATA->yeadir)),10)
            else
               cRetu += " "+padr("YeaD:"+ltrim(str(SM3DATA->yeadir)),10)
            endif

            // Year mass accuracy
            if cLanType() == "A"
               cRetu += " "+padr("JaaA:"+ltrim(str(SM3DATA->yeaacc)),8)
            else
               cRetu += " "+padr("YeaA:"+ltrim(str(SM3DATA->yeaacc)),8)
            endif
         endif

         if SM3DATA->m18acc > 10
            // 18Months mass direct
            if cLanType() == "A"
               cRetu += " "+padr("18mD:"+ltrim(str(SM3DATA->m18dir)),10)
            else
               cRetu += " "+padr("18mD:"+ltrim(str(SM3DATA->m18dir)),10)
            endif

            // 18Months mass accuracy
            if cLanType() == "A"
               cRetu += " "+padr("18mA:"+ltrim(str(SM3DATA->m18acc)),8)
            else
               cRetu += " "+padr("18mA:"+ltrim(str(SM3DATA->m18acc)),8)
            endif
         endif
      endif

      // Make NIL if only heading
      if len(cRetu) <= 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION fPBVPhC(n,cIdnr)

   // Function to get an animal's Phase C & D breeding values

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()

   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the animal
      if SM3DATA->(DBSEEK(cIdnr))

         do case
            case n = 1
               if cLanType() == "A"
                  cRetu := padl("EieEBV-C:",10)
               else
                  cRetu := padl("OwnEBV-C:",10)
               endif
            case n = 2
               if cLanType() == "A"
                  cRetu := padl("VaarEBV-C:",10)
               else
                  cRetu := padl("SireEBV-C:",10)
               endif
            case n = 3
               if cLanType() == "A"
                  cRetu := padl("MoerEBV-C:",10)
               else
                  cRetu := padl("DamEBV-C:",10)
               endif
         endcase

         if SM3DATA->adgacc > 10
            // ADG direct
            if cLanType() == "A"
               cRetu += " "+padr("GdtD:"+ltrim(str(SM3DATA->adgdir)),10)
            else
               cRetu += " "+padr("AdgD:"+ltrim(str(SM3DATA->adgdir)),10)
            endif

            // ADG accuracy
            if cLanType() == "A"
               cRetu += " "+padr("GdtA:"+ltrim(str(SM3DATA->adgacc)),8)
            else
               cRetu += " "+padr("AdgA:"+ltrim(str(SM3DATA->adgacc)),8)
            endif
         endif

         if SM3DATA->kleacc > 10
            // Kleiber direct
            if cLanType() == "A"
               cRetu += " "+padr("KleD:"+ltrim(str(SM3DATA->kledir)),10)
            else
               cRetu += " "+padr("KleD:"+ltrim(str(SM3DATA->kledir)),10)
            endif

            // Kleiber accuracy
            if cLanType() == "A"
               cRetu += " "+padr("KleA:"+ltrim(str(SM3DATA->kleacc)),8)
            else
               cRetu += " "+padr("KleA:"+ltrim(str(SM3DATA->kleacc)),8)
            endif
         endif

         if SM3DATA->scracc > 10
            // Scrotum direct
            if cLanType() == "A"
               cRetu += " "+padr("SkrD:"+ltrim(str(SM3DATA->scrdir)),10)
            else
               cRetu += " "+padr("ScrD:"+ltrim(str(SM3DATA->scrdir)),10)
            endif

            // Scrotum accuracy
            if cLanType() == "A"
               cRetu += " "+padr("SkrA:"+ltrim(str(SM3DATA->scracc)),8)
            else
               cRetu += " "+padr("ScrA:"+ltrim(str(SM3DATA->scracc)),8)
            endif
         endif
      endif

      // Make NIL if only heading
      if len(cRetu) <= 10
         cRetu := ""
      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

*-------------------------------------------------------------------------------
STATIC FUNCTION fAddAnim(cAuct)

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local nWatt := 1
   local lIdnr := FALSE
   local cTest := ""
   local nReko := 0

   //Vra een of groep diere
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
   endif

   nWatt := fNewMenu(nWatt,"SM3VEIL")
   fScrBood(23)
   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption(nWatt))
   else
      fScrOpsk( 1, "Option "+cOption(nWatt))
   endif

   do case
      case nWatt == 1
         //Een dier
         cTest := ""
         fACveil(0,cAuct)
      case nWatt == 2
         //Groep
         cTest := sm3groe()
         if empty(cTest)
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif
            restscreen(0,0,24,79,cCscr)
            cOption(-1)
            retu FALSE
         endif
      case nWatt == 3
         //Seleksiegroep
         cTest := sm3selg()
         if empty(cTest)
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No selection group requirements have been specified!")
            endif
            restscreen(0,0,24,79,cCscr)
            cOption(-1)
            retu FALSE
         endif
      otherwise
         restscreen(0,0,24,79,cCscr)
         cOption(-1)
         retu FALSE
   endcase

   //Soek diere
   if ! empty(cTest)
      dbselectarea("SM3VEIL")
      SET RELATION TO

      // The seek
      dbselectarea("SM3DATA")
      ordsetfocus(7)
      dbgotop()
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Diere word uitgesoek")
      else
         fScrWbood(24,"Animals being sorted")
      endif

      do while ! eof()
         if &(cTest)
            dbselectarea("SM3VEIL")
            ordsetfocus(2)

            if ! dbseek( SM3DATA->idnr + cAuct )
               dbappend()
               SM3VEIL->idnr     := SM3DATA->idnr// Id number
               SM3VEIL->geslag   := SM3DATA->geslag
               SM3VEIL->gebdatum := SM3DATA->gebdatum
               SM3VEIL->auctnumb := cAuct        // Auction Number
               SM3VEIL->lotnom   := 9999
               SM3VEIL->katalo   := fKatalo(SM3DATA->geslag,SM3DATA->dragti,SM3DATA->lkalfn,SM3DATA->dekdat)
            endif

            ordsetfocus(1)
         endif

         // Next record
         select SM3DATA
         dbskip()

      enddo
      ordsetfocus(1)

   endif

   // Reset
   dbselectarea("SM3VEIL")
   SET RELATION TO SM3VEIL->idnr INTO SM3DATA

   restscreen(0,0,24,79,cCscr)
   cOption(-1)

return TRUE

*------------------------------------------------------------------------------
STATIC FUNCTION fVKatal (aRecv)

   local nMenu    := 0
   local cMenuCol := IIF( cMenuCol==NIL, cColMenu(), cMenuCol )
   local aMenuAfr := {;
      {"A","Oop verse                          "},;
      {"B","Dragtige verse                     "},;
      {"C","Oop koeie                          "},;
      {"D","Dragtige koeie                     "},;
      {"E","Oop koeie met kalwers              "},;
      {"F","Dragtige koeie met kalwers (3 in 1)"},;
      {"G","Bulle                              "};
      }
   local aMenuEng := {;
      {"A","Open heifers                       "},;
      {"B","Pregnant heifers                   "},;
      {"C","Open cows                          "},;
      {"D","Pregnant cows                      "},;
      {"E","Open cows with calves              "},;
      {"F","Pregnant cows with calves (3 in 1) "},;
      {"G","Bulls                              "};
      }

   if ! aRecv[3,14] $ "ABCDEFG"
      if cLanType() == "A"
         nMenu := LPICKLIST(aMenuAfr,14,35,22,75,{1,2},"Kies 'n katalogustipe",,,,cMenuCol)
      else
         nMenu := LPICKLIST(aMenuEng,14,35,22,75,{1,2},"Choose a catalogue type",,,,cMenuCol)
      endif

      if nMenu = nil .or. nMenu = 0
         nMenu := 1
      endif

      aRecv[3,14] := aMenuAfr[nMenu,1]
   endif

return TRUE

*----------------------------------------------------------------------------
STATIC FUNCTION fGetOptn(cAfr,cEng,aOptn)

   LOCAL aCscr := fASaveScr()
   LOCAL lRetu := TRUE
   LOCAL nBoxc := 0
   LOCAL GETLIST := {}

   // Ask what to print
   DO WHILE TRUE
      AFILL(aOptn," ")
      nBoxc := fBoxCent( 5,space(66),15)
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Veilingsdiere")
         fScrBood(maxrow()  ,"Tik [J]a vir die data wat gedruk moet word - "+cAfr)
         @04,nBoxc say "[ "+cAfr+" ]"
         @06,nBoxc say "                    Opmerkings" get aOptn[CORMK] pict "@!"
         @07,nBoxc say "       Dier se prestasiesyfers" get aOptn[COWNP] pict "@!"
         @08,nBoxc say "         Dier se liggaamsmates" get aOptn[COWNM] pict "@!"
         @09,nBoxc say "     Dier se nageslagopsomming" get aOptn[COWNN] pict "@!"
         @10,nBoxc say "  Dier se dekkingsbesonderhede" get aOptn[COWNX] pict "@!"
         @11,nBoxc say "            Dier se kalfdatums" get aOptn[COWND] pict "@!"
         @12,nBoxc say "        Dier se kleiber syfers" get aOptn[COWNK] pict "@!"
         @13,nBoxc say "    Dier se teelwaardes Fase A" get aOptn[COWNA] pict "@!"
         @14,nBoxc say "    Dier se teelwaardes Fase B" get aOptn[COWNB] pict "@!"
         @15,nBoxc say "Dier se teelwaardes Fase C & D" get aOptn[COWNC] pict "@!"
         @06,nBoxc+34 say "       Vaar se prestasiesyfers" get aOptn[CSIRP] pict "@!"
         @07,nBoxc+34 say "     Vaar se nageslagopsomming" get aOptn[CSIRN] pict "@!"
         @08,nBoxc+34 say "        Vaar se kleiber syfers" get aOptn[CSIRK] pict "@!"
         @09,nBoxc+34 say "    Vaar se teelwaardes Fase A" get aOptn[CSIRA] pict "@!"
         @10,nBoxc+34 say "    Vaar se teelwaardes Fase B" get aOptn[CSIRB] pict "@!"
         @11,nBoxc+34 say "Vaar se teelwaardes Fase C & D" get aOptn[CSIRC] pict "@!"
         @13,nBoxc+34 say "       Moer se prestasiesyfers" get aOptn[CDAMP] pict "@!"
         @14,nBoxc+34 say "     Moer se nageslagopsomming" get aOptn[CDAMN] pict "@!"
         @15,nBoxc+34 say "        Moer se kleiber syfers" get aOptn[CDAMK] pict "@!"
         @16,nBoxc+34 say "    Moer se teelwaardes Fase A" get aOptn[CDAMA] pict "@!"
         @17,nBoxc+34 say "    Moer se teelwaardes Fase B" get aOptn[CDAMB] pict "@!"
         @18,nBoxc+34 say "Moer se teelwaardes Fase C & D" get aOptn[CDAMC] pict "@!"
      else
         fScrBood(maxrow()-1,"[Esc]=Sales animals")
         fScrBood(maxrow()  ,"Type [Y]es for data to be printed - "+cEng)
         @04,nBoxc say "[ "+cEng+" ]"
         @06,nBoxc say "                       Remarks" get aOptn[CORMK] pict "@!"
         @07,nBoxc say "   Animal's performance values" get aOptn[COWNP] pict "@!"
         @08,nBoxc say "    Animal's body measurements" get aOptn[COWNM] pict "@!"
         @09,nBoxc say "      Animal's progeny summary" get aOptn[COWNN] pict "@!"
         @10,nBoxc say "   Animal's mating particulars" get aOptn[COWNX] pict "@!"
         @11,nBoxc say "        Animal's calving dates" get aOptn[COWND] pict "@!"
         @12,nBoxc say "       Animal's kleiber values" get aOptn[COWNK] pict "@!"
         @13,nBoxc say " Animal's breeding values Ph-A" get aOptn[COWNA] pict "@!"
         @14,nBoxc say " Animal's breeding values Ph-B" get aOptn[COWNB] pict "@!"
         @15,nBoxc say "Animal's breeding values Ph-CD" get aOptn[COWNC] pict "@!"
         @06,nBoxc+34 say "     Sire's performance values" get aOptn[CSIRP] pict "@!"
         @07,nBoxc+34 say "        Sire's progeny summary" get aOptn[CSIRN] pict "@!"
         @08,nBoxc+34 say "         Sire's kleiber values" get aOptn[CSIRK] pict "@!"
         @09,nBoxc+34 say "   Sire's breeding values Ph-A" get aOptn[CSIRA] pict "@!"
         @10,nBoxc+34 say "   Sire's breeding values Ph-B" get aOptn[CSIRB] pict "@!"
         @11,nBoxc+34 say "  Sire's breeding values Ph-CD" get aOptn[CSIRC] pict "@!"
         @13,nBoxc+34 say "      Dam's performance values" get aOptn[CDAMP] pict "@!"
         @14,nBoxc+34 say "         Dam's progeny summary" get aOptn[CDAMN] pict "@!"
         @15,nBoxc+34 say "          Dam's kleiber values" get aOptn[CDAMK] pict "@!"
         @16,nBoxc+34 say "    Dam's breeding values Ph-A" get aOptn[CDAMA] pict "@!"
         @17,nBoxc+34 say "    Dam's breeding values Ph-B" get aOptn[CDAMB] pict "@!"
         @18,nBoxc+34 say "   Dam's breeding values Ph-CD" get aOptn[CDAMC] pict "@!"
      endif
      set confirm off
      setcursor(1)
      read
      setcursor(0)
      set confirm on

      // If escaped
      if lastkey() == K_ESC
         lRetu := FALSE
      endif

      exit
   ENDDO

   fARestScr(aCscr)

RETURN lRetu

*----------------------------------------------------------------------------
STATIC FUNCTION fCntOptn(aOptn)

   LOCAL i     := 0
   LOCAL nOptn := 0

   for i := 1 TO LEN(aOptn)
      if aOptn[i] $ "JY"
         nOptn++
      endif
   next

RETURN nOptn

*----------------------------------------------------------------------------
STATIC FUNCTION fCalAge(nDays)

   LOCAL nMths := 0
   LOCAL nRemd := nDays % 365.25
   LOCAL nYear := INT(nDays / 365.25)

   nMths := nRemd / 30.4375

   IF nMths >= 11.5
      nYear++
      nMths := 0
   ELSE
      nMths := ROUND(nMths,0)
   ENDIF

RETURN ALLTRIM(STR(nYear,4,0))+"."+ALLTRIM(STR(nMths,2,0))

*-----------------------------------------------------------------------------
STATIC FUNCTION fKatalo (cGeslag,cDragti,cLkalfn,dDekdat)

   LOCAL cKatalo := " "
   LOCAL nReko   := 0
   LOCAL nOrde   := 0
   LOCAL nPos    := RECNO()
   LOCAL nSel    := SELECT()
   LOCAL nOrd    := INDEXORD()

   IF cGeslag == "1"                             // Female animal
      IF EMPTY(cLkalfn)                          // Heifers
         IF cDragti $ "YJ"
            IF ROUND(((SM3AUCT->auctdate - SM3DATA->dekdat) / 30.4375),0) >= 9
               cKatalo := "E"                    // Make her Open cow with calf
            ELSE
               cKatalo := "B"                    // Pregnant Heifer
            ENDIF
         ELSE
            cKatalo := "A"                       // Open Heifer
         ENDIF
      ELSE                                       // Cows
         DBSELECTAREA("SM3DATA")
         nReko := RECNO()
         nOrde := INDEXORD()
         DBSETORDER(7)

         IF cDragti $ "YJ"
            IF ROUND(((SM3AUCT->auctdate - SM3DATA->dekdat) / 30.4375),0) >= 9
               cKatalo := "E"                    // Make her Open cow with calf
            ELSE
               IF DBSEEK(cLkalfn) .AND. SM3DATA->mas205 = 0
                  IF (SM3AUCT->auctdate - SM3DATA->gebdatum) > 270
                     cKatalo := "D"              // Pregnant cow
                  ELSE
                     cKatalo := "F"              // Pregnant cow with calf (3 in 1)
                  ENDIF
               ELSE
                  cKatalo := "D"                 // Pregnant cow
               ENDIF
            ENDIF
         ELSE
            IF DBSEEK(cLkalfn) .AND. SM3DATA->mas205 = 0
               IF (SM3AUCT->auctdate - SM3DATA->gebdatum) > 270
                  cKatalo := "C"                 // Open cow
               ELSE
                  cKatalo := "E"                 // Open cow with calf
               ENDIF
            ELSE
               cKatalo := "C"                    // Open cow
            ENDIF
         ENDIF

         DBSETORDER (nOrde)
         DBGOTO (nReko)
      ENDIF

   ELSEIF cGeslag == "2"                         // Male animal
      cKatalo := "G"
   ENDIF

   DBSELECTAREA (nSel)
   DBSETORDER (nOrd)
   DBGOTO (nPos)

RETURN cKatalo

/******************************************************************************/
STATIC FUNCTION fFile()

   // Function to prepare file with sales data

   // Declare
   local getlist := {}
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lRetu := .t.
   local nBoxc := 0
   local nBree := 0
   local nSale := 0
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local aStam := {}
   local i     := 0
   local dDgeb := ctod("")
   local dDkal := ctod("")
   local dMgeb := ctod("")
   local dMkal := ctod("")

   begin sequence

      // Ask for web breeder reference number
      if cLanType() = "A"
         fScrBood(maxrow()-1,"[Esc]=Katalogus")
         fScrBood(maxrow()  ,"Tik 'n webblad telerverwysingsnommer of LAAT OOP indien onbekend!")
         nBoxc := fBoxCent(11,"Web Telerverwysingsnommer? "+space(4),3)
         @12,nBoxc say "Web Telerverwysingsnommer?" get nBree pict "9999"
      else
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Type a web page breeder reference number or LEAVE OPEN if unknown!")
         nBoxc := fBoxCent(11,"Web Breeder reference number?"+space(4),3)
         @12,nBoxc say "Web Breeder reference number?" get nBree pict "9999"
      endif
      setcursor(1)
      read
      setcursor(0)
      // If escaped
      if lastkey() == K_ESC
         lRetu := .f.
         break
      endif
      fARestScr(aCscr)

      // Ask for web sale reference number
      if cLanType() = "A"
         fScrBood(maxrow()-1,"[Esc]=Katalogus")
         fScrBood(maxrow()  ,"Tik 'n webblad veilingverwysingsnommer of LAAT OOP indien onbekend!")
         nBoxc := fBoxCent(11,"Web Veilingverwysingsnommer? "+space(4),3)
         @12,nBoxc say "Web Veilingverwysingsnommer?" get nSale pict "9999"
      else
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Type a web page sale reference number or LEAVE OPEN if unknown!")
         nBoxc := fBoxCent(11,"Web Sale reference number?"+space(4),3)
         @12,nBoxc say "Web Sale reference number?" get nSale pict "9999"
      endif
      setcursor(1)
      read
      setcursor(0)
      // If escaped
      if lastkey() == K_ESC
         lRetu := .f.
         break
      endif
      fARestScr(aCscr)

      // Get the drive
      cDriv := stdfile()
      if empty(cDriv)
         lRetu := .f.
         break
      endif

      // Create the file
      cFile := cDriv
      set alternate to (cFile)
      set alternate on
      set console off

      // Save first line
      ?? "BreederRefNo"
      ?? ",SaleRefNo"
      ?? ",LotNo"
      ?? ",CatalogueType"
      ?? ",IdNumber"
      ?? ",DateOfBirth"
      ?? ",Sex"
      ?? ",Generation"
      ?? ",CalfBookNo"
      ?? ",RegistrationNo"

      // Data dier self a en b prestasiedata
      ?? ",BirthMass"
      ?? ",Mass100"
      ?? ",Cmas100"
      ?? ",Ada100"
      ?? ",Inde100"
      ?? ",Cont100"
      ?? ",Mass205"
      ?? ",Cmas205"
      ?? ",Ada205"
      ?? ",Inde205"
      ?? ",Cont205"
      ?? ",Mass365"
      ?? ",Cmas365"
      ?? ",Ada365"
      ?? ",Inde365"
      ?? ",Cont365"
      ?? ",Mass540"
      ?? ",Cmas540"
      ?? ",Ada540"
      ?? ",Inde540"
      ?? ",Cont540"

      // Data dier self c en d data
      if "D" $ SM3DATA->fasekode
         ?? ",Phase"
         ?? ",Ada"
         ?? ",AdaInde"
         ?? ",Adg"
         ?? ",AdgInde"
         ?? ",MassFinal"
         ?? ",Contemp"
         ?? ",FeedConv"
         ?? ",FeedConvInde"
      elseif "C" $ SM3DATA->fasekode
         ?? ",Phase"
         ?? ",Ada"
         ?? ",AdaInde"
         ?? ",Adg"
         ?? ",AdgInde"
         ?? ",MassFinal"
         ?? ",Contemp"
         ?? ",FeedConv"
         ?? ",FeedConvInde"
      else
         ?? ",Phase"
         ?? ",Ada"
         ?? ",AdaInde"
         ?? ",Adg"
         ?? ",AdgInde"
         ?? ",MassFinal"
         ?? ",Contemp"
         ?? ",FeedConv"
         ?? ",FeedConvInde"
      endif
      ?? ",Height"
      ?? ",Length"
      ?? ",L:H"
      ?? ",Scrotum"
      ?? ",Skin"

      // Dier blup data
      ?? ",BirDir"
      ?? ",BirMat"
      ?? ",WeaDir"
      ?? ",WeaMat"
      ?? ",YeaDir"
      ?? ",M18Dir"
      ?? ",AdgDir"
      ?? ",KleDir"
      ?? ",ScrDir"
      ?? ",HgtDir"
      ?? ",LgtDir"
      ?? ",FcrDir"
      ?? ",CatDir"

      // Dier se eie produksiesyfers
      ?? ",AgeFirstCalf"
      ?? ",AgeLastCalf"
      ?? ",NoCalves"
      ?? ",AvgWeanInd"
      ?? ",NoCalvesWeaned"
      ?? ",ICP"
      ?? ",ReprInde"

      // Data van dier se laaste dekking
      ?? ",MatingBull"
      ?? ",MatingType"
      ?? ",MatingGeneration"
      ?? ",MatingMonths"

      // Data van dier se laaste kalf
      ?? ",LastCalfId"
      ?? ",LastCalfCalfBook"
      ?? ",LastCalfCompNumb"
      ?? ",LastCalfSex"
      ?? ",LastCalfGeneration"
      ?? ",LastCalfDateOfBirth"
      ?? ",LastCalfSire"
      ?? ",LastCalfBirthDay"
      ?? ",LastCalfBirthMonth"
      ?? ",LastCalfBirthYear"

      // Dier se stamboom
      ?? ",Sire"
      ?? ",Dam"
      ?? ",SireSire"
      ?? ",SireDam"
      ?? ",DamSire"
      ?? ",DamDam"
      ?? ",SireSireSire"
      ?? ",SireSireDam"
      ?? ",SireDamSire"
      ?? ",SireDamDam"
      ?? ",DamSireSire"
      ?? ",DamSireDam"
      ?? ",DamDamSire"
      ?? ",DamDamDam"

      // Data van die dier se ma
      ?? ",DamGeneration"
      ?? ",DamCalfBook"
      ?? ",DamCompNumb"
      ?? ",DamAgeFirstCalf"
      ?? ",DamAgeLastCalf"
      ?? ",DamNoCalves"
      ?? ",DamAvgWeanInd"
      ?? ",DamNoCalvesWeaned"
      ?? ",DamIcp"
      ?? ",DamReprInde"

      // Data van die dier se pa
      ?? ",SireGeneration"
      ?? ",SireCalfBook"
      ?? ",SireCompNumb"

      // Ander velde
      ?? ",Remark"
      ?? ",BirthDay"
      ?? ",BirthMonth"
      ?? ",BirthYear"
      ?

      // Go to top of file
      select SM3VEIL
      go top

      // The data loop
      do while !eof()

         // Data dier self
         ?? alltrim(str(nBree))                  // BreederRef
         ?? ","+alltrim(str(nSale))              // SaleRef
         ?? ","+alltrim(str(int(SM3VEIL->lotnom)))+alltrim(num2alpha(remdec(SM3VEIL->lotnom)))
         ?? ","+alltrim(SM3VEIL->katalo)         // Catalogue Type
         ?? ","+alltrim(SM3VEIL->idnr)
         ?? ","+alltrim(dtoc(SM3DATA->gebdatum))
         ?? ","+alltrim(SM3DATA->geslag)
         ?? ","+alltrim(SM3DATA->generasie)
         ?? ","+alltrim(SM3DATA->kalfbnr)
         ?? ","+alltrim(SM3DATA->reknr)

         // Data dier self a en b prestasiedata
         ?? ","+alltrim(str(SM3DATA->gebmassa))
         ?? ","+alltrim(str(SM3DATA->mas100))
         ?? ","+alltrim(str(SM3DATA->gma100))
         ?? ","+alltrim(str(SM3DATA->gdo100))
         ?? ","+alltrim(str(SM3DATA->ind100))
         ?? ","+alltrim(str(SM3DATA->aan100))
         ?? ","+alltrim(str(SM3DATA->mas205))
         ?? ","+alltrim(str(SM3DATA->gma205))
         ?? ","+alltrim(str(SM3DATA->gdo205))
         ?? ","+alltrim(str(SM3DATA->ind205))
         ?? ","+alltrim(str(SM3DATA->aan205))
         ?? ","+alltrim(str(SM3DATA->mas365))
         ?? ","+alltrim(str(SM3DATA->gma365))
         ?? ","+alltrim(str(SM3DATA->gdo365))
         ?? ","+alltrim(str(SM3DATA->ind365))
         ?? ","+alltrim(str(SM3DATA->aan365))
         ?? ","+alltrim(str(SM3DATA->mas540))
         ?? ","+alltrim(str(SM3DATA->gma540))
         ?? ","+alltrim(str(SM3DATA->gdo540))
         ?? ","+alltrim(str(SM3DATA->ind540))
         ?? ","+alltrim(str(SM3DATA->aan540))

         // Data dier self c en d data
         if "D" $ SM3DATA->fasekode
            ?? ","+"D"
            ?? ","+alltrim(str(SM3DATA->gdogdo))
            ?? ","+alltrim(str(SM3DATA->gdoind))
            ?? ","+alltrim(str(SM3DATA->gdtgdt))
            ?? ","+alltrim(str(SM3DATA->gdtind))
            ?? ","+alltrim(str(SM3DATA->einmas))
            ?? ","+alltrim(str(SM3DATA->tydgen))
            ?? ","
            ?? ","+alltrim(str(SM3DATA->kleiberi))
         elseif "C" $ SM3DATA->fasekode
            ?? ","+"C"
            ?? ","+alltrim(str(SM3DATA->gdogdo))
            ?? ","+alltrim(str(SM3DATA->gdoind))
            ?? ","+alltrim(str(SM3DATA->gdtgdt))
            ?? ","+alltrim(str(SM3DATA->gdtind))
            ?? ","+alltrim(str(SM3DATA->einmas))
            ?? ","+alltrim(str(SM3DATA->tydgen))
            ?? ","+alltrim(str(SM3DATA->voeromset))
            ?? ","+alltrim(str(SM3DATA->voeromseti))
         else
            ?? ","+"B"
            ?? ","
            ?? ","
            ?? ","
            ?? ","
            ?? ","
            ?? ","
            ?? ","
            ?? ","
         endif
         if !empty(SM3DATA->gekhoo)
            ?? ","+alltrim(str(SM3DATA->gekhoo))
         else
            ?? ","+alltrim(str(SM3DATA->mateskouer))
         endif
         if !empty(SM3DATA->geklen)
            ?? ","+alltrim(str(SM3DATA->geklen))
         else
            ?? ","+alltrim(str(SM3DATA->matelengte))
         endif
         ?? ","+alltrim(str(SM3DATA->hoolen))
         if !empty(SM3DATA->gekskr)
            ?? ","+alltrim(str(SM3DATA->gekskr))
         else
            ?? ","+alltrim(str(SM3DATA->mateskrot))
         endif
         //if !empty(SM3DATA->gekvel)
         //   ?? ","+alltrim(str(SM3DATA->gekvel))
         //else
         ?? ","+alltrim(str(SM3DATA->veldikte))
         //endif

         // Dier blup data
         ?? ","+alltrim(str(SM3DATA->birdir))
         ?? ","+alltrim(str(SM3DATA->birmat))
         ?? ","+alltrim(str(SM3DATA->weadir))
         ?? ","+alltrim(str(SM3DATA->weamat))
         ?? ","+alltrim(str(SM3DATA->yeadir))
         ?? ","+alltrim(str(SM3DATA->m18dir))
         ?? ","+alltrim(str(SM3DATA->adgdir))
         ?? ","+alltrim(str(SM3DATA->kledir))
         ?? ","+alltrim(str(SM3DATA->scrdir))
         ?? ","+alltrim(str(SM3DATA->hgtdir))
         ?? ","+alltrim(str(SM3DATA->lgtdir))
         ?? ","+alltrim(str(SM3DATA->pcfcrd))
         ?? ","+alltrim(str(SM3DATA->eocdir))

         // Dier se eie produksiesyfers
         dDgeb := SM3DATA->gebdatum
         dDkal := SM3DATA->lkalfdatum
         ?? ","+alltrim(str(SM3DATA->oudekalf))
         if !empty(dDgeb) .and. !empty(dDkal) .and. dDkal > dDgeb
            ?? "," + fCalAge(dDkal - dDgeb)
         else
            ?? ",0"
         endif
         ?? ","+alltrim(str(SM3DATA->kalfaantal))
         ?? ","+alltrim(str(SM3DATA->gemspeeni))
         ?? ","+alltrim(str(SM3DATA->gemspeena))
         ?? ","+alltrim(str(SM3DATA->gemkalfin))
         ?? ","+alltrim(str(SM3DATA->repind))

         // Data van dier se laaste dekking
         ?? ","+alltrim(SM3DATA->bulid)
         ?? ","+alltrim(SM3DATA->tipede)
         ?? ","+fParentData(SM3DATA->bulid,"generasie")
         // Maande dragtig
         if ! EMPTY(SM3DATA->dekdat)
            ?? ","+str((SM3AUCT->auctdate - SM3DATA->dekdat) / 30.4375,2,0)
         else
            ?? ","
         endif

         // Data van dier se laaste kalf
         ?? ","+alltrim(SM3DATA->lkalfn)
         ?? ","+fParentData(SM3DATA->lkalfn,"kalfbnr")
         ?? ","+fParentData(SM3DATA->lkalfn,"reknr")
         ?? ","+fParentData(SM3DATA->lkalfn,"geslag")
         ?? ","+fParentData(SM3DATA->lkalfn,"generasie")
         ?? ","+fParentData(SM3DATA->lkalfn,"gebdatum")
         ?? ","+fParentData(SM3DATA->lkalfn,"idvaar")
         dDkal := ctod(fParentData(SM3DATA->lkalfn,"gebdatum"))
         ?? ","+right(dtos(dDkal),2)
         ?? ","+substr(dtos(dDkal),5,2)
         ?? ","+left(dtos(dDkal),4)

         // Dier se stamboom
         aStam := fStamboom(SM3VEIL->idnr)
         for i := 2 to len(aStam)
            ?? ","+alltrim(aStam[i,1])
         next

         // Data van die dier se ma
         dMgeb := ctod(fParentData(aStam[3,1],"gebdatum"))
         dMkal := ctod(fParentData(aStam[3,1],"lkalfdatum"))
         ?? ","+fParentData(aStam[3,1],"generasie")
         ?? ","+fParentData(aStam[3,1],"kalfbnr")
         ?? ","+fParentData(aStam[3,1],"reknr")
         ?? ","+fParentData(aStam[3,1],"oudekalf")
         if !empty(dMgeb) .and. !empty(dMkal) .and. dMkal > dMgeb
            ?? "," + fCalAge(dMkal - dMgeb)
         else
            ?? ",0"
         endif
         ?? ","+fParentData(aStam[3,1],"kalfaantal")
         ?? ","+fParentData(aStam[3,1],"gemspeeni")
         ?? ","+fParentData(aStam[3,1],"gemspeena")
         ?? ","+fParentData(aStam[3,1],"gemkalfin")
         ?? ","+fParentData(aStam[3,1],"repind")

         // Data van die dier se pa
         ?? ","+fParentData(aStam[2,1],"generasie")
         ?? ","+fParentData(aStam[2,1],"kalfbnr")
         ?? ","+fParentData(aStam[2,1],"reknr")

         // Ander velde
         ?? ","+alltrim(SM3VEIL->opmerk)
         ?? ","+right(dtos(SM3DATA->gebdatum),2)
         ?? ","+substr(dtos(SM3DATA->gebdatum),5,2)
         ?? ","+left(dtos(SM3DATA->gebdatum),4)
         ?

         // Next animal
         select SM3VEIL
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fParentData(cIdnr,cVeld)

   // Function to get the dam's data

   // Declare
   local cRetu := ""
   local aCdbf := fATopen()
   local nFiel := 0
   begin sequence

      // Make the main data file current
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus(1)

      // Locate the sire
      seek cIdnr

      if found()

         nFiel := fieldpos(cVeld)
         if type(cVeld) == "N"
            cRetu := alltrim(str(fieldget(nFiel)))
         elseif type(cVeld) == "D"
            set cent on
            cRetu := alltrim(dtoc(fieldget(nFiel)))
            set cent off
         else
            cRetu := alltrim(fieldget(nFiel))
         endif

      endif

   end
   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
STATIC FUNCTION remdec(nData)

   // Function to return the decimal part of a numeric

   local nRetu := 0
   local nInte := 0

   nRetu := nData - int(nData)

return nRetu

/******************************************************************************/
STATIC FUNCTION num2alpha(nData)

   // Function to convert numerics to alphas

   local cRetu := ""
   local cData := ""

   cData := left(alltrim(str(nData)),3)

   do case
      case cData == "0.1"
         cRetu := " A  "
      case cData == "0.2"
         cRetu := " B  "
      case cData == "0.3"
         cRetu := " C  "
      case cData == "0.4"
         cRetu := " D  "
      case cData == "0.5"
         cRetu := " E  "
      case cData == "0.6"
         cRetu := " F  "
      case cData == "0.7"
         cRetu := " G  "
      case cData == "0.8"
         cRetu := " H  "
      case cData == "0.9"
         cRetu := " I  "
   endcase

return cRetu
