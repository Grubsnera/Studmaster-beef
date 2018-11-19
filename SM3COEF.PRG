// Application: Stoetmeester
//   File Name: SM3COEF.PRG
// Description: Program to Calculate the inbreed coefficient for the herd
//   Copyright: (c) 1996 by Q Data Consulting (Pty) Ltd, Q Farm Division
//      Author: Sarel Cloete
//  Created on: 04-03-97 07:07am

#include "set.ch"
#include "inkey.ch"
#include "albert.ch"
#include "Common.ch"

/******************************************************************************/
FUNCTION sm3coef()

   // Declare
   LOCAL aMatrix
   LOCAL aCdbf   := fATopen()
   LOCAL cCcur   := SETCURSOR(0)
   LOCAL cBood   := ""
   LOCAL i       := 0
   LOCAL nRow    := 0
   LOCAL nCol    := 0
   LOCAL nPos    := 0
   LOCAL nVaar   := 0
   LOCAL nMoer   := 0
   LOCAL nAddRel := 0
   LOCAL nRowCol := 0

   BEGIN SEQUENCE
      // Clear screen
      fScrOpsk()

      IF cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      ELSE
         fScrOpsk(1,"Option "+cOption())
      ENDIF

      IF cLanType() == "A"
         fScrBood(MAXROW()-1,"Afhangende van die kudde grootte, mag hierdie stap...")
         cBood := "heelwat tyd en disk spasie benodig"
      ELSE
         fScrBood(MAXROW()-1,"Depending on the herd size, this step...")
         cBood := "might need considerible time and disc space"
      ENDIF

      IF ! fJaNee(MAXROW(),cBood,,FALSE )
         BREAK
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

      aCdbf := fATopen(aCdbf,cDd(),"SM3IBCP",,,,FALSE)
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3IBCA",,,,FALSE)
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Skep Stamboom lˆer")
      ELSE
         fScrWbood(MAXROW(),"Create Pedigree file")
      ENDIF

      fScrBood(MAXROW()-1,"")
      DBSELECTAREA("SM3IBCP")
      ZAP
      DBSELECTAREA("SM3IBCA")
      ZAP

      DBSELECTAREA("SM3DATA")
      DBCLEARIND()
      DBCREATEIND(cDd()+"SM3DATA.SSC","DTOS(gebdatum)",{ || DTOS(SM3DATA->gebdatum) })
      DBGOTOP()

      DO WHILE ! EOF()
         IF CMKEYNO() % 10 = 0
            SETCOLOR( cColBott() )
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+"% Voltooi")
            ELSE
               fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+"% Completed")
            ENDIF
            SETCOLOR( cColNorm() )
         ENDIF

         DO WHILE ! RLOCK()
         ENDDO
         SM3DATA->ibcoef := 0.0000

         IF EMPTY(SM3DATA->gebdatum)
            DBSKIP()
            LOOP
         ENDIF

         DBSELECTAREA("SM3IBCP")
         DBAPPEND()
         SM3IBCP->idnr  := SM3DATA->idnr
         nPos           := RECNO()
         nVaar          := 0
         nMoer          := 0

         IF ! EMPTY(SM3DATA->idvaar) .AND. SM3IBCP->(DBSEEK(SM3DATA->idvaar))
            nVaar := RECNO()
         ENDIF

         IF ! EMPTY(SM3DATA->idmoer) .AND. SM3IBCP->(DBSEEK(SM3DATA->idmoer))
            nMoer := RECNO()
         ENDIF

         DBGOTO (nPos)
         SM3IBCP->vaar := nVaar
         SM3IBCP->moer := nMoer

         DBSELECTAREA("SM3DATA")
         DBSKIP()
      ENDDO

      DBSELECTAREA("SM3IBCP")
      DBCLEARIND()

      // Create Additive Relationship (Matrix) file...
      // This file would contain one record for each cell in the matrix...
      // If there is a 1000 animals in the herd then this file would contain
      // a 1000 x 1000 = 1 000 000 records.
      // Although it is 1 field records, the file could be quite big...
      nRowCol := LASTREC()

      //IF DISKFREE() < ((nRowCol ** 2) * 10) + 67
      //fscrbood(24,str(diskspace()))
      //inkey(0)
      IF diskspace() < ((nRowCol ** 2) * 10) + 67
         IF cLanType() == "A"
            fScrbood(MAXROW()-1,"Daar is nie genoeg harde skyf spasie nie... benodig ñ "+ALLTRIM(STR((((nRowCol ** 2) * 10) + 67) / 1000000,9,2))+"Mg")
         ELSE
            fScrbood(MAXROW()-1,"There is not enough hard disc space... need ñ "+ALLTRIM(STR((((nRowCol ** 2) * 10) + 67) / 1000000,9,2))+"Mg")
         ENDIF

         fScrWait(MAXROW())
         BREAK

      ENDIF

      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Skep Aanvullende Verhouding (Matriks) lˆer")
      ELSE
         fScrWbood(MAXROW(),"Create Additive Relationship (Matrix) file")
      ENDIF

      fScrBood(MAXROW()-1,"")
      DBSELECTAREA("SM3IBCA")

      FOR i := 1 TO (nRowCol ** 2)
         IF i % 100 = 0
            SETCOLOR( cColBott() )
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,STR((i / (nRowCol ** 2)) * 100,4,0)+"% Voltooi")
            ELSE
               fScrBood(MAXROW()-1,STR((i / (nRowCol ** 2)) * 100,4,0)+"% Completed")
            ENDIF
            SETCOLOR( cColNorm() )
         ENDIF

         DBAPPEND()
         SM3IBCA->addrel := 0.0000
      NEXT

      // Initialize diagonal values... (Rule 4)
      FOR i := 1 TO nRowCol
         DBGOTO(CALPOS(i,i,nRowCol))
         SM3IBCA->addrel := 1.0000
      NEXT

      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Bereken Aanvullende Verhoudings")
      ELSE
         fScrWbood(MAXROW(),"Calculate Additive Relationships")
      ENDIF

      fScrBood(MAXROW()-1,"")

      FOR nRow := 1 TO nRowCol
         IF nRow % 10 = 0
            SETCOLOR( cColBott() )
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,STR((nRow / nRowCol) * 100,4,0)+"% Voltooi")
            ELSE
               fScrBood(MAXROW()-1,STR((nRow / nRowCol) * 100,4,0)+"% Completed")
            ENDIF
            SETCOLOR( cColNorm() )
         ENDIF

         SM3IBCP->(DBGOTO(nRow))

         // Calculate diagonal value... (Rule 6)
         IF SM3IBCP->vaar != 0 .AND. SM3IBCP->moer != 0
            SM3IBCA->(DBGOTO(CALPOS(SM3IBCP->vaar,SM3IBCP->moer,nRowCol)))
            nAddRel := SM3IBCA->addrel / 2
            SM3IBCA->(DBGOTO(CALPOS(nRow,nRow,nRowCol)))
            SM3IBCA->addrel += nAddRel
         ENDIF

         // Calculate off-diagonal values... (Rule 5)
         FOR nCol := (nRow + 1 ) TO nRowCol
            nVaar := 0
            nMoer := 0
            SM3IBCP->(DBGOTO(nCol))

            IF SM3IBCP->vaar != 0
               SM3IBCA->(DBGOTO(CALPOS(nRow,SM3IBCP->vaar,nRowCol)))
               nVaar := SM3IBCA->addrel
            ENDIF

            IF SM3IBCP->moer != 0
               SM3IBCA->(DBGOTO(CALPOS(nRow,SM3IBCP->moer,nRowCol)))
               nMoer := SM3IBCA->addrel
            ENDIF

            SM3IBCA->(DBGOTO(CALPOS(nRow,nCol,nRowCol)))
            SM3IBCA->addrel := (nVaar + nMoer) / 2
         NEXT

         // Transfer top part of matrix to bottom part
         FOR i := (nROW + 1) TO nRowCol
            SM3IBCA->(DBGOTO(CALPOS(nRow,i,nRowCol)))
            nAddRel := SM3IBCA->addrel
            SM3IBCA->(DBGOTO(CALPOS(i,nRow,nRowCol)))
            SM3IBCA->addrel := nAddRel
         NEXT
      NEXT

      // Close and re-open the databases... in order to activate normal indexes
      fATclose(aCdbf)
      FERASE(cDd()+"SM3DATA.SSC")
      aCdbf := fATopen()

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3IBCP",,,,FALSE)
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3IBCA",,,,FALSE)
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      // Calculate the Inbreed Coefficient
      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Bereken die Inteel Ko‰ffisi‰nt")
      ELSE
         fScrWbood(MAXROW(),"Calculate the Inbreed Coefficient")
      ENDIF

      fScrBood(MAXROW()-1,"")
      DBSELECTAREA("SM3DATA")
      ORDSETFOCUS(1)
      DBSELECTAREA("SM3IBCP")
      DBGOTOP()

      DO WHILE ! EOF()
         IF CMKEYNO() % 10 = 0
            SETCOLOR( cColBott() )
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+"% Voltooi")
            ELSE
               fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+"% Completed")
            ENDIF
            SETCOLOR( cColNorm() )
         ENDIF

         IF SM3IBCP->vaar != 0 .AND. SM3IBCP->moer != 0 .AND. SM3DATA->(DBSEEK(SM3IBCP->idnr))
            SM3IBCA->(DBGOTO(CALPOS(SM3IBCP->vaar,SM3IBCP->moer,nRowCol)))
            DBSELECTAREA("SM3DATA")
            DO WHILE ! RLOCK()
            ENDDO
            SM3DATA->ibcoef := (SM3IBCA->addrel / 2) * 100
         ENDIF

         DBSELECTAREA("SM3IBCP")
         DBSKIP()
      ENDDO

      SM3DATA->(DBCOMMIT())

      // Clear Temporarily databases... they could be big !!!
      DBSELECTAREA("SM3IBCA")
      ZAP
      DBSELECTAREA("SM3IBCP")
      ZAP

   END

   // Reset
   fATclose(aCdbf)
   SETCURSOR(cCcur)

RETURN NIL

*-----------------------------------------------------------------------------
STATIC FUNCTION CALPOS(nRow,nCol,nTot)

RETURN ((nRow - 1) * nTot) + nCol
