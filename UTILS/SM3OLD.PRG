//SM3JAAR.PRG
//Program om jaarlikse dagboek inskrywings te bewaar/skrap
//Kopiereg (c) 1992 A van Rensburg
//12:44pm May 26,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION Sm3Jaar( nTop, nLeft, nBottom, aVelde, cFind )

//Veranderlikes
LOCAL cCurSke := savescreen( 0, 0, 24, 79 )  //Skerm
LOCAL cCurScr := fCurScreen()                //Kleure ens
LOCAL cCurDbf := fTOpen()                    //Databasis
LOCAL cCurCur := Setcursor(0)                //Cursor
LOCAL aAdraOp := {}                          //Plaas opskrifte
LOCAL nScrlen := 0                           //Totale lengte van die veld
LOCAL nBoxCoo := 0                           //Waar begin en endig die boks
LOCAL nRight  := 76                          //Regterkantste lyn
LOCAL cBrowse                                //Browse object
LOCAL aColumn := {}                          //Kolomme array
LOCAL i                                      //Counter
LOCAL lMore                                  //Logical looper
LOCAL nKey                                   //Keypress
LOCAL cReturn := cFind                       //Return value
LOCAL lLogic                                 //Diverse logic carrier
LOCAL cLocate
LOCAL cJaar

PRIVATE cData := ""                          //Column data fields for tbrowse
PRIVATE cHead := ""                          //Heading of tbrowse

//Parameters
nTop := if( nTop == NIL, 4, nTop )
nLeft := if( nLeft == NIL, 4, nLeft )
nBottom := if( nBottom == NIL, 4, nBottom )
cFind := if( cFind == NIL, "     ", cFind )

//Skerm
fScrBood(23)
if cLanType() == "A"
   fScrBood(24,"Skermuitleg word bepaal")
else
   fScrBood(24,"Screen outlay being determined")
endif

//Kry die veldbeskrywings
//aVelde is array met velde wat vertoon moet word
//aJaarOp is array met volledige veldbesonderhede
aJaarOp := fGetfield( aVelde )

//Kry totale lengte van velde om breedte van venster te bepaal
for i = 1 to len( aJaarOp )

    //Lengte
    nScrlen := nScrlen + aJaarOp[i,4] + 1

    //Kolomme
    cData := aJaarOp[i,1] + aJaarOp[i,2]
    cHead := aJaarOp[i,7] + ";" + aJaarOp[i,8] + ";" + aJaarOp[i,9]
    aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

next

//Bepaal regterkantste lyn
nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

//Teken die boks
if cLanType() == "A"
   fBox( nTop, nLeft, nBottom, nRight, "JAARLIKSE DAGBOEK" )
else
   fBox( nTop, nLeft, nBottom, nRight, "ANNUAL DIARY" )
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
cJaar := fTOpen( cDd(), "SM3JAAR", , "dbf", , .t., .f. )
if left(cJaar, 1 ) == "f"
   fTClose( cCurDbf )
   fSetScreen( cCurscr )
   restscreen( 0, 0, 24, 79, cCurske )
   return cReturn
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

//Main loop
lMore := .T.
do while lMore

   //Skerm
   if cLanType() == "A"
      fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar  [Alt E]=Verander " )
      fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [Alt P]=Druk     " )
   else
      fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [Alt E]=Edit  " )
      fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [Alt P]=Print " )
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
      cReturn := fieldget(1)
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

   elseif nKey == K_F1
      //Hulp
      do help with "SM3JAAR",1,"oorsig"

   else
      // Apply the key to the browse
      ApplyKey(cBrowse, nKey)

   endif

enddo

//Herstel
fTClose( cJaar )
fTClose( cCurDbf )
fSetScreen( cCurScr )
restscreen( 0, 0, 24, 79, cCurske )
setcursor( cCurCur )

return cReturn

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
aadd( aSend, { "sm3jaar", "dagdag " })
aadd( aSend, { "sm3jaar", "maandd " })
aadd( aSend, { "sm3jaar", "handel " })
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
   nBoxCoor := fBoxCent( 9, space(50), 5, "BEWAAR/VERANDER JAARLIKSE DAGBOEK" )
else
   nBoxCoor := fBoxCent( 9, space(50), 5, "ENTER/EDIT ANNUAL DIARY" )
endif

//Teken veldbeskrywings
setcolor(cColNorm())
@  10, nBoxCoor say aRecv[1 ,6]
@  11, nBoxCoor say aRecv[2 ,6]
@  12, nBoxCoor say aRecv[3 ,6]

nLoop := 1
do while nLoop > 0

   if nLoop == 1
      setcolor(cColInve())
      @ 10, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
      @ 11, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
      @ 12, nBoxCoor+21 say transform( aRecv[3][14] , aRecv[3][10]  )
      setcolor(cColNorm())
   endif

   do case

      case nLoop == 1
           //Dagdag

           //Skerm + read
           if cLanType() == "A"
              fScrBood( 23, "[Esc]=Terug na Dagboek." )
              fScrBood( 24, "Tik die dag. " )
           else
              fScrBood( 23, "[Esc]=Return to Diary." )
              fScrBood( 24, "Type the day." )
           endif
           @  10, nBoxCoor say aRecv[1,6] get aRecv[1][14] pict aRecv[1,10]
           set curs on
           read
           set curs off

           //Return to master
           if lastkey() == K_ESC .or. aRecv[1][14] == 0
              if eof()
                 go top
              endif
              nLoop := 0
              loop
           endif
           lReturn := .t.

           //Toets datum
           if aRecv[1][14] < 1 .or. aRecv[1][14] > 31
              if cLanType() == "A"
                 fScrBood( 23, "Dag moet tussen 1 en 31 wees." )
              else
                 fScrBood( 23, "Day should be between 1 and 31.")
              endif
              fScrBood( 24)
              loop
           endif

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
              fScrBood( 23, "[Esc]=Terug na die dag." )
              fScrBood( 24, "Tik die maand. " )
           else
              fScrBood( 23, "[Esc]=Return to the day." )
              fScrBood( 24, "Type the month." )
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
                   //Toets datum
                   if aRecv[2][14] < 1 .or. aRecv[1][14] > 12
                      if cLanType() == "A"
                         fScrBood( 23, "Die Maand moet tussen 1 en 12 wees." )
                      else
                         fScrBood( 23, "The month should be between 1 and 12.")
                      endif
                      fScrBood( 24)
                      loop
                   endif
                   //Volgende vraag
                   nLoop++
              otherwise
                   loop
           endcase

      case nLoop == 3
           //Handeling
           //Skerm + read
           if cLanType() == "A"
              fScrBood( 23, "[Esc]=Terug na datum." )
              fScrBood( 24, "Tik die handeling.   " )
           else
              fScrBood( 23, "[Esc]=Return to date.")
              fScrBood( 24, "Type the happening." )
           endif
           @ 12, nBoxCoor say aRecv[3,6] get aRecv[3][14] pict aRecv[3,10]
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
                   if aRecv[3][14] == space(60)
                      if cLanType() == "A"
                         fScrBood(23, "Handeling is verpligtend.")
                      else
                         fScrBood(23, "Happening is compulsory.")
                      endif
                      fScrBood(24)
                      loop
                   endif
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
/************************************************************************/
STATIC FUNCTION fDelete

//Funksie om jaarlikse dagboek inskrywings te skrap

//Verklaar
LOCAL lReturn := .f.

fScrBood( 23, Trim( SM3JAAR->Handel) )
if cLanType() == "A"
   if fJaNee( 24, "Moet bogenoemde handeling geskrap word?", , .f. )
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
   if fJaNee( 24, "Should above-mentioned happening be deleted?", , .f. )
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
LOCAL aVelde  := {}
LOCAL aDbfOp  := {}
LOCAL cWaar   := NIL
LOCAL nTotaal := 1
LOCAL lLoop   := .t.
LOCAL nI      := 1
LOCAL nBladsy := 1
LOCAL nRekord := 1

PRIVATE cData

//Toets of drukker gereed is
fScrBood(23)
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
aadd( aVelde, { "sm3jaar", "dagdag" } )
aadd( aVelde, { "sm3jaar", "maandd" } )
aadd( aVelde, { "sm3jaar", "handel" })
aDbfOp := fGetField( aVelde )

nTotaal := lastrec()
go top

//Skerm
fScrBood(23,"")
if cLanType() == "A"
   fScrbood(24,"Jaarlikse Dagboek word gedruk!  [Esc]=Stop drukker.")
else
   fScrbood(24,"Annual Diary being printed!  [Esc]=Stop printer." )
endif

//Doen die loop
lLoop := .t.
do while lLoop

//Skakel die drukker aan
fPrnOn()

//Opskrifte
if prow() = 0

   fPrnCod( cPrnNorm()) )
   @prow()+1,  1 say upper( cGebNaam() )
   if cLanType() == "A"
      @prow()  , 50 say "               Datum: " + dtoc( dAppDate() )
      @prow()+1,  1 say upper( "Jaarlikse Dagboek." )
      @prow()  , 50 say "              Bladsy: " + str( nBladsy, 8 )
   else
      @prow()  , 50 say "                Date: " + dtoc( dAppDate() )
      @prow()+1,  1 say upper( "Annual Diary." )
      @prow()  , 50 say "                Page: " + str( nBladsy, 8 )
   endif
   @prow()+1,  1 say repl( "=", 79 )
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
   @prow()+1,  1 say repl( "=", 79 )

endif

//Toets of drukker moet stop
If fPrnStop() = K_ESC
   fTClose( cWaar )
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
   fPrnOff()
   if nTotaal > 0
   setcolor( cColBott() )
   if cLanType() == "A"
      @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Vol"
   else
      @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Com"
   endif
   setcolor( cColNorm() )
   nRekord++
 endif
 fPrnOn()

 //Volgende rekord
 skip

 //Toets vir einde van bladsy
 if prow() >= 58 .or. eof()

  //Print onderste lyn
  @prow()+1,  1 say repl( "=", 79 )
  @prow()+1,  1 say cAppName()
  fPrnCod( cPrnNorm() )

  //Eject
  @prow()+(nPrnLeng()-prow()),1 say ""
  setprc( 0, 0 )

  fPrnOff()
  nBladsy++

  //Indien eof()
  if eof()
     lLoop := .f.
  endif

 endif

enddo

//Herstel
go top
return NIL
