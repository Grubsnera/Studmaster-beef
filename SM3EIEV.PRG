//SM3EIEV.PRG
//Program om eie verslae te vertoon
//Kopiereg (c) 1992 A van Rensburg
//09:16 30 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

#xtrans GetSetBlock( <v> ) => {|x| if( x == NIL, <v>, <v> := x ) }

//****************************************************************************/
FUNCTION sm3eiev( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cEiev := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0

   //Hierdie program spesifieke veranderlikes
   local aRetu := {}
   local nTel  := 1
   local lVeld := .f.
   local cMemf := cDd()+"sm3eiev.mem"

   private cData := ""
   private cHead := ""
   private cMkod := ""
   private cMbes := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif
   else
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      else
         fScrOpsk(1,"Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 4, nTop  )
   nLeft   := if( nLeft == NIL, 4, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3eiev","kode"})
      aadd(aSend,{"sm3eiev","besk"})
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cEiev := fTOpen(cDd(),"sm3eiev")
   if left(cEiev,1) == "f"
      return aRetu
   endif

   //Skuif die databasis
   if cFind == NIL
   else
      aRetu := cFind
      set soft on
      seek cFind
      set soft off
      if eof()
         go top
      endif
   endif

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
      fBox( nTop, nLeft, nBott, nRigh, "EIE VERSLAE" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "OWN REPORTS" )
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
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [A - Z]=Vind      [Alt F]=Vertoon velde   " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt E]=Verander  [Alt S]=Skrap alle velde" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [A - Z]=Find  [Alt F]=Display fields   " )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt E]=Edit  [Alt S]=Delete all fields" )
      endif

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
         if lVeld
            keyboard chr(145)
            lVeld := .f.
         endif
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ENTER
         //Enter means return kode
         //Bou array vanaf databasis
         for i = 1 to 40
            if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
               aadd( aRetu, { trim(substr(SM3EIEV->veld,nTel,10)), trim(substr(SM3EIEV->veld,nTel+10,10)) } )
            endif
            nTel := nTel + 20
         next
         if len( aRetu ) > 0
            //Skep mem file
            cMkod := SM3EIEV->kode
            cMbes := SM3EIEV->besk
            save all like cM* to (cMemf)
            lMore := .f.
         else
            if cLanType() == "A"
               fScrBood(23,"Geen velde is gedefinieer nie!")
               fScrWait(24)
            else
               fScrBood(23,"No fields have been defined!")
               fScrWait(24)
            endif
         endif

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg(aRecv)
            lVeld := .t.
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fAddChg(aRecv)
            lVeld := .t.
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete(aRecv)
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecv)
         bBrow:refreshall()

      elseif nKeyp == K_ALT_F .or. nKeyp == 145
         //Alt F means display fields
         fVelde()

      elseif nKeyp == K_ALT_S
         //Alt S means clear all the defined fields
         if rlock()
            SM3EIEV->veld := space(800)
            dbUnlock()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cEiev)
   fTClose(cCdbf)
return aRetu

/*************************************************************************/
STATIC FUNCTION fAddChg(aRecv)

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxc    := 0
   local aSend    := {}
   local lLoop    := .t.
   local lReturn  := .f.
   local i        := 0
   local nLoop    := 0
   local nRekord  := 0
   local aDbfs    := {}
   local cSearch  := ""
   local nLine    := 0

   private aData
   private cData

   //Kry die velde benodig
   if aRecv == NIL
      aadd(aSend,{"sm3eiev","kode"})
      aadd(aSend,{"sm3eiev","besk"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE EIE VERSLAG")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW OWN REPORT")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER EIE VERSLAG")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT OWN REPORT")
      endif
   endif

   //Vul met data en vertoon
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i][13] )
   next

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Vra die velde
            //Skerm
            //Read
            @nLine+ 1,nBoxc say aRecv[ 1][6] get aRecv[ 1][14] pict aRecv[ 1][10] valid(fVkode(1,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 2,nBoxc say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10]
            set cursor on
            read
            set cursor off
            lReturn := .t.
            //Wat nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         otherwise
            //Bewaar rekord
            //Gaan na rekord
            if nRekord > 0
               goto nRekord
            else
               dbAppend()
            endif
            //Lock
            do while !rlock()
            enddo
            //Bewaar
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i][13], aRecv[i][14] )
            next
            commit
            if nRekord == 0
               nRekord := recno()
               //Maak rekord skoon
               go bottom
               skip
               for i = 1 to len( aRecv )
                  aRecv[i][14] := fieldget( aRecv[i][13] )
               next
               goto nRekord
               nRekord := 0
               nLoop := 0
            else
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen(0,0,24,79,cCurSke)
return lReturn

//*************************************************************************/
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1))+" - "+trim(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde "+alltrim(aRecv[1][6])+" geskrap word?"
   else
      cBood := "Should above-mentioned "+alltrim(aRecv[1][6])+" be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
      do while !rlock()
      enddo
      delete
      skip
      if eof()
         go top
      endif
      lReturn := .t.
   endif

return lReturn

//*************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local getlist := {}
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local cData := ""
   local nBoxc := 0

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
   set softseek on
   seek cData
   set softseek off
   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

//******************************************************************************/
STATIC FUNCTION fVkode(nItem,aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local aDisp   := aclone(aRecv)
   local cSeek   := ""
   local i       := 1

   do case
      case len(alltrim(aRecv[nItem][14])) == 0
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[nItem][6])+" is verpligtend!")
         else
            fScrBood(23,alltrim(aRecv[nItem][6])+" is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
      otherwise
         //Kyk of rekord reeds bestaan
         seek aDisp[nItem][14]
         if eof()
            //Bestaan nie - gaan voort
            if nRekord > 0
               goto nRekord
            endif
         else
            //Bestaan
            if nRekord > 0 .and. nRekord == recno()
               //Dieselfde rekord - gaan voort
            else
               //Bestaan reeds - vertoon bestaande
               //Vul data
               for i = 1 to len(aDisp)
                  aDisp[i][14] := fieldget(aRecv[i][13])
                  setcolor(cColInve())
                  @nLine+i,nBoxc+21 say transform(aDisp[i][14],aDisp[i][10])
                  setcolor(cColNorm())
               next
               //Wag
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,alltrim(aDisp[nItem][6])+" bestaan reeds!" )
               else
                  fScrWait(24,alltrim(aDisp[nItem][6])+" already exists!" )
               endif
               if nRekord > 0
                  goto nRekord
               else
                  go bottom
                  skip
               endif
               //Vertoon oorspronklike
               setcolor(cColInve())
               for i = 1 to len(aRecv)
                  @nLine+i,nBoxc+21 say transform(aRecv[i][14],aRecv[i][10])
               next
               setcolor(cColNorm())
               lRetu := .f.
            endif
         endif
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

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
      aadd(aSend,{"sm3eiev","kode"})
      aadd(aSend,{"sm3eiev","besk"})
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
      fScrbood(24,alltrim(aRecv[1][6])+" word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper(alltrim(aRecv[1][6])+".")
   else
      fScrbood(24,alltrim(aRecv[1][6])+" being printed!  [Esc]=Stop printer.")
      cHdln := upper(alltrim(aRecv[1][6])+"s.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := .t.
   do while lLoop

      //Skakel die drukker aan
      //fPrnOn()

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

         //fPrnOff()
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

/*************************************************************************/
STATIC FUNCTION fVelde

   //Veranderlikes
   local GetList := {}
   local cCscr := savescreen( 0, 0, 24, 79 )
   local nBoxc := 0
   local i     := 1
   local nTel  := 1
   local aVeld := {}
   local aOpsk := {}
   local aFiel := {}
   local bBrow := NIL
   local aCols := {}
   local lMore := .t.
   local t     := 1
   local cData := space(47)+"   1"
   local nKeyp := 0

   //Opskrif
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent( 4, space(70), 1, "EIE VERSLAE KOLOMME (VELDE) WAT VERTOON GAAN WORD VIR:- " )
      @ 4, nBoxc say SM3EIEV->besk
   else
      nBoxc := fBoxCent( 4, space(70), 1, "OWN REPORT COLUMNS (FIELDS) THAT WILL BE DISPLAYED FOR:-" )
      @ 4, nBoxc say SM3EIEV->besk
   endif

   //Skerm
   if cLanType() == "A"
      fScrWbood(24,"Veldbesonderhede word gelees")
   else
      fScrWbood(24,"Field information being read")
   endif

   //Bou array vanaf velde inligting
   for i = 1 to 40
      if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
         aadd( aVeld, { trim(substr(SM3EIEV->veld,nTel,10)), trim(substr(SM3EIEV->veld,nTel+10,10)) } )
      endif
      nTel := nTel + 20
   next

   //Indien die Array wel iets in het
   if len( aVeld ) > 0

      //Kry die veldbeskrywings
      aOpsk := fGetField( aVeld )

      //Stoor die veldbeskrywings
      if len(aOpsk) > 0
         for i = 1 to len(aOpsk)
            //aadd( aFiel, { padr(ltrim(aOpsk[i][6]),20) } )
            aadd( aFiel, padr(ltrim(aOpsk[i][6]),20) )
         next
      else
         //skoon velde
         aadd( aVeld, { space(10), space(10) } )
         //aadd( aFiel, { space(20) } )
         aadd( aFiel, space(20) )
      endif

   else

      //skoon velde
      aadd( aVeld, { space(10), space(10) } )
      //aadd( aFiel, { space(20) } )
      aadd( aFiel, space(20) )

   endif

   //Skerm
   if cLanType() == "A"
      fBox( 8, 2, 20, 25, "velde om te vertoon" )
   else
      fBox( 8, 2, 20, 25, "fields to display" )
   endif

   //Create tBrowse for arrays
   bBrow := tBrowseArray( 9, 4, 19, 23, aFiel, GetSetBlock( t ) )

   //Define a cloumn for viewing file names
   //aCols := tbColumnNew( , {|| aFiel[t][1] } )
   aCols := tbColumnNew( , {|| aFiel[t] } )

   aCols:width := 20

   bBrow:addColumn( aCols )

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "             [Ins]=Bewaar op balk [+]=Bewaar aan einde  [Alt S]=Skrap almal  " )
         fScrBood( 24, "[Esc]=Terug  [Del]=Skrap op balk  [-]=Skrap aan einde   [Alt E]=Verander veld" )
      else
         fScrBood( 23, "              [Ins]=Insert at bar  [+]=Add at end     [Alt S]=Delete all")
         fScrBood( 24, "[Esc]=Return  [Del]=Delete at bar  [-]=Delete at end  [Alt E]=Edit field")
      endif

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

      if nKeyp == K_ESC .or. nKeyp == K_ENTER
         // Esc means leave
         //Skerm
         if cLanType() == "A"
            fScrWbood(24,"Veldbesonderhede word bewaar")
         else
            fScrWbood(24,"Field information being saved")
         endif
         //Bewaar array in .dbf
         cData := ""
         for i = 1 to len( aVeld )
            if empty(aVeld[i,1]) .or. empty(aVeld[i,2])
            else
               cData := cData + padr(aVeld[i][1],10) + padr(aVeld[i][2],10)
            endif
            //if len(trim(aVeld[i][1])) > 0 .and. len(trim(aVeld[i][2])) > 0
            //   cData := cData + padr(aVeld[i][1],10) + padr(aVeld[i][2],10)
            //endif
         next
         if rlock()
            SM3EIEV->veld := padr( cData, 800 )
            dbUnlock()
         endif
         lMore := .f.

      elseif nKeyp == K_DEL
         //Delete means delete an element
         if len( aFiel ) >= 2
            adel( aFiel, t )
            adel( aVeld, t )
            asize( aFiel, len( aFiel ) - 1 )
            asize( aVeld, len( aVeld ) - 1 )
         else
            aFiel[1] := space(20)
            aVeld[1][1] := { space(10), space(10) }
         endif
         bBrow:refreshAll()

      elseif nKeyp == K_MINUS
         //Minus means delete an element at end
         if len( aFiel ) >= 2
            adel( aFiel, len(aFiel) )
            adel( aVeld, len(aVeld) )
            asize( aFiel, len( aFiel ) - 1 )
            asize( aVeld, len( aVeld ) - 1 )
         else
            aFiel[1] := space(20)
            aVeld[1] := { space(10), space(10) }
            t := len( aFiel )
         endif
         bBrow:refreshAll()

      elseif nKeyp == K_ALT_S
         //Alt S means delete all fields
         asize( aFiel, 0 )
         asize( aVeld, 0 )
         aadd( aFiel, space(20) )
         aadd( aVeld, { space(10), space(10) } )
         bBrow:refreshAll()

      elseif nKeyp == K_PLUS
         //Plus means add an element at end
         cData := sm3list( ,,, val(right(cData,4)) )
         if left( cData, 20 ) <> space(20)
            if len( aFiel ) == 1 .and. aFiel[1] == space(20)
               aFiel[1] := left( cData, 20 )
               aVeld[1] := { substr(cData,21,10), substr(cData,31,10) }
            else
               aadd( aFiel, left(cData,20) )
               aadd( aVeld, { substr(cData,21,10), substr(cData,31,10) } )
               t := len( aFiel )
            endif
         endif
         bBrow:refreshAll()

      elseif nKeyp == K_INS
         //Insert means add an element at end
         cData := sm3list( ,,, val(right(cData,4)) )
         if left( cData, 20 ) <> space(20)
            if len( aFiel ) == 1 .and. aFiel[1] == space(20)
               aFiel[1] := left( cData, 20 )
               aVeld[1] := { substr(cData,21,10), substr(cData,31,10) }
            else
               aadd( aFiel, space(20) )
               aadd( aVeld, { space(10), space(10) } )
               aFiel := ains( aFiel, t )
               aVeld := ains( aVeld, t )
               aFiel[t] := left( cData, 20 )
               aVeld[t] := { substr(cData,21,10), substr(cData,31,10) }
            endif
         endif
         bBrow:refreshAll()

      elseif nKeyp == K_ALT_E
         //Alt E means chhange an element
         if len(aFiel) > 0
            cData := sm3list( ,,, val(right(cData,4)) )
            if left( cData, 20 ) <> space(20)
               aFiel[t] := left( cData, 20 )
               aVeld[t] := { substr(cData,21,10), substr(cData,31,10) }
            endif
            bBrow:refreshAll()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen( 0, 0, 24, 79, cCscr )
return NIL

