//STDSERC.PRG
//Program om serie kommunikasie parameters te stel
//Kopiereg (c) 1991 A van Rensburg
//22:19 09 Sep,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

#define ASCPORT 1
#define ASCBAUD 2
#define ASCPARI 3
#define ASCBITS 4
#define ASCSTOP 5

/******************************************************************************/
FUNCTION STDSERC

   //Veranderlikes
	LOCAL cBood    := ""
   	LOCAL nBoxCoor := 0
   	LOCAL aCdbf    := fATopen()
	LOCAL getlist  := {}
	LOCAL aParam   := {;
					   2,;											// Port
					   9600,;										// Baud Rate
					   "N",;										// Parity
					   8,;											// Bits
					   1;											// Stop bits
					   }

	BEGIN SEQUENCE
    	IF cLanType() == "A"
        	fScrOpsk( , "Opsie "+cOption())
		ELSE
        	fScrOpsk( , "Option "+cOption())
		ENDIF

    	// Open drives file
    	aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
    	IF !aCdbf[len(aCdbf),1]
			BREAK
		ENDIF

		DBGOTOP()
		aParam[ASCPORT] := STDWAAR->scport
		aParam[ASCBAUD] := STDWAAR->scbaud
		aParam[ASCPARI] := STDWAAR->scpari
		aParam[ASCBITS] := STDWAAR->scbits
		aParam[ASCSTOP] := STDWAAR->scstop

   		DO WHILE TRUE
      		// Vra die serie kommunikasie parameters
      		fScrBood( MAXROW()-1 )
      		IF cLanType() == "A"
         		fScrBood( MAXROW(), "Tik die Serie Kommunikasie parameters... 'Esc' = Kanselleer" )
         		nBoxCoor := fBoxCent(5, space(34), 07, "SERIE KOMMUNIKASIE PARAMETERS" )
			ELSE
         		fScrBood( MAXROW(), "Type the Serial Communication parameters... 'Esc' = Quit" )
         		nBoxCoor := fBoxCent(5, space(34), 07, "SERIAL COMMUNICATION PARAMETERS" )
			ENDIF
      		SETCOLOR(cColNorm())

      		IF cLanType() == "A"
         		@ 06, nBoxCoor say "Serie Kommunikasie poort...." get aParam[ASCPORT] pict "@K 9" VALID(fVPoort(aParam))
         		@ 07, nBoxCoor say "Spoed (Baud rate)..........." get aParam[ASCBAUD] pict "@K 99999"
         		@ 08, nBoxCoor say "Pariteit...................." get aParam[ASCPARI] pict "@K Y"
         		@ 09, nBoxCoor say "Bisse (Bits)................" get aParam[ASCBITS] pict "@K 9"
         		@ 10, nBoxCoor say "Stop Bisse.................." get aParam[ASCSTOP] pict "@K 9"
			ELSE
         		@ 06, nBoxCoor say "Serial Communication port..." get aParam[ASCPORT] pict "@K 9" VALID(fVPoort(aParam))
         		@ 07, nBoxCoor say "Baud rate..................." get aParam[ASCBAUD] pict "@K 99999"
         		@ 08, nBoxCoor say "Parity......................" get aParam[ASCPARI] pict "@K Y"
         		@ 09, nBoxCoor say "Bits........................" get aParam[ASCBITS] pict "@K 9"
         		@ 10, nBoxCoor say "Stop bits..................." get aParam[ASCSTOP] pict "@K 9"
			ENDIF
   			SET(_SET_CURSOR,1)
   			READ
   			SET(_SET_CURSOR,0)

      		IF LASTKEY() == K_ESC
				EXIT
			ENDIF

   			IF cLanType() == "A"
      			cBood := "Aanvaar Serie Kommunikasie parameters"
   			ELSE
      			cBood := "Accept Serial Communication parameters"
   			ENDIF

   			IF fJaNee(MAXROW(),cBood,,TRUE )
				DBSELECTAREA("STDWAAR")
				DBGOTOP()

				DO WHILE ! RLOCK() ; ENDDO
				STDWAAR->scport := nScPort(aParam[ASCPORT])
				STDWAAR->scbaud := nScBaud(aParam[ASCBAUD])
				STDWAAR->scpari := cScPari(aParam[ASCPARI])
				STDWAAR->scbits := nScBits(aParam[ASCBITS])
				STDWAAR->scstop := nScStop(aParam[ASCSTOP])
				EXIT
			ENDIF
		ENDDO
	END

	//Reset
   	fATclose(aCdbf)

RETURN NIL

*-----------------------------------------------------------------------------
STATIC FUNCTION fVPoort (aCodes)

	IF aCodes[ASCPORT] < 1 .OR. aCodes[ASCPORT] > 4
    	fScrBood( MAXROW()-1 )
    	IF cLanType() == "A"
        	fScrWait( MAXROW(), "Gebruik '1,2,3 of 4' as Serie kommunikasie poort" )
		ELSE
        	fScrWait( MAXROW(), "Use '1,2,3 or 4' as Serial communication port" )
		ENDIF

    	fScrBood( MAXROW() )
		RETU FALSE
	ENDIF

RETURN TRUE

