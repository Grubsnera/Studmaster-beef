// Application: StudMaster for Beef Cattle
//   File Name: SM3PSIO.PRG
// Description: Program to load masses from the PSION handheld computer
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Sarel Cloete
//  Created on: 26-05-97 08:00am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3psion

   // Declare
   local aCscr   := fASaveScr()
   local aCdbf   := fATopen()
   local cCl     := "CL "+ALLTRIM(STR(nScBaud(),4,0))+","+ALLTRIM(STR(nScPort(),1,0))
   local lCl     := FALSE
   local nTota   := 0
   local nReko   := 0
   local cSeek   := ""
   local cBood   := ""
   local cFile   := "WEEGLYS.PSN"

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      //Clear old weigh list file
      if file(cFile)
         if ferase(cFile) < 0
            fScrBood(MAXROW()-1)
            if cLanType() == "A"
               fScrWait(MAXROW(),"Kan nie die PSION ler verwyder nie : "+ALLTRIM(STR(FERROR(),5,0)))
            else
               fScrWait(MAXROW(),"Unable to Erase PSION File : "+ALLTRIM(STR(FERROR(),5,0)))
            endif

            BREAK
         endif
      endif

      //Check if PSION programs is available
      if ! FILE("CL.EXE")
         IF cLanType() == "A"
            fScrWait(MAXROW()-1,"Die PSION Program 'CL.EXE' is not beskikbaar nie",,,,TRUE)
         else
            fScrWait(MAXROW()-1,"The PSION Program 'CL.EXE' is not available",,,,TRUE)
         endif

         break
      endif

      if ! FILE("S_FILE.EXE")
         IF cLanType() == "A"
            fScrWait(MAXROW()-1,"Die PSION program 'S_FILE.EXE' is nie beskikbaar nie",,,,TRUE)
         else
            fScrWait(MAXROW()-1,"The PSION Program 'S_FILE.EXE' is not available",,,,TRUE)
         endif

         break
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

      aCdbf := fATOpen(aCdbf,cDd(),"SM3PSIO",,,,FALSE)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      fScrBood(MAXROW())
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
         @ 05,12 say "ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
         @ 06,12 say "บ                       WAARSKUWING !!!                    บ"
         @ 07,12 say "บ                                                          บ"
         @ 08,12 say "บ Die PSION Comms Link Program gaan nou geaktiveer word... บ"
         @ 09,12 say "บ                                                          บ"
         @ 10,12 say "บ  Koppel die PSION, en sodra die Comms Link Program loop, บ"
         @ 11,12 say "บ    selekteer die 'Comms' & 'Transmit' funksies op die    บ"
         @ 12,12 say "บ          PSION sodat die weeglys oorgedra kan word.      บ"
         @ 13,12 say "บ                                                          บ"
         @ 14,12 say "บ  Wanneer die oordrag voltooi is... Stop die Comms Link   บ"
         @ 15,12 say "บ   program sodat StoetMeester weer geaktiveer kan word.   บ"
         @ 16,12 say "บ   Gebruik 'Q' en 'Y' om die Comms Link program te stop.  บ"
         @ 17,12 say "บ                                                          บ"
         @ 18,12 say "ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
         fScrWait(maxrow()-1,"Koppel die PSION...",,,,TRUE)
      else
         fScrOpsk( ,"Option "+cOption())
         @ 05,12 say "ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
         @ 06,12 say "บ                         WARNING !!!                      บ"
         @ 07,12 say "บ                                                          บ"
         @ 08,12 say "บ  The PSION Comms Link Program is about to be started...  บ"
         @ 09,12 say "บ                                                          บ"
         @ 10,12 say "บ Connect the PSION..., and once the Comms Link Program is บ"
         @ 11,12 say "บ   running, select the 'Comms' & 'Transmit' functions on  บ"
         @ 12,12 say "บ     the PSION to transfer the Weigh list to the PC.      บ"
         @ 13,12 say "บ                                                          บ"
         @ 14,12 say "บ  Once the transfer is completed... Quit the Comms Link   บ"
         @ 15,12 say "บ program to return to StudMaster. Use 'Q' and 'Y' to quit บ"
         @ 16,12 say "บ                 the Comms Link program.                  บ"
         @ 17,12 say "บ                                                          บ"
         @ 18,12 say "ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
         fScrWait(maxrow()-1,"Connect the PSION...",,,,TRUE)
      endif

      aCscr := fASaveScr()
      CLEAR SCREEN
      @ 0,0 SAY ""
      lCl  = SWPRUNCMD(cCl,0,"","")
      fARestScr(aCscr)

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      if ! lCl
         if cLanType() == "A"
            fScrWait(MAXROW()-1,"Kon nie die Comms Link Program aktiveer nie...")
         else
            fScrWait(MAXROW()-1,"Unable to Initiate the Comms. Link Program...")
         endif

         break
      endif

      //Check if weigh list file exist
      if ! file(cFile)
         fScrBood(MAXROW()-1)
         if cLanType() == "A"
            fScrWait(MAXROW(),"Daar is nie 'n PSION weeglys ler nie ?")
         else
            fScrWait(MAXROW(),"There is not a PSION weigh list file ?")
         endif

         BREAK
      endif

      //Process the imported masses
      IF cLanType() == "A"
         fScrBood(MAXROW(),"Prosesseer die PSION massas...")
      else
         fScrBood(MAXROW(),"Process the PSION masses...")
      endif

      DBSELECTAREA("SM3PSIO")
      ZAP
      APPEND FROM WEEGLYS.PSN DELIMITED
      DBGOTOP()
      nTota := LASTREC()

      do while ! eof()

         if nTota > 0
            if cLanType() == "A"
               fScrBood(MAXROW()-1,fPercent(++nReko/nTota)+"% Voltooi")
            else
               fScrBood(MAXROW()-1,fPercent(++nReko/nTota)+"% Completed")
            endif
         endif

         IF EMPTY(SM3PSIO->weegdatum) .OR. SM3PSIO->massa = 0
            DBSKIP()
            LOOP
         ENDIF

         DBSELECTAREA("SM3DATA")
         IF EMPTY(SM3PSIO->idnr) .AND. ! EMPTY(SM3PSIO->michip)
            cSeek := SM3PSIO->michip
            ORDSETFOCUS(13)
         ELSE
            cSeek := SM3PSIO->idnr
            ORDSETFOCUS(1)
         ENDIF

         IF ! SM3DATA->(DBSEEK(cSeek))
            DBSELECTAREA("SM3PSIO")
            DBSKIP()
            LOOP
         ENDIF

         DBSELECTAREA("SM3WEEG")

         IF ! SM3WEEG->(DBSEEK(SM3DATA->idnr+DTOS(SM3PSIO->weegdatum)))
            DBAPPEND()
            SM3WEEG->idnr  := SM3DATA->idnr
         ELSE
            DO WHILE ! RLOCK() ; ENDDO
            ENDIF

            SM3WEEG->weegdatum := SM3PSIO->weegdatum
            SM3WEEG->massa     := SM3PSIO->massa

            DBSELECTAREA("SM3PSIO")
            DBDELETE()
            DBSKIP()
         enddo

         fScrBood(MAXROW()-1)
         fScrBood(MAXROW())
         DBSELECTAREA("SM3WEEG")
         DBCOMMIT()

         DBSELECTAREA("SM3PSIO")
         PACK
         DBGOTOP()

         IF LASTREC() > 0
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,"Slegs " + ALLTRIM(STR(nTota-LASTREC())) + " uit " +ALLTRIM(STR(nTota)) + " massas kon geprosseer word...")
               cBood := "Druk ongeprosesseerde massas"
            ELSE
               fScrBood(MAXROW()-1,"Only " + ALLTRIM(STR(nTota-LASTREC())) + " out of " +ALLTRIM(STR(nTota)) + " masses was processed...")
               cBood := "Print unprocessed masses"
            ENDIF

            IF fJaNee(MAXROW(),cBood,,FALSE,TRUE)
               fPrint()
            ENDIF

         ENDIF
      end

      // Reset
      fATclose(aCdbf)
      fARestScr(aCscr)

      return NIL

/*************************************************************************/
      STATIC FUNCTION fPrint(aRecv)

         //Verklaar
         local nTota := 0
         local lLoop := .t.
         local nI    := 1
         local nReko := 1
         local cData := ""
         local aSend := {}
         local cHdln := ""
         local cPcod := ""
         local nMidc := 0
         local nWidt := 0
         local nTopl := 0
         local nPrnl := 0
         local nPagl := 0
         local nBlad := 1

         //Toets of drukker gereed is
         if fPrnReady() == K_ESC
            return NIL
         endif

         //Skerm
         fScrBood(MAXROW()-1)
         if cLanType() == "A"
            fScrbood(MAXROW(),"Ongeprosesseerde diere word gedruk!  [Esc]=Stop drukker.")
            cHdln := upper("Diere in PSION weeglys wat nie geprosesseer kon word nie")
         else
            fScrbood(MAXROW(),"Unprocessed animals being printed!  [Esc]=Stop printer.")
            cHdln := upper("Animals in PSION weigh list that could not be processed")
         endif

         //Skuif die databasis
         DBSELECTAREA("SM3PSIO")
         go top

         //Tel aantal velde
         nTota := lastrec()

         //Kry die velde wat gedruk moet word
         if aRecv == NIL
            asize(aSend,0)
            aadd(aSend,{"sm3psio","idnr"})
            aadd(aSend,{"sm3psio","michip"})
            aadd(aSend,{"sm3psio","weegdatum"})
            aadd(aSend,{"sm3psio","massa"})
            aRecv := fGetField(aSend)
         endif

         //Bepaal die drukgrootte
         nWidt := 0
         for nI = 1 to len(aRecv)
            nWidt+= aRecv[nI][4]+1
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

               @prow()+1,  1 say repl( "=",  nWidt )

               //1e Lyn van opskrif
               cData := ""
               for nI = 1 to len( aRecv )
                  cData := cData + padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
               next
               @prow()+1,1 say padr(cData, nWidt)

               //2e Lyn van opskrif
               cData := ""
               for nI = 1 to len( aRecv )
                  cData := cData + padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
               next
               @prow()+1,1 say padr(cData, nWidt)

               //3e Lyn van opskrif
               cData := ""
               for nI = 1 to len( aRecv )
                  cData := cData + padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
               next
               @prow()+1,1 say padr(cData, nWidt)

               //4e Lyn van opskrif
               cData := ""
               for nI = 1 to len( aRecv )
                  cData := cData + repl("-",aRecv[nI,4]) + " "
               next
               @prow()+1,1 say padr(cData, nWidt)
            endif

            //Toets of drukker moet stop
            if fPrnStop() = K_ESC
               lLoop := .f.
               exit
            endif

            //Data
            cData := ""
            for nI = 1 to len( aRecv )
               do case
                  case aRecv[nI][3] == "C"
                     //Character
                     cData+= fieldget(aRecv[nI,13]) + " "
                  case aRecv[nI][3] == "N"
                     //Numeric
                     cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
                  case aRecv[nI][3] == "D"
                     //Date
                     cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
                  otherwise
                     //Nie een van bogenoemde
                     cData+= space(aRecv[nI][4])+" "
               endcase
            next
            @prow()+1,1 say padr(cData, nWidt)

            //Skerm
            // fPrnOff()
            // if nTota > 0
            //    setcolor( cColBott() )
            //    if cLanType() == "A"
            //       @ MAXROW()-1, 30 say fPercent(nReko/nTota)+"% Voltooi"
            //    else
            //       @ MAXROW()-1, 30 say fPercent(nReko/nTota)+"% Completed"
            //    endif
            //    setcolor( cColNorm() )
            //    nReko++
            // endif
            // fPrnOn()

            //Volgende rekord
            skip

            //Toets vir einde van bladsy
            if prow() >= nPrnl .or. eof()

               //Print onderste lyn
               @prow()+1,  1 say repl( "=",  nWidt )
               @prow()+1,  1 say cAppName()
               fPrnEjec()
               //fPrnOff()
               nBlad++

               //Indien eof()
               if eof()
                  lLoop := .f.
               endif
            endif

         enddo

         fPrnOff()

         //Herstel
         go top

         return NIL

