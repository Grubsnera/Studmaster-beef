//SM3KALE.PRG
//Program om dagboek inskrywings te bewaar/skrap
//Kopiereg (c) 1992 A van Rensburg
//12:44pm May 26,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3kale( nTop, nLeft, nBottom, aVelde, dFind )

   //Veranderlikes
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := Setcursor(0)                 //Cursor
   LOCAL aAdraOp := {}                           //Plaas opskrifte
   local aKaleOp := {}
   LOCAL nScrlen := 0                            //Totale lengte van die veld
   LOCAL nBoxCoo := 0                            //Waar begin en endig die boks
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i                                       //Counter
   LOCAL lMore                                   //Logical looper
   LOCAL nKey                                    //Keypress
   LOCAL dReturn := dFind                        //Return value
   LOCAL lLogic                                  //Diverse logic carrier
   LOCAL cLocate := ""
   LOCAL cFilter := space(25)
   LOCAL ckale
   LOCAL bDatu   := 99/99/99
   LOCAL eDatu   := 99/99/99
   local cLocScr := ""
   local nBoxCoor := 0
   local getlist := {}

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 3, nTop )
   nLeft := if( nLeft == NIL, 3, nLeft )
   nBottom := if( nBottom == NIL, 4, nBottom )
   dFind := if( dFind == NIL, dAppDate(), dFind )

   //Skerm
   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrOpsk(1,"Option "+cOption())
      fScrBood(24,"Screen outlay being determined")
   endif
   fScrBood(23)

   //Kry die veldbeskrywings
   //aVelde is array met velde wat vertoon moet word
   //akaleOp is array met volledige veldbesonderhede
   akaleOp := fGetfield( aVelde )

   //Kry totale lengte van velde om breedte van venster te bepaal
   for i = 1 to len( akaleOp )
      //Lengte
      nScrlen := nScrlen + akaleOp[i,4] + 1

      //Kolomme
      cData := akaleOp[i,1] + akaleOp[i,2]
      cHead := akaleOp[i,7] + ";" + akaleOp[i,8] + ";" + akaleOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
   next
   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die boks
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "DAGBOEK" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "DIARY" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas Kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Datalˆers word geopen")
   else
      fScrBood(24,"Data files being opened")
   endif

   //Open die .dbf
   ckale := fTOpen( cDd(), "SM3KALE", , "dbf", , .t., .f. )
   if left(ckale, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurscr )
      restscreen( 0, 0, 24, 79, cCurske )
      return dReturn
   endif

   //Skuif die databasis
   if dFind <> ctod("")
      set soft on
      seek dtos(dFind)
      set soft off
      if eof()
         go top
      endif
   endif

   //Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar  [Alt E]=Verander  [Alt P]=Druk     " )
         fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [0 - 3]=Vind      [Alt F]=Filter   " )
      else
         fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [Alt E]=Edit  [Alt P]=Print ")
         fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [0 - 3]=Find  [Alt F]=Filter")
      endif

      //Vries
      //cBrowse:Freeze := 2

      //Sabilize display until stable or key is pressed
      nKey := 0
      do while nKey == 0 .and. .not. cBrowse:stable
         cBrowse:stabilize()
         nKey := InKey()
      enddo

      if cBrowse:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         cBrowse:refreshCurrent()
         ForceStable(cBrowse)
         // Everything's done -- wait for a key
         nKey := Inkey(0)
      endif

      if nKey == K_ESC
         // Esc means Leave
         lMore := .f.

      elseif nKey == K_ENTER
         //Enter means return kode and exit
         dReturn := fieldget(1)
         lMore := .f.

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey ==K_ALT_E
         //Alt E means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_P
         //Alt P means print a record
         fPrint()
         cBrowse:refreshall()

      elseif nKey == K_DEL
         // Del means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_F
         //Alt F
         cLocScr := savescreen( 0, 0, 24, 79 )
         cFilter := padr(cfilter,25)
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(23,"                 [Esc] Gaan terug na Dagboekinskrywing.              ")
            fScrBood(24,"Tik die gedeelte van die dagboekinskrywing waarvoor gesoek moet word.")
            nBoxCoor := fBoxCent( 11, "Watter Dagboekinskrywing? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 3, "FILTER" )
            @12, nBoxCoor say "Watter Dagboekinskrywing?" get cFilter pict "@!"
         else
            fScrBood(23,"                 [Esc] Return to Diary entry.           ")
            fScrBood(24,"Type a section of the diary entry which should be found.")
            nBoxCoor := fBoxCent( 11, "Which Diary entry? xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 3, "FILTER" )
            @12, nBoxCoor say "Which Diary entry? " get cFilter pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )

         //Escaped
         if lastkey() == K_ESC
         else
            if cFilter == space(25)
               set filter to
               set soft on
               seek dtos(dAppDate())
               set soft off
               if eof()
                  go top
               endif
            else
               cFilter := alltrim(cFilter)
               set filter to cFilter $ upper(SM3KALE->handeling)
               go top
            endif
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3kale",1,"oorsig"

      elseif nKey >= 48 .and. nKey <= 51
         // Means locate a record
         cLocate := upper(chr( nKey ) ) + space(7)
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik die datum waarvoor gesoek moet word.")
         else
            fScrBood(24,"Type the date which should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 11, "Vind watter Datum? xxxxxxxx", 3 )
            @12, nBoxCoor say "Vind watter Datum?" get cLocate pict "99/99/99"
         else
            nBoxCoor := fBoxCent( 12, "Find what Date? xxxxxxxx", 3 )
            @12, nBoxCoor say "Find what Date? " get cLocate pict "99/99/99"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            set soft on
            seek dtos(ctod(cLocate))
            set soft off
            if eof()
               go top
            endif
            cBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   fTClose( ckale )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurske )
   setcursor( cCurCur )

return dReturn

/**************************************************************************/
STATIC FUNCTION fAddChg

   //Veranderlikes
   LOCAL Getlist := {}
   LOCAL cCurSke := Savescreen( 0, 0, 24, 79 )
   LOCAL aSend   := {}
   LOCAL aRecv   := {}
   LOCAL nRekord := 0
   LOCAL aData   := {}
   LOCAL nBoxCoor:= 0
   LOCAL nLoop   := 0
   LOCAL lLoop   := .t.
   LOCAL i       := 1
   LOCAL lReturn := .f.
   LOCAL aVelde  := {}
   LOCAL aProd   := {}

   //Kry die velde benodig
   asize( aSend, 0 )
   aadd( aSend, { "sm3kale", "datum " })
   aadd( aSend, { "sm3kale", "handeling" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
   else
      nRekord := recno()
   endif

   //Lees data
   for i = 1 to len( aRecv )
      aRecv[i][14] := Fieldget( aRecv[i,13] )
   next

   //Skerm
   if cLanType() == "A"
      nBoxCoor := fBoxCent( 9, space(50), 4, "BEWAAR/VERANDER DAGBOEK" )
   else
      nBoxCoor := fBoxCent( 9, space(50), 4, "ENTER/EDIT DIARY" )
   endif

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @  10, nBoxCoor say aRecv[1 ,6]
   @  11, nBoxCoor say aRecv[2 ,6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @ 10, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
         @ 11, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Dagdag
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na dagboek." )
               fScrBood( 24, "Tik die datum. " )
            else
               fScrBood( 23, "[Esc]=Return to diary." )
               fScrBood( 24, "Type the date." )
            endif
            @  10, nBoxCoor say aRecv[1,6] get aRecv[1][14] pict aRecv[1,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC
               if eof()
                  go top
               endif
               nLoop := 0
               loop
            endif
            if aRecv[1][14] == ctod("")
               if eof()
                  go top
               endif
               nLoop := 0
               loop
            endif
            lReturn := .t.

            nLoop++
            loop
            go bottom
            skip
            //Vul data
            for i = 1 to len( aRecv )
               aRecv[i][14] := fieldget( aRecv[i,13] )
            next

         case nLoop == 2
            //Maandd
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na die Dagboek." )
               fScrBood( 24, "Tik die Dagboekinskrywing. " )
            else
               fScrBood( 23, "[Esc]=Return to the Diary. " )
               fScrBood( 24, "Type the Diary entry." )
            endif
            @ 11, nBoxCoor say aRecv[2,6] get aRecv[2][14] pict aRecv[2,10]
            set curs on
            read
            set curs off

            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++

               otherwise
                  loop
            endcase

         otherwise
            //Bewaar rekord

            if nRekord > 0
               goto nRekord
            else
               appe blank
            endif

            lLoop := .t.
            do while lLoop
               if rlock()
                  for i = 1 to len( aRecv )
                     //Bewaar die data
                     fieldput( aRecv[i,13], aRecv[i][14] )
                     //Maak datavelde skoon
                     do case
                        case aRecv[i][3]  == "N"
                           aRecv[i][14] := 0
                        case aRecv[i][3]  == "D"
                           aRecv[i][14] := ctod("  /  /  ")
                        otherwise
                           aRecv[i][14] := space(aRecv[i,4] )
                     endcase
                  next
                  commit
                  exit
               endif
            enddo

            if nRekord = 0
               nLoop := 1
            else
               nRekord = 0
               nLoop := 0
            endif
      endcase
   enddo

   //Herstel
   restscreen( 0,0,24,79, cCurske )
return lReturn

/**************************************************************************/
STATIC FUNCTION fDelete
   //Funksie om enige produktipe totaal en al te skrap
   //Verklaar
   LOCAL lReturn := .f.

   fScrBood( 23, Trim( SM3KALE->Handeling) + " - " +  dtoc(SM3KALE->Datum) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde Dagboekinskrywing geskrap word?", , .f. )
         if rlock()
            delete
            dbUnlock()
            skip
            if eof()
               go top
            endif
            lReturn := .t.
         endif
      endif
   else
      if fJaNee( 24, "Should above Diary entry be deleted?", , .f. )
         if rlock()
            delete
            dbUnlock()
            skip
            if eof()
               go top
            endif
            lReturn := .t.
         endif
      endif
   endif


return lReturn
/***********************************************************************/
STATIC FUNCTION fPrint

   //Verklaar
   local cCurScr := savescreen(0,0,24,79)
   local dBdate  := ctod("")
   local dEdate  := ctod("")
   LOCAL aVelde  := {}
   LOCAL aDbfOp  := {}
   LOCAL cWaar   := NIL
   LOCAL nTotaal := 1
   LOCAL lLoop   := .t.
   LOCAL nI      := 1
   LOCAL nRekord := 1
   local nBoxc   := 0
   local cSeek   := ""
   local cMess   := "DAGBOEK"
   local getlist := {}
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   PRIVATE cData

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Databasis
   select SM3KALE
   go top
   nTotaal := lastrec()


   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif

   //Kry die velde wat gedruk moet word
   asize( aVelde, 0 )
   aadd( aVelde, { "sm3kale", "datum" } )
   aadd( aVelde, { "sm3kale", "handeling" })
   aDbfOp := fGetField( aVelde )

   //Bepaal die drukgrootte
   nWidt := 0
   for nI = 1 to len(aDbfOp)
      nWidt+= aDbfOp[nI][4]+1
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

   //Teken skerm
   nBoxc := fBoxCent(10,space(36),5,cMess)
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Terug na Dagboek")
      fScrBood(24,"Tik van wanneer tot wanneer die dagboek gedruk moet word.")
   else
      fScrBood(23,"[Esc]=Return to Diary")
      fScrBood(24,"Type from when to when the diary should be printed.")
   endif

   //Vra die datums
   dBdate := dAppDate()
   dEdate := dAppDate() + 30
   if cLanType() == "A"
      @11,nBoxc say "Vanaf watter datum?" get dBdate
      @13,nBoxc say "  Tot watter datum?" get dEdate
   else
      @11,nBoxc say "    From what date?" get dBdate
      @13,nBoxc say "      To what date?" get dEdate
   endif

   //Read
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC
      select SM3KALE
      go top
      restscreen(0,0,24,79,cCurScr)
      return NIL
   endif

   //Soekstring
   if cLanType() == "A"
      do case
         case dBdate <> ctod("") .and. dEdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'").and.datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "DAGBOEK VANAF " + dtoc(dBdate) + " TOT " + dtoc(dEdate)
         case dBdate == ctod("") .and. dEdate == ctod("")
            cSeek := 'datum<>ctod("")'
            cMess := "DAGBOEK"
         case dBdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'")'
            cMess := "DAGBOEK NA " + dtoc(dBdate)
         case dEdate <> ctod("")
            cSeek := 'datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "DAGBOEK VOOR " + dtoc(dEdate)
         otherwise
            cSeek := 'datum<>ctod("")'
            cMess := "DAGBOEK"
      endcase
   else
      do case
         case dBdate <> ctod("") .and. dEdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'").and.datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "DIARY FROM " + dtoc(dBdate) + " TO " + dtoc(dEdate)
         case dBdate == ctod("") .and. dEdate == ctod("")
            cSeek := 'datum<>ctod("")'
            cMess := "DIARY"
         case dBdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'")'
            cMess := "DIARY AFTER " + dtoc(dBdate)
         case dEdate <> ctod("")
            cSeek := 'datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "DIARY BEFORE " + dtoc(dEdate)
         otherwise
            cSeek := 'datum<>ctod("")'
            cMess := "DIARY"
      endcase
   endif

   nTotaal := lastrec()
   go top

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Dagboek word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Diary being printed!  [Esc]=Stop printer." )
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
            @prow()  ,nWidt-len(cMess)+1 say cMess
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
            @prow()  ,nWidt-len(cMess)+1 say cMess
         endif
         @prow()+1,  1 say repl( "=", nWidt )

         //1e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] )
            endif
         next

         //2e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4])
            endif
         next

         //3e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4])
            endif
         next

         //4e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say repl( "-", aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say repl( "-", aDbfOp[nI,4] )
            endif
         next
      endif

      //Toets of drukker moet stop
      If fPrnStop() = K_ESC
         fTClose( cWaar )
         return NIL
      endif

      //Data
      if &cSeek
         for nI = 1 to len( aDbfOp )
            cData := aDbfOp[nI,1] + aDbfOp[nI,2]
            if nI == 1
               @prow()+1,  1 say &cData
            else
               @prow()  ,pcol()+1 say &cData
            endif
         next
      endif

      //Skerm
      // fPrnOff()
      // if nTotaal > 0
      //    setcolor( cColBott() )
      //    fScrBood(23)
      //    if cLanType() == "A"
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Voltooi"
      //    else
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Completed"
      //    endif
      //    setcolor( cColNorm() )
      //    nRekord++
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()
         //Print onderste lyn
         @prow()+1,  1 say repl( "=", nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
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
return NIL

