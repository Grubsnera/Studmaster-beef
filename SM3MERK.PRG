//SM3MERK.PRG
//Program om adrestipes te merk
//Kopiereg (c) 1992 A van Rensburg
//14:44 10 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3merk( nTop, nLeft, nBottom, aVelde, cFind )

   //Hierdie funksie laat mens toe om adrestipes te merk wat verlang word
   //'n leer met adreskodes word dan geskep
   //die leer se naam is ledexxxx.dbf

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := setcursor(0)                 //Cursor
   LOCAL aTipeOp := {}                           //Plaas opskrifte
   LOCAL nScrLen := 0                            //Totale lengte van die velde
   LOCAL nBoxCoo := 0                            //Waar begin en eindig die box
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i       := 0                            //Counter
   LOCAL lMore   := .t.                          //Logical looper
   LOCAL nKey    := 0                            //Keypress
   LOCAL lReturn := .f.                          //Return value
   LOCAL lLogic  := .t.                          //Diverse logic carrier
   LOCAL cLocate := ""
   LOCAL cTipe   := ""
   local nSum    := 0
   local cLocScr := ""
   local nBoxCoor := 0

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 60, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   cFind := if( cFind == NIL, "      ", cFind )

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrBood(24,"Screen outlay being determined")
   endif

   //Kry die veldbeskrywings
   //aVelde is die array met velde wat vertoon moet word
   //aTipeOp is die array met die volledige veldbesonderhede
   aTipeOp := fGetField( aVelde )

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len( aTipeOp )
      //Lengte
      nScrLen := nScrLen + aTipeOp[i,4] + 1
      //Kolomme
      cData := aTipeOp[i,1] + aTipeOp[i,2]
      cHead := aTipeOp[i,7] + ";" + aTipeOp[i,8] + ";" + aTipeOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "MERK ADRESTIPES OM TE VERTOON/DRUK" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "MARK ADDRESS TYPES TO DISPLAY/PRINT" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Datalˆers word geopen")
   else
      fScrBood(24,"Data files being opened")
   endif

   //Open die .dbf
   cTipe := fTOpen( cDd(), "sm3tipe", , "dbf", , .f., .f. )
   if left( cTipe, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif

   //Skuif die databasis
   if len( alltrim( cFind ) ) <> 0
      set soft on
      seek cFind
      set soft off
      if eof()
         go top
      endif
   endif

   // Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu   [+]=Merk        [*]=Merk alle tipes   [Alt S]=Somtotaal gemerk" )
         fScrBood( 24, "[Enter]=Begin  [-]=Skrap merk  [/]=Skrap alle merke  [Alt T]=Tel adresse     " )
      else
         fScrBood( 23, "[ Esc ]=Menu   [+]=Mark        [*]=Mark all types  [Alt S]=Summarise marked" )
         fScrBood( 24, "[Enter]=Start  [-]=Delete mark [/]=Del all marks   [Alt T]=Count addresses " )
      endif

      //Vries
      //cBrowse:freeze := 2

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
         // Enter means return plaaskode and exit
         //create lm2temp.dbf
         if fCreate()
            lReturn := .t.
         endif
         lMore := .f.

      elseif nKey == K_PLUS
         //Plus means mark an address type
         SM3TIPE->merk := chr(251)
         cBrowse:refreshCurrent()

      elseif nKey == K_MINUS
         //Plus means unmark an address type
         SM3TIPE->merk := " "
         cBrowse:refreshCurrent()

      elseif nKey == K_MULTIPLY
         //Plus means mark all address types
         replace all SM3TIPE->merk with chr(251)
         go top
         cBrowse:refreshAll()

      elseif nKey == K_DIVIDE
         //Plus means unmark all address types
         replace all SM3TIPE->merk with " "
         go top
         cBrowse:refreshAll()

      elseif nKey == K_ALT_T
         //Alt T means count adresses
         fTel()
         cBrowse:refreshall()

      elseif nKey == K_ALT_S
         //Alt S means count adresses
         go top
         nSum := 0
         do while !eof()
            if SM3TIPE->merk == chr(251)
               nSum := nSum + SM3TIPE->aantal
            endif
            skip
         enddo
         go top
         if cLanType() == "A"
            fScrBood(23,ltrim(str(nSum,10,0))+" adresse is gemerk!" )
         else
            fScrBood(23,ltrim(str(nSum,10,0))+" addresses were marked!" )
         endif
         fScrWait(24)
         cBrowse:refreshall()

      elseif nKey == K_F1
         //Hulp
         do help with "sm3merk",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + " "
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik die gedeelte van die adrestipe waarvoor gesoek word.")
         else
            fScrBood(24,"Type a section of the address type which should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter Adrestipe? xx", 1 )
            @12, nBoxCoor say "Vind watter Adrestipe?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find what address type? xx", 1 )
            @12, nBoxCoor say "Find what address type?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            cLocate := trim( cLocate )
            set soft on
            seek cLocate
            if eof()
               go top
            endif
            set soft off
            cBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   fTClose( cTipe )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
   setcursor( cCurCur )

return lReturn

/***********************************************************************/
STATIC FUNCTION fTel

   //Funksie om die aantal adresse te tel

   //Verklaar
   local GetList := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   local cCurScr := fCurScreen()                 //Kleure ens
   local cCurDbf := fTOpen()                     //Databasis
   local cLede   := ""                           //Adresse databasis
   local cData   := ""                           //Data carrier
   local i       := 1
   local nTeller := 1

   //Maak huidige adrestipes aantal skoon
   select SM3TIPE
   go top
   if flock()
      replace all SM3TIPE->aantal with 0
      dbUnlock()
   endif
   go top

   //Open die adresse leer
   cLede := fTOpen( cDd(), "sm3klie", , "dbf", , .t., .f. )
   if left( cLede, 1 ) == "f"
      fTClose(    cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return NIL
   endif
   go top

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Adresse word getel")
   else
      fScrWbood(24,"Addresses being counted")
   endif

   //Die loop
   do while !( eof() )

      setcolor( cColBott() )
      if cLanType() == "A"
         @23,35 say str((nTeller/lastrec())*100,3,0)+"% voltooi"
      else
         @23,35 say str((nTeller/lastrec())*100,3,0)+"% completed"
      endif
      setcolor( cColNorm() )

      //Loop deur die tipe veld
      for i = 1 to 13 step 3
         cData := substr( SM3KLIE->tipe, i, 2 )
         if len( trim( cData ) ) > 0
            //Bewaar die aantal adresse
            select SM3TIPE
            seek cData
            if !(eof()) .and. rlock()
               SM3TIPE->aantal++
               dbUnlock()
            endif
            select SM3KLIE
         endif
      next

      //Breek indien nodig
      if inkey() == K_ESC
         select SM3KLIE
         go bottom
      endif

      //Volgende rekord
      nTeller++
      select SM3KLIE
      skip

   enddo

   //Herstel
   fTClose(    cLede   )
   fTClose(    cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
return NIL

//**************************************************************************/
STATIC FUNCTION fCreate()

   //Funksie om 'n tydelike leer te skep

   //Verklaar
   local lReturn := .f.
   local cCurDbf := fTOpen()
   local getlist := {}
   local nBoxc   := 0
   local cFrom   := space(6)
   local cTo     := space(6)
   local aVelde  := {}
   local cLede   := ""
   local cTemp   := ""
   local cOrig   := cDd()+"KLIE.dbf"
   local cFile   := cDd()+"SM3TEMP.dbf"
   local i := 0
   local cData := ""

   //Skerm
   //fScrOpsk()
   nBoxc := fBoxCent(10,space(50),5)
   if cLanType() == "A"
      @11,nBoxc say "  Vanaf watter Lid #"
      @13,nBoxc say "    Tot watter Lid #"
   else
      @11,nBoxc say " From which Member #"
      @13,nBoxc say "   To which Member #"
   endif
   setcolor(cColInve())
   @11,nBoxc+21 say cFrom
   @13,nBoxc+21 say cTo
   setcolor(cColNorm())

   //Vanaf watter adres
   do while cFrom == space(6)
      //Verstek
      if cFrom == space(6)
         cFrom := "000000"
      endif
      //Skerm
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  "+D_DNARR+"=Adresse")
         fScrBood(24,"Vanaf watter lidnommer moet die adresse vertoon/gedruk word?")
      else
         fScrBood(23,"[Esc]=Menu  "+D_DNARR+"=Addresses")
         fScrBood(24,"From which member number should addresses be displayed/printed?")
      endif
      //Read
      if cLanType() == "A"
         @11,nBoxc say "  Vanaf watter Lid #" get cFrom pict "@!"
      else
         @11,nBoxc say " From which Member #" get cFrom pict "@!"
      endif
      readexit(.t.)
      set cursor on
      read
      set cursor off
      readexit(.f.)
      //Die res
      if cLanType() == "A"
         do case
            case cFrom == space(6)
               //Lidnommer verpligtend
               fScrBood(23,"Lidnommer is verpligtend!")
               fScrWait(24)
            case lastkey() == K_ESC
               //Menu
               return lReturn
            case lastkey() == K_DOWN
               //Roep adresse
               asize( aVelde, 0 )
               aadd( aVelde, { "sm3klie", "kode" })
               aadd( aVelde, { "sm3klie", "naam" })
               //aadd( aVelde, { "sm3klie", "lekkme" })
               //aadd( aVelde, { "sm3klie", "lestoe" })
               cFrom := sm3klie( 3, 2, 21, aVelde, cFrom )
               setcolor(cColInve())
               @11,nBoxc+21 say cFrom
               setcolor(cColNorm())
         endcase
      else
         do case
            case cFrom == space(6)
               //Lidnommer verpligtend
               fScrBood(23,"Member number is compulsory!")
               fScrWait(24)
            case lastkey() == K_ESC
               //Menu
               return lReturn
            case lastkey() == K_DOWN
               //Roep adresse
               asize( aVelde, 0 )
               aadd( aVelde, { "sm3klie", "kode" })
               aadd( aVelde, { "sm3klie", "naam" })
               //aadd( aVelde, { "sm3klie", "lekkme" })
               //aadd( aVelde, { "sm3klie", "lestoe" })
               cFrom := sm3klie( 3, 2, 21, aVelde, cFrom )
               setcolor(cColInve())
               @11,nBoxc+21 say cFrom
               setcolor(cColNorm())
         endcase
      endif
   enddo

   //Tot watter adres
   do while cTo == space(6)
      //Verstek
      if cTo == space(6)
         cTo := "ZZZZZZ"
      endif
      //Skerm
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  "+D_DNARR+"=Adresse")
         fScrBood(24,"Tot watter lidnommer moet die adresse vertoon/gedruk word?")
      else
         fScrBood(23,"[Esc]=Menu  "+D_DNARR+"=Addresses")
         fScrBood(24,"To which member number should addresses be displayed/printed?")
      endif
      //Read
      if cLanType() == "A"
         @13,nBoxc say "    Tot watter Lid #" get cTo pict "@!@K"
      else
         @13,nBoxc say "   To which Member #" get cTo pict "@!@K"
      endif
      readexit(.t.)
      set cursor on
      read
      set cursor off
      readexit(.f.)
      //Die res
      if cLanType() == "A"
         do case
            case cTo == space(6)
               //Lidnommer verpligtend
               fScrBood(23,"Lidnommer is verpligtend!")
               fScrWait(24)
            case lastkey() == K_ESC
               //Menu
               return lReturn
            case lastkey() == K_DOWN
               //Roep adresse
               asize( aVelde, 0 )
               aadd( aVelde, { "sm3klie", "kode" })
               aadd( aVelde, { "sm3klie", "naam" })
               //aadd( aVelde, { "sm3klie", "lekkme" })
               //aadd( aVelde, { "sm3klie", "lestoe" })
               cTo := sm3klie( 3, 2, 21, aVelde, cTo )
               setcolor(cColInve())
               @13,nBoxc+21 say cTo
               setcolor(cColNorm())
         endcase
      else
         do case
            case cTo == space(6)
               //Lidnommer verpligtend
               fScrBood(23,"Member number is compulsory!")
               fScrWait(24)
            case lastkey() == K_ESC
               //Menu
               return lReturn
            case lastkey() == K_DOWN
               //Roep adresse
               asize( aVelde, 0 )
               aadd( aVelde, { "sm3klie", "kode" })
               aadd( aVelde, { "sm3klie", "naam" })
               //aadd( aVelde, { "sm3klie", "lekkme" })
               //aadd( aVelde, { "sm3klie", "lestoe" })
               cTo := sm3klie( 3, 2, 21, aVelde, cTo )
               setcolor(cColInve())
               @13,nBoxc+21 say cTo
               setcolor(cColNorm())
         endcase
      endif
   enddo

   //Skep 'n nuwe skoon leer
   copy file (cOrig) to (cFile)

   //Open adresse leer
   cTemp := fTOpen(cDd(),"sm3temp",, "dbf","sm3temp",.f.,.f.)
   if left(cTemp,1) == "f"
      return lReturn
   endif
   cLede := fTOpen( cDd(), "sm3klie", , "dbf", , .t., .f. )
   if left( cLede, 1 ) == "f"
      fTClose(cTemp)
      return lReturn
   endif

   //Gaan na die eerste adres
   set soft on
   seek cFrom
   set soft off

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Lˆer met lidnommers om te vertoon/druk word voorberei")
   else
      fScrWbood(24,"File with member numbers to display/print being prepared")
   endif

   //Die loop
   do while !eof() .and. SM3KLIE->kode <= cTo

      //setcolor( cColBott() )
      if cLanType() == "A"
         //@23,35 say str((nTeller/lastrec())*100,3,0)+"% voltooi"
      else
         //@23,35 say str((nTeller/lastrec())*100,3,0)+"% completed"
      endif
      //setcolor( cColNorm() )

      //Loop deur die tipe veld
      for i = 1 to 13 step 3
         cData := substr( SM3KLIE->tipe, i, 2 )
         if len( trim( cData ) ) > 0
            //Bewaar die aantal adresse
            select SM3TIPE
            seek cData
            if !(eof()) .and. SM3TIPE->merk == chr(251)
               select SM3TEMP
               append blank
               SM3TEMP->kode := SM3KLIE->kode
               lReturn := .t.
               select SM3KLIE
               exit
            endif
            select SM3KLIE
         endif
      next

      //Breek indien nodig
      if inkey() == K_ESC
         select SM3KLIE
         go bottom
      endif

      //Volgende rekord
      select SM3KLIE
      skip

   enddo

   //Herstel
   fTClose( cTemp )
   fTClose( cLede )
   fTClose( cCurDbf )
return lReturn

