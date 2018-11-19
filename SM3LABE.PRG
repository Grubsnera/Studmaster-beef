//SM3LABE.PRG
//Program om plakkerformate te bewaar
//Kopiereg (c) 1992 A van Rensburg
//18:08 10 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3labe( nTop, nLeft, nBottom, aVelde )

//Veranderlikes
LOCAL GetList := {}
LOCAL cCurSke := savescreen( 0, 0, 24, 79 )      //Skerm
LOCAL cCurScr := fCurScreen()                    //Kleure ens
LOCAL cCurDbf := fTOpen()                        //Databasis
LOCAL cCurCur := setcursor(0)                    //Cursor
LOCAL aLabeOp := {}                              //Plaas opskrifte
LOCAL nScrLen := 0                               //Totale lengte van die velde
LOCAL nBoxCoo := 0                               //Waar begin en eindig die box
LOCAL nRight  := 76                              //Regterkantste lyn
LOCAL cBrowse                                    //Browse object
LOCAL aColumn := {}                              //Kolomme array
LOCAL i                                          //Counter
LOCAL lMore                                      //Logical looper
LOCAL nKey                                       //Keypress
LOCAL lLogic                                     //Diverse logic carrier
LOCAL cLocate
LOCAL cLabe
local nReturn := 0

PRIVATE cData := ""                              //Column data fields for tbrowse
PRIVATE cHead := ""                              //Heading of tbrowse

//Parameters
nTop := if( nTop == NIL, 4, nTop )
nLeft := if( nLeft == NIL, 60, nLeft )
nBottom := if( nBottom == NIL, 20, nBottom )

//Skerm
fScrBood(23,"")
if cLanType() == "A"
  fScrBood(24,"Skermuitleg word bepaal")
else
  fScrBood(24,"Screen outlay being determined")
endif

//Kry die veldbeskrywings
//aVelde is die array met velde wat vertoon moet word
//aLabeOp is die array met die volledige veldbesonderhede
aLabeOp := fGetField( aVelde )

//Kry die totale lengte van die velde om die breedte van die venster te bepaal
for i = 1 to len( aLabeOp )
  //Lengte
  nScrLen := nScrLen + aLabeOp[i,4] + 1
  //Kolomme
  cData := aLabeOp[i,1] + aLabeOp[i,2]
  cHead := aLabeOp[i,7] + ";" + aLabeOp[i,8] + ";" + aLabeOp[i,9]
  aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
next

//Bepaal regterkantste lyn
nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

//Teken die box
if cLanType() == "A"
  fBox( nTop, nLeft, nBottom, nRight, "ADRESPLAKKERS" )
else
  fBox( nTop, nLeft, nBottom, nRight, "ADDRESS LABELS" )
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
cLabe := fTOpen( cDd(), "sm3labe", , "dbf", , .t., .f. )
if left( cLabe, 1 ) == "f"
  fTClose( cCurDbf )
  fSetScreen( cCurScr )
  restscreen( 0, 0, 24, 79, cCurSke )
   return nReturn
endif

// Main loop
lMore := .T.
do while lMore

  //Skerm
  if cLanType() == "A"
    fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar                  " )
    fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [Alt E]=Verander" )
  else
    fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter               " )
    fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [Alt E]=Edit" )
  endif

  //Vries
  cBrowse:freeze := 1

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
    nReturn := recno()
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
    do help with "sm3labe",1,"oorsig"

  else
    // Apply the key to the browse
    ApplyKey(cBrowse, nKey)

  endif

enddo

//Herstel
fTClose( cLabe )
fTClose( cCurDbf )
fSetScreen( cCurScr )
restscreen( 0, 0, 24, 79, cCurSke )
setcursor( cCurCur )

return nReturn

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

//Kry die velde benodig
asize( aSend, 0 )
aadd( aSend, { "sm3labe", "laname" })
aadd( aSend, { "sm3labe", "laaccr" })
aadd( aSend, { "sm3labe", "lastar" })
aadd( aSend, { "sm3labe", "lawidt" })
aadd( aSend, { "sm3labe", "lacolb" })
aadd( aSend, { "sm3labe", "laheig" })
aadd( aSend, { "sm3labe", "labetw" })
aadd( aSend, { "sm3labe", "latype" })
aadd( aSend, { "sm3labe", "lali01" })
aadd( aSend, { "sm3labe", "lali02" })
aadd( aSend, { "sm3labe", "lali03" })
aadd( aSend, { "sm3labe", "lali04" })
aadd( aSend, { "sm3labe", "lali05" })
aadd( aSend, { "sm3labe", "lali06" })
aadd( aSend, { "sm3labe", "lali07" })
aadd( aSend, { "sm3labe", "lali08" })
aadd( aSend, { "sm3labe", "lali09" })
aadd( aSend, { "sm3labe", "lali10" })
aRecv := fGetField( aSend )

//Bou veranderlikes
if eof()
  nRekord := 0
  //Skerm
  if cLanType() == "A"
    nBoxCoor := fBoxCent( 4, space(50), 18, "NUWE PLAKKERS" )
  else
    nBoxCoor := fBoxCent( 4, space(50), 18, "NEW LABELS" )
  endif
else
  nRekord := recno()
  //Skerm
  if cLanType() == "A"
    nBoxCoor := fBoxCent( 4, space(50), 18, "VERANDER PLAKKERS" )
  else
    nBoxCoor := fBoxCent( 4, space(50), 18, "EDIT LABELS" )
  endif
endif

//Lees data
for i = 1 to len( aRecv )
  aRecv[i][14] := fieldget( aRecv[i,13] )
next

//Teken veldbeskrywings
setcolor(cColNorm())
for i = 1 to len( aRecv )
  @3+i, nBoxCoor say aRecv[i][6]
next

nLoop := 1
do while nLoop > 0

  if nLoop == 1
    setcolor(cColInve())
    for i = 1 to len( aRecv )
      @3+i, nBoxCoor+21 say transform( aRecv[i][14] , aRecv[i][10]  )
    next
    setcolor(cColNorm())
  endif

  do case

    case nLoop == 1
      //Naam

      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na die plakkerspesifikasies" )
        fScrBood( 24, "Tik 'n NAAM vir die plakker." )
      else
        fScrBood( 23, "[Esc]=Return to label specification" )
        fScrBood( 24, "Type a NAME for the label." )
      endif
      @  4, nBoxCoor say aRecv[1,6] get aRecv[1][14] pict aRecv[1,10]
      set curs on
      read
      set curs off

      //Keys
      do case
        case lastkey() == K_ESC
          if eof()
            go top
          endif
          nLoop := 0
        case aRecv[1][14] == space(30)
          if eof()
            go top
          endif
          nLoop := 0
        case lastkey() == K_ENTER
          lReturn := .t.
          nLoop++
      endcase

    case nLoop == 2
      //Labels accross
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "Hoeveel plakkers is daar langs mekaar op die bladsy?" )
      else
        fScrBood( 23, "[Esc]=Return to Label name" )
        fScrBood( 24, "How many labels alongside each other on the page?" )
      endif
      @  5, nBoxCoor say aRecv[2,6] get aRecv[2][14] pict aRecv[2,10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 3
      //Beginkolom
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "By watter kolom moet die plakker begin druk?" )
      else
        fScrBood( 23, "[Esc]=Return to Label Name" )
        fScrBood( 24, "At which column should printing of the label commence?" )
      endif
      @  6, nBoxCoor say aRecv[3,6] get aRecv[3][14] pict aRecv[3,10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 4
      //Wydte
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "Hoeveel kolomme wyd is die plakker?" )
      else
        fScrBood( 23, "[Esc]=Return to Label name" )
        fScrBood( 24, "How many columns wide is the label?" )
      endif
      @  7, nBoxCoor say aRecv[4,6] get aRecv[4][14] pict aRecv[4,10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 5
      //Kolomme tussenin
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "Hoeveel kolomme is daar tussen die plakkers?" )
      else
        fScrBood( 23, "[Esc]=Return to Label name" )
        fScrBood( 24, "How many columns between the labels?" )
      endif
      @  8, nBoxCoor say aRecv[5,6] get aRecv[5][14] pict aRecv[5,10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 6
      //Lyne hoog
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "Hoeveel lyne hoog is die plakker?" )
      else
        fScrBood( 23, "[Esc]=Return to Label name" )
        fScrBood( 24, "How many lines wide is the label?" )
      endif
      @  9, nBoxCoor say aRecv[6,6] get aRecv[6][14] pict aRecv[6,10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 7
      //Lyne tussenin
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "Hoeveel lyne is oop tussen die plakkers?" )
      else
        fScrBood( 23, "[Esc]=Return to Label name" )
        fScrBood( 24, "How many open lines between the labels?" )
      endif
      @ 10, nBoxCoor say aRecv[7,6] get aRecv[7][14] pict aRecv[7,10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 8
      //Tipe druk
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam" )
        fScrBood( 24, "Watter tipe druk moet gebruik word?  [N]ormaal  [C]Klein  [W]yd" )
      else
        fScrBood( 23, "[Esc]=Return to Label name" )
        fScrBood( 24, "What type of print should be used?  [N]ormal  [C]ondensed  [W]ide" )
      endif
      @ 11, nBoxCoor say aRecv[8,6] get aRecv[8][14] pict aRecv[8,10] valid(aRecv[8][14]$" NCW")
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
          nLoop++
      endcase

    case nLoop == 9
      //Velde
      //Skerm + read
      if cLanType() == "A"
        fScrBood( 23, "[Esc]=Terug na Plakkernaam  [F1]=Hulp" )
        fScrBood( 24, "Tik die veldbesonderhede wat op elke lyn gedruk moet word." )
      else
        fScrBood( 23, "[Esc]=Return to Label name  [F1]=Help" )
        fScrBood( 24, "Type the field information that should be printed on each line." )
      endif
      @ 12, nBoxCoor say aRecv[9][6] get aRecv[9][14] pict aRecv[9][10]
      @ 13, nBoxCoor say aRecv[10][6] get aRecv[10][14] pict aRecv[10][10]
      @ 14, nBoxCoor say aRecv[11][6] get aRecv[11][14] pict aRecv[11][10]
      @ 15, nBoxCoor say aRecv[12][6] get aRecv[12][14] pict aRecv[12][10]
      @ 16, nBoxCoor say aRecv[13][6] get aRecv[13][14] pict aRecv[13][10]
      @ 17, nBoxCoor say aRecv[14][6] get aRecv[14][14] pict aRecv[14][10]
      @ 18, nBoxCoor say aRecv[15][6] get aRecv[15][14] pict aRecv[15][10]
      @ 19, nBoxCoor say aRecv[16][6] get aRecv[16][14] pict aRecv[16][10]
      @ 20, nBoxCoor say aRecv[17][6] get aRecv[17][14] pict aRecv[17][10]
      @ 21, nBoxCoor say aRecv[18][6] get aRecv[18][14] pict aRecv[18][10]
      readexit(.t.)
      set curs on
      read
      set curs off
      readexit(.f.)

      //Keys
      do case
        case lastkey() == K_ESC
          //Return to first get
          nLoop := 1
        case lastkey() == K_UP
          //Return to first get
          nLoop--
        case lastkey() == K_ENTER
          //Volgende vraag
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
          next
          commit
          exit
        endif
      enddo

      //if nRekord = 0
      //   nLoop := 1
      //else
      nRekord = 0
      nLoop := 0
      //endif

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

fScrBood( 23, trim( SM3LABE->laname ) )
if cLanType() == "A"
  if fJaNee( 24, "Moet bogenoemde PLAKKER geskrap word?",,.f. )
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
  if fJaNee( 24, "Should above LABEL be deleted?",,.f. )
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

