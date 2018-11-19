// SM3IREG.PRG
// Program om registrasienommers van nuwe kalwers te lees
// Kopiereg (c) AB Janse van Rensburg
// 05-11-24 10:00

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION sm3ireg()

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
   local i     := 0
   local cMask := ""
   local nHerd := 0
   local nYear := 0
   local nSequ := 0
   local nZero := 0

   BEGIN SEQUENCE

      if cLanType() = "A"
         cPath := fFilePick("LEES REGISTRASIENOMMERS",cMailTar(),"*.csv","D","D")
      else
         cPath := fFilePick("IMPORT REGISTRATION NUMBERS",cMailTar(),"*.csv","D","D")
      endif

      if empty(cPath)

         // Ask for file name

         // Build path
         cPath := padr(cMailTar()+"B"+ltrim(str(val(substr(cTotNaam(),152,10))))+".CSV",50)

         do while .t.

            lBreak := .f.

            if cLanType() = "A"
               fScrOpsk( ,"Opsie "+cOption())
               nBoxc := fBoxCent(11,SPACE(50),3,"LEES REGISTRASIENOMMERS")
               fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
               fScrBood(maxrow(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
            else
               fScrOpsk( ,"Option "+cOption())
               nBoxc := fBoxCent(11,SPACE(50),3,"IMPORT REGISTRATION NUMBERS")
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3IREG",,,,.f.)
      IF ! aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      IF !aCdbf[len(aCdbf),1]
         BREAK
      ENDIF

      IF cLanType() = "A"
         fScrBood(MAXROW()-1)
         fScrBood(MAXROW(),"Die lˆer "+alltrim(cPath)+" word gelees...")
      ELSE
         fScrBood(MAXROW()-1)
         fScrBood(MAXROW(),"The file "+alltrim(cPath)+" being imported...")
      ENDIF

      DBSELECTAREA("SM3IREG")
      ZAP
      APPEND FROM (alltrim(cPath)) deli
      DBGOTOP()
      DBDELETE()
      PACK
      DBCOMMITALL()
      GO TOP
      nStart := LASTREC()

      DBSELECTAREA("SM3IREG")
      DBGOTOP()

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"Registrasienommers word gelees...")
      else
         fScrBood(maxrow()-1)
         fScrBood(maxrow(),"Registration numbers being imported...")
      endif

      DO WHILE ! EOF()

         // Screen
         fScrBood(maxrow()-1,recno())

         // Build the id number to locate

         if cIdForm() == "1"

            // Id number in HHHHYY-SSSS format

            cData := alltrim(substr(SM3IREG->idn,5,4)) // Hdm
            cData += substr(SM3IREG->idn,9,2) + "-" // Year
            if val(substr(SM3IREG->idn,11,4)) < 10
               cData += "00" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            elseif val(substr(SM3IREG->idn,11,4)) < 100
               cData += "0" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            else
               cData += alltrim(str(val(substr(SM3IREG->idn,11,4))))
            endif

         elseif cIdForm() == "2"

            // Id number in YY-SSSSHHHH format

            cData := substr(SM3IREG->idn,9,2) + "-" // Year
            if val(substr(SM3IREG->idn,11,4)) < 10
               cData += "000" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            elseif val(substr(SM3IREG->idn,11,4)) < 100
               cData += "00" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            elseif val(substr(SM3IREG->idn,11,4)) < 1000
               cData += "0" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            else
               cData += alltrim(str(val(substr(SM3IREG->idn,11,4))))
            endif
            cData += alltrim(substr(SM3IREG->idn,5,4)) // Hdm

         else

            altd()

            // Id number in free flow format

            cData := alltrim(cIdMask())

            // Year
            if at("Y",cData) > 0
               cData := strtran(cData,"Y","",2)
               cData := strtran(cData,"Y",substr(SM3IREG->idn,9,2))
            else
               if at("J",cData) > 0
                  cData := strtran(cData,"J","",2)
                  cData := strtran(cData,"J",substr(SM3IREG->idn,9,2))
               endif
            endif

            // Sequence number
            cMask := ""
            nZero := 0
            if val(substr(SM3IREG->idn,11,4)) < 10
               cMask := "000" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            elseif val(substr(SM3IREG->idn,11,4)) < 100
               cMask := "00" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            elseif val(substr(SM3IREG->idn,11,4)) < 1000
               cMask := "0" + alltrim(str(val(substr(SM3IREG->idn,11,4))))
            else
               cMask := alltrim(str(val(substr(SM3IREG->idn,11,4))))
            endif
            if at("S",cData) > 0
               cData := strtran(cData,"S","",2)
               cData := strtran(cData,"S",cMask)
            else
               if at("V",cData) > 0
                  cData := strtran(cData,"V","",2)
                  cData := strtran(cData,"V",cMask)
               endif
            endif

            // Herd designation
            if at("H",cData) > 0
               cData := strtran(cData,"H","",2)
               cData := strtran(cData,"H",alltrim(substr(SM3IREG->idn,5,4)))
            else
               if at("K",cData) > 0
                  cData := strtran(cData,"K","",2)
                  cData := strtran(cData,"K",alltrim(substr(SM3IREG->idn,5,4)))
               endif
            endif

         endif

         // Seek the animal in main file
         select SM3DATA
         go top
         seek cData

         if found()

            // Store registration number
            // 01/13/17 09:05am SM3DATA->reknr := alltrim(str(val(SM3IREG->reg)))
            SM3DATA->reknr := right("0000000000" + alltrim(str(val(SM3IREG->reg))),10)

            // Delete the found animal
            select SM3IREG
            dbdelete()

         endif

         // Next record
         Dbselectarea("SM3IREG")
         Dbskip()

      ENDDO

      DBSELECTAREA("SM3IREG")
      PACK
      DBCOMMITALL()

      IF LASTREC() = 0
         IF cLanType() = "A"
            fScrBood(MAXROW()-1,"Registrasienommers van "+ALLTRIM(STR(nStart))+" diere is ingelees.")
            fScrWait(MAXROW())
         ELSE
            fScrBood(MAXROW()-1,"Registration numbers for "+ALLTRIM(STR(nStart))+" animals was processed.")
            fScrWait(MAXROW())
         ENDIF
      ELSE
         IF cLanType() = "A"
            fScrBood(MAXROW()-1,"Registrasienommers van "+ALLTRIM(STR(LASTREC()))+" uit "+ALLTRIM(STR(nStart))+" diere kon nie gelees word nie.")
            cBood := "Druk inligting van die ongeprosesseerde diere"
         ELSE
            fScrBood(MAXROW()-1,"Registration numbers for "+ALLTRIM(STR(LASTREC()))+" out of "+ALLTRIM(STR(nStart))+" animals could not be read.")
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
