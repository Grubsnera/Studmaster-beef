// Application: StudMaster for Beef Cattle
//   File Name: SM3INVE.PRG
// Description: Program to run Libra scales and Inventaurus
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Sarel Cloete
//  Created on: 21-05-97 08:00am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3Inve

	// Declare
	local aCscr    := fASaveScr()
	local aCdbf    := fATopen()
	local nBoxc    := 1
	local nChoi    := 1
	local dDate    := date()
	local cIdnr    := ""
	local nWeight  := 0
	local cBood1   := ""
	local cBood2   := ""
	Local cBood01  := IIF(cLanType()="A","Serie Kommunikasie Poort Nommer vir Bolus Skandeerder : " , "Serial Communication Port Number for Bolus Scanner : " )
	Local cBood02  := IIF(cLanType()="A","      Serie Kommunikasie Poort Nommer vir Libra Skaal : " , "  Serial Communication Port Number for Libra Scale : " )
	Local cBood03  := IIF(cLanType()="A","Serie Kommunikasie" , "Serial Communication" )
	Local cError01 := IIF(cLanType()="A","Die Skandeerder en die Skaal kan nie op dieselfde poort wees nie" , "The Scanner and the Scale cannot be on the same Port" )
	local lNewRec  := TRUE
	LOCAL nPScanr  := 0
	LOCAL nPScale  := 0
	local getlist  := {}

	begin sequence

    	// Screen
  		if cLanType() == "A"
	    	fScrOpsk( ,"Opsie "+cOption())
		else
			fScrOpsk( ,"Option "+cOption())
		endif

    	// Open database files
    	aCdbf := fATOpen(aCdbf,cDd(),"SM3DATA")
    	if !aCdbf[len(aCdbf),1]
        	break
    	endif

    	aCdbf := fATOpen(aCdbf,cDd(),"SM3WEEG")
    	if !aCdbf[len(aCdbf),1]
        	break
    	endif

       	nBoxc := fBoxCent(10,"1234567890123456789012345678901234567890123456789012345678",4,cBood03)

		DO WHILE TRUE
			@ 11,nBoxc SAY cBood01 GET nPScanr PICT "9" VALID(nPScanr > 0 .AND. nPScanr < 5)
			@ 12,nBoxc SAY cBood02 GET nPScale PICT "9" VALID(nPScale > 0 .AND. nPScale < 5)
    		setcursor(1)
    		read
    		setcursor(0)

			IF LASTKEY() == K_ESC
				BREAK
			ENDIF

			IF nPScanr = nPScale
				fScrWait(MAXROW()-1,cError01)
				LOOP
			ENDIF

			EXIT
		ENDDO

		@ 10,00 CLEAR TO 14,MAXCOL()
		IF ! COM_OPEN(nPScanr)
    		if cLanType() == "A"
            fScrWait(MAXROW(),"Kan nie kommunikasiepoort "+ALLTRIM(STR(nPScanr,1,0))+" oopmaak nie")
			else
				fScrWait(MAXROW(),"Unable to Open Comms Port "+ALLTRIM(STR(nPScanr,1,0)))
			endif
			break
		ENDIF

		COM_HARD(nPScanr,TRUE)

		IF ! COM_INIT(nPScanr, nScBaud(), cScPari(), nScBits(), nScStop() )
    		if cLanType() == "A"
            fScrWait(MAXROW(),"Kan nie kommunikasiepoort "+ALLTRIM(STR(nPScanr,1,0))+" aanvoor nie")
			else
				fScrWait(MAXROW(),"Unable to Initialize Comms Port "+ALLTRIM(STR(nPScanr,1,0)))
			endif
			break
		ENDIF

		IF ! COM_OPEN(nPScale)
    		if cLanType() == "A"
            fScrWait(MAXROW(),"Kan nie kommunikasiepoort "+ALLTRIM(STR(nPScale,1,0))+" oopmaak nie")
			else
				fScrWait(MAXROW(),"Unable to  Open Comms Port "+ALLTRIM(STR(nPScale,1,0))+" ...")
			endif
			break
		ENDIF

		IF ! COM_INIT(nPScale, 19200, "N", 8, 1)
    		if cLanType() == "A"
            fScrWait(MAXROW(),"Kan nie kommunikasiepoort "+ALLTRIM(STR(nPScale,1,0))+" aanvoor nie")
			else
				fScrWait(MAXROW(),"Unable to Initialize Comms Port "+ALLTRIM(STR(nPScale,1,0))+" ...")
			endif
			break
		ENDIF

		COM_HARD(nPScale,TRUE)
		COM_DTR(nPScale,TRUE)

    	// Ask the weighing date
    	if cLanType() == "A"
			cBood1 := "Aanvaar die dier se gewig"
			cBood2 := "Volgende dier is gereed om ge-identifiseer en geweeg te word"
	    	fScrOpsk( ,"Opsie "+cOption())
        	fScrBood(maxrow()-1,"[Esc]=Menu")
        	fScrBood(maxrow()  ,"Tik die datum waarop die diere geweeg word...")
        	nBoxc := fBoxCent(11,"Weeg Datum? xx/xx/xx",3,"Weeg Datum")
        	@12,nBoxc say "Weeg Datum?" get dDate
    	else
			cBood1 := "Accept the animals weight"
			cBood2 := "Next animal is ready to be identified and weighed"
			fScrOpsk( ,"Option "+cOption())
        	fScrBood(maxrow()-1,"[Esc]=Menu")
        	fScrBood(maxrow()  ,"Type the weighing date of the animals...")
        	nBoxc := fBoxCent(11,"Weighing Date? xx/xx/xx",3,"Weighing Date")
        	@12,nBoxc say "Weighing Date?" get dDate
    	endif
    	setcursor(1)
    	read
    	setcursor(0)

    	// Break if no date
    	if lastkey() == K_ESC .or. empty(dDate)
        	break
    	endif

		do while TRUE
    		// Screen
  			if cLanType() == "A"
	    		fScrOpsk( ,"Opsie "+cOption())
			else
				fScrOpsk( ,"Option "+cOption())
			endif

			IF ! fJaNee(MAXROW(),cBood2)
				BREAK
			ENDIF

    		//Lees (Micro skyfie)
			cIdnr := sm3chip(nPScanr)
			IF EMPTY(cIdnr) .OR. ALLTRIM(cIdnr) == "ESC"
				BREAK
			ENDIF

			cIdnr := PADR(cIdnr,12," ")
			DBSELECTAREA("SM3WEEG")

			IF ! SM3WEEG->(DBSEEK(cIdnr+DTOS(dDate)))
				DBAPPEND()
				SM3WEEG->idnr  := cIdnr
				SM3WEEG->massa := 0
				lNewRec := TRUE
			ELSE
				lNewRec := FALSE
			ENDIF

			// Vertoon dier se inligting
    		if cLanType() == "A"
        		nBoxc := fBoxCent(08,"Geboorte datum.: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",7,"Automatiese weeging")
        		@09,nBoxc say "ID Nommer......: "+cIdnr
				@10,nBoxc say "Naam...........: "+SM3DATA->idnaam
				@11,nBoxc say "Geboorte datum.: "+DTOC(SM3DATA->gebdatum)
				@12,nBoxc say "Weeg datum.....: "+DTOC(dDate)
				@13,nBoxc say "Gewig..........: "+STR(SM3WEEG->massa,4,0)
    		else
        		nBoxc := fBoxCent(08,"Geboorte datum.: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",7,"Automatic weighing")
        		@09,nBoxc say "ID Number......: "+cIdnr
				@10,nBoxc say "Name...........: "+SM3DATA->idnaam
				@11,nBoxc say "Birth date.....: "+DTOC(SM3DATA->gebdatum)
				@12,nBoxc say "Weighing date..: "+DTOC(dDate)
				@13,nBoxc say "Weight.........: "+STR(SM3WEEG->massa,4,0)
    		endif

			// Lees gewig
			nWeight := 0
			IF ! sm3weigh(nPScale,@nWeight)
				LOOP
			ENDIF

			@13,nBoxc+17 say STR(nWeight,4,0)

			fScrBood(MAXROW()-1)
			fScrBood(MAXROW())

			IF fJaNee(MAXROW(),cBood1)
				DO WHILE ! RLOCK() ; ENDDO
				SM3WEEG->weegdatum := dDate
				SM3WEEG->massa     := nWeight
				DBCOMMIT()
			ELSE
				IF lNewRec
					DO WHILE ! RLOCK() ; ENDDO
					DBDELETE()
					DBCOMMIT()
				ENDIF
			ENDIF
		enddo
	end

	// Reset
	COM_CLOSE(nPScanr)
	COM_CLOSE(nPScale)
	fATclose(aCdbf)
	fARestScr(aCscr)

return NIL

*-----------------------------------------------------------------------------
STATIC FUNCTION sm3chip (nPort)

	LOCAL nChr, nChar, cBuffer, nPos
	LOCAL cCurScr := fCurScreen()                    //Huidige skerm besonderhede
	LOCAL cCurSke := savescreen( 0, 0, maxrow(), maxcol() )
	LOCAL aCdbf   := fATOpen()
	LOCAL cIdnr   := "ESC"

    if cLanType() == "A"
	    fScrOpsk(1,"Opsie "+cOption())
    else
    	fScrOpsk(1,"Option "+cOption())
    endif

	fScrBood(MAXROW()-1)
	fScrBood(MAXROW())

	IF ! COM_FLUSH(nPort)
    	if cLanType() == "A"
			fScrWait(MAXROW(),"Kan nie invoer buffer skoon maak nie")
		else
			fScrWait(MAXROW(),"Unable to Flush the Input Buffer")
		endif

		fSetScreen( cCurScr )
		restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
    	fATClose(aCdbf)
		RETU "ESC"
	ENDIF

	DO WHILE TRUE

		fScrBood(MAXROW()-1)
    	if cLanType() == "A"
			fScrBood(MAXROW(),"Wag vir dier se InvizBolus nommer... [Esc]=menu")
		else
			fScrBood(MAXROW(),"Waiting for animals InvizBolus number... [Esc]=menu")
		endif

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
   		if cLanType() == "A"
			fScrBood(MAXROW(),"Lees dier se Micro-skyfie nommer...")
		else
			fScrBood(MAXROW(),"Reading animals Micro-chip number...")
		endif

		cBuffer := COM_READ(nPort,42)		// Read first 42 characters from the Buffer
		nPos := AT("#",cBuffer)

		IF nPos = 0
			IF ! COM_FLUSH(nPort)
    			if cLanType() == "A"
					fScrWait(MAXROW(),"Kan nie invoer buffer skoon maak nie")
				else
					fScrWait(MAXROW(),"Unable to Flush the Input Buffer...")
				endif

				fSetScreen( cCurScr )
				restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
    			fATClose(aCdbf)
				RETU "ESC"
			ENDIF

			LOOP
		ENDIF

		cBuffer := SUBSTR(cBuffer,nPos+1,16)

		IF ! CheckSum(cBuffer)
			IF ! COM_FLUSH(nPort)
    			if cLanType() == "A"
					fScrWait(MAXROW(),"Kan nie invoer buffer skoon maak nie")
				else
					fScrWait(MAXROW(),"Unable to Flush the Input Buffer...")
				endif

				COM_CLOSE(nPort)
				fSetScreen( cCurScr )
				restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
    			fATClose(aCdbf)
				RETU "ESC"
			ENDIF

			LOOP
		ENDIF

		EXIT
	ENDDO

	IF ! EMPTY(cBuffer)
		cBuffer := PADR(cBuffer,12," ")
		DBSELECTAREA("SM3DATA")
		ORDSETFOCUS(13)

		IF ! SM3DATA->(DBSEEK(cBuffer))
    		if cLanType() == "A"
				fScrWait(MAXROW(),"Daar is nie 'n dier met die nommer : "+ALLTRIM(cBuffer)+" nie")
			else
				fScrWait(MAXROW(),"Unable to locate a animal with number : "+ALLTRIM(cBuffer))
			endif

			fSetScreen( cCurScr )
			restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
    		fATClose(aCdbf)
			RETU "ESC"
		ENDIF

		cIdnr := SM3DATA->idnr
	ENDIF

	//Herstel
	fSetScreen( cCurScr )
	restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
    fATClose(aCdbf)

return cIdnr

*-----------------------------------------------------------------------------*
STATIC FUNCTION Sm3Weigh (nPort,nWeight)

	LOCAL nChr, nChar, cBuffer, nPos, cNewBuf, nValue, i
	LOCAL cCurScr := fCurScreen()                    //Huidige skerm besonderhede
	LOCAL cCurSke := savescreen( 0, 0, maxrow(), maxcol() )
	LOCAL lRetu   := FALSE
	LOCAL n       := 0

    if cLanType() == "A"
	    fScrOpsk(1,"Opsie "+cOption())
    else
    	fScrOpsk(1,"Option "+cOption())
    endif

	fScrBood(MAXROW()-1)
	fScrBood(MAXROW())

	DO WHILE TRUE
		cBuffer := ""
		nChar := 0
		nChr  := 0

		IF ! COM_FLUSH(nPort)
    		if cLanType() == "A"
				fScrWait(MAXROW(),"Kan nie invoer buffer skoon maak nie")
			else
				fScrWait(MAXROW(),"Unable to Flush the Input Buffer...")
			endif

			COM_CLOSE(nPort)
			fSetScreen( cCurScr )
			restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
			RETU FALSE
		ENDIF

    	if cLanType() == "A"
			fScrBood(MAXROW()-1,"Wag vir gewig vanaf die skaal... [Esc]=aborteer")
		else
			fScrBood(MAXROW()-1,"Waiting for a weight from the scale... [Esc]=abort")
		endif

		DO WHILE TRUE
    		if cLanType() == "A"
	   			fScrBood(MAXROW(),"Skaal gereed : "+PADL(ALLTRIM(STR(++n)),3,"0"))
			else
	   			fScrBood(MAXROW(),"Scale Ready : "+PADL(ALLTRIM(STR(++n)),3,"0"))
			endif

			IF n > 998
				n := 0
			ENDIF

			nChr := INKEY(0.4)

			IF nChr == K_ESC
				EXIT
			ENDIF

			nChar := COM_COUNT(nPort)

			IF nChar > 0
				DO WHILE COM_COUNT(nPort) < 40
					nChr := INKEY(0.4)
					IF nChr == K_ESC
						EXIT
					ENDIF

					IF COM_COUNT(nPort) = nChar
						EXIT
					ENDIF
				ENDDO

				IF COM_COUNT(nPort) > 40
					EXIT
				ENDIF

				IF COM_COUNT(nPort) = nChar .AND. nChr != K_ESC
					LOOP
				ENDIF

				EXIT
			ENDIF
		ENDDO

		IF nChr == K_ESC
			EXIT
		ENDIF

		cBuffer += COM_READ(nPort)

//----------------------------------------------------------------------------
//	The data received from the LIBRA scale is not ASCII characters but a
//	binary code with the value stored in the middle 4 bits (00nnnn00) of a
//	byte. Each byte is Logical ANDed with decimal 60 (00111100) to clear the
//	2 bits on either side. The value remained is then devided by 4 to right
//	justify it and then 48 is added to convert it to an ASCII value.
//----------------------------------------------------------------------------
		cNewBuf := ""

		FOR i := 1 TO LEN(cBuffer)
			nValue  := NUMAND(ASC(SUBSTR(cBuffer,i,1)),60)		// Clear Left 2 and Right 2 bits Dec 60 = '00111100'
			cNewBuf += CHR((nValue / 4) + 48)					// Right justify value and convert to ASCII
		NEXT
//----------------------------------------------------------------------------

		IF ! "?" $ cNewBuf
			LOOP
		ENDIF

		IF LEN(cNewBuf) - AT("?",cNewBuf) < 8
			LOOP
		ENDIF

		cNewBuf := SUBSTR(cNewBuf,AT("?",cNewBuf)+1,5)
		EXIT
	ENDDO

	IF nChr != K_ESC .AND. ! EMPTY(cNewBuf)
		nWeight := VAL(ALLTRIM(SUBSTR(cNewBuf,1,5)))
		lRetu := TRUE
	ELSE
		lRetu := FALSE
	ENDIF

	fSetScreen( cCurScr )
	restscreen( 0, 0, maxrow(), maxcol(), cCurSke )

RETURN lRetu

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

