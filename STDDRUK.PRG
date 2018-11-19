//STDDRUK.PRG
//Program om drukkerkodes te verander
//Kopiereg (c) 1991 A van Rensburg
//22:19 09 Sep,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

#define APRTYPE 1
#define APRLPTP 2
#define APRINIT 3
#define APRNLIN 4
#define APRNPRL 5
#define APRNPAL 6
#define APRNWID 7
#define APRNCC  8
#define APRCLIN 9
#define APRCPRL 10
#define APRCPAL 11
#define APRCWID 12
#define APRCCC  13

/******************************************************************************/
FUNCTION stddruk

   LOCAL nCh    := 1
   LOCAL aCscr  := {}

   IF cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   ELSE
      fScrOpsk( 1, "Option "+cOption())
   ENDIF

   DO WHILE TRUE
      //Sluit alle .dbf leers
      dbcloseall()

      // Vertoon hulpskerm
      IF cLanType() == "A"
         fScrBood( MAXROW()-1, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Hoofmenu." )
      ELSE
         fScrBood( MAXROW()-1, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Main menu." )
      ENDIF

      // Kry opsienommer
      nCh := fNewMenu( nCh, "STDDRUK" )
      cOption(nCh)
      aCscr := fASaveScr()

      DO CASE
         CASE nCh = 1
            //Select a Printer
            sm3druk()

         CASE nCh = 2
            //Define Printer codes
            sm3code()

         CASE nCh = 3
            //Reset Printer codes
            sm3rest()

         CASE nCh = 4
            //Determine Page length
            sm3plen()

         OTHERWISE
            // Exit to hoofmenu
            cOption(-1)
            exit

      ENDCASE

      //Herstel menu
      fARestScr(aCscr)
      cOption(-1)
   ENDDO

RETURN NIL

/******************************************************************************/
STATIC FUNCTION sm3druk

   LOCAL nCh    := 1
   LOCAL aCdbf  := fATopen()

   IF cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   ELSE
      fScrOpsk( 1, "Option "+cOption())
   ENDIF

   BEGIN SEQUENCE
      // Vertoon hulpskerm
      IF cLanType() == "A"
         fScrBood( MAXROW()-1, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Hoofmenu." )
      ELSE
         fScrBood( MAXROW()-1, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Main menu." )
      ENDIF

      // Open drives file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      // Open Printers file
      aCdbf := fATopen(aCdbf,cDd(),"STDDRUK")
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      DBSELECTAREA("STDWAAR")
      DBGOTOP()

      IF ALLTRIM(STDWAAR->prtype) == "MATRIX"
         nCh := 1
      ELSE
         nCh := 2
      ENDIF

      // Kry opsienommer
      nCh := fNewMenu( nCh, "STDPRNT" )

      IF cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption(nCh))
      ELSE
         fScrOpsk( , "Option "+cOption(nCh))
      ENDIF

      DO CASE
         CASE nCh = 1
            //Select a Dot Matrix Printer
            IF cLanType() == "A"
               fScrBood(MAXROW(),"Stel Mosaiekdrukker kodes")
            ELSE
               fScrBood(MAXROW(),"Set Dot Matrix printer codes")
            ENDIF

            DBSELECTAREA("STDDRUK")
            DBGOTOP()

            DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "MATRIX"
               DBSKIP()
            ENDDO

            IF EOF()
               IF cLanType() == "A"
                  fScrWait(MAXROW(),"Daar is nie kodes vir 'n Mosaiekdrukker nie")
               ELSE
                  fScrWait(MAXROW(),"There is not Dot Matrix printer codes")
               ENDIF

               BREAK
            ENDIF

            DBSELECTAREA("STDWAAR")
            DBGOTOP()
            DO WHILE ! RLOCK()
            ENDDO
            STDWAAR->prtype := cPrnType(ALLTRIM(STDDRUK->prtype))
            STDWAAR->prlptp := nPrnLptp(STDDRUK->prlptp)
            STDWAAR->prinit := cPrnInit(ALLTRIM(STDDRUK->prinit))
            STDWAAR->prline := nPrnLine(STDDRUK->prnlin)
            STDWAAR->prprnl := nPrnPrnl(STDDRUK->prnprl)
            STDWAAR->prleng := nPrnLeng(STDDRUK->prnpal)
            STDWAAR->prwidt := nPrnWidt(STDDRUK->prnwid)
            STDWAAR->prnorm := cPrnNorm(ALLTRIM(STDDRUK->prncc))
            STDWAAR->prclin := nPrnLine(STDDRUK->prclin)
            STDWAAR->prcprl := nPrcPrnl(STDDRUK->prcprl)
            STDWAAR->prcpal := nPrcLeng(STDDRUK->prcpal)
            STDWAAR->prcwid := nPrnWidt(STDDRUK->prcwid)
            STDWAAR->prcond := cPrnCond(ALLTRIM(STDDRUK->prccc))
            DBCOMMIT()

            BREAK

         CASE nCh = 2
            //Select Laser Printer
            IF cLanType() == "A"
               fScrBood(MAXROW(),"Stel Laser printer kodes")
            ELSE
               fScrBood(MAXROW(),"Set Laser printer codes")
            ENDIF

            DBSELECTAREA("STDDRUK")
            DBGOTOP()

            DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "LAZER"
               DBSKIP()
            ENDDO

            IF EOF()
               IF cLanType() == "A"
                  fScrWait(MAXROW(),"Daar is nie kodes vir 'n Laser' drukker nie")
               ELSE
                  fScrWait(MAXROW(),"There is not Laser printer codes")
               ENDIF

               BREAK
            ENDIF

            DBSELECTAREA("STDWAAR")
            DBGOTOP()
            DO WHILE ! RLOCK()
            ENDDO
            STDWAAR->prtype := cPrnType(ALLTRIM(STDDRUK->prtype))
            STDWAAR->prlptp := nPrnLptp(STDDRUK->prlptp)
            STDWAAR->prinit := cPrnInit(ALLTRIM(STDDRUK->prinit))

            STDWAAR->prline := nPrnLine(STDDRUK->prnlin)
            STDWAAR->prprnl := nPrnPrnl(STDDRUK->prnprl)
            STDWAAR->prleng := nPrnLeng(STDDRUK->prnpal)
            STDWAAR->prwidt := nPrnWidt(STDDRUK->prnwid)
            STDWAAR->prnorm := cPrnNorm(ALLTRIM(STDDRUK->prncc))

            STDWAAR->prclin := nPrnLine(STDDRUK->prclin)
            STDWAAR->prcprl := nPrcPrnl(STDDRUK->prcprl)
            STDWAAR->prcpal := nPrcLeng(STDDRUK->prcpal)
            STDWAAR->prcwid := nPrnWidt(STDDRUK->prcwid)
            STDWAAR->prcond := cPrnCond(ALLTRIM(STDDRUK->prccc))
            DBCOMMIT()

            BREAK

         OTHERWISE
            // Exit
            BREAK

      ENDCASE

   END

   //Herstel
   fATclose(aCdbf)
   cOption(-1)

RETURN NIL

/******************************************************************************/
STATIC FUNCTION sm3code

   //Veranderlikes
   LOCAL lMod     := FALSE
   LOCAL cBood    := ""
   LOCAL nBoxCoor := 0
   LOCAL aCdbf    := fATopen()
   LOCAL getlist  := {}
   LOCAL aMatrix  := {"MATRIX",;
      1,;                                        // Port
      PADR("chr(27)+'@'",50," "),;               // Initialize printer
      2,;                                        // Start Line Number
      58,;                                       // Print Length
      64,;                                       // Page Length
      77,;                                       // Print Width
      PADR("chr(27)+chr(18)+chr(27)+'2'",80," "),; // Normal Print Code
      2,;                                        // Start Line Number
      79,;                                       // Print Length
      85,;                                       // Page Length
      129,;                                      // Print Width
      PADR("chr(27)+chr(15)+chr(27)+'0'",80," ")}// Condense Print Code
   LOCAL aLazer   := {"LAZER ",;
      1,;                                        // Port
      PADR("chr(27)+'E'+chr(27)+'&l26A'",50," "),; // Initialize printer + 'A4'
      2,;                                        // Start Line Number
      58,;                                       // Print Length
      64,;                                       // Page Length
      77,;                                       // Print Width
      PADR("chr(27)+'&k0S'+chr(27)+'&l6D'",80," "),; // Normal Print Code
      2,;                                        // Start Line Number
      79,;                                       // Print Length
      85,;                                       // Page Length
      129,;                                      // Print Width
      PADR("chr(27)+'&k2S'+chr(27)+'&l8D'",80," ")} // Condense Print Code

   IF cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   ELSE
      fScrOpsk( , "Option "+cOption())
   ENDIF

   BEGIN SEQUENCE
      // Open drives file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      // Open Printers file
      aCdbf := fATopen(aCdbf,cDd(),"STDDRUK")
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      DBSELECTAREA("STDDRUK")
      DBGOTOP()

      DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "MATRIX"
         DBSKIP()
      ENDDO

      IF EOF()
         DBAPPEND()
         STDDRUK->prtype := aMatrix[APRTYPE]
         STDDRUK->prlptp := aMatrix[APRLPTP]
         STDDRUK->prinit := aMatrix[APRINIT]
         STDDRUK->prnlin := aMatrix[APRNLIN]
         STDDRUK->prnprl := aMatrix[APRNPRL]
         STDDRUK->prnpal := aMatrix[APRNPAL]
         STDDRUK->prnwid := aMatrix[APRNWID]
         STDDRUK->prncc  := aMatrix[APRNCC]
         STDDRUK->prclin := aMatrix[APRCLIN]
         STDDRUK->prcprl := aMatrix[APRCPRL]
         STDDRUK->prcpal := aMatrix[APRCPAL]
         STDDRUK->prcwid := aMatrix[APRCWID]
         STDDRUK->prccc  := aMatrix[APRCCC]
      ELSE
         aMatrix[APRLPTP] := STDDRUK->prlptp
         aMatrix[APRNLIN] := STDDRUK->prnlin
         aMatrix[APRNPRL] := STDDRUK->prnprl
         aMatrix[APRINIT] := STDDRUK->prinit
         aMatrix[APRNPAL] := STDDRUK->prnpal
         aMatrix[APRNWID] := STDDRUK->prnwid
         aMatrix[APRNCC]  := STDDRUK->prncc
         aMatrix[APRCLIN] := STDDRUK->prclin
         aMatrix[APRCPRL] := STDDRUK->prcprl
         aMatrix[APRCPAL] := STDDRUK->prcpal
         aMatrix[APRCWID] := STDDRUK->prcwid
         aMatrix[APRCCC]  := STDDRUK->prccc
      ENDIF

      DBGOTOP()

      DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "LAZER"
         DBSKIP()
      ENDDO

      IF EOF()
         DBAPPEND()
         STDDRUK->prtype := aLazer[APRTYPE]
         STDDRUK->prlptp := aLazer[APRLPTP]
         STDDRUK->prinit := aLazer[APRINIT]
         STDDRUK->prnlin := aLazer[APRNLIN]
         STDDRUK->prnprl := aLazer[APRNPRL]
         STDDRUK->prnpal := aLazer[APRNPAL]
         STDDRUK->prnwid := aLazer[APRNWID]
         STDDRUK->prncc  := aLazer[APRNCC]
         STDDRUK->prclin := aLazer[APRCLIN]
         STDDRUK->prcprl := aLazer[APRCPRL]
         STDDRUK->prcpal := aLazer[APRCPAL]
         STDDRUK->prcwid := aLazer[APRCWID]
         STDDRUK->prccc  := aLazer[APRCCC]
      ELSE
         aLazer[APRLPTP] := STDDRUK->prlptp
         aLazer[APRNLIN] := STDDRUK->prnlin
         aLazer[APRNPRL] := STDDRUK->prnprl
         aLazer[APRINIT] := STDDRUK->prinit
         aLazer[APRNPAL] := STDDRUK->prnpal
         aLazer[APRNWID] := STDDRUK->prnwid
         aLazer[APRNCC]  := STDDRUK->prncc
         aLazer[APRCLIN] := STDDRUK->prclin
         aLazer[APRCPRL] := STDDRUK->prcprl
         aLazer[APRCPAL] := STDDRUK->prcpal
         aLazer[APRCWID] := STDDRUK->prcwid
         aLazer[APRCCC]  := STDDRUK->prccc
      ENDIF

      IF cLanType() == "A"
         cBood := "Verander Mosaiekdrukker kodes"
      ELSE
         cBood := "Modify Dot Matrix printer codes"
      ENDIF

      IF fJaNee(MAXROW(),cBood,,TRUE )
         //Loop - Dot Matrix
         DO WHILE TRUE
            // Vra die drukkerkodes
            fScrBood( MAXROW()-1 )
            IF cLanType() == "A"
               fScrBood( MAXROW(), "Tik die Mosaiekdrukkerkodes... 'Esc' = Kanselleer" )
               nBoxCoor := fBoxCent(5, space(68), 16, "MOSAIEKDRUKKERKODES" )
            ELSE
               fScrBood( MAXROW(), "Type the Dot Matrix Printer codes... 'Esc' = Quit" )
               nBoxCoor := fBoxCent(5, space(70), 16, "DOT MATRIX PRINTER CODES" )
            ENDIF
            SETCOLOR(cColNorm())

            IF cLanType() == "A"
               @ 06, nBoxCoor say "                Drukkerpoort" get aMatrix[APRLPTP] pict "@K 9" VALID(fVPoort(aMatrix))
               @ 07, nBoxCoor say "     Drukker aanvoor kode(s)" get aMatrix[APRINIT] pict "@KS40"
               @ 09, nBoxCoor say "Normale druk begin lynnommer" get aMatrix[APRNLIN] pict "@K 999"
               @ 10, nBoxCoor say "     Normale druk druklengte" get aMatrix[APRNPRL] pict "@K 999"
               @ 11, nBoxCoor say "   Normale druk papierlengte" get aMatrix[APRNPAL] pict "@K 999" VALID(fVNLeng(aMatrix))
               @ 12, nBoxCoor say "     Normale druk druk wydte" get aMatrix[APRNWID] pict "@K 999"
               @ 13, nBoxCoor say "           Normale druk kode" get aMatrix[APRNCC]  pict "@KS40" VALID(fVKode(aMatrix[APRNCC]))
               @ 15, nBoxCoor say "  Klein druk begin lynnommer" get aMatrix[APRCLIN] pict "@K 999"
               @ 16, nBoxCoor say "       Klein druk druklengte" get aMatrix[APRCPRL] pict "@K 999"
               @ 17, nBoxCoor say "     Klein druk papierlengte" get aMatrix[APRCPAL] pict "@K 999" VALID(fVCLeng(aMatrix))
               @ 18, nBoxCoor say "       Klein druk druk wydte" get aMatrix[APRCWID] pict "@K 999"
               @ 19, nBoxCoor say "             Klein druk kode" get aMatrix[APRCCC]  pict "@KS40" VALID(fVKode(aMatrix[APRCCC]))
            ELSE
               @ 06, nBoxCoor say "                  Printer port" get aMatrix[APRLPTP] pict "@K 9" VALID(fVPoort(aMatrix))
               @ 07, nBoxCoor say "    Printer initialize code(s)" get aMatrix[APRINIT] pict "@KS40"
               @ 09, nBoxCoor say "Normal print start line number" get aMatrix[APRNLIN] pict "@K 999"
               @ 10, nBoxCoor say "     Normal print print length" get aMatrix[APRNPRL] pict "@K 999"
               @ 11, nBoxCoor say "     Normal print paper length" get aMatrix[APRNPAL] pict "@K 999" VALID(fVNLeng(aMatrix))
               @ 12, nBoxCoor say "      Normal print print width" get aMatrix[APRNWID] pict "@K 999"
               @ 13, nBoxCoor say "             Normal print code" get aMatrix[APRNCC]  pict "@KS40" VALID(fVKode(aMatrix[APRNCC]))
               @ 15, nBoxCoor say "Condense prt start line number" get aMatrix[APRCLIN] pict "@K 999"
               @ 16, nBoxCoor say "   Condense print print length" get aMatrix[APRCPRL] pict "@K 999"
               @ 17, nBoxCoor say "   Condense print paper length" get aMatrix[APRCPAL] pict "@K 999" VALID(fVCLeng(aMatrix))
               @ 18, nBoxCoor say "    Condense print print width" get aMatrix[APRCWID] pict "@K 999"
               @ 19, nBoxCoor say "           Condense print code" get aMatrix[APRCCC]  pict "@KS40" VALID(fVKode(aMatrix[APRCCC]))
            ENDIF
            SET(_SET_CURSOR,1)
            READ
            SET(_SET_CURSOR,0)

            IF LASTKEY() == K_ESC
               EXIT
            ENDIF

            IF cLanType() == "A"
               cBood := "Aanvaar Mosaiekdrukker kodes"
            ELSE
               cBood := "Accept Dot Matrix printer codes"
            ENDIF

            IF fJaNee(MAXROW(),cBood,,TRUE )
               DBSELECTAREA("STDDRUK")
               DBGOTOP()

               DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "MATRIX"
                  DBSKIP()
               ENDDO

               IF EOF()
                  DBAPPEND()
                  STDDRUK->prtype := aMatrix[APRTYPE]
               ENDIF

               DO WHILE ! RLOCK()
               ENDDO
               STDDRUK->prlptp := aMatrix[APRLPTP]
               STDDRUK->prnlin := aMatrix[APRNLIN]
               STDDRUK->prnprl := aMatrix[APRNPRL]
               STDDRUK->prinit := aMatrix[APRINIT]
               STDDRUK->prnpal := aMatrix[APRNPAL]
               STDDRUK->prnwid := aMatrix[APRNWID]
               STDDRUK->prncc  := aMatrix[APRNCC]
               STDDRUK->prclin := aMatrix[APRCLIN]
               STDDRUK->prcprl := aMatrix[APRCPRL]
               STDDRUK->prcpal := aMatrix[APRCPAL]
               STDDRUK->prcwid := aMatrix[APRCWID]
               STDDRUK->prccc  := aMatrix[APRCCC]
               DBCOMMIT()
               lMod := TRUE
               EXIT
            ENDIF
         ENDDO
      ENDIF

      IF cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
         cBood := "Verander Laser drukker kodes"
      ELSE
         fScrOpsk( , "Option "+cOption())
         cBood := "Modify Laser printer codes"
      ENDIF

      IF fJaNee(MAXROW(),cBood,,TRUE )
         //Loop - Lazer
         DO WHILE TRUE

            // Vra die drukkerkodes
            fScrBood( MAXROW()-1 )
            IF cLanType() == "A"
               fScrBood( MAXROW(), "Tik die Laser Drukkerkodes... 'Esc' = Kanselleer" )
               nBoxCoor := fBoxCent(5, space(68), 15, "LASER DRUKKERKODES" )
            ELSE
               fScrBood( MAXROW(), "Type the Laser Printer codes... 'Esc' = Quit" )
               nBoxCoor := fBoxCent(5, space(70), 15, "LASER PRINTER CODES" )
            ENDIF
            SETCOLOR(cColNorm())

            IF cLanType() == "A"
               @ 06, nBoxCoor say "                Drukkerpoort" get aLazer[APRLPTP] pict "@K 9" VALID(fVPoort(aLazer))
               @ 07, nBoxCoor say "     Drukker aanvoor kode(s)" get aLazer[APRINIT] pict "@KS40"
               @ 09, nBoxCoor say "Normale druk begin lynnommer" get aLazer[APRNLIN] pict "@K 999"
               @ 10, nBoxCoor say "     Normale druk druklengte" get aLazer[APRNPRL] pict "@K 999"
               @ 11, nBoxCoor say "   Normale druk papierlengte" get aLazer[APRNPAL] pict "@K 999" VALID(fVNLeng(aLazer))
               @ 12, nBoxCoor say "     Normale druk druk wydte" get aLazer[APRNWID] pict "@K 999"
               @ 13, nBoxCoor say "           Normale druk kode" get aLazer[APRNCC]  pict "@KS40" VALID(fVKode(aLazer[APRNCC]))
               @ 15, nBoxCoor say "  Klein druk begin lynnommer" get aLazer[APRCLIN] pict "@K 999"
               @ 16, nBoxCoor say "       Klein druk druklengte" get aLazer[APRCPRL] pict "@K 999"
               @ 17, nBoxCoor say "     Klein druk papierlengte" get aLazer[APRCPAL] pict "@K 999" VALID(fVCLeng(aLazer))
               @ 18, nBoxCoor say "       Klein druk druk wydte" get aLazer[APRCWID] pict "@K 999"
               @ 19, nBoxCoor say "             Klein druk kode" get aLazer[APRCCC]  pict "@KS40" VALID(fVKode(aLazer[APRCCC]))
            ELSE
               @ 06, nBoxCoor say "                  Printer port" get aLazer[APRLPTP] pict "@K 9" VALID(fVPoort(aLazer))
               @ 07, nBoxCoor say "    Printer initialize code(s)" get aLazer[APRINIT] pict "@KS40"
               @ 09, nBoxCoor say "Normal print start line number" get aLazer[APRNLIN] pict "@K 999"
               @ 10, nBoxCoor say "     Normal print print length" get aLazer[APRNPRL] pict "@K 999"
               @ 11, nBoxCoor say "     Normal print paper length" get aLazer[APRNPAL] pict "@K 999" VALID(fVNLeng(aLazer))
               @ 12, nBoxCoor say "      Normal print print width" get aLazer[APRNWID] pict "@K 999"
               @ 13, nBoxCoor say "             Normal print code" get aLazer[APRNCC]  pict "@KS40" VALID(fVKode(aLazer[APRNCC]))
               @ 15, nBoxCoor say "Condense prt start line number" get aLazer[APRCLIN] pict "@K 999"
               @ 16, nBoxCoor say "   Condense print print length" get aLazer[APRCPRL] pict "@K 999"
               @ 17, nBoxCoor say "   Condense print paper length" get aLazer[APRCPAL] pict "@K 999" VALID(fVCLeng(aLazer))
               @ 18, nBoxCoor say "    Condense print print width" get aLazer[APRCWID] pict "@K 999"
               @ 19, nBoxCoor say "           Condense print code" get aLazer[APRCCC]  pict "@KS40" VALID(fVKode(aLazer[APRCCC]))
            ENDIF
            SET(_SET_CURSOR,1)
            READ
            SET(_SET_CURSOR,0)

            IF LASTKEY() == K_ESC
               EXIT
            ENDIF

            IF cLanType() == "A"
               cBood := "Aanvaar Laser drukker kodes"
            ELSE
               cBood := "Accept Laser printer codes"
            ENDIF

            IF fJaNee(MAXROW(),cBood,,TRUE )
               DBSELECTAREA("STDDRUK")
               DBGOTOP()

               DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "LAZER"
                  DBSKIP()
               ENDDO

               IF EOF()
                  DBAPPEND()
                  STDDRUK->prtype := aLazer[APRTYPE]
               ENDIF

               DO WHILE ! RLOCK()
               ENDDO
               STDDRUK->prlptp := aLazer[APRLPTP]
               STDDRUK->prnlin := aLazer[APRNLIN]
               STDDRUK->prnprl := aLazer[APRNPRL]
               STDDRUK->prinit := aLazer[APRINIT]
               STDDRUK->prnpal := aLazer[APRNPAL]
               STDDRUK->prnwid := aLazer[APRNWID]
               STDDRUK->prncc  := aLazer[APRNCC]
               STDDRUK->prclin := aLazer[APRCLIN]
               STDDRUK->prcprl := aLazer[APRCPRL]
               STDDRUK->prcpal := aLazer[APRCPAL]
               STDDRUK->prcwid := aLazer[APRCWID]
               STDDRUK->prccc  := aLazer[APRCCC]
               DBCOMMIT()
               lMod := TRUE
               EXIT
            ENDIF
         ENDDO
      ENDIF

      IF lMod
         IF cLanType() == "A"
            fScrOpsk( , "Opsie "+cOption())
         ELSE
            fScrOpsk( , "Option "+cOption())
         ENDIF

         //Select a Printer
         sm3druk()
      ENDIF

      BREAK
   END

   //Reset
   fATclose(aCdbf)

RETURN NIL

/******************************************************************************/
STATIC FUNCTION sm3rest

   LOCAL nCh    := 1
   LOCAL aCdbf  := fATopen()

   IF cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   ELSE
      fScrOpsk( , "Option "+cOption())
   ENDIF

   fScrBood( MAXROW()-1 )
   IF cLanType() == "A"
      fScrBood( MAXROW(), "Herstel Drukkerkodes met verstek waardes" )
   ELSE
      fScrBood( MAXROW(), "Reset Printer codes with default values" )
   ENDIF

   BEGIN SEQUENCE
      // Delete STDDRUK.DBF if does exist
      if file(cDd()+"STDDRUK.DBF")
         FERASE(cDd()+"STDDRUK.DBF")
      ENDIF

      // Copy default printer file
      COPY FILE STDDRUK.tdb TO (cDd()+"STDDRUK.DBF")

      // Open drives file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      DBSELECTAREA("STDWAAR")
      DBGOTOP()

      // Open Printers file
      aCdbf := fATopen(aCdbf,cDd(),"STDDRUK")
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      DBSELECTAREA("STDDRUK")
      DBGOTOP()

      DO WHILE ! EOF() .AND. ALLTRIM(STDDRUK->prtype) != "MATRIX"
         DBSKIP()
      ENDDO

      IF ! EOF()
         DBSELECTAREA("STDWAAR")
         DO WHILE ! RLOCK()
         ENDDO
         STDWAAR->prtype := cPrnType(ALLTRIM(STDDRUK->prtype))
         STDWAAR->prlptp := nPrnLptp(STDDRUK->prlptp)
         STDWAAR->prinit := cPrnInit(ALLTRIM(STDDRUK->prinit))

         STDWAAR->prline := nPrnLine(STDDRUK->prnlin)
         STDWAAR->prprnl := nPrnPrnl(STDDRUK->prnprl)
         STDWAAR->prleng := nPrnLeng(STDDRUK->prnpal)
         STDWAAR->prwidt := nPrnWidt(STDDRUK->prnwid)
         STDWAAR->prnorm := cPrnNorm(ALLTRIM(STDDRUK->prncc))

         STDWAAR->prclin := nPrnLine(STDDRUK->prclin)
         STDWAAR->prcprl := nPrcPrnl(STDDRUK->prcprl)
         STDWAAR->prcpal := nPrcLeng(STDDRUK->prcpal)
         STDWAAR->prcwid := nPrnWidt(STDDRUK->prcwid)
         STDWAAR->prcond := cPrnCond(ALLTRIM(STDDRUK->prccc))
         DBCOMMIT()
      ENDIF
   END

   //Reset
   fATclose(aCdbf)

RETURN NIL

/******************************************************************************/
STATIC FUNCTION sm3plen

   Local nLine   := 1
   Local cCond   := ""
   Local cNorm   := ""
   Local cMsgN   := IIF(cLanType() == "A", "Normale druk lyn nommer : ","Normal print line number : ")
   Local cMsgC   := IIF(cLanType() == "A", "Klein druk lyn nommer : ","Condense print line number : ")

   IF cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   ELSE
      fScrOpsk( , "Option "+cOption())
   ENDIF

   fScrBood( MAXROW()-1)
   fScrBood( MAXROW())

   BEGIN SEQUENCE
      //Toets of drukker gereed is
      if fPrnReady() == K_ESC
         break
      endif

      IF cLanType() == "A"
         fScrBood( MAXROW(), "Druk lyn nommers om bladsy lengtes te bepaal" )
      ELSE
         fScrBood( MAXROW(), "Print line numbers in order to determine page length" )
      ENDIF

      cNorm := cPrnNorm()
      cCond := cPrnCond()

      //Skakel die drukker aan
      fPrnOn()
      fPrnCod( cNorm )
      SETPRC( 0, 0 )
      nLine := 1
      @ PROW(),00 SAY cMsgN+ALLTRIM(STR(nLine,4,0))

      FOR nLine := 2 TO 80
         @ PROW()+1,00 SAY cMsgN+ALLTRIM(STR(nLine,4,0))
      NEXT

      @ PROW()+1,00 SAY "         1         2         3         4         5         6         7         8         9         "
      @ PROW()+1,00 SAY "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
      fPrnEjec()
      fPrnCod( cCond )
      nLine := 1
      @ PROW(),00 SAY cMsgC+ALLTRIM(STR(nLine,4,0))

      FOR nLine := 2 TO 100
         @ PROW()+1,00 SAY cMsgC+ALLTRIM(STR(nLine,4,0))
      NEXT

      @ PROW()+1,00 SAY "                                                                                                   1         1         1         1         "
      @ PROW()+1,00 SAY "         1         2         3         4         5         6         7         8         9         0         1         2         3         "
      @ PROW()+1,00 SAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
      fPrnEjec()

   END

   // Printer off
   fPrnOff()

RETURN NIL

*-----------------------------------------------------------------------------
STATIC FUNCTION fVPoort (aCodes)

   IF aCodes[APRLPTP] < 1 .OR. aCodes[APRLPTP] > 4
      fScrBood( MAXROW()-1 )
      IF cLanType() == "A"
         fScrWait( MAXROW(), "Gebruik '1,2,3 of 4' as drukker poort" )
      ELSE
         fScrWait( MAXROW(), "Use '1,2,3 or 4' as Printer port" )
      ENDIF

      fScrBood( MAXROW() )
      RETU FALSE
   ENDIF

RETURN TRUE

*-----------------------------------------------------------------------------
STATIC FUNCTION fVNLeng (aCodes)

   IF LASTKEY() == K_UP
      RETU TRUE
   ENDIF

   IF aCodes[APRNLIN] >= aCodes[APRNPRL]
      fScrBood( MAXROW()-1 )
      IF cLanType() == "A"
         fScrWait( MAXROW(), "Begin lyn nommer moet kleiner as druklengte wees" )
      ELSE
         fScrWait( MAXROW(), "Start line number must be smaller than print length" )
      ENDIF

      fScrBood( MAXROW() )
      RETU FALSE
   ENDIF

   IF aCodes[APRNPRL] > aCodes[APRNPAL] - 6
      fScrBood( MAXROW()-1 )
      IF cLanType() == "A"
         fScrWait( MAXROW(), "Druklengte moet minstes 6 lyne minder as bladsylengte wees" )
      ELSE
         fScrWait( MAXROW(), "Print length must be at least 6 lines less than page length" )
      ENDIF

      fScrBood( MAXROW() )
      RETU FALSE
   ENDIF

RETURN TRUE

*-----------------------------------------------------------------------------
STATIC FUNCTION fVCLeng (aCodes)

   IF LASTKEY() == K_UP
      RETU TRUE
   ENDIF

   IF aCodes[APRCLIN] >= aCodes[APRCPRL]
      fScrBood( MAXROW()-1 )
      IF cLanType() == "A"
         fScrWait( MAXROW(), "Begin lyn nommer moet kleiner as druklengte wees" )
      ELSE
         fScrWait( MAXROW(), "Start line number must be smaller than print length" )
      ENDIF

      fScrBood( MAXROW() )
      RETU FALSE
   ENDIF

   IF aCodes[APRCPRL] > aCodes[APRCPAL] - 6
      fScrBood( MAXROW()-1 )
      IF cLanType() == "A"
         fScrWait( MAXROW(), "Druklengte moet minstes 6 lyne minder as papierlengte wees" )
      ELSE
         fScrWait( MAXROW(), "Print length must be at least 6 lines less than paper length" )
      ENDIF

      fScrBood( MAXROW() )
      RETU FALSE
   ENDIF

RETURN TRUE

/*--------------------------------------------------------------------------*/
STATIC FUNCTION fVKode (cCodes)

   IF "LAZER" $ UPPER(cCodes) .OR. "LASER" $ UPPER(cCodes)
      fScrBood( MAXROW()-1 )
      IF cLanType() == "A"
         fScrWait( MAXROW(), "Gebruik die werklike Laser Drukker kodes" )
      ELSE
         fScrWait( MAXROW(), "Use the actual Laser Printer codes" )
      ENDIF

      fScrBood( MAXROW() )
      RETU FALSE
   ENDIF

RETURN TRUE


