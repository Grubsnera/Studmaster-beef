//SM3OPME.PRG
//Program vir opmerkings
//Kopiereg (c) 1992 A van Rensburg
//15:50 03 Feb,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3opme( nTop, nLeft, nBottom, aVelde, cFind )

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := setcursor(0)                 //Cursor
   LOCAL aOpmeOp := {}                           //Plaas opskrifte
   LOCAL nScrLen := 0                            //Totale lengte van die velde
   LOCAL nBoxCoo := 0                            //Waar begin en eindig die box
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i                                       //Counter
   LOCAL lMore                                   //Logical looper
   LOCAL nKey                                    //Keypress
   LOCAL cReturn := cFind                        //Return value
   LOCAL lLogic                                  //Diverse logic carrier
   LOCAL cLocate
   LOCAL cOpme
   local cLocScr := ""
   local nBoxCoor := 0

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   cFind := if( cFind == NIL, "      ", cFind )

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrOpsk( ,"Option "+cOption())
      fScrBood(24,"Screen outlay being determined")
   endif

   //Kry die veldbeskrywings
   //aVelde is die array met velde wat vertoon moet word
   //aOpmeOp is die array met die volledige veldbesonderhede
   aOpmeOp := fGetField( aVelde )

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len( aOpmeOp )

      //Lengte
      nScrLen := nScrLen + aOpmeOp[i,4] + 1

      //Kolomme
      cData := aOpmeOp[i,1] + aOpmeOp[i,2]
      cHead := aOpmeOp[i,7] + ";" + aOpmeOp[i,8] + ";" + aOpmeOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "OPMERKINGS KODES" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "REMARKS CODES" )
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
   cOpme := fTOpen( cDd(), "sm3opmk", , "dbf", , .t., .f. )
   if left( cOpme, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return cReturn
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
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Bewaar  [Alt E]=Verander              " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap   [Alt P]=Druk      [A - Z]=Vind" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=Enter   [Alt E]=Edit               " )
         fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [Alt P]=Print  [A - Z]=Find" )
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
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         // Esc means leave
         cReturn := ""
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means return plaaskode and exit
         //cData := aOpmeOp[1,1] + aOpmeOp[1,2]
         cReturn := fieldget(1)
         lMore := .f.

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E
         //Alt V means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_P
         //Alt P means print a record
         fPrint()
         cBrowse:refreshall()

      elseif nKey == K_DEL
         // Insert means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3opme",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + " "
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
            nBoxCoor := fBoxCent( 12, "Vind watter Kode? xx", 1 )
            @12, nBoxCoor say "Vind watter Kode?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find what Code? xx", 1 )
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
   fTClose( cOpme )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
   setcursor( cCurCur )

return cReturn

/*************************************************************************/
STATIC FUNCTION fAddChg

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
   aadd( aSend, { "sm3opmk", "kode" })
   aadd( aSend, { "sm3opmk", "besk" })
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
      nBoxCoor := fBoxCent( 10, space(50), 4, "BEWAAR/VERANDER OPMERKINGS KODES" )
   else
      nBoxCoor := fBoxCent( 10, space(50), 4, "ENTER/EDIT REMARKS CODES" )
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
               fScrBood( 23, "[Esc]=Terug na Opmerkings kodes" )
               fScrBood( 24, "Tik 'n KORT KODE wat die opmerkings kode sal identifiseer." )
            else
               fScrBood( 23, "[Esc]=Return to Remarks codes" )
               fScrBood( 24, "Type a SHORT CODE to identify the remarks code." )
            endif
            @ 11, nBoxCoor say aRecv[1,6] get aData[1] pict aRecv[1,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC .or. aData[1] == "  "
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
                     fScrWait( 24, "Code already on computer!" )
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
               fScrBood( 24, "Tik 'n beskrywing van die opmerkings kode." )
            else
               fScrBood( 23, "[Esc]=Return to Code" )
               fScrBood( 24, "Type a description for the remarks code." )
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
               nLoop := 1
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

   fScrBood( 23, trim( sm3opmk->kode ) + " - " + trim( sm3opmk->besk ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde OPMERKINGSKODE geskrap word?",,.f. )
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
      if fJaNee( 24, "Should above REMARKS CODE be deleted?",,.f. )
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
   local cOpme   := NIL
   local nTotaal := 1
   local nRekord := 1
   local lLoop   := .t.
   local nI      := 1
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
   aadd( aVelde, { "sm3opmk", "kode" } )
   aadd( aVelde, { "sm3opmk", "besk" } )
   aDbfOp := fGetField( aVelde )

   //Open die databasisse
   cOpme := fTOpen( cDd(), "sm3opmk", , "dbf", "sm3opmk", .t., .f. )
   if left( cOpme, 1 ) == "f"
      return NIL
   endif
   nTotaal := lastrec()
   go top

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

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Opmerkingskodes word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper( "Opmerkingskodes." )
   else
      fScrbood(24,"Remarks codes being printed!  [Esc]=Stop printer.")
      cHdln := upper( "Remarks codes." )
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
         fTClose( cOpme )
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
   fTClose( cOpme )
return NIL

