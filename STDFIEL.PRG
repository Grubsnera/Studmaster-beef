//STDFIEL.PRG
//Program om veldbeskrywings te bewaar
//Kopiereg (c) 1991 A van Rensburg
//07:53 17 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION stdfiel( nTop, nLeft, nBottom, aSend, cFind )

   //Veranderlikes
   local cFile   := ""                           //Status of opened file
   local aRecv := {}                             //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nRight  := 77                           //Regterkantste lyn
   local cBrowse := NIL                          //Browse object
   local aColumn := {}                           //Kolomme array
   local i       := 0                            //Counter
   local lMore   := .t.                          //Logical looper
   local nKey    := 0                            //Keypress
   local cResult := cFind                        //Return value
   local cLocate := ""
   local cLocScr := ""
   local getlist := {}
   local nBoxCoor := 0

   private cData := ""                           //Column data fields for tbrowse
   private cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop    := if( nTop    == NIL, 4, nTop )
   nLeft   := if( nLeft   == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   if aSend == NIL
      aSend := {}
      if cLanType() == "A"
         aadd( aSend, { "stdfiel", "dbfname" })
         aadd( aSend, { "stdfiel", "fldname" })
         aadd( aSend, { "stdfiel", "fldorde" })
         aadd( aSend, { "stdfiel", "fldtype" })
         aadd( aSend, { "stdfiel", "fldleng" })
         aadd( aSend, { "stdfiel", "flddeci" })
         aadd( aSend, { "stdfiel", "fldbesk" })
         aadd( aSend, { "stdfiel", "fldsort" })
         aadd( aSend, { "stdfiel", "fldlist" })
      else
         aadd( aSend, { "stdfiel", "dbfname" })
         aadd( aSend, { "stdfiel", "fldname" })
         aadd( aSend, { "stdfiel", "fldorde" })
         aadd( aSend, { "stdfiel", "fldtype" })
         aadd( aSend, { "stdfiel", "fldleng" })
         aadd( aSend, { "stdfiel", "flddeci" })
         aadd( aSend, { "stdfiel", "flddesc" })
         aadd( aSend, { "stdfiel", "fldsort" })
         aadd( aSend, { "stdfiel", "fldlist" })
      endif
   endif

   //Skerm
   fScrOpsk()

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
      fScrWbood(24,"Datalˆer word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cFile := fTOpen( , "stdfiel", , "tdb", "stdfiel", .f., .f. )
   if left( cFile, 1 ) == "f"
      return cResult
   endif
   set order to 2

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
      fBox( nTop, nLeft, nBottom, nRight, "DATABASIS VELDBESKRYWINGS" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "DATABASE FIELD DESCRIPTIONS" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+2, nBottom-1, nRight-2 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [A - Z]=Vind    " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt E]=Verander" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [A - Z]=Find  " )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt E]=Edit  " )
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
         //Esc means leave
         lMore := .f.

      elseif nKey == K_ENTER
         //Enter means return kode
         cResult := fieldget(1)
         lMore := .f.

      elseif nKey == K_INS
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E
         //Alt E means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_P
         //Alt P means print current dbf fields
         fPrint(aRecv)
         cBrowse:refreshall()

      elseif nKey == K_DEL
         //Delete means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + space(9)
         cLocScr := savescreen( 0, 0, 24, 79 )
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter databasis? xxxxxxxxxx", 1 )
            @12, nBoxCoor say "Vind watter databasis?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find which database? xxxxxxxxxx", 1 )
            @12, nBoxCoor say "Find which database?" get cLocate pict "@!"
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
   fTClose( cFile )
return cResult

/*************************************************************************/
STATIC FUNCTION fAddChg()

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxCoor := 0
   local aSend    := {}
   local aRecv    := {}
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
   asize( aSend, 0 )
   aadd( aSend, { "stdfiel", "dbfname" })
   aadd( aSend, { "stdfiel", "fldorde" })
   aadd( aSend, { "stdfiel", "fldname" })
   aadd( aSend, { "stdfiel", "fldtype" })
   aadd( aSend, { "stdfiel", "fldleng" })
   aadd( aSend, { "stdfiel", "flddeci" })
   aadd( aSend, { "stdfiel", "fldbesk" })
   aadd( aSend, { "stdfiel", "fldops1" })
   aadd( aSend, { "stdfiel", "fldops2" })
   aadd( aSend, { "stdfiel", "fldops3" })
   aadd( aSend, { "stdfiel", "flddesc" })
   aadd( aSend, { "stdfiel", "fldhed1" })
   aadd( aSend, { "stdfiel", "fldhed2" })
   aadd( aSend, { "stdfiel", "fldhed3" })
   aadd( aSend, { "stdfiel", "fldpict" })
   aadd( aSend, { "stdfiel", "fldsort" })
   aadd( aSend, { "stdfiel", "fldlist" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent(  3, space(60),  18, "NUWE VELD" )
      else
         nBoxCoor := fBoxCent(  3, space(60),  18, "NEW FIELD" )
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent(  3, space(60),  18, "VERANDER VELD" )
      else
         nBoxCoor := fBoxCent(  3, space(60),  18, "EDIT FIELD" )
      endif
   endif

   //Vul met data en vertoon
   nLine := 3
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
            @nLine+ 1,nBoxCoor say aRecv[ 1][6] get aRecv[ 1][14] pict aRecv[ 1][10] valid(fDbfName(aRecv,nRekord,nLine,nBoxCoor))
            @nLine+ 2,nBoxCoor say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10] valid(fFldNumb(aRecv,nRekord,nLine,nBoxCoor))
            @nLine+ 3,nBoxCoor say aRecv[ 3][6] get aRecv[ 3][14] pict aRecv[ 3][10] valid(fFldName(aRecv,nRekord,nLine,nBoxCoor))
            @nLine+ 4,nBoxCoor say aRecv[ 4][6] get aRecv[ 4][14] pict aRecv[ 4][10]
            @nLine+ 5,nBoxCoor say aRecv[ 5][6] get aRecv[ 5][14] pict aRecv[ 5][10]
            @nLine+ 6,nBoxCoor say aRecv[ 6][6] get aRecv[ 6][14] pict aRecv[ 6][10]
            @nLine+ 7,nBoxCoor say aRecv[ 7][6] get aRecv[ 7][14] pict aRecv[ 7][10]
            @nLine+ 8,nBoxCoor say aRecv[ 8][6] get aRecv[ 8][14] pict aRecv[ 8][10]
            @nLine+ 9,nBoxCoor say aRecv[ 9][6] get aRecv[ 9][14] pict aRecv[ 9][10]
            @nLine+10,nBoxCoor say aRecv[10][6] get aRecv[10][14] pict aRecv[10][10]
            @nLine+11,nBoxCoor say aRecv[11][6] get aRecv[11][14] pict aRecv[11][10]
            @nLine+12,nBoxCoor say aRecv[12][6] get aRecv[12][14] pict aRecv[12][10]
            @nLine+13,nBoxCoor say aRecv[13][6] get aRecv[13][14] pict aRecv[13][10]
            @nLine+14,nBoxCoor say aRecv[14][6] get aRecv[14][14] pict aRecv[14][10]
            @nLine+15,nBoxCoor say aRecv[15][6] get aRecv[15][14] pict aRecv[15][10]
            @nLine+16,nBoxCoor say aRecv[16][6] get aRecv[16][14] pict aRecv[16][10]
            @nLine+17,nBoxCoor say aRecv[17][6] get aRecv[17][14] pict aRecv[17][10]
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
      fScrBood(23,trim(fieldget(7)))
      cBood := "Moet bogenoemde veld geskrap word?"
   else
      fScrBood(23,trim(fieldget(2)))
      cBood := "Should above-mentioned field be deleted?"
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

//******************************************************************************/
STATIC FUNCTION fDbfName(aDisp,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu := .t.
   local cCscr := savescreen(0,0,24,79)

   if aDisp[1][14] == space(8)
      if cLanType() == "A"
         fScrBood(23,alltrim(aDisp[1][6])+" is verpligtend!")
      else
         fScrBood(23,alltrim(aDisp[1][6])+" is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   endif

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

//******************************************************************************/
STATIC FUNCTION fFldNumb(aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local aDisp   := aclone(aRecv)
   local i       := 0

   do case
      case aRecv[2][14] == space(3)
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[2][6])+" is verpligtend!")
         else
            fScrBood(23,alltrim(aRecv[2][6])+" is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
      case len(alltrim(aRecv[2][14])) < 3
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[2][6])+" moet opgevul word met nulle!")
         else
            fScrBood(23,alltrim(aRecv[2][6])+" should be filled with naughts!")
         endif
         fScrWait(24)
         lRetu := .f.
      case val(aRecv[2][14]) <= 0
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[2][6])+" mag nie nul wees nie!")
         else
            fScrBood(23,alltrim(aRecv[2][6])+" may not be naught!")
         endif
         fScrWait(24)
         lRetu := .f.
      otherwise
         //Kyk of rekord reeds bestaan
         seek aDisp[1][14] + aDisp[2][14]
         if eof()
            //Bestaan nie - gaan voort
            if nRekord > 0
               goto nRekord
            endif
         else
            //Bestaan
            if nRekord > 0 .and. nRekord == recno()
               //Dieselfde rekord - gaan voort
            else
               //Bestaan reeds - vertoon bestaande
               //Vul data
               for i = 1 to len(aDisp)
                  aDisp[i][14] := fieldget(aRecv[i][13])
               next
               //Vertoon data
               setcolor(cColInve())
               for i = 1 to len(aDisp)
                  @nLine+i,nBoxc+21 say transform(aDisp[i][14],aDisp[i][10])
               next
               setcolor(cColNorm())
               //Wag
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,alltrim(aDisp[2][6])+" bestaan reeds!" )
               else
                  fScrWait(24,alltrim(aDisp[2][6])+" already exists!" )
               endif
               if nRekord > 0
                  goto nRekord
               else
                  go bottom
                  skip
               endif
               //Vertoon oorspronklike
               setcolor(cColInve())
               for i = 1 to len(aRecv)
                  @nLine+i,nBoxc+21 say transform(aRecv[i][14],aRecv[i][10])
               next
               setcolor(cColNorm())
               lRetu := .f.
            endif
         endif
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

//******************************************************************************/
STATIC FUNCTION fFldName(aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local aDisp   := aclone(aRecv)
   local i       := 0

   do case
      case len(alltrim(aRecv[3][14])) == 0
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[3][6])+" is verpligtend!")
         else
            fScrBood(23,alltrim(aRecv[3][6])+" is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
      otherwise
         //Kyk of rekord reeds bestaan
         set order to 1
         seek aDisp[1][14] + aDisp[3][14]
         if eof()
            //Bestaan nie - gaan voort
            if nRekord > 0
               goto nRekord
            endif
         else
            //Bestaan
            if nRekord > 0 .and. nRekord == recno()
               //Dieselfde rekord - gaan voort
            else
               //Bestaan reeds - vertoon bestaande
               //Vul data
               for i = 1 to len(aDisp)
                  aDisp[i][14] := fieldget(aRecv[i][13])
               next
               //Vertoon data
               setcolor(cColInve())
               for i = 1 to len(aDisp)
                  @nLine+i,nBoxc+21 say transform(aDisp[i][14],aDisp[i][10])
               next
               setcolor(cColNorm())
               //Wag
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,alltrim(aDisp[3][6])+" bestaan reeds!" )
               else
                  fScrWait(24,alltrim(aDisp[3][6])+" already exists!" )
               endif
               if nRekord > 0
                  goto nRekord
               else
                  go bottom
                  skip
               endif
               //Vertoon oorspronklike
               setcolor(cColInve())
               for i = 1 to len(aRecv)
                  @nLine+i,nBoxc+21 say transform(aRecv[i][14],aRecv[i][10])
               next
               setcolor(cColNorm())
               lRetu := .f.
            endif
         endif
         set order to 2
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aSend)

   //Verklaar
   local aDbfOp  := {}
   local nTotaal := 0
   local lLoop   := .t.
   local nI      := 1
   local nRekord := 1
   local cDbfn   := ""
   local nCurr   := recno()
   local nNewr   := 0
   local cData   := ""
   local cHdln   := ""
   local cPcod   := ""
   local nMidc   := 0
   local nWidt   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local nPagl   := 0
   local nBlad   := 1

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   cDbfn := fieldget(1)
   seek cDbfn
   if eof()
      return NIL
   endif
   nNewr := recno()

   //Tel aantal velde
   if cLanType() == "A"
      fScrWbood(24,"Aantal velde word getel")
   else
      fScrWbood(24,"Number of fields being counted")
   endif
   do while STDFIEL->dbfname == cDbfn
      nTotaal++
      skip
   enddo
   goto nNewr

   //Kry die velde wat gedruk moet word
   if aSend == NIL
      aSend := {}
      asize( aSend, 0 )
      if cLanType() == "A"
         fScrWbood(24,"Verslagformaat word bepaal")
         aadd( aSend, { "stdfiel", "dbfname" })
         aadd( aSend, { "stdfiel", "fldname" })
         aadd( aSend, { "stdfiel", "fldorde" })
         aadd( aSend, { "stdfiel", "fldtype" })
         aadd( aSend, { "stdfiel", "fldleng" })
         aadd( aSend, { "stdfiel", "flddeci" })
         aadd( aSend, { "stdfiel", "fldbesk" })
         aadd( aSend, { "stdfiel", "fldsort" })
         aadd( aSend, { "stdfiel", "fldlist" })
      else
         fScrWbood(24,"Report format being determined")
         aadd( aSend, { "stdfiel", "dbfname" })
         aadd( aSend, { "stdfiel", "fldname" })
         aadd( aSend, { "stdfiel", "fldorde" })
         aadd( aSend, { "stdfiel", "fldtype" })
         aadd( aSend, { "stdfiel", "fldleng" })
         aadd( aSend, { "stdfiel", "flddeci" })
         aadd( aSend, { "stdfiel", "flddesc" })
         aadd( aSend, { "stdfiel", "fldsort" })
         aadd( aSend, { "stdfiel", "fldlist" })
      endif
      aDbfOp := fGetField( aSend )
   else
      aDbfOp := aclone(aSend)
   endif

   //Bepaal die drukwydte
   nWidt := 0
   for nI = 1 to len(aDbfOp)
      nWidt+= aDbfOp[nI,4]+1
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
      fScrbood(24,"Veldbeskrywings word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper( "Velde vir die "+trim(cDbfn)+" databasis." )
   else
      fScrbood(24,"Field descriptions being printed!  [Esc]=Stop printer.")
      cHdln := upper( "Fields for the "+trim(cDbfn)+" database." )
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
         cData := ""
         for nI = 1 to len( aDbfOp )
            cData := cData + padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData,nWidt)

         //2e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aDbfOp )
            cData := cData + padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData,nWidt)

         //3e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aDbfOp )
            cData := cData + padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData,nWidt)

         //4e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aDbfOp )
            cData := cData + repl("-",aDbfOp[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData,nWidt)
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Data
      for nI = 1 to len( aDbfOp )
         if nI == 1
            @prow()+1,       1 say fieldget(aDbfOp[nI,13])
         else
            @prow()  ,pcol()+1 say fieldget(aDbfOp[nI,13])
         endif
      next

      //Skerm
      // fPrnOff()
      // if nTotaal > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say fPercent(nRekord/nTotaal)+"% Voltooi"
      //    else
      //       @ 23, 30 say fPercent(nRekord/nTotaal)+"% Completed"
      //    endif
      //    setcolor( cColNorm() )
      //    nRekord++
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof() .or. STDFIEL->dbfname <> cDbfn
         //Print onderste lyn
         @prow()+1,  1 say repl( "=", nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof() .or. STDFIEL->dbfname <> cDbfn
            lLoop := .f.
         endif
      endif
   enddo

   fPrnOff()

   //Herstel
   goto nNewr
return NIL

