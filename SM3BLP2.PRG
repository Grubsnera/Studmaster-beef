// SM3BLP2.PRG
// Program om massa teelwaardes in te lees
// Kopiereg (c) AB Janse van Rensburg
// 12-06-05 09:13

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3blp2()

   // Veranderlikes
   LOCAL nSouh := 0                              // Source text file handle
   LOCAL nDesh := 0                              // Destination text file
   LOCAL nReco := 0
   LOCAL nLast := 0
   LOCAL cText := ""
   LOCAL cNewt := ""
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3IMPO",,,,.f.)
      IF ! aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3BLP2",,,,.f.)
      IF ! aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      //Step one to convert the data received from studbook
      //Read the raw data file, remove all " and write each data line to
      //SM3IMPO.DBF

      IF cLanType() = "A"
         fScrBood(MAXROW(),"Die lˆer "+alltrim(cPath)+" word omgeskakel. Stap 1...")
         fScrBood(MAXROW()-1)
      ELSE
         fScrBood(MAXROW(),"The file "+alltrim(cPath)+" being converted. Step 1...")
         fScrBood(MAXROW()-1)
      ENDIF

      // Prepare the file to receive data
      DBSELECTAREA("SM3IMPO")
      ZAP

      // Open and read the text file
      nSouh := ft_fuse(cPath)
      nReco := 1
      nLast := ft_flastre()
      ft_fgotop()
      do while !ft_feof()

         // Screen
         fScrBood(MAXROW()-1,alltrim(str(ft_frecno()))+"/"+alltrim(str(nLast))+" "+str((nReco/nLast)*100,3,0)+"%")
         //@ 4,57 say alltrim(str(ft_frecno()))+"/"+alltrim(str(nLast))+" "+str((nReco/nLast)*100,3,0)+"%"

         // Populate string
         cText := ft_freadln()
         cNewt := strtran(cText,'"','')
         //Save the data string
         dbappend()
         SM3IMPO->text := cNewt

         // Next record
         ft_fskip()
         nReco++

      enddo

      // Close the text file
      ft_fuse()

      //Step two to convert the studbook blup data
      //Write SM3IMPO records to Export.txt

      IF cLanType() = "A"
         fScrBood(MAXROW(),"Die lˆer "+alltrim(cPath)+" word omgeskakel. Stap 2...")
         fScrBood(MAXROW()-1)
      ELSE
         fScrBood(MAXROW(),"The file "+alltrim(cPath)+" being converted. Step 2...")
         fScrBood(MAXROW()-1)
      ENDIF

      //Create a new text file from the imports
      nDesh := fcreate("Export.txt")
      DBSELECTAREA("SM3IMPO")
      dbgobottom()
      nLast := recno()
      dbgotop()
      do while !(eof())

         fScrBood(MAXROW()-1,alltrim(str(recno()))+"/"+alltrim(str(nLast))+" "+str((nReco/nLast)*100,3,0)+"%")

         //Write the line
         fwrite(nDesh,alltrim(SM3IMPO->text)+chr(10))

         //Next record
         dbskip()

      enddo
      fclose(nDesh)

      DBSELECTAREA("SM3BLP2")
      ZAP
      APPEND FROM "Export.txt" deli
      nStart := LASTREC()

      DBSELECTAREA("SM3DATA")
      ordsetfocus("sm3zzsu")

      DBSELECTAREA("SM3BLP2")
      DBGOTOP()

      DO WHILE ! EOF()

         IF SM3DATA->(DBSEEK(PADL(ALLTRIM(SM3BLP2->reknr),10,"0")))

            DBSELECTAREA("SM3DATA")
            DO WHILE ! RLOCK()
            ENDDO

            // Transfer the data
            SM3DATA->birdir := SM3BLP2->birdir
            SM3DATA->biracc := SM3BLP2->birdira
            SM3DATA->birmat := SM3BLP2->birmat
            SM3DATA->birmac := SM3BLP2->birmata
            SM3DATA->eocdir := SM3BLP2->caltem
            SM3DATA->eocacc := SM3BLP2->caltema
            SM3DATA->weadir := SM3BLP2->weadir
            SM3DATA->weaacc := SM3BLP2->weadira
            SM3DATA->weamat := SM3BLP2->weamat
            SM3DATA->weamac := SM3BLP2->weamata
            SM3DATA->weacom := SM3BLP2->weacom
            SM3DATA->yeadir := SM3BLP2->yeadir
            SM3DATA->yeaacc := SM3BLP2->yeadira
            SM3DATA->m18dir := SM3BLP2->m18dir
            SM3DATA->m18acc := SM3BLP2->m18dira
            SM3DATA->feidir := SM3BLP2->feeint
            SM3DATA->feiacc := SM3BLP2->feeinta
            SM3DATA->pcfcrd := SM3BLP2->feecon
            SM3DATA->pcfcra := SM3BLP2->feecona
            SM3DATA->findir := SM3BLP2->feepro
            SM3DATA->finacc := SM3BLP2->feeproa
            SM3DATA->mcwdir := SM3BLP2->matwei
            SM3DATA->mcwacc := SM3BLP2->matweia
            SM3DATA->stadir := SM3BLP2->sta
            SM3DATA->staacc := SM3BLP2->staa
            SM3DATA->adgdir := SM3BLP2->adgdir
            SM3DATA->adgacc := SM3BLP2->adgdira
            SM3DATA->kledir := SM3BLP2->kledir
            SM3DATA->kleacc := SM3BLP2->kledira
            SM3DATA->scrdir := SM3BLP2->scrdir
            SM3DATA->scracc := SM3BLP2->scrdira
            SM3DATA->hgtdir := SM3BLP2->hgtdir
            SM3DATA->hgtacc := SM3BLP2->hgtdira
            SM3DATA->lgtdir := SM3BLP2->bodlen
            SM3DATA->lgtacc := SM3BLP2->bodlena
            SM3DATA->fatdir := SM3BLP2->fatthi
            SM3DATA->fatacc := SM3BLP2->fatthia
            SM3DATA->eyedir := SM3BLP2->eyemus
            SM3DATA->eyeacc := SM3BLP2->eyemusa
            SM3DATA->ribdir := SM3BLP2->marbli
            SM3DATA->ribacc := SM3BLP2->marblia
            SM3DATA->oekdir := SM3BLP2->agefir
            SM3DATA->oekacc := SM3BLP2->agefira
            SM3DATA->tkpdir := SM3BLP2->icp
            SM3DATA->tkpacc := SM3BLP2->icpa
            SM3DATA->cowdir := SM3BLP2->cowpro
            SM3DATA->cowacc := SM3BLP2->cowproa
            SM3DATA->cardir := SM3BLP2->dreper
            SM3DATA->caracc := SM3BLP2->drepera
            SM3DATA->kmedir := SM3BLP2->kgmeat
            SM3DATA->kmeacc := SM3BLP2->kgmeata
            SM3DATA->coedir := SM3BLP2->coweff
            SM3DATA->coeacc := SM3BLP2->coweffa
            SM3DATA->powdir := SM3BLP2->poswea
            SM3DATA->powacc := SM3BLP2->posweaa
            SM3DATA->prodir := SM3BLP2->proind
            SM3DATA->proacc := SM3BLP2->proinda
            SM3DATA->eocmat := SM3BLP2->coweas
            SM3DATA->eocmac := SM3BLP2->coweasa
            SM3DATA->comdir := SM3BLP2->cowmil
            SM3DATA->comacc := SM3BLP2->cowmila
            SM3DATA->cogdir := SM3BLP2->cowgro
            SM3DATA->cogacc := SM3BLP2->cowgroa
            SM3DATA->cohdir := SM3BLP2->cowhei
            SM3DATA->cohacc := SM3BLP2->cowheia
            SM3DATA->cordir := SM3BLP2->cowrep
            SM3DATA->coracc := SM3BLP2->cowrepa

            SM3DATA->ibcoef := SM3BLP2->ibcoef

            // Test for phase a b date
            if SM3BLP2->birdir == 0 .and. SM3BLP2->weadir == 0 .and. ;
                  SM3BLP2->yeadir == 0 .and. SM3BLP2->m18dir == 0
               SM3DATA->analdate   := ctod("")
            else
               SM3DATA->analdate := SM3BLP2->analdate
            endif

            // Test for phase d date
            if SM3BLP2->adgdir == 0 .and. SM3BLP2->kledir == 0 .and. ;
                  SM3BLP2->scrdir == 0 .and. SM3BLP2->hgtdir == 0
               SM3DATA->phddat   := ctod("")
            else
               SM3DATA->phddat   := SM3BLP2->analdate
            endif

            DBSELECTAREA("SM3BLP2")
            DBDELETE()

         ENDIF

         DBSELECTAREA("SM3BLP2")
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
      aadd(aSend,{"SM3BLP2","idnomm"})
      aadd(aSend,{"SM3BLP2","geslag"})
      aadd(aSend,{"SM3BLP2","bdate"})
      aadd(aSend,{"SM3BLP2","reknr"})
      aadd(aSend,{"SM3BLP2","animname"})
      aadd(aSend,{"SM3BLP2","idvaar"})
      aadd(aSend,{"SM3BLP2","rekvaar"})
      aadd(aSend,{"SM3BLP2","idmoer"})
      aadd(aSend,{"SM3BLP2","rekmoer"})
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
