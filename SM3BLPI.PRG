// SM3BLPI.PRG
// Program om massa teelwaardes in te lees
// Kopiereg (c) AB Janse van Rensburg
// 04-06-98 11:12am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3blpi()

   // Veranderlikes
   LOCAL aCscr   := fASaveScr()
   LOCAL aCdbf   := fATopen()
   LOCAL cPath   := ""
   LOCAL cBood   := ""
   LOCAL nStart  := 0
   LOCAL nBoxc   := 0
   LOCAL lBreak  := FALSE
   LOCAL GETLIST := {}
   local cDate := ""

   begin sequence

      cPath := padr(cMailTar()+ltrim(str(val(substr(cTotNaam(),152,10))))+".CSV",50)

      do while .t.

         lBreak := .f.

         if cLanType() = "A"
            fScrOpsk( ,"Opsie "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"LEES MASSA TEELWAARDES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
         else
            fScrOpsk( ,"Option "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"IMPORT MASS BREEDING VALUES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow(),"Type full file name e.g. '"+cPath+"filename.ext'")
         endif

         @ 12,nboxc get cPath PICT "@K!"
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         if lastkey() == K_ESC
            lBreak := .t.
            exit
         endif

         if !(file(alltrim(cPath)))

            //   if cLanType() = "A"
            //      fScrBood(MAXROW()-1,"Die lˆer "+alltrim(cPath)+" bestaan nie ?")
            //      fScrWait(MAXROW())
            //   else
            //      fScrBood(MAXROW()-1,"The file "+alltrim(cPath)+" does not exist ?")
            //      fScrWait(MAXROW())
            //   endif

            if cLanType() = "A"
               cPath := fFilePick("LEES BERAAMDE TEELWAARDES",alltrim(cPath),"*.*","D","D")
            else
               cPath := fFilePick("IMPORT ESTIMATED BREEDING VALUES",alltrim(cPath),"*.csv","D","D")
            endif

            if empty(cPath)

               cPath := padr(cMailTar()+ltrim(str(val(substr(cTotNaam(),152,10))))+".CSV",50)
               loop

            elseif cPath == "Esc"

               // Exit to menu
               break

            else

               exit

            endif

         else

            exit

         endif

      enddo

      if lBreak
         break
      endif

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
         fScrBood(MAXROW(),"Die lˆer "+alltrim(cPath)+" word gelees...")
         fScrBood(MAXROW()-1)
      ELSE
         fScrBood(MAXROW(),"The file "+alltrim(cPath)+" being imported...")
         fScrBood(MAXROW()-1)
      ENDIF

      DBSELECTAREA("SM3BLP1")
      ZAP
      APPEND FROM (alltrim(cPath)) deli
      nStart := LASTREC()

      DBSELECTAREA("SM3DATA")
      ordsetfocus("sm3zzsu")

      DBSELECTAREA("SM3BLP1")
      DBGOTOP()

      DO WHILE ! EOF()

         IF SM3DATA->(DBSEEK(PADL(ALLTRIM(SM3BLP1->reknr),10,"0")))

            DBSELECTAREA("SM3DATA")
            DO WHILE ! RLOCK()
            ENDDO
            SM3DATA->birdir   := ROUND(SM3BLP1->birdir,2)
            if SM3BLP1->biracc < 100
               SM3DATA->biracc   := ROUND(SM3BLP1->biracc,0)
            else
               SM3DATA->biracc   := 99
            endif
            SM3DATA->birmat   := ROUND(SM3BLP1->birmat,2)
            if SM3BLP1->birmac < 100
               SM3DATA->birmac   := ROUND(SM3BLP1->birmac,0)
            else
               SM3DATA->birmac   := 99
            endif
            SM3DATA->eocdir   := ROUND(SM3BLP1->eocdir,2)
            if SM3BLP1->eocacc < 100
               SM3DATA->eocacc   := ROUND(SM3BLP1->eocacc,0)
            else
               SM3DATA->eocacc   := 99
            endif
            SM3DATA->weadir   := ROUND(SM3BLP1->weadir,2)
            if SM3BLP1->weaacc < 100
               SM3DATA->weaacc   := ROUND(SM3BLP1->weaacc,0)
            else
               SM3DATA->weaacc   := 99
            endif
            SM3DATA->weamat   := ROUND(SM3BLP1->weamat,2)
            if SM3BLP1->weamac < 100
               SM3DATA->weamac   := ROUND(SM3BLP1->weamac,0)
            else
               SM3DATA->weamac   := 99
            endif
            SM3DATA->weacom   := ROUND(SM3BLP1->weacom,2)
            SM3DATA->yeadir   := ROUND(SM3BLP1->yeadir,2)
            if SM3BLP1->yeaacc < 100
               SM3DATA->yeaacc   := ROUND(SM3BLP1->yeaacc,0)
            else
               SM3DATA->yeaacc   := 99
            endif
            SM3DATA->m18dir   := ROUND(SM3BLP1->m18dir,2)
            if SM3BLP1->m18acc < 100
               SM3DATA->m18acc   := ROUND(SM3BLP1->m18acc,0)
            else
               SM3DATA->m18acc   := 99
            endif
            SM3DATA->adgdir   := ROUND(SM3BLP1->adgdir,2)
            if SM3BLP1->adgacc < 100
               SM3DATA->adgacc   := ROUND(SM3BLP1->adgacc,0)
            else
               SM3DATA->adgacc   := 99
            endif
            SM3DATA->kledir   := ROUND(SM3BLP1->pcadgd,2)
            if SM3BLP1->pcadga < 100
               SM3DATA->kleacc   := ROUND(SM3BLP1->pcadga,0)
            else
               SM3DATA->kleacc   := 99
            endif
            SM3DATA->scrdir   := ROUND(SM3BLP1->scrdir,2)
            if SM3BLP1->scracc < 100
               SM3DATA->scracc   := ROUND(SM3BLP1->scracc,0)
            else
               SM3DATA->scracc   := 99
            endif
            SM3DATA->hgtdir   := ROUND(SM3BLP1->hgtdir,2)
            if SM3BLP1->hgtacc < 100
               SM3DATA->hgtacc   := ROUND(SM3BLP1->hgtacc,0)
            else
               SM3DATA->hgtacc   := 99
            endif
            SM3DATA->lgtdir   := ROUND(SM3BLP1->lgtdir,2)
            if SM3BLP1->lgtacc < 100
               SM3DATA->lgtacc   := ROUND(SM3BLP1->lgtacc,0)
            else
               SM3DATA->lgtacc   := 99
            endif
            SM3DATA->pcfcrd   := ROUND(SM3BLP1->pcfcrd,2)
            if SM3BLP1->pcfcra < 100
               SM3DATA->pcfcra   := ROUND(SM3BLP1->pcfcra,0)
            else
               SM3DATA->pcfcra   := 99
            endif
            SM3DATA->ibcoef   := ROUND(SM3BLP1->ibcoef,2)
            SM3DATA->findir   := ROUND(SM3BLP1->pcscrd,2)
            if SM3BLP1->pcscra < 100
               SM3DATA->finacc   := ROUND(SM3BLP1->pcscra,0)
            else
               SM3DATA->finacc   := 99
            endif
            SM3DATA->mcwdir   := ROUND(SM3BLP1->pchgtd,  0)
            if SM3BLP1->pchgta < 100
               SM3DATA->mcwacc   := ROUND(SM3BLP1->pchgta,0)
            else
               SM3DATA->mcwacc   := 99
            endif

            // Inter calf period
            SM3DATA->tkpdir := ROUND(SM3BLP1->icpbv,1)
            if SM3BLP1->icpacc < 100
               SM3DATA->tkpacc := ROUND(SM3BLP1->icpacc,0)
            else
               SM3DATA->tkpacc   := 99
            endif

            // Age first calf
            SM3DATA->oekdir := ROUND(SM3BLP1->afcbv,1)
            if SM3BLP1->afcacc < 100
               SM3DATA->oekacc := ROUND(SM3BLP1->afcacc,0)
            else
               SM3DATA->afcacc   := 99
            endif

            // Inter mascular fat - ribvet - marmering
            SM3DATA->ribdir := ROUND(SM3BLP1->imfbv,1)
            if SM3BLP1->imfacc < 100
               SM3DATA->ribacc := ROUND(SM3BLP1->imfacc,0)
            else
               SM3DATA->ribacc   := 99
            endif

            // Karkasmassa - dressage
            SM3DATA->cardir := ROUND(SM3BLP1->dresbv,1)
            if SM3BLP1->dresacc < 100
               SM3DATA->caracc := ROUND(SM3BLP1->dresacc,0)
            else
               SM3DATA->caracc   := 99
            endif

            // Koeiwins
            SM3DATA->cowdir := ROUND(SM3BLP1->cowbv,2)
            if SM3BLP1->cowacc < 100
               SM3DATA->cowacc := ROUND(SM3BLP1->cowacc,0)
            else
               SM3DATA->cowacc   := 99
            endif

            // Koeidoeltreffendheid
            SM3DATA->coedir := ROUND(SM3BLP1->cowefbv,1)
            if SM3BLP1->cowefacc < 100
               SM3DATA->coeacc := ROUND(SM3BLP1->cowefacc,0)
            else
               SM3DATA->coeacc   := 99
            endif

            // Vleisopbrengs
            SM3DATA->kmedir := ROUND(SM3BLP1->kmeatbv,1)
            if SM3BLP1->kmeatacc < 100
               SM3DATA->kmeacc := ROUND(SM3BLP1->kmeatacc,0)
            else
               SM3DATA->kmeacc   := 99
            endif

            if SM3BLP1->birdir == 0 .and. SM3BLP1->weadir == 0 .and. ;
                  SM3BLP1->yeadir == 0 .and. SM3BLP1->m18dir == 0
               SM3DATA->analdate   := ctod("")
            else
               SM3DATA->analdate := SM3BLP1->analdate
            endif


            // Test for phase d date
            if SM3BLP1->adgdir == 0 .and. SM3BLP1->kledir == 0 .and. ;
                  SM3BLP1->scrdir == 0 .and. SM3BLP1->hgtdir == 0
               SM3DATA->phddat   := ctod("")
            else
               SM3DATA->phddat   := SM3BLP1->analdate
            endif
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
            fScrBood(MAXROW()-1,"Teelwaardes van "+ALLTRIM(STR(LASTREC()))+" uit "+ALLTRIM(STR(nStart))+" diere kon nie gelees word nie")
            cBood := "Druk inligting van die ongeprosesseerde diere"
         ELSE
            fScrBood(MAXROW()-1,"Breeding values for "+ALLTRIM(STR(LASTREC()))+" out of "+ALLTRIM(STR(nStart))+" animals could not be read")
            cBood := "Print information of the unprocessed animals"
         ENDIF

         if fJaNee(maxrow(),cBood,,.f. )
            fPrint()
         endif

      ENDIF

   end

   // Herstel
   fATclose(aCdbf)
   //FERASE("SM3DATA.SSC")

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

   //Skuif die databasis
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3blp1","idnomm"})
      aadd(aSend,{"sm3blp1","geslag"})
      aadd(aSend,{"sm3blp1","bdate"})
      aadd(aSend,{"sm3blp1","reknr"})
      aadd(aSend,{"sm3blp1","animname"})
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
