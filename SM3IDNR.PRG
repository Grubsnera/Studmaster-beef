//SM3IDNR.PRG
//Program om 'n dier se nommer te vra
//Kopiereg (c) 1992 A van Rensburg
//07:52 13 Jan,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/****************************************************************************/
FUNCTION sm3idnr( cIdnr, nLine, nColu, cBood, cMess, cWind, lTipe, lUp )

   //cIdnr = Id nommer
   //nLine = Lyn waar vertoon
   //nColu = Kolom waar vertoon moet word
   //cBood = Boodskap voor die get
   //cMess = Boodskap aan onderkant vd skerm
   //cWind = Boodskap bo-aan die venster
   //lTipe = Moet program vra of bewaar of nie
   //lUp   = Moet oppyl toegelaat word

   //Verklaar
   local getlist := {}
   local lLoop := TRUE
   local cCurCol := setcolor()
   local cCurScr := ""
   local nCh := 1

   //Waardes
   cIdnr := if( cIdnr==NIL, space(12), cIdnr )
   nline := if( nLine==NIL, 12, nLine )
   nColu := if( nLine==NIL,  5, nColu )
   if cLanType() == "A"
      cBood := if( cBood==NIL, padl("ID nommer",20), padl(cBood,20) )
      cMess := if( cMess==NIL, "Tik die ID nommer van die dier en druk "+D_ENTER, cMess )
      cWind := if( cWind==NIL, "ID NOMMER", upper(cWind) )
   else
      cBood := if( cBood==NIL, padl("ID number",20), padl(cBood,20) )
      cMess := if( cMess==NIL, "Type the ID number of the animal and press "+D_ENTER, cMess )
      cWind := if( cWind==NIL, "ID NUMBER", upper(cWind) )
   endif
   lTipe := if( lTipe==NIL, FALSE, lTipe )
   lUp   := if( lUp  ==NIL, FALSE, lUp   )
   //set function 8 to trim(substr(cTotNaam(),125,4))
   //set function 7 to trim(substr(cTotNaam(),129,20)) + " "

   //Loop
   lLoop := TRUE
   do while lLoop

      //Teken get boodskap
      if cLanType() == "A"
         fScrBood(23,"[PgDn]=Volgende dier  [PgUp]=Vorige dier  [Esc]=Menu")
      else
         fScrBood(23,"[PgDn]=Next animal  [PgUp]=Previous animal   [Esc]=Menu")
      endif
      fScrBood(24,cMess)
      setcolor( cColNorm() )
      @ nLine, nColu say cBood

      //Vra die nommer
      @ nLine, nColu+21 get cIdnr pict "@!"
      readexit(lUp)
      set confirm off
      set cursor on
      read
      set cursor off
      set confirm on
      readexit(FALSE)

      //Indien Esc gedruk is
      if lastkey() = K_ESC
         cIdnr = "CANCELLED   "
         setcolor( cCurCol )
         RETURN cIdnr
      endi

      //Indien uparrow gedruk was
      if lastkey() == K_UP
         cIdnr = "UPARROW     "
         setcolor( cCurCol )
         RETURN cIdnr
      endif

      //Indien PgUp gedruk is
      if lastkey() = K_PGUP
         skip -1
         if bof()
            if cLanType() == "A"
               fScrBood(24,"Hierdie is die heel eerste dier!")
            else
               fScrBood(24,"This is the very first animal!")
            endif
            inkey(.5)
         endi
         cIdnr = SM3DATA->idnr
         loop
      endi

      // Indien PgDn gedruk is
      if lastkey() = K_PGDN
         skip
         if eof()
            if cLanType() == "A"
               fScrBood(24,"Hierdie is die laaste dier!")
            else
               fScrBood(24,"This is the last animal!")
            endif
            inkey(.5)
            go bottom
         endi
         cIdnr := SM3DATA->idnr
         loop
      endi

      //Indien al die velde null is
      if cIdnr == space(12)
         cIdnr = "NOTHING     "
         setcolor( cCurCol )
         RETURN cIdnr
      endi

      // Soek die diernommer
      seek cIdnr

      //Indien einde van leer en bewaar is TRUE
      if eof() .and. lTipe
         //Stoor huidige skerm
         cCurScr := savescreen( 0, 0, maxrow(), maxcol() )
         //Vertoon menu
         // Vertoon hulpskerm
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die ID nommer." )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the ID number.")
         endif
         // Kry opsienommer
         nCh := fNewMenu( 1, "SM3IDNR" )
         restscreen( 0, 0, maxrow(), maxcol(), cCurScr )
         do case
            case nCh == 1
               //Bewaar
               lLoop := FALSE
               loop
            case nCh == 3
               //Vind (Id Nommer)
            case nCh == 4
               //Vind (Micro skyfie)
               cIdnr := sm3chip()
               IF ! EMPTY(cIdnr) .AND. ALLTRIM(cIdnr) != "CAN"
                  //Vertoon die gekose nommer
                  setcolor( cColInve() )
                  @ nLine, nColu+21 say cIdnr
                  setcolor( cColNorm() )
               ENDIF

               exit
            otherwise
               //Return to ID nommer
               loop
         endcase
      endif

      //Indien nie gevind - vertoon venster
      if eof()

         //Bepaal die volgorde van vertoon
         set soft on
         seek cIdnr
         set soft off

         //Indien nog steeds nie gevind
         if eof()
            go top
         endi

         //Stoor besonderhede - vertoon venster
         cIdnr := sm3wiid( cWind )

         //Indien laaste sleutel = Escape
         if lastkey() = K_ESC
            //Indien Esc gedruk
            loop
         endi

      endif

      cIdnr := SM3DATA->idnr

      //Vertoon die gekose nommer
      setcolor( cColInve() )
      @ nLine, nColu+21 say cIdnr
      setcolor( cColNorm() )
      lLoop := FALSE

   enddo

   setcolor( cCurCol )

RETURN cIdnr

/****************************************************************************/
FUNCTION sm3wiid( cBood )

   //Funksie om skerm te vertoon met Id nommers

   //Verklaar
   LOCAL cCurScr := fCurScreen()                 //Huidige skerm besonderhede
   LOCAL cCurSke := savescreen( 0, 0, maxrow(), maxcol() )
   LOCAL nBoxCoo := 0                            //Waarde van venster
   LOCAL cBrowse
   LOCAL aColumn := {}
   LOCAL i       := 1
   LOCAL lMore   := TRUE
   LOCAL nKey    := 1
   local cData   := space(12)

   //Vertoon die data
   if cLanType() == "A"
      fScrBood( 23, "[PgDn]=Nog Diere  [PgUp]=Nog Diere" )
      fScrBood( 24, "Kies dier met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER )
   else
      fScrBood( 23, "[PgDn]=More animals   [PgUp]=More Animals")
      fScrBood( 24, "Choose animal with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER )
   endif
   fBox( 3, 57, maxrow()-4, maxcol()-2, cBood, cColMenu() )
   setcolor( cColMenu() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( 4, 59, maxrow()-5, maxcol()-4 )

   //Definieer kolomme
   aadd( aColumn, TBColumnNew( , {|| SM3DATA->idnr } ) )
   aadd( aColumn, TBColumnNew( , {|| SM3DATA->geslag } ) )
   aadd( aColumn, TBColumnNew( , {|| SM3DATA->uitkrede } ) )

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   // Main loop
   lMore := TRUE
   do while lMore

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
         lMore := FALSE

      elseif nKey == K_ENTER
         // Enter means leave and update drive variable
         cData := SM3DATA->idnr
         lMore := FALSE

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   fSetScreen( cCurScr )
   restscreen( 0, 0, maxrow(), maxcol(), cCurSke )

return cData

*-----------------------------------------------------------------------------
STATIC FUNCTION sm3chip

   LOCAL cCurScr := fCurScreen()                 //Huidige skerm besonderhede
   LOCAL cCurSke := savescreen( 0, 0, maxrow(), maxcol() )
   LOCAL aCdbf   := fATOpen()
   LOCAL cIdnr   := "CAN"
   LOCAL nChr, nChar, cBuffer, nPos
   LOCAL nPort := nScPort()

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   fScrBood(MAXROW()-1)
   fScrBood(MAXROW())

   IF ! COM_OPEN(nPort)
      fScrWait(MAXROW(),"Unable to Open Comms Port "+ALLTRIM(STR(nPort,1,0))+" ...")
      fSetScreen( cCurScr )
      restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
      fATClose(aCdbf)
      RETU "CAN"
   ENDIF

   COM_HARD(nPort,TRUE)

   IF ! COM_INIT(nPort, nScBaud(), cScPari(), nScBits(), nScStop() )
      fScrWait(MAXROW(),"Unable to Initialize Comms Port "+ALLTRIM(STR(nPort,1,0))+" ...")
      COM_CLOSE(nPort)
      fSetScreen( cCurScr )
      restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
      fATClose(aCdbf)
      RETU "CAN"
   ENDIF

   fScrBood(MAXROW(),"Comms Port "+ALLTRIM(STR(nPort,1,0))+" Opened and Initialized")
   IF ! COM_FLUSH(nPort)
      fScrWait(MAXROW(),"Unable to Flush the Input Buffer...")
      COM_CLOSE(nPort)
      fSetScreen( cCurScr )
      restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
      fATClose(aCdbf)
      RETU "CAN"
   ENDIF

   fScrBood(MAXROW()-1)
   fScrBood(MAXROW(),"Waiting for Data from Micro-chip System...")

   DO WHILE TRUE

      cBuffer := ""
      nChar := 0

      DO WHILE TRUE
         nChr := INKEY(0.1)
         IF nChr == K_ESC
            EXIT
         ENDIF
         nChar := COM_COUNT(nPort)
         IF nChar >= 42
            EXIT
         ENDIF
      ENDDO

      IF nChr == K_ESC
         EXIT
      ENDIF

      fScrBood(MAXROW()-1)
      fScrBood(MAXROW(),"Reading Data from Micro-chip System...")
      cBuffer := COM_READ(nPort,42)              // Read first 14 characters from the Buffer
      nPos := AT("#",cBuffer)

      IF nPos = 0
         IF ! COM_FLUSH(nPort)
            fScrWait(MAXROW(),"Unable to Flush the Input Buffer...")
            COM_CLOSE(nPort)
            fSetScreen( cCurScr )
            restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
            fATClose(aCdbf)
            RETU "CAN"
         ENDIF

         LOOP
      ENDIF

      cBuffer := SUBSTR(cBuffer,nPos+1,16)

      IF ! CheckSum(cBuffer)
         IF ! COM_FLUSH(nPort)
            fScrWait(MAXROW(),"Unable to Flush the Input Buffer...")
            COM_CLOSE(nPort)
            fSetScreen( cCurScr )
            restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
            fATClose(aCdbf)
            RETU "CAN"
         ENDIF

         LOOP
      ENDIF

      EXIT
   ENDDO

   COM_CLOSE(nPort)

   IF ! EMPTY(cBuffer)
      cBuffer := PADR(cBuffer,12," ")
      DBSELECTAREA("SM3DATA")
      ORDSETFOCUS(13)

      IF ! SM3DATA->(DBSEEK(cBuffer))
         fScrWait(MAXROW(),"Unable to locate a animal with number : "+ALLTRIM(cBuffer))
         fSetScreen( cCurScr )
         restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
         fATClose(aCdbf)
         RETU "CAN"
      ENDIF

      cIdnr := SM3DATA->idnr
   ENDIF

   //Herstel
   fSetScreen( cCurScr )
   restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
   fATClose(aCdbf)

return cIdnr

*------------------------------------------------------------------------------
STATIC FUNCTION CheckSum (cBuf)

   LOCAL n, cChkSum
   LOCAL lReturn := TRUE
   LOCAL nChkSum := 0

   FOR n := 1 TO 15
      nChkSum += VAL(SUBSTR(cBuf,n,1))
   NEXT

   cChkSum := ALLTRIM(STR(nChkSum))

   IF RIGHT(cChkSum,1) != SUBSTR(cBuf,16,1)
      lReturn := FALSE
   ENDIF

RETURN lReturn


