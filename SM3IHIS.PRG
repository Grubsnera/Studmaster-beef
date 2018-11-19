// SM3IHIS.PRG
// Program om massa historiese data vanaf Iris in te lees
// Kopiereg (c) AB Janse van Rensburg
// 04-05-12 14:31

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3ihis()

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
   local cData := ""
   local nCoun := 0
   local cData1 := ""
   local cData2 := ""
   local cData3 := ""
   local nReko := 0

   BEGIN SEQUENCE

      cPath := padr("A:\ANIM"+ltrim(str(val(substr(cTotNaam(),152,10))))+".CSV",50)

      DO WHILE TRUE
         lBreak := FALSE

         IF cLanType() = "A"
            fScrOpsk( ,"Opsie "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"LEES HISTORIESE DATA")
            fScrBood(MAXROW()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(MAXROW(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
         ELSE
            fScrOpsk( ,"Option "+cOption())
            nBoxc := fBoxCent(11,SPACE(50),3,"IMPORT HISTORICAL DATA")
            fScrBood(MAXROW()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(MAXROW(),"Type full file name e.g. '"+cPath+"filename.ext'")
         ENDIF

         @ 12,nboxc GET cPath PICT "@!"
         SET(_SET_CURSOR,1)
         READ
         SET(_SET_CURSOR,0)

         IF LASTKEY() == K_ESC
            lBreak := TRUE
            EXIT
         ENDIF

         IF ! FILE(alltrim(cPath))
            IF cLanType() = "A"
               fScrBood(MAXROW()-1,"Die lˆer "+alltrim(cPath)+" bestaan nie ?")
               fScrWait(MAXROW())
            ELSE
               fScrBood(MAXROW()-1,"The file "+alltrim(cPath)+" does not exist ?")
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
   aCdbf := fATopen(aCdbf,cDd(),"SM3IHIS",,,,.f.)
   IF ! aCdbf[len(aCdbf),1]
      BREAK
   ENDIF

   aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
   IF !aCdbf[len(aCdbf),1]
      BREAK
   ENDIF
   //zap

   IF cLanType() = "A"
      fScrBood(MAXROW()-1)
      fScrBood(MAXROW(),"Die lˆer "+alltrim(cPath)+" word gelees...")
   ELSE
      fScrBood(MAXROW()-1)
      fScrBood(MAXROW(),"The file "+alltrim(cPath)+" being imported...")
   ENDIF

   DBSELECTAREA("SM3IHIS")
   ZAP
   APPEND FROM (alltrim(cPath)) deli
   nStart := LASTREC()

   DBSELECTAREA("SM3DATA")
   ordsetfocus("sm3zzsu")

   DBSELECTAREA("SM3IHIS")
   DBGOTOP()

   //break

   // Screen
   if cLanType() = "A"
      fScrBood(maxrow()-1)
      fScrBood(maxrow(),"Hoofdata word omgeskakel...")
   else
      fScrBood(maxrow()-1)
      fScrBood(maxrow(),"Main data being converted...")
   endif

   DO WHILE ! EOF()

      // Screen
      fScrBood(maxrow()-1,recno())

      IF !(SM3DATA->(DBSEEK(PADL(ALLTRIM(SM3IHIS->reknrr),10,"0"))))

         DBSELECTAREA("SM3DATA")
         DBAPPEND()

         // Id number
         SM3DATA->reknr := alltrim(str(val(SM3IHIS->reknrr)))
         SM3DATA->idnr := SM3DATA->reknr
         SM3DATA->kuddek := SM3IHIS->kuddek
         SM3DATA->jaarle := SM3IHIS->jaarle
         SM3DATA->volgno := str(val(SM3IHIS->volgno))
         if !empty(SM3DATA->kuddek) .and. !empty(SM3DATA->jaarle) .and. !empty(SM3DATA->volgno)
            if isdigit(SM3DATA->jaarle)
               // Jaarsyfer
               if val(SM3DATA->volgno) > 999
                  SM3DATA->idnr := alltrim(SM3DATA->kuddek)+alltrim(SM3DATA->jaarle)+"-"+alltrim(SM3DATA->volgno)
               else
                  SM3DATA->idnr := alltrim(SM3DATA->kuddek)+alltrim(SM3DATA->jaarle)+"-"+padl(alltrim(SM3DATA->volgno),3,"0")
               endif
            else
               // Jaartal
               if val(SM3DATA->volgno) > 999
                  SM3DATA->idnr := alltrim(SM3DATA->kuddek)+alltrim(SM3DATA->jaarle)+alltrim(SM3DATA->volgno)
               else
                  SM3DATA->idnr := alltrim(SM3DATA->kuddek)+alltrim(SM3DATA->jaarle)+padl(alltrim(SM3DATA->volgno),3,"0")
               endif
            endif
         endif

         // Sire
         SM3DATA->idvaar := SM3IHIS->vaarre
         //cData1 := alltrim(substr(SM3IHIS->vaarid,5,4))
         //cData2 := alltrim(substr(SM3IHIS->vaarid,9,2))
         //cData3 := alltrim(str(val(alltrim(substr(SM3IHIS->vaarid,11,4)))))
         //if !empty(cData1) .and. !empty(cData2) .and. !empty(cData3)
         //   if isdigit(cData2)
         //     // Jaarsyfer
         //      SM3DATA->idvaar := cData1+cData2+"-"+padl(cData3,3,"0")
         //   else
         //      // Jaartal
         //      SM3DATA->idvaar := cData1+cData2+padl(cData3,3,"0")
         //   endif
         //endif

         // Dam
         SM3DATA->idmoer := SM3IHIS->moerre
         //cData1 := alltrim(substr(SM3IHIS->moerid,5,4))
         //cData2 := alltrim(substr(SM3IHIS->moerid,9,2))
         //cData3 := alltrim(str(val(alltrim(substr(SM3IHIS->moerid,11,4)))))
         //if !empty(cData1) .and. !empty(cData2) .and. !empty(cData3)
         //   if isdigit(cData2)
         //      // Jaarsyfer
         //      SM3DATA->idmoer := cData1+cData2+"-"+padl(cData3,3,"0")
         //   else
         //      // Jaartal
         //      SM3DATA->idmoer := cData1+cData2+padl(cData3,3,"0")
         //   endif
         //endif

         // Sex
         if SM3IHIS->geslag == "M"
            SM3DATA->geslag := "2"
         else
            SM3DATA->geslag := "1"
         endif

         // Date of birth
         SM3DATA->gebdatum := stodl(SM3IHIS->gebdat)

         // Owner
         if val(SM3IHIS->eienaa) == val(substr(cTotNaam(),152,10))
            SM3DATA->uitkrede := "IK"
         endif
         if !empty(SM3IHIS->uitkda)
            SM3DATA->uitkrede := "DD"
            SM3DATA->uitkdatum := stodl(SM3IHIS->uitkda)
         endif
         if !empty(SM3IHIS->kansda)
            SM3DATA->uitkrede := SM3IHIS->kansre
            SM3DATA->uitkdatum := stodl(SM3IHIS->kansda)
         endif

         // Ander data
         SM3DATA->idnaam := alltrim(SM3IHIS->voorvo)+ " " + alltrim(SM3IHIS->naammm)
         SM3DATA->generasie := SM3IHIS->afdeli
         SM3DATA->gebmassa := val(SM3IHIS->gebmas)
         SM3DATA->gekeur := SM3IHIS->gekeur
         SM3DATA->keurda := stodl(SM3IHIS->keurda)
         SM3DATA->vaarkode := SM3IHIS->dekkod
         SM3DATA->gebstat := SM3IHIS->gebsta
         SM3DATA->bloednr := SM3IHIS->bloedn
         SM3DATA->kalfstat := SM3IHIS->kalfst
         SM3DATA->kalfgem := SM3IHIS->gemakk
         SM3DATA->nagebo := SM3IHIS->nagebo
         SM3DATA->niereg := SM3IHIS->niereg
         SM3DATA->ident := SM3IHIS->idmeto
         SM3DATA->tipies := SM3IHIS->kleurk
         SM3DATA->mamoergeb := val(SM3IHIS->mamoeg)
         SM3DATA->mamoerspe := val(SM3IHIS->mamoes)
         SM3DATA->subafd := SM3IHIS->afdelo
         SM3DATA->mpresind := val(SM3IHIS->doelin)
         SM3DATA->begdatum := stodl(SM3IHIS->begdat)
         SM3DATA->begmassa := val(SM3IHIS->begmas)
         SM3DATA->eindat := stodl(SM3IHIS->eindat)
         SM3DATA->einmas := val(SM3IHIS->einmas)
         SM3DATA->daeint := val(SM3IHIS->daeint)
         SM3DATA->tydgen := val(SM3IHIS->tydgen)
         SM3DATA->rangor := val(SM3IHIS->rangor)
         SM3DATA->gdtgdt := val(SM3IHIS->gdtgdt)
         SM3DATA->gdtind := val(SM3IHIS->gdtind)
         SM3DATA->gdogdo := val(SM3IHIS->gdogdo)
         SM3DATA->gdoind := val(SM3IHIS->gdoind)
         SM3DATA->voeromset := val(SM3IHIS->voerom)
         SM3DATA->voeromseti := val(SM3IHIS->voeroi)
         SM3DATA->kleiber := val(SM3IHIS->kleibe)
         SM3DATA->kleiberi := val(SM3IHIS->kleibi)
         SM3DATA->mateskouer := val(SM3IHIS->skouer)
         SM3DATA->gekhoo := val(SM3IHIS->gekhoo)
         SM3DATA->matelengte := val(SM3IHIS->lengte)
         SM3DATA->geklen := val(SM3IHIS->geklen)
         SM3DATA->veldikte := val(SM3IHIS->veldik)
         SM3DATA->gekvel := val(SM3IHIS->gekvel)
         SM3DATA->mateskrot := val(SM3IHIS->skrotu)
         SM3DATA->gekskr := val(SM3IHIS->gekskr)
         SM3DATA->ibcoef := val(SM3IHIS->inteel)

         // Twins with
         if SM3IHIS->tweeli == "M"
            SM3DATA->tweeling := "2"
         elseif SM3IHIS->tweeli == "F"
            SM3DATA->geslag := "1"
         endif

         // 100d
         SM3DATA->kod100 := SM3IHIS->kod100
         SM3DATA->dat100 := stodl(SM3IHIS->dat100)
         SM3DATA->mas100 := val(SM3IHIS->mas100)
         SM3DATA->aan100 := val(SM3IHIS->aan100)
         SM3DATA->ple100 := val(SM3IHIS->ple100)
         SM3DATA->oud100 := val(SM3IHIS->oud100)
         SM3DATA->gma100 := val(SM3IHIS->gma100)
         SM3DATA->gdo100 := val(SM3IHIS->gdo100)
         SM3DATA->ind100 := val(SM3IHIS->ind100)

         // 205d
         SM3DATA->kod205 := SM3IHIS->kod205
         SM3DATA->dat205 := stodl(SM3IHIS->dat205)
         SM3DATA->mas205 := val(SM3IHIS->mas205)
         SM3DATA->aan205 := val(SM3IHIS->aan205)
         SM3DATA->ple205 := val(SM3IHIS->ple205)
         SM3DATA->oud205 := val(SM3IHIS->oud205)
         SM3DATA->gma205 := val(SM3IHIS->gma205)
         SM3DATA->gdo205 := val(SM3IHIS->gdo205)
         SM3DATA->ind205 := val(SM3IHIS->ind205)

         // 365d
         SM3DATA->kod365 := SM3IHIS->kod365
         SM3DATA->dat365 := stodl(SM3IHIS->dat365)
         SM3DATA->mas365 := val(SM3IHIS->mas365)
         SM3DATA->aan365 := val(SM3IHIS->aan365)
         SM3DATA->ple365 := val(SM3IHIS->ple365)
         SM3DATA->oud365 := val(SM3IHIS->oud365)
         SM3DATA->gma365 := val(SM3IHIS->gma365)
         SM3DATA->gdo365 := val(SM3IHIS->gdo365)
         SM3DATA->ind365 := val(SM3IHIS->ind365)

         // 540d
         SM3DATA->kod540 := SM3IHIS->kod540
         SM3DATA->dat540 := stodl(SM3IHIS->dat540)
         SM3DATA->mas540 := val(SM3IHIS->mas540)
         SM3DATA->aan540 := val(SM3IHIS->aan540)
         SM3DATA->ple540 := val(SM3IHIS->ple540)
         SM3DATA->oud540 := val(SM3IHIS->oud540)
         SM3DATA->gma540 := val(SM3IHIS->gma540)
         SM3DATA->gdo540 := val(SM3IHIS->gdo540)
         SM3DATA->ind540 := val(SM3IHIS->ind540)

         DBSELECTAREA("SM3IHIS")

      ENDIF

      DBSELECTAREA("SM3IHIS")
      DBDELETE()
      DBSKIP()

   ENDDO

   DBSELECTAREA("SM3IHIS")
   PACK
   DBCOMMITALL()

   // Remove duplicate id numbers
   // Screen
   if cLanType() = "A"
      fScrBood(maxrow()-1)
      fScrBood(maxrow(),"Duplikaat id nommers word omgeskakel...")
   else
      fScrBood(maxrow()-1)
      fScrBood(maxrow(),"Duplicate id numbers being converted...")
   endif
   dbselectarea("SM3DATA")
   ordsetfocus("sm3zzsv")
   go top
   cData := SM3DATA->idnr
   nCoun := 1
   nReko := recno()
   dbskip()
   do while !eof()

      // Screen
      fScrBood(maxrow()-1,recno())

      if SM3DATA->idnr == cData
         SM3DATA->idnr := alltrim(SM3DATA->idnr)+"/"+alltrim(str(nCoun))
         nCoun++
         goto nReko
      else
         cData := SM3DATA->idnr
         nCoun := 1
         nReko := recno()
      endif

      dbselectarea("SM3DATA")
      dbskip()

   enddo

   // Calculate sire and dam id numbers
   // Screen
   altd()
   if cLanType() = "A"
      fScrBood(maxrow()-1)
      fScrBood(maxrow(),"Ouers word omgeskakel...")
   else
      fScrBood(maxrow()-1)
      fScrBood(maxrow(),"Parents being converted...")
   endif
   dbselectarea("SM3DATA")
   ordsetfocus("sm3zzsu")
   go top
   do while !eof()

      // Screen
      fScrBood(maxrow()-1,recno())
      nReko := recno()

      // Debug
      if SM3DATA->idnr = "JHL05-015"
         altd()
      endif

      // Sire
      if !empty(SM3DATA->idvaar)
         if dbseek(padl(alltrim(SM3DATA->idvaar),10,"0"))
            cData := SM3DATA->idnr
            goto nReko
            SM3DATA->idvaar := cData
         else
            goto nReko
         endif
      endif

      // Dam
      if !empty(SM3DATA->idmoer)
         if dbseek(padl(alltrim(SM3DATA->idmoer),10,"0"))
            cData := SM3DATA->idnr
            goto nReko
            SM3DATA->idmoer := cData
         else
            goto nReko
         endif
      endif

      // Next record
      goto nReko
      dbselectarea("SM3DATA")
      dbskip()

   enddo

   // Herstel
   fATclose(aCdbf)
   fARestScr(aCscr)

RETURN NIL
