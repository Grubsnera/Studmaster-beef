//SM3OPDV.PRG
//Program om opsommende dekkingsverslae voor te berei
//Kopiereg (c) 1992 A van Rensburg
//                  S Cloete
//12:00 12 May,1997

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

#define IDVAAR   1
#define AANDEK   2
#define AANKOE   3
#define AANDRA   4
#define AANGEB   5
#define AANNAT   6
#define AANKII   7
#define AANINO   8
#define AANSPE   9
#define AANWAA   10
#define AANSEX01 11
#define AANSEX02 12
#define AANSEX99 13
#define AANGENKC 14
#define AANGENF  15
#define AANGENA  16
#define AANGENB  17
#define AANGENC  18
#define AANGEND  19
#define AANGENE  20
#define AANGENSP 21
#define AANGEB01 22
#define AANGEB02 23
#define AANGEB99 24
#define AANKLF01 25
#define AANKLF02 26
#define AANKLF03 27
#define AANKLF04 28
#define AANKLF05 29
#define AANKLF06 30
#define AANKLF07 31
#define AANKLF08 32
#define AANKLF10 33
#define AANKGM09 34
#define AANKGM10 35
#define AANKGM11 36
#define AANKGM12 37
#define AANKGM13 38

#define KONSEP   1
#define GEMDRA   2
#define GEMGEB   3
#define GEMNAT   4
#define GEMKII   5
#define GEMINO   6
#define GEMSPE   7
#define GEMSPG   8
#define GEMSEX01 9
#define GEMSEX02 10
#define GEMSEX99 11
#define GEMGENKC 12
#define GEMGENF  13
#define GEMGENA  14
#define GEMGENB  15
#define GEMGENC  16
#define GEMGEND  17
#define GEMGENE  18
#define GEMGENSP 19
#define GEMGEB01 20
#define GEMGEB02 21
#define GEMGEB99 22
#define GEMKLF01 23
#define GEMKLF02 24
#define GEMKLF03 25
#define GEMKLF04 26
#define GEMKLF05 27
#define GEMKLF06 28
#define GEMKLF07 29
#define GEMKLF08 30
#define GEMKLF10 31
#define GEMKGM09 32
#define GEMKGM10 33
#define GEMKGM11 34
#define GEMKGM12 35
#define GEMKGM13 36

//**************************************************************************/
FUNCTION sm3opdv(cFind)

   //Veranderlikes
   local cCscr   := savescreen(23,0,24,79)
   local lRetu   := FALSE
   local cData   := ""
   local cDekk   := ""
   local cIdMoer := " "
   local lKalw   := FALSE
   local aAanTal := {}
   local aGemid  := {}
   local n       := 0
   local nKey    := 0
   local cHdl1   := ""
   local cHdl2   := ""
   local cPcod   := ""
   local nMidc   := 0
   local nWidt   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local nPagl   := 0
   local nBlad   := 1
   local cMsg    := IIF(cLanType()=="A","Opsommende Dekverslag...","Summary Mating Report...")
   local cYesNo  := IIF(cLanType()=="A","[J]=Druk  [N]=Vertoon","[Y]=Print  [N]=Display")

   //Open dataleers
   fScrBood(MAXROW()-1)
   IF cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
      fScrWbood(MAXROW(),"Datalˆers word geopen")
   ELSE
      fScrOpsk( , "Option "+cOption())
      fScrWbood(MAXROW(),"Data files being opened")
   ENDIF

   cData := fTOpen(cDd(),"sm3data",,,,FALSE)
   IF left(cData,1) == "f"
      RETU lRetu
   ENDIF

   cDekk := fTOpen(cDd(),"sm3dekk")
   IF left( cDekk, 1 ) == "f"
      fTClose(cData)
      RETU lRetu
   ENDIF
   ORDSETFOCUS(2)

   //Skuif die databasis
   IF cFind == NIL
      fTClose(cData)
      fTClose(cDekk)
      RETU lRetu
   ELSE
      IF ! DBSEEK(cFind)
         fTClose(cData)
         fTClose(cDekk)
         RETU lRetu
      ENDIF
   ENDIF

   //Maak rekord oop vir Totale teelgroep
   lRetu := TRUE
   AADD(aAanTal,{SPACE(12),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
   aAanTal[1,IDVAAR] := PADR(cFind,12," ")

   //Soek diere
   fScrBood(MAXROW()-1)
   IF cLanType() == "A"
      fScrBood(MAXROW(),"Kalfseisoen se berekeninge word gedoen!")
   ELSE
      fScrBood(MAXROW(),"Calving season calculations being done!")
   ENDIF

   //Die loop
   DBSELECTAREA("SM3DEKK")
   DO WHILE SM3DEKK->teelgroep == cFind

      setcolor(cColBott())
      IF cLanType() == "A"
         fScrBood(MAXROW()-1,SM3DEKK->idmoer + "(Rondte 2)")
      ELSE
         fScrBood(MAXROW()-1,SM3DEKK->idmoer + "(Round 2)")
      ENDIF
      setcolor(cColNorm())

      //Toets datumin wel bestaan
      IF SM3DEKK->datumin == ctod("")
         DBSKIP()
         LOOP
      ENDIF

      // Aantal dekkings totale groep
      aAantal[1,AANDEK]++

      // Aantal koeie
      IF SM3DEKK->idmoer <> cIdMoer
         cIdMoer := SM3DEKK->idmoer
         lKalw   := FALSE
         aAantal[1,AANKOE]++

         // Aantal dragtig
         IF SM3DEKK->dragtig $ "JY123456*"
            aAantal[1,AANDRA]++
         ENDIF

         //Aantal kalwings
         IF SM3DEKK->kalwer > 0 .and. !lKalw
            lKalw := TRUE
            aAantal[1,AANGEB] += SM3DEKK->kalwer
            aAantal[1,AANSPE] += SM3DEKK->speenn
            aAantal[1,AANWAA] += SM3DEKK->waaris
            IF SM3DEKK->vaarkode == "3"
               aAantal[1,AANKII] += SM3DEKK->kalwer
            ELSEIF SM3DEKK->vaarkode == "4"
               aAantal[1,AANINO] += SM3DEKK->kalwer
            ELSE
               aAantal[1,AANNAT] += SM3DEKK->kalwer
            ENDIF
         ENDIF

         //Get additional values
         IF ! EMPTY(SM3DEKK->idnr) .AND. SM3DATA->(DBSEEK(SM3DEKK->idnr))
            DO CASE
               CASE SM3DATA->geslag == "1"
                  aAanTal[1,AANSEX01]++
               CASE SM3DATA->geslag == "2"
                  aAanTal[1,AANSEX02]++
               OTHERWISE
                  aAanTal[1,AANSEX99]++
            ENDCASE

            DO CASE
               CASE SM3DATA->kalfstat == "01"
                  aAanTal[1,AANKLF01]++
               CASE SM3DATA->kalfstat == "02"
                  aAanTal[1,AANKLF02]++
               CASE SM3DATA->kalfstat == "03"
                  aAanTal[1,AANKLF03]++
               CASE SM3DATA->kalfstat == "04"
                  aAanTal[1,AANKLF04]++
               CASE SM3DATA->kalfstat == "05"
                  aAanTal[1,AANKLF05]++
               CASE SM3DATA->kalfstat == "06"
                  aAanTal[1,AANKLF06]++
               CASE SM3DATA->kalfstat == "07"
                  aAanTal[1,AANKLF07]++
               CASE SM3DATA->kalfstat == "08"
                  aAanTal[1,AANKLF08]++
               CASE SM3DATA->kalfstat == "10"
                  aAanTal[1,AANKLF10]++
            ENDCASE

            DO CASE
               CASE SM3DATA->gebstat $ " /1"
                  aAanTal[1,AANGEB01]++
               CASE SM3DATA->gebstat == "2"
                  aAanTal[1,AANGEB01]++
               OTHERWISE
                  aAanTal[1,AANGEB99]++
            ENDCASE

            DO CASE
               CASE SM3DATA->kalfgem == "09"
                  aAanTal[1,AANKGM09]++
               CASE SM3DATA->kalfgem == "10"
                  aAanTal[1,AANKGM10]++
               CASE SM3DATA->kalfgem == "11"
                  aAanTal[1,AANKGM11]++
               CASE SM3DATA->kalfgem == "12"
                  aAanTal[1,AANKGM12]++
               CASE SM3DATA->kalfgem == "13"
                  aAanTal[1,AANKGM13]++
            ENDCASE

            DO CASE
               CASE ALLTRIM(SM3DATA->generasie) $ " /K/C"
                  aAanTal[1,AANGENKC]++
               CASE ALLTRIM(SM3DATA->generasie) $ "F/F0"
                  aAanTal[1,AANGENF]++
               CASE ALLTRIM(SM3DATA->generasie) $ "A/F1"
                  aAanTal[1,AANGENA]++
               CASE ALLTRIM(SM3DATA->generasie) $ "B/F2"
                  aAanTal[1,AANGENB]++
               CASE ALLTRIM(SM3DATA->generasie) $ "C/F3"
                  aAanTal[1,AANGENC]++
               CASE ALLTRIM(SM3DATA->generasie) $ "D/F4"
                  aAanTal[1,AANGEND]++
               CASE ALLTRIM(SM3DATA->generasie) $ "E/F5"
                  aAanTal[1,AANGENE]++
               CASE ALLTRIM(SM3DATA->generasie) $ "SP"
                  aAanTal[1,AANGENSP]++
            ENDCASE

         ENDIF
      ENDIF

      DBSELECTAREA("SM3DEKK")
      DBSKIP()

   ENDDO

   //Verskeie bulle se syfers
   DBSELECTAREA("SM3DEKK")
   ORDSETFOCUS(3)
   DBSEEK(cFind)
   cIdMoer := " "
   DO WHILE SM3DEKK->teelgroep == cFind

      setcolor(cColBott())
      IF cLanType() == "A"
         fScrBood(MAXROW()-1,SM3DEKK->idmoer + "(Rondte 3)")
      ELSE
         fScrBood(MAXROW()-1,SM3DEKK->idmoer + "(Round 3)")
      ENDIF
      setcolor(cColNorm())

      //Toets datumin wel bestaan
      IF SM3DEKK->datumin == ctod("")
         DBSKIP()
         LOOP
      ENDIF

      //Kyk of bul bestaan
      n := ASCAN(aAanTal,{ |aVal| aVal[IDVAAR] == SM3DEKK->idvaar})
      IF n = 0
         AADD(aAanTal,{SPACE(12),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
         n := LEN(aAanTal)
         aAantal[n,IDVAAR] := PADR(SM3DEKK->idvaar,12," ")
      ENDIF

      //Aantal dekkings een bul
      aAantal[n,AANDEK]++

      //Aantal koeie
      IF SM3DEKK->idmoer <> cIdMoer
         cIdMoer := SM3DEKK->idmoer
         lKalw   := FALSE
         aAantal[n,AANKOE]++

         //Aantal dragtig
         IF SM3DEKK->dragtig $ "JY123456*"
            aAantal[n,AANDRA]++
         ENDIF

         //Aantal kalwings
         IF SM3DEKK->kalwer > 0 .and. !lKalw
            lKalw := TRUE
            aAantal[n,AANGEB] += SM3DEKK->kalwer
            aAantal[n,AANSPE] += SM3DEKK->speenn
            aAantal[n,AANWAA] += SM3DEKK->waaris
            IF SM3DEKK->vaarkode == "3"
               aAantal[n,AANKII] += SM3DEKK->kalwer
            ELSEIF SM3DEKK->vaarkode == "4"
               aAantal[n,AANINO] += SM3DEKK->kalwer
            ELSE
               aAantal[n,AANNAT] += SM3DEKK->kalwer
            ENDIF
         ENDIF

         //Get additional values
         IF ! EMPTY(SM3DEKK->idnr) .AND. SM3DATA->(DBSEEK(SM3DEKK->idnr))
            DO CASE
               CASE SM3DATA->geslag == "1"
                  aAanTal[n,AANSEX01]++
               CASE SM3DATA->geslag == "2"
                  aAanTal[n,AANSEX02]++
               OTHERWISE
                  aAanTal[n,AANSEX99]++
            ENDCASE

            DO CASE
               CASE SM3DATA->kalfstat == "01"
                  aAanTal[n,AANKLF01]++
               CASE SM3DATA->kalfstat == "02"
                  aAanTal[n,AANKLF02]++
               CASE SM3DATA->kalfstat == "03"
                  aAanTal[n,AANKLF03]++
               CASE SM3DATA->kalfstat == "04"
                  aAanTal[n,AANKLF04]++
               CASE SM3DATA->kalfstat == "05"
                  aAanTal[n,AANKLF05]++
               CASE SM3DATA->kalfstat == "06"
                  aAanTal[n,AANKLF06]++
               CASE SM3DATA->kalfstat == "07"
                  aAanTal[n,AANKLF07]++
               CASE SM3DATA->kalfstat == "08"
                  aAanTal[n,AANKLF08]++
               CASE SM3DATA->kalfstat == "10"
                  aAanTal[n,AANKLF10]++
            ENDCASE

            DO CASE
               CASE SM3DATA->gebstat $ " /1"
                  aAanTal[n,AANGEB01]++
               CASE SM3DATA->gebstat == "2"
                  aAanTal[n,AANGEB01]++
               OTHERWISE
                  aAanTal[n,AANGEB99]++
            ENDCASE

            DO CASE
               CASE SM3DATA->kalfgem == "09"
                  aAanTal[n,AANKGM09]++
               CASE SM3DATA->kalfgem == "10"
                  aAanTal[n,AANKGM10]++
               CASE SM3DATA->kalfgem == "11"
                  aAanTal[n,AANKGM11]++
               CASE SM3DATA->kalfgem == "12"
                  aAanTal[n,AANKGM12]++
               CASE SM3DATA->kalfgem == "13"
                  aAanTal[n,AANKGM13]++
            ENDCASE

            DO CASE
               CASE ALLTRIM(SM3DATA->generasie) $ " /K/C"
                  aAanTal[n,AANGENKC]++
               CASE ALLTRIM(SM3DATA->generasie) $ "F/F0"
                  aAanTal[n,AANGENF]++
               CASE ALLTRIM(SM3DATA->generasie) $ "A/F1"
                  aAanTal[n,AANGENA]++
               CASE ALLTRIM(SM3DATA->generasie) $ "B/F2"
                  aAanTal[n,AANGENB]++
               CASE ALLTRIM(SM3DATA->generasie) $ "C/F3"
                  aAanTal[n,AANGENC]++
               CASE ALLTRIM(SM3DATA->generasie) $ "D/F4"
                  aAanTal[n,AANGEND]++
               CASE ALLTRIM(SM3DATA->generasie) $ "E/F5"
                  aAanTal[n,AANGENE]++
               CASE ALLTRIM(SM3DATA->generasie) $ "SP"
                  aAanTal[n,AANGENSP]++
            ENDCASE

         ENDIF
      ENDIF

      DBSELECTAREA("SM3DEKK")
      DBSKIP()
   ENDDO

   //Bereken persentasies
   fScrBood(MAXROW()-1)
   IF cLanType() == "A"
      fScrWbood(MAXROW(),"Persentasies word bereken")
   ELSE
      fScrWbood(MAXROW(),"Percentages being calculated")
   ENDIF

   FOR n := 1 TO LEN(aAanTal)
      AADD(aGemid,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
   next

   FOR n := 1 TO LEN(aAanTal)
      aGemid[n,KONSEP] := aAanTal[n,AANDEK] / aAanTal[n,AANDRA]
      aGemid[n,GEMDRA]   := val(fpercent(aAanTal[n,AANDRA]   ,aAanTal[n,AANKOE]))
      aGemid[n,GEMGEB]   := val(fpercent(aAanTal[n,AANGEB]   ,aAanTal[n,AANKOE]))
      aGemid[n,GEMNAT]   := val(fpercent(aAanTal[n,AANNAT]   ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKII]   := val(fpercent(aAanTal[n,AANKII]   ,aAanTal[n,AANGEB]))
      aGemid[n,GEMINO]   := val(fpercent(aAanTal[n,AANINO]   ,aAanTal[n,AANGEB]))
      aGemid[n,GEMSPE]   := val(fpercent(aAanTal[n,AANSPE]   ,aAanTal[n,AANDRA]))
      aGemid[n,GEMSPG]   := val(fpercent(aAanTal[n,AANSPE]   ,aAanTal[n,AANGEB]))
      aGemid[n,GEMSEX01] := val(fpercent(aAanTal[n,AANSEX01] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMSEX02] := val(fpercent(aAanTal[n,AANSEX02] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMSEX99] := val(fpercent(aAanTal[n,AANSEX99] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENKC] := val(fpercent(aAanTal[n,AANGENKC] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENF]  := val(fpercent(aAanTal[n,AANGENF]  ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENA]  := val(fpercent(aAanTal[n,AANGENA]  ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENB]  := val(fpercent(aAanTal[n,AANGENB]  ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENC]  := val(fpercent(aAanTal[n,AANGENC]  ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGEND]  := val(fpercent(aAanTal[n,AANGEND]  ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENE]  := val(fpercent(aAanTal[n,AANGENE]  ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGENSP] := val(fpercent(aAanTal[n,AANGENSP] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGEB01] := val(fpercent(aAanTal[n,AANGEB01] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGEB02] := val(fpercent(aAanTal[n,AANGEB02] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMGEB99] := val(fpercent(aAanTal[n,AANGEB99] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF01] := val(fpercent(aAanTal[n,AANKLF01] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF02] := val(fpercent(aAanTal[n,AANKLF02] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF03] := val(fpercent(aAanTal[n,AANKLF03] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF04] := val(fpercent(aAanTal[n,AANKLF04] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF05] := val(fpercent(aAanTal[n,AANKLF05] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF06] := val(fpercent(aAanTal[n,AANKLF06] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF07] := val(fpercent(aAanTal[n,AANKLF07] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF08] := val(fpercent(aAanTal[n,AANKLF08] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKLF10] := val(fpercent(aAanTal[n,AANKLF10] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKGM09] := val(fpercent(aAanTal[n,AANKGM09] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKGM10] := val(fpercent(aAanTal[n,AANKGM10] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKGM11] := val(fpercent(aAanTal[n,AANKGM11] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKGM12] := val(fpercent(aAanTal[n,AANKGM12] ,aAanTal[n,AANGEB]))
      aGemid[n,GEMKGM13] := val(fpercent(aAanTal[n,AANKGM13] ,aAanTal[n,AANGEB]))
   next

   If fJaNee(MAXROW(),cMsg,,,,cYesNo)
      //Toets of drukker gereed is
      if fPrnReady() == K_ESC
         return NIL
      endif

      // Druk die syfers
      if cLanType() == "A"
         fScrbood(24,"Dekverslag van die "+ALLTRIM(cFind)+" kalfseisoen word gedruk!  [Esc]=Stop drukker.")
         cHdl1 := upper("OPSOMMENDE DEKVERSLAG VAN DIE "+ALLTRIM(cFind)+" KALFSEISOEN.")
      else
         fScrbood(24,"Mating report for the "+ALLTRIM(cFind)+" calving season being printed! [Esc]=Stop printer.")
         cHdl1 := upper("SUMMARY MATING REPORT FOR THE "+ALLTRIM(cFind)+" CALVING SEASON.")
      endif

      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
      nMidc := nWidt - 29

      FOR n := 1 TO LEN(aAanTal)
         //Skakel die drukker aan
         fPrnOn()

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
               @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
               if n > 1
                  cHdl2 := "Bul: "+ALLTRIM(aAanTal[n,IDVAAR])
                  @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
               endif
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
               @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
               if n > 1
                  cHdl2 := "Sire: "+ALLTRIM(aAanTal[n,IDVAAR])
                  @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
               endif
            endif
            @prow()+1,  1 say repl( "=",  nWidt )
         endif

         if cLanType() == "A"
            @PROW()+1,01 SAY "                                 Aantal   Persentasie                       "
            @PROW()+1,01 SAY "       Dekkings.................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANDEK],5,0)
            @PROW()+1,01 SAY "       Koeie....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKOE],5,0)
            @PROW()+1,01 SAY "       Dragtig..................:                     Konsepsie verh..:     "
            @PROW(),35 SAY STR(aAanTal[n,AANDRA],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMDRA],3,0)
            @PROW(),73 SAY STR(aGemid[n,KONSEP],4,2)
            @PROW()+1,01 SAY "       Geboortes................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB],3,0)
            @PROW()+1,01 SAY "       Gespeen..................:                 (/Geb)      (/Drag)       "
            @PROW(),35 SAY STR(aAanTal[n,AANSPE],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSPG],3,0)
            @PROW(),59 SAY STR(aGemid[n,GEMSPE],3,0)

            @PROW()+2,01 SAY "Dekkings.......................  Aantal   Persentasie                       "
            @PROW()+1,01 SAY "       Natuurlike...............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANNAT],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMNAT],3,0)
            @PROW()+1,01 SAY "       Kunsmatige Inseminasie...:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKII],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKII],3,0)
            @PROW()+1,01 SAY "       Embrio oorplantings......:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANINO],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMINO],3,0)

            @PROW()+2,01 SAY "Geslag.........................  Aantal   Persentasie                       "
            @PROW()+1,01 SAY "       Vroulik..................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANSEX01],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSEX01],3,0)
            @PROW()+1,01 SAY "       Manlik...................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANSEX02],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSEX02],3,0)
            @PROW()+1,01 SAY "       Ander....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANSEX99],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSEX99],3,0)

            @PROW()+2,01 SAY "Geboortestatus.................  Aantal   Persentasie                       "
            @PROW()+1,01 SAY "       Enkelinge................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB01],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB01],3,0)
            @PROW()+1,01 SAY "       Tweelinge................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB02],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB02],3,0)
            @PROW()+1,01 SAY "       Meerlinge................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB99],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB99],3,0)

            @PROW()+2,01 SAY "Generasie......................  Aantal   Persentasie                       "
            @PROW()+1,01 SAY "       K (kommersieel)..........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENKC],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENKC],3,0)
            @PROW()+1,01 SAY "       F (fundemental)..........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENF],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENF],3,0)
            @PROW()+1,01 SAY "       F1/A.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENA],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENA],3,0)
            @PROW()+1,01 SAY "       F2/B.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENB],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENB],3,0)
            @PROW()+1,01 SAY "       F3/C.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENC],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENC],3,0)
            @PROW()+1,01 SAY "       F4/D.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEND],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEND],3,0)
            @PROW()+1,01 SAY "       F5/E.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENE],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENE],3,0)
            @PROW()+1,01 SAY "       SP.......................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENSP],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENSP],3,0)

            @PROW()+2,01 SAY "Kalfstatus.....................  Aantal   Persentasie                       "
            @PROW()+1,01 SAY "       Normale dragtigheid......:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF01],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF01],3,0)
            @PROW()+1,01 SAY "       Aborsie..................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF02],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF02],3,0)
            @PROW()+1,01 SAY "       Aborsie na 7 mde.........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF03],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF03],3,0)
            @PROW()+1,01 SAY "       Doodgebore...............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF04],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF04],3,0)
            @PROW()+1,01 SAY "       Dood na geboorte.........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF05],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF05],3,0)
            @PROW()+1,01 SAY "       Vernietig................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF06],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF06],3,0)
            @PROW()+1,01 SAY "       Vroeggebore..............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF07],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF07],3,0)
            @PROW()+1,01 SAY "       Laatgebore...............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF08],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF08],3,0)
            @PROW()+1,01 SAY "       Hulp verleen.............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF10],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF10],3,0)

            @PROW()+2,01 SAY "Gemak van kalwing..............  Aantal   Persentasie                       "
            if substr(cTotNaam(),149,3) == "219" .or. substr(cTotNaam(),149,3) == "207"
               @PROW()+1,01 SAY "       Normaal..................:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM09],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM09],3,0)
               @PROW()+1,01 SAY "       Ligte kalwingsprobleme...:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM10],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM10],3,0)
               @PROW()+1,01 SAY "       Ernstige probleme........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM11],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM11],3,0)
               @PROW()+1,01 SAY "       Keisersnee...............:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM12],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM12],3,0)
               @PROW()+1,01 SAY "       Kalf dood - uitgesny.....:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM13],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM13],3,0)
            ELSE
               @PROW()+1,01 SAY "       Normaal..................:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM09],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM09],3,0)
               @PROW()+1,01 SAY "       Geringe probleme.........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM10],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM10],3,0)
               @PROW()+1,01 SAY "       Ernstige probleme........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM11],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM11],3,0)
               @PROW()+1,01 SAY "       Kalf dood................:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM12],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM12],3,0)
            ENDIF

         ELSE
            @PROW()+1,01 SAY "                                 Amount    Percentage                       "
            @PROW()+1,01 SAY "       Matings..................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANDEK],5,0)
            @PROW()+1,01 SAY "       Cows.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKOE],5,0)
            @PROW()+1,01 SAY "       Conceived................:                    Conseption ratio.:     "
            @PROW(),35 SAY STR(aAanTal[n,AANDRA],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMDRA],3,0)
            @PROW(),73 SAY STR(aGemid[n,KONSEP],4,2)
            @PROW()+1,01 SAY "       Births...................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB],3,0)
            @PROW()+1,01 SAY "       Weaned...................:                 (/Brt)      (/Cons)       "
            @PROW(),35 SAY STR(aAanTal[n,AANSPE],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSPG],3,0)
            @PROW(),59 SAY STR(aGemid[n,GEMSPE],3,0)

            @PROW()+2,01 SAY "Matings........................  Amount    Percentage                       "
            @PROW()+1,01 SAY "       Natural..................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANNAT],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMNAT],3,0)
            @PROW()+1,01 SAY "       Artificial Insemination..:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKII],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKII],3,0)
            @PROW()+1,01 SAY "       Embrio transfers.........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANINO],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMINO],3,0)

            @PROW()+2,01 SAY "Sex............................  Amount    Percentage                       "
            @PROW()+1,01 SAY "       Female...................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANSEX01],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSEX01],3,0)
            @PROW()+1,01 SAY "       Male.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANSEX02],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSEX02],3,0)
            @PROW()+1,01 SAY "       Other....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANSEX99],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMSEX99],3,0)

            @PROW()+2,01 SAY "Birth status...................  Amount    Percentage                       "
            @PROW()+1,01 SAY "       Single...................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB01],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB01],3,0)
            @PROW()+1,01 SAY "       Twins....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB02],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB02],3,0)
            @PROW()+1,01 SAY "       Multiple births..........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEB99],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEB99],3,0)

            @PROW()+2,01 SAY "Generation.....................  Amount    Percentage                       "
            @PROW()+1,01 SAY "       C (commercial)...........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENKC],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENKC],3,0)
            @PROW()+1,01 SAY "       F (fundemental)..........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENF],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENF],3,0)
            @PROW()+1,01 SAY "       F1/A.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENA],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENA],3,0)
            @PROW()+1,01 SAY "       F2/B.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENB],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENB],3,0)
            @PROW()+1,01 SAY "       F3/C.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENC],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENC],3,0)
            @PROW()+1,01 SAY "       F4/D.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGEND],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGEND],3,0)
            @PROW()+1,01 SAY "       F5/E.....................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENE],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENE],3,0)
            @PROW()+1,01 SAY "       SP.......................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANGENSP],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMGENSP],3,0)

            @PROW()+2,01 SAY "Calving status.................  Amount    Percentage                       "
            @PROW()+1,01 SAY "       Normal pregnancy.........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF01],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF01],3,0)
            @PROW()+1,01 SAY "       Abortion.................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF02],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF02],3,0)
            @PROW()+1,01 SAY "       Abortion after 7 mths....:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF03],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF03],3,0)
            @PROW()+1,01 SAY "       Still born...............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF04],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF04],3,0)
            @PROW()+1,01 SAY "       Died after birth.........:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF05],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF05],3,0)
            @PROW()+1,01 SAY "       Destroyed................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF06],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF06],3,0)
            @PROW()+1,01 SAY "       Premature................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF07],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF07],3,0)
            @PROW()+1,01 SAY "       Overmature...............:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF08],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF08],3,0)
            @PROW()+1,01 SAY "       Assisted.................:                                           "
            @PROW(),35 SAY STR(aAanTal[n,AANKLF10],5,0)
            @PROW(),47 SAY STR(aGemid[n,GEMKLF10],3,0)

            @PROW()+2,01 SAY "Ease of calving................  Amount    Percentage                       "
            if substr(cTotNaam(),149,3) == "219" .or. substr(cTotNaam(),149,3) == "207"
               @PROW()+1,01 SAY "       Normal calving...........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM09],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM09],3,0)
               @PROW()+1,01 SAY "       Calving with some assist.:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM10],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM10],3,0)
               @PROW()+1,01 SAY "       Serious difficulty.......:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM11],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM11],3,0)
               @PROW()+1,01 SAY "       Caesarean birth..........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM12],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM12],3,0)
               @PROW()+1,01 SAY "       Calf died - foetomy .....:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM13],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM13],3,0)
            ELSE
               @PROW()+1,01 SAY "       Normal...................:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM09],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM09],3,0)
               @PROW()+1,01 SAY "       Minor problems...........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM10],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM10],3,0)
               @PROW()+1,01 SAY "       Serious problems.........:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM11],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM11],3,0)
               @PROW()+1,01 SAY "       Calf died................:                                           "
               @PROW(),35 SAY STR(aAanTal[n,AANKGM12],5,0)
               @PROW(),47 SAY STR(aGemid[n,GEMKGM12],3,0)
            ENDIF

         ENDIF

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         IF n > 1
            @PROW()+(nPagl-3-PROW()),nWidt-LEN(ALLTRIM(aAanTal[n,IDVAAR])) SAY ALLTRIM(aAanTal[n,IDVAAR])
         ENDIF

         fPrnEjec()
         fPrnOff()
         nBlad++
      NEXT
   ELSE
      n := 1

      DO WHILE TRUE
         fScrBood(MAXROW())
         fScrBood(MAXROW()-1)
         IF cLanType() == "A"
            @ 03,01 SAY "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
            @ 04,01 SAY "³                                                                            ³"
            @ 05,01 SAY "³                                                 Gemak v Kalwing #####    % ³"
            @ 06,01 SAY "³            #####    %  Geboortestat #####    %   Normaal......:            ³"
            @ 07,01 SAY "³Dekkings..:              Enkelinge.:              Ger. probleme:            ³"
            @ 08,01 SAY "³Koeie.....:              Tweelinge.:              Ern. probleme:            ³"
            @ 09,01 SAY "³Dragtig...:              Meerlinge.:              Kalf dood....:            ³"
            @ 10,01 SAY "³Geboortes.:                                                                 ³"
            @ 11,01 SAY "³Gespeen...:           /Geb     /Drag  KV.:                                  ³"
            @ 12,01 SAY "³                                                 Kalfstatus..... #####    % ³"
            @ 13,01 SAY "³Dekkings... #####    %  Generasie... #####    %   Normale drag.:            ³"
            @ 14,01 SAY "³ Natuurlik:              C (komm)..:              Aborsie......:            ³"
            @ 15,01 SAY "³ KI.......:              F (fund)..:              Aborsie na 7m:            ³"
            @ 16,01 SAY "³ Embrio...:              F1/A......:              Doodgebore...:            ³"
            @ 17,01 SAY "³                         F2/B......:              Dood na geb..:            ³"
            @ 18,01 SAY "³Geslag..... #####    %   F3/C......:              Vernietig....:            ³"
            @ 19,01 SAY "³ Vroulik..:              F4/D......:              Vroeggebore..:            ³"
            @ 20,01 SAY "³ Manlik...:              F5/E......:              Laatgebore...:            ³"
            @ 21,01 SAY "³ Ander....:              SP........:              Hulp verleen.:            ³"
            @ 22,01 SAY "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

            if substr(cTotNaam(),149,3) == "219" .or. substr(cTotNaam(),149,3) == "207"
               @ 07,52 SAY "Lig. probleme:"
               @ 08,52 SAY "Ern. probleme:"
               @ 09,52 SAY "Keisersnee...:"
               @ 10,52 SAY "Kalf dood....:"
            endif

            @ 04,03 SAY "Opsommende Dekverslag van die "+ALLTRIM(cFind)+" Kalfseisoen."

            if n > 1
               @ 05,03 SAY "Bul..: "+ALLTRIM(aAanTal[n,IDVAAR])
            endif

            fScrBood( MAXROW(), "[Esc]=Menu   [PgUp]=Vorige Bul  [PgDn]=Volgende Bul" )
         ELSE
            @ 03,01 SAY "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
            @ 04,01 SAY "³                                                                            ³"
            @ 05,01 SAY "³                                                 Ease of Calving #####    % ³"
            @ 06,01 SAY "³            #####    %  Birth stat.  #####    %   Normal.......:            ³"
            @ 07,01 SAY "³Matings...:              Single....:              Minor problem:            ³"
            @ 08,01 SAY "³Cows......:              Twins.....:              Serious prob.:            ³"
            @ 09,01 SAY "³Conceived.:              M. Births.:              Calf died....:            ³"
            @ 10,01 SAY "³Births....:                                                                 ³"
            @ 11,01 SAY "³Weaned....:           /Brt     /Cons  CR.:                                  ³"
            @ 12,01 SAY "³                                                 Calving status. #####    % ³"
            @ 13,01 SAY "³Matings.... #####    %  Generation.. #####    %   Normal preg..:            ³"
            @ 14,01 SAY "³ Natural..:              C (comm)..:              Abortion.....:            ³"
            @ 15,01 SAY "³ AI.......:              F (fund)..:              Abort after 7:            ³"
            @ 16,01 SAY "³ Ambrio...:              F1/A......:              Still born...:            ³"
            @ 17,01 SAY "³                         F2/B......:              Died after Br:            ³"
            @ 18,01 SAY "³Sex........ #####    %   F3/C......:              Destroyed....:            ³"
            @ 19,01 SAY "³ Female...:              F4/D......:              Premature....:            ³"
            @ 20,01 SAY "³ Male.....:              F5/E......:              Overmature...:            ³"
            @ 21,01 SAY "³ Other....:              SP........:              Assisted.....:            ³"
            @ 22,01 SAY "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

            if substr(cTotNaam(),149,3) == "219" .or. substr(cTotNaam(),149,3) == "207"
               @ 07,52 SAY "Assisted.....:"
               @ 08,52 SAY "Ser. difficul:"
               @ 09,52 SAY "Ceasarean....:"
               @ 10,52 SAY "Calf died....:"
            endif

            @ 04,03 SAY "Summary Mating Report for the "+ALLTRIM(cFind)+" Calving Season."

            if n > 1
               @ 05,03 SAY "Sire..: "+ALLTRIM(aAanTal[n,IDVAAR])
            endif

            fScrBood( MAXROW(), "[Esc]=Menu  [PgUp]=Previous Sire   [PgDn]=Next Sire" )
         ENDIF

         @ 07,14 SAY STR(aAanTal[n,AANDEK],5,0)
         @ 08,14 SAY STR(aAanTal[n,AANKOE],5,0)
         @ 09,14 SAY STR(aAanTal[n,AANDRA],5,0)
         @ 09,21 SAY STR(aGemid[n,GEMDRA],3,0)
         @ 10,14 SAY STR(aAanTal[n,AANGEB],5,0)
         @ 10,21 SAY STR(aGemid[n,GEMGEB],3,0)
         @ 11,14 SAY STR(aAanTal[n,AANSPE],5,0)
         @ 11,21 SAY STR(aGemid[n,GEMSPG],3,0)
         @ 11,30 SAY STR(aGemid[n,GEMSPE],3,0)
         @ 11,45 SAY STR(aGemid[n,KONSEP],4,2)

         @ 14,14 SAY STR(aAanTal[n,AANNAT],5,0)
         @ 14,21 SAY STR(aGemid[n,GEMNAT],3,0)
         @ 15,14 SAY STR(aAanTal[n,AANKII],5,0)
         @ 15,21 SAY STR(aGemid[n,GEMKII],3,0)
         @ 16,14 SAY STR(aAanTal[n,AANINO],5,0)
         @ 16,21 SAY STR(aGemid[n,GEMINO],3,0)

         @ 19,14 SAY STR(aAanTal[n,AANSEX01],5,0)
         @ 19,21 SAY STR(aGemid[n,GEMSEX01],3,0)
         @ 20,14 SAY STR(aAanTal[n,AANSEX02],5,0)
         @ 20,21 SAY STR(aGemid[n,GEMSEX02],3,0)
         @ 21,14 SAY STR(aAanTal[n,AANSEX99],5,0)
         @ 21,21 SAY STR(aGemid[n,GEMSEX99],3,0)

         @ 07,39 SAY STR(aAanTal[n,AANGEB01],5,0)
         @ 07,46 SAY STR(aGemid[n,GEMGEB01],3,0)
         @ 08,39 SAY STR(aAanTal[n,AANGEB02],5,0)
         @ 08,46 SAY STR(aGemid[n,GEMGEB02],3,0)
         @ 09,39 SAY STR(aAanTal[n,AANGEB99],5,0)
         @ 09,46 SAY STR(aGemid[n,GEMGEB99],3,0)

         @ 14,39 SAY STR(aAanTal[n,AANGENKC],5,0)
         @ 14,46 SAY STR(aGemid[n,GEMGENKC],3,0)
         @ 15,39 SAY STR(aAanTal[n,AANGENF],5,0)
         @ 15,46 SAY STR(aGemid[n,GEMGENF],3,0)
         @ 16,39 SAY STR(aAanTal[n,AANGENA],5,0)
         @ 16,46 SAY STR(aGemid[n,GEMGENA],3,0)
         @ 17,39 SAY STR(aAanTal[n,AANGENB],5,0)
         @ 17,46 SAY STR(aGemid[n,GEMGENB],3,0)
         @ 18,39 SAY STR(aAanTal[n,AANGENC],5,0)
         @ 18,46 SAY STR(aGemid[n,GEMGENC],3,0)
         @ 19,39 SAY STR(aAanTal[n,AANGEND],5,0)
         @ 19,46 SAY STR(aGemid[n,GEMGEND],3,0)
         @ 20,39 SAY STR(aAanTal[n,AANGENE],5,0)
         @ 20,46 SAY STR(aGemid[n,GEMGENE],3,0)
         @ 21,39 SAY STR(aAanTal[n,AANGENSP],5,0)
         @ 21,46 SAY STR(aGemid[n,GEMGENSP],3,0)

         @ 06,67 SAY STR(aAanTal[n,AANKGM09],5,0)
         @ 06,74 SAY STR(aGemid[n,GEMKGM09],3,0)
         @ 07,67 SAY STR(aAanTal[n,AANKGM10],5,0)
         @ 07,74 SAY STR(aGemid[n,GEMKGM10],3,0)
         @ 08,67 SAY STR(aAanTal[n,AANKGM11],5,0)
         @ 08,74 SAY STR(aGemid[n,GEMKGM11],3,0)
         @ 09,67 SAY STR(aAanTal[n,AANKGM12],5,0)
         @ 09,74 SAY STR(aGemid[n,GEMKGM12],3,0)

         if substr(cTotNaam(),149,3) == "219" .or. substr(cTotNaam(),149,3) == "207"
            @ 10,67 SAY STR(aAanTal[n,AANKGM13],5,0)
            @ 10,74 SAY STR(aGemid[n,GEMKGM13],3,0)
         endif

         @ 13,67 SAY STR(aAanTal[n,AANKLF01],5,0)
         @ 13,74 SAY STR(aGemid[n,GEMKLF01],3,0)
         @ 14,67 SAY STR(aAanTal[n,AANKLF02],5,0)
         @ 14,74 SAY STR(aGemid[n,GEMKLF02],3,0)
         @ 15,67 SAY STR(aAanTal[n,AANKLF03],5,0)
         @ 15,74 SAY STR(aGemid[n,GEMKLF03],3,0)
         @ 16,67 SAY STR(aAanTal[n,AANKLF04],5,0)
         @ 16,74 SAY STR(aGemid[n,GEMKLF04],3,0)
         @ 17,67 SAY STR(aAanTal[n,AANKLF05],5,0)
         @ 17,74 SAY STR(aGemid[n,GEMKLF05],3,0)
         @ 18,67 SAY STR(aAanTal[n,AANKLF06],5,0)
         @ 18,74 SAY STR(aGemid[n,GEMKLF06],3,0)
         @ 19,67 SAY STR(aAanTal[n,AANKLF07],5,0)
         @ 19,74 SAY STR(aGemid[n,GEMKLF07],3,0)
         @ 20,67 SAY STR(aAanTal[n,AANKLF08],5,0)
         @ 20,74 SAY STR(aGemid[n,GEMKLF08],3,0)
         @ 21,67 SAY STR(aAanTal[n,AANKLF10],5,0)
         @ 21,74 SAY STR(aGemid[n,GEMKLF10],3,0)

         nKey := INKEY(0)

         DO CASE
            CASE nKey == K_ESC
               EXIT
            CASE nKey == K_PGDN
               n++
               IF n > LEN(aAanTal)
                  n:= LEN(aAanTal)
                  TONE( 300, 1 )
               ENDIF

            CASE nKey == K_PGUP
               n--
               IF n < 1
                  n := 1
                  // TONE( 300, 1 )
               ENDIF
         ENDCASE
      ENDDO
   ENDIF

   //Herstel
   fTClose(cData)
   fTClose(cDekk)
   restscreen(23,0,24,79)
RETURN lRetu
