//SM3SELG.PRG
//Program om seleksiegroep te spesifiseer
//Kopiereg (c) 1992 A van Rensburg
//08:56 11 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

#xtrans GetSetBlock( <v> ) => {|x| if( x == NIL, <v>, <v> := x ) }

/************************************************************************/
FUNCTION sm3selg( nTop, nLeft, nBottom, aSend, cFind, lFull )

   //Veranderlikes
   local GetList := {}
   local aCscr  := {}
   local cCurScr := fCurScreen()                 //Kleure ens
   local cCurDbf := fTOpen()                     //Databasis
   local cCurCur := setcursor(0)                 //Cursor
   local aRecv   := {}                           //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nBoxCoo := 0                            //Waar begin en eindig die box
   local nRight  := 76                           //Regterkantste lyn
   local cBrowse                                 //Browse object
   local aColumn := {}                           //Kolomme array
   local i                                       //Counter
   local lMore                                   //Logical looper
   local nKey                                    //Keypress
   local lLogic                                  //Diverse logic carrier
   local cLocate
   local cSelg
   local cReturn := ""
   local cVeld1  := ""
   local cVeld2  := ""
   local cVeld3  := ""
   local cDats := ""

   //Hierdie program spesifieke veranderlikes
   local nTel    := 1
   local lVeld   := .f.
   local cMemf   := cDd()+"sm3selg.mem"
   local cLocScr := ""

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse
   PRIVATE cMkod := ""
   PRIVATE cMbes := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   aCscr := fASaveScr()

   //Parameters
   nTop    := if( nTop    == NIL,  4, nTop    )
   nLeft   := if( nLeft   == NIL,  4, nLeft   )
   nBottom := if( nBottom == NIL, 20, nBottom )
   lFull   := if( lFull   == NIL, .f., lFull  )

   if aSend == NIL
      aSend := {}
      asize(aSend,0)

      aadd( aSend, { "sm3selg", "kode" })
      aadd( aSend, { "sm3selg", "besk" })
   endif

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrBood(24,"Screen outlay being determined")
   endif

   //Kry die veldbeskrywings
   aRecv := fGetField( aSend )

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len( aRecv )

      //Lengte
      nScrLen := nScrLen + aRecv[i,4] + 1

      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "SELEKSIEGROEPE" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "SELECTION GROUPS" )
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
   cSelg := fTOpen( cDd(), "sm3selg", , "dbf", , .t., .f. )
   if left( cSelg, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      fARestScr(aCscr)
      setcursor( cCurCur )
      return cReturn
   endif

   //Skuif die databasis
   if cFind == NIL
   else
      if cFind <> "      "
         seek cFind
         if eof()
            go top
         endif
      endif
   endif

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Bewaar  [Alt E]=Verander  [Alt F]=Velde      " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap   [A - Z]=Vind      [Alt S]=Skrap velde" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=Enter   [Alt E]=Edit  [Alt F]=Fields       " )
         fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [A - Z]=Find  [Alt S]=Delete fields" )
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
         //Enter means bou kode
         //Bou array vanaf velde inligting
         nTel := 1
         for i = 1 to 40
            cVeld1 := substr(SM3SELG->veld1,nTel,20)
            cVeld2 := substr(SM3SELG->veld2,nTel,20)
            cVeld3 := substr(SM3SELG->veld3,nTel,20)
            cDats := ""
            if cVeld1 == space(20) .or. cVeld2 == space(20) .or. cVeld3 == space(20)
            else
               if trim(substr(cVeld2,8,1)) == "C" .and. trim(left(cVeld2,2)) == "$"
                  cDats += '"' + trim(cVeld3) + '"'
                  cDats += trim(left(cVeld2,2))
                  if lFull
                     cDats += trim(left(cVeld1,10)) + "->" + trim(right(cVeld1,10))
                  else
                     cDats += trim(right(cVeld1,10))
                  endif
                  cDats += trim(substr(cVeld2,3,5))
               elseif trim(substr(cVeld2,8,1)) == "C" .and. trim(left(cVeld2,2)) <> "$"
                  if lFull
                     cDats += trim(left(cVeld1,10)) + "->" + trim(right(cVeld1,10))
                  else
                     cDats += trim(right(cVeld1,10))
                  endif
                  cDats += trim(left(cVeld2,2))
                  cDats += '"' + trim(cVeld3) + '"'
                  cDats += trim(substr(cVeld2,3,5))
               elseif trim(substr(cVeld2,8,1)) == "N"
                  if lFull
                     cDats += trim(left(cVeld1,10)) + "->" + trim(right(cVeld1,10))
                  else
                     cDats += trim(right(cVeld1,10))
                  endif
                  cDats += trim(left(cVeld2,2))
                  cDats += alltrim(cVeld3)
                  cDats += trim(substr(cVeld2,3,5))
               elseif trim(substr(cVeld2,8,1)) == "D"
                  if lFull
                     cDats += trim(left(cVeld1,10)) + "->" + trim(right(cVeld1,10))
                  else
                     cDats += trim(right(cVeld1,10))
                  endif
                  cDats += trim(left(cVeld2,2))
                  cDats += 'ctod("' + trim(cVeld3) + '")'
                  cDats += trim(substr(cVeld2,3,5))
               endif
            endif
            nTel := nTel + 20

            if len(cDats) + len(cReturn) < 250
               cReturn += cDats
            else
               // cReturn += cDats
               //@24,0 say "Too long"
               //inkey(0)
            endif

         next

         //Verwyder stert
         if right(cReturn,5) == ".and."
            cReturn := left(cReturn,len(cReturn)-5)
         endif
         if right(cReturn,4) == ".or."
            cReturn := left(cReturn,len(cReturn)-4)
         endif
         if len(trim(cReturn)) > 0
            //Skep mem file
            cMkod := SM3SELG->kode
            cMbes := SM3SELG->besk
            save all like cM* to (cMemf)
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
         if fAddChg(aRecv)
            lVeld := .t.
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E
         //Alt V means change a record
         if fAddChg(aRecv)
            lVeld := .t.
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_P
         //Alt P means print a record
         fPrint()
         cBrowse:refreshall()

      elseif nKey == K_ALT_F .or. nKey == 145
         //Alt F means print a record
         fVelde()

      elseif nKey == K_ALT_S
         //Alt S means clear all the defined fields
         do while !rlock()
         enddo
         SM3SELG->veld1 := space(800)
         SM3SELG->veld2 := space(800)
         SM3SELG->veld3 := space(800)

      elseif nKey == K_DEL
         // Insert means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3selg",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + "     "
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik 'n gedeelte van die seleksiegroep waarna gesoek word.")
         else
            fScrBood(24,"Type a section of the selection group which should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoo := fBoxCent( 11, "Vind watter seleksiegroep? xxxxxx", 3 )
            @12, nBoxCoo say "Vind watter seleksiegroep?" get cLocate pict "@!"
         else
            nBoxCoo := fBoxCent( 11, "Find which selection group? xxxxxx", 3 )
            @12, nBoxCoo say "Find which selection group?" get cLocate pict "@!"
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
   fTClose( cSelg )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   fARestScr(aCscr)
   setcursor( cCurCur )

return cReturn

/*************************************************************************/
STATIC FUNCTION fAddChg(aSelgOp)

   //Veranderlikes
   local GetList := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )
   local aSend := {}
   local nRekord
   local nBoxCoor
   local nLoop
   local lLoop
   local i
   local lReturn := .f.

   //Kry die velde benodig
   if aSelgOp == NIL
      asize( aSend, 0 )
      aadd( aSend, { "sm3selg", "kode" })
      aadd( aSend, { "sm3selg", "besk" })
      aSelgOp := fGetField( aSend )
   endif

   //Bou veranderlikes
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent( 10, space(50), 4, "NUWE SELEKSIEGROEP" )
      else
         nBoxCoor := fBoxCent( 10, space(50), 4, "NEW SELECTION GROUP" )
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent( 10, space(50), 4, "VERANDER SELEKSIEGROEP" )
      else
         nBoxCoor := fBoxCent( 10, space(50), 4, "EDIT SELECTION GROUP" )
      endif
   endif
   for i = 1 to len( aSelgOp )
      aSelgOp[i][14] := fieldget(aSelgOp[i][13])
   next

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @ 11, nBoxCoor say aSelgOp[1,6]
   @ 12, nBoxCoor say aSelgOp[2,6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @ 11, nBoxCoor+21 say transform( aSelgOp[1][14], aSelgOp[1,10] )
         @ 12, nBoxCoor+21 say transform( aSelgOp[2][14], aSelgOp[2,10] )
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Kode

            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na seleksiegroepe" )
               fScrBood( 24, "Tik 'n KORT KODE wat die seleksiegroep sal identifiseer." )
            else
               fScrBood( 23, "[Esc]=Return to selection groups" )
               fScrBood( 24, "Type a SHORT CODE that will identify the selection group." )
            endif
            @ 11, nBoxCoor say aSelgOp[1,6] get aSelgOp[1][14] pict aSelgOp[1,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC .or. aSelgOp[1][14]== "      "
               if eof()
                  go top
               endif
               nLoop := 0
               loop
            endif
            lReturn := .t.

            //Toets of die rekord reeds bestaan
            seek upper(aSelgOp[1][14])
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
                  for i = nLoop+1 to len( aSelgOp )
                     aSelgOp[i][14] := fieldget( aSelgOp[i,13] )
                  next
                  //Vertoon data
                  setcolor(cColInve())
                  @ 11, nBoxCoor+21 say transform( aSelgOp[1][14], aSelgOp[1,10] )
                  @ 12, nBoxCoor+21 say transform( aSelgOp[2][14], aSelgOp[2,10] )
                  setcolor(cColNorm())
                  fScrBood( 23 )
                  if cLanType() == "A"
                     fScrWait( 24, "Seleksiegroep is reeds op rekenaar!" )
                  else
                     fScrWait( 24, "Selection group already on computer!" )
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
            for i = nLoop+1 to len( aSelgOp )
               aSelgOp[i][14] := fieldget( aSelgOp[i,13] )
            next
            //Vertoon data
            setcolor(cColInve())
            @ 11, nBoxCoor+21 say transform( aSelgOp[1][14], aSelgOp[1,10] )
            @ 12, nBoxCoor+21 say transform( aSelgOp[2][14], aSelgOp[2,10] )
            setcolor(cColNorm())

         case nLoop == 2
            //Beskrywing
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na seleksiegroepkode" )
               fScrBood( 24, "Tik 'n BESKRYWING vir die seleksiegroep." )
            else
               fScrBood( 23, "[Esc]=Return to selection group code" )
               fScrBood( 24, "Type a DESCRIPTION for the selection group." )
            endif
            @ 12, nBoxCoor say aSelgOp[2,6] get aSelgOp[2][14] pict aSelgOp[2,10]
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

            do while !rlock()
            enddo

            for i = 1 to len( aSelgOp )
               fieldput( aSelgOp[i,13], aSelgOp[i][14] )
               //Maak datavelde skoon
               do case
                  case aSelgOp[i,3] == "N"
                     aSelgOp[i][14] := 0
                  case aSelgOp[i,3] == "D"
                     aSelgOp[i][14] := ctod("  /  /  ")
                  otherwise
                     aSelgOp[i][14] := space( aSelgOp[i,4] )
               endcase
            next
            commit

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

   fScrBood( 23, trim( SM3SELG->kode ) + " - " + trim( SM3SELG->besk ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde SELEKSIEGROEP geskrap word?",,.f. )
         do while !rlock()
         enddo
         delete
         skip
         if eof()
            go top
         endif
         lReturn := .t.
      endif
   else
      if fJaNee( 24, "Should above SELECTION GROUP be deleted?",,.f. )
         do while !rlock()
         enddo
         delete
         skip
         if eof()
            go top
         endif
         lReturn := .t.
      endif
   endif

return lReturn

/*************************************************************************/
STATIC FUNCTION fPrint

   //Verklaar
   local aVelde  := {}
   local aDbfOp  := {}
   local cSelg   := NIL
   local nTotaal := 1
   local lLoop   := .t.
   local nI      := 1
   local nRekord := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

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
   aadd( aVelde, { "sm3selg", "kode" } )
   aadd( aVelde, { "sm3selg", "besk" } )
   aDbfOp := fGetField( aVelde )

   //Open die databasisse
   cSelg := fTOpen( cDd(), "sm3selg", , "dbf", "sm3selg", .t., .f. )
   if left( cSelg, 1 ) == "f"
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
      fScrbood(24,"Seleksie groepe word gedruk!  [Esc]=Stop drukker.")
      cHdln := "SELEKSIE GROEPE."
   else
      fScrbood(24,"Selection groups being printed!  [Esc]=Stop printer.")
      cHdln := "SELECTION GROUPS."
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
         fTClose( cSelg )
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
   fTClose( cSelg )
return NIL

/*************************************************************************/
STATIC FUNCTION fVelde

   //Veranderlikes
   local GetList := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )
   local nBoxCoo := 0
   local i       := 1
   local nTel    := 1
   local aOpskr  := {}
   local aField  := {}
   local cBrowse := NIL                          //Tbrowse element
   local cColumn := NIL                          //tBrowse element
   local lMore   := .t.
   local t
   local cData   := space(47)+"   1"
   local cVeld1  := ""
   local cVeld2  := ""
   local cVeld3  := ""
   local aVeld1  := {}
   local aVeld2  := {}
   local aVeld3  := {}
   local aData   := {}
   local nNext   := 0
   local nChoice := 0
   local cCarry  := ""
   local nCarry  := 0
   local dCarry  := ctod("")
   local nKey := 0

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   if cLanType() == "A"
      fScrWbood(24,"Veldbesonderhede word gelees")
   else
      fScrWbood(24,"Field information being read")
   endif

   //Bou array vanaf velde inligting
   nTel := 1
   for i = 1 to 40
      cVeld1 := substr(SM3SELG->veld1,nTel,20)
      cVeld2 := substr(SM3SELG->veld2,nTel,20)
      cVeld3 := substr(SM3SELG->veld3,nTel,20)
      if cVeld1 == space(20) .or. cVeld2 == space(20) .or. cVeld3 == space(20)
      else
         aadd( aVeld1, { trim(left(cVeld1,10)), trim(right(cVeld1,10)) } )
         aadd( aVeld2, { left(cVeld2,2), substr(cVeld2,3,5), substr(cVeld2,8,1),val(substr(cVeld2,9,3)), val(substr(cVeld2,11,3))  } )
         aadd( aVeld3, cVeld3 )
      endif
      nTel := nTel + 20
   next

   //Indien die Array wel iets in het
   if len( aVeld1 ) > 0

      //Kry die veldbeskrywings
      aOpskr := fGetField( aVeld1 )

      //Stoor die veldbeskrywings
      for i = 1 to len( aVeld1 )
         aadd( aField, {"","","",""} )

         //Naam
         aField[i][1] := padr(ltrim(aOpskr[i][6]),20)

         //Operator
         if cLanType() == "A"
            if aVeld2[i][1] == "= "
               aField[i][2] := padr("is gelyk aan",25)
            elseif aVeld2[i][1] == "=="
               aField[i][2] := padr("is gelyk aan",25)
            elseif aVeld2[i][1] == "> "
               aField[i][2] := padr("is groter as",25)
            elseif aVeld2[i][1] == ">="
               aField[i][2] := padr("is groter of gelyk aan",25)
            elseif aVeld2[i][1] == "< "
               aField[i][2] := padr("is kleiner as",25)
            elseif aVeld2[i][1] == "<="
               aField[i][2] := padr("is kleiner of gelyk aan",25)
            elseif aVeld2[i][1] == "<>"
               aField[i][2] := padr("is nie gelyk aan",25)
            elseif aVeld2[i][1] == "$ "
               aField[i][2] := padr("bevat",25)
            else
               aField[i][2] := padr("is gelyk aan",25)
            endif
         else
            if aVeld2[i][1] == "= "
               aField[i][2] := padr("is equal to",25)
            elseif aVeld2[i][1] == "=="
               aField[i][2] := padr("is equal to",25)
            elseif aVeld2[i][1] == "> "
               aField[i][2] := padr("is greater than",25)
            elseif aVeld2[i][1] == ">="
               aField[i][2] := padr("is greater or equal to",25)
            elseif aVeld2[i][1] == "< "
               aField[i][2] := padr("is smaller than",25)
            elseif aVeld2[i][1] == "<="
               aField[i][2] := padr("is smaller or equal to",25)
            elseif aVeld2[i][1] == "<>"
               aField[i][2] := padr("is not equal to",25)
            elseif aVeld2[i][1] == "$ "
               aField[i][2] := padr("contains",25)
            else
               aField[i][2] := padr("is equal to",25)
            endif
         endif

         //Veranderlike
         aField[i][3] := padr(aVeld3[i],20)

         //Operator
         if cLanType() == "A"
            if aVeld2[i][2] == ".and."
               aField[i][4] := "en "
            elseif aVeld2[i][2] == ".or. "
               aField[i][4] := "of "
            else
               aField[i][4] := "en "
            endif
         else
            if aVeld2[i][2] == ".and."
               aField[i][4] := "and"
            elseif aVeld2[i][2] == ".or. "
               aField[i][4] := "or "
            else
               aField[i][4] := "and"
            endif
         endif

         //Veldtipe, Veldlengte, Velddesi
         aVeld2[i][3] := aOpskr[i][3]
         aVeld2[i][4] := aOpskr[i][4]
         aVeld2[i][5] := aOpskr[i][5]

      next

   else

      //skoon velde
      aadd( aVeld1, { space(10), space(10) } )
      aadd( aVeld2, { "  ","     "," ",0,0 } )
      aadd( aVeld3, space(20)                )
      aadd( aField, { space(20),space(25),space(20),space(3) } )

   endif

   //Skerm
   if cLanType() == "A"
      fBox( 3, 2, 20, 76, left("SELEKSIEGROEP VEREISTES VIR ("+trim(SM3SELG->KODE)+") "+SM3SELG->besk,70) )
   else
      fBox( 3, 2, 20, 76, left("SELECTION GROUP REQUIREMENTS FOR ("+trim(SM3SELG->KODE)+") "+SM3SELG->besk,70) )
   endif

   //Create tBrowse for arrays
   cBrowse := tBrowseArray( 4, 4, 19, 74, aField, GetSetBlock( t ) )

   if cLanType() == "A"
      cColumn := tbColumnNew("VELDNAAM",{|| aField[t][1] } )
      cBrowse:addcolumn(cColumn)
      cColumn := tbColumnNew("KWALIFISEERDER",{|| aField[t][2] } )
      cBrowse:addcolumn(cColumn)
      cColumn := tbColumnNew("VERANDERLIKE",{|| aField[t][3] } )
      cBrowse:addcolumn(cColumn)
      cColumn := tbColumnNew("BEH",{|| aField[t][4] } )
      cBrowse:addcolumn(cColumn)
   else
      cColumn := tbColumnNew("FIELD NAME",{|| aField[t][1] } )
      cBrowse:addcolumn(cColumn)
      cColumn := tbColumnNew("QUALIFIER",{|| aField[t][2] } )
      cBrowse:addcolumn(cColumn)
      cColumn := tbColumnNew("VARIABLE",{|| aField[t][3] } )
      cBrowse:addcolumn(cColumn)
      cColumn := tbColumnNew("OPE",{|| aField[t][4] } )
      cBrowse:addcolumn(cColumn)
   endif
   cBrowse:headsep := "Ä"
   cBrowse:colsep  := " "

   // Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar op balk [+]=Bewaar aan einde  [Alt S]=   " )
         fScrBood( 24, "[Enter]=Terug  [Del]=Skrap op balk  [-]=Skrap aan einde   Skrap almal" )
      else
         fScrBood( 23, "[ Esc ]=Return  [Ins]=Insert at bar  [+]=Add at end     [Alt S]=  " )
         fScrBood( 24, "[Enter]=Return  [Del]=Delete at bar  [-]=Delete at end  Delete all" )
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
         if nNext > 0
            keyboard chr(nNext)
            nNext := 0
         endif
         nKey := InKey(0)
      endif

      if nKey == K_ESC .or. nKey == K_ENTER
         //Esc means leave
         //Skerm
         if cLanType() == "A"
            fScrWbood(24,"Veldbesonderhede word bewaar")
         else
            fScrWbood(24,"Field information being entered")
         endif
         //Lock record
         do while !rlock()
         enddo
         //Bewaar array in .dbf
         cData := ""
         for i = 1 to len( aVeld1 )
            if len(trim(aVeld1[i][1])) > 0 .and. len(trim(aVeld1[i][2])) > 0
               cData := cData + padr(aVeld1[i][1],10) + padr(aVeld1[i][2],10)
            endif
         next
         SM3SELG->veld1 := padr(cData,800)
         //Bewaar array in .dbf
         cData := ""
         for i = 1 to len( aVeld1 )
            if len(trim(aVeld1[i][1])) > 0 .and. len(trim(aVeld1[i][2])) > 0
               cData := cData + padr(aVeld2[i][1]+aVeld2[i][2]+aVeld2[i][3]+str(aVeld2[i][4],3,0)+str(aVeld2[i][5],3,0),20)
            endif
         next
         SM3SELG->veld2 := padr(cData,800)
         //Bewaar array in .dbf
         cData := ""
         for i = 1 to len( aVeld1 )
            if len(trim(aVeld1[i][1])) > 0 .and. len(trim(aVeld1[i][2])) > 0
               cData := cData + padr(aVeld3[i],20)
            endif
         next
         SM3SELG->veld3 := padr(cData,800)
         lMore := .f.

      elseif nKey == K_DEL
         //Delete means delete an element
         if len( aField ) >= 2
            adel( aField, t )
            adel( aVeld1, t )
            adel( aVeld2, t )
            adel( aVeld3, t )
            asize( aField, len( aField ) - 1 )
            asize( aVeld1, len( aVeld1 ) - 1 )
            asize( aVeld2, len( aVeld2 ) - 1 )
            asize( aVeld3, len( aVeld3 ) - 1 )
         else
            //Maak 1ste array skoon
            aVeld1[1] := {space(10),space(10)}
            aVeld2[1] := { "  ","     "," ",0,0 }
            aVeld3[1] := space(20)
            aField[1] := { space(20),space(25),space(20),space(3) }
         endif
         cBrowse:refreshAll()

      elseif nKey == K_MINUS
         //Minus means delete an element at end
         if len( aField ) >= 2
            adel( aField, len(aField) )
            adel( aVeld1, len(aVeld1) )
            adel( aVeld2, len(aVeld2) )
            adel( aVeld3, len(aVeld3) )
            asize( aField, len( aField ) - 1 )
            asize( aVeld1, len( aVeld1 ) - 1 )
            asize( aVeld2, len( aVeld2 ) - 1 )
            asize( aVeld3, len( aVeld3 ) - 1 )
         else
            //Maak 1ste array skoon
            aVeld1[1] := {space(10),space(10)}
            aVeld2[1] := { "  ","     "," ",0,0 }
            aVeld3[1] := space(20)
            aField[1] := { space(20),space(25),space(20),space(3) }
            t := len(aField)
         endif
         cBrowse:refreshAll()

      elseif nKey == K_ALT_S
         //Alt S means delete all fields
         asize( aField, 0 )
         asize( aVeld1, 0 )
         asize( aVeld2, 0 )
         asize( aVeld3, 0 )
         //skoon velde
         aadd( aVeld1, { space(10), space(10) } )
         aadd( aVeld2, { "  ","     "," ",0,0 } )
         aadd( aVeld3, space(20)                )
         aadd( aField, { space(20),space(25),space(20),space(3) } )
         cBrowse:refreshAll()

      elseif nKey == K_PLUS
         //Plus means add an element at end
         if cBrowse:colpos <> 1
            cBrowse:colpos := 1
            cBrowse:refreshcurrent()
            nNext := K_PLUS
         else
            //Skep nuwe
            if len( aField ) == 1 .and. aField[1][1] == space(20)
               //Moenie nuwe array skep nie
            else
               //Add new element
               //skoon velde
               aadd( aVeld1, { space(10), space(10) } )
               aadd( aVeld2, { "  ","     "," ",0,0 } )
               aadd( aVeld3, space(20)                )
               aadd( aField, { space(20),space(25),space(20),space(3) } )
               t := len( aField )
            endif
            //Roep die volgende stap - vra veldnaam
            if aField[t][1] == space(20)
               nNext := K_CTRL_BS
            endif
            cBrowse:refreshall()
         endif

      elseif nKey == K_INS
         //Insert means add element
         if cBrowse:colpos <> 1
            cBrowse:colpos := 1
            cBrowse:refreshcurrent()
            nNext := K_INS
         else
            if len( aField ) == 1 .and. aField[1][1] == space(20)
               //Moenie nuwe array skep nie
            else
               //Add new element
               //skoon velde
               aadd( aVeld1, { space(10), space(10) } )
               aadd( aVeld2, { "  ","     "," ",0,0 } )
               aadd( aVeld3, space(20)                )
               aadd( aField, { space(20),space(25),space(20),space(3) } )
               aField := ains( aField, t )
               aVeld1 := ains( aVeld1, t )
               aVeld2 := ains( aVeld2, t )
               aVeld3 := ains( aVeld3, t )
               aVeld1[t] := { space(10), space(10) }
               aVeld2[t] := { "  ","     "," ",0,0 }
               aVeld3[t] := space(20)
               aField[t] := { space(20),space(25),space(20),space(3) }
            endif
            //Roep die volgende stap - vra veldnaam
            if aField[t][1] == space(20)
               nNext := K_CTRL_BS
            endif
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E .or. nKey == K_CTRL_BS
         //Vra die verskillende velde

         if cBrowse:colpos == 2
            //Kwalifiseerder
            if cLanType() == "A"
               nChoice := fKwal()
               if nChoice == 1
                  aField[t][2] := "is gelyk aan             "
                  aVeld2[t][1] := "= "
               elseif nChoice == 2
                  aField[t][2] := "is groter of gelyk aan   "
                  aVeld2[t][1] := ">="
               elseif nChoice == 3
                  aField[t][2] := "is kleiner of gelyk aan  "
                  aVeld2[t][1] := "<="
               elseif nChoice == 4
                  aField[t][2] := "is groter as             "
                  aVeld2[t][1] := "> "
               elseif nChoice == 5
                  aField[t][2] := "is kleiner as            "
                  aVeld2[t][1] := "< "
               elseif nChoice == 6
                  aField[t][2] := "is nie gelyk aan         "
                  aVeld2[t][1] := "<>"
               elseif nChoice == 7
                  aField[t][2] := "bevat                    "
                  aVeld2[t][1] := "$ "
               else
                  aField[t][2] := "is gelyk aan             "
                  aVeld2[t][1] := "= "
               endif
            else
               nChoice := fKwal()
               if nChoice == 1
                  aField[t][2] := "is equal to              "
                  aVeld2[t][1] := "= "
               elseif nChoice == 2
                  aField[t][2] := "is greater than or equal "
                  aVeld2[t][1] := ">="
               elseif nChoice == 3
                  aField[t][2] := "is smaller or equal to   "
                  aVeld2[t][1] := "<="
               elseif nChoice == 4
                  aField[t][2] := "is greater than          "
                  aVeld2[t][1] := "> "
               elseif nChoice == 5
                  aField[t][2] := "is smaller than          "
                  aVeld2[t][1] := "< "
               elseif nChoice == 6
                  aField[t][2] := "is not equal to          "
                  aVeld2[t][1] := "<>"
               elseif nChoice == 7
                  aField[t][2] := "contains                 "
                  aVeld2[t][1] := "$ "
               else
                  aField[t][2] := "is equal to              "
                  aVeld2[t][1] := "= "
               endif
            endif
            //Roep die volgende stap - vra veldnaam
            if aField[t][3] == space(20)
               nNext := K_CTRL_BS
               cBrowse:colpos := 3
            endif
         elseif cBrowse:colpos == 3
            //Vra die veranderlike

            //Datatipe
            if aVeld2[t][3] == "C"
               cCarry := left(aVeld3[t],aVeld2[t][4])
               @row(),col() get cCarry pict "@!"
               set cursor on
               read
               set cursor off
               aField[t][3] := padr(cCarry,20)
               aVeld3[t]    := padr(cCarry,20)
            elseif aVeld2[t][3] == "D"
               dCarry := ctod(left(aVeld3[t],aVeld2[t][4]))
               @row(),col() get dCarry pict "99/99/99"
               set cursor on
               read
               set cursor off
               aField[t][3] := padr(dtoc(dCarry),20)
               aVeld3[t]    := padr(dtoc(dCarry),20)
            elseif aVeld2[t][3] == "N"
               cCarry := padr("",aVeld2[t][4],"9")
               if aVeld2[t][5] > 0
                  nCarry := aVeld2[t][4] - aVeld2[t][5]
                  cCarry := strtran(cCarry,"9",".",nCarry,1)
               endif
               nCarry := val(aVeld3[t])
               @row(),col() get nCarry pict cCarry
               set cursor on
               read
               set cursor off
               aField[t][3] := padr(str(nCarry,aVeld2[t][4],aVeld2[t][5]),20)
               aVeld3[t]    := padr(str(nCarry,aVeld2[t][4],aVeld2[t][5]),20)
            endif

            //Roep die volgende stap - vra veldnaam
            if aField[t][4] == space(3)
               nNext := K_CTRL_BS
               cBrowse:colpos := 4
            endif
         elseif cBrowse:colpos == 4
            //Beheerder
            nChoice := fBeheer()
            if cLanType() == "A"
               if nChoice == 1
                  aField[t][4] := "en "
                  aVeld2[t][2] := ".and."
                  nNext := K_ESC
               elseif nChoice == 2
                  aField[t][4] := "en "
                  aVeld2[t][2] := ".and."
                  nNext := K_PLUS
               elseif nChoice == 3
                  aField[t][4] := "of "
                  aVeld2[t][2] := ".or. "
                  nNext := K_PLUS
               else
                  aField[t][4] := "en "
                  aVeld2[t][2] := ".and."
               endif
            else
               if nChoice == 1
                  aField[t][4] := "and "
                  aVeld2[t][2] := ".and."
                  nNext := K_ESC
               elseif nChoice == 2
                  aField[t][4] := "and "
                  aVeld2[t][2] := ".and."
                  nNext := K_PLUS
               elseif nChoice == 3
                  aField[t][4] := "or "
                  aVeld2[t][2] := ".or. "
                  nNext := K_PLUS
               else
                  aField[t][4] := "and "
                  aVeld2[t][2] := ".and."
               endif
            endif
            //Roep die volgende stap - vra veldnaam
            cBrowse:colpos := 1
         else
            //Vra die veldnaam
            cData := sm3veld(6,25,21,val(right(cData,4)))
            if left( cData, 20 ) <> space(20)
               //Veldnaam wel gekies
               aField[t][1] := left( cData, 20 )
               aVeld1[t][1] := substr(cData,21,10)
               aveld1[t][2] := substr(cData,31,10)
               aVeld2[t][3] := substr(cData,41, 1)
               aVeld2[t][4] := val(substr(cData,42, 3))
               aVeld2[t][5] := val(substr(cData,45, 3))
               //Roep die volgende stap - vra veldnaam
               if aField[t][2] == space(25)
                  nNext := K_CTRL_BS
                  cBrowse:colpos := 2
               endif
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


//*************************************************************************/
STATIC FUNCTION fKwal(nTopp,nLeft,nBott)

   //Verklaar
   local cCurScr := savescreen(0,0,24,79)
   local nRigh   := 0
   local aChoice := {}
   local nChoice := 0

   //Die menu
   if cLanType() == "A"
      aadd(aChoice,"is gelyk aan             ")
      aadd(aChoice,"is groter of gelyk aan   ")
      aadd(aChoice,"is kleiner of gelyk aan  ")
      aadd(aChoice,"is groter as             ")
      aadd(aChoice,"is kleiner as            ")
      aadd(aChoice,"is nie gelyk aan         ")
      aadd(aChoice,"bevat                    ")
   else
      aadd(aChoice,"is equal to              ")
      aadd(aChoice,"is greater or equal to   ")
      aadd(aChoice,"is smaller or equal to   ")
      aadd(aChoice,"is greater than          ")
      aadd(aChoice,"is smaller than          ")
      aadd(aChoice,"is not equal to          ")
      aadd(aChoice,"contains                 ")
   endif

   //Waardes
   nTopp := if( nTopp==NIL, 6, nTopp )
   nLeft := if( nLeft==NIL,40, nLeft )
   nBott := if( nBott==NIL,21, nBott )
   nRigh := nLeft + 30

   //Skerm
   fScrBood( 23 )
   if cLanType() == "A"
      fScrBood( 24, "Kies 'n kwalifiseerder met " + D_DNARR + D_UPARR + " sleutels en druk " + D_ENTER )
      fBox( nTopp, nLeft, nBott, nRigh, "Kwalifiseerders", cColMenu() )
   else
      fScrBood( 24, "Choose a qualifier with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER )
      fBox( nTopp, nLeft, nBott, nRigh, "Qualifiers", cColMenu() )
   endif

   //Die menu
   setcolor(cColMenu())
   nChoice := achoice(nTopp+1,nLeft+2,nBott-1,nRigh-2,aChoice)

   //Herstel
   restscreen(0,0,24,79,cCurScr)
   setcolor(cColNorm())
return nChoice

//*************************************************************************/
STATIC FUNCTION fBeheer(nTopp,nLeft,nBott)

   //Verklaar
   local cCurScr := savescreen(0,0,24,79)
   local nRigh   := 0
   local aChoice := {}
   local nChoice := 0

   //Die menu
   if cLanType() == "A"
      aadd(aChoice,"    klaar    ")
      aadd(aChoice,"     en      ")
      aadd(aChoice,"     of      ")
   else
      aadd(aChoice,"   finished  ")
      aadd(aChoice,"     and     ")
      aadd(aChoice,"     or      ")
   endif

   //Waardes
   nTopp := if( nTopp==NIL, 6, nTopp )
   nLeft := if( nLeft==NIL,55, nLeft )
   nBott := if( nBott==NIL,21, nBott )
   nRigh := nLeft + 15

   //Skerm
   fScrBood( 23 )
   if cLanType() == "A"
      fScrBood( 24, "Kies 'n beheerder met " + D_DNARR + D_UPARR + " sleutels en druk " + D_ENTER )
      fBox( nTopp, nLeft, nBott, nRigh, "Beheerders", cColMenu() )
   else
      fScrBood( 24, "Choose an operator with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER )
      fBox( nTopp, nLeft, nBott, nRigh, "Operators", cColMenu() )
   endif

   //Die menu
   setcolor(cColMenu())
   nChoice := achoice(nTopp+1,nLeft+2,nBott-1,nRigh-2,aChoice)

   //Herstel
   restscreen(0,0,24,79,cCurScr)
   setcolor(cColNorm())
return nChoice
