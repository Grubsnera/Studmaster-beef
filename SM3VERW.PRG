//SM3VERW.PRG
//Program om verwantskappe te bereken en te vertoon
//Kopiereg (c) 1992 A van Rensburg
//08:53 28 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

//**************************************************************************/
FUNCTION sm3verw

   //Verklaar
   local nCh     := 1
   local cVerw   := ""
   local cData   := ""
   local nReko   := 1
   local nTota   := 0
   local aBull   := {}
   local aStam   := {}
   local aBroe   := {}
   local aSeun   := {}
   local nFind   := 0
   local i       := 0
   local j       := 0
   local nBoxc   := 0
   local nIbPer  := 0
   local cRela   := ""
   local cHdl2   := ""
   local getlist := {}
   local cMemf := ""
   private cTest := ""

   //Vra groep of seleksiegroep
   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
   else
      fScrOpsk(1,"Option "+cOption())
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu." )
   endif

   nCh := fNewMenu(nCh,"SM3VERW")
   cOption(nCh)

   do case
      case nCh == 1
         //Groep
         cTest := sm3groe()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif

            cOption(-1)
            return NIL
         endif
         if cLanType() == "A"
            cHdl2 := "Groep diere"
         else
            cHdl2 := "Group animals"
         endif

      case nCh == 2
         //Seleksiegroep
         cTest := sm3selg()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No selection group requirements have been specified!")
            endif

            cOption(-1)
            return NIL
         endif
         //Kry mem besonderhede
         cMemf := cDd()+"sm3selg.mem"
         restore from (cMemf) additive
         cHdl2 := ALLTRIM(cMbes)

      otherwise

         cOption(-1)
         return NIL
   endcase

   //Open dataleers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif

   cVerw := fTOpen(cDd(),"sm3verw",,,,FALSE)
   if left(cVerw,1) == "f"
      cOption(-1)
      return NIL
   endif
   zap

   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      fTClose(cVerw)
      cOption(-1)
      return NIL
   endif
   nTota := lastrec()

   //Vra die bulle gebruik
   for i = 1 to 5
      aadd(aBull,space(12))
   next

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif
   fScrBood(23,"[Esc]=Menu")

   if cLanType() == "A"
      fScrBood(24,"Tik die id nommers van bulle wat gebruik gaan word!")
   else
      fScrBood(24,"Type the id numbers of bulls which are to be used!")
   endif
   //Trek raam
   if cLanType() == "A"
      nBoxc := fBoxCent(7,space(20),7,"TEELBULLE")
      @ 8,nBoxc say "Bul 1" get aBull[ 1] pict "@!" valid(fVidnr(aBull[ 1]))
      @ 9,nBoxc say "Bul 2" get aBull[ 2] pict "@!" valid(fVidnr(aBull[ 2]))
      @10,nBoxc say "Bul 3" get aBull[ 3] pict "@!" valid(fVidnr(aBull[ 3]))
      @11,nBoxc say "Bul 4" get aBull[ 4] pict "@!" valid(fVidnr(aBull[ 4]))
      @12,nBoxc say "Bul 5" get aBull[ 5] pict "@!" valid(fVidnr(aBull[ 5]))
   else
      nBoxc := fBoxCent(7,space(20),7,"BREEDING BULLS")
      @ 8,nBoxc say "Bull 1" get aBull[ 1] pict "@!" valid(fVidnr(aBull[ 1]))
      @ 9,nBoxc say "Bull 2" get aBull[ 2] pict "@!" valid(fVidnr(aBull[ 2]))
      @10,nBoxc say "Bull 3" get aBull[ 3] pict "@!" valid(fVidnr(aBull[ 3]))
      @11,nBoxc say "Bull 4" get aBull[ 4] pict "@!" valid(fVidnr(aBull[ 4]))
      @12,nBoxc say "Bull 5" get aBull[ 5] pict "@!" valid(fVidnr(aBull[ 5]))
   endif
   set cursor on
   read
   set cursor off

   //If escaped
   if lastkey() == K_ESC
      fTClose(cData)
      fTClose(cVerw)
      cOption(-1)
      return NIL
   endif

   //Kyk of enige bulle wel genomineer is
   for i = 1 to len(aBull)
      if aBull[i] <> space(12)
         exit
      endif
   next
   if i > len(aBull)
      if cLanType() == "A"
         fScrBood(23,"Geen bulle is genomineer!")
      else
         fScrBood(23,"No bulls have been nominated!")
      endif
      fScrWait(24)
      fTClose(cData)
      fTClose(cVerw)
      cOption(-1)
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verwantskappe word bereken")
   else
      fScrWbood(24,"Relationships being calculated")
   endif
   //Gaan deur hele leer
   do while !eof()

      //Vertoon %
      if cLanType() == "A"
         fScrBood(23,fPercent(nReko,nTota)+"% Voltooi")
      else
         fScrBood(23,fPercent(nReko,nTota)+"% Completed")
      endif

      if &cTest

         //Stamboom ens word opgesoek
         aStam := fStamboom(SM3DATA->idnr)
         aBroe := fBroers(SM3DATA->idnr)
         aSeun := fSeuns(SM3DATA->idnr)

         //Bewaar in verwantskappeleer
         select SM3VERW
         append blank
         SM3VERW->idnr := SM3DATA->idnr

         //Toets elke bul
         for i = 1 to len(aBull)

            if len(alltrim(aBull[i])) > 0

               cRela := ""
               nIbPer := 0
               //Stamboom
               for j = 1 to len(aStam)
                  if aStam[j][1] == aBull[i]
                     if cLanType() == "A"
                        do case
                           case j == 2
                              cRela := "Pa"
                              exit
                           case j == 3
                              cRela := "Ma"
                              exit
                           case j == 4
                              cRela := "Oupa (V)"
                              exit
                           case j == 5
                              cRela := "Ouma (V)"
                              exit
                           case j == 6
                              cRela := "Oupa (M)"
                              exit
                           case j == 7
                              cRela := "Ouma (M)"
                              exit
                           case j >= 8 .and. j <= 11
                              cRela := "Grootjie (V)"
                              exit
                           case j >= 12 .and. j <= 15
                              cRela := "Grootjie (M)"
                              exit
                        endcase
                     else
                        do case
                           case j == 2
                              cRela := "Sire"
                              exit
                           case j == 3
                              cRela := "Dam"
                              exit
                           case j == 4
                              cRela := "Grandfather (S)"
                              exit
                           case j == 5
                              cRela := "Grandmother (S)"
                              exit
                           case j == 6
                              cRela := "Grandfather (D)"
                              exit
                           case j == 7
                              cRela := "Grandmother (D)"
                              exit
                           case j >= 8 .and. j <= 11
                              cRela := "Great-grandfather (S)"
                              exit
                           case j >= 12 .and. j <= 15
                              cRela := "Great-grandfather (D)"
                              exit
                        endcase
                     endif
                  endif
               next

               if len(alltrim(cRela)) == 0
                  //Toets vir broers
                  nFind := 0
                  nFind := ascan(aBroe,aBull[i])
                  if nFind > 0
                     if cLanType() == "A"
                        cRela := "Broer/Suster"
                     else
                        cRela := "Brother/Sister"
                     endif
                  endif
               endif

               if len(alltrim(cRela)) == 0
                  //Toets vir seuns
                  nFind := 0
                  nFind := ascan(aSeun,aBull[i])
                  if nFind > 0
                     if cLanType() == "A"
                        cRela := "Seun/Dogter"
                     else
                        cRela := "Son/Daughter"
                     endif
                  endif
               endif

               // Get inbreeding percentage
               nIbPer := sm3fpib(aBull[i],SM3DATA->idnr)

               IF nIbPer != 0 .OR. ! EMPTY(cRela)
                  fieldput(i+1,ALLTRIM(STR(nIbPer,6,2))+IIF(EMPTY(cRela), "", " ("+cRela+")"))
               ENDIF

            endif

         next

      endif

      //Stop
      if inkey() == K_ESC
         select SM3DATA
         go bottom
      endif

      //Volgende
      select SM3DATA
      skip
      nReko++

   enddo

   //Vertoon die resultate
   fTClose(cData)
   select SM3VERW
   go top
   if lastrec() > 0
      fDisplay(,,,,,aBull,cHdl2)
   else
      if cLanType() == "A"
         fScrBood(23,"Geen diere gevind!")
      else
         fScrBood(23,"No animals found!")
      endif
      fScrWait(24)
   endif

   //Herstel
   cOption(-1)
   fTClose(cVerw)

return NIL

//*************************************************************************/
STATIC FUNCTION fVidnr(cIdnr)

   //Funksie om id nommers te toets

   //Verklaar
   local cCdbf := fTOpen()
   local cCscr := savescreen(23,0,24,79)
   local lRetu := TRUE

   //Indien Id nommer niks is
   if cIdnr == space(12)
      return lRetu
   endif

   //Kyk of wel bestaan
   select SM3DATA
   seek cIdnr
   if eof()
      if cLanType() == "A"
         fScrBood(23,"Dier is onbekend!")
      else
         fScrBood(23,"Animal is unknown!")
      endif
      fScrWait(24)
      restscreen(23,0,24,79,cCscr)
      lRetu := FALSE
   endif

   if SM3DATA->geslag != "2"
      if cLanType() == "A"
         fScrBood(23,"Dier is nie manlik nie !")
      else
         fScrBood(23,"Animal is not a male !")
      endif
      fScrWait(24)
      restscreen(23,0,24,79,cCscr)
      lRetu := FALSE
   endif

   //Herstel
   fTClose(cCdbf)
return lRetu

//*************************************************************************/
STATIC FUNCTION fDisplay( nTop, nLeft, nBott, aSend, cFind, aBull, cHdl2 )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local cCoun := ""
   local lMore := TRUE
   local nKeyp := 0
   local cRetu := space(12)

   private cData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3verw","idnr"})
      if aBull[ 1] <> space(12)
         aadd(aSend,{"sm3verw","bul001"})
      endif
      if aBull[ 2] <> space(12)
         aadd(aSend,{"sm3verw","bul002"})
      endif
      if aBull[ 3] <> space(12)
         aadd(aSend,{"sm3verw","bul003"})
      endif
      if aBull[ 4] <> space(12)
         aadd(aSend,{"sm3verw","bul004"})
      endif
      if aBull[ 5] <> space(12)
         aadd(aSend,{"sm3verw","bul005"})
      endif
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Bewaar bulnommers
   for i = 1 to len(aBull)
      if aBull[i] <> space(12)
         aRecv[i+1][9] := alltrim(aBull[i])
      endif
   next

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "INTEEL % (VERWANTSKAPPE) - "+cHdl2 )
   else
      fBox( nTop, nLeft, nBott, nRigh, "INBREEDING % (RELATIONSHIPS) - "+cHdl2 )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   // Main loop
   lMore := TRUE
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu              " )
         fScrBood( 24, "[Alt P]=Druk  [A - Z]=Vind" )
      else
         fScrBood( 23, "[ Esc ]=Menu               " )
         fScrBood( 24, "[Alt P]=Print  [A - Z]=Find" )
      endif

      // Display the record number
      cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
      @nBott,nRigh-(len(cCoun)+1) say cCoun

      //Vries
      bBrow:freeze := 1

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := FALSE

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecv,cHdl2)
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cCdbf)
return cRetu

//*************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := FALSE
   local cData := ""
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cData := upper(chr(nKeyp)) + space(aRecv[1][4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[1][6] get cData pict aRecv[1][10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cData == space(aRecv[1][4])
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   locate for SM3VERW->idnr == cData
   if eof()
      go top
   endif
   lRetu := TRUE

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aRecv,cHdl2)

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local nCh   := 0
   local nTota := 0
   local lLoop := TRUE
   local lDoub := FALSE
   local nI    := 1
   local nReko := 0
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
   fScrBood(MAXROW())

   nCh := fNewMenu(1,"OWNRDOUB")

   if nCh == 1
      // No spacing
   elseif nCh == 2
      // With spacing
      lDoub := TRUE
   else
      // Exit
      return NIL
   endif

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fScrBood(MAXROW()-1)
   fScrBood(MAXROW())

   //Skuif die databasis
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3verw","idnr"})
      aadd(aSend,{"sm3verw","bul001"})
      aadd(aSend,{"sm3verw","bul002"})
      aadd(aSend,{"sm3verw","bul003"})
      aadd(aSend,{"sm3verw","bul004"})
      aadd(aSend,{"sm3verw","bul005"})

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
      nPrnl := nPrnPrnl() - 2
      nPagl := nPrnLeng()
   else
      // Condense
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl() - 2
         nPagl := nPrnLeng()
      else
         nPrnl := nPrcPrnl() - 2
         nPagl := nPrcLeng()
      endif
   endif

   nMidc := nWidt - 29

   //Skerm
   if cLanType() == "A"
      fScrbood(MAXROW(),"Verwantskappe word gedruk!  [Esc]=Stop drukker.")
      cHdln := "INTEEL PERSENTASIES (VERWANTSKAPPE)"
      cHdl2 := "SELEKSIE: "+cHdl2
   else
      fScrbood(MAXROW(),"Relationships being printed!  [Esc]=Stop printer.")
      cHdln := "INBREEDING PERCENTAGES (RELATIONSHIPS)"
      cHdl2 := "SELECTION: "+cHdl2
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := TRUE
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
            @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
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
            @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
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
         lLoop := FALSE
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
      //       @ 23, 30 say fPercent(++nReko/nTota)+"% Voltooi"
      //    else
      //       @ 23, 30 say fPercent(++nReko/nTota)+"% Completed"
      //    endif
      //    setcolor( cColNorm() )
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()
         if eof()
            @prow()+1,  1 say repl("-",nWidt)
            if cLanType() == "A"
               @prow()+1,  1 say alltrim(str(nReko,6,0))+" diere in verslag"
            else
               @prow()+1,  1 say alltrim(str(nReko,6,0))+" animals in report"
            endif
         endif

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof()
            lLoop := FALSE
         endif
      else
         if lDoub
            @prow()+1,1 say repl("-",nWidt)
         endif
      endif
   enddo

   fPrnOff()

   //Herstel
   go top
return NIL

