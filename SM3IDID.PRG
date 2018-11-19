//SM3IDID.PRG
//Program om diere te vertoon, te skrap en te verander
//Kopiereg (c) 1993 A van Rensburg
//05-06-93 08:22am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "setcurs.ch"

/******************************************************************************/
FUNCTION sm3idid( nTop, nLeft, nBott, aSend, cFind )

   // Declare
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
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
   local cMess := ""

   private pData := ""
   private cHead := ""

   begin sequence

      // Ask to create indexes
      // Removed 07-05-22 12:06
      //if cLanType() == "A"
      // fScrOpsk( ,"Opsie "+cOption())
      //   fScrBood(maxrow()-1,"Indekslˆers moet eers herskep word! Dit neem lank!")
      //   cMess := "Gaan voort?"
      //else
      // fScrOpsk( ,"Option "+cOption())
      //   fScrBood(maxrow()-1,"Index files must be created! This will take some time!")
      //   cMess := "Continue?"
      //endif
      //if fJaNee(maxrow(),cMess,,.f.)
      //else
      //   break
      //endif

      // Herskep Indekse
      stdinde(.t.)
      stdindx()

      // Skerm
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

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
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
         fBox( nTop, nLeft, nBott, nRigh, "SKRAP OF VERANDER ID NOMMERS" )
      else
         fBox( nTop, nLeft, nBott, nRigh, "DELETE OR EDIT ID NUMBERS" )
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
            fScrBood( 23, "[A-Z]=Vind  [ Del ]=Skrap dier        " )
            fScrBood( 24, "[Esc]=Menu  [Alt E]=Verander id nommer" )
         else
            fScrBood( 23, "[A-Z]=Find  [ Del ]=Delete animal " )
            fScrBood( 24, "[Esc]=Menu  [Alt E]=Edit id number" )
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

         elseif nKeyp == K_ALT_E
            //Alt E means verander id nommer
            if fEdit()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_DEL
            //Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
            //Means locate a record
            if fLocate(aRecv,nKeyp)
               bBrow:refreshall()
            endif

         elseif nKeyp == K_F1
            //Hulp
            do help with "sm3idid",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
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

/******************************************************************************/
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
      lDele := .t.

      //Toets of dier nie ma is nie
      set order to 4
      seek cSeek
      if found()
         lDele := .f.
         if cLanType() == "A"
            fScrBood(23,trim(cSeek)+" is die ma van "+trim(fieldget(1))+" en moet eintlik nie geskrap word nie!" )
            cBood := "Moet bogenoemde dier nog steeds geskrap word?"
         else
            fScrBood(23,trim(cSeek)+" is the dam of "+trim(fieldget(1))+" and should not be deleted!" )
            cBood := "Should above-mentioned animal still be deleted?"
         endif
         if fJaNee(24,cBood,,.f.)
            lDele := .t.
         endif
      endif

      //Toets of dier nie pa is nie
      set order to 5
      seek cSeek
      if found()
         lDele := .f.
         if cLanType() == "A"
            fScrBood(23,trim(cSeek)+" is die pa van "+trim(fieldget(1))+" en moet eintlik nie geskrap word nie!" )
            cBood := "Moet bogenoemde dier nog steeds geskrap word?"
         else
            fScrBood(23,trim(cSeek)+" is the sire of "+trim(fieldget(1))+" and should not be deleted!" )
            cBood := "Should above-mentioned animal still be deleted?"
         endif
         if fJaNee(24,cBood,,.f.)
            lDele := .t.
         endif
      endif

      //Herstel
      set order to 1
      goto nCrec
      //Hoofleer word laaste geskrap

      if lDele

         //Skerm
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,trim(cSeek)+" word geskrap")
         else
            fScrWbood(24,trim(cSeek)+" being deleted")
         endif

         //Skrap ander leers
         fDelFile(cSeek,"sm3aank")               // Aankope
         fDelFile(cSeek,"sm3dekk")               // Dekkings
         fDelFile(cSeek,"sm3insp")               // Inspeksies
         fDelFile(cSeek,"sm3note")               // Notas
         fDelFile(cSeek,"sm3oord")               // Oordragte
         fDelFile(cSeek,"sm3pick")               // Kieslys
         fDelFile(cSeek,"sm3veea")               // Veeartseny
         fDelFile(cSeek,"sm3veev")               // Veearts verslag
         fDelFile(cSeek,"sm3veil",2)               // Veilings
         fDelFile(cSeek,"sm3verk")               // Verkope
         fDelFile(cSeek,"sm3vore")               // Vorm E
         fDelFile(cSeek,"sm3weeg")               // Wegings

         //Skrap hoofleer
         select SM3DATA
         goto nCrec
         if fieldget(1) == cSeek
            do while !rlock()
            enddo
            delete
            skip
            if eof()
               go top
            endif
            lRetu := .t.
         endif

      endif

   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fDelFile(cSeek,cName,nOrde)

   // Funksie om elke dier in gegewe leer te skrap

   //Verklaar
   local cCdbf := fTOpen()
   local cFile := ""

   //Waardes
   nOrde := if(nOrde==NIL,1,nOrde)

   //Die proses
   cFile := fTOpen(cDd(),cName,,,,.f.)
   if left(cFile,1) == "f"
   else
      set order to nOrde
      seek cSeek
      do while !eof()
         delete
         seek cSeek
      enddo
   endif
   fTClose(cFile)

   //Herstel
   fTClose(cCdbf)
return NIL

/******************************************************************************/
STATIC FUNCTION fEdit()

   // Funksie om diere se nommers te verander

   //Verklaar
   local lRetu := .f.
   local aCscr := fASaveScr()
   local cSeek := fieldget(1)
   local cNewi := space(12)
   local nBoxc := 0
   local lLoop := .t.
   local nCrec := recno()
   local getlist := {}
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   begin sequence

      // Cannot edit an empty number
      if empty(cSeek)
         break
      endif

      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent( 9,space(33),8,"VERANDER ID NOMMER")
         @11,nBoxc say "        Ou id nommer"
         @13,nBoxc say "      Nuwe id nommer"
         @14,nBoxc say "  Kuddekenmerkletter"
         @15,nBoxc say "          Jaarletter"
         @16,nBoxc say "          Volgnommer"
      else
         nBoxc := fBoxCent( 9,space(33),8,"CHANGE ID NUMBER")
         @11,nBoxc say "       Old id number"
         @13,nBoxc say "       New id number"
         @14,nBoxc say "    Herd designation"
         @15,nBoxc say "         Year letter"
         @16,nBoxc say "     Sequence number"
      endif

      // Variables
      cKudd := fieldget(fieldpos("kuddek"))
      cJaar := fieldget(fieldpos("jaarle"))
      cVolg := fieldget(fieldpos("volgno"))
      setcolor(cColInve())
      @11,nBoxc+21 say fieldget(1)
      @14,nBoxc+21 say cKudd
      @15,nBoxc+21 say cJaar
      @16,nBoxc+21 say cVolg
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
            fScrBood(24,"Type the new id number!")
         endif

         //Vra die vrae
         @13,nBoxc+21 get cNewi pict "@!"
         @14,nboxc+21 get cKudd pict "@!"
         @15,nboxc+21 get cJaar pict "!9"
         @16,nboxc+21 get cVolg pict "9999"
         set cursor on
         read
         set cursor off

         //If escaped or nothing
         if lastkey() == K_ESC .or. empty(cNewi)
            break
         endif

         // Toets of dier nie reeds bestaan nie
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

      // Screen
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,trim(cSeek)+" se id nommer word verander na "+trim(cNewi))
      else
         fScrWbood(24,trim(cSeek)+" id number being changed to "+trim(cNewi))
      endif

      // Verander kuddek ens
      select SM3DATA
      goto nCrec
      SM3DATA->kuddek := cKudd
      SM3DATA->jaarle := cJaar
      SM3DATA->volgno := cVolg

      //Verander nommers - hoofleer laaste
      fEdiFile(cSeek,cNewi,"sm3aank",1,1)        // Aankope
      fEdiFile(cSeek,cNewi,"sm3acti",2,1)        // Aksies
      fEdiFile(cSeek,cNewi,"sm3dekk",1,1)        // Dekkings - Koeinommer
      fEdiFile(cSeek,cNewi,"sm3dekk",4,2)        // Dekkings - Bulnommer
      fEdiFile(cSeek,cNewi,"sm3dekk",5,11)       // Dekkings - Skenker
      fEdiFile(cSeek,cNewi,"sm3deko",2,2)        // Dekkingsopsommings
      fEdiFile(cSeek,cNewi,"sm3insp",1,1)        // Inspeksielys
      fEdiFile(cSeek,cNewi,"sm3note",1,1)        // Notas
      fEdiFile(cSeek,cNewi,"sm3oord",1,1)        // Oordragte
      fEdiFile(cSeek,cNewi,"sm3pick",1,1)        // Pick list
      fEdiFile(cSeek,cNewi,"sm3veea",1,1)        // Veeartseny
      fEdiFile(cSeek,cNewi,"sm3veev",1,1)        // Veearts verslag
      fEdiFile(cSeek,cNewi,"sm3veil",2,2)        // Veilingskatalogus
      fEdiFile(cSeek,cNewi,"sm3verk",1,1)        // Verkope
      fEdiFile(cSeek,cNewi,"sm3vore",1,1)        // Skrappingslys
      fEdiFile(cSeek,cNewi,"sm3weeg",1,1)        // Wegings
      fEdiFile(cSeek,cNewi,"sm3data",4,6)        // Hooflˆer - idmoer
      fEdiFile(cSeek,cNewi,"sm3data",5,5)        // Hooflˆer - idvaar
      fEdiFile(cSeek,cNewi,"sm3data",1,1)        // Hooflˆer - idnr

      //Id in hoofleer
      select SM3DATA
      ordsetfocus("SM3DATA")
      seek cNewi
      if eof()
         go top
      endif

   end

   // Herstel
   fARestScr(aCscr)
   lRetu := .t.

return lRetu

/******************************************************************************/
STATIC FUNCTION fEdiFile(cSeek,cNewi,cName,nOrde,nPutt)

   // Funksie om elke dier in gegewe leer te verander

   //Verklaar
   local aCdbf := fATopen()
   local cFile := ""

   //Waardes
   nOrde := if(nOrde==NIL,1,nOrde)

   // Die proses
   if upper(cName) == "SM3DATA"
      select SM3DATA
      set order to nOrde
      seek cSeek
      do while !eof()
         fieldput(nPutt,cNewi)
         seek cSeek
      enddo
   else
      aCdbf := fATopen(aCdbf,cDd(),cName,,,"FILE",.f.)
      if !aCdbf[len(aCdbf),1]
      else
         set order to nOrde
         seek cSeek
         do while !eof()
            fieldput(nPutt,cNewi)
            seek cSeek
         enddo
      endif
   endif

   //Herstel
   fATclose(aCdbf)

return NIL
