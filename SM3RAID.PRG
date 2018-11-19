// Application: Stoetmeester
//   File Name: SM3RAID.PRG
// Description: Reset AI or Service dates from the Service Database
//   Copyright: (c) 1996 by Q Data Consulting (Pty) Ltd, Q Farm Division
//      Author: Sarel Cloete
//  Created on: 05-05-97 13:50am

#include "set.ch"
#include "inkey.ch"
#include "albert.ch"
#include "Common.ch"

/******************************************************************************/
FUNCTION sm3raid()

   // Declare
   LOCAL aCdbf   := fATopen()
   LOCAL cCcur   := SETCURSOR(0)
   LOCAL cIdMoer := ""
   LOCAL cTGr    := ""
   LOCAL nPos    := 0
   LOCAL cSiklus := 21

   BEGIN SEQUENCE
      // Clear screen
      fScrOpsk()

      IF cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      ELSE
         fScrOpsk(1,"Option "+cOption())
      ENDIF

      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Datalˆers word geopen")
      ELSE
         fScrWbood(MAXROW(),"Data files being opened")
      ENDIF

      fScrBood(MAXROW()-1)
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3DEKK",,,,FALSE)
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS")
      IF !aCdbf[len(aCdbf),1]
      ELSE
         LOCATE FOR SM3RASS->raskod == substr(cTotNaam(),149,3)
         IF !EOF()
            cSiklus := SM3RASS->siklus
         ENDIF
      ENDIF

      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Herstel dek datums")
      ELSE
         fScrWbood(MAXROW(),"Reset service dates")
      ENDIF

      fScrBood(MAXROW()-1,"")
      DBSELECTAREA("SM3DEKK")
      ORDSETFOCUS(1)
      DBGOTOP()

      DO WHILE ! EOF()

         // Display a percentage
         IF CMKEYNO() % 10 = 0
            SETCOLOR( cColBott() )
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+"% Voltooi")
            ELSE
               fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+"% Completed")
            ENDIF
            SETCOLOR( cColNorm() )
         ENDIF

         cIdMoer := SM3DEKK->idmoer

         DO WHILE ! EOF() .AND. SM3DEKK->idmoer == cIdMoer
            DBSKIP()
         ENDDO

         DBSKIP(-1)
         IF cIdMoer != SM3DEKK->idmoer
            EXIT                                 // Database out of sinc. ???
         ENDIF

         IF ! SM3DATA->(DBSEEK(cIdMoer))
            DBSKIP()
            LOOP
         ENDIF

         IF ! SM3DATA->uitkrede $ cWaarisd() //.OR. ! EMPTY(SM3DATA->dekdat)
            DBSKIP()
            LOOP
         ENDIF

         IF SM3DEKK->datumin <= SM3DATA->lkalfdatum
            DBSKIP()
            LOOP
         ENDIF

         nPos := RECNO()
         cTGr := SM3DEKK->teelgroep
         ORDSETFOCUS(2)

         IF ! SM3DEKK->(DBSEEK(cTGr + cIdMoer))
            ORDSETFOCUS(1)
            DBGOTO (nPos)
            DBSKIP()
            LOOP
         ENDIF

         IF SM3DEKK->datumin <= SM3DATA->lkalfdatum .OR. EMPTY(SM3DEKK->dragtig)
            ORDSETFOCUS(1)
            DBGOTO (nPos)
         ENDIF

         DBSELECTAREA("SM3DATA")
         DO WHILE ! RLOCK()
         ENDDO
         SM3DATA->dekdat     := SM3DEKK->datumin
         SM3DATA->tipede     := SM3DEKK->vaarkode
         SM3DATA->dragda     := SM3DEKK->dragda
         SM3DATA->bulid      := SM3DEKK->idvaar
         SM3DATA->teelgroep  := SM3DEKK->teelgroep
         SM3DATA->dragwe     := SM3DEKK->dragwe
         SM3DATA->dragti     := SM3DEKK->dragtig

         IF SM3DEKK->dragwe > 0 .AND. ! EMPTY(SM3DEKK->dragda)
            SM3DATA->dekdat := SM3DEKK->dragda - (SM3DEKK->dragwe * 7)
         ENDIF

         IF SM3DATA->dragti == "N" .AND. EMPTY(SM3DATA->dragda)
            SM3DATA->dragda := SM3DATA->dekdat + (cSiklus * 3)
            DBSELECTAREA("SM3DEKK")
            DO WHILE ! RLOCK()
            ENDDO
            SM3DEKK->dragda := SM3DEKK->datumin + (cSiklus * 3)
         ENDIF

         DBSELECTAREA("SM3DEKK")
         ORDSETFOCUS(1)
         DBGOTO (nPos)
         DBSKIP()

      ENDDO

   END

   // Reset
   fATclose(aCdbf)
   SETCURSOR(cCcur)

RETURN NIL
