//SM3NOTE.PRG
//Program om diernotas te vertoon
//Kopiereg (c) 1993 A van Rensburg
//07-11-93 08:05am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "memoedit.ch"

//****************************************************************************/
FUNCTION sm3note( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local aCscr    := {}
   local cCdbf := fTOpen()
   local cHoof := ""
   local cNote := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(12)
   local cText := ""

   private cData := ""
   private cHead := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   aCscr := fASaveScr()

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3note","idnr"})
      aadd(aSend,{"sm3data","geslag"})
      aadd(aSend,{"sm3data","gebdatum"})
      aadd(aSend,{"sm3data","idvaar"})
      aadd(aSend,{"sm3data","idmoer"})
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
   if left(cData,1) == "f"
      fTClose(cCdbf)
      return cRetu
   endif
   cNote := fTOpen(cDd(),"sm3note")
   if left(cNote,1) == "f"
      fTClose(cHoof)
      fTClose(cCdbf)
      return cRetu
   endif
   set relation to sm3note->IDNR into SM3DATA

   //Skakel ou leers om
   if file(cDd()+"sm3nota.dbf") .and. file(cDd()+"sm3nota.dbt")

      //Skerm
      fScrBood(23)
      if cLanType() =="A"
         fScrBood(24,"Diernotas word omgeskakel")
      else
         fScrBood(24,"Animal notes being converted")
      endif
      fBox(3,2,maxrow()-4,maxcol()-3,,cColNorm())

      //Open die notas leer
      v_files(1)
      v_use(cDd()+"sm3notd.dbf")

      //Open hierdie leer
      dbusearea(.t.,,cDd()+"sm3nota")

      do while !eof()

         //Nuwe
         cText := ""
         set cons off
         keyboard chr(K_ESC)
         cText := memoedit(SM3NOTA->nota,4,3,maxrow()-5,maxcol()-4,.f.)
         set cons on

         //Bewaar in die nuwe leer
         if len(trim(cText)) > 0
            fScrBood(23,SM3NOTA->idnr)
            select SM3NOTE
            seek SM3NOTA->idnr
            if eof()
               append blank
               do while !rlock()
               enddo
               SM3NOTE->idnr := SM3NOTA->idnr
               SM3NOTE->note := v_replace(cText,SM3NOTE->note)
            endif
         endif

         //Volgende
         select SM3NOTA
         skip

      enddo

      //Sluit leer
      v_closeall()
      select SM3NOTA
      dbclosearea()
      select SM3NOTE
      go top

      ferase(cDd()+"sm3nota.dbf")
      ferase(cDd()+"sm3nota.dbt")

      //Skerm
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif
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
      fBox( nTop, nLeft, nBott, nRigh, "DIERNOTAS" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "ANIMAL NOTES" )
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
         fScrBood( 23, "Menu   Sleutel  Nuwe   Nota     Druk     Skrap  Vind   Hulp" )
         fScrBood( 24, "[Esc]  [Space]  [Ins]  [Alt N]  [Alt P]  [Del]  [A-Z]  [F1]" )
      else
         fScrBood( 23, "Menu   Keys     New    Note     Print    Delete  Find   Help" )
         fScrBood( 24, "[Esc]  [Space]  [Ins]  [Alt N]  [Alt P]  [Del]   [A-Z]  [F1]" )
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

      elseif nKeyp == K_SPACE
         //Space means display menu
         fKeys()

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         if fIdnr()
            bBrow:refreshall()
            keyboard chr(K_CTRL_N)
         endif

      elseif nKeyp == K_ALT_N .or. nKeyp == K_CTRL_N
         //Nota
         fNote(SM3NOTE->idnr)

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
         do help with "sm3note",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   fARestScr(aCscr)
   select SM3NOTE
   set relation to
   fTClose(cNote)
   fTClose(cHoof)
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
      aadd(aMenu,{"","B - Nuwe nota          [ Ins ]",trim("Bewaar 'n nota vir enige dier.                                              "),0,0})
      aadd(aMenu,{"","C - Skrap 'n nota      [ Del ]",trim("Skrap enige bestaande nota.                                                 "),0,0})
      aadd(aMenu,{"","D - Vertoon 'n nota    [Alt N]",trim("Vertoon enige bestaande nota.                                               "),0,0})
      aadd(aMenu,{"","E - Druk 'n nota       [Alt P]",trim("Druk enige bestaande nota.                                                  "),0,0})
      aadd(aMenu,{"","F - Hierdie menu       [Space]",trim("Vertoon hierdie menu met aktiewe sleutels.                                  "),0,0})
      aadd(aMenu,{"","G - Hulp               [ F1  ]",trim("Vertoon volledige hulpskerm oor die gebruik van notas.                      "),0,0})
      aadd(aMenu,{"","H - Vind 'n dier       [A - Z]",trim("Druk enige alfabetiese sleutel terwyl lys van diere vertoon word.           "),0,0})
      aMenu[1,1] := "Aktiewe sleutels"           //Menu opskrif
   else
      aadd(aMenu,{"","A - Menu               [ Esc ]",trim("Return to the menu.                                                         "),0,0})
      aadd(aMenu,{"","B - New note           [ Ins ]",trim("Enter a note for any animal.                                                "),0,0})
      aadd(aMenu,{"","C - Delete a note      [ Del ]",trim("Delete an existing note.                                                    "),0,0})
      aadd(aMenu,{"","D - Display a note     [Alt N]",trim("Display any existing note.                                                  "),0,0})
      aadd(aMenu,{"","E - Print a note       [Alt P]",trim("Print any existing note.                                                    "),0,0})
      aadd(aMenu,{"","F - This menu          [Space]",trim("Display this menu with active keys.                                         "),0,0})
      aadd(aMenu,{"","G - Help               [ F1  ]",trim("Display the notes help screen.                                              "),0,0})
      aadd(aMenu,{"","H - Find an animal     [A - Z]",trim("Press any alphabetic key while list of animals is displayed.                "),0,0})
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
         //Skrap
         keyboard chr(K_DEL)
      case nKeus == 4
         //Vertoon
         keyboard chr(K_CTRL_N)
      case nKeus == 5
         //Druk
         keyboard chr(K_CTRL_P)
      case nKeus == 6
         //Hierdie menu
         keyboard chr(K_SPACE)
      case nKeus == 7
         //Hulp
         keyboard chr(K_F1)
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return NIL

//*************************************************************************/
STATIC FUNCTION fDelete(aRecv)


   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde diernota geskrap word?"
   else
      cBood := "Should above-mentioned animal note be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )


      do while !rlock()
      enddo

      if len(trim(SM3NOTE->note)) == 0
         //Vee nota uit
         v_files(1)
         v_use(cDd()+"sm3notd.dbf")
         SM3NOTE->note := v_delete(SM3NOTE->note)
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

//***************************************************************************/
STATIC FUNCTION fIdnr

   //Funksie om id nommer te vra

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local nBoxc := 0
   local cData := space(12)
   local oCols := NIL
   local cKeyp := space(12)

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
         select SM3NOTE
         set relation to sm3note->IDNR into SM3DATA
      case left(cData, 3 ) == "NOT"
         select SM3NOTE
         set relation to sm3note->IDNR into SM3DATA
      otherwise
         select SM3NOTE
         seek cData
         if eof()
            append blank
            do while !rlock()
            enddo
            SM3NOTE->idnr := cData
         endif
         set relation to sm3note->IDNR into SM3DATA
         lRetu := .t.
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/***************************************************************************/
STATIC FUNCTION fNote(cIdnr)

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cCskr := fCurScreen()
   local cCcur := set(_SET_CURSOR,.t.)
   local cText := ""

   //Stel Funksiesleutels
   set func 10 to chr(23)                        //Save and exit

   //Open leer
   v_files(1)
   v_use(cDd()+"sm3notd.dbf")

   //Skerm
   if cLanType() == "A"
      fScrBood(23,"Bewaar  Exit   Sleutels  Druk     [PgDn]  " + D_DNARR )
      fScrBood(24,"[F10]   [Esc]  [Alt M]   [Alt P]  [PgUp]  " + D_UPARR )
      fBox(3,2,maxrow()-4,maxcol()-3,"NOTA VIR "+trim(cIdnr),cColNorm())
   else
      fScrBood(23,"Save   Exit   Keys      Print    [PgDn]  " + D_DNARR )
      fScrBood(24,"[F10]  [Esc]  [Alt M]   [Alt P]  [PgUp]  " + D_UPARR )
      fBox(3,2,maxrow()-4,maxcol()-3,"NOTE FOR "+trim(cIdnr),cColNorm())
   endif

   //Vertoon nota
   cText := v_retrieve(SM3NOTE->note)
   showkey("I",3,(maxcol()/2)-5,"  Insert   "," Overwrite ",cColHead())
   setcursor(1)
   cText := memoedit(cText,4,3,maxrow()-5,maxcol()-4,.t.,"NoteUDF")
   setcursor(0)
   showkey()
   setcolor(cColNorm())
   do while !rlock()
   enddo
   SM3NOTE->note := v_replace(cText,SM3NOTE->note)

   //Herstel
   v_closeall()
   set(_SET_CURSOR,cCcur)
   fSetScreen(cCskr)
   restscreen(0,0,24,79,cCscr)
return NIL

/***************************************************************************/
FUNCTION NoteUDF( nMode, nLine, nCol )

   //Verklaar
   local cCscr := ""
   local nKeyp := LASTKEY()
   local nRetv := ME_DEFAULT                     // Default return action

   do case
      case nMode == ME_IDLE
         //fScrBood(24,"MemoMode is ME_IDLE  ")
         setcolor(cColHead())
         if cLanType() == "A"
            @3,maxcol()-16 say " Kolom:"+str(nCol+1,4)+" "
            @3,maxcol()-27 say " Ry:"+str(nLine,4)+" "
         else
            @3,maxcol()-17 say " Column:"+str(nCol+1,4)+" "
            @3,maxcol()-29 say " Row:"+str(nLine,4)+" "
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
         //cCscr := savescreen(0,0,24,79)
         do case
            case nKeyp == K_ESC
               if cLanType() == "A"
                  if fJaNee(24,"Moet veranderings aan die nota bewaar word?",,.t. )
                     nRetv := ME_IGNORE
                     keyboard chr(K_CTRL_W)
                  endif
               else
                  if fJaNee(24,"Should changes to the note be saved?",,.t. )
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
      aadd(aMenu,{"","A - Bewaar nota       [   F10   ]",trim("Bewaar die nota van die dier.                                               "),0,0})
      aadd(aMenu,{"","B - Skrap veranderings[   Esc   ]",trim("Skrap enige veranderings aan die nota.                                      "),0,0})
      aadd(aMenu,{"","C - Druk nota         [  Alt P  ]",trim("Bewaar en druk die nota vir die huidige dier.                               "),0,0})
      aadd(aMenu,{"","D - Hierdie menu      [  Alt M  ]",trim("Vertoon hierdie menu met aktiewe sleutels.                                  "),0,0})
      aadd(aMenu,{"","E - Begin van lyn     [  Home   ]",trim("Gaan na die begin van die huidige lyn.                                      "),0,0})
      aadd(aMenu,{"","F - Einde van lyn     [   End   ]",trim("Gaan na die einde van die huidige lyn.                                      "),0,0})
      aadd(aMenu,{"","G - Begin van venster [Ctrl Home]",trim("Gaan na die begin van die huidige venster.                                  "),0,0})
      aadd(aMenu,{"","H - Einde van venster [Ctrl End ]",trim("Gaan na die einde van die huidige venster.                                  "),0,0})
      aadd(aMenu,{"","I - Vorige venster    [  PgUp   ]",trim("Gaan na die vorige venster.                                                 "),0,0})
      aadd(aMenu,{"","J - Volgende venster  [  PgDn   ]",trim("Gaan na die volgende venster.                                               "),0,0})
      aadd(aMenu,{"","K - Begin van nota    [Ctrl PgUp]",trim("Gaan na die begin van die nota.                                             "),0,0})
      aadd(aMenu,{"","L - Einde van nota    [Ctrl PgDn]",trim("Gaan na die einde van die nota.                                             "),0,0})
      aadd(aMenu,{"","M - Skrap lyn         [ Ctrl Y  ]",trim("Skrap die huidige lyn.                                                      "),0,0})
      aadd(aMenu,{"","N - Skrap woord regs  [ Ctrl T  ]",trim("Skrap die woord aan die regterkant.                                         "),0,0})
      aMenu[1,1] := "Aktiewe sleutels"           //Menu opskrif
   else
      aadd(aMenu,{"","A - Enter note        [   F10   ]",trim("Enter a note for the animal.                                          "),0,0})
      aadd(aMenu,{"","B - Delete changes    [   Esc   ]",trim("Delete any changes to the note.                                       "),0,0})
      aadd(aMenu,{"","C - Print note        [  Alt P  ]",trim("Enter and print the note for the current animal.                      "),0,0})
      aadd(aMenu,{"","D - This menu         [  Alt M  ]",trim("Display this menu with the active keys.                               "),0,0})
      aadd(aMenu,{"","E - Start of line     [  Home   ]",trim("Go to the beginning of the current line.                                  "),0,0})
      aadd(aMenu,{"","F - End of line       [   End   ]",trim("Go to the end of the current line.                                    "),0,0})
      aadd(aMenu,{"","G - Start of window   [Ctrl Home]",trim("Go to the beginning of the current window.                                "),0,0})
      aadd(aMenu,{"","H - End of window     [Ctrl End ]",trim("Go to the end of the current window.                                  "),0,0})
      aadd(aMenu,{"","I - Previous window   [  PgUp   ]",trim("Go to the previous window.                                            "),0,0})
      aadd(aMenu,{"","J - Next window       [  PgDn   ]",trim("Go to the next window.                                                "),0,0})
      aadd(aMenu,{"","K - Start of note     [Ctrl PgUp]",trim("Go to the beginning of the note.                                          "),0,0})
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
   local cText := ""
   local nLinc := 0
   local nLine := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   //Kyk of daar iets is om te druk
   if len(trim(SM3NOTE->note)) == 0
      //Niks om te druk
      if cLanType() == "A"
         fScrBood(23,"Daar is niks om te druk!")
      else
         fScrBood(23,"Nothing was found for printing!")
      endif
      fScrWait(24)
      return NIL
   endif

   //Kyk of drukker aan is
   if fPrnReady(23) == K_ESC
      return NIL
   endif

   // Normal Print
   cPcod := cPrnNorm()
   nWidt := nPrnWidt()
   nTopl := nPrnLine()
   nPrnl := nPrnPrnl()
   nPagl := nPrnLeng()
   nMidc := nWidt - 29

   //Skerm
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Stop drukker")
      fScrBood(24,"Nota vir "+trim(SM3NOTE->idnr)+" word gedruk!")
   else
      fScrBood(23,"[Esc]=Stop printer")
      fScrBood(24,"Note for "+trim(SM3NOTE->idnr)+" being printed!")
   endif

   //Open die leer en lees die data
   v_files(1)
   v_use(cDd()+"sm3notd.dbf")
   cText := v_retrieve(SM3NOTE->note)
   v_closeall()

   //Kry die aantal lyne
   nLinc = mlcount(cText,72)

   //Skakel drukker aan
   fPrnOn()
   fPrnCod( cPcod )

   //Doen die loop
   for nLine := 1 to nLinc

      if prow() == 0
	      //Opskrif
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
         	cHdln := "Nota vir " + ALLTRIM(SM3NOTE->idnr)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
            @prow()+1, 1 say repl("=",nWidt)
			@prow()+1, 1 say ""
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
         	cHdln := "Note for " + ALLTRIM(SM3NOTE->idnr)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
            @prow()+1, 1 say repl("=",nWidt)
			@prow()+1, 1 say ""
         endif
      endif

      //Druk die betrokke lyn
      @prow()+1, 1 say memoline(cText,72,nLine)

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         return NIL
      endif

      if prow() >= nPrnl .or. nLine == nLinc
         //Onderste lyn
         @prow()+2, 1 say repl("=",nWidt)
         @prow()+1, 1 say cAppName()
         fPrnEjec()
         nBlad++

      endif

   next

   //Skakel drukker af
   fPrnCod( cPrnNorm() )
   fPrnOff()

   //Herstel
return NIL

