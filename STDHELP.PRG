//STDHELP.PRG
//Program om hulpskerms te vertoon
//Kopiereg (c) 1991 A van Rensburg
//03:50 03 Sep,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
PROCEDURE help( cProg, nLine, cVariable )

   //Veranderlikes
   local cCurDbf := fTOpen()
   local cCurScr := fCurScreen()
   local cCurSke := savescreen( 0, 0, 24, 79 )
   local cCurCur := set( _SET_CURSOR, .f. )
   local getlist := {}
   local aVelde := {}
   local cHelpStat
   local cHandStat
   local fHelp   := "fPrnHelp"
   local cBood   := ""
   local nBoxCoor := 0

   private cText   := ""

   //Waardes
   cProg := upper( padr( cProg, 10) )
   cVariable := upper( padr( cVariable, 30 ) )
   v_files(1)

   //Open die data
   cHelpStat := fTOpen( , "stdhelp", , "tdb", , .t., .f. )
   if left( cHelpStat, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return
   endif

   //Open die help text leer
   cHandStat := fTOpen( , "stdhand", , "tdb", , .t., .f. )
   if left( cHandStat, 1 ) == "f"
      fTClose( cHelpStat )
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return
   endif

   //Skerm
   fScrBood(23)
   fScrBood(24)

   //Open die hulpleer
   if cLanType() == "A"
      v_use("stdhulp")
   else
      v_use("stdhelp")
   endif

   //Selekteer die hulpleer
   select stdhelp

   //Stel Funksiesleutels
   set func 10 to chr(23)                        //Save and exit

   //Soek vir hulp
   seek cProg + cVariable

   if eof()
      //Hulp nie gevind
      if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
         //Vir eie gebruik
         if fJaNee( 24, if(cLanType()=="A","Moet hulp bygevoeg word?","Should help be added?"))
            asize( aVelde, 0 )
            if cLanType() == "A"
               aadd( aVelde, { "stdhand", "numb" })
               aadd( aVelde, { "stdhand", "besk" })
            else
               aadd( aVelde, { "stdhand", "numb" })
               aadd( aVelde, { "stdhand", "desc" })
            endif
            append blank
            if rlock()
               stdhelp->prog := cProg
               stdhelp->vari := cVariable
               stdhelp->numb := fStdHand( 3, 4, 20, aVelde )
            endif
            if stdhelp->numb <= 0
               //Verwyder hulpskerm
               if rlock()
                  delete
               endif
            else
               //Skryf hulp
               select STDHAND
               goto stdhelp->numb
               //Edit - Teken skerm
               if cLanType() == "A"
                  fScrBood(23,"[Esc]=Exit                  [PgUp]  " + D_UPARR )
                  fScrBood(24,"[F10]=Bewaar  [Alt P]=Druk  [PgDn]  " + D_DNARR )
                  fBox( 3, 39, 20, 75, "HULP - " + trim(stdHand->besk), cColHelp() )
               else
                  fScrBood(23,"[Esc]=Exit                 [PgUp]  " + D_UPARR )
                  fScrBood(24,"[F10]=Save  [Alt P]=Print  [PgDn]  " + D_DNARR )
                  fBox( 3, 39, 20, 75, "HELP - " + trim(stdHand->desc), cColHelp() )
               endif
               set cursor on
               if rlock()
                  if cLanType() == "A"
                     cText := v_retrieve(STDHAND->teks)
                     cText := memoedit(cText,4,41,19,72,.t.,fHelp)
                     STDHAND->teks := v_replace(cText,STDHAND->teks)
                  else
                     cText := v_retrieve(STDHAND->text)
                     cText := memoedit(cText,4,41,19,72,.t.,fHelp)
                     STDHAND->text := v_replace(cText,STDHAND->text)
                  endif
                  dbUnlock()
               endif
               set cursor off
               //herstel
               select stdhelp
            endif
         endif
      else
         //Hulp nie beskikbaar
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "   Geen hulp beskikbaar!   ", 3,, cColHelp() )
            fScrWord( 13, nBoxCoor, "   Geen hulp beskikbaar!", cColHelp() )
         else
            nBoxCoor := fBoxCent( 12, "     No help available!    ", 3,, cColHelp() )
            fScrWord( 13, nBoxCoor, "     No help available!", cColHelp() )
         endif
         fScrBood( 23 )
         fScrWait( 24, , , , 2 )
      endif
   else
      //Hulp gevind
      if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
         //Kry die hulpskerm beskrywing
         select stdHand
         goto stdhelp->numb
         select stdhelp
         //Vir eie gebruik
         asize( aVelde, 0 )
         if cLanType() == "A"
            cBood := "Moet die " + upper(trim(stdHand->besk)) + " hulpskerm verander word?"
            aadd( aVelde, { "stdHand", "numb" })
            aadd( aVelde, { "stdHand", "besk" })
         else
            cBood := "Should the " + upper(trim(stdHand->desc)) + " help screen be changed?"
            aadd( aVelde, { "stdHand", "numb" })
            aadd( aVelde, { "stdHand", "desc" })
         endif
         if fJaNee( 24, cBood )
            //Vertoon venster met bestaande hulp
            if rlock()
               stdhelp->numb := fstdHand( 3, 4, 20, aVelde )
               dbUnlock()
            endif
            if stdhelp->numb <= 0
               //Verwyder hulpskerm
               if rlock()
                  delete
                  dbUnlock()
               endif
            else
               //Skryf hulp
               select stdHand
               goto stdhelp->numb
               //Edit - Teken skerm
               if cLanType() == "A"
                  fScrBood(23,"[Esc]=Exit                  [PgUp]  " + D_UPARR )
                  fScrBood(24,"[F10]=Bewaar  [Alt P]=Druk  [PgDn]  " + D_DNARR )
                  fBox( 3, 39, 20, 75, "HULP - " + trim(stdHand->besk), cColHelp() )
               else
                  fScrBood(23,"[Esc]=Exit                 [PgUp]  " + D_UPARR )
                  fScrBood(24,"[F10]=Save  [Alt P]=Print  [PgDn]  " + D_DNARR )
                  fBox( 3, 39, 20, 75, "HELP - " + trim(stdHand->desc), cColHelp() )
               endif
               set cursor on
               if rlock()
                  if cLanType() == "A"
                     cText := v_retrieve(STDHAND->teks)
                     cText := memoedit(cText,4,41,19,72,.t.,fHelp)
                     STDHAND->teks := v_replace(cText,STDHAND->teks)
                  else
                     cText := v_retrieve(STDHAND->text)
                     cText := memoedit(cText,4,41,19,72,.t.,fHelp)
                     STDHAND->text := v_replace(cText,STDHAND->text)
                  endif
                  dbUnlock()
               endif
               set cursor off
               //herstel
               select stdhelp
            endif
         endif
      else
         //Net vir opkyk doeleindes
         select stdHand
         goto stdhelp->numb
         //Edit - Teken skerm
         if cLanType() == "A"
            fScrBood(23,"[ Esc ]=Klaar  [PgUp]  " + D_UPARR )
            fScrBood(24,"[Alt P]=Druk   [PgDn]  " + D_DNARR )
            fBox( 3, 39, 20, 75, "HULP", cColHelp() )
         else
            fScrBood(23,"[ Esc ]=Exit  [PgUp]  " + D_UPARR )
            fScrBood(24,"[Alt P]=Print [PgDn]  " + D_DNARR )
            fBox( 3, 39, 20, 75, "HELP", cColHelp() )
         endif
         set cursor off
         if rlock()
            if cLanType() == "A"
               cText := v_retrieve(STDHAND->teks)
            else
               cText := v_retrieve(STDHAND->text)
            endif
            cText := memoedit(cText,4,41,19,72,.f.,fHelp)
            dbUnlock()
         endif
         //herstel
         select stdhelp
      endif
   endif

   //Herstel
   v_closeall()
   set( _SET_CURSOR, cCurCur )
   fTClose( cHandStat )
   fTClose( cHelpStat )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
return

/**************************************************************************/
STATIC FUNCTION fStdHand( nTop, nLeft, nBottom, aVelde, nFind )
   //Funksie om bestaande hulpskerm te vertoon

   //Veranderlikes
   local cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   local cCurScr := fCurScreen()                 //Kleure ens
   local cCurDbf := fTOpen()                     //Databasis
   local aHandop := {}                           //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nBoxCoor := 0                           //Waar begin en eindig die box
   local nRight  := 77                           //Regterkantste lyn
   local cBrowse                                 //Browse object
   local aColumn := {}                           //Kolomme array
   local i                                       //Counter
   local lMore                                   //Logical looper
   local nKey                                    //Keypress
   local cResult                                 //Return value
   local lLogic                                  //Diverse logic carrier
   local cHandStat
   local nReturn := 0
   local cScreen
   local getlist := {}

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   nFind := if( nFind == NIL, 0, nFind )

   //Skerm
   fScrOpsk()
   set cursor off

   //Open die nodige leer
   select stdHand

   //Skuif die databasis
   if nFind > 0
      goto nFind
   endif

   //Kry die veldbeskrywings
   //aVelde is die array met velde wat vertoon moet word
   //aHandop is die array met die volledige veldbesonderhede
   aHandop := fGetField( aVelde )

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len( aHandop )

      //Lengte
      nScrLen := nScrLen + aHandop[i,4] + 3

      //Kolomme
      cData := aHandop[i,1] + aHandop[i,2]
      cHead := aHandop[i,7] + ";" + aHandop[i,8] + ";" + aHandop[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 77, 77, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "BESTAANDE HULPSKERMS" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "EXISTING HELP SCREENS" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+2, nBottom-1, nRight-2 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := " ³ "

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   //Skerm
   fScrBood( 23 )
   if cLanType() == "A"
      fScrBood( 24, "[Enter]=Kies  [Esc]=Niks  [Ins]=Open nuwe  [Alt E]=Verander" )
   else
      fScrBood( 24, "[Enter]=Choose  [Esc]=Nil   [Ins]=Open new   [Alt E]=Edit" )
   endif

   // Main loop
   lMore := .T.
   do while lMore

      // Stabilize the display until it's stable or a key is pressed
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
         // Everything's done -- just wait for a key
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         // Esc means leave
         nReturn := 0
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means return plaaskode and exit
         nReturn := stdHand->numb
         lMore := .f.

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         //Skerm
         cScreen := savescreen( 0, 0, 24, 79 )
         cData := space(20)
         if cLanType() == "A"
            fScrBood( 23, "[Esc]=Moenie nuwe hulpskerm oopmaak nie")
            fScrBood( 24, "Tik 'n kort beskrywing van die hulpskerm." )
         else
            fScrBood( 23, "[Esc]=Do not open new help screen" )
            fScrBood( 24, "Type a short description for the help screen." )
         endif
         nBoxCoor := fBoxCent( 11, space(40), 3 )
         lLogic := .t.
         do while lLogic

            @ 12, nBoxCoor say aHandop[2,6] get cData pict aHandop[2,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC
               exit
            endif

            //Beskrywing mag nie niks wees nie
            if cData == space(20)
               loop
            endif

            lLogic := .f.

         enddo
         restscreen( 0, 0, 24, 79, cScreen )
         if lLogic
            loop
         endif
         appe blank
         if rlock()
            stdHand->numb := recno()
            if cLanType() == "A"
               stdHand->besk := cData
            else
               stdHand->desc := cData
            endif
            dbUnlock()
         endif
         nReturn := recno()
         lMore := .f.

      elseif nKey == K_ALT_E
         //Alt E means change a record
         //Skerm
         cScreen := savescreen( 0, 0, 24, 79 )
         if cLanType() == "A"
            cData := stdHand->besk
         else
            cData := stdHand->desc
         endif
         if cLanType() == "A"
            fScrBood( 23, "[Esc]=Moet niks verander nie")
            fScrBood( 24, "Tik 'n kort beskrywing van die hulpskerm." )
         else
            fScrBood( 23, "[Esc]=Do not change anything")
            fScrBood( 24, "Type a short description for the help screen." )
         endif
         nBoxCoor := fBoxCent( 11, space(40), 3 )
         lLogic := .t.
         do while lLogic

            @ 12, nBoxCoor say aHandop[2,6] get cData pict aHandop[2,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC
               exit
            endif

            //Beskrywing mag nie niks wees nie
            if cData == space(20)
               loop
            endif

            lLogic := .f.

         enddo
         restscreen( 0, 0, 24, 79, cScreen )
         if lLogic
            loop
         endif
         if rlock()
            if cLanType() == "A"
               stdHand->besk := cData
            else
               stdHand->desc := cData
            endif
            dbUnlock()
         endif
         cBrowse:refreshcurrent()

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   //Herstel
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )

return nReturn

//***********************************************************************/
FUNCTION fPrnHelp(nMode,nLine,nCol)

   //Verklaar
   local cCurScr := ""
   local nKey    := 0

   //Modes
   do case

      case nMode = 3
         return 0

      case nMode = 0
         return 0

      otherwise
         //Keystroke exception
         cCurScr := savescreen(23,0,24,79)
         nKey = lastkey()
         do case
            case nKey == K_ALT_P
               //Druk die memo
               //Toets of drukker gereed is
               fScrBood(23)
               if fPrnReady() == K_ESC
                  return 0
               endif
               fMemoPrn()
         endcase
         restscreen(23,0,24,79,cCurScr)
         return 0

   endcase

return NIL

//************************************************************************/
FUNCTION fMemoPrn

   //Verklaar
   local nLineCount := 0
   local nCurrLine  := 0
   local cPrintLine := ""
   local nPage      := 1
   local nPrnl      := nPrnPrnl()

   //Skerm
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Stop drukker")
      fScrWbood(24,trim(memoline(cText,65,1))+" hulpskerm word gedruk")
   else
      fScrBood(23,"[Esc]=Stop printer")
      fScrWbood(24,trim(memoline(cText,65,1))+" help screen being printed")
   endif

   //Waardes

   //Get number of formatted lines in memo.
   nLineCount = mlcount(cText, 65)

   //Skakel die drukker aan
   fPrnOn()
   fPrnCod( cPrnNorm() )

   //Walk through the memo one line at a time.
   for nCurrLine = 2 to nLineCount

      //Opskrif
      if prow() == 0
         if cLanType() == "A"
            if nPage == 1
               @ prow()+1, 9 say padr(trim(memoline(cText,65,1)),50) + "     Bladsy: " + str(nPage,2,0)
               @ prow()+1, 9 say repl("=",65)
            else
               @ prow()+1, 9 say padr(trim(memoline(cText,65,1))+" (vervolg)",50) + "     Bladsy: " + str(nPage,2,0)
               @ prow()+1, 9 say repl("=",65)
            endif
         else
            if nPage == 1
               @ prow()+1, 9 say padr(trim(memoline(cText,65,1)),50) + "       Page: " + str(nPage,2,0)
               @ prow()+1, 9 say repl("=",65)
            else
               @ prow()+1, 9 say padr(trim(memoline(cText,65,1))+" (continue)",50) + "       Page: " + str(nPage,2,0)
               @ prow()+1, 9 say repl("=",65)
            endif
         endif
      endif

      //Extract the current line.
      cPrintLine = memoline(cText, 65, nCurrLine)

      //Print the current line.
      @ prow()+1, 9 say cPrintLine

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         return NIL
      endif

      if prow() >= nPrnl .or. nCurrLine == nLineCount
         //Onderste lyn
         @prow()+1,9 say repl("=",65)
         @prow()+1,9 say cAppName()
         fPrnEjec()

         //Bladsy
         nPage++

      endif
   next

   //Skakel drukker af
   fPrnCod( cPrnNorm() )
   fPrnOff()

return NIL

