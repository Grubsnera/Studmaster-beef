//SM3VELD.PRG
//Program om velde te vertoon en te kies
//Kopiereg (c) 1991 A van Rensburg
//15:03 24 Mar,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3veld( nTopp, nLeft, nBott, nReko )

   //Veranderlikes
   local cCurDbf := fTOpen()                     //Bewaar huidige dbf waardes
   local cCurScr := fCurScreen()                 //Huidige skerm besonderhede
   local cCurSke := savescreen( 0, 0, 24, 79 )
   local nRigh   := 76
   local nBoxCoo := 0                            //Waarde van venster
   local cBrowse
   local aColumn := {}
   local i       := 1
   local lMore   := .t.
   local nKey    := 1
   local cRetu   := space(71)
   local cLocate := ""
   local cLocScr := ""
   local getlist := {}

   //Waardes
   nTopp := if( nTopp==NIL, 8, nTopp )
   nLeft := if( nLeft==NIL,40, nLeft )
   nBott := if( nBott==NIL,20, nBott )
   nReko := if( nReko==NIL, 1, nReko )
   nRigh := nLeft + 26

   //Open dryfleer
   do while lMore
      dbUseArea( .t., , "stdveld.tdb", "stdveld", .t., .f. )
      if neterr()
         if cLanType() == "A"
            fScrBood(23,"Netwerkfout! - Velde.            ")
            fScrBood(24,"[Esc]=Terug  [Enter]=Probeer weer")
         else
            fScrBood(23,"Network error! - Fields.     ")
            fScrBood(24,"[Esc]=Return  [Enter]=Retry")
         endif
         inkey(0)
         if lastkey() == K_ESC
            setcolor( cColBegi() )
            clear screen
            set curs on
            quit
         endif
      else
         exit
      endif
   enddo

   //Vind die laaste roete
   if nReko > 0
      goto nReko
   endif

   //Vertoon die beskikbare drywe
   if cLanType() == "A"
      fScrBood( 23, "[PgDn]=Nog velde  [PgUp]=Nog velde  [A - Z]=Vind  [Alt V]=Vind verder" )
      fScrBood( 24, "Kies veld met " + D_DNARR + D_UPARR + " sleutels en druk " + D_ENTER )
      fBox( nTopp, nLeft, nBott, nRigh, "Velde om van te kies", cColMenu() )
   else
      fScrBood( 23, "[PgDn]=More fields  [PgUp]=More fields  [A - Z]=Find  [Alt V]=Find more")
      fScrBood( 24, "Choose field with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER )
      fBox( nTopp, nLeft, nBott, nRigh, "Fields to choose from", cColMenu() )
   endif
   setcolor(cColMenu())

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTopp+1, nLeft+2, nBott-1, nRigh-2 )

   //Definieer kolomme
   if cLanType() == "A"
      aadd( aColumn, TBColumnNew( , {|| stdveld->fldbesk } ) )
   else
      aadd( aColumn, TBColumnNew( , {|| stdveld->flddesc } ) )
   endif

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

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
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means leave and update drive variable
         if stdveld->dbfname <> space(8)
            if cLanType() == "A"
               cRetu := stdveld->fldbesk + ;
                  padr( stdveld->dbfname, 10 ) + ;
                  stdveld->fldname + ;
                  stdveld->fldtype + ;
                  str(stdveld->fldleng,3,0) + ;
                  str(stdveld->flddeci,3,0) + ;
                  str( recno(), 4, 0 )
            else
               cRetu := stdveld->flddesc + ;
                  padr( stdveld->dbfname, 10 ) + ;
                  stdveld->fldname + ;
                  stdveld->fldtype + ;
                  str(stdveld->fldleng,3,0) + ;
                  str(stdveld->flddeci,3,0) + ;
                  str( recno(), 4, 0 )
            endif
            lMore := .f.
         endif

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         //Means locate a record
         cLocate := upper( chr( nKey ) ) + space(19)
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik 'n gedeelte van die veld waarna gesoek word.")
         else
            fScrBood(24,"Type a part of the field that should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoo := fBoxCent( 11, "Vind watter veld? xxxxxxxxxxxxxxxxxxxx", 3 )
            @12, nBoxCoo say "Vind watter veld?" get cLocate pict "@!"
         else
            nBoxCoo := fBoxCent( 11, "Find what field? xxxxxxxxxxxxxxxxxxxx", 3 )
            @12, nBoxCoo say "Find what field?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            if cLanType() == "A"
               locate for trim(cLocate) $ upper(STDVELD->fldbesk)
               if eof()
                  go top
                  fScrBood(23,"Veld onbekend!")
                  fScrWait(24)
               endif
            else
               locate for trim(cLocate) $ upper(STDVELD->flddesc)
               if eof()
                  go top
                  fScrBood(23,"Field unknown!")
                  fScrWait(24)
               endif
            endif
            cBrowse:refreshall()
         endif

      elseif nKey >= K_ALT_V
         //Means continue locate
         if len(trim(cLocate)) > 0
            continue
            if cLanType() == "A"
               if eof()
                  go top
                  fScrBood(23,"Veld onbekend!")
                  fScrWait(24)
               endif
            else
               if eof()
                  go top
                  fScrBood(23,"Field unknown!")
                  fScrWait(24)
               endif
            endif
            cBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   dbCloseArea()
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )

return cRetu

