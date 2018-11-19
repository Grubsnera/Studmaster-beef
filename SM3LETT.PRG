//SM3LETT.PRG
//Program om briewe mee te skryf
//Kopiereg (c) 1993 A van Rensburg
//07-14-93 06:15am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "memoedit.ch"

//****************************************************************************/
FUNCTION sm3lett( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cLett := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(6)
   local cText := ""
   local lFilt := .f.

   private cData := ""
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
      aadd(aSend,{"sm3lett","verwys"})
      aadd(aSend,{"sm3lett","datums"})
      aadd(aSend,{"sm3lett","beskry"})
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
   cLett := fTOpen(cDd(),"sm3lett")
   if left(cLett,1) == "f"
      fTClose(cCdbf)
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
      fBox( nTop, nLeft, nBott, nRigh, "KORRESPONDENSIE")
   else
      fBox( nTop, nLeft, nBott, nRigh, "CORRESPONDENCE")
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
         fScrBood( 23, "Menu   Sleutels  Nuwe   Verander  Nota     Filter   Druk     Invoer   Skrap  Vind " )
         fScrBood( 24, "[Esc]  [Space]   [Ins]  [Alt E ]  [Alt N]  [Alt F]  [Alt P]  [Alt I]  [Del]  [A-Z]" )
      else
         fScrBood( 23, "Menu   Keys     New    Edit     Note     Filter   Print    Import   Delete  Find " )
         fScrBood( 24, "[Esc]  [Space]  [Ins]  [Alt E]  [Alt N]  [Alt F]  [Alt P]  [Alt I]  [Del]   [A-Z]" )
      endif

      // Stabilize the display until it's stable or a key is pressed
      do while (nKeyp := inkey()) == 0 .and. !(bBrow:stabilize)
      enddo
      if bBrow:stable
         nKeyp := inkey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_SPACE
         //Space means display menu
         fKeys()

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         if bBrow:rowpos <> 1
            bBrow:gotop()
            bBrow:refreshcurrent()
            keyboard chr(K_CTRL_PGUP)+chr(K_INS)
            loop
         endif
         go bottom
         skip
         if fAClett(aRecv)
            //keyboard chr(K_CTRL_N)
            bBrow:refreshcurrent()
         endif

      elseif nKeyp == K_ALT_E
         //Insert means add a record to the .dbf
         if fAClett(aRecv)
            //keyboard chr(K_CTRL_N)
            bBrow:refreshcurrent()
         endif

      elseif nKeyp == K_ALT_F .or. nKeyp == K_CTRL_Q
         //Alt F means show only selected letters
         lFilt := fFilter(lFilt)
         go top
         bBrow:refreshall()

      elseif nKeyp == K_ALT_N .or. nKeyp == K_CTRL_N
         //Nota
         fNote(SM3LETT->verwys,SM3LETT->datums,SM3LETT->beskry)

      elseif nKeyp == K_ALT_I .or. nKeyp == K_CTRL_I
         //Nota
         if fImport()
            keyboard chr(K_CTRL_N)
            bBrow:refreshcurrent()
         endif

      elseif nKeyp == K_ALT_P .or. nKeyp == K_CTRL_P
         //Print a note
         fMprint()

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
         do help with "sm3lett",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cLett)
   fTClose(cCdbf)
return cRetu

/**************************************************************************/
STATIC FUNCTION fKeys

   //Funksie om menu te vertoon van aktiewe sleutels

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local aMenu := {}
   local nKeus := 4

   //Waardes
   if cLanType() == "A"
      aadd(aMenu,{"","A - Menu               [ Esc ]",trim("Gaan terug na die menu.                                                     "),0,0})
      aadd(aMenu,{"","B - Nuwe brief         [ Ins ]",trim("Skryf 'n nuwe brief.                                                        "),0,0})
      aadd(aMenu,{"","C - Verander brief     [Alt E]",trim("Verander die verligte brief.                                                "),0,0})
      aadd(aMenu,{"","D - Skrap brief        [ Del ]",trim("Skrap die verligte brief.                                                   "),0,0})
      aadd(aMenu,{"","E - Vertoon brief      [Alt N]",trim("Vertoon die verligte brief.                                                 "),0,0})
      aadd(aMenu,{"","F - Filtreer briewe    [Alt F]",trim("Vertoon slegs briewe wat oor 'n sekere onderwerp handel.                    "),0,0})
      aadd(aMenu,{"","G - Druk brief         [Alt P]",trim("Druk die verligte brief.                                                    "),0,0})
      aadd(aMenu,{"","H - Hierdie menu       [Space]",trim("Vertoon hierdie menu met aktiewe sleutels.                                  "),0,0})
      aadd(aMenu,{"","I - Hulp               [ F1  ]",trim("Vertoon volledige hulpskerm oor die gebruik van notas.                      "),0,0})
      aadd(aMenu,{"","J - Vind brief         [A - Z]",trim("Druk enige alfabetiese sleutel terwyl lys van korrespondensie vertoon word.  "),0,0})
      aadd(aMenu,{"","K - Lees tekslˆer      [Alt I]",trim("Lees 'n tekslˆer in 'n nuwe dokument in.                                    "),0,0})
      aMenu[1,1] := "Aktiewe sleutels"           //Menu opskrif
   else
      aadd(aMenu,{"","A - Menu               [ Esc ]",trim("Return to the menu.                                             "),0,0})
      aadd(aMenu,{"","B - New letter         [ Ins ]",trim("Write a new letter.                                             "),0,0})
      aadd(aMenu,{"","C - Edit letter        [Alt E]",trim("Change the highlighted letter.                                  "),0,0})
      aadd(aMenu,{"","D - Delete letter      [ Del ]",trim("Delete the highlighted letter.                                  "),0,0})
      aadd(aMenu,{"","E - Display letter     [Alt N]",trim("Display the highlighted letter.                                 "),0,0})
      aadd(aMenu,{"","F - Filter letter      [Alt F]",trim("Display letters dealing with a certain subject.                 "),0,0})
      aadd(aMenu,{"","G - Print letter       [Alt P]",trim("Print the highlighted letter.                                   "),0,0})
      aadd(aMenu,{"","H - This menu          [Space]",trim("Display this menu with active keys.                             "),0,0})
      aadd(aMenu,{"","I - Help               [ F1  ]",trim("Display detailed help screen for use of notes.                  "),0,0})
      aadd(aMenu,{"","J - Find letter        [A - Z]",trim("Press any alpha key while list of correspondence is displayed.  "),0,0})
      aadd(aMenu,{"","K - Read text file     [Alt I]",trim("Read a text file into a new document.                           "),0,0})
      aMenu[1,1] := "Active keys"                //Menu opskrif
   endif

   //Bepaal koordinate
   aMenu[1,4] := 12 - int(len(aMenu)/2)          //Menu lyn
   aMenu[1,5] := 39 - int(len(aMenu[1,2])/2)     //Menu kolom

   //Vertoon die menu
   if cLanType() == "A"
      fScrBood(23,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". Druk [Esc] vir diernotas." )
   else
      fScrBood(23,"Choose with "+D_DNARR+D_UPARR+" tests and press "+D_ENTER+". Press [Esc] for animal notes." )
   endif
   nKeus := fNewMenu(nKeus,,,aMenu)

   //Keuses
   do case
      case nKeus == 1
         //Menu
         keyboard chr(K_ESC)
      case nKeus == 2
         //Nuwe nota
         keyboard chr(K_INS)
      case nKeus == 3
         //Verander
         keyboard chr(K_ALT_E)
      case nKeus == 4
         //Skrap
         keyboard chr(K_DEL)
      case nKeus == 5
         //Vertoon
         keyboard chr(K_CTRL_N)
      case nKeus == 6
         //Filtreer
         keyboard chr(K_CTRL_Q)
      case nKeus == 7
         //Druk
         keyboard chr(K_CTRL_P)
      case nKeus == 8
         //Hierdie menu
         keyboard chr(K_SPACE)
      case nKeus == 9
         //Hulp
         keyboard chr(K_F1)
      case nKeus == 11
         //Import
         keyboard chr(K_CTRL_I)
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return NIL

/*************************************************************************/
STATIC FUNCTION fAClett(aRecv)

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
      aadd(aSend,{"sm3lett","verwys"})
      aadd(aSend,{"sm3lett","datums"})
      aadd(aSend,{"sm3lett","beskry"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE BRIEF")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW LETTER")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER BRIEF")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT LETTER")
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
            @nLine+ 1,nBoxc say aRecv[ 1][6] get aRecv[ 1][14] pict aRecv[ 1][10] valid(fVverw(1,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 2,nBoxc say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10]
            @nLine+ 3,nBoxc say aRecv[ 3][6] get aRecv[ 3][14] pict aRecv[ 3][10]
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
                  lReturn := .f.
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
               nLoop := 0                        //nLoop := 1
            else
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen(0,0,24,79,cCurSke)
return lReturn

//******************************************************************************/
STATIC FUNCTION fVverw(nItem,aRecv,nRekord,nLine,nBoxc)

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
                  fScrWait(24,"Brief bestaan reeds!" )
               else
                  fScrWait(24,"Letter already exists!" )
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


//*************************************************************************/
STATIC FUNCTION fDelete(aRecv)


   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1))+" - "+trim(fieldget(3)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde brief geskrap word?"
   else
      cBood := "Should above-mentioned letter be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )

      do while !rlock()
      enddo

      if len(trim(SM3LETT->letter)) == 0
         //Vee nota uit
         v_files(1)
         v_use(cDd()+"sm3letd.dbf")
         SM3LETT->letter := v_delete(SM3LETT->letter)
         v_closeall()
      endif

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

/***************************************************************************/
STATIC FUNCTION fFilter(lFilt)
   //Funksie om databasis te filtreer

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cFilt := space(30)
   local nBoxc := 0
   local lRetu := lFilt
   local getlist := {}

   if lFilt == .t.

      //Skakel filter af
      set filter to
      lRetu := .f.

   else
      //Skakel filter aan

      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(11,space(30),3,"Filtreerwoord")
      else
         nBoxc := fBoxCent(11,space(30),3,"Filter word")
      endif
      @12,nBoxc get cFilt
      setcursor(1)
      read
      setcursor(0)

      do case

         case lastkey() == K_ESC
            //Los net so

         case len(trim(cFilt)) == 0
            //Los net so
            set filter to
            lRetu := .f.

         otherwise
            //Stel filter
            set filter to upper(trim(cFilt)) $ upper(SM3LETT->beskry)
            lRetu := .t.

      endcase

   endif

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/***************************************************************************/
STATIC FUNCTION fNote(cVerw,dDatu,cBesk)

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cCskr := fCurScreen()
   local cCcur := set(_SET_CURSOR,.t.)
   local cText := ""

   //Stel Funksiesleutels
   set func 10 to chr(23)                        //Save and exit

   //Open leer
   v_files(1)
   v_use(cDd()+"sm3letd.dbf")

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
      fScrBood(23,"Bewaar  Skrap  Sleutels  Druk     [PgDn]  " + D_DNARR )
      fScrBood(24,"[F10]   [Esc]  [Alt M]   [Alt P]  [PgUp]  " + D_UPARR )
   else
      fScrOpsk( , "Option "+cOption())
      fScrBood(23,"Save   Delete  Keys      Print    [PgDn]  " + D_DNARR )
      fScrBood(24,"[F10]  [Esc]   [Alt M]   [Alt P]  [PgUp]  " + D_UPARR )
   endif
   fScrWord(3,39-(len(cBesk)/2)," "+cBesk+" ",cColHead())
   fBox(5,2,maxrow()-4,maxcol()-3,cVerw+"  "+dtoc(dDatu),cColNorm())

   //Vertoon nota
   cText := v_retrieve(SM3LETT->letter)
   showkey("I",5,(maxcol()/2)-5,"  Insert   "," Overwrite ",cColHead())
   setcursor(1)
   cText := memoedit(cText,6,3,maxrow()-5,maxcol()-4,.t.,"LettUDF")
   setcursor(0)
   showkey()
   setcolor(cColNorm())
   do while !rlock()
   enddo
   SM3LETT->letter := space(6)
   SM3LETT->letter := v_replace(cText,SM3LETT->letter)

   //Herstel
   v_closeall()
   set(_SET_CURSOR,cCcur)
   fSetScreen(cCskr)
   restscreen(0,0,24,79,cCscr)
return NIL

/***************************************************************************/
FUNCTION LettUDF( nMode, nLine, nCol )

   //Verklaar
   local cCscr := ""
   local nKeyp := LASTKEY()
   local nRetv := ME_DEFAULT                     // Default return action

   do case
      case nMode == ME_IDLE
         //fScrBood(24,"MemoMode is ME_IDLE  ")
         setcolor(cColHead())
         if cLanType() == "A"
            @5,maxcol()-16 say " Kolom:"+str(nCol+1,4)+" "
            @5,maxcol()-27 say " Ry:"+str(nLine,4)+" "
         else
            @5,maxcol()-17 say " Column:"+str(nCol+1,4)+" "
            @5,maxcol()-29 say " Row:"+str(nLine,4)+" "
         endif
         setcolor(cColNorm())
      case nMode == ME_UNKEY
         //fScrBood(24,"MemoMode is ME_UNKEY ")
         //cCscr := savescreen(0,0,24,79)
         do case
            case nKeyp == K_ALT_P .or. nKeyp == K_CTRL_P
               //Druk
               keyboard chr(K_ESC)+chr(K_CTRL_P) //fMemoPrn()
            case nKeyp == K_ALT_M
               //Menu
               fMkeys()
         endcase
         //restscreen(0,0,24,79,cCscr)
      case nMode == ME_UNKEYX
         //fScrBood(24,"MemoMode is ME_UNKEYX")
         //inkey(0)
         //cCscr := savescreen(0,0,24,79)
         do case
            case nKeyp == K_ESC
               if cLanType() == "A"
                  if fJaNee(24,"Moet veranderings aan die brief bewaar word?",,.t. )
                     nRetv := ME_IGNORE
                     keyboard chr(K_CTRL_W)
                  endif
               else
                  if fJaNee(24,"Should changes to letter be saved?",,.t. )
                     nRetv := ME_IGNORE
                     keyboard chr(K_CTRL_W)
                  endif
               endif
            case nKeyp == K_ALT_P .or. nKeyp == K_CTRL_P
               //Druk
               keyboard chr(K_CTRL_W)+chr(K_CTRL_P) //fMemoPrn()
            case nKeyp == K_ALT_M
               //Menu
               fMkeys()
         endcase
         //restscreen(0,0,24,79,cCscr)
      otherwise
         //fScrBood(24,"MemoMode is ME_INIT  ")
   endcase

return nRetv

/**************************************************************************/
STATIC FUNCTION fMKeys

   //Funksie om menu te vertoon van aktiewe sleutels

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local aMenu := {}
   local nKeus := 1

   //Waardes
   if cLanType() == "A"
      aadd(aMenu,{"","A - Bewaar brief      [   F10   ]",trim("Bewaar die brief.                                                           "),0,0})
      aadd(aMenu,{"","B - Skrap veranderings[   Esc   ]",trim("Skrap enige veranderings aan die brief.                                     "),0,0})
      aadd(aMenu,{"","C - Druk brief        [  Alt P  ]",trim("Bewaar en druk die brief.                                                   "),0,0})
      aadd(aMenu,{"","D - Hierdie menu      [  Alt M  ]",trim("Vertoon hierdie menu met aktiewe sleutels.                                  "),0,0})
      aadd(aMenu,{"","E - Begin van lyn     [  Home   ]",trim("Gaan na die begin van die huidige lyn.                                      "),0,0})
      aadd(aMenu,{"","F - Einde van lyn     [   End   ]",trim("Gaan na die einde van die huidige lyn.                                      "),0,0})
      aadd(aMenu,{"","G - Begin van venster [Ctrl Home]",trim("Gaan na die begin van die huidige venster.                                  "),0,0})
      aadd(aMenu,{"","H - Einde van venster [Ctrl End ]",trim("Gaan na die einde van die huidige venster.                                  "),0,0})
      aadd(aMenu,{"","I - Vorige venster    [  PgUp   ]",trim("Gaan na die vorige venster.                                                 "),0,0})
      aadd(aMenu,{"","J - Volgende venster  [  PgDn   ]",trim("Gaan na die volgende venster.                                               "),0,0})
      aadd(aMenu,{"","K - Begin van brief   [Ctrl PgUp]",trim("Gaan na die begin van die brief.                                            "),0,0})
      aadd(aMenu,{"","L - Einde van brief   [Ctrl PgDn]",trim("Gaan na die einde van die brief.                                            "),0,0})
      aadd(aMenu,{"","M - Skrap lyn         [ Ctrl Y  ]",trim("Skrap die huidige lyn.                                                      "),0,0})
      aadd(aMenu,{"","N - Skrap woord regs  [ Ctrl T  ]",trim("Skrap die woord aan die regterkant.                                         "),0,0})
      aMenu[1,1] := "Aktiewe sleutels"           //Menu opskrif
   else
      aadd(aMenu,{"","A - Enter note        [   F10   ]",trim("Enter a note for the animal.                                          "),0,0})
      aadd(aMenu,{"","B - Delete changes    [   Esc   ]",trim("Delete any changes to the note.                                       "),0,0})
      aadd(aMenu,{"","C - Print note        [  Alt P  ]",trim("Enter and print the note for the current animal.                      "),0,0})
      aadd(aMenu,{"","D - This menu         [  Alt M  ]",trim("Display this menu with the active keys.                               "),0,0})
      aadd(aMenu,{"","E - Start of line     [  Home   ]",trim("Go to the beginning of the current line.                              "),0,0})
      aadd(aMenu,{"","F - End of line       [   End   ]",trim("Go to the end of the current line.                                    "),0,0})
      aadd(aMenu,{"","G - Start of window   [Ctrl Home]",trim("Go to the beginning of the current window.                            "),0,0})
      aadd(aMenu,{"","H - End of window     [Ctrl End ]",trim("Go to the end of the current window.                                  "),0,0})
      aadd(aMenu,{"","I - Previous window   [  PgUp   ]",trim("Go to the previous window.                                            "),0,0})
      aadd(aMenu,{"","J - Next window       [  PgDn   ]",trim("Go to the next window.                                                "),0,0})
      aadd(aMenu,{"","K - Start of note     [Ctrl PgUp]",trim("Go to the beginning of the note.                                      "),0,0})
      aadd(aMenu,{"","L - End of note       [Ctrl PgDn]",trim("Go to the end of the note.                                            "),0,0})
      aadd(aMenu,{"","M - Delete line       [ Ctrl Y  ]",trim("Delete the current line.                                              "),0,0})
      aadd(aMenu,{"","N - Delete word right [ Ctrl T  ]",trim("Delete the word on the right.                                         "),0,0})
      aMenu[1,1] := "Active keys"                //Menu opskrif
   endif

   //Bepaal koordinate
   aMenu[1,4] := 12 - int(len(aMenu)/2)          //Menu lyn
   aMenu[1,5] := 39 - int(len(aMenu[1,2])/2)     //Menu kolom

   //Vertoon die menu
   if cLanType() == "A"
      fScrBood(23,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". Druk [Esc] vir nota." )
   else
      fScrBood(23,"Choose with "+D_DNARR+D_UPARR+" tests and press "+D_ENTER+". Press [Esc] for note." )
   endif
   nKeus := fNewMenu(nKeus,,,aMenu)

   //Keuses
   do case
      case nKeus == 1
         //Bewaar
         keyboard chr(K_CTRL_W)
      case nKeus == 2
         //Skrap
         keyboard chr(K_ESC)
      case nKeus == 3
         //Druk
         keyboard chr(K_CTRL_P)
      case nKeus == 4
         //Hierdie menu
         //keyboard chr(K_CTRL_N)
      case nKeus == 5
         //Home
         keyboard chr(K_HOME)
      case nKeus == 6
         //End
         keyboard chr(K_END)
      case nKeus == 7
         //Begin venster
         keyboard chr(K_CTRL_HOME)
      case nKeus == 8
         //Einde venster
         keyboard chr(K_CTRL_END)
      case nKeus == 9
         //Vorige venster
         keyboard chr(K_PGUP)
      case nKeus == 10
         //Volgende venster
         keyboard chr(K_PGDN)
      case nKeus == 11
         //Begin nota
         keyboard chr(K_CTRL_PGUP)
      case nKeus == 12
         //Einde nota
         keyboard chr(K_CTRL_PGDN)
      case nKeus == 13
         //Skrap lyn
         keyboard chr(K_CTRL_Y)
      case nKeus == 14
         //Skrap woord regs
         keyboard chr(K_CTRL_T)
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return NIL

/***************************************************************************/
STATIC FUNCTION fMprint

   //Verklaar
   local cCscr := (0,0,24,79)
   local cText := ""
   local nLinc := 0
   local nLine := 1
   local nBlad := 1
   local nKeus := 0

   //Kyk of daar iets is om te druk
   if len(trim(SM3LETT->letter)) == 0
      //Niks om te druk
      if cLanType() == "A"
         fScrBood(23,"Daar is niks om te druk!")
      else
         fScrBood(23,"Nothing was found for printing!")
      endif
      fScrWait(24)
      return NIL
   endif

   //Vra drukker of teksleer
   if cLanType() == "A"
      nKeus := alert("Skryf na?",{"Drukker","Tekslˆer"})
   else
      nKeus := alert("Write to?",{"Printer","Text file"})
   endif
   restscreen(0,0,24,79,cCscr)
   if nKeus == 0
      return NIL
   endif

   //Kyk of drukker aan is
   if nKeus == 1
      if fPrnReady(23) == K_ESC
         return NIL
      endif
   endif

   //Skerm
   if nKeus == 2
      //Leer
      fScrBood(23)
      if cLanType() == "A"
         fScrBood(24,trim(SM3LETT->verwys)+" tekslˆer word voorberei!")
      else
         fScrBood(24,trim(SM3LETT->verwys)+" text file being prepared!")
      endif
   else
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Stop drukker")
         fScrBood(24,trim(SM3LETT->verwys)+" word gedruk!")
      else
         fScrBood(23,"[Esc]=Stop printer")
         fScrBood(24,trim(SM3LETT->verwys)+" being printed!")
      endif
   endif

   //Open die leer en lees die data
   v_files(1)
   v_use(cDd()+"sm3letd.dbf")
   cText := v_retrieve(SM3LETT->letter)
   v_closeall()

   //Indien teksleer
   if nKeus == 2
      memowrit(cDd()+trim(SM3LETT->verwys)+".txt",cText)
      if cLanType() == "A"
         alert("'n Tekslˆer is voorberei in die;;"+upper(cDd()+trim(SM3LETT->verwys)+".txt")+";; subgids van die hardeskyf!")
      else
         alert("A text file is being prepared in the;;"+upper(cDd()+trim(SM3LETT->verwys)+".txt")+";; subdirectory of the hard disk!")
      endif
      restscreen(0,0,24,79,cCscr)
      return NIL
   endif

   //Kry die aantal lyne
   nLinc = mlcount(cText,72)

   //Skakel drukker aan
   fPrnOn()
   //fPrnCod( cPrnNorm() )

   //Doen die loop
   for nLine := 1 to nLinc

      //Skakel drukker aan

      //Druk die betrokke lyn
      if nLine == 1
         @prow()  , 1 say memoline(cText,72,nLine)
      else
         @prow()+1, 1 say memoline(cText,72,nLine)
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         restscreen(0,0,24,79,cCscr)
         return NIL
      endif

      if prow() >= nPrnLeng()-6 .or. nLine == nLinc

         if cLanType() == "A"
            @prow()+(nPrnLeng()-4-prow()),39-4 say "Bladsy " + ltrim(str(nBlad))
         else
            @prow()+(nPrnLeng()-4-prow()),39-4 say "Page " + ltrim(str(nBlad))
         endif

         fPrnEjec()

         //Bladsy
         nBlad++

      endif

   next

   //Skakel drukker af
   //fPrnCod( cPrnNorm() )
   fPrnOff()

   //Herstel
   restscreen(0,0,24,79,cCscr)
return NIL

/***************************************************************************/
STATIC FUNCTION fImport
   //Funksie om teksleer te lees

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local nBoxc := 0
   local cFile := space(30)
   local lLoop := .t.
   local cText := ""
   local getlist := {}

   //Daar moenie reeds teks wees
   if len(trim(SM3LETT->letter)) > 0
      if cLanType() == "A"
         fScrBood(23,"Daar bestaan reeds teks vir hierdie brief!")
      else
         fScrBood(23,"Text already exists for this letter!")
      endif
      fScrWait(24)
      return .f.
   endif

   //Skerm
   if cFile == space(30)
      keyboard cDd()
   endif
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(30),3,"Lˆernaam?")
   else
      nBoxc := fBoxCent(11,space(30),3,"File name?")
   endif

   //Vra die leernaam
   lLoop := .t.
   do while lLoop
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Briewe")
         fScrBood(24,"Tik die naam van die tekslˆer wat gelees moet word!")
      else
         fScrBood(23,"[Esc]=Letters")
         fScrBood(24,"Type the name of the text file that should be read!")
      endif
      @12,nBoxc get cFile pict "@!"
      set cursor on
      read
      set cursor off
      if lastkey() == K_ESC
         exit
      endif
      if cFile == Space(30)
         exit
      endif
      if file(trim(cFile))
         lLoop := .f.
      else
         if cLanType() == "A"
            fScrBood(23,"Lˆernaam is onbekend!")
         else
            fScrBood(23,"File name is unknown!")
         endif
         fScrWait(24)
      endif
   enddo
   if lLoop
      restscreen(0,0,24,79,cCscr)
      return .f.
   endif

   //Lees die leer
   cText := memoread(trim(cFile))

   //Bewaar in databasis
   v_files(1)
   v_use(cDd()+"sm3letd.dbf")
   do while !rlock()
   enddo
   SM3LETT->letter := v_replace(cText,SM3LETT->letter)
   v_closeall()

   //Herstel
   restscreen(0,0,24,79,cCscr)
return .t.

