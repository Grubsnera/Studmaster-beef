//SM3DUBB.PRG
//Program om dubbel diere te soek
//Kopiereg (c) 1993 A van Rensburg
//05-06-93 05:10pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "setcurs.ch"

/****************************************************************************/
FUNCTION sm3dubb( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cCcur := setcursor(SC_NONE)
   local cData := ""
   local cFile := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(12)
   local lDubb := .f.

   private pData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
		if cLanType() == "A"
    		fScrOpsk( , "Opsie "+cOption())
		else
    		fScrOpsk( , "Option "+cOption())
		endif
	else
		if cLanType() == "A"
    		fScrOpsk( 1, "Opsie "+cOption())
		else
    		fScrOpsk( 1, "Option "+cOption())
		endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3data","idnr"})
      aadd(aSend,{"sm3data","reknr"})
      aadd(aSend,{"sm3data","kalfbnr"})
      aadd(aSend,{"sm3data","geslag"})
      aadd(aSend,{"sm3data","gebdatum"})
      aadd(aSend,{"sm3data","idmoer"})
      aadd(aSend,{"sm3data","idvaar"})
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
   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      setcursor(cCcur)
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
      pData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &pData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "TOETS VIR DUBBEL ID NOMMERS" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "TEST FOR DUPLICATE ID NUMBERS" )
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
      if lDubb
         if cLanType() == "A"
            fScrBood( 23, "[Esc]  [A-Z]  [Alt T]  [Esc]  [Alt E ]" )
            fScrBood( 24, " Menu   Vind   Toets   Skrap  Verander" )
         else
            fScrBood( 23, "[Esc]  [A-Z]  [Alt T]  [Esc ]  [Alt E]" )
            fScrBood( 24, " Menu   Find   Tests   Delete   Change" )
         endif
      else
         if cLanType() == "A"
            fScrBood( 23, "[Esc]  [A-Z]  [Alt T]" )
            fScrBood( 24, " Menu   Vind   Toets " )
         else
            fScrBood( 23, "[Esc]  [A-Z]  [Alt T]" )
            fScrBood( 24, " Menu   Find   Tests " )
         endif
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

      elseif nKeyp == K_ALT_T
         //Alt T means verander id nommer
         if fDouble()
            lDubb := .t.
         else
            if cLanType() == "A"
               fScrBood(23,"Geen dubbel id nommers bestaan!")
            else
               fScrBood(23,"No duplicate id numbers exist!")
            endif
            fScrWait(24)
            go top
         endif
         bBrow:refreshall()

      elseif nKeyp == K_ALT_E .and. lDubb
         //Alt E means verander id nommer
         if fEdit()
            lDubb := .f.
            bBrow:refreshall()
         endif

      elseif nKeyp == K_DEL .and. lDubb
         //Delete means delete a record
         if fDelete()
            lDubb := .f.
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_F1
         //Hulp
         do help with "sm3dubb",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   setcursor(cCcur)
   fTClose(cData)
   fTClose(cCdbf)
return cRetu

//*************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local getlist := {}
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local cSeek := ""
   local nBoxc := 0

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cSeek := upper(chr(nKeyp)) + space(aRecv[1,4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[1][6] get cSeek pict aRecv[1][10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cSeek == space(aRecv[1][4])
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   set softseek on
   seek cSeek
   set softseek off
   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

//*************************************************************************/
STATIC FUNCTION fDelete()

   //Funksie om enige rekord te skrap

   //Verklaar
   local lRetu := .f.
   local cBood := ""
   local nCrec := recno()
   local cSeek := fieldget(1)
   local lDele := .f.

   //Skerm
   fScrBood(23,trim(fieldget(1)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde dier geskrap word?"
   else
      cBood := "Should above-mentioned animal be deleted?"
   endif

   //Vra
   if fJaNee(24,cBood,,.f.)

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,trim(cSeek)+" word geskrap")
      else
         fScrWbood(24,trim(cSeek)+" being deleted")
      endif

      do while !rlock()
      enddo
      delete
      skip
      if eof()
         go top
      endif
      lRetu := .t.

   endif

return lRetu

//***************************************************************************/
STATIC FUNCTION fEdit()

   //Funksie om diere se nommers te verander

   //Verklaar
   local lRetu := .f.
   local cCscr := savescreen(0,0,24,79)
   local cSeek := fieldget(1)
   local cNewi := space(12)
   local nBoxc := 0
   local lLoop := .t.
   local nCrec := recno()
   local getlist := {}

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(10,space(33),5,"VERANDER ID NOMMER")
      @11,nBoxc say "        Ou id nommer"
      @13,nBoxc say "      Nuwe id nommer"
   else
      nBoxc := fBoxCent(10,space(33),5,"CHANGE ID NUMBER")
      @11,nBoxc say "       Old id number"
      @13,nBoxc say "       New id number"
   endif
   setcolor(cColInve())
   @11,nBoxc+21 say fieldget(1)
   setcolor(cColNorm())

   //Vra die nuwe nommer
   lLoop := .t.
   do while lLoop

      //Skerm
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Lys van diere")
         fScrBood(24,"Tik die nuwe id nommer!")
      else
         fScrBood(23,"[Esc]=List of animals")
         fScrBood(24,"type the new id number!")
      endif

      //Vra die vrae
      @13,nBoxc+21 get cNewi pict "@!"
      set cursor on
      read
      set cursor off

      //If escaped or nothing
      if lastkey() == K_ESC .or. len(trim(cNewi)) == 0
         exit
      endif

      //Toets of dier nie reeds bestaan nie
      seek cNewi
      if found()
         if cLanType() == "A"
            fScrBood(23,"Dier bestaan reeds!")
         else
            fScrBood(23,"Animal already exists!")
         endif
         fScrWait(24)
         goto nCrec
         loop
      endif

      lLoop := .f.

   enddo
   if lLoop
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,trim(cSeek)+" se id nommer word verander na "+trim(cNewi))
   else
      fScrWbood(24,trim(cSeek)+" id number is being changed to "+trim(cNewi))
   endif

   //Id in hoofleer
   select SM3DATA
   set order to 1
   goto nCrec
   do while !rlock()
   enddo
   SM3DATA->idnr := cNewi
   seek cNewi
   if eof()
      go top
   endif

   //Herstel
   restscreen(0,0,24,79,cCscr)
   lRetu := .t.
return lRetu

//***************************************************************************/
STATIC FUNCTION fDouble()

   //Funksie om te toets vir dubbel diere

   //Verklaar
   local cIdnr := fieldget(1)
   local lRetu := .f.

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆer word deurgesoek vir dubbel id nommers")
   else
      fScrWbood(24,"Data file being searched for duplicate id numbers")
   endif

   //Loop
   skip
   do while !eof()

      if cIdnr == fieldget(1)
         skip -1
         lRetu := .t.
         exit
      else
         cIdnr := fieldget(1)
      endif

      //Volgende
      skip

   enddo

   //Herstel
return lRetu














