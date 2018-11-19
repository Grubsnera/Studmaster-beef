//STDNTXS.PRG
//Program om indeksleers te bewaar
//Kopiereg (c) 1992 A van Rensburg
//10:00am Nov 12,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION stdntxs( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := NIL
   local aGets := {}

   private cData := ""
   private cHead := ""

   //Herskep alle indeksleers
   stdinde(.f.)

   //Skerm
   fScrOpsk()

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"stdntxs","dbfname"})
      aadd(aSend,{"stdntxs","ntxname"})
      if cLanType() == "A"
         aadd(aSend,{"stdntxs","ntxbesk"})
      else
         aadd(aSend,{"stdntxs","ntxdesc"})
      endif
   endif

   //Skerm
   fScrOpsk()

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Kry die vrae
   asize(aSend,0)
   aadd(aSend,{"stdntxs","dbfname"})
   aadd(aSend,{"stdntxs","ntxname"})
   aadd(aSend,{"stdntxs","ntxbesk"})
   aadd(aSend,{"stdntxs","ntxdesc"})
   aadd(aSend,{"stdntxs","ntxexpr"})
   aadd(aSend,{"stdntxs","ntxcond"})
   aadd(aSend,{"stdntxs","ntxuniq"})
   aGets := fGetField(aSend)

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   lMore := .t.
   do while lMore
      dbusearea(.t.,,"stdntxs.tdb",,.f.,.f.)
      if neterr()
         //Loop forever
      else
         exit
      endif
   enddo

   //Skuif die databasis
   if cFind == NIL
   else
      cRetu := cFind
      seek cFind
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
      fBox( nTop, nLeft, nBott, nRigh, "INDEKSLˆERS" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "INDEX FILES" )
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
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [A - Z]=Vind                   " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt E]=Verander  [Alt P]=Print" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [A - Z]=Find               " )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt E]=Edit  [Alt P]=Print" )
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

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ENTER
         //Enter means return kode
         cRetu := fieldget(1) + fieldget(2)
         lMore := .f.

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg(aGets)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fAddChg(aGets)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete()
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
         //Means locate a record

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   select STDNTXS
   dbclosearea()
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

   private aData
   private cData

   //Kry die velde benodig
   if aRecv == NIL
      aadd(aSend,{"stdntxs","dbfname"})
      aadd(aSend,{"stdntxs","ntxname"})
      aadd(aSend,{"stdntxs","ntxbesk"})
      aadd(aSend,{"stdntxs","ntxdesc"})
      aadd(aSend,{"stdntxs","ntxexpr"})
      aadd(aSend,{"stdntxs","ntxcond"})
      aadd(aSend,{"stdntxs","ntxuniq"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE INDEKSLˆER")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW INDEX FILE")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER INDEKSLˆER")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT INDEX FILE")
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
            @nLine+ 1,nBoxc say aRecv[ 1][6] get aRecv[ 1][14] pict aRecv[ 1][10] valid(fVdbfname(aRecv,nRekord,nLine,nBoxc))
            @nLine+ 2,nBoxc say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10] valid(fVntxname(aRecv,nRekord,nLine,nBoxc))
            @nLine+ 3,nBoxc say aRecv[ 3][6] get aRecv[ 3][14] pict aRecv[ 3][10]
            @nLine+ 4,nBoxc say aRecv[ 4][6] get aRecv[ 4][14] pict aRecv[ 4][10]
            @nLine+ 5,nBoxc say aRecv[ 5][6] get aRecv[ 5][14] pict aRecv[ 5][10] valid(fVntxexpr(aRecv,nRekord,nLine,nBoxc))
            @nLine+ 6,nBoxc say aRecv[ 6][6] get aRecv[ 6][14] pict aRecv[ 6][10]
            @nLine+ 7,nBoxc say aRecv[ 7][6] get aRecv[ 7][14] pict aRecv[ 7][10]

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
STATIC FUNCTION fDelete

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1))+" "+trim(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde indekslˆer geskrap word?"
   else
      cBood := "Should above-mentioned index file be deleted?"
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

//******************************************************************************/
STATIC FUNCTION fVdbfname(aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := ""

   do case
      case len(alltrim(aRecv[1][14])) == 0
         cCscr   := savescreen(0,0,24,79)
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[1][6])+" is verpligtend!")
         else
            fScrBood(23,alltrim(aRecv[1][6])+" is compulsory!")
         endif
         fScrWait(24)
         restscreen(0,0,24,79,cCscr)
         lRetu := .f.
   endcase

   //Herstel
return lRetu


//******************************************************************************/
STATIC FUNCTION fVntxname(aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local aDisp   := aclone(aRecv)
   local cSeek   := ""
   local i       := 1

   do case
      case len(alltrim(aRecv[2][14])) == 0
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[2][6])+" is verpligtend!")
         else
            fScrBood(23,alltrim(aRecv[2][6])+" is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
      otherwise
         //Kyk of rekord reeds bestaan
         seek aDisp[1][14] + aDisp[2][14]
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
                  fScrWait(24,alltrim(aDisp[2][6])+" bestaan reeds!" )
               else
                  fScrWait(24,alltrim(aDisp[2][6])+" already exists!" )
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

//******************************************************************************/
STATIC FUNCTION fVntxexpr(aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := ""

   do case
      case len(alltrim(aRecv[5][14])) == 0
         cCscr   := savescreen(0,0,24,79)
         if cLanType() == "A"
            fScrBood(23,alltrim(aRecv[5][6])+" is verpligtend!")
         else
            fScrBood(23,alltrim(aRecv[5][6])+" is compulsory!")
         endif
         fScrWait(24)
         restscreen(0,0,24,79,cCscr)
         lRetu := .f.
   endcase

   //Herstel
return lRetu

