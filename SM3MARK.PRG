//SM3MARK.PRG
//Program om tydelike merke te vertoon
//Kopiereg (c) 1993 A van Rensburg
//06-20-93 04:31am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3mark( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cMerk := ""
   local cHoof := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(2)
   local cBood := ""

   private cData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk(  , "Opsie "+cOption())
      else
         fScrOpsk(  , "Option "+cOption())
      endif
   else
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 4, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3merk","kode"})
      aadd(aSend,{"sm3merk","besk"})
      aadd(aSend,{"sm3merk","aant"})
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
   cHoof := fTOpen(cDd(),"sm3data")
   if left(cHoof,1) == "f"
      return cRetu
   endif
   cMerk := fTOpen(cDd(),"sm3merk")
   if left(cMerk,1) == "f"
      fTClose(cHoof)
      return cRetu
   endif

   //Skuif die databasis
   if cFind == NIL
   else
      cRetu := cFind
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
      fBox( nTop, nLeft, nBott, nRigh, "TYDELIKE MERKE" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "TEMPORARY MARKS" )
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
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [A - Z]=Vind      [Alt S]=Skrap alle merke" )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt E]=Verander  [Alt B]=Bou nuwe lˆer   " )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [A - Z]=Find  [Alt S]=Delete all marks" )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt E]=Edit  [Alt B]=Build new file  " )
      endif

      //Stabilize the display whilw checking for keystrokes
      do while (nKeyp := inkey()) == 0 .and. !bBrow:stabilize()
      enddo
      if bBrow:stable
         nKeyp := inkey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ENTER
         //Enter means return kode
         cRetu := fieldget(1)
         if SM3MERK->aant > 0
            if cLanType() == "A"
               cBood := "Moet bestaande "+cRetu+" merke eers geskrap word?"
            else
               cBood := "Should current "+cRetu+" marks first be deleted?"
            endif
            if fJaNee(24,cBood,,.t.)
               if cLanType() == "A"
                  fScrWbood(24,"Tydelike merke word geskrap")
               else
                  fScrWbood(24,"Temporary marks being deleted")
               endif
               //Skrap aantal merke in merke leer
               do while !rlock()
               enddo
               SM3MERK->aant := 0
               select SM3DATA
               set order to 8
               go top
               seek cRetu
               do while !eof()
                  do while !rlock()
                  enddo
                  SM3DATA->toggle1 := ""
                  seek cRetu
               enddo
               set order to 1
               go top
               select SM3MERK
            endif
         endif
         lMore := .f.

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fAddChg()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete(aRecv)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_S
         //Alt S means delete all marks
         if cLanType() == "A"
            if fJaNee(24,"Moet alle bestaande merke geskrap word?",,.t.)
               fSkrap()
               bBrow:refreshall()
            endif
         else
            if fJaNee(24,"Should all existing marks be deleted?",,.t.)
               fSkrap()
               bBrow:refreshall()
            endif
         endif

      elseif nKeyp == K_ALT_B
         //Alt B means build a new file
         fBouNuwe()
         bBrow:refreshall()

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cHoof)
   fTClose(cMerk)
   fTClose(cCdbf)
return cRetu

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
   local cRetu := ""

   private aData
   private cData

   //Kry die velde benodig
   if aRecv == NIL
      aadd(aSend,{"sm3merk","kode"})
      aadd(aSend,{"sm3merk","besk"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE TYDELIKE MERK")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW TEMPORARY MARK")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER TYDELIKE MERK")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT TEMPORARY MARK")
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

               //Tydelike merke word verander
               if fieldget(1) <> aRecv[1,14]
                  cRetu := fieldget(1)
                  fScrBood(23,cRetu+" -> "+aRecv[1,14])
                  if cLanType() == "A"
                     fScrWbood(24,"Tydelike merke word verander")
                  else
                     fScrWbood(24,"Temporary marks being changed")
                  endif
                  select SM3DATA
                  set order to 8
                  go top
                  seek cRetu
                  do while !eof()
                     do while !rlock()
                     enddo
                     SM3DATA->toggle1 := aRecv[1,14]
                     seek cRetu
                  enddo
                  set order to 1
                  go top
                  select SM3MERK
               endif

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
               nLoop := 1
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
   local cRetu   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1))+" - "+trim(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde "+alltrim(aRecv[1][6])+" geskrap word?"
   else
      cBood := "Should above-mentioned "+alltrim(aRecv[1][6])+" be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )

      //Skrap in hoofleer
      cRetu := fieldget(1)
      if cLanType() == "A"
         fScrWbood(24,"Tydelike merke word geskrap")
      else
         fScrWbood(24,"Temporary marks being deleted")
      endif
      select SM3DATA
      set order to 8
      go top
      seek cRetu
      do while !eof()
         do while !rlock()
         enddo
         SM3DATA->toggle1 := ""
         seek cRetu
      enddo
      set order to 1
      go top
      select SM3MERK

      //Skrap in merke leer
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
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
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

/****************************************************************************/
STATIC FUNCTION FBouNuwe

   //Funksie om nuwe inskrywings te bou
   local nTell := 1

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Tydelike merke word getel")
   else
      fScrWbood(24,"Temporary marks being counted")
   endif

   //Maak bestaande aantal nul
   select SM3MERK
   go top
   do while !eof()
      do while !rlock()
      enddo
      SM3MERK->aant := 0
      skip
   enddo

   //Loop deur hoofleer
   select SM3DATA
   go top
   do while !eof()
      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say fpercent(nTell,lastrec())+"% Voltooi"
      else
         @23,35 say fpercent(nTell,lastrec())+"% Completed"
      endif
      setcolor(cColNorm())
      if !empty(SM3DATA->toggle1)
         select SM3MERK
         seek SM3DATA->toggle1
         if eof()
            dbappend()
         endif
         do while !rlock()
         enddo
         if empty(SM3MERK->kode)
            SM3MERK->kode := SM3DATA->toggle1
         endif
         SM3MERK->aant++
      endif
      select SM3DATA
      nTell++
      skip
   enddo
   go top

   //Skrap merke sonder aantalle
   select SM3MERK
   do while !eof()
      if SM3MERK->aant == 0
         do while !rlock()
         enddo
         delete
      endif
      skip
   enddo
   go top

   //Herstel
return NIL

/****************************************************************************/
STATIC FUNCTION fSkrap

   //Funksie om alle merke te skrap

   //Verklaar
   local nTell := 1

   //Loop deur hoofleer
   select SM3DATA
   go top
   do while !eof()
      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say fpercent(nTell,lastrec())+"% Voltooi"
      else
         @23,35 say fpercent(nTell,lastrec())+"% Completed"
      endif
      setcolor(cColNorm())
      if !empty(SM3DATA->toggle1)
         do while !rlock()
         enddo
         SM3DATA->toggle1 := ""
      endif
      nTell++
      skip
   enddo
   go top

   //Skrap merke sonder aantalle
   select SM3MERK
   do while !eof()
      do while !rlock()
      enddo
      delete
      skip
   enddo
   go top

   //Herstel
return NIL

