// Application: Stoetmeester
//   File Name: SM3FPIB.PRG
// Description: Program to Calculate the inbreed coefficient for future progeny
//   Copyright: (c) 1996 by Q Data Consulting (Pty) Ltd, Q Farm Division
//      Author: Sarel Cloete
//  Created on: 12-03-97 09:46am

#include "set.ch"
#include "inkey.ch"
#include "albert.ch"
#include "Common.ch"

/******************************************************************************/
FUNCTION sm3cfpi()

	// Declare
	LOCAL nIbPer  := 0
	LOCAL aCdbf   := fATopen()
	LOCAL cCcur   := SETCURSOR(0)
	LOCAL cMoer   := ""
	LOCAL cVaar   := ""
	LOCAL cHdg    := ""
	LOCAL cBd1    := ""
	LOCAL cBd2    := ""

	// Clear screen
	IF cLanType() == "A"
		fScrOpsk( ,"Opsie "+cOption())
		cHdg := "Waarskuwing"
		cBd1 := "Inteel Ko‰ffisi‰nte vir kudde moet bereken word voordat"
		cBd2 := "     hierdie funksie suksesvol gebruik kan word."
	ELSE
		fScrOpsk( ,"Option "+cOption())
		cHdg := "Warning"
		cBd1 := "The inbreed coefficient for the herd must be calculated"
		cBd2 := "  before this function could be successfully applied."
	ENDIF

	fBox(04,11,07,69,cHdg)
	@ 05,13 SAY cBd1
	@ 06,13 SAY cBd2

	DO WHILE TRUE
		IF cLanType() == "A"
			IF ! fLocate("Tik Id Nommer van Vaar (Esc -> aborteer)","Vaar ",@cVaar,"2")
				EXIT
			ENDIF

			IF ! fLocate("Tik Id Nommer van Moer (Esc -> aborteer)","Moer ",@cMoer,"1")
				EXIT
			ENDIF

			cHdg := "Inteel Persentasie"
			cBd1 := "Bereken toekomstige nageslag se inteel persentasie"
		ELSE
			IF ! fLocate("Enter Id Number of Sire (Esc -> abort)","Sire ",@cVaar,"2")
				EXIT
			ENDIF

			IF ! fLocate("Enter Id Number of Dam (Esc -> abort)","Dam ",@cMoer,"1")
				EXIT
			ENDIF

			cHdg := "Inbreed Percentage"
			cBd1 := "Calculate future progeny inbreeding percentage"
		ENDIF

		IF cLanType() == "A"
			fScrBood(MAXROW()-1,cBd1)
		ELSE
			fScrBood(MAXROW()-1,cBd1)
		ENDIF

		nIbPer := sm3fpib (cVaar,cMoer)

		fBox(16,20,20,61,cHdg)
		@ 18,22 SAY ALLTRIM(cVaar)+" x "+ALLTRIM(cMoer)+" = "+ALLTRIM(STR(nIbPer,6,2))+"%"
		fScrBood(MAXROW()-1)
		fScrWait(MAXROW())
	ENDDO

	// Reset
	fATclose(aCdbf)
	SETCURSOR(cCcur)

RETURN NIL

/******************************************************************************/
STATIC FUNCTION fLocate(cMsg1,cMsg2,cKeyp,cSex)

   	// Declare
   	LOCAL getlist := {}
   	LOCAL lRetu := TRUE
   	LOCAL aCscr := fASaveScr()
   	LOCAL aCdbf := fATopen()
   	LOCAL nBoxc := 0

	BEGIN SEQUENCE
    	aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
    	IF ! aCdbf[LEN(aCdbf),1]
			BREAK
		ENDIF

		DBSELECTAREA("SM3DATA")
		ORDSETFOCUS(1)

		DO WHILE TRUE
   			// Field length
   			cKeyp := SPACE(12)

   			// Ask the data to locate
   			fScrBood(MAXROW()-1)
   			fScrBood(MAXROW(),cMsg1)
   			nBoxc := fBoxCent(MAXROW()/2,cMsg2+SPACE(LEN(cKeyp)),1)
            @MAXROW()/2, nBoxc SAY cMsg2 GET cKeyp PICT "@!"
   			SET(_SET_CURSOR,1)
   			READ
   			SET(_SET_CURSOR,0)
   			fARestScr(aCscr)
   			cmclrfilter()

   			// To do
   			IF LASTKEY() == K_ESC
      			lRetu := FALSE
				EXIT
   			ENDIF

			IF ! SM3DATA->(DBSEEK(cKeyp))
				IF cLanType() == "A"
					fScrBood(MAXROW()-1,"Daar is nie 'n dier met hierdie nommer nie !")
				ELSE
					fScrBood(MAXROW()-1,"There is not an animal with this number !")
				ENDIF

				fScrWait(MAXROW())
				LOOP
			ENDIF

			IF SM3DATA->geslag != cSex
				IF cLanType() == "A"
					IF cSex == "1"
						fScrBood(MAXROW()-1,"Hierdie dier is nie vroulik nie")
					ELSE
						fScrBood(MAXROW()-1,"Hierdie dier is nie manlik nie")
					ENDIF
				ELSE
					IF cSex == "1"
						fScrBood(MAXROW()-1,"This is not a female animal")
					ELSE
						fScrBood(MAXROW()-1,"This is not a male animal")
					ENDIF
				ENDIF

				fScrWait(MAXROW())
				LOOP
			ENDIF

			EXIT
		ENDDO
	END

	// Reset
	fATclose(aCdbf)

RETURN lRetu


