// SM3IGES.PRG
// Program om Iris historiese data in te lees
// Kopiereg (c) AB Janse van Rensburg
// 10-10-24 08:52

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION sm3iges()

   // Veranderlikes
   LOCAL aCscr   := fASaveScr()
   LOCAL aCdbf   := fATopen()
   LOCAL nAppe   := 1
   LOCAL nOver   := 1
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
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local cVaai := ""
   local cVaar := ""
   local cMoer := ""
   local cMoei := ""

   BEGIN SEQUENCE

      if cLanType() = "A"
         cPath := fFilePick("LEES GESKIENDENIS",cMailTar(),"beefd*.csv","D","D")
      else
         cPath := fFilePick("IMPORT HISTORY",cMailTar(),"beefd*.csv","D","D")
      endif

      if empty(cPath)

         // Ask for file name

         // Build path
         cPath := padr(cMailTar()+"BEEFDATA.CSV",50)

         do while .t.

            lBreak := .f.

            if cLanType() = "A"
               fScrOpsk( ,"Opsie "+cOption())
               nBoxc := fBoxCent(11,SPACE(50),3,"LEES GESKIEDENIS")
               fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
               fScrBood(maxrow(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
            else
               fScrOpsk( ,"Option "+cOption())
               nBoxc := fBoxCent(11,SPACE(50),3,"IMPORT HISTORY")
               fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
               fScrBood(maxrow(),"Type full file name e.g. '"+cPath+"filename.ext'")
            endif

            @ 12,nboxc get cPath PICT "@!"
            set(_SET_CURSOR,1)
            read
            set(_SET_CURSOR,0)

            if lastkey() == K_ESC
               lBreak := .t.
               exit
            endif

            if !(file(alltrim(cPath)))
               if cLanType() = "A"
                  fScrBood(MAXROW()-1,"Die lˆer "+alltrim(cPath)+" bestaan nie ?")
                  fScrWait(MAXROW())
               else
                  fScrBood(MAXROW()-1,"The file "+alltrim(cPath)+" does not exist ?")
                  fScrWait(MAXROW())
               endif
            else
               exit
            endif
         enddo

         IF lBreak
            BREAK
         ENDIF

      elseif cPath == "Esc"

         // Exit to menu
         break

      endif

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3IGES",,,,.f.)
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

      DBSELECTAREA("SM3IGES")
      ZAP
      APPEND FROM (alltrim(cPath)) deli

      // Delete header records
      dbgotop()
      dbdelete()
      pack
      dbcommitall()

      nStart := LASTREC()

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"Geskiedenisdata word gelees...")
      else
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"Historic data being imported...")
      endif

      DO WHILE ! EOF()

         // Screen
         fScrBood(maxrow()-1,recno())

         // 008 Get the id number
         cData := fConvIrisId(SM3IGES->idno)

         // If no number
         if empty(cData)
            // Next record
            dbselectarea("SM3IGES")
            dbskip()
            loop
         endif

         // Seek the animal in main file
         select SM3DATA
         go top
         seek cData

         if !found()

            // Add animal
            if nAppe = 1
               dbappend()
               SM3DATA->idnr := cData
            else
               // Next record
               dbselectarea("SM3IGES")
               dbskip()
               loop
            endif

         endif

         // 009 Registrasienommer
         if !empty(SM3IGES->reknr)
            if nOver == 1 .or. empty(SM3DATA->reknr) .and. nOver == 0
               SM3DATA->reknr := alltrim(str(val(SM3IGES->reknr)))
            endif
         endif

         // 001 Dummy gen
         // 002 Dummy ani_id
         // 003 Dummy raskode

         // 004 Store sex of animal
         if !empty(SM3IGES->geslag)
            if nOver == 1 .or. empty(SM3DATA->geslag) .and. nOver == 0
               if SM3IGES->geslag == "M"
                  SM3DATA->geslag := "2"
               else
                  SM3DATA->geslag := "1"
               endif
            endif
         endif

         // 005 Kuddekenmerk
         if !empty(SM3IGES->kuddek)
            if nOver == 1 .or. empty(SM3DATA->kuddek) .and. nOver == 0
               SM3DATA->kuddek := alltrim(SM3IGES->kuddek)
            endif
         endif

         // 006 Jaarletter
         if !empty(SM3IGES->jaarle)
            if nOver == 1 .or. empty(SM3DATA->jaarle) .and. nOver == 0
               SM3DATA->jaarle := alltrim(SM3IGES->jaarle)
            endif
         endif

         // 007 Volgnommer
         if !empty(SM3IGES->volgno)
            if nOver == 1 .or. empty(SM3DATA->volgno) .and. nOver == 0
               SM3DATA->volgno := alltrim(SM3IGES->volgno)
            endif
         endif

         // 008 Id nommer reeds gedoen
         // 009 Registrasienommer reeds gedoen

         // 010 011 Store name of animal
         if !empty(SM3IGES->naam)
            if nOver == 1 .or. empty(SM3DATA->idnaam) .and. nOver == 0
               cData := alltrim(SM3IGES->naamvv) + " " + alltrim(SM3IGES->naam)
               SM3DATA->idnaam := alltrim(cData)
            endif
         endif

         // 012 013 Sire ************************************************************

         // 012 Vaar
         cVaai := fConvIrisId(SM3IGES->vaarnom)
         if !empty(cVaai)
            if nOver == 1 .or. empty(SM3DATA->idvaar) .and. nOver == 0
               SM3DATA->idvaar := cVaai
            endif
         endif
         cVaar := SM3IGES->vaarreg
         // Doen verwerking later

         // 014 015 Damm ************************************************************

         cMoei := fConvIrisId(SM3IGES->moernom)
         if !empty(cMoei)
            if nOver == 1 .or. empty(SM3DATA->idmoer) .and. nOver == 0
               SM3DATA->idmoer := cMoei
            endif
         endif
         cMoer := SM3IGES->moerreg
         // Doen verwerking later

         // 016 Afdeling generasie
         if !empty(SM3IGES->generasie)
            if nOver == 1 .or. empty(SM3DATA->generasie) .and. nOver == 0
               SM3DATA->generasie := alltrim(SM3IGES->generasie)
            endif
         endif

         // 017 Oafdeling subafd
         if !empty(SM3IGES->subafd)
            if nOver == 1 .or. empty(SM3DATA->subafd) .and. nOver == 0
               SM3DATA->subafd := alltrim(SM3IGES->subafd)
            endif
         endif

         // 018 telernommer
         // 019 in kudde


         // 020 Eiendatum datum op rekenaar
         if !empty(SM3IGES->dumm006)
            if nOver == 1 .or. empty(SM3DATA->dataan) .and. nOver == 0
               set century on
               SM3DATA->dataan := stodl(SM3IGES->dumm006)
               set century off
            endif
         endif

         // 021 Einddatum dummy

         // 022 Gebdatum
         if !empty(SM3IGES->gebdatum)
            if nOver == 1 .or. empty(SM3DATA->gebdatum) .and. nOver == 0
               SM3DATA->gebdatum := stodl(SM3IGES->gebdatum)
            endif
         endif

         // 023 Gebmassa
         if !empty(SM3IGES->gebmassa)
            if nOver == 1 .or. empty(SM3DATA->gebmassa) .and. nOver == 0
               SM3DATA->gebmassa := val(SM3IGES->gebmassa)
            endif
         endif

         // 024 ggreliable
         // 025 ggdtm
         // 026 spmassa
         // 027 spgreliable
         // 028 spgdtm
         // 029 afgoedgekeur

         // 030 Inspeksiedatum
         if !empty(SM3IGES->keurda)
            if nOver == 1 .or. empty(SM3DATA->keurda) .and. nOver == 0
               SM3DATA->keurda := stodl(SM3IGES->keurda)
            endif
         endif

         // 031 033 Date died
         if !empty(SM3IGES->dooddat)
            if nOver == 1 .or. empty(SM3DATA->dooddat) .and. nOver == 0
               SM3DATA->uitkdatum := stodl(SM3IGES->dooddat)
               SM3DATA->uitkrede := "DD"
            endif
         endif

         // 032 033 Date cancelled
         if !empty(SM3IGES->kansdat)
            if nOver == 1 .or. empty(SM3DATA->kansdat) .and. nOver == 0
               SM3DATA->uitkdatum := stodl(SM3IGES->kansdat)
               SM3DATA->uitkrede := SM3IGES->uitkrede + SM3IGES->uitkrede
            endif
         endif

         // 019 Owner waar is dier kode
         if !empty(SM3IGES->dumm005) .and. empty(SM3DATA->uitkdatum)
            if nOver == 1 .or. empty(SM3DATA->uitkrede) .and. nOver == 0
               if val(SM3IGES->dumm005) == val(substr(cTotNaam(),152,10))
                  if cLanType() = "A"
                     SM3DATA->uitkrede := "IK"
                  else
                     SM3DATA->uitkrede := "IH"
                  endif
               endif
            endif
         endif

         // 034 Dekkode
         if !empty(SM3IGES->vaarkode)
            if nOver == 1 .or. empty(SM3DATA->vaarkode) .and. nOver == 0
               SM3DATA->vaarkode := SM3IGES->vaarkode
            endif
         endif

         // 035 Geboortestatus
         if !empty(SM3IGES->gebstat)
            if nOver == 1 .or. empty(SM3DATA->gebstat) .and. nOver == 0
               SM3DATA->gebstat := SM3IGES->gebstat
            endif
         endif

         // 036 Tweeling met
         if !empty(SM3IGES->tweeling)
            if nOver == 1 .or. empty(SM3DATA->tweeling) .and. nOver == 0
               SM3DATA->tweeling := SM3IGES->tweeling
            endif
         endif

         // 037 Bloedlabnommer
         if !empty(SM3IGES->bloednr)
            if nOver == 1 .or. empty(SM3DATA->bloednr) .and. nOver == 0
               SM3DATA->bloednr := SM3IGES->bloednr
            endif
         endif

         // 038 Kalfstatus
         if !empty(SM3IGES->kalfstat)
            if nOver == 1 .or. empty(SM3DATA->kalfstat) .and. nOver == 0
               SM3DATA->kalfstat := SM3IGES->kalfstat
            endif
         endif

         // 039 Gemak van kalwing
         if !empty(SM3IGES->kalfgem)
            if nOver == 1 .or. empty(SM3DATA->kalfgem) .and. nOver == 0
               SM3DATA->kalfgem := SM3IGES->kalfgem
            endif
         endif

         // 040 Na geboorte opmerking
         if !empty(SM3IGES->nagebo)
            if nOver == 1 .or. empty(SM3DATA->nagebo) .and. nOver == 0
               SM3DATA->nagebo := SM3IGES->nagebo
            endif
         endif

         // 041 Nie vir registrasie
         if !empty(SM3IGES->niereg)
            if nOver == 1 .or. empty(SM3DATA->niereg) .and. nOver == 0
               SM3DATA->niereg := SM3IGES->niereg
            endif
         endif

         // 042 Id metode
         if !empty(SM3IGES->ident)
            if nOver == 1 .or. empty(SM3DATA->ident) .and. nOver == 0
               SM3DATA->ident := SM3IGES->ident
            endif
         endif

         // 043 Kleurkode
         if !empty(SM3IGES->tipies)
            if nOver == 1 .or. empty(SM3DATA->tipies) .and. nOver == 0
               SM3DATA->tipies := SM3IGES->tipies
            endif
         endif

         // 044 Moermass met geboorte
         if !empty(SM3IGES->mamoergeb)
            if nOver == 1 .or. empty(SM3DATA->mamoergeb) .and. nOver == 0
               SM3DATA->mamoergeb := val(SM3IGES->mamoergeb)
            endif
         endif

         // 045 Moermass met speen
         if !empty(SM3IGES->mamoerspe)
            if nOver == 1 .or. empty(SM3DATA->mamoerspe) .and. nOver == 0
               SM3DATA->mamoerspe := val(SM3IGES->mamoerspe)
            endif
         endif

         // 046 Moer doeltreffendheid indeks
         if !empty(SM3IGES->mpresind)
            if nOver == 1 .or. empty(SM3DATA->mpresind) .and. nOver == 0
               SM3DATA->mpresind := val(SM3IGES->mpresind)
            endif
         endif

         // 047 Abnormaliteit1 dumm013
         // 048 Abnormaliteit2 dumm014
         // 049 Abnormaliteit3 dumm015

         // 050 Horings
         if !empty(SM3IGES->type)
            if nOver == 1 .or. empty(SM3DATA->type) .and. nOver == 0
               SM3DATA->type := SM3IGES->type
            endif
         endif

         // 051 Dierstatus
         if !empty(SM3IGES->kalfbnr)
            if nOver == 1 .or. empty(SM3DATA->kalfbnr) .and. nOver == 0
               SM3DATA->kalfbnr := SM3IGES->kalfbnr
            endif
         endif

         // 052 Perfrecorded dumm 016
         // 053 Country code dumm 017

         // Voorspeen a1 indeks **********************************************

         // 054 A1 indekskode
         if !empty(SM3IGES->kod100)
            if nOver == 1 .or. empty(SM3DATA->kod100) .and. nOver == 0
               SM3DATA->kod100 := SM3IGES->kod100
            endif
         endif

         // 055 A1 weegdatum
         if !empty(SM3IGES->dat100)
            if nOver == 1 .or. empty(SM3DATA->dat100) .and. nOver == 0
               SM3DATA->dat100 := stodl(SM3IGES->dat100)
            endif
         endif

         // 056 A1 massa
         if !empty(SM3IGES->mas100)
            if nOver == 1 .or. empty(SM3DATA->mas100) .and. nOver == 0
               SM3DATA->mas100 := val(SM3IGES->mas100)
            endif
         endif

         // 057 A1 tydgenote
         if !empty(SM3IGES->aan100)
            if nOver == 1 .or. empty(SM3DATA->aan100) .and. nOver == 0
               SM3DATA->aan100 := val(SM3IGES->aan100)
            endif
         endif

         // 058 A1 rangorde
         if !empty(SM3IGES->ple100)
            if nOver == 1 .or. empty(SM3DATA->ple100) .and. nOver == 0
               SM3DATA->ple100 := val(SM3IGES->ple100)
            endif
         endif

         // 059 A1 ouderdom
         if !empty(SM3IGES->oud100)
            if nOver == 1 .or. empty(SM3DATA->oud100) .and. nOver == 0
               SM3DATA->oud100 := val(SM3IGES->oud100)
            endif
         endif

         // 060 A1 korr massa
         if !empty(SM3IGES->gma100)
            if nOver == 1 .or. empty(SM3DATA->gma100) .and. nOver == 0
               SM3DATA->gma100 := val(SM3IGES->gma100)
            endif
         endif

         // 061 A1 gdo
         if !empty(SM3IGES->gdo100)
            if nOver == 1 .or. empty(SM3DATA->gdo100) .and. nOver == 0
               SM3DATA->gdo100 := val(SM3IGES->gdo100)
            endif
         endif

         // 062 A1 indeks
         if !empty(SM3IGES->ind100)
            if nOver == 1 .or. empty(SM3DATA->ind100) .and. nOver == 0
               SM3DATA->ind100 := val(SM3IGES->ind100)
            endif
         endif

         // Speen A2 indeks **********************************************

         // 063 A2 indekskode
         if !empty(SM3IGES->kod205)
            if nOver == 1 .or. empty(SM3DATA->kod205) .and. nOver == 0
               SM3DATA->kod205 := SM3IGES->kod205
            endif
         endif

         // 064 A2 weegdatum
         if !empty(SM3IGES->dat205)
            if nOver == 1 .or. empty(SM3DATA->dat205) .and. nOver == 0
               SM3DATA->dat205 := stodl(SM3IGES->dat205)
            endif
         endif

         // 065 A2 massa
         if !empty(SM3IGES->mas205)
            if nOver == 1 .or. empty(SM3DATA->mas205) .and. nOver == 0
               SM3DATA->mas205 := val(SM3IGES->mas205)
            endif
         endif

         // 066 A2 tydgenote
         if !empty(SM3IGES->aan205)
            if nOver == 1 .or. empty(SM3DATA->aan205) .and. nOver == 0
               SM3DATA->aan205 := val(SM3IGES->aan205)
            endif
         endif

         // 067 A2 rangorde
         if !empty(SM3IGES->ple205)
            if nOver == 1 .or. empty(SM3DATA->ple205) .and. nOver == 0
               SM3DATA->ple205 := val(SM3IGES->ple205)
            endif
         endif

         // 068 A2 ouderdom
         if !empty(SM3IGES->oud205)
            if nOver == 1 .or. empty(SM3DATA->oud205) .and. nOver == 0
               SM3DATA->oud205 := val(SM3IGES->oud205)
            endif
         endif

         // 069 A2 korr massa
         if !empty(SM3IGES->gma205)
            if nOver == 1 .or. empty(SM3DATA->gma205) .and. nOver == 0
               SM3DATA->gma205 := val(SM3IGES->gma205)
            endif
         endif

         // 070 A2 gdo
         if !empty(SM3IGES->gdo205)
            if nOver == 1 .or. empty(SM3DATA->gdo205) .and. nOver == 0
               SM3DATA->gdo205 := val(SM3IGES->gdo205)
            endif
         endif

         // 071 A2 indeks
         if !empty(SM3IGES->ind205)
            if nOver == 1 .or. empty(SM3DATA->ind205) .and. nOver == 0
               SM3DATA->ind205 := val(SM3IGES->ind205)
            endif
         endif

         // Jaar B1 indeks **********************************************

         // 072 B1 indekskode
         if !empty(SM3IGES->kod365)
            if nOver == 1 .or. empty(SM3DATA->kod365) .and. nOver == 0
               SM3DATA->kod365 := SM3IGES->kod365
            endif
         endif

         // 073 B1 weegdatum
         if !empty(SM3IGES->dat365)
            if nOver == 1 .or. empty(SM3DATA->dat365) .and. nOver == 0
               SM3DATA->dat365 := stodl(SM3IGES->dat365)
            endif
         endif

         // 074 B1 massa
         if !empty(SM3IGES->mas365)
            if nOver == 1 .or. empty(SM3DATA->mas365) .and. nOver == 0
               SM3DATA->mas365 := val(SM3IGES->mas365)
            endif
         endif

         // 075 B1 tydgenote
         if !empty(SM3IGES->aan365)
            if nOver == 1 .or. empty(SM3DATA->aan365) .and. nOver == 0
               SM3DATA->aan365 := val(SM3IGES->aan365)
            endif
         endif

         // 076 B1 rangorde
         if !empty(SM3IGES->ple365)
            if nOver == 1 .or. empty(SM3DATA->ple365) .and. nOver == 0
               SM3DATA->ple365 := val(SM3IGES->ple365)
            endif
         endif

         // 077 B1 ouderdom
         if !empty(SM3IGES->oud365)
            if nOver == 1 .or. empty(SM3DATA->oud365) .and. nOver == 0
               SM3DATA->oud365 := val(SM3IGES->oud365)
            endif
         endif

         // 078 B1 korr massa
         if !empty(SM3IGES->gma365)
            if nOver == 1 .or. empty(SM3DATA->gma365) .and. nOver == 0
               SM3DATA->gma365 := val(SM3IGES->gma365)
            endif
         endif

         // 079 B1 gdo
         if !empty(SM3IGES->gdo365)
            if nOver == 1 .or. empty(SM3DATA->gdo365) .and. nOver == 0
               SM3DATA->gdo365 := val(SM3IGES->gdo365)
            endif
         endif

         // 080 B1 indeks
         if !empty(SM3IGES->ind365)
            if nOver == 1 .or. empty(SM3DATA->ind365) .and. nOver == 0
               SM3DATA->ind365 := val(SM3IGES->ind365)
            endif
         endif

         // 18mde B2 indeks **********************************************

         // 081 B2 indekskode
         if !empty(SM3IGES->kod540)
            if nOver == 1 .or. empty(SM3DATA->kod540) .and. nOver == 0
               SM3DATA->kod540 := SM3IGES->kod540
            endif
         endif

         // 082 B2 weegdatum
         if !empty(SM3IGES->dat540)
            if nOver == 1 .or. empty(SM3DATA->dat540) .and. nOver == 0
               SM3DATA->dat540 := stodl(SM3IGES->dat540)
            endif
         endif

         // 083 B2 massa
         if !empty(SM3IGES->mas540)
            if nOver == 1 .or. empty(SM3DATA->mas540) .and. nOver == 0
               SM3DATA->mas540 := val(SM3IGES->mas540)
            endif
         endif

         // 084 B2 tydgenote
         if !empty(SM3IGES->aan540)
            if nOver == 1 .or. empty(SM3DATA->aan540) .and. nOver == 0
               SM3DATA->aan540 := val(SM3IGES->aan540)
            endif
         endif

         // 085 B2 rangorde
         if !empty(SM3IGES->ple540)
            if nOver == 1 .or. empty(SM3DATA->ple540) .and. nOver == 0
               SM3DATA->ple540 := val(SM3IGES->ple540)
            endif
         endif

         // 086 B2 ouderdom
         if !empty(SM3IGES->oud540)
            if nOver == 1 .or. empty(SM3DATA->oud540) .and. nOver == 0
               SM3DATA->oud540 := val(SM3IGES->oud540)
            endif
         endif

         // 087 B2 korr massa
         if !empty(SM3IGES->gma540)
            if nOver == 1 .or. empty(SM3DATA->gma540) .and. nOver == 0
               SM3DATA->gma540 := val(SM3IGES->gma540)
            endif
         endif

         // 088 B2 gdo
         if !empty(SM3IGES->gdo540)
            if nOver == 1 .or. empty(SM3DATA->gdo540) .and. nOver == 0
               SM3DATA->gdo540 := val(SM3IGES->gdo540)
            endif
         endif

         // 089 B2 indeks
         if !empty(SM3IGES->ind540)
            if nOver == 1 .or. empty(SM3DATA->ind540) .and. nOver == 0
               SM3DATA->ind540 := val(SM3IGES->ind540)
            endif
         endif

         // Fase cd indeks **************************************************

         // 090 Aanpas begin datum
         if !empty(SM3IGES->aandat)
            if nOver == 1 .or. empty(SM3DATA->aandat) .and. nOver == 0
               SM3DATA->aandat := stodl(SM3IGES->aandat)
            endif
         endif

         // 091 Aanpas begin massa
         if !empty(SM3IGES->aanmas)
            if nOver == 1 .or. empty(SM3DATA->aanmas) .and. nOver == 0
               SM3DATA->aanmas := val(SM3IGES->aanmas)
            endif
         endif

         // 092 Toets begin datum
         if !empty(SM3IGES->begdatum)
            if nOver == 1 .or. empty(SM3DATA->begdatum) .and. nOver == 0
               SM3DATA->begdatum := stodl(SM3IGES->begdatum)
            endif
         endif

         // 093 Toets begin massa
         if !empty(SM3IGES->begmassa)
            if nOver == 1 .or. empty(SM3DATA->begmassa) .and. nOver == 0
               SM3DATA->begmassa := val(SM3IGES->begmassa)
            endif
         endif

         // 094 Toets eind datum
         if !empty(SM3IGES->eindat)
            if nOver == 1 .or. empty(SM3DATA->eindat) .and. nOver == 0
               SM3DATA->eindat := stodl(SM3IGES->eindat)
               SM3DATA->fasekode := "D"
            endif
         endif

         // 095 Toets eind massa
         if !empty(SM3IGES->einmas)
            if nOver == 1 .or. empty(SM3DATA->einmas) .and. nOver == 0
               SM3DATA->einmas := val(SM3IGES->einmas)
            endif
         endif

         // 096 Dae in toets
         if !empty(SM3IGES->daeint)
            if nOver == 1 .or. empty(SM3DATA->daeint) .and. nOver == 0
               SM3DATA->daeint := val(SM3IGES->daeint)
            endif
         endif

         // 097 Toets tydgenote
         if !empty(SM3IGES->tydgen)
            if nOver == 1 .or. empty(SM3DATA->tydgen) .and. nOver == 0
               SM3DATA->tydgen := val(SM3IGES->tydgen)
            endif
         endif

         // 098 Toets rangorde
         if !empty(SM3IGES->rangor)
            if nOver == 1 .or. empty(SM3DATA->rangor) .and. nOver == 0
               SM3DATA->rangor := val(SM3IGES->rangor)
            endif
         endif

         // 099 Toets gdt
         if !empty(SM3IGES->gdtgdt)
            if nOver == 1 .or. empty(SM3DATA->gdtgdt) .and. nOver == 0
               SM3DATA->gdtgdt := val(SM3IGES->gdtgdt)
            endif
         endif

         // 100 Toets gdtind
         if !empty(SM3IGES->gdtind)
            if nOver == 1 .or. empty(SM3DATA->gdtind) .and. nOver == 0
               SM3DATA->gdtind := val(SM3IGES->gdtind)
            endif
         endif

         // 101 Toets gdoind
         if !empty(SM3IGES->gdogdo)
            if nOver == 1 .or. empty(SM3DATA->gdogdo) .and. nOver == 0
               SM3DATA->gdogdo := val(SM3IGES->gdogdo)
            endif
         endif

         // 102 Toets gdoind
         if !empty(SM3IGES->gdoind)
            if nOver == 1 .or. empty(SM3DATA->gdoind) .and. nOver == 0
               SM3DATA->gdoind := val(SM3IGES->gdoind)
            endif
         endif

         // 103 Toets voeromset
         if !empty(SM3IGES->voeromset)
            if nOver == 1 .or. empty(SM3DATA->voeromset) .and. nOver == 0
               SM3DATA->voeromset := val(SM3IGES->voeromset)
            endif
         endif

         // 104 Toets voeromset ind
         if !empty(SM3IGES->voeromseti)
            if nOver == 1 .or. empty(SM3DATA->voeromseti) .and. nOver == 0
               SM3DATA->voeromseti := val(SM3IGES->voeromseti)
            endif
         endif

         // 105 Toets kleiber
         if !empty(SM3IGES->kleiber)
            if nOver == 1 .or. empty(SM3DATA->kleiber) .and. nOver == 0
               SM3DATA->kleiber := val(SM3IGES->kleiber)
            endif
         endif

         // 106 Toets kleiber ind
         if !empty(SM3IGES->kleiberi)
            if nOver == 1 .or. empty(SM3DATA->kleiberi) .and. nOver == 0
               SM3DATA->kleiberi := val(SM3IGES->kleiberi)
            endif
         endif

         // 107 Toets mateskouer
         if !empty(SM3IGES->mateskouer)
            if nOver == 1 .or. empty(SM3DATA->mateskouer) .and. nOver == 0
               SM3DATA->mateskouer := val(SM3IGES->mateskouer)
            endif
         endif

         // 108 Toets gekhoogte ind
         if !empty(SM3IGES->gekhoo)
            if nOver == 1 .or. empty(SM3DATA->gekhoo) .and. nOver == 0
               SM3DATA->gekhoo := val(SM3IGES->gekhoo)
            endif
         endif

         // 109 Toets matelengte
         if !empty(SM3IGES->matelengte)
            if nOver == 1 .or. empty(SM3DATA->matelengte) .and. nOver == 0
               SM3DATA->matelengte := val(SM3IGES->matelengte)
            endif
         endif

         // 110 Toets geklengte
         if !empty(SM3IGES->geklen)
            if nOver == 1 .or. empty(SM3DATA->geklen) .and. nOver == 0
               SM3DATA->geklen := val(SM3IGES->geklen)
            endif
         endif

         // 111 Toets veldikte
         if !empty(SM3IGES->veldikte)
            if nOver == 1 .or. empty(SM3DATA->veldikte) .and. nOver == 0
               SM3DATA->veldikte := val(SM3IGES->veldikte)
            endif
         endif

         // 112 Toets gekveldikte
         if !empty(SM3IGES->gekvel)
            if nOver == 1 .or. empty(SM3DATA->gekvel) .and. nOver == 0
               SM3DATA->gekvel := val(SM3IGES->gekvel)
            endif
         endif

         // 113 Toets skrotum
         if !empty(SM3IGES->mateskrot)
            if nOver == 1 .or. empty(SM3DATA->mateskrot) .and. nOver == 0
               SM3DATA->mateskrot := val(SM3IGES->mateskrot)
            endif
         endif

         // 114 Toets gek skrotum
         if !empty(SM3IGES->gekskr)
            if nOver == 1 .or. empty(SM3DATA->gekskr) .and. nOver == 0
               SM3DATA->gekskr := val(SM3IGES->gekskr)
            endif
         endif

         // 115 Inteelkoef
         if !empty(SM3IGES->ibcoef)
            if nOver == 1 .or. empty(SM3DATA->ibcoef) .and. nOver == 0
               SM3DATA->ibcoef := val(SM3IGES->ibcoef)
            endif
         endif

         // Next record after deleting current record
         Dbselectarea("SM3IGES")
         dbdelete()
         Dbskip()

      ENDDO

      DBSELECTAREA("SM3IGES")
      PACK
      DBCOMMITALL()

      IF LASTREC() = 0
         IF cLanType() = "A"
            fScrBood(MAXROW()-1,"Geskiedenisdata van "+ALLTRIM(STR(nStart))+" diere is ingelees.")
            fScrWait(MAXROW())
         ELSE
            fScrBood(MAXROW()-1,"Historical data for "+ALLTRIM(STR(nStart))+" animals was processed.")
            fScrWait(MAXROW())
         ENDIF
      ELSE
         //IF cLanType() = "A"
         //   fScrBood(MAXROW()-1,"Geskiedenisdata van "+ALLTRIM(STR(LASTREC()))+" uit "+ALLTRIM(STR(nStart))+" diere kon nie gelees word nie.")
         //   cBood := "Druk inligting van die ongeprosesseerde diere"
         //ELSE
         //   fScrBood(MAXROW()-1,"Historical data for "+ALLTRIM(STR(LASTREC()))+" out of "+ALLTRIM(STR(nStart))+" animals could not be read.")
         //   cBood := "Print information of the unprocessed animals"
         //ENDIF
         //
         //if fJaNee(maxrow(),cBood,,.f. )
         //   fPrint()
         //endif

      ENDIF

   END

   // Herstel
   fATclose(aCdbf)
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
      aadd(aSend,{"sm3ireg","idn"})
      aadd(aSend,{"sm3ireg","reg"})
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
      cHdln := upper("Diere waarvan registrasienommers nie gelees kon word nie")
   else
      fScrbood(24,"Unprocessed animals being printed!  [Esc]=Stop printer.")
      cHdln := upper("Animals whose registration numbers could not be imported")
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
