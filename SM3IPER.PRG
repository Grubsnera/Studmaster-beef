// SM3IPER.PRG
// Program om prestasiedata te lees
// Kopiereg (c) AB Janse van Rensburg
// 06-05-29 12:27

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3iper()

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
   private cOude := ""

   BEGIN SEQUENCE

      if cLanType() = "A"
         cPath := fFilePick("LEES PRESTASIEDATA",cMailTar(),"*.csv","D","D")
      else
         cPath := fFilePick("IMPORT PERFORMANCE DATA",cMailTar(),"*.csv","D","D")
      endif

      if empty(cPath)

         // Ask for file name

         // Build path
         cPath := padr(cMailTar()+"P"+ltrim(str(val(substr(cTotNaam(),152,10))))+".CSV",50)

         do while .t.

            lBreak := .f.

            if cLanType() = "A"
               fScrOpsk( ,"Opsie "+cOption())
               nBoxc := fBoxCent(11,SPACE(50),3,"LEES PRESTASIEDATA")
               fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
               fScrBood(maxrow(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
            else
               fScrOpsk( ,"Option "+cOption())
               nBoxc := fBoxCent(11,SPACE(50),3,"IMPORT PERFORMANCE DATA")
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3IPER",,,,.f.)
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

      DBSELECTAREA("SM3IPER")
      ZAP
      APPEND FROM (alltrim(cPath)) deli
      nStart := LASTREC()

      DBSELECTAREA("SM3DATA")
      ordsetfocus("sm3zzsu")

      DBSELECTAREA("SM3IPER")
      DBGOTOP()

      // Delete heading field
      if upper(SM3IPER->animal) == "ANIMAL_NUM"
         dbdelete()
         dbskip()
      endif

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"Prestasietoetsreultate word gelees...")
      else
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"Performance test results being imported...")
      endif

      DO WHILE ! EOF()

         // Screen
         fScrBood(maxrow()-1,recno())

         // Build the id number to locate
         cData := padl(alltrim(SM3IPER->animal),10,"0")

         altd()

         // Seek the animal in main file
         select SM3DATA
         go top
         seek cData
         if found()

            // Determince which performance data to be imported
            if alltrim(SM3IPER->testco) == "PWE"
               cOude := "100"
            elseif alltrim(SM3IPER->testco) == "WEA"
               cOude := "205"
            elseif alltrim(SM3IPER->testco) == "12M"
               cOude := "365"
            elseif alltrim(SM3IPER->testco) == "18M"
               cOude := "540"
            else
               cOude := ""
            endif

            altd()

            if !empty(cOude)
               // store phase a & b data
               SM3DATA->aan&cOude. := val(SM3IPER->contem)
               SM3DATA->ple&cOude. := 0
               SM3DATA->oud&cOude. := val(SM3IPER->ageatt)
               SM3DATA->gma&cOude. := val(SM3IPER->weight)
               SM3DATA->gdo&cOude. := val(SM3IPER->adaada)
               SM3DATA->ind&cOude. := val(SM3IPER->adaind)
               if cOude == "205"
                  // Also save cow efficiency and index
                  SM3DATA->mpresind := val(SM3IPER->cowind)
               endif
            else
               // Store phase c & d data

               set century on
               SM3DATA->aandat := ctod(alltrim(SM3IPER->adapsd))
               SM3DATA->aanmas := val(SM3IPER->weigba)
               SM3DATA->begdatum := ctod(alltrim(SM3IPER->testsd))
               SM3DATA->begmassa := val(SM3IPER->weigbt)
               SM3DATA->eindat := ctod(alltrim(SM3IPER->testfd))
               set century off
               SM3DATA->einmas := val(SM3IPER->weight)
               SM3DATA->tydgen := val(SM3IPER->contem)
               SM3DATA->gdogdo := val(SM3IPER->adaada)
               SM3DATA->gdoind := val(SM3IPER->adaind)
               SM3DATA->gdtgdt := val(SM3IPER->adgadg)
               SM3DATA->gdtind := val(SM3IPER->adgind)
               SM3DATA->voeromset := val(SM3IPER->fcrfcr)
               SM3DATA->voeromseti := val(SM3IPER->fcrind)
               SM3DATA->kleiber := val(SM3IPER->krkrkr)
               SM3DATA->kleiberi := val(SM3IPER->krindg)
               SM3DATA->mateskrot := val(SM3IPER->scunad)
               SM3DATA->gekskr := val(SM3IPER->scadju)
               SM3DATA->matelengte := val(SM3IPER->blunad)
               SM3DATA->geklen := val(SM3IPER->bladju)
               SM3DATA->mateskouer := val(SM3IPER->shunad)
               SM3DATA->gekhoo := val(SM3IPER->shadju)
               SM3DATA->hoolen := val(SM3IPER->shblra)
               SM3DATA->veldikte := val(SM3IPER->skunad)

            endif

            // Delete the found animal
            select SM3IPER
            dbdelete()

         endif

         // Next record
         Dbselectarea("SM3IPER")
         Dbskip()

      ENDDO

      DBSELECTAREA("SM3IPER")
      PACK
      DBCOMMITALL()

      IF LASTREC() = 0
         IF cLanType() = "A"
            fScrBood(MAXROW()-1,"Prestasiedata van "+ALLTRIM(STR(nStart))+" diere is ingelees.")
            fScrWait(MAXROW())
         ELSE
            fScrBood(MAXROW()-1,"Performance data for "+ALLTRIM(STR(nStart))+" animals was processed.")
            fScrWait(MAXROW())
         ENDIF
      ELSE
         IF cLanType() = "A"
            fScrBood(MAXROW()-1,"Prestasiedata van "+ALLTRIM(STR(LASTREC()))+" uit "+ALLTRIM(STR(nStart))+" diere kon nie gelees word nie.")
            cBood := "Druk inligting van die ongeprosesseerde diere"
         ELSE
            fScrBood(MAXROW()-1,"Performance data for "+ALLTRIM(STR(LASTREC()))+" out of "+ALLTRIM(STR(nStart))+" animals could not be read.")
            cBood := "Print information of the unprocessed animals"
         ENDIF

         if fJaNee(maxrow(),cBood,,.f. )
            fPrint()
         endif

      ENDIF

   end

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
      aadd(aSend,{"sm3iper","animal"})
      aadd(aSend,{"sm3iper","weigid"})
      aadd(aSend,{"sm3iper","weighu"})
      aadd(aSend,{"sm3iper","ageatt"})
      aadd(aSend,{"sm3iper","weight"})
      aadd(aSend,{"sm3iper","adaada"})
      aadd(aSend,{"sm3iper","adaind"})
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
      cHdln := upper("Diere waarvan prestasiedata nie gelees kon word nie")
   else
      fScrbood(24,"Unprocessed animals being printed!  [Esc]=Stop printer.")
      cHdln := upper("Animals whose performance data could not be imported")
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
