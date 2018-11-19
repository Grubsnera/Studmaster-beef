//SM3AUCT.PRG
//Program om veilingskatalogus te beheer
//Kopiereg (c) 1993 A van Rensburg
//20:20 22 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/****************************************************************************/
FUNCTION sm3auct( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local aCdbf := fATOpen()
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local nKeyp := 0
   local nCurr := 0
   local nReko := 0
   local cHead := ""
   local getlist := {}

   private cData := ""

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,21, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3auct","auctdate" })
      aadd(aSend,{"sm3auct","auctdesc" })
      aadd(aSend,{"sm3auct","auctnumb" })
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Vra een of groep diere
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
   endif

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif

   aCdbf := fATOpen(aCdbf,cDd(),"SM3VEIL",,,,FALSE)

   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      RETU NIL
   ENDIF

   aCdbf := fATOpen(aCdbf,cDd(),"SM3AUCT",,,,FALSE)

   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      RETU NIL
   ENDIF

   // Activate catalogue data file
   select SM3AUCT
   ordsetfocus(1)
   go top

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Skerm
   //Teken die box
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
      fBox( nTop, nLeft, nBott, nRigh, "VEILINGSKATALOGUS" )
   else
      fScrOpsk( ,"Option "+cOption())
      fBox( nTop, nLeft, nBott, nRigh, "AUCTION CATALOGUE" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   // Freeze
   bBrow:freeze := 3

   // Main loop
   do while TRUE

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [ 0-9 ]=Vind                  " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt-E]=Verander  [Alt-P]=Druk" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [ 0-9 ]=Find               " )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt-E]=Edit  [Alt-P]=Print" )
      endif

      FullStabilize(bBrow)
      // Stabilize the display until it's stable or a key is pressed

      if bBrow:stable
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         EXIT

      elseif nKeyp == K_ENTER
         //Enter means return kode
         if LASTREC() != 0
            SM3VEIL( ,,,,SM3AUCT->auctnumb )
            EXIT
         endif

         bBrow:refreshall()

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         nCurr := RECNO()
         IF fAddPerf()
            nCurr := RECNO()
            bBrow:refreshall()
         ELSE
            GOTO(nCurr)
         ENDIF

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         nCurr := RECNO()
         if fAddPerf(nCurr)
            GOTO(nCurr)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete()
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         if fPrint()
            bBrow:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fATClose(aCdbf)

return NIL

//*************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local cData := ""
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cData := upper(chr(nKeyp)) + space(aRecv[1][4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[1][6] get cData pict aRecv[1][10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cData == space(aRecv[1][4])
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   locate for SM3AUCT->auctdate == CTOD(cData)

   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/******************************************************************************/
STATIC FUNCTION fAddPerf(nReko,aOpsk)

   // Declare
   LOCAL getList := {}
   LOCAL lRetu := FALSE
   LOCAL aCscr := fASaveScr()
   LOCAL aCdbf := fATopen()
   LOCAL aVeld := {}
   LOCAL nLine := 0
   LOCAL nBoxc := 0
   LOCAL lLoop := TRUE
   LOCAL lClea := TRUE
   LOCAL lRepe := FALSE
   LOCAL i     := 0
   LOCAL nAuct := 0
   LOCAL nPrev := 0
   LOCAL cMess := ""
   BEGIN SEQUENCE

      // Values
      nReko := IIF(EMPTY(nReko),0,nReko)
      nPrev := nReko

      // Get the fields
      IF EMPTY(aOpsk)
         ASIZE(aVeld,0)
         aadd(aVeld,{"sm3auct","auctdate" })
         aadd(aVeld,{"sm3auct","auctdesc" })
         aOpsk := fGetField(aVeld)
      ENDIF

      // Screen
      nLine := MAXROW()/2-int(LEN(aOpsk)/2)-1
      IF nReko == 0
         IF cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),LEN(aOpsk),"BEWAAR VEILING-INLIGTING" )
         ELSE
            nBoxc := fBoxCent(nLine,space(60),LEN(aOpsk),"ENTER AUCTION DATA" )
         ENDIF
      ELSE
         IF cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),LEN(aOpsk),"VERANDER VEILING-INLIGTING" )
         ELSE
            nBoxc := fBoxCent(nLine,space(60),LEN(aOpsk),"EDIT AUCTION DATA" )
         ENDIF
      ENDIF

      fAddMess()

      // The get
      lLoop := TRUE
      DO WHILE lLoop

         IF lClea
            // Get the current values
            IF nReko == 0
               // Insert a new record
               IF lRepe
                  lRepe := FALSE
                  aOpsk := fFillBlank(aOpsk)
               ELSE
                  aOpsk := fFillBlank(aOpsk)
               ENDIF

            ELSE
               // Edit a record by filling the array with current values
               FOR i := 1 TO LEN(aOpsk)
                  SELECT SELECT(strtran(aOpsk[i,DBF_NAME],"->",""))
                  aOpsk[i,FLD_CARG] := FIELDGET(aOpsk[i,FLD_NUMB])
               NEXT
            ENDIF
         ELSE
            // Clear the get array
            lClea := TRUE
         ENDIF

         // Vertoon en get velde
         @nLine+1-1,nBoxc SAY aOpsk[1,FLD_DESC] GET aOpsk[1,FLD_CARG] PICT aOpsk[1,FLD_PICT] valid(fVdate(aOpsk,getlist))
         @nLine+2-1,nBoxc SAY aOpsk[2,FLD_DESC] GET aOpsk[2,FLD_CARG] PICT aOpsk[2,FLD_PICT]

         // The get
         SET(_SET_CURSOR,1)
         READ
         SET(_SET_CURSOR,0)

         // The actions
         IF LASTKEY() == K_ENTER
            // Add or edit record
            IF nReko == 0
               // Add
               IF LASTREC() = 0
                  nAuct := 1
               ELSE
                  ORDSETFOCUS(2)
                  DBGOTOP()
                  nAuct := SM3AUCT->auctnumb + 1
                  ORDSETFOCUS(1)
               ENDIF

               DBAPPEND()
            ELSE
               // Edit
               DO WHILE ! RLOCK() ; ENDDO
               ENDIF

               // Save the entry
               lRetu := TRUE
               FOR i := 1 TO LEN(aOpsk)
                  FIELDPUT(aOpsk[i,FLD_NUMB],aOpsk[i,FLD_CARG])
               NEXT

               IF nReko == 0
                  SM3AUCT->auctnumb := nAuct
               ENDIF

               DBUNLOCK()
               DBCOMMIT()

               // Store the current record number
               nPrev := RECNO()

               // Next new record
               IF nReko == 0
                  // Repeat the previous data
                  lRepe := TRUE
                  LOOP
               ENDIF
            ELSE
               // Activate the correct previous record
               IF ! EMPTY(nPrev)
                  GOTO(nPrev)
               ENDIF

               // Escaped
               IF UPDATED()
                  // Warn that data will be lost
                  IF cLanType() == "A"
                     cMess := "Kan veranderings verlore gaan?"
                  ELSE
                     cMess := "Ok to lose changes?"
                  ENDIF

                  IF ! fJaNee(MAXROW(),cMess)
                     lClea := FALSE
                     LOOP
                  ENDIF
               ENDIF
            ENDIF

            lLoop := FALSE
         ENDDO
      END

      // Reset
      fARestScr(aCscr)

      RETURN lRetu

/******************************************************************************/
      STATIC FUNCTION fAddMess

         // Function to paint the get message

         // The print
         IF cLanType() == "A"
            fScrBood(MAXROW()-1,"[Esc]=Menu")
            fScrBood(MAXROW()  ,"Tik die besonderhede van die VEILING!")
         ELSE
            fScrBood(MAXROW()-1,"[Esc]=Menu")
            fScrBood(MAXROW()  ,"Type the particulars of the AUCTION!")
         ENDIF

         RETURN TRUE

/******************************************************************************/
         STATIC FUNCTION fDelete

            // Function to delete records

            // Declare
            LOCAL aCscr := fASaveScr(MAXROW()-1,0,MAXROW(),MAXCOL())
            LOCAL lRetu := FALSE
            LOCAL cBood := ""

            // Screen
            IF cLanType() == "A"
               cBood := "Moet bogenoemde VEILINGS-INLIGTING geskrap word?"
               fScrBood(MAXROW()-1,DTOC(SM3AUCT->auctdate)+" - "+ALLTRIM(SM3AUCT->auctdesc))
            ELSE
               cBood := "Should above-mentioned AUCTION INFORMATION be deleted?"
               fScrBood(MAXROW()-1,DTOC(SM3AUCT->auctdate)+" - "+ALLTRIM(SM3AUCT->auctdesc))
            ENDIF

            IF fJaNee(MAXROW(),cBood,,FALSE )
               fScrBood(MAXROW()-1)
               if cLanType() == "A"
                  fScrWBood(MAXROW(),"Die veiling word geskrap word !")
               else
                  fScrWBood(MAXROW(),"The auction being deleted !")
               endif

               DBSELECTAREA("SM3VEIL")
               ORDSETFOCUS(1)

               DO WHILE SM3VEIL->(DBSEEK(PADL(ALLTRIM(STR(SM3AUCT->auctnumb,5,0)),5,"0")))
                  DO WHILE ! RLOCK() ; ENDDO
                     DBDELETE()
                  ENDDO

                  PACK
                  DBCOMMIT()
                  DBSELECTAREA("SM3AUCT")
                  DO WHILE ! RLOCK() ; ENDDO
                     DBDELETE()
                     PACK
                     DBCOMMIT()

//***** The following code delete old SM3VEIL records that are not attached to
//***** a Header record... in other words they are without a auction number...
		DBSELECTAREA("SM3VEIL")
		DBGOTOP()

		DO WHILE ! EOF()
			IF EMPTY(SM3VEIL->auctnumb)
				DBDELETE()
			ENDIF

			DBSKIP()
		ENDDO
		PACK
		DBCOMMIT()
		DBSELECTAREA("SM3AUCT")
//****************************************************************************

		DBGOTOP()
		lRetu := TRUE
   ENDIF

   // Reset
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
                     STATIC FUNCTION fVdate(aRecv,aGets)

                        // Function to validate date entry

                        // Declare
                        local lRetu := TRUE
                        local aCscr := fASaveScr(maxrow()-1,1,maxrow(),maxcol())
                        local nDate := fEnum(aRecv,"auctdate")

                        // Validation
                        if empty(aGets[nDate]:varget())
                           lRetu := FALSE
                           fScrBood(maxrow()-1)
                           if cLanType() == "A"
                              fScrWait(maxrow(),"Veilingsdatum is verpligtend")
                           else
                              fScrWait(maxrow(),"Date of auction is compulsory")
                           endif
                        endif

                        // Reset
                        fARestScr(aCscr)

                        return lRetu

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
                              retu FALSE
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
                           aadd( aVelde, { "sm3auct", "auctnumb" } )
                           aadd( aVelde, { "sm3auct", "auctdate" } )
                           aadd( aVelde, { "sm3auct", "auctdesc" } )
                           aDbfOp := fGetField( aVelde )

                           //Open die databasisse
                           cSelg := fTOpen( cDd(), "sm3auct", , "dbf", "sm3auct", .t., .f. )
                           if left( cSelg, 1 ) == "f"
                              retu FALSE
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
                              fScrbood(24,"Veilings word gedruk!  [Esc]=Stop drukker.")
                              cHdln := "VEILINGS."
                           else
                              fScrbood(24,"Auction being printed!  [Esc]=Stop printer.")
                              cHdln := "AUCTIONS."
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
                                 retu FALSE
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

                           return TRUE

