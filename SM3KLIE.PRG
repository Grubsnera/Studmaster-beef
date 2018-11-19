//SM3KLIE.PRG
//Program om adresse te bewaar
//Kopiereg (c) 1992 A van Rensburg
//15:37 12 Aug,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3klie( nTop, nLeft, nBottom, aVelde, cFind )

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL aCscr := fASaveScr()
   LOCAL aCdbf := fATopen()
   LOCAL cCurCur := setcursor(0)                 //Cursor
   LOCAL aLedeOp := {}                           //Plaas opskrifte
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
   LOCAL cLede
   local cLocScr := ""
   local nBoxCoor := 0

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   begin sequence

      //Parameters
      nTop := if( nTop == NIL, 4, nTop )
      nLeft := if( nLeft == NIL, 4, nLeft )
      nBottom := if( nBottom == NIL, 20, nBottom )
      aVelde := iif(empty(aVelde),{},aVelde)
      cFind := if( cFind == NIL, "      ", cFind )

      //Skerm
      fScrBood(23,"")
      if cLanType() == "A"
		 fScrOpsk(,"Opsie "+cOption())
         fScrBood(24,"Skermuitleg word bepaal")
      else
		 fScrOpsk(,"Option "+cOption())
         fScrBood(24,"Screen outlay being determined")
      endif

      //Kry die veldbeskrywings
      //aVelde is die array met velde wat vertoon moet word
      //aLedeOp is die array met die volledige veldbesonderhede
      if empty(aVelde)
         aadd(aVelde,{"SM3KLIE","kode"})
         aadd(aVelde,{"SM3KLIE","naam"})
      endif
      aLedeOp := fGetField( aVelde )

      //Kry die totale lengte van die velde om die breedte van die venster te bepaal
      for i = 1 to len( aLedeOp )
         //Lengte
         nScrLen := nScrLen + aLedeOp[i,4] + 1
         //Kolomme
         cData := aLedeOp[i,1] + aLedeOp[i,2]
         cHead := aLedeOp[i,7] + ";" + aLedeOp[i,8] + ";" + aLedeOp[i,9]
         aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
      next

      //Bepaal regterkantste lyn
      nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

      //Teken die box
      if cLanType() == "A"
         fBox( nTop, nLeft, nBottom, nRight, "ADRESSE" )
      else
         fBox( nTop, nLeft, nBottom, nRight, "ADDRESSES" )
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

      // Open die .dbf
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      //Skuif die databasis
      if len( alltrim( cFind ) ) <> 0
         set soft on
         seek cFind
         set soft off
         if eof()
            go top
         endif
      endif

      // Main loop
      lMore := .T.
      do while lMore

         //Skerm
         if cLanType() == "A"
            fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar  [Alt E]=Verander" )
            fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [A - Z]=Vind    " )
         else
            fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [Alt E]=Edit" )
            fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [A - Z]=Find" )
         endif

         //Vries
         cBrowse:freeze := 2

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
            lMore := .f.

         elseif nKey == K_ENTER
            // Enter means return plaaskode and exit
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

         elseif nKey == K_DEL
            // Insert means delete a record
            if fDelete()
               cBrowse:refreshall()
            endif

         elseif nKey == K_F1
            //Hulp
            do help with "sm3klie",1,"oorsig"

         elseif nKey >= 65 .and. nKey <= 90 .or. ;
               nKey >= 97 .and. nKey <= 122 .or. ;
               nKey >= 48 .and. nKey <= 57
            // Means locate a record
            cLocate := upper( chr( nKey ) ) + "     "
            cLocScr := savescreen( 0, 0, 24, 79 )
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Tik die gedeelte van die adreskode waarvoor gesoek word.")
            else
               fScrBood(24,"Type the section of the address code which should be found.")
            endif
            keyboard chr( K_RIGHT )
            //Skerm
            if cLanType() == "A"
               nBoxCoor := fBoxCent( 12, "Vind watter Adreskode? xxxxxx", 1 )
               @12, nBoxCoor say "Vind watter Adreskode?" get cLocate pict "@!"
            else
               nBoxCoor := fBoxCent( 12, "Find what Address Code? xxxxxx", 1 )
               @12, nBoxCoor say "Find what Address Code?" get cLocate pict "@!"
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

   end

   //Herstel
   fATclose(aCdbf)
   fARestScr(aCscr)
   setcursor( cCurCur )

return cReturn

/*************************************************************************/
STATIC FUNCTION fAddChg

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )
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
   local cData := ""
   local nLine   := 0

   //Kry die velde benodig
   asize( aSend, 0 )
   aadd( aSend, { "sm3klie", "kode" })
   aadd( aSend, { "sm3klie", "naam" })
   aadd( aSend, { "sm3klie", "adr1" })
   aadd( aSend, { "sm3klie", "adr2" })
   aadd( aSend, { "sm3klie", "adr3" })
   aadd( aSend, { "sm3klie", "posk" })
   aadd( aSend, { "sm3klie", "wtel" })
   aadd( aSend, { "sm3klie", "htel" })
   aadd( aSend, { "sm3klie", "kontak" })
   aadd( aSend, { "sm3klie", "adat" })
   aadd( aSend, { "sm3klie", "kudkl" })
   aadd( aSend, { "sm3klie", "kudvv" })
   aadd( aSend, { "sm3klie", "tipe" })
   aadd( aSend, { "sm3klie", "datum2" })
   aadd( aSend, { "sm3klie", "opmerk" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
   else
      nRekord := recno()
   endif

   //Lees data
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget(aRecv[i][13])
   next

   //Skerm
   if cLanType() == "A"
      if nRekord == 0
         nBoxCoor := fBoxCent( 5, space(60), 15, "NUWE ADRES" )
      else
         nBoxCoor := fBoxCent( 5, space(60), 15, "VERANDER ADRES" )
      endif
   else
      if nRekord == 0
         nBoxCoor := fBoxCent( 5, space(60), 15, "NEW ADDRESS" )
      else
         nBoxCoor := fBoxCent( 5, space(60), 15, "EDIT ADDRESS" )
      endif
   endif
   nLine := 4

   //Teken veldbeskrywings
   setcolor(cColNorm())
   for i = 1 to len(aRecv)
      @nLine+i,nBoxCoor say aRecv[i][6]
   next

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         for i = 1 to len(aRecv)
            @nLine+i,nBoxCoor+21 say transform( aRecv[i][14] , aRecv[i][10] )
         next
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Kode
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na die adresse" )
               fScrBood( 24, "Tik 'n kort ADRESKODE wat die adres sal identifiseer." )
            else
               fScrBood( 23, "[Esc]=Return to the addresses" )
               fScrBood( 24, "Type a SHORT CODE that will identify the address." )
            endif
            //Die vraag
            @nLine+1,nBoxCoor say aRecv[1][6] get aRecv[1][14] pict aRecv[1][10]
            set curs on
            read
            set curs off
            //Die res
            do case
               case aRecv[1][14] == space(6)
                  if eof()
                     go top
                  endif
                  nLoop := 0
                  loop
               case lastkey() == K_ESC
                  if eof()
                     go top
                  endif
                  nLoop := 0
                  loop
               case lastkey() == K_ENTER
                  lReturn := .t.
                  //Toets of die rekord reeds bestaan
                  seek upper(aRecv[1][14])
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
                           aRecv[i][14] := fieldget( aRecv[i,13] )
                        next
                        //Vertoon data
                        setcolor(cColInve())
                        for i = 1 to len(aRecv)
                           @nLine+i,nBoxCoor+21 say transform(aRecv[i][14],aRecv[i][10])
                        next
                        setcolor(cColNorm())
                        fScrBood( 23 )
                        if cLanType() == "A"
                           fScrWait( 24, "Adres is reeds op rekenaar!" )
                        else
                           fScrWait( 24, "Address is already on computer!" )
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
                     aRecv[i][14] := fieldget( aRecv[i,13] )
                  next
                  //Vertoon data
                  setcolor(cColInve())
                  for i = 1 to len(aRecv)
                     @nLine-1+i+21,nBoxCoor say transform(aRecv[i][14],aRecv[i][10])
                  next
                  setcolor(cColNorm())
            endcase

         case nLoop == 2
            //Naam adres en nommers
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adreskode  [F1]=Hulp" )
               fScrBood( 24, "Tik die NAAM, ADRES en TELEFOON besonderhede." )
            else
               fScrBood( 23, "[Esc]=Return to Address code  [F1]=Help" )
               fScrBood( 24, "Type the NAME, ADDRESS AND TELEPHONE details." )
            endif
            //Die vraag
            @nLine+2 ,nBoxCoor say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10]
            @nLine+3 ,nBoxCoor say aRecv[ 3][6] get aRecv[ 3][14] pict aRecv[ 3][10]
            @nLine+4 ,nBoxCoor say aRecv[ 4][6] get aRecv[ 4][14] pict aRecv[ 4][10]
            @nLine+5 ,nBoxCoor say aRecv[ 5][6] get aRecv[ 5][14] pict aRecv[ 5][10]
            @nLine+6 ,nBoxCoor say aRecv[ 6][6] get aRecv[ 6][14] pict aRecv[ 6][10]
            @nLine+7 ,nBoxCoor say aRecv[ 7][6] get aRecv[ 7][14] pict aRecv[ 7][10]
            @nLine+8 ,nBoxCoor say aRecv[ 8][6] get aRecv[ 8][14] pict aRecv[ 8][10]
            @nLine+9 ,nBoxCoor say aRecv[ 9][6] get aRecv[ 9][14] pict aRecv[ 9][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Die res
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 3
            //Datum in
            //Verstek
            if aRecv[10][14] == ctod("")
               aRecv[10][14] := dAppDate()
            endif
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adreskode  [F1]=Hulp" )
               fScrBood( 24, "Tik die DATUM waarop die adres opgeneem is." )
            else
               fScrBood( 23, "[Esc]=Return to Address code  [F1]=Help" )
               fScrBood( 24, "Type DATE on which the address is taken on." )
            endif
            //Die vraag
            @nLine+10,nBoxCoor say aRecv[10][6] get aRecv[10][14] pict aRecv[10][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Die res
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 4
            //Kuddekenmerk
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adreskode  [F1]=Hulp" )
               fScrBood( 24, "Tik die KUDDEKENMERKLETTERS van die lid indien benodig." )
            else
               fScrBood( 23, "[Esc]=Return to Address code  [F1]=Help" )
               fScrBood( 24, "Type the HERD DESIGNATION LETTERS of the member if required." )
            endif
            //Die vraag
            @nLine+11,nBoxCoor say aRecv[11][6] get aRecv[11][14] pict aRecv[11][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Die res
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 5
            //Voorvoegsel
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adreskode  [F1]=Hulp" )
               fScrBood( 24, "Tik die VOORVOEGSEL van die adres indien benodig." )
            else
               fScrBood( 23, "[Esc]=Return to Address code  [F1]=Help" )
               fScrBood( 24, "Type PREFIX of the address if required." )
            endif
            //Die vraag
            @nLine+12,nBoxCoor say aRecv[12][6] get aRecv[12][14] pict aRecv[12][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Die res
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 6
            //Adrestipe
            //Verstekwaarde
            if len(trim(aRecv[13][14])) <= 0
               aRecv[13][14] := "  -  -  -  -  "
            endif
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adreskode  "+D_DNARR+"=Adrestipes  [F1]=Hulp" )
               fScrBood( 24, "Tik die ADRESTIPE van die lid." )
            else
               fScrBood( 23, "[Esc]=Return to Address code "+D_DNARR+"=Address types  [F1]=Help" )
               fScrBood( 24, "Type the ADDRESS TYPE for the member." )
            endif
            //Die vraag
            @nLine+13,nBoxCoor say aRecv[13][6] get aRecv[13][14] pict aRecv[13][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Die res
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_DOWN
                  cData := ""
                  cData := alltrim(left(aRecv[13][14],2))
                  asize(aVelde,0)
                  aadd(aVelde,{"sm3tipe","tipe"})
                  aadd(aVelde,{"sm3tipe","beskr"})
                  cData := sm3tipe( 5, 11, 20, aVelde, cData )
                  if len( alltrim( cData ) ) > 0
                     if cData $ aRecv[13][14]
                     else
                        aRecv[13][14] := strtran(aRecv[13][14],"  ",cData,1,1)
                        //keyboard chr(K_ENTER)
                     endif
                  endif
                  loop
               case lastkey() == K_ENTER
                  if aRecv[13][14] == space(14) .or. aRecv[13][14] == "  -  -  -  -  "
                     //Ten minste een adrestipe moet bekend wees
                     if cLanType() == "A"
                        fScrBood(23,"Ten minste een adrestipe moet bekend wees!")
                     else
                        fScrBood(23,"At least one address type should be known!")
                     endif
                     fScrWait(24)
                     loop
                  endif
                  cData := ""
                  cData := fTipe(aRecv[13][14])
                  if len(trim(cData)) > 0
                     if cLanType() == "A"
                        fScrBood(23,"Die "+cData+" adrestipe is onbekend!")
                     else
                        fScrBood(23,"The "+cData+" address type is unknown!")
                     endif
                     fScrWait(24)
                     loop
                  endif
                  nLoop++
            endcase

         case nLoop == 7
            //Verdere vrae
            //Skerm
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adreskode  [F1]=Hulp" )
               fScrBood( 24, "Tik enige ANDER DATUM en/of enige OPMERKINGS." )
            else
               fScrBood( 23, "[Esc]=Return to Address code  [F1]=Help" )
               fScrBood( 24, "Type any OTHER DATE and/or any REMARKS." )
            endif
            //Die vraag
            @nLine+14,nBoxCoor say aRecv[14][6] get aRecv[14][14] pict aRecv[14][10]
            @nLine+15,nBoxCoor say aRecv[15][6] get aRecv[15][14] pict aRecv[15][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Die res
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_ENTER
                  nLoop++
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
                           aRecv[i][14] := ctod(" /  /  ")
                        otherwise
                           aRecv[i][14] := space( aRecv[i,4] )
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

/******************************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige adres totaal en al te skrap

   //Verklaar
   local lReturn := .f.

   fScrBood( 23, trim( SM3KLIE->kode ) + " - " + trim( SM3KLIE->naam ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde ADRES geskrap word?",,.f. )
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
      if fJaNee( 24, "Should above ADDRESS be deleted?",,.f. )
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
STATIC FUNCTION fTipe(cTest)

   //Funksie om te toets of al die adrestipes bekend is

   //Verklaar
   local cCurDbf := fTOpen()
   local cTipe   := ""
   local cReturn := ""
   local cData   := ""
   local i := 0

   //Open dataleer
   cTipe := fTOpen(cDd(),"sm3tipe",,"dbf",,.t.,.f.)
   if left(cTipe,1) == "f"
      fTClose(cCurDbf)
      cReturn := "XX"
      return cReturn
   endif

   //Elke kode
   for i = 1 to 13 step 3
      cData := substr(cTest,i,2)
      if len(trim(cData)) > 0
         //Kyk of die kode bestaan
         seek cData
         if eof()
            cReturn := cData
            exit
         endif
      endif
   next

   //Herstel
   fTClose(cTipe)
   fTClose(cCurDbf)
return cReturn

