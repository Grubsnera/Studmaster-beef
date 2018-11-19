//SM3WEEG.PRG
//Program om wegings te bewaar en skrap
//Kopiereg (c) 1992 A van Rensburg
//05-08-93 11:35am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "setcurs.ch"

/**************************************************************************/
FUNCTION sm3weeg( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cCcur := setcursor(SC_NONE)
   local cWeeg := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local nRetu := 0
   local lCalc := .f.
   local nKeus := 1
   local cBrep := ""

   private cData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif
   else
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      else
         fScrOpsk(1,"Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3weeg","idnr"})
      aadd(aSend,{"sm3weeg","weegdatum"})
      aadd(aSend,{"sm3weeg","massa"})
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
   cWeeg := fTOpen(cDd(),"sm3weeg")
   if left(cWeeg,1) == "f"
      setcursor(cCcur)
      return nRetu
   endif

   //Skuif die databasis
   if cFind == NIL
   else
      //nRetu := cFind
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
      fBox( nTop, nLeft, nBott, nRigh, "GEREELDE WEGINGS" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "REGULAR WEIGHINGS" )
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
         fScrBood( 23, "[Esc] [Enter] [Ins] [Alt E ] [AltF] [Del] [A-Z] [F1]" )
         fScrBood( 24, " Menu  Kies    Nuwe Verander  Lˆer  Skrap  Vind Hulp" )
      else
         fScrBood( 23, "[Esc] [Enter] [Ins] [AltE] [AltF] [Del]  [A-Z] [F1]" )
         fScrBood( 24, " Menu  Choose  New   Edit   File  Delete  Find Help" )
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
         nRetu := fieldget(3)
         lMore := .f.

      elseif nKeyp == K_INS
         //Display menu
         nKeus := fMweeg(nKeus)
         do case
            case nKeus == 1
               //Insert means add a record to the .dbf
               go bottom
               skip
               if fAcWeeg(aRecv)
                  bBrow:refreshall()
               endif
            case nKeus >= 2
               //Doen vanaf leer
               fFileWeeg(aRecv)
               bBrow:refreshall()
         endcase

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fAcWeeg(aRecv)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_F
         // Alt F means create electronic notofication
         cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
         if cBrep $ "JYjy"
            // Breedplan format
            if fDiskBrer()
               bBrow:refreshall()
            endif
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

      elseif nKeyp == K_F1
         //Hulp
         do help with "sm3weeg",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   setcursor(cCcur)
   fTClose(cWeeg)
   fTClose(cCdbf)
return nRetu

/*************************************************************************/
STATIC FUNCTION fAcWeeg(aRecv)

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
      aadd(aSend,{"sm3weeg","idnr"})
      aadd(aSend,{"sm3weeg","weegdatum"})
      aadd(aSend,{"sm3weeg","massa"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE WEEGDATUM")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW WEIGHING DATE")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER WEEGDATUM")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT WEIGHING DATE")
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
            @nLine+ 1,nBoxc say aRecv[ 1,6] get aRecv[ 1,14] pict aRecv[ 1,10] valid(fVidnr(1,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 2,nBoxc say aRecv[ 2,6] get aRecv[ 2,14] pict aRecv[ 2,10] valid(fVdatu(2,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 3,nBoxc say aRecv[ 3,6] get aRecv[ 3,14] pict aRecv[ 3,10] valid(fVmass(3,aRecv,nRekord,nLine,nBoxc))
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
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1))+" - "+dtoc(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde weging geskrap word?"
   else
      cBood := "Should above-mentioned weight be deleted?"
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
   cData := upper(chr(nKeyp)) + space(aRecv[1,4]-1)

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
STATIC FUNCTION fVidnr(nItem,aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(23,0,24,79)
   local aDisp   := aclone(aRecv)
   local cSeek   := ""
   local i       := 1

   do case
      case len(alltrim(aRecv[nItem][14])) == 0
         if cLanType() == "A"
            fScrBood(23,"Id nommer is verpligtend!")
         else
            fScrBood(23,"Id number is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
   endcase

   //Herstel
   restscreen(23,0,24,79,cCscr)
return lRetu


//******************************************************************************/
STATIC FUNCTION fVdatu(nItem,aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(23,0,24,79)
   local aDisp   := aclone(aRecv)
   local cSeek   := ""
   local i       := 1

   do case
      case aRecv[nItem][14] == ctod("")
         if cLanType() == "A"
            fScrBood(23,"Weegdatum is verpligtend!")
         else
            fScrBood(23,"Weighing date is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
      otherwise
         //Kyk of rekord reeds bestaan
         seek aDisp[1][14]+dtos(aDisp[nItem,14])
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
                  fScrWait(24,"Dier reeds geweeg op hierdie datum!" )
               else
                  fScrWait(24,"Animal already weighed on this date!" )
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
   restscreen(23,0,24,79,cCscr)
return lRetu

//******************************************************************************/
STATIC FUNCTION fVmass(nItem,aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(23,0,24,79)
   local aDisp   := aclone(aRecv)
   local cSeek   := ""
   local i       := 1

   do case
      case aRecv[nItem][14] == 0
         if cLanType() == "A"
            fScrBood(23,"Massa is verpligtend!")
         else
            fScrBood(23,"Mass is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
   endcase

   //Herstel
   restscreen(23,0,24,79,cCscr)
return lRetu

//***************************************************************************/
STATIC FUNCTION fMweeg(nKeus)

   //Funksie om menu te vertoon

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cData := ""
   local cWeig := ""
   local nDier := 0
   private cTest := ""

   //Waardes
   nKeus := if(nKeus==NIL,1,nKeus)

   //Vertoon menu
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Gereelde wegings" )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Regular weighings" )
   endif

   // Kry opsienommer
   nKeus := fNewMenu(nKeus,"SM3WEEGa")
   if nKeus == 0
      return nKeus
   endif

   //Vra in kudde of almal
   if nKeus >= 4 .and. nKeus <= 5
      nDier := fNewMenu(1,"SM3WEEGb")
      if nDier == 0
         return nDier
      endif
   endif

   //Open data
   if nKeus >= 2 .and. nKeus <= 5

      cWeig := fTOpen(cDd(),"weeg",,,,.f.)
      if left(cWeig,1) == "f"
         nKeus := 0
      else
         cData := fTOpen(cDd(),"sm3data")
         if left(cData,1) == "f"
            nKeus := 0
         endif
         if nDier == 1 .and. nKeus == 4 .or. nDier == 1 .and. nKeus == 5
            set order to 7
            go top
         else
            set order to 1
            go top
         endif
      endif
   endif

   do case
      case nKeus == 2
         //Indeksgroep
         cTest := sm3indg(4)
         if len(trim(cTest)) == 0
            nKeus := 0
         else
            //Kyk of daar wel diere is vir die indeksgroep
            if cLanType() == "A"
               fScrBood(23)
               fScrWbood(24,"Diere word uitgesoek")
            else
               fScrBood(23)
               fScrWbood(24,"Animals being selected")
            endif
            select SM3DATA
            set order to 3
            seek cTest
            if found()
               select WEEG
               zap
               dbcommit()
               select SM3DATA
            endif
            do while SM3DATA->indekskode == cTest
               select WEEG
               dbappend()
               WEEG->idnr := SM3DATA->idnr
               //Volgende
               select SM3DATA
               skip
            enddo
            set order to 1
            go top
            select WEEG
            if lastrec() == 0
               if cLanType() == "A"
                  fScrBood(23,"Geen diere gevind om te weeg!")
                  fScrWait(24)
               else
                  fScrBood(23,"No animals found to be weighed!")
                  fScrWait(24)
               endif
               nKeus := 0
            endif
         endif

      case nKeus == 3
         //Fasegroep
         cTest := sm3fasg(4)
         if len(trim(cTest)) == 0
            nKeus := 0
         else
            //Kyk of daar wel diere is vir die fasegroep
            if cLanType() == "A"
               fScrBood(23)
               fScrWbood(24,"Diere word uitgesoek")
            else
               fScrBood(23)
               fScrWbood(24,"Animals being sorted")
            endif
            select SM3DATA
            set order to 2
            seek cTest
            if found()
               select WEEG
               zap
               dbcommit()
               select SM3DATA
            endif
            do while SM3DATA->fasekode == cTest
               select WEEG
               dbappend()
               WEEG->idnr := SM3DATA->idnr
               //Volgende
               select SM3DATA
               skip
            enddo
            set order to 1
            go top
            select WEEG
            if lastrec() == 0
               if cLanType() == "A"
                  fScrBood(23,"Geen diere gevind om te weeg!")
                  fScrWait(24)
               else
                  fScrBood(23,"No animals found to be weighed!")
                  fScrWait(24)
               endif
               nKeus := 0
            endif
         endif

      case nKeus == 4
         //Groep
         cTest := sm3groe()
         if len(trim(cTest)) == 0
            nKeus := 0
         else
            //Kyk of daar wel diere is vir die fasegroep
            if cLanType() == "A"
               fScrBood(23)
               fScrWbood(24,"Diere word uitgesoek")
            else
               fScrBood(23)
               fScrWbood(24,"Animals being sorted")
            endif
            select WEEG
            dbcommit()
            zap
            select SM3DATA
            do while !eof()
               if &cTest
                  select WEEG
                  dbappend()
                  WEEG->idnr := SM3DATA->idnr
               endif
               //Volgende
               select SM3DATA
               skip
            enddo
            set order to 1
            go top
            select WEEG
            if lastrec() == 0
               if cLanType() == "A"
                  fScrBood(23,"Geen diere gevind om te weeg!")
                  fScrWait(24)
               else
                  fScrBood(23,"No animals found to be weighed!")
                  fScrWait(24)
               endif
               nKeus := 0
            endif
         endif

      case nKeus == 5
         //Seleksiegroep
         cTest := sm3selg()
         if len(trim(cTest)) == 0
            nKeus := 0
         else
            //Kyk of daar wel diere is vir die fasegroep
            if cLanType() == "A"
               fScrBood(23)
               fScrWbood(24,"Diere word uitgesoek")
            else
               fScrBood(23)
               fScrWbood(24,"Animals being sorted")
            endif
            select WEEG
            zap
            dbcommit()
            select SM3DATA
            do while !eof()
               if &cTest
                  select WEEG
                  dbappend()
                  WEEG->idnr := SM3DATA->idnr
               endif
               //Volgende
               select SM3DATA
               skip
            enddo
            select SM3DATA
            set order to 1
            go top
            select WEEG
            if lastrec() == 0
               if cLanType() == "A"
                  fScrBood(23,"Geen diere gevind om te weeg!")
                  fScrWait(24)
               else
                  fScrBood(23,"No animals found to be weighed!")
                  fScrWait(24)
               endif
               nKeus := 0
            endif
         endif
   endcase

   //Herstel
   fTClose(cWeig)
   fTClose(cData)
   fTClose(cCdbf)
   restscreen(0,0,24,79,cCscr)
return nKeus

//*************************************************************************/
STATIC FUNCTION fFileWeeg(aRecv)

   //Funksie om alle diere te weeg in leer

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cWeeg := ""
   local nBoxc := 0
   local dDate := ctod("")
   local nReko := 0
   local getlist := {}

   //Waardes
   aRecv[2,14] := ctod("")
   aRecv[3,14] := 0

   //Open dataleers
   cWeeg := fTOpen(cDd(),"weeg",,,,.f.)
   if left(cWeeg,1) == "f"
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(10,space(33),5,"Bewaar gereelde wegings")
   else
      nBoxc := fBoxCent(10,space(33),5,"Enter regular weighings")
   endif
   @11,nBoxc say aRecv[1,6]
   @12,nBoxc say aRecv[2,6]
   @13,nBoxc say aRecv[3,6]

   //Die loop
   do while !eof()

      //Skerm
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Gereelde wegings  [PgUp]=Vorige dier  [F1]=Hulp")
         fScrBood(24,"Tik die gevraagde inligting!")
      else
         fScrBood(23,"[Esc]=Regular weighings  [PgUp]=Previous animal  [F1]=Help")
         fScrBood(24,"Type the requested information!")
      endif
      setcolor(cColInve())
      @11,nBoxc+21 say WEEG->idnr
      setcolor(cColNorm())

      //Vra die vrae
      @12,nBoxc+21 get aRecv[2,14] pict(aRecv[2,10])
      @13,nBoxc+21 get aRecv[3,14] when(fMass(aRecv)) pict(aRecv[3,10])
      set cursor on
      read
      set cursor off

      //Wat om te doen
      do case
         case lastkey() == K_ESC
            //Escaped
            go bottom
            skip
         case lastkey() == K_ENTER
            //Entered

            //Save
            if aRecv[2,14] == ctod("") .or. aRecv[3,14] <= 0
               //if cLanType() == "A"
               //  fScrBood(23,"Weegdatum en massa is verpligtend!")
               //  fScrWait(24)
               //else
               //  fScrBood(23,"Weighing date and mass are compulsory!")
               //  fScrWait(24)
               //endif
               nReko := recno()

               //Volgende
               select WEEG
               skip
               aRecv[3,14] := 0
               keyboard chr(K_ENTER)
               loop
            else
               select SM3WEEG
               seek WEEG->idnr+dtos(aRecv[2,14])
               if eof()
                  dbappend()
               endif
               do while !rlock()
               enddo
               SM3WEEG->idnr := WEEG->idnr
               SM3WEEG->weegdatum := aRecv[2,14]
               SM3WEEG->massa := aRecv[3,14]
               nReko := recno()

               //Volgende
               select WEEG
               skip
               aRecv[3,14] := 0
               keyboard chr(K_ENTER)
            endif
         case lastkey() == K_PGUP
            //Up page
            skip -1
            if bof()
               go top
            endif
            aRecv[3,14] := 0
            keyboard chr(K_ENTER)

      endcase

   enddo

   //Herstel
   fTClose(cWeeg)
   fTClose(cCdbf)
   goto nReko
   restscreen(0,0,24,79,cCscr)
return NIL

//***************************************************************************/
STATIC FUNCTION fMass(aRecv)

   //Funksie om te toets of massa reeds geneem is

   select SM3WEEG
   seek WEEG->idnr+dtos(aRecv[2,14])
   if found()
      aRecv[3,14] := SM3WEEG->massa
   endif
   select WEEG
return .t.

/******************************************************************************/
STATIC FUNCTION fDiskBrer

   // Program to create diskettes with performance data for Breedplan
   // Breedplan data collection formats Version 4.1 dated 16 march 2000
   // Marcus O'Sullivan Bloemfontein Brahman December 2001

   // Declare
   local lRetu := .t.
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
   local cDreg := ""
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
         cFile := cDriv+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Prestasielˆer word voorberei")
      else
         fScrWbood(maxrow(),"Performance file being prepared")
      endif

      // Open additional data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      //aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG")
      //if !aCdbf[len(aCdbf),1]
      //   break
      //endif
      select SM3WEEG
      set relation to idnr into sm3data
      go top

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
      select SM3WEEG
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

         // Test if there is data
         if val(SM3DATA->reknr) < 1
            // Next
            select SM3WEEG
            skip
            loop
         endif

         // Toets vir die kuddekenmerk
         //if alltrim(substr(cTotNaam(),125,4)) $ SM3DATA->idnr
         //else
         //   // Next
         //   select SM3WEEG
         //   skip
         //   loop
         //endif

         // Tydelik
         //if SM3WEEG->weegdatum == SM3DATA->eindat .and. SM3WEEG->massa == SM3DATA->einmas
         //else
         //   select SM3WEEG
         //   skip
         //   loop
         //endif

         /*********************************************************************/
         // The actual write of the animal itself
         ?? "K"                                  // Always K
         ?? padr(ltrim(str(val(alltrim(substr(cTotNaam(),152,10))))),7) // Soc ident of herd

         // ?? padr(ltrim(str(val(SM3DATA->reknr))),19) // Computer number
         // 02-04-23 09:16 Changed to idnr by Paul Lubout

         // Calf tattoo
         if substr(cTotNaam(),149,3) == "298"
            // Breedplan special no id number conversion
            ?? padr(SM3DATA->idnr,19)
         else
            // Breedplan normal
            ?? padr(fId(SM3DATA->idnr,.f.),19)   // Id number
         endif

         ?? "K"                                  // Kilograms
         ?? space(1)                             // Further test
         ?? space(1)                             // Disposal code

         set cent on
         ??  strtran(dtoc(SM3WEEG->weegdatum),"/","") // Weighing date
         set cent off

         ?? padl(ltrim(str(SM3WEEG->massa)),4,"0") //Mass

         ?? "SMR"

         ?? space(1)                             // Desexed

         // Hoogte
         if SM3WEEG->weegdatum == SM3DATA->eindat .and. SM3WEEG->massa == SM3DATA->einmas .and. !empty(SM3DATA->mateskouer)
            if SM3DATA->mateskouer > 50 .and. SM3DATA->mateskouer <= 9999
               ?? padr(ltrim(str(SM3DATA->mateskouer)),4," ") // Hoogte
            else
               ?? space(4)                       // Scrotum circ
            endif
         else
            ?? space(4)                          // Scrotum circ
         endif

         // Skrotum
         if SM3WEEG->weegdatum == SM3DATA->eindat .and. SM3WEEG->massa == SM3DATA->einmas .and. !empty(SM3DATA->mateskrot)
            if SM3DATA->mateskrot > 50 .and. SM3DATA->mateskrot <= 999
               ?? padr(ltrim(str(SM3DATA->mateskrot)),3," ") // Scrotum
            else
               ?? space(3)                       // Scrotum circ
            endif
         else
            ?? space(3)                          // Scrotum circ
         endif

         ?? space(2)                             // Serving capacity
         ?? space(2)                             // Number of serves

         // Analysis indicator
         if SM3WEEG->weegdatum == SM3DATA->begdatum .and. SM3WEEG->massa == SM3DATA->begmassa
            ?? "E"
         elseif SM3WEEG->weegdatum == SM3DATA->eindat .and. SM3WEEG->massa == SM3DATA->einmas
            ?? "S"
            //elseif SM3WEEG->weegdatum - SM3DATA->gebdatum > 30 .and. SM3WEEG->weegdatum - SM3DATA->gebdatum < 300
            //   ?? "Y"
         else
            ?? " "
         endif


         // Fill up
         ?? space(128)

         // Carriage return etc
         ?

         // Next
         select SM3WEEG
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Prestasielˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Performance file was not created!")
         endif
      else

         // Display note on the screen
         if cLanType() == "A"
            nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
            if left(cFile,1) $ "AB"
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
            else
               // File
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is in die"
               @12, nBoxc say cMailTar()+" subgids op die"
               @13, nBoxc say "hardeskyf geskryf!"
               @14, nBoxc say "Heg asseblief hierdie lˆer aan 'n epos boodskap"
               @15, nBoxc say "gerig aan die betrokke Registrerende Owerheid."
            endif
            fScrBood(maxrow()-1,"Prestasielˆer is suksesvol geskep!")
         else
            nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
            if left(cFile,1) $ "AB"
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
            else
               // File
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created in the"
               @12, nBoxc say cMailTar()+" subdirectory of the"
               @13, nBoxc say "hard disk!"
               @14, nBoxc say "Attach this file to an email message addressed"
               @15, nBoxc say "to the relative Registering Authority."
            endif
            fScrBood(maxrow()-1,"Performance data file was succesfully created!")
         endif

      endif

      fScrWait(maxrow())

   end
   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
