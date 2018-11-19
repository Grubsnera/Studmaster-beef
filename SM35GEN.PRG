//SM35GEN.PRG
//Program om 5 generasie voorgeslagte te vertoon
//Kopiereg (c) 1993 A van Rensburg
//                  S Cloete
//11:40 27 Feb,1997

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/

FUNCTION sm35Gen(cIdnr)

   //Veranderlikes
   LOCAL cCscr := SAVESCREEN(0,0,24,79)
   LOCAL aCdbf := fATOpen()
   LOCAL nMenu := 1
   LOCAL cSeek := ""
   LOCAL lItis := TRUE
   LOCAL i     := 1
   LOCAL nTel  := 1
   LOCAL aSend := {}
   LOCAL aRecv := {}
   LOCAL aSens := {}
   LOCAL aRecs := {}
   LOCAL cTest := ""
   LOCAL nReko := 0
   LOCAL nMin  := 0

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   //Kyk of leer bestaan
   //IF ! file(cDd()+"SM35GEN.DBF") Removed 12-17-97 10:32am
   COPY FILE SM35GEN.tdb TO (cDd()+"SM35GEN.DBF")
   //ENDIF

   //Open progeny file
   aCdbf := fATOpen(aCdbf,cDd(),"SM35GEN",,,,FALSE)

   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      RETU NIL
   ENDIF

   REPLACE ALL gener1 WITH SPACE(12),;
      gener2 with SPACE(12),;
      gener3 with SPACE(12),;
      gener4 with SPACE(12),;
      gener5 with SPACE(12),;
      gener6 with SPACE(12)

   //Vertoon menu indien nommer nie gegee is nie
   IF cIdnr == NIL
      // Vertoon hulpskerm
      IF cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      ELSE
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      ENDIF
      // Kry opsienommer
      nMenu := fNewMenu(nMenu,"SM3PEDI")
      fScrBood(23)
      fScrBood(24)

      IF nMenu == 0
         RETU NIL
      ENDIF

      nMin++

      IF cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nMenu))
      ELSE
         fScrOpsk(1,"Option "+cOption(nMenu))
      ENDIF
   ENDIF

   //Kry die groep of seleksiegroep
   IF nMenu == 2
      //Groep
      cTest := sm3groe()
      IF LEN(ALLTRIM(cTest)) == 0
         IF cLanType() == "A"
            fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
         ELSE
            fScrWait(24,"No group selection requirements have been specified!")
         ENDIF

         cOption(-nMin)
         RETU NIL
      ENDIF
   ELSEIF nMenu == 3
      //Seleksiegroep
      cTest := sm3selg()
      IF LEN(ALLTRIM(cTest)) == 0
         IF cLanType() == "A"
            fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
         ELSE
            fScrWait(24,"No selection group requirements have been specified!")
         ENDIF

         cOption(-nMin)
         RETU NIL
      ENDIF
   ENDIF

   //Skerm
   IF cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   ELSE
      fScrOpsk(1,"Option "+cOption())
   ENDIF

   AADD(aSend,{"SM35GEN","gener1"    })
   AADD(aSend,{"SM35GEN","lines1"    })
   AADD(aSend,{"SM35GEN","gener2"    })
   AADD(aSend,{"SM35GEN","lines2"    })
   AADD(aSend,{"SM35GEN","gener3"    })
   AADD(aSend,{"SM35GEN","lines3"    })
   AADD(aSend,{"SM35GEN","gener4"    })
   AADD(aSend,{"SM35GEN","lines4"    })
   AADD(aSend,{"SM35GEN","gener5"    })
   AADD(aSend,{"SM35GEN","lines5"    })
   AADD(aSend,{"SM35GEN","gener6"    })
   aRecv := fGetfield(aSend)

   aCdbf := fATOpen(aCdbf,cDd(),"sm3eiev")

   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      cOption(-nMin)
      RETU NIL
   ENDIF

   cSeek := "5GENER"
   DBSELECTAREA("sm3eiev")

   IF sm3eiev->(DBSEEK(cSeek))
      //Bou die send array
      FOR i = 1 TO 40
         IF ! EMPTY(SUBSTR(SM3EIEV->veld,nTel,10)) .AND. ! EMPTY(SUBSTR(SM3EIEV->veld,nTel+10,10))
            AADD(aSens,{TRIM(SUBSTR(SM3EIEV->veld,nTel,10)),TRIM(SUBSTR(SM3EIEV->veld,nTel+10,10))})
         ENDIF
         nTel := nTel + 20
      NEXT
   ELSE
      AADD(aSens,{"sm3data","reknr"     })
      //AADD(aSens,{"sm3data","kalfbnr"   })
      AADD(aSens,{"sm3data","generasie" })
      AADD(aSens,{"sm3data","gebdatum"  })
      AADD(aSens,{"sm3data","gebmassa"  })
      AADD(aSens,{"sm3data","gekeur"    })
      AADD(aSens,{"sm3data","uitkrede"  })
      AADD(aSens,{"sm3data","ind205"    })
      AADD(aSens,{"sm3data","kalfaantal"})
      AADD(aSens,{"sm3data","gemkalfin" })
   ENDIF

   aRecs := fGetField(aSens)

   //Open datalˆers
   fScrBood(23)

   IF cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   ELSE
      fScrWbood(24,"Data files being opened")
   ENDIF

   aCdbf := fATOpen(aCdbf,cDd(),"sm3weeg")
   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      cOption(-nMin)
      RETU NIL
   ENDIF
   ORDSETFOCUS(2)                                // to get latest weigh date

   aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"SM3VAAR")
   if !aCdbf[len(aCdbf),DBF_NAME]
      fATClose(aCdbf)
      cOption(-nMin)
      RETU NIL
   endif
   aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"SM3MOER")
   if !aCdbf[len(aCdbf),DBF_NAME]
      fATClose(aCdbf)
      cOption(-nMin)
      RETU NIL
   endif
   aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"SM3KALF")
   if !aCdbf[len(aCdbf),DBF_NAME]
      fATClose(aCdbf)
      cOption(-nMin)
      RETU NIL
   endif
   aCdbf := fATOpen(aCdbf,cDd(),"sm3data")
   IF ! aCdbf[LEN(aCdbf),1]
      fATClose(aCdbf)
      cOption(-nMin)
      RETU NIL
   ENDIF

   DBGOBOTTOM()
   DBSKIP()
   DBSELECTAREA("SM35GEN")
   dbsetrelation("SM3WEEG",{|| SM3DATA->idnr },"SM3DATA->idnr")
   dbsetrelation("SM3VAAR",{|| SM3DATA->idvaar },"SM3DATA->idvaar")
   dbsetrelation("SM3MOER",{|| SM3DATA->idmoer },"SM3DATA->idmoer")
   dbsetrelation("SM3KALF",{|| SM3DATA->lkalfn },"SM3DATA->lkalfn")

   //Wat nou
   IF nMenu == 1
      //Een dier
      fDisplay(,,,aRecv,cIdnr,aRecs)
   ELSE
      //Groep of seleksiegroep
      DBSELECTAREA("SM3DATA")
      DBGOTOP()

      DO WHILE ! EOF()
         nReko := RECNO()

         IF &cTest
            fVul(SM3DATA->idnr)

            IF !fPrint(aRecs)
               DBSELECTAREA("SM3DATA")
               DBGOBOTTOM()
               DBSKIP()
               LOOP
            ENDIF
         ENDIF

         //Volgende dier
         DBSELECTAREA("SM3DATA")
         DBGOTO (nReko)
         DBSKIP()
      ENDDO

   ENDIF

   //Herstel
   RESTSCREEN(0,0,24,79,cCscr)
   DBSELECTAREA("SM35GEN")
   set relation to
   fATClose(aCdbf)
   cOption(-nMin)

RETURN NIL

/****************************************************************************/
STATIC FUNCTION fDisplay( nTop, nLeft, nBott, aRecv, cIdnr ,aRecs )

   //Funksie om die stamboom te vertoon

   //Verklaar
   LOCAL nScrl := 0
   LOCAL nRigh := 77
   LOCAL bBrow := NIL
   LOCAL aCols := {}
   LOCAL i     := 0
   LOCAL lMore := TRUE
   LOCAL nKeyp := 0
   LOCAL lNumb := TRUE
   LOCAL oCols := NIL

   private cData := ""
   private cHead := ""

   //Skerm
   IF cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   ELSE
      fScrOpsk( ,"Option "+cOption())
   ENDIF

   //Parameters
   nTop    := IF( nTop  == NIL, 3, nTop  )
   nLeft   := IF( nLeft == NIL, 2, nLeft )
   nBott   := IF( nBott == NIL,19, nBott )

   //Kry die breedte van venster
   FOR i = 1 TO LEN(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      AADD( aCols, TBColumnNew( , {|| &cData } ) )
   NEXT

   //Bepaal regterkantste lyn
   nRigh := IF(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   IF cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "STAMBOOM" )
   ELSE
      fBox( nTop, nLeft, nBott, nRigh, "PEDIGREE" )
   ENDIF
   SETCOLOR( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )

   //Plaas kolomme oor na die browse object
   FOR i = 1 TO LEN( aCols )
      bBrow:addColumn( aCols[i] )
   NEXT

   //Moet idnr gevra word
   IF cIdnr == NIL
      lNumb := TRUE
      cIdnr := SPACE(12)
   ELSE
      IF LEN(ALLTRIM(cIdnr)) > 0
         lNumb := FALSE
         fVul(cIdnr)
         bBrow:rowpos := 8
      ELSE
         lNumb := TRUE
         cIdnr := SPACE(12)
      ENDIF
   ENDIF

   // Main loop
   lMore := TRUE

   DO WHILE lMore
      //Skerm

      IF cLanType() == "A"
         SETCOLOR(cColHead())
         @nTop,nLeft+2 SAY " STAMBOOM VAN " + cIdnr
         SETCOLOR(cColNorm())
         fScrBood( 23, "[ Esc ]=Menu     [Alt P]=Druk     " )
         fScrBood( 24, "[Enter]=Vertoon  [A - Z]=Nuwe dier" )
      ELSE
         SETCOLOR(cColHead())
         @nTop,nLeft+2 SAY " PEDIGREE FOR " + cIdnr
         SETCOLOR(cColNorm())
         fScrBood( 23, "[ Esc ]=Menu     [Alt P]=Print     " )
         fScrBood( 24, "[Enter]=Display  [A - Z]=New animal" )
      ENDIF

      //Vries
      bBrow:freeze := 1

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      DO WHILE nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      ENDDO

      IF bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in CASE we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         IF lNumb
            KEYBOARD CHR(K_CTRL_BS)
            lNumb := FALSE
         ENDIF
         nKeyp := InKey(0)
      ENDIF

      IF nKeyp == K_ESC
         //Esc means leave
         lMore := FALSE

      ELSEIF nKeyp == K_ENTER
         //Enter means display figures
         fFigure(nTop,nLeft,nBott,aRecs,fieldget(bBrow:colpos))
         bBrow:refreshall()

      ELSEIF nKeyp == K_CTRL_BS
         //Nuwe nommer
         IF fIdnr()
            cIdnr := SM3DATA->idnr
            bBrow:refreshall()
            ForceStable(bBrow)
            bBrow:rowpos := 8
            bBrow:colpos := 1
         ELSE
            lMore := FALSE
         ENDIF

      ELSEIF CHR(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Nuwe nommer
         bBrow:panHome()
         bBrow:rowpos := 1
         bBrow:colpos := 1
         SM35GEN->(DBGOTOP())
         ForceStable(bBrow)

         IF fIdnr(CHR(nKeyp))
            cIdnr := SM3DATA->idnr
            bBrow:refreshall()
            ForceStable(bBrow)
            bBrow:rowpos := 8
            bBrow:colpos := 1
         ENDIF

      ELSEIF nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecs)
         bBrow:refreshall()
         bBrow:rowpos := 8
         bBrow:colpos := 1
      ELSE
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)
      ENDIF
   ENDDO

   //Herstel
RETURN NIL

/****************************************************************************/
STATIC FUNCTION fVul(cIdnr)

   //Funksie om leer te vul met die korrekte data

   //Verklaar
   LOCAL aStam := {}

   //Kry die dier self
   DBSELECTAREA("SM3DATA")
   aStam := f5GenStam(cIdnr)
   SM3DATA->(DBSEEK(cIdnr))

   //Vul die stamboomleer
   DBSELECTAREA("SM35GEN")
   DBGOTOP()

   DO WHILE ! EOF()

      DO CASE
         CASE RECNO() == 1
            SM35GEN->gener6 := aStam[32,1]
            SM35GEN->gener5 := aStam[16,2]
         CASE RECNO() == 2
            SM35GEN->gener5 := aStam[16,1]
         CASE RECNO() == 3
            SM35GEN->gener6 := aStam[33,1]
            SM35GEN->gener5 := aStam[16,3]
            SM35GEN->gener4 := aStam[08,2]
         CASE RECNO() == 4
            SM35GEN->gener4 := aStam[08,1]
         CASE RECNO() == 5
            SM35GEN->gener6 := aStam[34,1]
            SM35GEN->gener5 := aStam[17,2]
            SM35GEN->gener4 := aStam[08,3]
         CASE RECNO() == 6
            SM35GEN->gener5 := aStam[17,1]
         CASE RECNO() == 7
            SM35GEN->gener6 := aStam[35,1]
            SM35GEN->gener5 := aStam[17,3]
            SM35GEN->gener3 := aStam[04,2]
         CASE RECNO() == 8
            SM35GEN->gener3 := aStam[04,1]
         CASE RECNO() == 9
            SM35GEN->gener6 := aStam[36,1]
            SM35GEN->gener5 := aStam[18,2]
            SM35GEN->gener3 := aStam[04,3]
         CASE RECNO() == 10
            SM35GEN->gener5 := aStam[18,1]
         CASE RECNO() == 11
            SM35GEN->gener6 := aStam[37,1]
            SM35GEN->gener5 := aStam[18,3]
            SM35GEN->gener4 := aStam[09,2]
         CASE RECNO() == 12
            SM35GEN->gener4 := aStam[09,1]
         CASE RECNO() == 13
            SM35GEN->gener6 := aStam[38,1]
            SM35GEN->gener5 := aStam[19,2]
            SM35GEN->gener4 := aStam[09,3]
         CASE RECNO() == 14
            SM35GEN->gener5 := aStam[19,1]
         CASE RECNO() == 15
            SM35GEN->gener6 := aStam[39,1]
            SM35GEN->gener5 := aStam[19,3]
            SM35GEN->gener2 := aStam[02,2]
         CASE RECNO() == 16
            SM35GEN->gener2 := aStam[02,1]
         CASE RECNO() == 17
            SM35GEN->gener6 := aStam[40,1]
            SM35GEN->gener5 := aStam[20,2]
            SM35GEN->gener2 := aStam[02,3]
         CASE RECNO() == 18
            SM35GEN->gener5 := aStam[20,1]
         CASE RECNO() == 19
            SM35GEN->gener6 := aStam[41,1]
            SM35GEN->gener5 := aStam[20,3]
            SM35GEN->gener4 := aStam[10,2]
         CASE RECNO() == 20
            SM35GEN->gener4 := aStam[10,1]
         CASE RECNO() == 21
            SM35GEN->gener6 := aStam[42,1]
            SM35GEN->gener5 := aStam[21,2]
            SM35GEN->gener4 := aStam[10,3]
         CASE RECNO() == 22
            SM35GEN->gener5 := aStam[21,1]
         CASE RECNO() == 23
            SM35GEN->gener6 := aStam[43,1]
            SM35GEN->gener5 := aStam[21,3]
            SM35GEN->gener3 := aStam[05,2]
         CASE RECNO() == 24
            SM35GEN->gener3 := aStam[05,1]
         CASE RECNO() == 25
            SM35GEN->gener6 := aStam[44,1]
            SM35GEN->gener5 := aStam[22,2]
            SM35GEN->gener3 := aStam[05,3]
         CASE RECNO() == 26
            SM35GEN->gener5 := aStam[22,1]
         CASE RECNO() == 27
            SM35GEN->gener6 := aStam[45,1]
            SM35GEN->gener5 := aStam[22,3]
            SM35GEN->gener4 := aStam[11,2]
         CASE RECNO() == 28
            SM35GEN->gener4 := aStam[11,1]
         CASE RECNO() == 29
            SM35GEN->gener6 := aStam[46,1]
            SM35GEN->gener5 := aStam[23,2]
            SM35GEN->gener4 := aStam[11,3]
         CASE RECNO() == 30
            SM35GEN->gener5 := aStam[23,1]
         CASE RECNO() == 31
            SM35GEN->gener6 := aStam[47,1]
            SM35GEN->gener5 := aStam[23,3]
            SM35GEN->gener1 := aStam[01,2]
         CASE RECNO() == 32
            SM35GEN->gener1 := aStam[01,1]
         CASE RECNO() == 33
            SM35GEN->gener6 := aStam[48,1]
            SM35GEN->gener5 := aStam[24,2]
            SM35GEN->gener1 := aStam[01,3]
         CASE RECNO() == 34
            SM35GEN->gener5 := aStam[24,1]
         CASE RECNO() == 35
            SM35GEN->gener6 := aStam[49,1]
            SM35GEN->gener5 := aStam[24,3]
            SM35GEN->gener4 := aStam[12,2]
         CASE RECNO() == 36
            SM35GEN->gener4 := aStam[12,1]
         CASE RECNO() == 37
            SM35GEN->gener6 := aStam[50,1]
            SM35GEN->gener5 := aStam[25,2]
            SM35GEN->gener4 := aStam[12,3]
         CASE RECNO() == 38
            SM35GEN->gener5 := aStam[25,1]
         CASE RECNO() == 39
            SM35GEN->gener6 := aStam[51,1]
            SM35GEN->gener5 := aStam[25,3]
            SM35GEN->gener3 := aStam[06,2]
         CASE RECNO() == 40
            SM35GEN->gener3 := aStam[06,1]
         CASE RECNO() == 41
            SM35GEN->gener6 := aStam[52,1]
            SM35GEN->gener5 := aStam[26,2]
            SM35GEN->gener3 := aStam[06,3]
         CASE RECNO() == 42
            SM35GEN->gener5 := aStam[26,1]
         CASE RECNO() == 43
            SM35GEN->gener6 := aStam[53,1]
            SM35GEN->gener5 := aStam[26,3]
            SM35GEN->gener4 := aStam[13,2]
         CASE RECNO() == 44
            SM35GEN->gener4 := aStam[13,1]
         CASE RECNO() == 45
            SM35GEN->gener6 := aStam[54,1]
            SM35GEN->gener5 := aStam[27,2]
            SM35GEN->gener4 := aStam[13,3]
         CASE RECNO() == 46
            SM35GEN->gener5 := aStam[27,1]
         CASE RECNO() == 47
            SM35GEN->gener6 := aStam[55,1]
            SM35GEN->gener5 := aStam[27,3]
            SM35GEN->gener2 := aStam[03,2]
         CASE RECNO() == 48
            SM35GEN->gener2 := aStam[03,1]
         CASE RECNO() == 49
            SM35GEN->gener6 := aStam[56,1]
            SM35GEN->gener5 := aStam[28,2]
            SM35GEN->gener2 := aStam[03,3]
         CASE RECNO() == 50
            SM35GEN->gener5 := aStam[28,1]
         CASE RECNO() == 51
            SM35GEN->gener6 := aStam[57,1]
            SM35GEN->gener5 := aStam[28,3]
            SM35GEN->gener4 := aStam[14,2]
         CASE RECNO() == 52
            SM35GEN->gener4 := aStam[14,1]
         CASE RECNO() == 53
            SM35GEN->gener6 := aStam[58,1]
            SM35GEN->gener5 := aStam[29,2]
            SM35GEN->gener4 := aStam[14,3]
         CASE RECNO() == 54
            SM35GEN->gener5 := aStam[29,1]
         CASE RECNO() == 55
            SM35GEN->gener6 := aStam[59,1]
            SM35GEN->gener5 := aStam[29,3]
            SM35GEN->gener3 := aStam[07,2]
         CASE RECNO() == 56
            SM35GEN->gener3 := aStam[07,1]
         CASE RECNO() == 57
            SM35GEN->gener6 := aStam[60,1]
            SM35GEN->gener5 := aStam[30,2]
            SM35GEN->gener3 := aStam[07,3]
         CASE RECNO() == 58
            SM35GEN->gener5 := aStam[30,1]
         CASE RECNO() == 59
            SM35GEN->gener6 := aStam[61,1]
            SM35GEN->gener5 := aStam[30,3]
            SM35GEN->gener4 := aStam[15,2]
         CASE RECNO() == 60
            SM35GEN->gener4 := aStam[15,1]
         CASE RECNO() == 61
            SM35GEN->gener6 := aStam[62,1]
            SM35GEN->gener5 := aStam[31,2]
            SM35GEN->gener4 := aStam[15,3]
         CASE RECNO() == 62
            SM35GEN->gener5 := aStam[31,1]
         CASE RECNO() == 63
            SM35GEN->gener6 := aStam[63,1]
            SM35GEN->gener5 := aStam[31,2]
      ENDCASE

      DBSKIP()
   ENDDO

   DBGOTO(25)

RETURN NIL

/****************************************************************************/
STATIC FUNCTION fIdnr(cKeyp)

   //Funksie om id nommer te vra

   //Verklaar
   LOCAL cCscr := SAVESCREEN(0,0,24,79)
   LOCAL nBoxc := 0
   LOCAL cData := SPACE(12)
   LOCAL lRetu := TRUE

   //Waardes
   IF cKeyp == NIL
      cKeyp := SPACE(12)
   ELSE
      cKeyp := PADR(cKeyp,12)
      KEYBOARD CHR(K_RIGHT)
   ENDIF

   //Vorige nommer
   DBSELECTAREA("SM3DATA")

   //Vra die nommer
   nBoxc := fBoxCent( 12, SPACE(33), 1 )
   cData := sm3idnr(cKeyp,12,nBoxc)
   DBSELECTAREA("SM35GEN")

   DO CASE
      CASE LEFT(cData,9) == "CANCELLED"
         lRetu := FALSE
      CASE LEFT(cData, 3 ) == "NOT"
         lRetu := FALSE
      OTHERWISE
         fVul(cData)
   ENDCASE
   RESTSCREEN(0,0,24,79,cCscr)
RETURN lRetu

/****************************************************************************/
STATIC FUNCTION fFigure(nTop,nLeft,nBott,aRecs,cIdnr)

   //Funksie om die basiese inligting van 'n koei te wys

   //Verklaar
   LOCAL cCscr := SAVESCREEN(0,0,24,79)
   LOCAL i     := 1
   LOCAL nRow  := 1
   LOCAL nCol  := 1
   LOCAL cData := ""

   //Kyk of nommer iets in het
   IF cIdnr == NIL
      RETU NIL
   ENDIF

   //Kyk of nommer iets in het
   IF LEN(ALLTRIM(cIdnr)) == 0
      RETU NIL
   ENDIF

   //Databasis
   DBSELECTAREA("SM3DATA")

   IF ! SM3DATA->(DBSEEK(cIdnr))
      DBSELECTAREA("SM35GEN")
      RETU NIL
   ENDIF

   //Skerm
   IF cLanType() == "A"
      fBox(nTop+1,nLeft+1,maxrow()-3,77," STAMBOOM INLIGTING VAN " + cIdnr )
   ELSE
      fBox(nTop+1,nLeft+1,maxrow()-3,77," PEDIGREE INFORMATION FOR " + cIdnr )
   ENDIF

   //Waardes
   nRow := nTop+3
   nCol := nLeft+3

   //Veldname
   FOR i = 1 TO LEN(aRecs)

      IF i > ((maxrow()-4)-nTop+3)*2
      ELSE
         IF nRow >= maxrow()-4
            nRow := nTop+3
            nCol := nLeft + 40
         ENDIF
         @nRow,nCol SAY aRecs[i,6]
         SETCOLOR(cColInve())
         cData := aRecs[i,1] + aRecs[i,2]
         @nRow,nCol+21 SAY transform(&(cData),aRecs[i,10])
         SETCOLOR(cColNorm())
         nRow++
      ENDIF

   NEXT

   //Wag vir sleutel
   fScrBood(23)
   fScrWait(24)

   //Herstel
   DBSELECTAREA("SM35GEN")
   RESTSCREEN(0,0,24,79,cCscr)
RETURN NIL

/****************************************************************************/
STATIC FUNCTION fPrint(aRecs)

   //Verklaar
   LOCAL nTota := 0
   LOCAL lLoop := TRUE
   LOCAL nI    := 1
   LOCAL nBlad := 1
   LOCAL nReko := 1
   LOCAL cData := ""
   LOCAL aSens := {}
   LOCAL lRetu := TRUE
   LOCAL cIdnr := SPACE(12)
   LOCAL cText := ""
   LOCAL cSeek := ""
   LOCAL cPcod := cPrnCond()                     // Force condenced printing
   LOCAL nWidt := nPrnCwid()
   LOCAL nTopl := nPrnLine()
   LOCAL nPagl := nPrcLeng()
   LOCAL nPrnl := nPrcPrnl()
   LOCAL nMidc := nWidt - 29

   //Bepaal die drukgrootte
   // Condense Printing
   if nPrnLptp() < 8
      cPcod := cPrnCond()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      cPcod := cPrn8lpi()
      nPrnl := nPrcPrnl()
      nPagl := nPrcLeng()
   endif
   nMidc := nWidt - 29

   //Toets of drukker gereed is
   IF fPrnReady() == K_ESC
      RETURN FALSE
   ENDIF

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   DBSELECTAREA("SM35GEN")
   DBGOTO (32)
   cIdnr := SM35GEN->gener1
   DBGOTOP()

   //Tel aantal velde
   nTota := LASTREC()

   //Kry die velde wat gedruk moet word
   IF aRecs == NIL
      ASIZE(aSens,0)
      AADD(aSens,{"sm3data","reknr"     })
      //AADD(aSens,{"sm3data","kalfbnr"   })
      AADD(aSens,{"sm3data","generasie" })
      AADD(aSens,{"sm3data","gebdatum"  })
      AADD(aSens,{"sm3data","gebmassa"  })
      AADD(aSens,{"sm3data","gekeur"    })
      AADD(aSens,{"sm3data","uitkrede"  })
      AADD(aSens,{"sm3data","kalfaantal"})
      aRecs := fGetField(aSens)
   ENDIF

   FOR nI := 1 TO LEN(aRecs)
      AADD(aRecs[nI],0)                          //Add count for dam numeric fields
      AADD(aRecs[nI],0)                          //Add sum for dam numeric fields
      AADD(aRecs[nI],0)                          //Add count for sire numeric fields
      AADD(aRecs[nI],0)                          //Add sum for sire numeric fields
      aRecs[nI,FLD_COUN] := 0
      aRecs[nI,FLD_TOTA] := 0
   NEXT

   //Skerm
   IF cLanType() == "A"
      fScrbood(24,ALLTRIM(cIdnr)+" stamboom word gedruk!  [Esc]=Stop drukker.")
   ELSE
      fScrbood(24,ALLTRIM(cIdnr)+" pedigree being printed!  [Esc]=Stop printer.")
   ENDIF

   // Switch printer on
   fPrnOn()

   //Doen die loop
   lLoop := TRUE
   DO WHILE lLoop

      //Skakel die drukker aan
      //fPrnOn()

      //Opskrifte
      IF PROW() = 0

         fPrnCod( cPcod )
         // fPrnCod(cPrn8lpi())

         IF cLanType() == "A"
            @PROW()+nTopl, 1 SAY upper( cGebNaam() )
            //@PROW()  , nMidc SAY "             Verslag: " + cOption()
            //@PROW()+1,     1 SAY substr(cTotNaam(),  1,40)
            //@PROW()  , nMidc SAY "               Datum: " + dtoc( dAppDate() )
            //@PROW()+1,     1 SAY substr(cTotNaam(), 41,40)
            //@PROW()  , nMidc SAY "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            //@PROW()+1,     1 SAY substr(cTotNaam(), 81,40)
            //@PROW()  , nMidc SAY "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
            //@PROW()+1,     1 SAY substr(cTotNaam(),121, 4)
            cText := "Uitgebreide stamboom van "+ALLTRIM(cIdnr)
            @PROW()  ,nWidt-LEN(cText)+1 SAY cText
         ELSE
            @PROW()+nTopl, 1 SAY upper( cGebNaam() )
            //@PROW()  , nMidc SAY "              Report: " + cOption()
            //@PROW()+1,     1 SAY substr(cTotNaam(),  1,40)
            //@PROW()  , nMidc SAY "                Date: " + dtoc( dAppDate() )
            //@PROW()+1,     1 SAY substr(cTotNaam(), 41,40)
            //@PROW()  , nMidc SAY "                Page: " + ltrim( str( nBlad, 8 ) )
            //@PROW()+1,     1 SAY substr(cTotNaam(), 81,40)
            //@PROW()  , nMidc SAY "    Herd Designation: " + substr(cTotNaam(),125,4)
            //@PROW()+1,     1 SAY substr(cTotNaam(),121, 4)
            cText := "Extended pedigree for "+ALLTRIM(cIdnr)
            @PROW()  ,nWidt-LEN(cText)+1 SAY cText
         ENDIF
         @PROW()+1,  1 SAY REPLICATE( "=",  nWidt )

         //1e Lyn van opskrif
         cData := SPACE(90)
         FOR nI = 1 TO LEN( aRecs )
            cData+= PADR( ALLTRIM( aRecs[nI,FLD_HED1] ), aRecs[nI,FLD_LENG] ) + " "
         NEXT
         @PROW()+1,1 SAY PADR(cData, nWidt)

         //2e Lyn van opskrif
         cData := SPACE(90)
         FOR nI = 1 TO LEN( aRecs )
            cData := cData + PADR( ALLTRIM( aRecs[nI,FLD_HED2] ), aRecs[nI,FLD_LENG] ) + " "
         NEXT
         @PROW()+1,1 SAY PADR(cData, nWidt)

         //3e Lyn van opskrif
         IF cLanType() == "A"
            cData := LEFT("Stamboom"+SPACE(90),90)
         ELSE
            cData := LEFT("Pedigree"+SPACE(90),90)
         ENDIF
         FOR nI = 1 TO LEN( aRecs )
            cData := cData + PADR( ALLTRIM( aRecs[nI,FLD_HED3] ), aRecs[nI,FLD_LENG] ) + " "
         NEXT
         @PROW()+1,1 SAY PADR(cData, nWidt)

         //4e Lyn van opskrif
         cData := REPLICATE("=",87) + SPACE(3)
         FOR nI = 1 TO LEN( aRecs )
            cData := cData + REPLICATE("=",aRecs[nI,FLD_LENG]) + " "
         NEXT
         @PROW()+1,1 SAY PADR(cData, nWidt)
      ENDIF

      //Toets of drukker moet stop
      IF fPrnStop() = K_ESC
         lLoop := FALSE
         lRetu := FALSE
         exit
      ENDIF

      //Data
      cData := ""
      DO CASE
         CASE SM35GEN->(RECNO()) == 1
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 2
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 3
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 4
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 5
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 6
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 7
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 8
            cData := SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener3 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener3
         CASE SM35GEN->(RECNO()) == 9
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 10
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 11
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 12
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 13
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 14
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 15
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 16
            cData := SPACE(12)       + " |-" + SM35GEN->gener2 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener2
         CASE SM35GEN->(RECNO()) == 17
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6+"   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 18
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 19
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 20
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 21
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 22
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 23
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 24
            cData := SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener3 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener3
         CASE SM35GEN->(RECNO()) == 25
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 26
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 27
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 28
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 29
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 30
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 31
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 32
            cData := SM35GEN->gener1 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener1
         CASE SM35GEN->(RECNO()) == 33
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6+"   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 34
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 35
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 36
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 37
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 38
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 39
            cData := SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 40
            cData := SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener3 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener3
         CASE SM35GEN->(RECNO()) == 41
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 42
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 43
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 44
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 45
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 46
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 47
            cData := SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 48
            cData := SPACE(12)       + " |-" + SM35GEN->gener2 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener2
         CASE SM35GEN->(RECNO()) == 49
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6+"   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 50
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 51
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 52
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 53
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 54
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 55
            cData := SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 56
            cData := SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener3 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener3
         CASE SM35GEN->(RECNO()) == 57
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 58
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 59
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 60
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener4 + "-| " + SPACE(12)       + "   " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener4
         CASE SM35GEN->(RECNO()) == 61
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " | " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
         CASE SM35GEN->(RECNO()) == 62
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener5 + "-| " + SPACE(12)       + "   "
            cSeek := SM35GEN->gener5
         CASE SM35GEN->(RECNO()) == 63
            cData := SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + "   " + SPACE(12)       + " |-" + SM35GEN->gener6 + "   "
            cSeek := SM35GEN->gener6
      ENDCASE

      //Data
      IF ! EMPTY(cSeek)
         DBSELECTAREA("SM3DATA")

         IF SM3DATA->(DBSEEK(cSeek))
            FOR nI = 1 TO LEN( aRecs )
               //Kies die regte leer
               cText := aRecs[nI,DBF_NAME]
               cText := strtran(cText,"->")
               cText := ALLTRIM(cText)
               SELECT SELECT(cText)

               DO CASE
                  CASE aRecs[nI,FLD_TYPE] == "C" //Character
                     cData+= fieldget(aRecs[nI,FLD_NUMB]) + " "
                  CASE aRecs[nI,FLD_TYPE] == "N" //Numeric
                     cData+= str(  fieldget(aRecs[nI,FLD_NUMB])  ,aRecs[nI,FLD_LENG],aRecs[nI,FLD_DECI]) + " "
                     IF fieldget(aRecs[nI,FLD_NUMB]) != 0
                        aRecs[nI,FLD_COUN]++
                        aRecs[nI,FLD_TOTA] += fieldget(aRecs[nI,FLD_NUMB])
                        IF SM35GEN->(RECNO()) < 32
                           aRecs[nI,16]++
                           aRecs[nI,17] += fieldget(aRecs[nI,FLD_NUMB])
                        ELSEIF SM35GEN->(RECNO())  > 32
                           aRecs[nI,18]++
                           aRecs[nI,19] += fieldget(aRecs[nI,FLD_NUMB])
                        ENDIF
                     ENDIF

                  CASE aRecs[nI,FLD_TYPE] == "D" //Date
                     cData+= dtoc(  fieldget(aRecs[nI,FLD_NUMB])  ) + " "
                  OTHERWISE
                     //Nie een van bogenoemde
                     cData+= SPACE(aRecs[nI,FLD_LENG])+" "
               ENDCASE
               DBSELECTAREA("SM35GEN")
            NEXT
         ENDIF
      ENDIF

      DBSELECTAREA("SM35GEN")
      @PROW()+1,1 SAY PADR(cData, nWidt)

      //Skerm
      // fPrnOff()
      // IF nTota > 0
      //    SETCOLOR( cColBott() )
      //    IF cLanType() == "A"
      //       @ 23, 30 SAY fPercent(nReko/nTota)+"% Voltooi"
      //    ELSE
      //       @ 23, 30 SAY fPercent(nReko/nTota)+"% Completed"
      //    ENDIF
      //    SETCOLOR( cColNorm() )
      //    nReko++
      // ENDIF
      // fPrnOn()

      //Volgende rekord
      DBSKIP()

      //Toets vir einde van bladsy
      IF EOF()
         //Print onderste lyn
         @PROW()+1,  1 SAY REPLICATE( "-",  nWidt )
         cData := PADR("Sire Average",90," ")

         FOR nI = 1 TO LEN( aRecs )
            DO CASE
               CASE aRecs[nI,FLD_TYPE] == "N"    //Numeric
                  IF aRecs[nI,16] != 0
                     cData+= str( (aRecs[nI,17] / aRecs[nI,16])  ,aRecs[nI,FLD_LENG],aRecs[nI,FLD_DECI]) + " "
                  ELSE
                     cData+= SPACE(aRecs[nI,FLD_LENG])+" "
                  ENDIF

               OTHERWISE
                  //Nie een van bogenoemde
                  cData+= SPACE(aRecs[nI,FLD_LENG])+" "
            ENDCASE
         NEXT

         @PROW()+1,1 SAY PADR(cData, nWidt)
         cData := PADR("Dam Average",90," ")

         FOR nI = 1 TO LEN( aRecs )
            DO CASE
               CASE aRecs[nI,FLD_TYPE] == "N"    //Numeric
                  IF aRecs[nI,18] != 0
                     cData+= str( (aRecs[nI,19] / aRecs[nI,18])  ,aRecs[nI,FLD_LENG],aRecs[nI,FLD_DECI]) + " "
                  ELSE
                     cData+= SPACE(aRecs[nI,FLD_LENG])+" "
                  ENDIF

               OTHERWISE
                  //Nie een van bogenoemde
                  cData+= SPACE(aRecs[nI,FLD_LENG])+" "
            ENDCASE
         NEXT

         @PROW()+1,1 SAY PADR(cData, nWidt)
         cData := PADR("Average",90," ")

         FOR nI = 1 TO LEN( aRecs )
            DO CASE
               CASE aRecs[nI,FLD_TYPE] == "N"    //Numeric

                  IF aRecs[nI,FLD_COUN] != 0
                     cData+= str( (aRecs[nI,FLD_TOTA] / aRecs[nI,FLD_COUN])  ,aRecs[nI,FLD_LENG],aRecs[nI,FLD_DECI]) + " "
                  ELSE
                     cData+= SPACE(aRecs[nI,FLD_LENG])+" "
                  ENDIF

               OTHERWISE

                  //Nie een van bogenoemde
                  cData+= SPACE(aRecs[nI,FLD_LENG])+" "

            ENDCASE

         NEXT

         @PROW()+1,1 SAY PADR(cData, nWidt)
         @PROW()+1,  1 SAY REPLICATE( "=",  nWidt )
         @PROW()+1,  1 SAY cAppName()
         // @PROW()+(nPagl-3-PROW()),nWidt-LEN(TRIM(cIdnr)) SAY TRIM(cIdnr)
         @PROW() ,nWidt-LEN(TRIM(cIdnr)) SAY TRIM(cIdnr)
         fPrnEjec(nPrcLeng())
         //fPrnCod(cPrn6lpi())
         //SETPRC( 0, 0 )
         // fPrnOff()
         nBlad++
         lLoop := FALSE
      ENDIF

   ENDDO

   fPrnOff()

   //Herstel
   DBGOTO (32)

RETURN lRetu

