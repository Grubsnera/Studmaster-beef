//SM3GEBK.PRG
//Program om geboortekennisgewings te druk
//Kopiereg (c) 1992 A van Rensburg
//12:43 20 Aug,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "fileio.ch"

/******************************************************************************/
FUNCTION sm3gebk(nTop,nLeft,nBottom,aSend)

   //Veranderlikes
   local getlist := {}
   local nCh := 1
   local cSm3data := ""
   local cSm3tydi := ""
   local cTydFile := cDd() + "sm3tydi.dbf"
   local cIndFile := cDd()+"sm3tydi"+cIndeExt()
   local aRecv    := {}
   local nScrlen  := 0
   local cHead    := ""
   local nRight   := 76
   local aColumn  := {}
   local cBrowse  := NIL
   local i        := 0
   local lMore    := TRUE
   local nKey     := 0
   local cLocate  := ""
   local cLocScr  := ""
   local nCopy    := 2
   local nBoxc    := 0
   local cOpsk    := ""
   local cBrep    := ""
   local lNewb    := .f.
   private cData  := ""
   private cRasn  := ""

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop    == NIL,  3, nTop )
   nLeft   := if( nLeft   == NIL,  2, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )

   // Delete index files
   ferase(cIndFile)

   //Kry die rasnaam
   cOpsk := fRasNaam(substr(cTotNaam(),149,3),"HEADBN")
   cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

   if empty(cOpsk)
      cRasn := fRasNaam(substr(cTotNaam(),149,3))
      if cLanType() == "A"
         cOpsk := "die "+cRasn+" Beestelersgenootskap van S.A."
      else
         cOpsk := "the "+cRasn+" Cattle Breeders Society of S.A."
      endif
   endif

   //Vra die diere waarvoor gedruk moet word.
   nCh := fNewMenu(nCh,"SM3GEBK")
   if nCh < 1
      return NIL
   endif

   cOption(nCh)

   //Open die .dbf
   if cLanType() == "A"
      fScrWbood(24,"Hoofdatalˆer word geopen")
   else
      fScrWbood(24,"Main data file being opened")
   endif

   cSm3data := fTOpen(cDd(),"sm3data",,"dbf",,TRUE,FALSE)
   if left(cSm3data,1) == "f"
      cOption(-1)
      return NIL
   endif

   //Soek diere uit
   do case
      case nCh == 1
         //Enkel dier
         if cLanType() == "A"
            fScrOpsk( 1, "Opsie "+cOption())
            fScrWbood(MAXROW(),"Diere vir geboortekennisgewings word uitgesoek")
         else
            fScrOpsk( 1, "Option "+cOption())
            fScrWbood(MAXROW(),"Animals requiring birth notifications being sorted")
         endif

         fScrbood(MAXROW()-1)
         go bottom
         copy to (cTydFile) fields idnr,kalfbnr while !eof()
      case nCh == 2
         //Pasgebore diere
         if cLanType() == "A"
            fScrOpsk( 1, "Opsie "+cOption())
            fScrWbood(MAXROW(),"Diere vir geboortekennisgewings word uitgesoek")
         else
            fScrOpsk( 1, "Option "+cOption())
            fScrWbood(MAXROW(),"Animals requiring birth notifications being sorted")
         endif

         fScrbood(MAXROW()-1)
         copy to (cTydFile) fields idnr,kalfbnr for SM3DATA->toggle2 == "G"
         lNewb := .t.
      case nCh == 3
         //Groep
         cData := sm3groe()
         if len(trim(cData)) == 0
            cOption(-1)
            return NIL
         endif

         if cLanType() == "A"
            fScrOpsk( 1, "Opsie "+cOption())
            fScrWbood(MAXROW(),"Diere vir geboortekennisgewings word uitgesoek")
         else
            fScrOpsk( 1, "Option "+cOption())
            fScrWbood(MAXROW(),"Animals requiring birth notifications being sorted")
         endif

         fScrbood(MAXROW()-1)
         copy to (cTydFile) fields idnr,kalfbnr for &cData
      case nCh == 4
         //Seleksiegroep
         cData := sm3selg()
         if len(trim(cData)) == 0
            cOption(-1)
            return NIL
         endif

         if cLanType() == "A"
            fScrOpsk( 1, "Opsie "+cOption())
            fScrWbood(MAXROW(),"Diere vir geboortekennisgewings word uitgesoek")
         else
            fScrOpsk( 1, "Option "+cOption())
            fScrWbood(MAXROW(),"Animals requiring birth notifications being sorted")
         endif

         fScrbood(MAXROW()-1)
         copy to (cTydFile) fields idnr,kalfbnr for &cData
      otherwise
         //Herstel
         cOption(-1)
         return NIL
   endcase

   //Open tydelike leer
   if cLanType() == "A"
      fScrWbood(MAXROW(),"Tydelike geboortekennisgewinglˆer word geopen")
   else
      fScrWbood(MAXROW(),"Temporary birth notification file being opened")
   endif
   cSm3tydi := fTOpen(cDd(),"sm3tydi",,"dbf",,FALSE,FALSE)
   if left(cSm3tydi,1) == "f"
      fTClose(cSm3data)
      cOption(-1)
      return NIL
   endif

   //Kyk of daar enige diere in die leer is
   if lastrec() <= 0 .and. nCh > 1
      if cLanType() == "A"
         fScrBood(MAXROW()-1,"Geen diere is gevind waarvoor geboortekennisgewings gedruk moet word nie!")
      else
         fScrBood(MAXROW()-1,"No animals for which birth notifications should be printed were found!")
      endif
      fScrWait(24)
      fTClose(cSm3tydi)
      fTClose(cSm3data)
      cOption(-1)
      return NIL
   endif

   //Verwyder enige diere in geval van die enkel dier opsie
   select SM3TYDI
   if nCh == 1
      zap
   endif

   //Diere wel gevind - set relation
   set relation to SM3TYDI->idnr into SM3DATA

   //Veldbeskrywings
   if cLanType() == "A"
      fScrBood(MAXROW(),"Skermuitleg word bepaal")
   else
      fScrBood(MAXROW(),"Screen outlay being determined")
   endif
   aRecv := fGetfield( aSend )

   //Kry totale lengte van velde om breedte van venster te bepaal
   for i = 1 to len(aRecv)
      //Lengte
      nScrlen := nScrlen + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die boks
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "DIERE VIR GEBOORTEKENNISGEWINGS" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "ANIMALS FOR BIRTH NOTIFICATIONS" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas Kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   //Main loop
   lMore := TRUE
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( MAXROW()-1, "[Esc]=Menu  [Ins]=Nuwe dier  [AltP]=Druk geboortekennisgewing        ")
         fScrBood( MAXROW(), "[A-Z]=Vind  [Del]=Skrap      [AltF]=Elektroniese geboortekennisgewing")
      else
         fScrBood( MAXROW()-1, "[Esc]=Menu  [Ins]=New animal  [AltP]=Print birth notification     ")
         fScrBood( MAXROW(), "[A-Z]=Find  [Del]=Delete      [AltF]=Electronic birth notification")
      endif

      //Vries
      cBrowse:Freeze := 1

      //Sabilize display until stable or key is pressed
      nKey := 0
      do while nKey == 0 .and. .not. cBrowse:stable
         cBrowse:stabilize()
         nKey := InKey()
      enddo

      if cBrowse:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         cBrowse:refreshCurrent()
         ForceStable(cBrowse)
         // Everything's done -- wait for a key
         if nCh == 1
            keyboard chr(K_CTRL_BS)
            nCh := 0
         endif
         nKey := Inkey(0)
      endif

      if nKey == K_ESC
         // Esc means Leave
         lMore := FALSE

      elseif nKey == K_INS .or. nKey == K_CTRL_BS
         //Nuwe nommer
         if fIdnr(,cBrowse,aRecv)
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_P
         //Alt P means print a record
         nCopy := 1                              // fCopies(2) 07-05-28 12:16
         for i = 1 to nCopy
            if i == nCopy
               if cIsoCoun() == "ZWE"
                  // Zimbabwe
                  if !fPzimb(lNewb,cOpsk)
                     i := 100
                  endif
                  //elseif cIsoCoun() == "NAM"
                  // Namibia
                  //if !fPnami(lNewb,cOpsk)
                  //   i := 100
                  //endif
               elseif cBrep $ "JYjy"
                  // Breedplan
                  if !fPbree(lNewb,cOpsk)
                     i := 100
                  endif
                  //elseif substr(cTotNaam(),149,3) == "211"
                  // Angus
                  //if !fPangu(lNewb,cOpsk)
                  //   i := 100
                  //endif
                  //elseif substr(cTotNaam(),149,3) == "213"
                  //Bonsmara
                  //if !fPbons(lNewb,cOpsk)
                  //   i := 100
                  //endif
               else
                  //Ander rasse
                  //if !fPlist(lNewb,cOpsk) 05-08-11 16:15
                  if !fPiris(lNewb,cOpsk)
                     i := 100
                  endif
               endif
            else
               if cIsoCoun() == "ZWE"
                  // Zimbabwe
                  if !fPzimb(FALSE,cOpsk)
                     i := 100
                  endif
                  //elseif cIsoCoun() == "NAM"
                  // Namibia
                  //if !fPnami(FALSE,cOpsk)
                  //   i := 100
                  //endif
               elseif cBrep $ "JYjy"
                  // Breedplan
                  if !fPbree(lNewb,cOpsk)
                     i := 100
                  endif
                  //elseif substr(cTotNaam(),149,3) == "211"
                  // Angus
                  //if !fPangu(FALSE,cOpsk)
                  //   i := 100
                  //endif
                  //elseif substr(cTotNaam(),149,3) == "213"
                  //Bonsmara
                  //if !fPbons(FALSE,cOpsk)
                  //   i := 100
                  //endif
               else
                  //Ander rasse
                  //if !fPlist(FALSE,cOpsk) 05-08-11 16:15
                  if !fPiris(FALSE,cOpsk)
                     i := 100
                  endif
               endif
            endif
         next
         go top
         pack
         go top
         if lastrec() <= 0
            keyboard chr(K_ESC)
         endif
         cBrowse:refreshall()

      elseif nKey == K_ALT_F

         // Alt F means create electronic birth notification
         if cIsoCoun() == "ZWE"
            if fDiskZimb(lNewb)
               cBrowse:refreshall()
            endif
            //elseif cIsoCoun() == "NAM"
            //   if fDiskNami(lNewb)
            //      cBrowse:refreshall()
            //   endif
         else
            if cBrep $ "JYjy"
               // Breedplan format
               if fDiskBrep(lNewb)
                  cBrowse:refreshall()
               endif
            else
               // Iris format
               if fDiskIris(lNewb)
                  cBrowse:refreshall()
               endif
            endif
         endif

      elseif nKey == K_DEL

         //Del means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1

         //Hulp
         do help with "sm3gebk",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57

         // Means locate a record
         cLocate := upper( chr( nKey ) ) + space(11)
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(MAXROW(),"Tik die Id nommer waarvoor gesoek word.")
         else
            fScrBood(MAXROW(),"Type the Id number to be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxc := fBoxCent( 11, "Vind watter dier? xxxxxxxxxxxx", 3 )
            @12, nBoxc say "Vind watter dier?" get cLocate pict "@!"
         else
            nBoxc := fBoxCent( 11, "Find which animal? xxxxxxxxxxxx", 3 )
            @12, nBoxc say "Find which animal?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            locate for trim(cLocate) $ SM3TYDI->idnr
            if eof()
               go top
               if cLanType() == "A"
                  fScrBood(MAXROW()-1,"Geen dier gevind!")
               else
                  fScrBood(MAXROW()-1,"No animal found!")
               endif
               fScrWait(24)
            endif
            cBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   select SM3TYDI
   set relation to
   fTClose(cSm3tydi)
   fTClose(cSm3data)
   cOption(-1)
return NIL

//****************************************************************************/
STATIC FUNCTION fDelete()

   //Funksie om diere te skrap

   //Verklaar
   local lRetu := FALSE

   //Vra
   fScrBood(MAXROW()-1,trim(SM3TYDI->idnr))
   if cLanType() == "A"
      if fJaNee(MAXROW(),"Moet "+trim(SM3TYDI->idnr)+" geskrap word vanaf die geboortekennisgewinglys?",cColBott(),FALSE,TRUE)
         lRetu := TRUE
         select SM3DATA
         if SM3DATA->toggle2 == "G"
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
         endif
         select SM3TYDI
         delete
         skip
         if eof()
            go bottom
         endif
      endif
   else
      if fJaNee(MAXROW(),"Should "+trim(SM3TYDI->idnr)+" be deleted from the birth notification list?",cColBott(),FALSE,TRUE)
         lRetu := TRUE
         select SM3DATA
         if SM3DATA->toggle2 == "G"
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
         endif
         select SM3TYDI
         delete
         skip
         if eof()
            go bottom
         endif
      endif
   endif

   //Herstel
return lRetu

/******************************************************************************/
STATIC FUNCTION fPangu(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nBlad   := 1
   local nWidt   := 0
   local nWidN   := 0
   local nMidc   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local cCond   := ""
   local cNorm   := ""

   begin sequence

      //Toets of drukker gereed is
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl() - 8
      nMidc := nWidN - 27

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      // Printer on
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING (Opsie "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "1 DokNr.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "2 LidNr.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "3 RasNr.......: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Voorvoegsel.: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "                    |      |   |----Geboortestatus----|----Kalf----|-------Vaar---------|-------Moer---------|      |Waa|   |Geb"
               @prow()+1, 1 say "                    |Geb.  |   |Enk|Twe|Nie|Vee|Dek|Id|            |RegNr          TatNr|RekNr          TatNr|Insem.|by |Sub|286"
               @prow()+1, 1 say "Naam van kalf       |datum |Ges|Twe|met|reg|vaa|kod|me|Kkm  Jr Volg|       Naam         |       Naam         |datum |geb|afd|Ma "
               @prow()+1, 1 say "6                   |7     | 8 | 9 |10 |12 |13 |14 |15|16   17 18  |21     20      22   |25     24      26   | 27   |28a|285|287"
               //                1                   21     28  32  36  40  44  48  52 55    61 64  68                   89                  110     117 121 125
               @prow()+1,  1 say repl( "=", nWidt )
            else
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION (Option "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "1 DocNo.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "2 MemNo.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "3 BreedNo.....: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Prefix......: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "                    |      |   |------Birth status----|----Calf----|-------Sire---------|-------Dam----------|      |Obs|Sub|Bir"
               @prow()+1, 1 say "                    |Birth |   |Sta|Twi|No |Mul|Ser|Id|            |RegNo          TatNo|RekNo          TatNo|Insem |at |of |286"
               @prow()+1, 1 say "Name of calf        |date  |Sex|tus|wit|reg|sir|cod|me|Hdl  Yr Seq |       Name         |       Name         |date  |bir|cal|Dam"
               @prow()+1, 1 say "6                   |7     | 8 | 9 |10 |12 |13 |14 |15|16   17 18  |21     20      22   |25     24      26   | 27   |28a|285|287"
               //                1                   21     28  32  36  40  44  48  52 55    61 64  68                   89                  110     117 121 125
               @prow()+1,  1 say repl( "=", nWidt )
            endif

         endif

         //Data
         //fPrnCod( cCond )
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow()+1,  1 say left(cData,20)
         @prow()  , 21 say "|" + right( dtos( SM3DATA->gebdatum ), 6 )
         @prow()  , 28 say "| " + SM3DATA->geslag
         @prow()  , 32 say "| " + SM3DATA->gebstat
         @prow()  , 36 say "| " + SM3DATA->tweeling
         @prow()  , 40 say "| " + SM3DATA->niereg
         if "VVAAR" $ upper(SM3DATA->idvaar) .or. "MSIRE" $ upper(SM3DATA->idvaar)
            @prow()  , 44 say "| 1 "
         else
            @prow()  , 44 say "|   "
         endif
         @prow()  , 48 say "| " + SM3DATA->vaarkode
         @prow()  , 52 say "|" + left(SM3DATA->ident,2)

         //Id nommer
         cData := fid(SM3DATA->idnr,.t.)
         @prow()  , 55 say "|" + left(cData,4)
         @prow()  , 61 say substr(cData,5,2)
         @prow()  , 64 say right(cData,4)

         //Id vaar
         @prow()  , 68 say "|"+fVaarData("reknr")
         cData := fid(SM3DATA->idvaar,.t.)
         cData := trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4))
         @prow()  , 89-len(trim(cData)) say trim(cData)

         //Id moer
         @prow()  , 89 say "|"+fMoerData("reknr")
         cData := fid(SM3DATA->idmoer,.t.)
         cData := trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4))
         @prow()  , 110-len(trim(cData)) say trim(cData)

         //Res van dier
         @prow()  ,110 say "|" + right( dtos( SM3DATA->idatum ), 6 )
         @prow()  ,117 say "| " + SM3DATA->kalfstat
         @prow()  ,121 say "| " + SM3DATA->subafd
         @prow()  ,125 say "| " + str(SM3DATA->gebmassa,2,0)

         //Volgende lyn
         @prow()+1, 21 say "|"
         @prow()  , 28 say "|"
         @prow()  , 32 say "|"
         @prow()  , 36 say "|"
         @prow()  , 40 say "|"
         @prow()  , 44 say "|"
         @prow()  , 48 say "|"
         @prow()  , 52 say "|"
         if SM3DATA->vaarkode == "4"
            @prow()  , 55 say "|(" + trim(SM3DATA->bloednr) + ")"
         else
            @prow()  , 55 say "|"
         endif
         @prow()  , 68 say "|"+left(fVaarData("idnaam"),20)
         @prow()  , 89 say "|"+left(fMoerData("idnaam"),20)
         @prow()  ,110 say "|"
         @prow()  ,117 say "|"
         @prow()  ,121 say "|"
         @prow()  ,125 say "|"+str(SM3DATA->mamoergeb,3,0)

         @prow()+1,  1 say repl( "-", nWidt )

         //Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         //Verwyder gedrukte dier
         if lDelete
            delete
         endif

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
               @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
               @prow()+1,  1 say 'Stamboekvereniging en ' + cOpsk
               @prow()+1, 80 say 'Handtekening...: ________________________________'
               @prow()+1,  1 say cAppName()
            else
               @prow()+1,  1 say 'I declare that I have bred the animals described here and that the breeding'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'details, pedigree and identification  marks are  correct  and  I  agree  to'
               @prow()+1,  1 say 'honour and submit myself to the regulations of the Stud Book Association'
               @prow()+1,  1 say 'and '+ cOpsk
               @prow()+1, 80 say 'Signature......: ________________________________'
               @prow()+1,  1 say cAppName()
            endif

            fPrnEjec()

            //fPrnOff()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fPbons(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nBlad   := 1
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nWidt   := 0
   local nWidN   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local nMidc   := 0
   local cCond   := ""
   local cNorm   := ""

   begin sequence

      //Toets of drukker gereed is
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl() - 8
      nMidc := nWidN - 27

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()
      index on SM3TYDI->kalfbnr+SM3TYDI->idnr to (cDd()+"SM3TYDI"+cIndeExt())
      set index to (cDd()+"SM3TYDI"+cIndeExt())
      go top

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      //Skakel die drukker aan
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING (Opsie "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "1 DokNr.......: 2421"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "2 LidNr.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40)) + ", " + substr(cTotNaam(),121,4)
               @prow()  , nMidc say "3 RasNr.......: " + substr(cTotNaam(),149,3)
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "         |        |     |-------Geboortestatus-------| ---Kalf------- | ---Vaar----- | ---Moer----- |        |      | Waar | Gema"
               @prow()+1, 1 say "         | Geb.   | Ges | Enk | Twe | Nie | Veel| Ver|      Jaar Kalf | 22-Id Nommer | 26-Id nommer | Insem. | Gebo | by   | van "
               @prow()+1, 1 say "KalfbNr. | Dat.   | 1/2 | Twe | met | Reg | Vaar| wek| KKM  Nr   Nr   | RegNr        | RegNr        | Datum  | Mass | Gebo | Kalf"
               @prow()+1, 1 say "         | 7      | 8   | 9   | 10  | 12  | 13  | 14 | 16   17   18   |              |              | 27     | 28.6 | 28a  | 28b "
               //                1          12       21    27    33    39    45    51   56   61   66     73             88             103      112    119    126
               @prow()+1,  1 say repl( "=", nWidt )
            else
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION (Option "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "1 DocNo.......: 2421"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "2 MemNo.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40)) + ", " + substr(cTotNaam(),121,4)
               @prow()  , nMidc say "3 BreedNo.....: " + substr(cTotNaam(),149,3)
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "         | Date   |     |--------Birth status--------| ---Calf------- | ---Sire----- | ----Dam----- |        |      | Obse | Ease"
               @prow()+1, 1 say "Calfbook | of     | Sex | Sing| Twin| No  | Mult| Beg|      Year Calf | 22-Id Number | 26-Id Number | Insem. | Birth| at   | of  "
               @prow()+1, 1 say "number   | birth  | 1/2 | Twin| with| Reg | Sire| by | HDM  No   No   | RegNo        | RegNo        | date   | mass | birth| calf"
               @prow()+1, 1 say "         | 7      | 8   | 9   | 10  | 12  | 13  | 14 | 16   17   18   |              |              | 27     | 28.6 | 28a  | 28b "
               //                1          12       21    27    33    39    45    51   56   61   66     73             88             103      112    119    126
               @prow()+1,  1 say repl( "=", nWidt )
            endif

         endif

         //Data
         @prow()+1,  1 say alltrim(SM3DATA->kalfbnr)
         @prow()  , 10 say "| " + right( dtos( SM3DATA->gebdatum ), 6 )
         @prow()  , 19 say "|  " + SM3DATA->geslag
         @prow()  , 25 say "|  " + SM3DATA->gebstat
         @prow()  , 31 say "|  " + SM3DATA->tweeling
         @prow()  , 37 say "|  " + SM3DATA->niereg
         @prow()  , 43 say "|  " + " "
         @prow()  , 49 say "|  " + SM3DATA->vaarkode

         //Id nommer
         cData := fid(SM3DATA->idnr,.t.)
         @prow()  , 54 say "| " + left(cData,4)
         @prow()  , 61 say substr(cData,5,2)
         @prow()  , 66 say right(cData,4)

         //Id vaar
         cData := fid(SM3DATA->idvaar,.t.)
         @prow()  , 71 say "| " + trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4))

         //Id moer
         cData := fid(SM3DATA->idmoer,.t.)
         @prow()  , 86 say "| " + trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4))

         //Res van dier
         if SM3DATA->vaarkode $ "34"
            @prow()  ,101 say "| " + right( dtos( SM3DATA->idatum ), 6 )
         else
            @prow()  ,101 say "|"
         endif
         @prow()  ,110 say "| " + str(SM3DATA->gebmassa,2,0)
         @prow()  ,117 say "| " + SM3DATA->kalfstat
         @prow()  ,124 say "| " + SM3DATA->kalfgem

         //Volgende lyn
         @prow()+1, 10 say "|"
         @prow()  , 19 say "|"
         @prow()  , 25 say "|"
         @prow()  , 31 say "|"
         @prow()  , 37 say "|"
         @prow()  , 43 say "|"
         @prow()  , 49 say "|"
         if SM3DATA->vaarkode == "4"
            @prow()  , 54 say "|(" + trim(SM3DATA->bloednr) + ")"
         else
            @prow()  , 54 say "|"
         endif
         @prow()  , 71 say "| " + fVaarData( "reknr" )
         @prow()  , 86 say "| " + fMoerData( "reknr" )
         @prow()  ,101 say "| "
         @prow()  ,110 say "| "
         @prow()  ,117 say "| "
         @prow()  ,124 say "| "

         @prow()+1,  1 say repl( "-", nWidt )

         //Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         //Verwyder gedrukte dier
         if lDelete
            delete
         endif

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
               @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
               @prow()+1,  1 say 'Stamboekvereniging en ' + cOpsk
               @prow()+1, 80 say 'Handtekening...: ________________________________'
               @prow()+1,  1 say cAppName()
            else
               @prow()+1,  1 say 'I declare that I have bred the animals described here and that the breeding'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'details, pedigree and identification  marks are  correct  and  I  agree  to'
               @prow()+1,  1 say 'honour and submit myself to the regulations of the Stud Book Association'
               @prow()+1,  1 say 'and '+ cOpsk
               @prow()+1, 80 say 'Signature......: ________________________________'
               @prow()+1,  1 say cAppName()
            endif

            fPrnEjec()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   set index to
   go top
   ferase(cDd()+"SM3TYDI"+cIndeExt())

return lRetu

/******************************************************************************/
STATIC FUNCTION fPlist(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nBlad   := 1
   local nWidt   := 0
   local nWidN   := 0
   local nMidc   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local cCond   := ""
   local cNorm   := ""

   begin sequence

      //Toets of drukker gereed is
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl() - 8
      nMidc := nWidN - 27

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      // Printer on
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING (Opsie "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "1 DokNr.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "2 LidNr.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "3 RasNr.......: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Voorvoegsel.: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "                    |      |   |--Geboortestatus---|----Kalf----|-------Vaar---------|-------Moer---------|      |Waa|Gem|Geb|   "
               @prow()+1, 1 say "                    |Geb.  |   |Enk|Tw|Ni|Ve|De|Ide|            |RegNr          TatNr|RekNr          TatNr|Insem.|by |van|286|Tip"
               @prow()+1, 1 say "Naam van kalf       |datum |Ges|Twe|me|re|va|ko|met|Kkm  Jr Volg|       Naam         |       Naam         |datum |geb|kal|Ma |kle"
               @prow()+1, 1 say "6                   |7     | 8 | 9 |10|12|13|14|15 |16   17 18  |21     20      22   |25     24      26   | 27   |28a|28b|287|288"
               //                1                   21     28  32  36 39 42 45 48  52    58 61  65      73      81   86      94      102  107    114 118 122 126
               @prow()+1,  1 say repl( "=", nWidt )
            else
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION (Option "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "1 DocNo.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "2 MemNo.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "3 BreedNo.....: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Prefix......: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "                    |      |   |---Birth status----|----Calf----|-------Sire---------|-------Dam----------|      |Obs|Eas|Bir|   "
               @prow()+1, 1 say "                    |Birth |   |Sta|Tw|No|Mu|Se|Ide|            |RegNo          TatNo|RekNo          TatNo|Insem |at |of |286|Typ"
               @prow()+1, 1 say "Name of calf        |date  |Sex|tus|wi|re|si|ty|met|Hdl  Yr Seq |       Name         |       Name         |date  |bir|cal|Dam|col"
               @prow()+1, 1 say "6                   |7     | 8 | 9 |10|12|13|14|15 |16   17 18  |21     20      22   |25     24      26   | 27   |28a|28b|287|288"
               //                1                   21     28  32  36 39 42 45 48  52    58 61  65                   86                   107    114 118 122 126
               @prow()+1,  1 say repl( "=", nWidt )
            endif

         endif

         //Data
         //fPrnCod( cCond )
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow()+1,  1 say left(cData,20)
         @prow()  , 21 say "|" + right( dtos( SM3DATA->gebdatum ), 6 )
         @prow()  , 28 say "| " + SM3DATA->geslag
         @prow()  , 32 say "| " + SM3DATA->gebstat
         @prow()  , 36 say "| " + SM3DATA->tweeling
         @prow()  , 39 say "| " + SM3DATA->niereg
         if "VVAAR" $ upper(SM3DATA->idvaar) .or. "MSIRE" $ upper(SM3DATA->idvaar)
            @prow()  , 42 say "| 1"
         else
            @prow()  , 42 say "|  "
         endif
         @prow()  , 45 say "| " + SM3DATA->vaarkode
         @prow()  , 48 say "| " + left(SM3DATA->ident,2)

         //Id nommer
         cData := fid(SM3DATA->idnr,.t.)
         @prow()  , 52 say "|" + left(cData,4)
         @prow()  , 58 say substr(cData,5,2)
         @prow()  , 61 say right(cData,4)

         //Id vaar
         @prow()  , 65 say "|"+fVaarData("reknr")
         cData := fid(SM3DATA->idvaar,.t.)
         cData := trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4))
         @prow()  , 86-len(trim(cData)) say trim(cData)

         //Id moer
         @prow()  , 86 say "|"+fMoerData("reknr")
         cData := fid(SM3DATA->idmoer,.t.)
         cData := trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4))
         @prow()  , 107-len(trim(cData)) say trim(cData)

         //Res van dier
         @prow()  ,107 say "|" + right( dtos( SM3DATA->idatum ), 6 )
         @prow()  ,114 say "| " + SM3DATA->kalfstat
         @prow()  ,118 say "| " + SM3DATA->kalfgem
         @prow()  ,122 say "| " + str(SM3DATA->gebmassa,2,0)
         @prow()  ,126 say "|" + left(SM3DATA->tipies,3)

         //Volgende lyn
         @prow()+1, 21 say "|"
         @prow()  , 28 say "|"
         @prow()  , 32 say "|"
         @prow()  , 36 say "|"
         @prow()  , 39 say "|"
         @prow()  , 42 say "|"
         @prow()  , 45 say "|"
         @prow()  , 48 say "|"
         if SM3DATA->vaarkode == "4"
            @prow()  , 52 say "|(" + trim(SM3DATA->bloednr) + ")"
         else
            @prow()  , 52 say "|"
         endif
         @prow()  , 65 say "|"+left(fVaarData("idnaam"),20)
         @prow()  , 86 say "|"+left(fMoerData("idnaam"),20)
         @prow()  ,107 say "|"
         @prow()  ,114 say "|"
         @prow()  ,118 say "|"
         @prow()  ,122 say "|"+str(SM3DATA->mamoergeb,3,0)
         @prow()  ,126 say "|"

         @prow()+1,  1 say repl( "-", nWidt )

         //Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         //Verwyder gedrukte dier
         if lDelete
            delete
         endif

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
               @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
               @prow()+1,  1 say 'Stamboekvereniging en ' + cOpsk
               @prow()+1, 80 say 'Handtekening...: ________________________________'
               @prow()+1,  1 say cAppName()
            else
               @prow()+1,  1 say 'I declare that I have bred the animals described here and that the breeding'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'details, pedigree and identification  marks are  correct  and  I  agree  to'
               @prow()+1,  1 say 'honour and submit myself to the regulations of the Stud Book Association'
               @prow()+1,  1 say 'and '+ cOpsk
               @prow()+1, 80 say 'Signature......: ________________________________'
               @prow()+1,  1 say cAppName()
            endif

            fPrnEjec()

            //fPrnOff()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fPiris(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nBlad   := 1
   local nWidt   := 0
   local nWidN   := 0
   local nMidc   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local cCond   := ""
   local cNorm   := ""
   local cIcar   := ""

   local cSexx := ""
   local nPcol := 0

   altd()

   begin sequence

      //Toets of drukker gereed is
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      // Get the iso breed code
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl() - 8
      else
         nPrnl := nPrcPrnl() - 8
      endif
      nMidc := nWidN - 27

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      // Printer on
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"

               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Verslag.....: " + cOption()
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "  Datum.......: " + dtoc(dAppDate())
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()+1,  1 say repl( "-",  nPrnWidt() )

               @prow()+1, 1 say "1 Dokumentkode.: ANIM"
               @prow()  , nMidc say "4 Doel.........: Beef"
               @prow()+1, 1 say "2 Aksietipe....: Create"
               @prow()  , nMidc say "6 Deelnemerkode: " + padl(alltrim(substr(cTotNaam(),152,10)),7,"0") + cIcar
               @prow()+1, 1 say "3 Dokument tipe: BirthNotification"
               @prow()  , nMidc say "9 Raskode......: " + cIcar

               @prow()+1,  1 say repl( "-",  nPrnWidt() )

               fPrnCod( cCond )

               @prow()+1, 2 say "N|G|R|KalfIdNommer        |Mi|D |GebDatum|ToetsN|Bs|Ka|Ge|Su|Kl|Moer RekNr           |Vaar RekNr           |VV|"
               @prow()+1, 2 say "F|e|e|10                  |11|e |16      |20    |24|st|va|33|eu|39                   |40                   |45|"
               @prow()+1, 2 say "R|s|g|KalfNaam            |Si|k |Gmas Gak|KmasAk|Sx|at|ka|HP|r |Moer IdNr            |Vaar IdNr            |Ss|"
               @prow()+1, 2 say "5|7|8|12                  |13|15|17   19 |21  23|25|30|31|34|38|41                   |42                   |46|"


               @prow()+1,  1 say repl( "-", nWidt )

            else

               // English headings

               fPrnCod( cNorm )

               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Report......: " + cOption()
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "  Date........: " + dtoc(dAppDate())
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()+1,  1 say repl( "-",  nPrnWidt() )

               @prow()+1, 1 say "1 Document code: ANIM"
               @prow()  , nMidc say "4 Purpose......: Beef"
               @prow()+1, 1 say "2 Action type..: Create"
               @prow()  , nMidc say "6 Participant..: " + padl(alltrim(substr(cTotNaam(),152,10)),7,"0") + cIcar
               @prow()+1, 1 say "3 Document type: BirthNotification"
               @prow()  , nMidc say "9 Breed code...: " + cIcar

               @prow()+1,  1 say repl( "-",  nPrnWidt() )

               fPrnCod( cCond )

               @prow()+1, 2 say "N|S|R|CalfIdNumber        |Id|S |BirthDat|TestNo|Bs|Ca|Ea|Su|Co|Dam Comp No          |Sire Comp No         |MS|"
               @prow()+1, 2 say "F|e|e|10                  |11|e |16      |20    |24|st|of|33|lo|39                   |40                   |45|"
               @prow()+1, 2 say "R|x|g|CalfName            |Si|r |BmassAcc|CmasAc|Sx|  |ca|HP|  |Dam Id No            |Sire Id No           |Ls|"
               @prow()+1, 2 say "5|7|8|12                  |13|15|17   19 |21  23|25|30|31|34|38|41                   |42                   |46|"

               @prow()+1,  1 say repl( "-", nWidt )

            endif

         endif

         // Data

         // Not for registration
         if SM3DATA->niereg == "1"
            @prow()+1,  2 say "Y"+"|"
         else
            @prow()+1,  2 say "N"+"|"
         endif

         // Sex
         if SM3DATA->geslag $ "1VFKC"
            @prow()  ,pcol() say "F"+"|"
            cSexx := "F"
         else
            @prow()  ,pcol() say "M"+"|"
            cSexx := "M"
         endif

         // Registration status
         if SM3DATA->niereg == "C"
            @prow(),pcol() say "C"+"|"
         else
            If substr(cTotNaam(),149,3) == "229" //Santa Gertrudis
               @prow(),pcol() say "Q"+"|"
            else
               @prow(),pcol() say "R"+"|"
            endif
         endif

         //Id nommer
         cData := fid(SM3DATA->idnr,.t.)
         nPcol := pcol()
         @prow(),pcol() say cIcar
         @prow(),pcol()+1 say cSexx
         @prow(),pcol()+1 say left(cData,4)
         @prow(),pcol()+1 say substr(cData,5,2)
         @prow(),pcol()+1 say right(cData,4)
         if SM3DATA->niereg == "C"
            @prow(),pcol()+1 say "*"+"|"
         else
            @prow(),pcol()+1 say " "+"|"
         endif

         // Id method
         @prow(),pcol() say left(SM3DATA->ident,2)+"|"

         // Service
         if SM3DATA->vaarkode $ "4"
            @prow(),pcol() say "3 "+"|"
         elseif SM3DATA->vaarkode $ "3"
            @prow(),pcol() say "2 "+"|"
         else
            @prow(),pcol() say "1 "+"|"
         endif

         // Date of birth
         @prow(),pcol() say padr(dtod(SM3DATA->gebdatum),8) + "|"

         // Beef test number
         if !empty(SM3DATA->indekskode)
            cData := fDataLocate("SM3INDG","Kode",SM3DATA->indekskode,"Testye")
            cData +=fDataLocate("SM3INDG","Kode",SM3DATA->indekskode,"Testno")
            @prow(),pcol() say padr(cData,6) + "|"
         else
            @prow(),pcol() say space(6) + "|"
         endif

         // Birth status
         @prow(),pcol() say padr(SM3DATA->gebstat,2) + "|"

         // Calf status
         @prow(),pcol() say padr(SM3DATA->kalfstat,2) + "|"

         // Ease of calving
         @prow(),pcol() say padr(SM3DATA->kalfgem,2) + "|"

         // Subafdeling
         @prow(),pcol() say padr(SM3DATA->subafd,2) + "|"

         // Colour
         @prow(),pcol() say padr(SM3DATA->tipies,2) + "|"

         // Dam comp number
         @prow(),pcol() say padr(fMoerData("reknr"),21) + "|"

         // Sire comp number
         @prow(),pcol() say padr(fVaarData("reknr"),21) + "|"

         // Multiple sire
         if "VVAAR" $ upper(SM3DATA->idvaar) .or. "MSIRE" $ upper(SM3DATA->idvaar)
            @prow(),pcol() say "Y |"
         else
            @prow(),pcol() say "  |"
         endif

         // Second line

         // Spacers
         @prow()+1,     2 say " "+"|"
         @prow()  ,pcol() say " "+"|"
         @prow()  ,pcol() say " "+"|"

         // Name of animal
         cData := SM3DATA->idnaam
         cData := padr(alltrim(strtran(cData,alltrim(substr(cTotNaam(),129,20)))),20)
         @prow(),pcol() say left(cData,20) + "|"

         // Second Id method
         @prow(),pcol() say right(SM3DATA->ident,2)+"|"

         // Filler for service
         @prow(),pcol() say "  |"

         // Birth mass and accuracy
         @prow(),pcol() say str(SM3DATA->gebmassa,3,0)
         @prow(),pcol() say "  Y  |"

         // Beef test number
         @prow(),pcol() say str(SM3DATA->mamoergeb,3,0)
         if !empty(SM3DATA->mamoergeb)
            @prow(),pcol() say " Y " + "|"
         else
            @prow(),pcol() say "   " + "|"
         endif

         // Twins with
         if empty(SM3DATA->tweeling)
            @prow()  ,pcol() say "  "+"|"
         elseif SM3DATA->geslag $ "1VFKC"
            @prow()  ,pcol() say "F "+"|"
         else
            @prow()  ,pcol() say "M "+"|"
         endif

         // Filler for calving status
         @prow(),pcol() say "  " + "|"

         // Filler for ease of calving
         @prow(),pcol() say "  " + "|"

         // Horn poll filler
         @prow(),pcol() say padr(SM3DATA->type,2) + "|"

         // Filler for colour
         @prow(),pcol() say "  " + "|"

         // Dam id number
         @prow(),pcol() say cIcar + " "
         cData := fMoerData("geslag")
         if cData $ "1VFKC"
            @prow()  ,pcol() say "F "
         else
            @prow()  ,pcol() say "M "
         endif
         cData := fid(SM3DATA->idmoer,.t.)
         @prow(),pcol()+1 say left(cData,4)
         @prow(),pcol()+1 say substr(cData,5,2)
         @prow(),pcol()+1 say right(cData,4)
         cData := fMoerData("niereg")
         if cData == "C"
            @prow(),pcol()+1 say "*"+"|"
         else
            @prow(),pcol()+1 say " "+"|"
         endif

         // Sire id number
         @prow(),pcol() say cIcar + " "
         cData := fVaarData("geslag")
         if cData $ "1VFKC"
            @prow()  ,pcol() say "F "
         else
            @prow()  ,pcol() say "M "
         endif
         cData := fid(SM3DATA->idvaar,.t.)
         @prow(),pcol()+1 say left(cData,4)
         @prow(),pcol()+1 say substr(cData,5,2)
         @prow(),pcol()+1 say right(cData,4)
         cData := fVaarData("niereg")
         if cData == "C"
            @prow(),pcol()+1 say "*"+"|"
         else
            @prow(),pcol()+1 say " "+"|"
         endif

         // Lowest subsection
         if "VVAAR" $ upper(SM3DATA->idvaar) .or. "MSIRE" $ upper(SM3DATA->idvaar)
            @prow(),pcol() say fVaarData("generasie") + "|"
         else
            @prow(),pcol() say "  |"
         endif

         @prow()+1,  1 say repl( "-", nWidt )

         // Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         // Verwyder gedrukte dier
         if lDelete
            delete
         endif

         // Volgende rekord
         skip

         // Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            // Print onderste lyn
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek sertifiseer data dat bogenoemde inligting korrek is:'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+3,  1 say cAppName()
               @prow()  , 80 say 'Handtekening...: ________________________________'
            else
               @prow()+1,  1 say 'I certify that above-mentioned information are correct:'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+3,  1 say cAppName()
               @prow()  , 80 say 'Signature......: ________________________________'
            endif

            fPrnEjec()

            //fPrnOff()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   go top

return lRetu


/******************************************************************************/
STATIC FUNCTION fPbree(lDelete,cOpsk)

   // Declare
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nBlad   := 1
   local nWidt   := 0
   local nWidN   := 0
   local nMidc   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local cCond   := ""
   local cNorm   := ""
   local cBrec   := ""

   begin sequence

      // Test if printer ready
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl() - 8
      //nMidc := nWidN - 27
      nMidc := nWidN - 40

      // Breed code
      cBrec := alltrim(fRasNaam(substr(cTotNaam(),149,3),"BREEDS"))

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      // Printer on
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"
               // Afrikaans
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING (Funksie "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()+1,  1 say alltrim(substr(cTotNaam(),1,40))
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say alltrim(substr(cTotNaam(),41,40))
               @prow()  , nMidc say "4 LidNr.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say alltrim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "  Ras.........: " + cBrec
               @prow()+1,  1 say alltrim(substr(cTotNaam(),121,4))
               @prow()  , nMidc say "  Voorvoegsel.: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "---------KALF----------------KALF---------------KALF-------------------KALF-----------------|---VAAR---|---MOER---|----EMBRIO----"
               @prow()+1, 1 say "Reg|GebDatum|IdNr      |Naam                |Gen|Ges|Geb|Twe|Dek|Kal|Gem|Nag|Geb|Tip|Bes|Oog|IdNr      |IdNr      |ET| DNA#      "
               @prow()+1, 1 say "sta|ddmmjjjj|          |                    |   |   |sta|met|kod|sta|kal|opm|mas|   |grp|pig|RegNr     |RegNr     |  | RecipId   "
               @prow()+1, 1 say " 5 | 7    8 |9         |10                  |11 |12 |13 |14 |16 |18 |19 |20 |21 |22 |23 |24 |          |          |15|           "
               @prow()+1, 1 say "---|--------|----------|--------------------|---|---|---|---|---|---|---|---|---|---|---|---|----------|----------|--|-----------"
               //                1  4        13         24                   45  49  53  57  61  65  69  73  77  81  85  89  93         104        115118
            else
               // English
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION (Function "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()+1,  1 say alltrim(substr(cTotNaam(),1,40))
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say alltrim(substr(cTotNaam(),41,40))
               @prow()  , nMidc say "4 MemberNo....: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say alltrim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "  Breed.......: " + cBrec
               @prow()+1,  1 say alltrim(substr(cTotNaam(),121,4))
               @prow()  , nMidc say "  Prefix......: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1, 1 say "---------CALF----------------CALF---------------CALF-------------------CALF-----------------|---SIRE---|---DAM----|----EMBRIO----"
               @prow()+1, 1 say "Reg|BirthDat|IdNumber  |Name                |Gen|Sex|Bir|Twi|Mat|Cal|Eas|Aft|Bir|Typ|Man|Eye|IdNumber  |IdNumber  |ET| DNA#      "
               @prow()+1, 1 say "sta|ddmmjjjj|          |                    |   |   |sta|wit|cod|sta|cal|rem|wht|   |grp|pig|RegNo     |RegNo     |  | RecipId   "
               @prow()+1, 1 say " 5 | 7    8 |9         |10                  |11 |12 |13 |14 |16 |18 |19 |20 |21 |22 |23 |24 |          |          |15|           "
               @prow()+1, 1 say "---|--------|----------|--------------------|---|---|---|---|---|---|---|---|---|---|---|---|----------|----------|--|-----------"
               //                1  4        13         24                   45  49  53  57  61  65  69  73  77  81  85  89  93         104        115118
            endif

         endif

         // Data

         // Register status
         cData := ""
         if cBrec == "SBBS" .or. cBrec == "SIBS"
            if empty(SM3DATA->niereg)
               cData := "Q"
            elseif SM3DATA->niereg == "C"
               cData := "C"
            else
               cData := "N"
            endif
         else
            if empty(SM3DATA->niereg)
               If substr(cTotNaam(),149,3) == "229" //Santa Gertrudis
                  cData := "Q"
               else
                  cData = "R"
               endif
            elseif SM3DATA->niereg == "C"
               cData := "C"
            else
               cData := "N"
            endif
         endif
         @prow()+1, 2 say cData

         // Date of birth
         set cent on
         @prow(),4 say "|"
         @prow(),pcol() say strtran(dtoc(SM3DATA->gebdatum),"/")
         set cent off

         altd()

         // Calf id
         @prow(),13 say "|"
         cData := ""
         if empty(SM3DATA->idsoc)
            cData := left(fId(SM3DATA->idnr,.f.),10)
         else
            cData := left(SM3DATA->idsoc,10)
         endif
         @prow(),14 say cData

         // Calf name
         @prow(),24 say "|"
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow(),pcol() say left(cData,20)

         // Generation
         cData := ""
         if cBrec == "SBBS" .or. cBrec == "SABF"
            // Simbra
            if empty(SM3DATA->generasie)
               // Pure
               cData := "  "
            elseif alltrim(SM3DATA->generasie) == "SP"
               // Pure
               cData := "  "
            elseif alltrim(SM3DATA->generasie) $ "AzF1"
               // A grade
               cData := "1 "
            elseif alltrim(SM3DATA->generasie) $ "BzF2"
               // B grade
               cData := "2 "
            elseif alltrim(SM3DATA->generasie) $ "CzF3"
               // C grade
               cData := "3 "
            elseif alltrim(SM3DATA->generasie) $ "DzF4"
               // D grade
               cData := "4 "
            elseif alltrim(SM3DATA->generasie) $ "C"
               // C grade
               cData := "C "
            else
               cData := "  "
            endif
         else
            if empty(SM3DATA->generasie)
               // Pure
               cData := "  "
            elseif alltrim(SM3DATA->generasie) == "SP"
               // Pure
               cData := "  "
            elseif alltrim(SM3DATA->generasie) $ "AzF1"
               // A grade
               cData := "A "
            elseif alltrim(SM3DATA->generasie) $ "BzF2"
               // B grade
               cData := "B "
            else
               cData := "  "
            endif
         endif
         @prow(),45 say "| "
         @prow(),pcol() say cData

         // Sex
         @prow(),49 say "| "
         if SM3DATA->geslag $ "1FVKHC"
            @prow(),pcol() say "F"
         else
            @prow(),pcol() say "M"
         endif

         // Number in birth
         @prow(),53 say "| "
         if val(SM3DATA->gebstat) >= 2
            @prow(),pcol() say alltrim(SM3DATA->gebstat)
         else
            @prow(),pcol() say "1"
         endif

         // Twin sex
         @prow(),57 say "| "
         if empty(SM3DATA->tweeling)
         elseif SM3DATA->tweeling $ "1FVKHC"
            @prow(),pcol() say "F"
         else
            @prow(),pcol() say "M"
         endif

         // Service code
         @prow(),61 say "| "
         if SM3DATA->vaarkode == "4"
         elseif SM3DATA->vaarkode $ "3"
            @prow(),pcol() say "A"
         else
            @prow(),pcol() say "N"
         endif

         // Calf fate
         @prow(),65 say "| "
         if alltrim(SM3DATA->kalfstat) $ "AzBzCzDzF"
            // As is
            @prow(),pcol() say alltrim(SM3DATA->kalfstat)
         elseif empty(SM3DATA->kalfstat)
            // Alive
         elseif alltrim(SM3DATA->kalfstat) $ "01"
            // Alive
         elseif alltrim(SM3DATA->kalfstat) $ "02z03"
            // Aborted
            @prow(),pcol() say "A"
         else
            // Died
            @prow(),pcol() say "D"
         endif

         // Calving ease
         @prow(),69 say "| "
         if alltrim(SM3DATA->kalfgem) $ "1z2z3z4z5"
            // As is
            @prow(),pcol() say alltrim(SM3DATA->kalfgem)
         elseif alltrim(SM3DATA->kalfgem) $ "09"
            // No difficulty
            @prow(),pcol() say "1"
         elseif alltrim(SM3DATA->kalfgem) $ "10"
            // Easy pull
            @prow(),pcol() say "2"
         elseif alltrim(SM3DATA->kalfgem) $ "11"
            // Hard pull
            @prow(),pcol() say "3"
         elseif alltrim(SM3DATA->kalfgem) $ "12"
            // Surgical
            @prow(),pcol() say "4"
         elseif alltrim(SM3DATA->kalfgem) $ "08"
            // Abnormal presentation
            @prow(),pcol() say "5"
         else
            // Unknown
         endif

         // After birth remark
         @prow(),73 say "|"
         @prow(),pcol() say alltrim(SM3DATA->nagebo)

         // Birth mass
         @prow(),77 say "| "
         @prow(),pcol() say SM3DATA->gebmassa

         // Animal type
         @prow(),81 say "| "
         //@prow(),pcol() say SM3DATA->type
         @prow(),pcol() say SM3DATA->tipies

         // Management group
         @prow(),85 say "| "

         // Eye pigmentation
         @prow(),89 say "| "
         @prow(),pcol() say SM3DATA->eyepig

         // Sire
         @prow(),93 say "|"
         cData := fVaarData("IDSOC")
         if empty(cData)
            cData := fId(SM3DATA->idvaar,.f.)
            @prow(),pcol() say left(cData,10)
         else
            @prow(),pcol() say left(cData,10)
         endif

         // Dam
         @prow(),104 say "|"
         cData := fMoerData("IDSOC")
         if empty(cData)
            cData := fId(SM3DATA->idmoer,.f.)
            @prow(),pcol() say left(cData,10)
         else
            @prow(),pcol() say left(cData,10)
         endif

         // ET
         @prow(),115 say "| "

         // ET extend
         @prow(),118 say "| "






         @prow()+1, 2 say ""

         // Date of birth
         @prow(),4 say "|"
         // Calf id
         @prow(),13 say "|"
         // Calf name
         @prow(),24 say "|"
         // Generation
         @prow(),45 say "| "
         // Sex
         @prow(),49 say "| "
         // Number in birth
         @prow(),53 say "| "
         // Twin sex
         @prow(),57 say "| "
         // Service code
         @prow(),61 say "| "
         // Calf fate
         @prow(),65 say "| "
         // Calving ease
         @prow(),69 say "| "
         // After birth remark
         @prow(),73 say "|"
         // Birth mass
         @prow(),77 say "| "
         // Animal type
         @prow(),81 say "| "
         // Management group
         @prow(),85 say "| "
         // Eye pigmentation
         @prow(),89 say "| "
         // Sire
         @prow(),93 say "|"+left(fVaarData("reknr"),10)
         // Dam
         @prow(),104 say "|"+left(fMoerData("reknr"),10)
         // ET
         @prow(),115 say "| "
         // ET extend
         @prow(),118 say "| "

         @prow()+1,  1 say repl( "-", nWidt )

         //Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         //Verwyder gedrukte dier
         if lDelete
            delete
         endif

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            @prow(),  1 say repl( "=", nWidt )
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
               @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
               @prow()+1,  1 say 'Stamboekvereniging en ' + cOpsk
               @prow()+1, 80 say 'Handtekening...: ________________________________'
               @prow()+1,  1 say cAppName()
            else
               @prow()+1,  1 say 'I declare that I have bred the animals described here and that the breeding'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'details, pedigree and identification  marks are  correct  and  I  agree  to'
               @prow()+1,  1 say 'honour and submit myself to the regulations of the Stud Book Association'
               @prow()+1,  1 say 'and '+ cOpsk
               @prow()+1, 80 say 'Signature......: ________________________________'
               @prow()+1,  1 say cAppName()
            endif

            fPrnEjec()

            //fPrnOff()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   go top

return lRetu


/******************************************************************************/
STATIC FUNCTION fPZimb(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nBlad   := 1
   local nWidt   := 0
   local nWidN   := 0
   local nMidc   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local cCond   := ""
   local cNorm   := ""
   local cSreg   := ""
   local cDreg   := ""

   begin sequence

      //Toets of drukker gereed is
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl() - 8
      nMidc := nWidN - 27

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      // Printer on
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING (Opsie "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               //@prow()  , nMidc say "1 DokNr.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "  LidNr.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "  RasNr.......: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Voorvoegsel.: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1,  1 say "            |G|                    |        |Kleu|            |            |D|        |  |Ge|  |G|T|N|V|Moe|    |Kalf-   "
               @prow()+1,  1 say "            |e|                    |Geboorte|van |Vaar        |Moer        |e|Insem   |Ka|va|Ge|s|w|v|v|mas|Iden|boek    "
               @prow()+1,  1 say "Id nommer   |s|Naam van dier       |datum   |dier|Id nommer   |Id nommer   |k|date    |st|ka|ma|t|m|r|r|geb|met |nommer  "
               @prow()+1,  1 say "------------|-|--------------------|--------|----|------------|------------|-|--------|--|--|--|-|-|-|-|---|----|--------"
               //                 1           1315                   36       45   50           63           7678       87 90 93 9698 0 2104 108  113
               @prow()+1,  1 say repl( "=", nWidt )
            else
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION (Option "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               //@prow()  , nMidc say "1 DocNo.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "  MemNo.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "  BreedNo.....: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Prefix......: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1,  1 say "            |S|                    |        |Colo|            |            |M|        |  |Ea|  |B|T|N|M|Dam|    |Calf    "
               @prow()+1,  1 say "            |e|                    |Date of |of  |Sire        |Dam         |a|Insem   |Ca|of|Bi|s|w|f|s|mas|Iden|book    "
               @prow()+1,  1 say "Id number   |x|Name of animal      |birth   |anim|Id number   |Id number   |t|date    |st|ca|ma|t|w|r|i|bir|met |number  "
               @prow()+1,  1 say "------------|-|--------------------|--------|----|------------|------------|-|--------|--|--|--|-|-|-|-|---|----|--------"
               //                 1           1315                   36       45   50           63           7678       87 90 93 9698 0 2104 108  113
               @prow()+1,  1 say repl( "=", nWidt )
            endif

         endif

         //Data

         // Get the sire and dam registration numbers
         cSreg := fVaarData("reknr")
         cDreg := fMoerData("reknr")

         // Convert main id number
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idnr)
         else
            cData := fid(SM3DATA->idnr,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         @prow()+1,  1 say cData

         // Sex
         @prow()  , 13 say "|" + SM3DATA->geslag

         // Name of animal
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow()  , 15 say "|" + left(cData,20)

         // Other data
         @prow()  , 36 say "|" + dtoc(SM3DATA->gebdatum)
         @prow()  , 45 say "|" + SM3DATA->tipies

         // Sire
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idvaar)
         else
            cData := fid(SM3DATA->idvaar,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         @prow()  , 50 say "|" + cData

         // Dam
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idmoer)
         else
            cData := fid(SM3DATA->idmoer,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         @prow()  , 63 say "|" + cData

         // Other data
         @prow()  , 76 say "|" + SM3DATA->vaarkode
         @prow()  , 78 say "|" + dtoc(SM3DATA->idatum)
         @prow()  , 87 say "|" + SM3DATA->kalfstat
         @prow()  , 90 say "|" + SM3DATA->kalfgem
         @prow()  , 93 say "|" + str(SM3DATA->gebmassa,2,0)
         @prow()  , 96 say "|" + SM3DATA->gebstat
         @prow()  , 98 say "|" + SM3DATA->tweeling
         @prow()  ,100 say "|" + SM3DATA->niereg

         // Multiple Sire
         if "VVAAR" $ upper(SM3DATA->idvaar) .or. "MSIRE" $ upper(SM3DATA->idvaar)
            @prow()  ,102 say "|1"
         else
            @prow()  ,102 say "| "
         endif

         // Other data
         @prow()  ,104 say "|" + str(SM3DATA->mamoergeb,3,0)
         @prow()  ,108 say "|" + SM3DATA->ident
         @prow()  ,113 say "|" + SM3DATA->kalfbnr

         if !empty(cSreg) .or. !empty(cDreg)
            @prow()+1, 13 say "|"
            @prow()  , 15 say "|"
            @prow()  , 36 say "|"
            @prow()  , 45 say "|"
            @prow()  , 50 say "|" + cSreg
            @prow()  , 63 say "|" + cDreg
            @prow()  , 76 say "|"
            @prow()  , 78 say "|"
            @prow()  , 87 say "|"
            @prow()  , 90 say "|"
            @prow()  , 93 say "|"
            @prow()  , 96 say "|"
            @prow()  , 98 say "|"
            @prow()  ,100 say "|"
            @prow()  ,102 say "|"
            @prow()  ,104 say "|"
            @prow()  ,108 say "|"
            @prow()  ,113 say "|"
         endif

         @prow()+1,  1 say repl( "-", nWidt )

         //Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         //Verwyder gedrukte dier
         if lDelete
            delete
         endif

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
               @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
               @prow()+1,  1 say 'Stamboekvereniging en ' + cOpsk
               @prow()+1, 80 say 'Handtekening...: ________________________________'
               @prow()+1,  1 say cAppName()
            else
               @prow()+1,  1 say 'I declare that I have bred the animals described here and that the breeding'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'details, pedigree and identification  marks are  correct  and  I  agree  to'
               @prow()+1,  1 say 'honour and submit myself to the regulations of the Stud Book Association'
               @prow()+1,  1 say 'and '+ cOpsk
               @prow()+1, 80 say 'Signature......: ________________________________'
               @prow()+1,  1 say cAppName()
            endif

            fPrnEjec()

            //fPrnOff()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fPNami(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nBlad   := 1
   local nWidt   := 0
   local nWidN   := 0
   local nMidc   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local cCond   := ""
   local cNorm   := ""
   local cSreg   := ""
   local cDreg   := ""

   begin sequence

      //Toets of drukker gereed is
      fScrBood(23)
      if fPrnReady() == K_ESC
         break
      endif

      //Waardes
      lDelete := if(lDelete==NIL,FALSE,lDelete)
      cNorm := cPrnNorm()
      nWidN := nPrnWidt()
      cCond := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl() - 8
      nMidc := nWidN - 27

      //Databasis
      select SM3TYDI
      go top
      nTotaal := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
      endif

      // Printer on
      fPrnOn()

      //Doen die loop
      lLoop := TRUE
      do while lLoop

         //Opskrifte
         if prow() = 0

            if cLanType() == "A"
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "GEBOORTEKENNISGEWING (Opsie "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Bladsy......: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               //@prow()  , nMidc say "1 DokNr.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "  LidNr.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "  RasNr.......: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Voorvoegsel.: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1,  1 say "                    |        |G|G|T|N|D|G |            |            |V|H |            |Moe|        |Wa|Op|  |Kleu|  |    |Kalf-   "
               @prow()+1,  1 say "                    |Geboorte|e|s|w|v|e|e |            |            |v|k |            |mas|Insem   |by|by|Ge|van |Su|Iden|boek    "
               @prow()+1,  1 say "Naam van dier       |datum   |s|t|e|r|k|n |Id nommer   |Id vaar     |a|a |Id moer     |geb|datum   |ge|ge|ma|dier|af|met |nommer  "
               @prow()+1,  1 say "--------------------|--------|-|-|-|-|-|--|------------|------------|-|--|------------|---|--------|--|--|--|----|--|----|--------"
               //                 1                   21       303234363840 43           45           6971 74           87  91       100103106109  114117  122
               @prow()+1,  1 say repl( "=", nWidt )
            else
               fPrnCod( cNorm )
               @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
               cData := "BIRTH NOTIFICATION (Option "+cOption()+")"
               @prow()+1,(nWidN - LEN(cData)) / 2 say cData
               @prow()+2,  1 say cGebNaam()
               @prow()  , nMidc say "  Page........: " + alltrim(str(nBlad,3))
               @prow()+1,  1 say substr(cTotNaam(),1,40)
               //@prow()  , nMidc say "1 DocNo.......: 2321"
               @prow()+1,  1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "  MemNo.......: " + substr(cTotNaam(),152,10)
               @prow()+1,  1 say trim(substr(cTotNaam(),81,40))
               @prow()  , nMidc say "  BreedNo.....: " + substr(cTotNaam(),149,3)
               @prow()+1,  1 say substr(cTotNaam(),121,4)
               @prow()  , nMidc say "  Prefix......: " + trim(substr(cTotNaam(),129,20))
               fPrnCod( cCond )
               @prow()+1,  1 say repl( "=", nWidt )
               @prow()+1,  1 say "                    |        |S|B|T|N|M|G |            |            |M|U |            |Dam|        |  |  |  |Colo|  |    |Calf    "
               @prow()+1,  1 say "                    |Date of |e|s|w|f|a|e |            |Sire        |s|c |Dam         |mas|Insem   |Ca|Bi|Bi|of  |Su|Iden|book    "
               @prow()+1,  1 say "Name of animal      |birth   |x|t|i|r|t|n |Id number   |Id number   |i|a |Id number   |bir|date    |st|re|ma|anim|di|metd|number  "
               @prow()+1,  1 say "--------------------|--------|-|-|-|-|-|--|------------|------------|-|--|------------|---|--------|--|--|--|----|--|----|--------"
               //                 1                   21       303234363840 43           45           6971 74           87  91       100103106109  114117  122
               @prow()+1,  1 say repl( "=", nWidt )
            endif

         endif

         //Data

         // Get the sire and dam registration numbers
         cSreg := fVaarData("reknr")
         cDreg := fMoerData("reknr")

         // Name of animal
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow()+1,  1 say left(cData,20)

         // Other data
         @prow()  , 21 say "|" + dtoc(SM3DATA->gebdatum)
         @prow()  , 30 say "|" + SM3DATA->geslag
         @prow()  , 32 say "|" + SM3DATA->gebstat
         @prow()  , 34 say "|" + SM3DATA->tweeling
         @prow()  , 36 say "|" + SM3DATA->niereg
         @prow()  , 38 say "|" + SM3DATA->vaarkode
         @prow()  , 40 say "|" + SM3DATA->generasie

         // Convert main id number
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idnr)
         else
            cData := fid(SM3DATA->idnr,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         @prow()  , 43 say "|" + cData

         // Sire
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idvaar)
         else
            cData := fid(SM3DATA->idvaar,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         @prow()  , 56 say "|" + cData

         // Multiple Sire
         if "VVAAR" $ upper(SM3DATA->idvaar) .or. "MSIRE" $ upper(SM3DATA->idvaar)
            @prow()  , 69 say "|1"
         else
            @prow()  , 69 say "| "
         endif

         // Other data
         @prow()  , 71 say "|"

         // Dam
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idmoer)
         else
            cData := fid(SM3DATA->idmoer,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         @prow()  , 74 say "|" + cData

         // Other data
         @prow()  , 87 say "|" + str(SM3DATA->mamoergeb,3,0)
         @prow()  , 91 say "|" + dtoc(SM3DATA->idatum)
         @prow()  ,100 say "|" + SM3DATA->kalfstat
         @prow()  ,103 say "|" + SM3DATA->kalfgem
         @prow()  ,106 say "|" + str(SM3DATA->gebmassa,2,0)
         @prow()  ,109 say "|" + SM3DATA->tipies
         @prow()  ,114 say "|" + SM3DATA->subafd
         @prow()  ,117 say "|" + SM3DATA->ident
         @prow()  ,122 say "|" + SM3DATA->kalfbnr

         if !empty(cSreg) .or. !empty(cDreg)
            @prow()+1, 21 say "|"
            @prow()  , 30 say "|"
            @prow()  , 32 say "|"
            @prow()  , 34 say "|"
            @prow()  , 36 say "|"
            @prow()  , 38 say "|"
            @prow()  , 40 say "|"
            @prow()  , 43 say "|"
            @prow()  , 56 say "|" + cSreg
            @prow()  , 69 say "|"
            @prow()  , 71 say "|"
            @prow()  , 74 say "|" + cDreg
            @prow()  , 87 say "|"
            @prow()  , 91 say "|"
            @prow()  ,100 say "|"
            @prow()  ,103 say "|"
            @prow()  ,106 say "|"
            @prow()  ,109 say "|"
            @prow()  ,114 say "|"
            @prow()  ,117 say "|"
            @prow()  ,122 say "|"
         endif

         @prow()+1,  1 say repl( "-", nWidt )

         //Verwyder pasgebore merk indien enige
         if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         //Verwyder gedrukte dier
         if lDelete
            delete
         endif

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            if cLanType() == "A"
               @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
               @prow()  , 80 say 'Datum geteken..: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
               @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
               @prow()+1,  1 say 'Stamboekvereniging en ' + cOpsk
               @prow()+1, 80 say 'Handtekening...: ________________________________'
               @prow()+1,  1 say cAppName()
            else
               @prow()+1,  1 say 'I declare that I have bred the animals described here and that the breeding'
               @prow()  , 80 say 'Date signed....: ' + dtoc(dAppDate())
               @prow()+1,  1 say 'details, pedigree and identification  marks are  correct  and  I  agree  to'
               @prow()+1,  1 say 'honour and submit myself to the regulations of the Stud Book Association'
               @prow()+1,  1 say 'and '+ cOpsk
               @prow()+1, 80 say 'Signature......: ________________________________'
               @prow()+1,  1 say cAppName()
            endif

            fPrnEjec()

            //fPrnOff()
            nBlad++

            //Kyk of drukker moet stop
            if inkey() == K_ESC
               lRetu := FALSE
               go bottom
               skip
            endif

            //Indien eof()
            if eof()
               lLoop := FALSE
            endif

         endif

      enddo

   end

   // Printer off
   fPrnOff()

   //Herstel
   select SM3TYDI
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fPande(lDelete,cOpsk)

   //Verklaar
   local nTotaal := 1
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cData   := ""
   local lRetu   := TRUE
   local nTopl   := 0
   local nWidN   := 0
   local cNorm   := ""

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return lRetu
   endif

   //Waardes
   lDelete := if(lDelete==NIL,FALSE,lDelete)
   cNorm := cPrnNorm()
   nWidN := nPrnWidt()
   nTopl := nPrnLine()

   //Databasis
   select SM3TYDI
   go top
   nTotaal := lastrec()

   //Skerm
   if cLanType() == "A"
      fScrbood(MAXROW(),"Geboortekennisgewings word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(MAXROW(),"Birth notifications being printed!  [Esc]=Stop printer." )
   endif

   //Doen die loop
   lLoop := TRUE
   do while lLoop

      //Skakel die drukker aan
      fPrnOn()
      fPrnCod( cNorm )

      if cLanType() == "A"

         @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
         @prow()+1, 30 say "GEBOORTEKENNISGEWING"
         @prow()+1,  1 say repl("=",79)
         @prow()+1,  1 say "    Geboortekennisgewingnommer        "+SM3DATA->kalfbnr

         @prow()+2,  1 say "                Dokumentnommer    1.  "+"2321"
         @prow()+1,  1 say "                     Lidnommer    2.  "+substr(cTotNaam(),152,10)
         @prow()+1,  1 say "                       Raskode    4.  "+substr(cTotNaam(),149, 3)

         //Naam en voorvoegsel
         @prow()+2,  1 say "                   Voorvoegsel    5.  "+substr(cTotNaam(),129,20)
         //Kry die naam van dier sonder voorvoegsel
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow()+1,  1 say "                 Naam van dier    6.  "+cData

         //Ander inligting
         @prow()+2,  1 say "        Geboortedatum (JJMMDD)    7.  "+right(dtos(SM3DATA->gebdatum),6)
         @prow()+1,  1 say "                        Geslag    8.  "+SM3DATA->geslag
         @prow()+1,  1 say "                Geboortestatus    9.  "+SM3DATA->gebstat
         @prow()+1,  1 say "                  Tweeling met   10.  "+SM3DATA->tweeling
         if SM3DATA->vaarkode == "4"
            @prow()+1,  1 say "          Bloedtiperingsnommer   11.  "+SM3DATA->bloednr
         endif
         @prow()+1,  1 say "           Nie vir registrasie   12.  "+SM3DATA->niereg
         if "VVAAR" $ SM3DATA->idvaar .or. "MSIRE" $ SM3DATA->idvaar
            @prow()+1,  1 say "              Veelvuldige vaar   13.  "+"1"
         endif
         @prow()+1,  1 say "                   Verwek deur   14.  "+SM3DATA->vaarkode
         @prow()+1,  1 say "           Identifikasiemetode   15.  "+SM3DATA->ident

         //Kalf self
         cData := fid(SM3DATA->idnr,.t.)
         @prow()+2,  1 say "           Kuddekenmerkletters   16.  " + substr(cTotNaam(),125,4) //left(cData,4)
         @prow()+1,  1 say "             Jaar van geboorte   17.  " + substr(cData,5,2)
         @prow()+1,  1 say "                    Volgnommer   18.  " + right(cData,4)
         if SM3DATA->vaarkode == "4"
            @prow()+1,  1 say "                Rekenaarnommer   19.  "+SM3DATA->reknr
         endif

         //Vaar
         @prow()+2,  1 say "                 Naam van vaar   20.  " + trim(fVaarData("idnaam"))
         @prow()+1,  1 say "       Rekenaarnommer van vaar   21.  " + trim(fVaarData("reknr"))
         if substr(cTotNaam(),149,3) == "210"
            //Simmentaler
            cData := fid(SM3DATA->idvaar,.t.)
            @prow()+1,  1 say "        Identifikasie van vaar   22.  " + trim(left(cData,4)) + ;
               trim(substr(cData,5,2)) + ;
               trim(right(cData,4))

         else
            @prow()+1,  1 say "        Identifikasie van vaar   22.  " + SM3DATA->idvaar
         endif
         @prow()+1,  1 say "  Bloedtiperingsnommer van vaar       " + trim(fVaarData("bloednr"))

         //Moer
         @prow()+2,  1 say "               Naam van moeder   24.  " + trim(fMoerData("idnaam"))
         @prow()+1,  1 say "     Rekenaarnommer van moeder   25.  " + trim(fMoerData("reknr"))
         if substr(cTotNaam(),149,3) == "210"
            //Simmentaler
            cData := fid(SM3DATA->idmoer,.t.)
            @prow()+1,  1 say "        Identifikasie van moer   26.  " + trim(left(cData,4)) + ;
               trim(substr(cData,5,2)) + ;
               trim(right(cData,4))

         else
            @prow()+1,  1 say "        Identifikasie van moer   26.  " + SM3DATA->idmoer
         endif
         @prow()+1,  1 say "     Inseminasiedatum (JJMMDD)   27.  " + right(dtos(SM3DATA->idatum),6)
         @prow()+1,  1 say "            Moeder kere gekalf        "
         @prow()  , 39 say                                          fMoerData("kalfaantal","N")
         @prow()+1,  1 say "       Hulpstamboek van moeder        " + trim(fMoerData("generasie"))

         //Ander inligting
         @prow()+2,  1 say "        Kalfstatus by geboorte  28a.  " + SM3DATA->kalfstat
         @prow()+1,  1 say "             Gemak van kalwing  28b.  " + SM3DATA->kalfgem
         @prow()+1,  1 say "     Subafdeling van kuddeboek 28.5.  " + SM3DATA->subafd
         @prow()+1,  1 say "                 Geboortemassa 28.6.  " + ltrim(str(SM3DATA->gebmassa,2,0))
         @prow()+1,  1 say "                         Kleur 28.8.  " + SM3DATA->tipies
         @prow()+1,  1 say "       Moedermassa by geboorte        " + ltrim(str(SM3DATA->mamoergeb,3,0))
         @prow()+1,  1 say repl("=",79)

         //Verklaring
         @prow()+1,  1 say 'Ek verklaar dat ek elke dier wat hierin beskryf is geteel het en dat die'
         @prow()+1,  1 say 'teelbesonderhede,  stamboom en identifikasiemerke korrek is en  ek  stem'
         @prow()+1,  1 say 'toe  om  my  te   hou  en  te  onderwerp  aan  die  regulasies  van  die'
         @prow()+1,  1 say 'Stamboekvereniging en '+cOpsk

         //Naam en adres
         @prow()+2,  1 say "Naam en adres 29. " + cGebNaam()
         @prow()+1,  1 say " van teler        " + substr(cTotNaam(),  1,40)
         @prow()+1,  1 say "                  " + substr(cTotNaam(), 41,40)
         @prow()+1,  1 say "                  " + substr(cTotNaam(), 81,40)
         @prow()+1,  1 say "                  " + substr(cTotNaam(),121, 4)

         //Handtekeninge
         @prow()+2,  1 say "Datum geteken 30. " + right(dtos(dAppDate()),6)
         @prow()  , 30 say "        Handtekening 31. _________________________"
         @prow()+2,  1 say "Datum ontvang 33. " + "____ / ____ / ____" + space(18) + cAppName()

      else

         @prow()+nTopl,(nWidN - LEN(cOpsk)) / 2 say upper(cOpsk)
         @prow()+1, 30 say "BIRTH NOTIFICATION"
         @prow()+1,  1 say repl("=",79)
         @prow()+1,  1 say "     Birth Notification number        "+SM3DATA->kalfbnr

         @prow()+2,  1 say "               Document number    1.  "+"2321"
         @prow()+1,  1 say "                 Member number    2.  "+substr(cTotNaam(),152,10)
         @prow()+1,  1 say "                    Breed code    4.  "+substr(cTotNaam(),149, 3)

         //Naam en voorvoegsel
         @prow()+2,  1 say "                        Prefix    5.  "+substr(cTotNaam(),129,20)
         //Kry die naam van dier sonder voorvoegsel
         cData := SM3DATA->idnaam
         cData := strtran(cData,alltrim(substr(cTotNaam(),129,20)))
         @prow()+1,  1 say "                Name of animal    6.  "+cData

         //Ander inligting
         @prow()+2,  1 say "        Date of birth (YYMMDD)    7.  "+right(dtos(SM3DATA->gebdatum),6)
         @prow()+1,  1 say "                           Sex    8.  "+SM3DATA->geslag
         @prow()+1,  1 say "                  Birth status    9.  "+SM3DATA->gebstat
         @prow()+1,  1 say "                     Twin with   10.  "+SM3DATA->tweeling
         if SM3DATA->vaarkode == "4"
            @prow()+1,  1 say "            Bloodtyping number   11.  "+SM3DATA->bloednr
         endif
         @prow()+1,  1 say "          Not for registration   12.  "+SM3DATA->niereg
         if "VVAAR" $ SM3DATA->idvaar .or. "MSIRE" $ SM3DATA->idvaar
            @prow()+1,  1 say "                 Multiple sire   13.  "+"1"
         endif
         @prow()+1,  1 say "                   Begotten by   14.  "+SM3DATA->vaarkode
         @prow()+1,  1 say "         Identification method   15.  "+SM3DATA->ident

         //Kalf self
         cData := fid(SM3DATA->idnr,.t.)
         @prow()+2,  1 say "      Herd Designation letters   16.  " + substr(cTotNaam(),125,4) //left(cData,4)
         @prow()+1,  1 say "                 Year of birth   17.  " + substr(cData,5,2)
         @prow()+1,  1 say "               Sequence number   18.  " + right(cData,4)
         if SM3DATA->vaarkode == "4"
            @prow()+1,  1 say "               Computer number   19.  "+SM3DATA->reknr
         endif

         //Vaar
         @prow()+2,  1 say "                  Name of sire   20.  " + trim(fVaarData("idnaam"))
         @prow()+1,  1 say "       Computer number of sire   21.  " + trim(fVaarData("reknr"))
         if substr(cTotNaam(),149,3) == "210"
            //Simmentaler
            cData := fid(SM3DATA->idvaar,.t.)
            @prow()+1,  1 say "        Identification of sire   22.  " + trim(left(cData,4)) + ;
               trim(substr(cData,5,2)) + ;
               trim(right(cData,4))

         else
            @prow()+1,  1 say "        Identification of sire   22.  " + SM3DATA->idvaar
         endif
         @prow()+1,  1 say "    Bloodtyping number of sire        " + trim(fVaarData("bloednr"))

         //Moer
         @prow()+2,  1 say "                   Name of dam   24.  " + trim(fMoerData("idnaam"))
         @prow()+1,  1 say "        Computer number of dam   25.  " + trim(fMoerData("reknr"))
         if substr(cTotNaam(),149,3) == "210"
            //Simmentaler
            cData := fid(SM3DATA->idmoer,.t.)
            @prow()+1,  1 say "         Identification of dam   26.  " + trim(left(cData,4)) + ;
               trim(substr(cData,5,2)) + ;
               trim(right(cData,4))

         else
            @prow()+1,  1 say "         Identification of dam   26.  " + SM3DATA->idmoer
         endif
         @prow()+1,  1 say "    Insemination date (YYMMDD)   27.  " + right(dtos(SM3DATA->idatum),6)
         @prow()+1,  1 say "              Times dam calved        "
         @prow()  , 39 say                                          fMoerData("kalfaantal","N")
         @prow()+1,  1 say "               Appendix of dam        " + trim(fMoerData("generasie"))

         //Ander inligting
         @prow()+2,  1 say "          Calf status at birth  28a.  " + SM3DATA->kalfstat
         @prow()+1,  1 say "               Ease of calving  28b.  " + SM3DATA->kalfgem
         @prow()+1,  1 say "     Sub-division of herd book 28.5.  " + SM3DATA->subafd
         @prow()+1,  1 say "                    Birth mass 28.6.  " + ltrim(str(SM3DATA->gebmassa,2,0))
         @prow()+1,  1 say "                        Colour 28.8.  " + SM3DATA->tipies
         @prow()+1,  1 say "             Dam mass at birth        " + ltrim(str(SM3DATA->mamoergeb,3,0))
         @prow()+1,  1 say repl("=",79)

         //Verklaring
         @prow()+1,  1 say 'I declare that I have bred the animal described here and that the'
         @prow()+1,  1 say 'breeding details, pedigree and identification marks are correct and I'
         @prow()+1,  1 say 'agree to honour and submit myself to the regulations of the Stud'
         @prow()+1,  1 say 'Book Association and '+cOpsk

         //Naam en adres
         @prow()+2,  1 say "Name and ad-  29. " + cGebNaam()
         @prow()+1,  1 say "dress of breeder  " + substr(cTotNaam(),  1,40)
         @prow()+1,  1 say "                  " + substr(cTotNaam(), 41,40)
         @prow()+1,  1 say "                  " + substr(cTotNaam(), 81,40)
         @prow()+1,  1 say "                  " + substr(cTotNaam(),121, 4)

         //Handtekeninge
         @prow()+2,  1 say "Date signed   30. " + right(dtos(dAppDate()),6)
         @prow()  , 30 say "           Signature 31. _________________________"
         @prow()+2,  1 say "Date received 33. " + "____ / ____ / ____" + space(18) + cAppName()

      endif

      fPrnEjec()
      fPrnOff()

      //Verwyder pasgebore merk indien enige
      if lDelete .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
         select SM3DATA
         do while !rlock()
         enddo
         SM3DATA->toggle2 := " "
         select SM3TYDI
      endif

      //Verwyder gedrukte dier
      if lDelete
         delete
      endif

      //Skerm
      if nTotaal > 0
         setcolor( cColBott() )
         if cLanType() == "A"
            @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Voltooi"
         else
            @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Completed"
         endif
         setcolor( cColNorm() )
         nRekord++
      endif

      //Toets of drukker moet stop
      if inkey() == K_ESC
         go bottom
         lRetu := FALSE
      endif

      //Volgende rekord
      skip

      //Indien eof()
      if eof()
         lLoop := FALSE
      endif

   enddo

   //Herstel
   go top

return lRetu

/***************************************************************************/
STATIC FUNCTION fIdnr(cKeyp,bBrow,aRecv)

   //Funksie om id nommer te vra

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local nBoxc := 0
   local cData := space(12)
   local oCols := NIL

   //Waardes
   if cKeyp == NIL
      cKeyp := space(12)
   else
      ckeyp := padr(cKeyp,12)
      keyboard chr(K_RIGHT)
   endif

   //Kry die huidige nageslag se dier
   cData := SM3DATA->idnr

   //Ander databasis
   select SM3DATA
   seek cData
   if eof()
      go top
   endif

   //Vra die nommer
   nBoxc := fBoxCent( 12, space(33), 1 )
   cData := sm3idnr(cKeyp,12,nBoxc)
   do case
      case left(cData,9) == "CANCELLED"
         select SM3TYDI
         set relation to SM3TYDI->IDNR into SM3DATA
      case left(cData, 3 ) == "NOT"
         select SM3TYDI
         set relation to SM3TYDI->IDNR into SM3DATA
      otherwise
         select SM3TYDI
         append blank
         SM3TYDI->idnr := cData
         set relation to SM3TYDI->IDNR into SM3DATA
   endcase
   restscreen(0,0,24,79,cCscr)
return TRUE

/******************************************************************************/
STATIC FUNCTION fDiskIris(lDele)

   // Program to create electronic births for Iris
   // 02-02-07 09:55

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nHdel := 0
   local cStr  := ""
   local cData := ""
   local i     := 0
   local nLen  := 0
   local cIcar := ""
   local nBoxc := 0
   local nMfil := 0
   local nSeqn := 1
   local cSeqn := ""

   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      nSeqn := STDWAAR->elecsq
      if nSeqn = 0
         nSeqn := 1
      else
         nSeqn := STDWAAR->elecsq + 1
         if nSeqn > 999
            nSeqn := 1
         endif
      endif
      do while !rlock()
      enddo
      STDWAAR->elecsq := nSeqn
      cSeqn := right("00"+alltrim(str(nSeqn)),3)


      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"B"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"B"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Geboorteslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Births file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Geboorteslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create births file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Geboorteslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create births file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Start writing the data to the file

      // Write the data
      select SM3TYDI
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Header
         cStr := "B"                             //1
         cStr += substr(alltrim(cIcar),1,3)      // Breed code
         cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cStr += "S"
         cStr += cSeqn
         cStr += padr("SM"+alltrim(cVersion()),10) // Version number
         cStr += "ANIM"                          // Document code
         cStr += "C"                             // Action type

         // Header replaced on 14-02-11 09:15
         // Header
         //cStr := padl(dtos(date())+substr(time(),1,2)+substr(time(),4,2),15,"0") //Batch number
         //cStr += padr("SM"+cVersion(),10)        // Employee
         //cStr += "ANIM"                          // Document code
         //cStr += "C"                             // Action type
         cStr += "B"                             // Document type
         cStr += "B"                             // Purpose

         // Not for registration
         if empty(SM3DATA->niereg)
            cStr += "N"
         else
            cStr += "Y"
         endif

         // Participant code (memberno'7'+icarbreedcode'3')
         cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cStr += alltrim(cIcar)                  // Breed code

         // Sex
         if SM3DATA->geslag $ "1FVKHC"
            cStr += "F"
         else
            cStr += "M"
         endif

         // Registered/Commercial
         If substr(cTotNaam(),149,3) == "229"    //Santa Gertrudis
            cStr += "Q"
         else
            cStr += "R"
         endif

         // Icar animal breed code
         cStr += alltrim(cIcar)                  // Breed code

         // Id number
         cStr += alltrim(cIcar)                  // Breed code
         if SM3DATA->geslag $ "1FVKHC"
            cStr += "F"
         else
            cStr += "M"
         endif
         cStr += fid(SM3DATA->idnr,.t.)
         cStr += space(1)

         // Main Id method
         // Remove any didigts from identification
         cData := ""
         for i := 1 to len(SM3DATA->ident)
            if isdigit(substr(SM3DATA->ident,i,1))
               cData += substr(SM3DATA->ident,i,1)
            endif
         next
         if len(cData) > 0
            if val(substr(cData,1,1)) >= 1 .and. val(substr(cData,1,1)) <= 8
               cStr += alltrim(substr(cData,1,1))
            else
               cStr += "1"
            endif
         else
            cStr += "1"
         endif
         // Keep cData for sub id method

         // Name of animal
         if empty(SM3DATA->idnaam)
            cStr += space(20)                    //padr(alltrim(SM3DATA->idnr),20)
         else
            cStr += padr(alltrim(strtran(SM3DATA->idnaam,alltrim(substr(cTotNaam(),129,20)))),20)
         endif

         // Sub Id method
         // Remove any didigts from identification
         cData := ""
         for i := 1 to len(SM3DATA->ident)
            if isdigit(substr(SM3DATA->ident,i,1))
               cData += substr(SM3DATA->ident,i,1)
            endif
         next
         if len(cData) > 1
            if val(substr(cData,2,1)) >= 1 .and. val(substr(cData,2,1)) <= 8
               cStr += alltrim(substr(cData,2,1))
            else
               cStr += space(1)
            endif
         else
            cStr += space(1)
         endif

         // Farm animal number
         cStr += space(10)

         // Service
         if SM3DATA->vaarkode $ "4"
            cStr += "3"
         elseif SM3DATA->vaarkode $ "3"
            cStr += "2"
         else
            cStr += "1"
         endif

         // Birth date
         cData := dtos(SM3DATA->gebdatum)
         cStr += right(cData,2)
         cStr += substr(cData,5,2)
         cStr += left(cData,4)

         // Birth weight
         if SM3DATA->gebmassa > 0
            cStr += padl(ltrim(str(SM3DATA->gebmassa)),3)
         else
            cStr += space(3)
         endif

         // Birth weigh date
         cStr += space(8)

         // Birth weight reliable
         if SM3DATA->gebmassa > 0
            cStr += "Y"
         else
            cStr += space(1)
         endif

         // Beef test number
         cStr += SM3DATA->indekskode
         // cStr += space(6) Replaced 4.4b(25) 18-08-02 05:41

         // Dam weight at calving
         if SM3DATA->mamoergeb > 0
            cStr += padl(ltrim(str(SM3DATA->mamoergeb)),3)
         else
            cStr += space(3)
         endif

         // Dam weight weighing date
         cStr += space(8)

         // Dam weight reliable
         if SM3DATA->mamoergeb > 0
            cStr += "Y"
         else
            cStr += space(1)
         endif

         // Birth status
         if val(SM3DATA->gebstat) > 0
            cStr += left(SM3DATA->gebstat,1)
         else
            cStr += "1"
         endif

         // Twin sex
         if val(SM3DATA->gebstat) >= 2
            if SM3DATA->tweeling $ "1FVKHC"
               cStr += "F"
            else
               cStr += "M"
            endif
         else
            cStr += space(1)
         endif

         // Cow feeding status
         cStr += space(1)

         // Takeon animal status
         cStr += space(1)

         // Pregnancy status date
         cStr += space(8)

         // Birth abnormalities
         cStr += space(3)
         cStr += space(3)
         cStr += space(3)

         // Calf status
         if val(SM3DATA->kalfstat) > 0
            cStr += padl(ltrim(str(val(SM3DATA->kalfstat))),1)
         else
            cStr += "1"
         endif

         // Ease of calving
         if val(SM3DATA->kalfgem) == 4
            cStr += "4"
         elseif val(SM3DATA->kalfgem) == 5
            cStr += "5"
         elseif val(SM3DATA->kalfgem) == 9
            cStr += "1"
         elseif val(SM3DATA->kalfgem) == 10
            cStr += "2"
         elseif val(SM3DATA->kalfgem) == 11
            cStr += "3"
         elseif val(SM3DATA->kalfgem) == 12
            cStr += "4"
         else
            cStr += space(1)
         endif

         // Section
         cStr += space(2)

         // Subsection
         if val(SM3DATA->subafd) > 0
            cStr += padr(SM3DATA->subafd,2)
         else
            cStr += space(2)
         endif

         // Horn poll
         cStr += space(2)

         // Inspection weight
         cStr += space(4)

         // Inspector participant code
         cStr += space(10)

         // Inspection date
         cStr += space(8)

         // Colour
         if val(SM3DATA->tipies) > 0
            cStr += padl(alltrim(SM3DATA->tipies),2,"0")
         else
            cStr += "01"
         endif

         // Dam computer number
         cStr += padl(alltrim(fMoerData("reknr")),10,"0") // Computer number

         // Sire computer number
         // Multiple sires
         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
            cStr += space(10)                    // Multi sire indicator
         else
            cStr += padl(alltrim(fVaarData("reknr")),10,"0") // Computer number
         endif

         // Dam Id number
         cStr += alltrim(cIcar)                  // Breed code
         cStr += "F"
         cStr += fId(fMoerData("idnr"),.t.)
         cStr += space(1)

         // Sire Id number
         // Multiple sires
         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
            cStr += space(15)                    // Multi sire indicator
         else
            cStr += alltrim(cIcar)               // Breed code
            cStr += "M"
            cStr += fId(fVaarData("idnr"),.t.)
            cStr += space(1)
         endif

         // Semen code
         cStr += space(7)

         // Date received
         cData := dtos(date())
         cStr += right(cData,2)
         cStr += substr(cData,5,2)
         cStr += left(cData,4)

         // Multiple sires
         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
            cStr += "Y"                          // Multi sire indicator
         else
            cStr += space(1)                     // Multi sire indicator
         endif

         // Lowest section
         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
            cStr += "SP"
         else
            cStr += space(2)
         endif

         // Accept sire minimum age
         cStr += space(1)

         // Accept dam minimum age
         cStr += space(1)

         // Accept dam maximim age
         cStr += space(1)

         // Accept dam minimum interbirth
         cStr += space(1)

         // Accept dam maximum interbirth
         cStr += space(1)

         // Accept inv gestation
         cStr += space(1)

         // Accept late birth
         cStr += space(1)

         // Search participant
         cStr += space(10)

         // Search farm animal number
         cStr += space(10)

         // Search animal computer number
         cStr += space(10)

         // Search animal id number
         cStr += space(15)

         cStr += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStr)

         if nLen != len(cStr)
            fScrWBood(maxrow(),"File Write Error : "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Verwyder pasgebore merk indien enige
         if lDele .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         // Next record
         select SM3TYDI
         skip

      enddo

      // Close the file
      fclose(nHdel)

      // Test if file was created
      if !file(cFile)

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geboorteslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Births file was not created!")
         endif

      else

         // Display note on the screen for removable medium
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam B"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Geboorteslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name B"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing births was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Geboorte epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Birth email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Geboortekennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Geboortekennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile + chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van geboortes vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Birth Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Birth Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic birth notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskBrep(lDele)

   // Program to create electronic births for Breedplan
   // 02-04-03 10:20

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nHdel := 0
   local cStra := ""
   local cStrb := ""
   local cData := ""
   local i     := 0
   local nLen  := 0
   local cIcar := ""
   local cBrec := ""
   local cDreg := ""
   local nBoxc := 0
   local cPref := ""
   local cName := ""
   local lSkip := .f.
   local nMfil := 0
   local cStr := ""

   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")
      cBrec := alltrim(fRasNaam(substr(cTotNaam(),149,3),"BREEDS"))

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Geboorteslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Births file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Geboorteslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create births file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Geboorteslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create births file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Start writing the data to the file

      // Write the data
      select SM3TYDI
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Record A

         // Always A
         cStra := "A"                            // Always A

         // Society code
         if !empty(cBrec)                        // Society code
            cStra += padr(cBrec,7)
         else
            cStra += space(7)
         endif

         // Herd of membership
         cStra += substr(cTotNaam(),152,7)       // Soc ident of herd

         // Calf tattoo
         cStra += padr(fId(SM3DATA->idnr,.f.),11)

         // Sex
         if SM3DATA->geslag $ "1FVKHC"
            cStra += "F"
         else
            cStra += "M"
         endif

         // Birth date
         cStra += dtos(SM3DATA->gebdatum)

         // Prefix and name
         if empty(alltrim(SM3DATA->idnaam))

            // Prefix and name is empty - blanks please

            // Prefix
            if empty(substr(cTotNaam(),129,20))
               cStra += space(20)
            else
               cStra +=  padr(substr(cTotNaam(),129,20),20)
            endif
            // Name
            cStra += space(20)

         else

            // Name not empty
            if at(alltrim(substr(cTotNaam(),129,20)),alltrim(SM3DATA->idnaam)) > 0

               // Prefix is in name

               // Prefix
               cStra +=  padr(substr(cTotNaam(),129,20),20)
               // Name
               cStra += padr(alltrim(strtran(SM3DATA->idnaam,alltrim(substr(cTotNaam(),129,20)))),20)

            else

               // Prefix not the same and not in name

               // Loop the name and build variables
               cPref := ""
               cName := ""
               lSkip := .f.
               for i := 1 to len(SM3DATA->idnaam)
                  cData := substr(SM3DATA->idnaam,i,1)
                  if cData == " "
                     lSkip := .t.
                  endif
                  if lSkip == .f.
                     // Prefix
                     cPref += cData
                  else
                     // Name
                     cName += cData
                  endif
               next
               cPref := alltrim(cPref)
               cName := alltrim(cName)

               // Prefix
               cStra +=  padr(cPref,20)

               // Name
               cStra +=  padr(cName,20)

            endif

         endif

         // Dam registration number
         if substr(cTotNaam(),149,3) == "298"
            // Breedplan special no id number conversion
            cDreg := fMoerData("REKNR")
            cStra += padr(ltrim(str(val(cDreg))),19) // Computer number
         else
            cDreg := fMoerData("IDSOC")
            if empty(cDreg)
               cStra += padr(fId(SM3DATA->idmoer,.f.),19) // Id number
            else
               cStra += padr(cDreg,19)           // Id number
            endif
         endif

         // Dam tattoo
         if substr(cTotNaam(),149,3) == "298"
            cStra += left(SM3DATA->idmoer,11)
         else
            cStra += padr(fId(SM3DATA->idmoer,.f.),11)
         endif

         // Sire registration number
         if substr(cTotNaam(),149,3) == "298"
            // Breedplan special no id number conversion
            cDreg := fVaarData("REKNR")
            cStra += padr(ltrim(str(val(cDreg))),19) // Computer number
         else
            cDreg := fVaarData("idsoc")
            if empty(cDreg)
               cStra += padr(fId(SM3DATA->idvaar,.f.),19)
            else
               cStra += padr(cDreg,19)
            endif
         endif

         // Sire tattoo
         if substr(cTotNaam(),149,3) == "298"
            cStra += left(SM3DATA->idvaar,11)
         else
            cStra += padr(fId(SM3DATA->idvaar,.f.),11)
         endif

         // Service code
         if SM3DATA->vaarkode $ "4"
            cStra += " "
         elseif SM3DATA->vaarkode $ "3"
            cStra += "A"
         else
            cStra += "N"
         endif

         // Final mating date
         cStra += space(8)

         // Correction - remate
         cStra += " "

         // Calf fate
         if alltrim(SM3DATA->kalfstat) $ "AzBzCzDzF"
            // As is
            cStra += alltrim(SM3DATA->kalfstat)
         elseif empty(SM3DATA->kalfstat)
            // Alive
            cStra += " "
         elseif alltrim(SM3DATA->kalfstat) $ "01"
            // Alive
            cStra += " "
         elseif alltrim(SM3DATA->kalfstat) $ "02z03"
            // Aborted
            cStra += "A"
         else
            // Died
            cStra += "D"
         endif

         // Number in birth
         if val(SM3DATA->gebstat) >= 2
            cStra += alltrim(SM3DATA->gebstat)
         else
            cStra += "1"
         endif

         // Register status
         if cBrec == "SBBS" .or. cBrec == "SIBS"
            if empty(SM3DATA->niereg)
               cStra += "Q "
            elseif SM3DATA->niereg == "C"
               cStra += "C "
            else
               cStra += "N "
            endif
         else
            if empty(SM3DATA->niereg)
               If substr(cTotNaam(),149,3) == "229" //Santa Gertrudis
                  cStra += "Q"
               else
                  cStra += "R"
               endif
               //cStra += "R "
            elseif SM3DATA->niereg == "C"
               cStra += "C "
            elseif SM3DATA->niereg == "Q"
               cStra += "Q "
            else
               cStra += "N "
            endif
         endif

         // Calving ease
         if alltrim(SM3DATA->kalfgem) $ "1z2z3z4z5"
            // As is
            cStra += alltrim(SM3DATA->kalfgem)
         elseif alltrim(SM3DATA->kalfgem) $ "09"
            // No difficulty
            cStra += "1"
         elseif alltrim(SM3DATA->kalfgem) $ "10"
            // Easy pull
            cStra += "2"
         elseif alltrim(SM3DATA->kalfgem) $ "11"
            // Hard pull
            cStra += "3"
         elseif alltrim(SM3DATA->kalfgem) $ "12"
            // Surgical
            cStra += "4"
         elseif alltrim(SM3DATA->kalfgem) $ "08"
            // Abnormal presentation
            cStra += "5"
         else
            // Unknown
            cStra += " "
         endif

         // Service code is embrio
         if SM3DATA->vaarkode $ "4"
            cStra += "Y"
         else
            cStra += "N"
         endif

         // Calf grade
         if cBrec == "SBBS" .or. cBrec == "SABF"
            // Simbra
            if empty(SM3DATA->generasie)
               // Pure
               cStra += "  "
            elseif alltrim(SM3DATA->generasie) == "SP"
               // Pure
               cStra += "  "
            elseif alltrim(SM3DATA->generasie) $ "AzF1"
               // A grade
               cStra += "1 "
            elseif alltrim(SM3DATA->generasie) $ "BzF2"
               // B grade
               cStra += "2 "
            elseif alltrim(SM3DATA->generasie) $ "CzF3"
               // C grade
               cStra += "3 "
            elseif alltrim(SM3DATA->generasie) $ "DzF4"
               // D grade
               cStra += "4 "
            elseif alltrim(SM3DATA->generasie) $ "C"
               // C grade
               cStra += "C "
            else
               cStra += "  "
            endif
         else
            if empty(SM3DATA->generasie)
               // Pure
               cStra += "  "
            elseif alltrim(SM3DATA->generasie) == "SP"
               // Pure
               cStra += "  "
            elseif alltrim(SM3DATA->generasie) $ "AzF1"
               // A grade
               cStra += "A "
            elseif alltrim(SM3DATA->generasie) $ "BzF2"
               // B grade
               cStra += "B "
            else
               cStra += "  "
            endif
         endif

         // Horn status
         cStra += " "                            // Unknown

         // Mating group
         cStra += " "

         // Brand code
         cStra += " "

         // Certificate required
         cStra += " "

         // Bought in calf
         cStra += " "

         // Calving year
         cStra += left(dtos(SM3DATA->gebdatum),4)

         // Breed
         cStra += space(8)

         // Breeder herd
         cStra += substr(cTotNaam(),152,7)       // Soc ident of herd

         // Colour type
         cStra += space(2)

         // Colour 1
         cStra += space(2)

         // Colour 2
         cStra += space(2)

         // Colour 3
         cStra += space(2)

         // Fullblood
         cStra += space(1)

         // Blood/DNA
         cStra += space(8)

         // Subdivision
         cStra += space(1)

         // Abnormal
         cStra += space(1)

         // Freemartin
         cStra += space(1)

         // Appraisal
         cStra += space(1)

         // Society tag number
         // cStra += space(19) 02-04-24 15:10 remove Paul Lubout
         if substr(cTotNaam(),149,3) == "298"
            // Breedplan special
            cStra += padr(ltrim(str(val(SM3DATA->reknr))),19) // Computer number
         else
            cStra += padr(fId(SM3DATA->idnr,.f.),19)
         endif

         // Overseas identity
         cStra += space(18)

         // Inspection date
         cStra += dtos(SM3DATA->keurda)

         // Twin sex
         if empty(SM3DATA->tweeling)
            cStra += " "
         elseif SM3DATA->tweeling $ "1FVKHC"
            cStra += "F"
         else
            cStra += "M"
         endif

         // Not used
         cStra += space(6)

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error (Record A): "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // ********************************************************************
         // Record B

         // Always B
         cStrb := "B"                            // Always B

         // Birth mass
         if SM3DATA->gebmassa > 0
            cStrb += padl(alltrim(str(SM3DATA->gebmassa)),4,"0")
         else
            cStrb += space(4)
         endif

         // Birth management group
         cStrb += space(1)

         // Left eye pigment
         cStrb += padr(left(SM3DATA->eyepig,1),3)

         // Right eye pigment
         cStrb += padr(right(SM3DATA->eyepig,1),3)

         // Trait 1 (After birth remark)
         // cStrb += "ABO" removed 2005-04-08 11:51 Paul Lubout
         cStrb += "ABO"

         // After birth remark (Left eye pigment)
         cStrb += padr(alltrim(SM3DATA->nagebo),6," ")

         // Trait 2 (Animal type)
         // cStrb += "ABO" removed 2005-04-08 11:51 Paul Lubout
         cStrb += space(3)

         // After birth remark (Left eye pigment)
         cStrb += space(6)

         // Recipient dam identity number
         cStrb += space(19)

         // Preparation date (Flush date)
         cStrb += space(8)

         // Implant date
         cStrb += space(8)

         // Foster dam
         cStrb += space(19)

         // Sire permit
         cStrb += space(1)

         // Dam permit
         cStrb += space(1)

         // AI certificate number
         cStrb += space(19)

         // ET certificate number
         cStrb += space(19)

         // First sire identity number
         cStrb += space(19)

         // First sire tattoo
         cStrb += space(11)

         // First service code
         cStrb += space(1)

         // First mating date
         cStrb += space(8)

         // Dam fate
         cStrb += space(1)

         // Dam fate date
         cStrb += space(8)

         // Recipient dam breed
         cStrb += space(8)

         // National certificate number
         cStrb += space(19)

         // Embryo ref
         cStrb += space(19)

         // Optional trait code 3
         cStrb += space(3)

         // Trait 3 value
         cStrb += space(6)

         // Optional trait code 4
         cStrb += space(3)

         // Trait 4 value
         cStrb += space(6)

         // Birth date accuracy
         cStrb += space(2)

         // Generic flag
         cStrb += space(1)

         // Not used
         cStrb += space(11)

         cStrb += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStrb)

         if nLen != len(cStrb)
            fScrWBood(maxrow(),"File Write Error (Record B): "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Verwyder pasgebore merk indien enige
         if lDele .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         // Next record
         select SM3TYDI
         skip

      enddo

      fclose(nHdel)

      // Test if file was created
      if !file(cFile)

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geboorteslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Births file was not created!")
         endif

      else

         // Display note on the screen
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Geboorteslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing births was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Geboorte epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Birth email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Geboortekennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Geboortekennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van geboortes vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Birth Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Birth Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic birth notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskZimb(lDele)

   // Program to create diskettes with birth notification data

   // Declare
   local lRetu := TRUE
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local nRout := 1
   local cNumb := ""
   local nMfil := 0
   local cStr := ""
   begin sequence

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT"
         //cFile := cDriv+"R"+alltrim(substr(cTotNaam(),152,7))+".TXT"
      else
         //cFile := cMailTar()+"R"+alltrim(substr(cTotNaam(),152,7))+".TXT"
         cFile := cMailTar()+"B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Geboorteslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Births file being prepared")
      endif

      // Open the file
      if file(cFile)
         set alternate to (cFile) additive
         set alternate on
         set console off
      else
         set alternate to (cFile)
         set alternate on
         set console off
      endif

      // Write the data
      select SM3TYDI
      go top
      do while !eof()

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif
         set cons off
         set alternate on

         // Convert main id number
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idnr)
         else
            cData := fid(SM3DATA->idnr,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif

         // The actual write
         ?? trim(cData)+","                      // Id number
         ?? trim(SM3DATA->idnaam)+","            // Name of animal
         ?? trim(dtos(SM3DATA->gebdatum))+","    // Date of birth
         ?? trim(SM3DATA->geslag)+","            // Sex
         ?? trim(SM3DATA->gebstat)+","           // Birth status
         ?? trim(SM3DATA->tweeling)+","          // Twins with
         ?? trim(SM3DATA->niereg)+","            // Not for registration
         ?? trim(SM3DATA->vaarkode)+","          // Service code
         ?? trim(SM3DATA->ident)+","             // Identification method

         // Normal sire
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idvaar)
         else
            cData := fid(SM3DATA->idvaar,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         ?? trim(cData)+","

         // Normal dam
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idmoer)
         else
            cData := fid(SM3DATA->idmoer,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         ?? trim(cData)+","

         // Insemination date
         if SM3DATA->vaarkode == "3"
            ?? trim(dtos(SM3DATA->idatum))+","   // Insemindation date
         else
            ?? ","                               // Insemination date
         endif

         // Other data continue
         ?? trim(SM3DATA->kalfstat)+","          // Birth remark
         ?? trim(SM3DATA->kalfgem)+","           // Birth remark
         ?? ltrim(str(SM3DATA->mamoergeb))+","   // Dam mass at birth
         ?? ltrim(str(SM3DATA->gebmassa))+","    // Birth mass
         ?? trim(SM3DATA->subafd)+","            // Subsection of herd book
         ?? trim(SM3DATA->tipies)+","            // Colour code
         ?? ","                                  // First remark
         ?? ","                                  // Generasie

         // Mutli sire mark
         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
            ?? "1,"                              // Multi sire indicator
         else
            ?? ","                               // Multi sire indicator
         endif

         // Other data continue
         ?? ","                                  // Kalfke
         ?? ","                                  // Merkkk
         ?? trim(SM3DATA->kalfbnr)+","           // Bonsmara calf book number
         ?? ","                                  // Red gene carrier
         ?? ","                                  // Keurdatum
         ?? ","                                  // Aanvaa
         ?? ","                                  // Remark 2
         ?? ","                                  // Remark 3
         ?? ","                                  // Remark 4
         ?? ","                                  // Remark 5
         // ?? Add polled field
         ?

         // Verwyder pasgebore merk indien enige
         if lDele .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         // Next
         select SM3TYDI
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geboorteslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Births file was not created!")
         endif
      else

         // Display note on the screen
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Geboorteslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing births was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Geboorte epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Birth email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Geboortekennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Geboortekennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van geboortes vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Birth Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Birth Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic birth notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskNami(lDele)

   // Program to create diskettes with birth notification data

   // Declare
   local lRetu := TRUE
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local nRout := 1
   local cNumb := ""
   begin sequence

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT"
         //cFile := cDriv+"R"+alltrim(substr(cTotNaam(),152,7))+".TXT"
      else
         //cFile := cMailTar()+"R"+alltrim(substr(cTotNaam(),152,7))+".TXT"
         cFile := cMailTar()+"B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Geboorteslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Births file being prepared")
      endif

      // Open the file
      if file(cFile)
         set alternate to (cFile) additive
         set alternate on
         set console off
      else
         set alternate to (cFile)
         set alternate on
         set console off
      endif

      // Write the data
      select SM3TYDI
      go top
      do while !eof()

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif
         set cons off
         set alternate on

         // Convert main id number
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idnr)
         else
            cData := fid(SM3DATA->idnr,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif

         // The actual write
         ?? trim(cData)+","                      // Id number
         ?? trim(SM3DATA->idnaam)+","            // Name of animal
         ?? trim(dtos(SM3DATA->gebdatum))+","    // Date of birth
         ?? trim(SM3DATA->geslag)+","            // Sex
         ?? trim(SM3DATA->gebstat)+","           // Birth status
         ?? trim(SM3DATA->tweeling)+","          // Twins with
         ?? trim(SM3DATA->niereg)+","            // Not for registration
         ?? trim(SM3DATA->vaarkode)+","          // Service code
         ?? trim(SM3DATA->ident)+","             // Identification method

         // Normal sire
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idvaar)
         else
            cData := fid(SM3DATA->idvaar,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         ?? trim(cData)+","

         // Normal dam
         if sm3idfo() == "2"
            cData := alltrim(SM3DATA->idmoer)
         else
            cData := fid(SM3DATA->idmoer,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         endif
         ?? trim(cData)+","

         // Insemination date
         if SM3DATA->vaarkode == "3"
            ?? trim(dtos(SM3DATA->idatum))+","   // Insemindation date
         else
            ?? ","                               // Insemination date
         endif

         // Other data continue
         ?? trim(SM3DATA->kalfstat)+","          // Birth remark
         ?? trim(SM3DATA->kalfgem)+","           // Birth remark
         ?? ltrim(str(SM3DATA->mamoergeb))+","   // Dam mass at birth
         ?? ltrim(str(SM3DATA->gebmassa))+","    // Birth mass
         ?? trim(SM3DATA->subafd)+","            // Subsection of herd book
         ?? trim(SM3DATA->tipies)+","            // Colour code
         ?? ","                                  // First remark
         ?? ","                                  // Generasie

         // Mutli sire mark
         if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
            ?? "1,"                              // Multi sire indicator
         else
            ?? ","                               // Multi sire indicator
         endif

         // Other data continue
         ?? ","                                  // Kalfke
         ?? ","                                  // Merkkk
         ?? trim(SM3DATA->kalfbnr)+","           // Bonsmara calf book number
         ?? ","                                  // Red gene carrier
         ?? ","                                  // Keurdatum
         ?? ","                                  // Aanvaa
         ?? ","                                  // Remark 2
         ?? ","                                  // Remark 3
         ?? ","                                  // Remark 4
         ?? ","                                  // Remark 5
         // ?? Add polled field
         ?

         // Verwyder pasgebore merk indien enige
         if lDele .and. SM3DATA->idnr == SM3TYDI->idnr .and. SM3DATA->toggle2 == "G"
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->toggle2 := " "
            select SM3TYDI
         endif

         // Next
         select SM3TYDI
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geboorteslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Births file was not created!")
         endif
      else

         // Display note on the screen
         if cLanType() == "A"
            nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
            if left(cFile,1) $ "AB"
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
            else
               // File
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT is in die"
               @12, nBoxc say cMailTar()+" subgids op die"
               @13, nBoxc say "hardeskyf geskryf!"
               @14, nBoxc say "Heg asseblief hierdie lˆer aan 'n epos boodskap"
               @15, nBoxc say "gerig aan die betrokke Registrerende Owerheid."
            endif
            fScrBood(maxrow()-1,"Geboorteslˆer is suksesvol geskep!")
         else
            nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
            if left(cFile,1) $ "AB"
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
            else
               // File
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name B"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT was created in the"
               @12, nBoxc say cMailTar()+" subdirectory of the"
               @13, nBoxc say "hard disk!"
               @14, nBoxc say "Attach this file to an email message addressed"
               @15, nBoxc say "to the relative Registering Authority."
            endif
            fScrBood(maxrow()-1,"File containing births was succesfully created!")
         endif

      endif

      fScrWait(maxrow())


   end
   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
