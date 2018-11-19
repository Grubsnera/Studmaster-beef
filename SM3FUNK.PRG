//SM3FUNK.PRG
//Funksies net vir die beesprogram
//Kopiereg (c) 1992 A van Rensburg
//14:34 18 Sep,1992

Static nIndex := 1

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "Box.ch"
#include "Common.ch"

#xcommand Default <cVar> To <xValue> =>  ;
   <cVar> := Iif(Valtype(<cVar>)!= Valtype(<xValue>),<xValue>,<cVar>)

#define ADIDNR 1                                 // Id number of animal
#define ADVAAR 2                                 // Sire id number
#define ADMOER 3                                 // Dam id number
#define ADGEBR 4                                 // Birth date
#define ADINTK 5                                 // Inbreeding coefficient
#define ADSIRE 6                                 // Position of Sire in matrix
#define ADDAM  7                                 // Position of dam in matrix

/******************************************************************************/
FUNCTION fStamboom(cId)

   //Funksie om basiese stamboombesonderhede na te slaan
   //SM3DATA lˆer moet reeds oop wees en id nommer moet
   //die bestaande indeks wees

   //Verklaar
   //local cSker := savescreen(23,0,24,79)
   local cCurd := fTOpen()
   local aStam := {}
   local i     := 0

   //Waardes
   for i = 1 to 15
      aadd(aStam,{space(12),space(30),space(10)," "})
   next

   //Skerm
   //fScrBood(23)
   if cLanType() == "A"
      //fScrWbood(24,"Voorgeslagte word opgesoek")
   else
      //fScrWbood(24,"Ancestors being sorted")
   endif

   //Soek die dier
   select SM3DATA
   set order to 1

   //Dier self
   aStam[1][1] := cId

   for i = 1 to 15
      if aStam[i][1] == space(12)
         //Moenie soek
      else
         seek aStam[i][1]
         if found()
            aStam[i][2] := SM3DATA->kalfbnr
            aStam[i][3] := SM3DATA->reknr
            do case
               case i==1
                  aStam[i+1][1] := SM3DATA->idvaar
                  aStam[i+2][1] := SM3DATA->idmoer
                  aStam[i+1][4] := "2"
                  aStam[i+2][4] := "1"
               case i==2
                  aStam[i+2][1] := SM3DATA->idvaar
                  aStam[i+3][1] := SM3DATA->idmoer
                  aStam[i+2][4] := "2"
                  aStam[i+3][4] := "1"
               case i==3
                  aStam[i+3][1] := SM3DATA->idvaar
                  aStam[i+4][1] := SM3DATA->idmoer
                  aStam[i+3][4] := "2"
                  aStam[i+4][4] := "1"
               case i==4
                  aStam[i+4][1] := SM3DATA->idvaar
                  aStam[i+5][1] := SM3DATA->idmoer
                  aStam[i+4][4] := "2"
                  aStam[i+5][4] := "1"
               case i==5
                  aStam[i+5][1] := SM3DATA->idvaar
                  aStam[i+6][1] := SM3DATA->idmoer
                  aStam[i+5][4] := "2"
                  aStam[i+6][4] := "1"
               case i==6
                  aStam[i+6][1] := SM3DATA->idvaar
                  aStam[i+7][1] := SM3DATA->idmoer
                  aStam[i+6][4] := "2"
                  aStam[i+7][4] := "1"
               case i==7
                  aStam[i+7][1] := SM3DATA->idvaar
                  aStam[i+8][1] := SM3DATA->idmoer
                  aStam[i+7][4] := "2"
                  aStam[i+8][4] := "1"
            endcase
         else
            //Dier onbekend
         endif
      endi
   next

   //Herstel
   select SM3DATA
   set order to 1
   fTClose(cCurd)
   //restscreen(23,0,24,79,cSker)
return aStam

/**************************************************************************/
FUNCTION f5GenStam(cId)

   //Funksie om basiese stamboombesonderhede na te slaan
   //SM3DATA lˆer moet reeds oop wees en id nommer moet
   //die bestaande indeks wees

   //Verklaar
   LOCAL aCdbf := fATOpen()
   LOCAL aStam := {}
   LOCAL i     := 0

   //Waardes
   FOR i = 1 TO 63
      AADD(aStam,{SPACE(12),SPACE(8),SPACE(10)," "})
   NEXT

   //Soek die dier
   DBSELECTAREA("SM3DATA")
   DBSETORDER(1)

   //Dier self
   aStam[1,1] := cId

   FOR i = 1 TO 63
      IF ! EMPTY(aStam[i,1])
         IF SM3DATA->(DBSEEK(aStam[i,1]))
            aStam[i,2] := SM3DATA->kalfbnr
            aStam[i,3] := SM3DATA->reknr

            IF i < 32
               aStam[i+i,1] := SM3DATA->idvaar
               aStam[i+i,4] := "2"
               aStam[i+i+1,1] := SM3DATA->idmoer
               aStam[i+i+1,4] := "1"
            ENDIF
         ENDIF
      ENDIF
   NEXT

   //Herstel
   fATClose(aCdbf)

RETURN aStam

/**************************************************************************/
FUNCTION fBroers(cId)

   //Funksie om enige dier se broers en susters op te spoor
   //SM3DATA lˆer moet reeds oop wees

   //Verklaar
   //local cSker := savescreen(23,0,24,79)
   local cCurd := fTOpen()
   local aBroe := {}
   local i     := 0
   local cOuer := space(12)

   //Toets vir geen ouer
   if empty(cId)
      return aBroe
   endif

   //Skerm
   //fScrBood(23)
   if cLanType() == "A"
      //fScrWbood(24,"Broers en susters word opgesoek")
   else
      //fScrWbood(24,"Brothers and sisters being checked")
   endif

   //Databasis
   select SM3DATA
   set order to 1

   //Soek dier self
   seek cId
   if eof()
      return aBroe
   endif

   //Kry die ouer van die dier
   if SM3DATA->geslag == "2"
      if empty(SM3DATA->idvaar)
      else
         cOuer := SM3DATA->idvaar
         set order to 5
         seek cOuer
         do while SM3DATA->idvaar == cOuer .and. !eof()
            aadd(aBroe,SM3DATA->idnr)
            skip
         enddo
      endif
   else
      if empty(SM3DATA->idmoer)
      else
         cOuer := SM3DATA->idmoer
         set order to 4
         seek cOuer
         do while SM3DATA->idmoer == cOuer .and. !eof()
            aadd(aBroe,SM3DATA->idnr)
            skip
         enddo
      endif
   endif

   //Herstel
   select SM3DATA
   set order to 1
   fTClose(cCurd)
   //restscreen(23,0,24,79,cSker)
return aBroe

/**************************************************************************/
FUNCTION fSeuns(cId)

   //Funksie om enige dier se kinders op te spoor
   //SM3DATA lˆer moet reeds oop wees

   //Verklaar
   //local cSker := savescreen(23,0,24,79)
   local cCurd := fTOpen()
   local aSeun := {}
   local i     := 0

   //Skerm
   //fScrBood(23)
   if cLanType() == "A"
      //fScrWbood(24,"Nageslag word opgesoek")
   else
      //fScrWbood(24,"Progeny being sorted")
   endif

   //Databasis
   select SM3DATA
   set order to 1

   //Soek dier self
   seek cId
   if eof()
      return aSeun
   endif

   //Kry die ouer van die dier
   if SM3DATA->geslag == "2"
      set order to 5
      seek cId
      do while SM3DATA->idvaar == cId
         aadd(aSeun,SM3DATA->idnr)
         skip
      enddo
   else
      set order to 4
      seek cId
      do while SM3DATA->idmoer == cId
         aadd(aSeun,SM3DATA->idnr)
         skip
      enddo
   endif

   //Herstel
   select SM3DATA
   set order to 1
   fTClose(cCurd)
   //restscreen(23,0,24,79,cSker)
return aSeun

/****************************************************************************/
FUNCTION fRasNaam(cRask,cVeld)

   //Funksie om rasbesonderhede te verkry

   //Veranderlikes
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lMore := .t.
   local cRetu := ""

   begin sequence

      // Waardes
      cRask := if(cRask==NIL,"",cRask)
      cVeld := if(cVeld==NIL,"",cVeld)

      // Open dryfleer
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      //dbUseArea(.t.,,cDd()+"sm3rass.dbf","sm3rass",.t.,.f.)
      //if neterr()
      //else

      // Vind die ras
      if empty(cRask)
         go bottom
         skip
      else
         locate for SM3RASS->raskod = cRask
      endif

      //Kry die data
      if upper(cVeld) == "HEADBN"
         cRetu := trim(SM3RASS->headbn)
      elseif upper(cVeld) == "HEADCL"
         cRetu := trim(SM3RASS->headcl)
      elseif upper(cVeld) == "HEADIL"
         cRetu := trim(SM3RASS->headil)
      elseif upper(cVeld) == "HEADTL"
         cRetu := trim(SM3RASS->headtl)
      elseif upper(cVeld) == "HEADDL"
         cRetu := trim(SM3RASS->headdl)
      elseif upper(cVeld) == "BREEDP"
         cRetu := trim(SM3RASS->breedp)
      elseif upper(cVeld) == "ISOCOD"
         cRetu := trim(SM3RASS->isocod)
      elseif upper(cVeld) == "BREEDS"
         cRetu := trim(SM3RASS->breeds)
      else
         cRetu := trim(SM3RASS->rasnaa)
      endif


      //endif

   end

   //Herstel
   fATclose(aCdbf)
   fARestScr(aCscr)

return cRetu

*-----------------------------------------------------------------------------*
FUNCTION LPICKLIST(;
      aArray,;                                   // The Array to Browse
      nTop,nLeft,nBottom,nRight,;                // The Browse Window Coords
      aShowElements,;                            // The Columns to Browse
      cMessage,;                                 // Optional Message on Top
      aActions,;                                 // Custom Actions to Preform
      bPreBlock,;                                // Evaluate before main loop
      bPostBlock,;                               // Evaluaate after main loop
      cNewClr)                                   // New Colour Settings

   LOCAL oBrowse,oColumn                         // Browse and Columns Objects
   LOCAL nOldIndex:=nIndex,;                     // Curs pos. Saved for recursion
      nKey,;                                     // Inkey variable
      nCounter,;                                 // Temp loop counter
      nOldCursor := set(_SET_CURSOR,0), ;        // Cursor Size
      nSkipped,;                                 // Skipblock variable
      nRetValue := 0,;                           // Return variable
      nNumber := 48                              // Mark Number Counter
   LOCAL lDone,;                                 // Flag Variable
      lContinue := TRUE                          // Loop Test variable
   LOCAL cScreen                                 // Screen region saved
   LOCAL aCursorPos:={Row(),Col()}               // Save Cursor position
   LOCAL bAction                                 // Used with Setkey() Evaluation
   LOCAL cDev := SET(_SET_DEVICE,"SCREEN")
   LOCAL cColor := SETCOLOR()                    // Current Colour Settings

   nIndex := 1                                   // Reset static variable

   // Default values for parameters
   DEFAULT aActions To {}
   DEFAULT aShowElements To {}
   DEFAULT nTop To 0
   DEFAULT nLeft To 0
   DEFAULT nBottom To MaxRow()
   DEFAULT nRight To MaxCol()

   If cNewClr != NIL
      SETCOLOR(cNewClr)
   Endif

   If len(aArray) < nBottom - nTop+1
      nBottom := nTop+len(aArray)+1
   Endif

   If Len(aShowElements) == 0                    // If not specify, browse
      For nCounter := 1 To Len(aArray[1])        // all columns
         aAdd(aShowElements,nCounter)
      Next
   Endif

   cScreen := SaveScreen(nTop,nLeft,nBottom+1,nRight+2)
   DispBox(nTop,nLeft,nBottom,nRight,B_DOUBLE+" ")
   LBoxShadow(nTop,nLeft,nBottom,nRight)

   If cMessage != NIL
      @ nTop,nLeft+2 SAY "[ "+SUBSTR(cMessage,1,MIN(LEN(cMessage),(nRight-nLeft-7)))+" ]"
   Endif

   oBrowse := TBrowseNew(nTop+1,nLeft+1,nBottom-1,nRight-1)
   oBrowse:SkipBlock := {|nToSkip| ;
      nSkipped := If(Abs(nToSkip) >= If(nToSkip >= 0, ;
      Len(aArray) - nIndex, nIndex - 1), ;
      If(nToSkip >= 0, Len(aArray) - nIndex, ;
      1 - nIndex), nToSkip), ;
      nIndex += nSkipped,  nSkipped }

   oBrowse:GoTopBlock := { || nIndex := 1 }
   oBrowse:GoBottomBlock := { || nIndex := Len(aArray) }

   // Add the columns for the Browse
   for nCounter := 1 to len(aShowElements)
      oColumn := TBColumnNew("",MakeBlock(aArray,;
         aShowElements[nCounter]))
      oBrowse:AddColumn(oColumn)

   next

   If ValType(bPreBlock) == "B"
      EVal(bPreBlock,aArray,oBrowse)
   Endif

   Do While lContinue
    /* stabilization */
      Do While ( !oBrowse:stabilize() )          // Wait for Repaint
      enddo

      oBrowse:ColorRect({oBrowse:RowPos,1,;
         oBrowse:RowPos,oBrowse:ColCount},{2,1})
      nKey := Inkey(0)

      // First test custom Actions
      lDone := FALSE
      For nCounter := 1 to len(aActions)
         If nKey == aActions[nCounter,1]
            If Valtype(aActions[nCounter,2]) == "B"
               lContinue := Eval(aActions[nCounter,2],;
                  aArray,nIndex,oBrowse,@nNumber)
               If Valtype(lContinue) != "L"
                  lContinue := TRUE
               Endif
               If !lContinue
                  nRetValue := nIndex
               Endif
            Endif
            lDone := TRUE
            Exit
         Endif
      Next

      // Otherwise Default Actions
      If !lDone
         Do Case
            Case (bAction := SetKey(nKey)) != NIL
               Eval(bAction,ProcName(),ProcLine(),ReadVar())
            Case nKey == K_UP         ;oBrowse:Up()
            Case nKey == K_DOWN       ;oBrowse:Down()
            Case nKey == K_PGUP       ;oBrowse:PageUp()
            Case nKey == K_CTRL_RIGHT ;oBrowse:PanRight()
            Case nKey == K_CTRL_LEFT  ;oBrowse:PanLeft()
            Case nKey == K_PGDN       ;oBrowse:PageDown()
            Case nKey == K_CTRL_PGUP  ;oBrowse:GoTop()
            Case nKey == K_CTRL_PGDN  ;oBrowse:GoBottom()
            Case nKey == K_ENTER
               lContinue := FALSE
               nRetValue := nIndex
            Case nKey == K_ESC
               lContinue := FALSE
               nRetValue := 0
         Endcase
      Endif
      oBrowse:ColorRect({oBrowse:RowPos,1,;
         oBrowse:RowPos,oBrowse:ColCount},{1,2})

   Enddo

   If ValType(bPostBlock) == "B"
      EVal(bPostBlock,aArray,oBrowse)
   Endif

   // Restore the environment before leaving
   SetPos(aCursorPos[1],aCursorPos[2])           // Put cursor back
   Set(_SET_CURSOR,nOldCursor)                   // Restore Cursor Size
   SETCOLOR(cColor)
   RestScreen(nTop,nLeft,nBottom+1,nRight+2,;
      cScreen)                                   // Restore Screen
   SET(_SET_DEVICE,cDev)
   nIndex := nOldIndex                           // Reset Array Index for
   // Recursive Calls
Return nRetValue                                 // Return a Value

*-----------------------------------------------------------------------------*
// Used in the above picklist
Static Function MakeBlock(aArray,nColumn)

Return {|| aArray[nIndex,nColumn] }

*------------------------------------------------------------------------------*
// LBoxShadow taken from the samples subdirectory of Clipper 5
Procedure LBoxShadow( nTop, nLeft, nBottom, nRight )
   LOCAL nShadTop, nShadLeft, nShadBottom, nShadRight
   LOCAL cDev := SET(_SET_DEVICE,"SCREEN")

   nShadTop   := nShadBottom := MIN(nBottom + 1, MaxRow())
   nShadLeft  := nLeft + 2
   nShadRight := MIN(nRight + 2, MaxCol())

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
      TRANSFORM( SAVESCREEN(nShadTop, nShadLeft, nShadBottom, nShadRight),;
      REPLICATE("X", nShadRight - nShadLeft + 1 ) ) )

   nShadTop    := nTop + 1
   nShadLeft   := nShadRight := MIN(nRight + 1, MaxCol())
   nShadBottom := nBottom

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
      TRANSFORM( SAVESCREEN(nShadTop,  nShadLeft , nShadBottom,  nShadRight),;
      REPLICATE("X", nShadBottom - nShadTop + 1 ) ) )

   nShadTop    := nTop + 1
   nShadLeft   := nShadRight := MIN(nRight + 2, MaxCol())
   nShadBottom := nBottom

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
      TRANSFORM( SAVESCREEN(nShadTop,  nShadLeft , nShadBottom,  nShadRight),;
      REPLICATE("X", nShadBottom - nShadTop + 1 ) ) )

   SET(_SET_DEVICE,cDev)

RETURN

*-----------------------------------------------------------------------------
FUNCTION fReset(aArr,nVal)

   LOCAL n

   FOR n := 1 TO LEN(aArr)
      IF aArr[n,1] != " "
         IF ASC(aArr[n,1]) > nVal
            aArr[n,1] := CHR(ASC(aArr[n,1]) - 1)
         ENDIF
      ENDIF
   NEXT

RETURN NIL

/******************************************************************************/
FUNCTION sm3fpib(cVaar,cMoer)

   // Calculate inbreeding coefficient for future progeny
   // Return the percentage inbreeding

   // Declare
   LOCAL nRet    := 0
   LOCAL i       := 0
   LOCAL cPaSire := ""
   LOCAL cPaDam  := ""
   LOCAL cMaSire := ""
   LOCAL cMaDam  := ""
   LOCAL aMatrix
   LOCAL aCdbf   := fATopen()
   LOCAL aDiere  := {}
   LOCAL nDiere  := 0
   LOCAL nSire   := 0
   LOCAL nDam    := 0
   LOCAL nRow    := 0
   LOCAL nCol    := 0

   BEGIN SEQUENCE

      IF EMPTY(cVaar) .OR. EMPTY(cMoer)
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      DBSELECTAREA("SM3DATA")
      ORDSETFOCUS(1)

      // add future progeny to array
      AADD(aDiere,{;
         "Future Prog.",;                        // Id number of animal
         PADR(ALLTRIM(cVaar),12," "),;           // Id number of sire
         PADR(ALLTRIM(cMoer),12," "),;           // Id number of dam
         DTOS(DATE() + 274),;                    // Today + normal pregnancy length
         0,;                                     // Inbreeding coefficient
         0,;                                     // Position of Sire in matrix
         0;                                      // Position of dam in matrix
         })

      // add Sire to array
      IF ! SM3DATA->(DBSEEK(cVaar)) .OR. EMPTY(SM3DATA->gebdatum)
         BREAK
      ENDIF

      AADD(aDiere,{;
         PADR(ALLTRIM(cVaar),12," "),;
         PADR(ALLTRIM(SM3DATA->idvaar),12," "),;
         PADR(ALLTRIM(SM3DATA->idmoer),12," "),;
         DTOS(SM3DATA->gebdatum),;
         SM3DATA->ibcoef / 100,;
         0,;
         0;
         })

      // add Dam to array
      IF ! SM3DATA->(DBSEEK(cMoer)) .OR. EMPTY(SM3DATA->gebdatum)
         BREAK
      ENDIF

      AADD(aDiere,{;
         PADR(ALLTRIM(cMoer),12," "),;
         PADR(ALLTRIM(SM3DATA->idvaar),12," "),;
         PADR(ALLTRIM(SM3DATA->idmoer),12," "),;
         DTOS(SM3DATA->gebdatum),;
         SM3DATA->ibcoef / 100,;
         0,;
         0;
         })

      // Add paternal and maternal parents
      FOR i := 2 TO LEN(aDiere)

         // add a sire
         IF ! EMPTY(aDiere[i,ADVAAR])
            cPaSire := aDiere[i,ADVAAR]

            IF ASCAN(aDiere,{ |aVal| aVal[ADIDNR] == cPaSire}) = 0
               IF SM3DATA->(DBSEEK(cPaSire)) .AND. ! EMPTY(SM3DATA->gebdatum)
                  AADD(aDiere,{;
                     PADR(ALLTRIM(cPaSire),12," "),;
                     PADR(ALLTRIM(SM3DATA->idvaar),12," "),;
                     PADR(ALLTRIM(SM3DATA->idmoer),12," "),;
                     DTOS(SM3DATA->gebdatum),;
                     SM3DATA->ibcoef / 100,;
                     0,;
                     0;
                     })
               ENDIF
            ENDIF
         ENDIF

         // add a dam
         IF ! EMPTY(aDiere[i,ADMOER])
            cPaDam := aDiere[i,ADMOER]

            IF ASCAN(aDiere,{ |aVal| aVal[ADIDNR] == cPaDam}) = 0
               IF SM3DATA->(DBSEEK(cPaDam)) .AND. ! EMPTY(SM3DATA->gebdatum)
                  AADD(aDiere,{;
                     PADR(ALLTRIM(cPaDam),12," "),;
                     PADR(ALLTRIM(SM3DATA->idvaar),12," "),;
                     PADR(ALLTRIM(SM3DATA->idmoer),12," "),;
                     DTOS(SM3DATA->gebdatum),;
                     SM3DATA->ibcoef / 100,;
                     0,;
                     0;
                     })
               ENDIF
            ENDIF
         ENDIF
      NEXT

      // Sort animals on birth date (oldest first)
      ASORT(aDiere,,, { |x,y| x[ADGEBR] < y[ADGEBR] })

      // Determine and set array (matrix) positions of parents
      FOR i := 1 TO LEN(aDiere)
         IF ! EMPTY(aDiere[i,ADVAAR])
            cPaSire := aDiere[i,ADVAAR]
            aDiere[i,ADSIRE] := ASCAN(aDiere,{ |aVal| aVal[ADIDNR] == cPaSire})
         ENDIF

         IF ! EMPTY(aDiere[i,ADMOER])
            cPaSire := aDiere[i,ADMOER]
            aDiere[i,ADDAM] := ASCAN(aDiere,{ |aVal| aVal[ADIDNR] == cPaSire})
         ENDIF
      NEXT

      // Create Matrix
      nDiere := LEN(aDiere)
      aMatrix := ARRAY(nDiere,nDiere)

      FOR i := 1 TO nDiere
         AFILL(aMatrix[i],0)
      NEXT

      // Set Diagonal values (1 + inbreeding coefficient)
      FOR i := 1 TO nDiere
         aMatrix[i,i] := 1 + aDiere[i,ADINTK]
      NEXT

      // Set Additive relationship values for parents of future progeny
      FOR i := 1 TO nDiere
         nSire := aDiere[i,ADSIRE]
         nDam  := aDiere[i,ADDAM]

         IF nSire != 0 .AND. nDam != 0
            IF aDiere[nSire,ADSIRE] != 0 .AND. aDiere[nSire,ADDAM] != 0
               aMatrix[aDiere[nSire,ADSIRE],aDiere[nSire,ADDAM]] := aDiere[nSire,ADINTK] * 2
               aMatrix[aDiere[nSire,ADDAM],aDiere[nSire,ADSIRE]] := aDiere[nSire,ADINTK] * 2
            ENDIF

            IF aDiere[nDam,ADSIRE] != 0 .AND. aDiere[nDam,ADDAM] != 0
               aMatrix[aDiere[nDam,ADSIRE],aDiere[nDam,ADDAM]] := aDiere[nDam,ADINTK] * 2
               aMatrix[aDiere[nDam,ADDAM],aDiere[nDam,ADSIRE]] := aDiere[nDam,ADINTK] * 2
            ENDIF
         ENDIF
      NEXT

      // Calculate rest of the off-diagonal values (additive relationships)
      For nRow := 1 TO nDiere
         FOR nCol := (nRow + 1) TO nDiere
            IF aMatrix[nRow,nCol] = 0
               nSire := 0
               nDam  := 0

               IF aDiere[nCol,ADSIRE] != 0
                  nSire := aMatrix[nRow,aDiere[nCol,ADSIRE]]
               ENDIF

               IF aDiere[nCol,ADDAM] != 0
                  nDam := aMatrix[nRow,aDiere[nCol,ADDAM]]
               ENDIF

               aMatrix[nRow,nCol] := (nSire + nDam) / 2
            ENDIF
         NEXT

         // Transfer top part of matrix to bottom
         FOR i := (nRow + 1) TO nDiere
            aMatrix[i,nRow] := aMatrix[nRow,i]
         NEXT

      NEXT

      // Calculate inbreeding percentage for the future progeny
      nRet := (aMatrix[aDiere[nDiere,ADSIRE],aDiere[nDiere,ADDAM]] / 2) * 100

   END

   // Reset
   fATclose(aCdbf)

RETURN nRet

/******************************************************************************/
FUNCTION fPedi(cId)

   // 02-02-14 08:46
   // Function to lookup extended pedigree and fill array with animals

   // Declare
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aPedi := {}
   local i     := 0

   begin sequence

      // Build array
      for i = 1 to 15
         aadd(aPedi,{"","","",""})
      next

      // Open the main data file
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Animal itself
      aPedi[1][1] := cId

      for i = 1 to 15
         if empty(aPedi[i][1])
            // Do not seek
         else
            seek aPedi[i][1]
            if found()
               aPedi[i][2] := SM3DATA->kalfbnr
               aPedi[i][3] := SM3DATA->reknr
               do case
                  case i==1
                     aPedi[i+1][1] := SM3DATA->idvaar
                     aPedi[i+2][1] := SM3DATA->idmoer
                     aPedi[i+1][4] := "2"
                     aPedi[i+2][4] := "1"
                  case i==2
                     aPedi[i+2][1] := SM3DATA->idvaar
                     aPedi[i+3][1] := SM3DATA->idmoer
                     aPedi[i+2][4] := "2"
                     aPedi[i+3][4] := "1"
                  case i==3
                     aPedi[i+3][1] := SM3DATA->idvaar
                     aPedi[i+4][1] := SM3DATA->idmoer
                     aPedi[i+3][4] := "2"
                     aPedi[i+4][4] := "1"
                  case i==4
                     aPedi[i+4][1] := SM3DATA->idvaar
                     aPedi[i+5][1] := SM3DATA->idmoer
                     aPedi[i+4][4] := "2"
                     aPedi[i+5][4] := "1"
                  case i==5
                     aPedi[i+5][1] := SM3DATA->idvaar
                     aPedi[i+6][1] := SM3DATA->idmoer
                     aPedi[i+5][4] := "2"
                     aPedi[i+6][4] := "1"
                  case i==6
                     aPedi[i+6][1] := SM3DATA->idvaar
                     aPedi[i+7][1] := SM3DATA->idmoer
                     aPedi[i+6][4] := "2"
                     aPedi[i+7][4] := "1"
                  case i==7
                     aPedi[i+7][1] := SM3DATA->idvaar
                     aPedi[i+8][1] := SM3DATA->idmoer
                     aPedi[i+7][4] := "2"
                     aPedi[i+8][4] := "1"
               endcase
            else
               // Animal unknown
            endif
         endi
      next

   end

   // Restore
   fATclose(aCdbf)
   fARestScr(aCscr)

return aPedi

/******************************************************************************/
FUNCTION fProg(cId)

   // 02-02-14 08:46
   // Function to lookup extended progeny and fill array with animals

   // Declare
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aProg := {}
   local i     := 0

   begin sequence

      // Open the main data file
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Locate the animal itself
      seek cId
      if eof()
         break
      endif

      // Animal was found
      if SM3DATA->geslag == "2"
         // Animal is male
         set order to 5
         seek cId
         do while SM3DATA->idvaar == cId
            aadd(aProg,SM3DATA->idnr)
            skip
         enddo
      else
         // Animal is female
         set order to 4
         seek cId
         do while SM3DATA->idmoer == cId
            aadd(aProg,SM3DATA->idnr)
            skip
         enddo
      endif

   end

   // Restore
   fATclose(aCdbf)
   fARestScr(aCscr)

return aProg
