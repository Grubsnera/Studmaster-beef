//SM3BLP1.PRG
//Program om massa teelwaardes in te lees
//Kopiereg (c) 1993 A van Rensburg
//                  S Cloete
//25-02-97 04:25pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3blp1()

   // Veranderlikes
   LOCAL aCscr   := fASaveScr()
   LOCAL aCdbf   := fATopen()
   LOCAL cPath   := cDd()
   LOCAL cBood   := ""
   LOCAL nStart  := 0
   LOCAL nBoxc   := 0
   LOCAL lBreak  := FALSE
   LOCAL GETLIST := {}

   BEGIN SEQUENCE

      IF RIGHT(cPath,1) <> "\"
         cPath += "\"
      ENDIF

      DO WHILE TRUE
         lBreak := FALSE

         IF cLanType() = "A"
            fScrOpsk( ,"Opsie "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"LEES MASSA TEELWAARDES")
            fScrBood(MAXROW()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(MAXROW(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
         ELSE
            fScrOpsk( ,"Option "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"IMPORT MASS BREEDING VALUES")
            fScrBood(MAXROW()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(MAXROW(),"Type full file name e.g. '"+cPath+"filename.ext'")
         ENDIF

         cPath := PADR(cPath,50," ")
         @ 12,nboxc GET cPath PICT "@!"
         SET(_SET_CURSOR,1)
         READ
         SET(_SET_CURSOR,0)

         IF LASTKEY() == K_ESC
            lBreak := TRUE
            EXIT
         ENDIF

         cPath := ALLTRIM(cPath)

         IF ! FILE(cPath)
            IF cLanType() = "A"
               fScrBood(MAXROW()-1,"Die lˆer "+cPath+" bestaan nie ?")
               fScrWait(MAXROW())
            ELSE
               fScrBood(MAXROW()-1,"The file "+cPath+" does not exist ?")
               fScrWait(MAXROW())
            ENDIF
         ELSE
            EXIT
         ENDIF
      ENDDO

   END

   IF lBreak
      BREAK
   ENDIF

   // Open the data files
   aCdbf := fATopen(aCdbf,cDd(),"SM3BLP1",,,,.f.)
   IF ! aCdbf[len(aCdbf),1]
      BREAK
   ENDIF

   aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
   IF !aCdbf[len(aCdbf),1]
      BREAK
   ENDIF

   IF cLanType() = "A"
      fScrBood(MAXROW(),"Die lˆer "+cPath+" word gelees...")
      fScrBood(MAXROW()-1)
   ELSE
      fScrBood(MAXROW(),"The file "+cPath+" being imported...")
      fScrBood(MAXROW()-1)
   ENDIF

   DBSELECTAREA("SM3BLP1")
   ZAP
   APPEND FROM (cPath) SDF
   nStart := LASTREC()

   DBSELECTAREA("SM3DATA")
   DBCLEARIND()
   DBCREATEINDEX("SM3DATA.SSC","PADL(ALLTRIM(reknr),10,'0')",{|| PADL(ALLTRIM(SM3DATA->reknr),10,"0") })

   DBSELECTAREA("SM3BLP1")
   DBGOTOP()

   DO WHILE ! EOF()

      IF SM3DATA->(DBSEEK(PADL(ALLTRIM(SM3BLP1->reknr),10,"0")))
         DBSELECTAREA("SM3DATA")
         DO WHILE ! RLOCK()
         ENDDO
         SM3DATA->birdir   := ROUND(VAL(SM3BLP1->birdir),2)
         SM3DATA->birmat   := ROUND(VAL(SM3BLP1->birmat),2)
         SM3DATA->biracc   := ROUND(VAL(SM3BLP1->biracc),0)
         SM3DATA->weadir   := ROUND(VAL(SM3BLP1->weadir),2)
         SM3DATA->weamat   := ROUND(VAL(SM3BLP1->weamat),2)
         SM3DATA->weacom   := ROUND(VAL(SM3BLP1->weacom),2)
         SM3DATA->weaacc   := ROUND(VAL(SM3BLP1->weaacc),0)
         SM3DATA->yeadir   := ROUND(VAL(SM3BLP1->yeadir),2)
         SM3DATA->yeaacc   := ROUND(VAL(SM3BLP1->yeaacc),0)
         SM3DATA->m18dir   := ROUND(VAL(SM3BLP1->m18dir),2)
         SM3DATA->m18acc   := ROUND(VAL(SM3BLP1->m18acc),0)
         SM3DATA->analdate := SM3BLP1->analdate

         DBSELECTAREA("SM3BLP1")
         DBDELETE()

      ENDIF

      DBSELECTAREA("SM3BLP1")
      DBSKIP()
   ENDDO

   PACK
   DBCOMMITALL()

   IF LASTREC() = 0
      IF cLanType() = "A"
         fScrBood(MAXROW()-1,"Teelwaardes van "+ALLTRIM(STR(nStart))+" diere is ingelees")
         fScrWait(MAXROW())
      ELSE
         fScrBood(MAXROW()-1,"Breeding values for "+ALLTRIM(STR(nStart))+" animals was processed")
         fScrWait(MAXROW())
      ENDIF
   ELSE
      IF cLanType() = "A"
         fScrBood(MAXROW()-1,"Teelwaardes van "+ALLTRIM(STR(LASTREC()))+" uit "+ALLTRIM(STR(nStart))+" diere kon nie geprosesseer word nie")
         cBood := "Druk inligting van die ongeprosesseerde diere"
      ELSE
         fScrBood(MAXROW()-1,"Breeding values for "+ALLTRIM(STR(LASTREC()))+" out of "+ALLTRIM(STR(nStart))+" animals could not be processed")
         cBood := "Print information of the unprocessed animals"
      ENDIF

      if fJaNee(maxrow(),cBood,,.f. )
         fPrint()
      endif

   ENDIF

   // Herstel
   fATclose(aCdbf)
   FERASE("SM3DATA.SSC")

   fARestScr(aCscr)
RETURN NIL

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
   fScrBood(23)

   //Convert character dates to dates
   go top

   do while ! eof()
      sm3blp1->brtdat := CTOD(SUBSTR(sm3blp1->bdate,7,2)+"/"+SUBSTR(sm3blp1->bdate,5,2)+"/"+SUBSTR(sm3blp1->bdate,1,4))
      dbskip()
   enddo

   //Skuif die databasis
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3blp1","idnomm"})
      aadd(aSend,{"sm3blp1","reknr"})
      aadd(aSend,{"sm3blp1","animname"})
      aadd(aSend,{"sm3blp1","brtdat"})
      aadd(aSend,{"sm3blp1","idvaar"})
      aadd(aSend,{"sm3blp1","rekvaar"})
      aadd(aSend,{"sm3blp1","idmoer"})
      aadd(aSend,{"sm3blp1","rekmoer"})
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
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

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Ongeprosesseerde diere word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("Diere met teelwaardes wat nie geprosesseer kon word nie")
   else
      fScrbood(24,"Unprocessed animals being printed!  [Esc]=Stop printer.")
      cHdln := upper("Animals with breeding values that could not be processed")
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
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
      //    else
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
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


