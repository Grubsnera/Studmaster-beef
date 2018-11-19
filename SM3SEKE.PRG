//SM3SEKE.PRG
//Program om sekere data te vertoon
//Kopiereg (c) 1992 A van Rensburg
//09:19 24 Mar,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

#xtrans GetSetBlock( <v> ) => {|x| if( x == NIL, <v>, <v> := x ) }

/************************************************************************/
FUNCTION sm3seke( nTop, nLeft, nBottom, aVelde, cFind )

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL aCscr  := {}
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := setcursor(0)                 //Cursor
   LOCAL aSekeOp := {}                           //Plaas opskrifte
   LOCAL nScrLen := 0                            //Totale lengte van die velde
   LOCAL nBoxCoo := 0                            //Waar begin en eindig die box
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i                                       //Counter
   LOCAL lMore                                   //Logical looper
   LOCAL nKey                                    //Keypress
   LOCAL lLogic                                  //Diverse logic carrier
   LOCAL cLocate := ""
   LOCAL cSeke
   local cLocScr := ""
   local nBoxcoor := 0

   //Hierdie program spesifieke veranderlikes
   local aReturn := {}
   local nTel    := 1
   local lVeld   := .f.

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Opskrif
   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   aCscr := fASaveScr()

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   cFind := if( cFind == NIL, "      ", cFind )

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrBood(24,"Screen outlay being determined")
   endif

   //Kry die veldbeskrywings
   //aVelde is die array met velde wat vertoon moet word
   //aSekeOp is die array met die volledige veldbesonderhede
   aSekeOp := fGetField( aVelde )

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len( aSekeOp )

      //Lengte
      nScrLen := nScrLen + aSekeOp[i,4] + 1

      //Kolomme
      cData := aSekeOp[i,1] + aSekeOp[i,2]
      cHead := aSekeOp[i,7] + ";" + aSekeOp[i,8] + ";" + aSekeOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "SEKERE INLIGTING BEWAAR SKERMS" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "CERTAIN INFORMATION INPUT SCREENS" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas kolomme oor na die browse object
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
   cSeke := fTOpen( cDd(), "sm3seke", , "dbf", , .t., .f. )
   if left( cSeke, 1 ) == "f"
      fTClose( cCurDbf )
      fARestScr(aCscr)
      return aReturn
   endif

   //Skuif die databasis
   if len( alltrim( cFind ) ) <> 0
      seek cFind
      if eof()
         go top
      endif
   endif

   // Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[Esc]  [Enter]  [Ins ]  [Del]  [Alt E ]  [Alt F]  [  Alt S  ]  [A-Z]  [F1]" )
         fScrBood( 24, " Menu   Kies    Bewaar  Skrap  Verander   Velde   Skrap velde   Vind  Hulp" )
      else
         fScrBood( 23, "[Esc]  [Enter]  [Ins]ert  [Del ]  [Alt E]  [Alt F]  [  Alt S    ]  [A-Z]  [F1]" )
         fScrBood( 24, "Menu   Choice   EnterNew  Delete  Edit     Fields   Delete fields  Find   Help" )
      endif

      //Vries
      //cBrowse:freeze := 2

      // Stabilize the display until it's stable or a key is pressed
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
         // Everything's done -- just wait for a key
         if lVeld
            keyboard chr(145)
            lVeld := .f.
         endif
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         // Esc means leave
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means return plaaskode and exit
         //Bou array vanaf databasis
         for i = 1 to 40
            if substr(SM3SEKE->veld,nTel,10) <> space(10) .and. substr(SM3SEKE->veld,nTel+10,10) <> space(10)
               aadd( aReturn, { trim(substr(SM3SEKE->veld,nTel,10)), trim(substr(SM3SEKE->veld,nTel+10,10)) } )
            endif
            nTel := nTel + 20
         next
         if len( aReturn ) > 0
            lMore := .f.
         else
            if cLanType() == "A"
               fScrBood(23,"Geen velde is gedefinieer nie!")
               fScrWait(24)
            else
               fScrBood(23,"No fields have been defined!")
               fScrWait(24)
            endif
         endif

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         go bottom
         skip
         if fACseke()
            lVeld := .t.
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E
         //Alt V means change a record
         if fACseke()
            lVeld := .t.
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_P
         //Alt P means print a record
         fPrint()
         cBrowse:refreshall()

      elseif nKey == K_ALT_F .or. nKey == 145
         //Alt P means print a record
         fVelde()

      elseif nKey == K_ALT_S
         //Alt S means clear all the defined fields
         if rlock()
            SM3SEKE->veld := space(800)
            dbUnlock()
         endif

      elseif nKey == K_DEL
         // Insert means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3seke",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + "     "
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik die gedeelte van die kode waarvoor gesoek moet word.")
         else
            fScrBood(24,"Type a section of the code which should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter Kode? xxxxxx", 1 )
            @12, nBoxCoor say "Vind watter Kode?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find what Code? xxxxxx", 1 )
            @12, nBoxCoor say "Find what Code?" get cLocate pict "@!"
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
            cBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   fTClose( cSeke )
   fTClose( cCurDbf )
   fARestScr(aCscr)
   setcursor( cCurCur )

return aReturn

/*************************************************************************/
STATIC FUNCTION fACseke

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )
   LOCAL aSend := {}
   LOCAL aRecv := {}
   LOCAL nRekord
   LOCAL aData := {}
   LOCAL nBoxCoor
   LOCAL nLoop
   LOCAL lLoop
   LOCAL i
   LOCAL lReturn := .f.

   //Kry die velde benodig
   asize( aSend, 0 )
   aadd( aSend, { "sm3seke", "kode" })
   aadd( aSend, { "sm3seke", "besk" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
   else
      nRekord := recno()
   endif
   asize( aData, 0 )
   aData := {}
   for i = 1 to len( aRecv )
      aadd( aData, fieldget( aRecv[i,13] ) )
   next

   //Skerm
   if cLanType() == "A"
      nBoxCoor := fBoxCent( 10, space(50), 4, "BEWAAR/VERANDER SEKERE INLIGTING BEWAARSKERMS" )
   else
      nBoxCoor := fBoxCent( 10, space(50), 4, "ENTER/EDIT CERTAIN INFORMATION INPUT SCREENS" )
   endif

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @ 11, nBoxCoor say aRecv[1,6]
   @ 12, nBoxCoor say aRecv[2,6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @ 11, nBoxCoor+21 say transform( aData[1], aRecv[1,10] )
         @ 12, nBoxCoor+21 say transform( aData[2], aRecv[2,10] )
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Kode

            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Sekere Inligting BewaarSkerms" )
               fScrBood( 24, "Tik 'n KORT KODE wat die BewaarSkerm sal identifiseer." )
            else
               fScrBood( 23, "[Esc]=Return to Certain Information Input Screens" )
               fScrBood( 24, "Type a SHORT CODE that will identify the Input Screens." )
            endif
            @ 11, nBoxCoor say aRecv[1,6] get aData[1] pict aRecv[1,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC .or. aData[1] == "      "
               if eof()
                  go top
               endif
               nLoop := 0
               loop
            endif
            lReturn := .t.

            //Toets of die rekord reeds bestaan
            seek upper(aData[1])
            //Dieselfde rekord
            if eof()
               if nRekord > 0
                  goto nRekord
               endif
               nLoop++
            else
               if nRekord > 0 .and. nRekord == recno()
                  nLoop++
               else
                  //Vul data
                  for i = nLoop+1 to len( aRecv )
                     aData[i] := fieldget( aRecv[i,13] )
                  next
                  //Vertoon data
                  setcolor(cColInve())
                  @ 11, nBoxCoor+21 say transform( aData[1], aRecv[1,10] )
                  @ 12, nBoxCoor+21 say transform( aData[2], aRecv[2,10] )
                  setcolor(cColNorm())
                  fScrBood( 23 )
                  if cLanType() == "A"
                     fScrWait( 24, "Kode is reeds op rekenaar!" )
                  else
                     fScrWait( 24, "Code is already on computer!" )
                  endif
                  if nRekord > 0
                     goto nRekord
                  else
                     go bottom
                     skip
                  endif
               endif
            endif
            //Vul data
            for i = nLoop+1 to len( aRecv )
               aData[i] := fieldget( aRecv[i,13] )
            next
            //Vertoon data
            setcolor(cColInve())
            @ 11, nBoxCoor+21 say transform( aData[1], aRecv[1,10] )
            @ 12, nBoxCoor+21 say transform( aData[2], aRecv[2,10] )
            setcolor(cColNorm())

         case nLoop == 2
            //Beskrywing
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Kode" )
               fScrBood( 24, "Tik 'n beskrywing van die Sekere Inligting BewaarSkerm." )
            else
               fScrBood( 23, "[Esc]=Return to Code" )
               fScrBood( 24, "Type a description for the Certain Information Input Screen." )
            endif
            @ 12, nBoxCoor say aRecv[2,6] get aData[2] pict aRecv[2,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
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
                     fieldput( aRecv[i,13], aData[i] )
                     //Maak datavelde skoon
                     do case
                        case aRecv[i,3] == "N"
                           aData[i] := 0
                        case aRecv[i,3] == "D"
                           aData[i] := ctod("  /  /  ")
                        otherwise
                           aData[i] := space( aRecv[i,4] )
                     endcase
                  next
                  commit
                  exit
               endif
            enddo

            if nRekord = 0
               nLoop := 0
            else
               nRekord = 0
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen( 0, 0, 24, 79, cCurSke )
return lReturn

/***********************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige adres totaal en al te skrap

   //Verklaar
   local lReturn := .f.

   fScrBood( 23, trim( SM3SEKE->kode ) + " - " + trim( SM3SEKE->besk ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde SEKERE INLIGTING BEWAARSKERM geskrap word?",,.f. )
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
      if fJaNee( 24, "Should above CERTAIN INFORMATION INPUT SCREEN be deleted?",,.f. )
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

/*************************************************************************/
STATIC FUNCTION fPrint

   //Verklaar
   local aVelde  := {}
   local aDbfOp  := {}
   local cSeke   := NIL
   local nTotaal := 1
   local lLoop   := .t.
   local nI      := 1
   local nRekord := 1
   local cHdln   := ""
   local cPcod   := ""
   local nMidc   := 0
   local nWidt   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local nPagl   := 0
   local nBlad   := 1

   private cData

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif

   //Kry die velde wat gedruk moet word
   asize( aVelde, 0 )
   aadd( aVelde, { "sm3seke", "kode" } )
   aadd( aVelde, { "sm3seke", "besk" } )
   aDbfOp := fGetField( aVelde )

   //Open die databasisse
   cSeke := fTOpen( cDd(), "sm3seke", , "dbf", "sm3seke", .t., .f. )
   if left( cSeke, 1 ) == "f"
      return NIL
   endif
   nTotaal := lastrec()
   go top

   //Bepaal die drukwydte
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

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Sekere Inligting BewaarSkerms word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper( "Sekere Inligting Bewaarskerms." )
   else
      fScrbood(24,"Certain Information Input Screens being printed!  [Esc]=Stop printer.")
      cHdln := upper( "Certain Information input screens." )
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
               @prow()+1,       1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4] )
            endif
         next

         //3e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4] )
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
      if fPrnStop() = K_ESC
         fTClose( cSeke )
         return NIL
      endif

      //Data
      for nI = 1 to len( aDbfOp )
         cData := aDbfOp[nI,1] + aDbfOp[nI,2]
         if nI == 1
            @prow()+1,  1 say &cData
         else
            @prow()  ,pcol()+1 say &cData
         endif
      next

      //Skerm
      // fPrnOff()
      // if nTotaal > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Voltooi "
      //    else
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Completed "
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
   fTClose( cSeke )
return NIL

/*************************************************************************/
STATIC FUNCTION fVelde

   //Veranderlikes
   local GetList := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )
   local nBoxCoo := 0
   local i       := 1
   local nTel    := 1
   local aVelde  := {}
   local aOpskr  := {}
   local aField  := {}
   local cBrowse                                 //Tbrowse element
   local cColumn                                 //tBrowse element
   local lMore   := .t.
   local t
   local cData   := space(47)+"   1"
   local nKey := 0

   if cLanType() == "A"
      nBoxCoo := fBoxCent( 4, space(70), 1, "INLIGTING (VELDE) WAT GEVRA GAAN WORD VIR:" )
      @ 4, nBoxCoo say SM3SEKE->besk
   else
      nBoxCoo := fBoxCent( 4, space(70), 1, "INFORMATION (FIELDS) THAT WILL BE REQUESTED:" )
      @ 4, nBoxCoo say SM3SEKE->besk
   endif

   //Skerm
   if cLanType() == "A"
      fScrWbood(24,"Veldbesonderhede word gelees")
   else
      fScrWbood(24,"Field information being read")
   endif

   //Bou array vanaf velde inligting
   for i = 1 to 40
      if substr(SM3SEKE->veld,nTel,10) <> space(10) .and. substr(SM3SEKE->veld,nTel+10,10) <> space(10)
         aadd( aVelde, { trim(substr(SM3SEKE->veld,nTel,10)), trim(substr(SM3SEKE->veld,nTel+10,10)) } )
      endif
      nTel := nTel + 20
   next

   //Indien die Array wel iets in het
   if len( aVelde ) > 0

      //Kry die veldbeskrywings
      aOpskr := fGetField( aVelde )

      //Stoor die veldbeskrywings
      for i = 1 to len( aOpskr )
         //aadd( aField, { padr(ltrim(aOpskr[i][6]),20) } )
         aadd( aField, padr(ltrim(aOpskr[i][6]),20) )
      next

   else

      //skoon velde
      aadd( aVelde, { space(10), space(10) } )
      //aadd( aField, { space(20) } )
      aadd( aField, space(20) )

   endif

   //Skerm
   if cLanType() == "A"
      fBox( 8, 2, 20, 25, "velde om te vra" )
   else
      fBox( 8, 2, 20, 25, "fields to request" )
   endif

   //Create tBrowse for arrays
   cBrowse := tBrowseArray( 9, 4, 19, 23, aField, GetSetBlock( t ) )

   //Define a cloumn for viewing file names
   //cColumn := tbColumnNew( , {|| aField[t][1] } )
   cColumn := tbColumnNew( , {|| aField[t] } )

   cColumn:width := 20

   cBrowse:addColumn( cColumn )

   // Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar op balk [+]=Bewaar aan einde  [Alt S]=   " )
         fScrBood( 24, "[Enter]=Terug  [Del]=Skrap op balk  [-]=Skrap aan einde   Skrap almal" )
      else
         fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [+]=Add at end    [Alt S]=   " )
         fScrBood( 24, "[Enter]=Return  [Del]=Delete  [-]=Delete at end  Delete all" )
      endif

      // Stabilize the display until it's stable or a key is pressed
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
         // Everything's done -- just wait for a key
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         // Esc means leave
         //Skerm
         if cLanType() == "A"
            fScrWbood(24,"Veldbesonderhede word bewaar")
         else
            fScrWbood(24,"Field information being saved")
         endif
         //Bewaar array in .dbf
         cData := ""
         for i = 1 to len( aVelde )
            if len(trim(aVelde[i][1])) > 0 .and. len(trim(aVelde[i][2])) > 0
               cData := cData + padr(aVelde[i][1],10) + padr(aVelde[i][2],10)
            endif
         next
         if rlock()
            SM3SEKE->veld := padr( cData, 800 )
            dbUnlock()
         endif
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means stoor array in databasis
         //Skerm
         if cLanType() == "A"
            fScrWbood(24,"Veldbesonderhede word bewaar")
         else
            fScrWbood(24,"Field information being saved")
         endif
         //Bewaar array in .dbf
         cData := ""
         for i = 1 to len( aVelde )
            if len(trim(aVelde[i][1])) > 0 .and. len(trim(aVelde[i][2])) > 0
               cData := cData + padr(aVelde[i][1],10) + padr(aVelde[i][2],10)
            endif
         next
         if rlock()
            SM3SEKE->veld := padr( cData, 800 )
            dbUnlock()
         endif
         lMore := .f.

      elseif nKey == K_DEL
         //Delete means delete an element
         if len( aField ) >= 2
            adel( aField, t )
            adel( aVelde, t )
            asize( aField, len( aField ) - 1 )
            asize( aVelde, len( aVelde ) - 1 )
         else
            aField[1] := space(20)
            aVelde[1][1] := { space(10), space(10) }
         endif
         cBrowse:refreshAll()

      elseif nKey == K_MINUS
         //Minus means delete an element at end
         if len( aField ) >= 2
            adel( aField, len(aField) )
            adel( aVelde, len(aVelde) )
            asize( aField, len( aField ) - 1 )
            asize( aVelde, len( aVelde ) - 1 )
         else
            aField[1] := space(20)
            aVelde[1] := { space(10), space(10) }
            t := len( aField )
         endif
         cBrowse:refreshAll()

      elseif nKey == K_ALT_S
         //Alt S means delete all fields
         asize( aField, 0 )
         asize( aVelde, 0 )
         aadd( aField, space(20) )
         aadd( aVelde, { space(10), space(10) } )
         cBrowse:refreshAll()

      elseif nKey == K_PLUS
         //Plus means add an element at end
         cData := sm3veld( ,,, val(right(cData,4)) )
         //Id nommer mag nie gevra word nie
         if substr( cData, 31, 10 ) == "IDNR      "
            if cLanType() == "A"
               fScrBood(23,"Idnr word outomaties gevra wanneer 'n dier se inligting opgeroep word!")
            else
               fScrBood(23,"Id no.automatically asked when an animal's information is called for!")
            endif
            fScrWait(24)
         else
            if ascan( aField, left( cData, 20 ) ) > 0
               if cLanType() == "A"
                  fScrBood(23,"Veld word reeds gevra!")
               else
                  fScrBood(23,"Field already been requested!")
               endif
               fScrWait(24)
            else
               if left( cData, 20 ) <> space(20)
                  if len( aField ) == 1 .and. aField[1] == space(20)
                     aField[1] := left( cData, 20 )
                     aVelde[1] := { substr(cData,21,10), substr(cData,31,10) }
                  else
                     aadd( aField, left(cData,20) )
                     aadd( aVelde, { substr(cData,21,10), substr(cData,31,10) } )
                     t := len( aField )
                  endif
               endif
               cBrowse:refreshAll()
            endif
         endif

      elseif nKey == K_INS
         //Insert means add an element at end
         cData := sm3veld( ,,, val(right(cData,4)) )
         if substr( cData, 31, 10 ) == "IDNR      "
            if cLanType() == "A"
               fScrBood(23,"Idnr word outomaties gevra wanneer 'n dier se inligting opgeroep word!")
            else
               fScrBood(23,"Id no.automatically asked when an animal's information is called for!")
            endif
            fScrWait(24)
         else
            if ascan( aField, left( cData, 20 ) ) > 0
               if cLanType() == "A"
                  fScrBood(23,"Veld word reeds gevra!")
               else
                  fScrBood(23,"Field already been requested!")
               endif
               fScrWait(24)
            else
               if left( cData, 20 ) <> space(20)
                  if len( aField ) == 1 .and. aField[1] == space(20)
                     aField[1] := left( cData, 20 )
                     aVelde[1] := { substr(cData,21,10), substr(cData,31,10) }
                  else
                     aadd( aField, space(20) )
                     aadd( aVelde, { space(10), space(10) } )
                     aField := ains( aField, t )
                     aVelde := ains( aVelde, t )
                     aField[t] := left( cData, 20 )
                     aVelde[t] := { substr(cData,21,10), substr(cData,31,10) }
                  endif
               endif
               cBrowse:refreshAll()
            endif
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   restscreen( 0, 0, 24, 79, cCurSke )
return NIL

