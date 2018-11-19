//STDNETU.PRG
//Program om netwerkgebruikers te beheer
//Kopiereg (c) 1991 A van Rensburg
// 4:26pm Nov 16,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION StdNetu

//Verklaar
local lReturn := .f. // (.t. indien korrek) (.f. indien nie korrek gekies)
local lLoop   := .t. // gebruik in loops
local nTop    := 3   //Skermkoordinate
local nLeft   := 2   //Skermkoordinate
local nBottom := 20  //Skermkoordinate
local nRight  := 76  //Skermkoordinate
local aColumn := {}  //Browse opskrifte en datavelde
local cBrowse := NIL //tbrowse object
local i       := 1   //Counter
local nKey    := 0   //Keypress
local cLocScr := ""  //Vind naam skerm
local cLocate := ""  //Vind naam data
local nScrLen := 76  //Skerm lengte
local cWagw   := NIL //Wagwoord
local cWag1   := NIL //Eerste wagwoord
local cWag2   := NIL //Tweede wagwoord

//Skerm
fScrOpsk()

//Skep leer indien nie reeds bestaan
if !( file( cDd()+"stdnetu.dbf" ) )
   copy file stdnetu.tdb to (cDd()+"stdnetu.dbf")
endif

//Open die leer
lLoop := .t.
do while lLoop
   dbUseArea( .t., , cDd()+"stdnetu", "stdnetu", .t., .f. )
   if neterr()
      if cLanType() == "A"
         fScrBood(23,"NETWERKFOUT!!! - Netwerkgebruikers reeds aktief.")
         fScrBood(24,"[Esc]=Dos  [Enter]=Probeer weer")
      else
         fScrBood(23,"NETWORK ERROR!!! - Network users already active.")
         fScrBood(24,"[Esc]=Dos  [Enter]=Try again")
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

//Watter kolomme moet vertoon word
aadd( aColumn, TBColumnNew( "Naam",         {|| stdnetu->genaam } ) )
aadd( aColumn, TBColumnNew( "Kort;naam",    {|| stdnetu->gekort } ) )
aadd( aColumn, TBColumnNew( "Regte",        {|| stdnetu->gewaar } ) )
aadd( aColumn, TBColumnNew( "Laaste;datum", {|| stdnetu->gedatu } ) )

//Bepaal regterkantste lyn
nScrLen := 44
nRight := if( nLeft+nScrLen > 76, 76, nLeft+nScrLen )

//Teken die box
if cLanType() == "A"
   fBox( nTop, nLeft, nBottom, nRight, "netwerkgebruikers" )
else
   fBox( nTop, nLeft, nBottom, nRight, "network users" )
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
if cLanType() == "A"
   fScrBood( 23, "[ Esc ]=Dos   [A - Z]=Vind naam  [Ins]=Nuwe gebruiker " )
   fScrBood( 24, "[Enter]=Kies  [Alt E]=Verander   [Del]=Skrap gebruiker" )
else
   fScrBood( 23, "[ Esc ]=Dos     [A - Z]=Find name  [Ins]=New user   " )
   fScrBood( 24, "[Enter]=Choose  [Alt E]=Edit       [Del]=Delete user" )
endif

// Main loop
lLoop := .t.
do while lLoop

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
      //Esc means back to dos
      close all
      setcolor( cColBegi() )
      clear screen
      set curs on
      quit

   elseif nKey == K_ENTER

      //Enter means kies 'n gebruiker en vra wagwoord

      if stdnetu->gewagw == space(10)
         //Nuwe wagwoord
         cLocScr := savescreen( 0 , 0, 24, 79 )
         if cLanType() == "A"
            fScrBood(23,"U gaan nou geleentheid kry om u wagwoord te tik.")
         else
            fScrBood(23,"You will now have an opportunity to type your password.")
         endif
         fScrWait(24)
         if cLanType() == "A"
            fScrBood(23,"Onthou die wagwoord. Sonder die wagwoord kan u nie in die program kom nie.")
         else
            fScrBood(23,"Remember the password. Without password you do not have access to the program.")
         endif
         fScrWait(24)
         //Eerste wagwoord
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik u wagwoord vir die eerste maal.")
         else
            fScrBood(24,"Type your password for the first time.")
         endif
         cWag1 := stdnetu->gewagw
         cWag2 := stdnetu->gewagw
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 10, "12345678901234567890 xxxxxxxxxx", 3, "nuwe wagwoord" )
            @11, nBoxCoor say "  Wagwoord 1ste maal"
            @12, nBoxCoor say "   Wagwoord 2de maal"
         else
            nBoxCoor := fBoxCent( 10, "12345678901234567890 xxxxxxxxxx", 3, "new password" )
            @11, nBoxCoor say "   Password 1st time"
            @12, nBoxCoor say "   Password 2nd time"
         endif
         setcolor( cColPass() )
         @11, nBoxCoor+21 get cWag1 pict "@!"
         setcolor( cColNorm() )
         set cursor on
         read
         set cursor off
         if lastkey() == K_ESC .or. cWag1 == space(10)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Tweede wagwoord
         if cLanType() == "A"
            fScrBood(24,"Bevestig u wagwoord deur dit vir die tweede maal te tik.")
         else
            fScrBood(24,"Confirm your password by typing it a second time.")
         endif
         setcolor( cColPass() )
         @12, nBoxCoor+21 get cWag2 pict "@!"
         setcolor( cColNorm() )
         set cursor on
         read
         set cursor off
         if lastkey() == K_ESC .or. cWag2 == space(10)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Toets wagwoorde
         if cWag1 == stdnetu->genaam
            if cLanType() == "A"
               fScrBood(23,"Wagwoord mag nie dieselfde as die Netwerknaam wees nie.")
            else
               fScrBood(23,"Password may not be the same as the Network name.")
            endif
            fScrWait(24)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Toets wagwoorde
         if cWag1 == cWag2
            //wagwoorde stem ooreen
            if rlock()
               stdnetu->gewagw := cWag1
               dbUnlock()
               if cLanType() == "A"
                  fScrWait(24,"Wagwoord is aanvaar")
               else
                  fScrWait(24,"Password accepted")
               endif
            else
               if cLanType() == "A"
                  fScrWait(24,"Wagwoord is nie aanvaar - Netwerkfout")
               else
                  fScrWait(24,"Password not accepted - Network error")
               endif
            endif
         else
            //wagwoorde stem nie ooreen
            if cLanType() == "A"
               fScrWait(24,"Wagwoorde stem nie ooreen")
            else
               fScrWait(24,"Passwords do not agree")
            endif
         endif
         restscreen( 0, 0, 24, 79, cLocScr )
         loop
      endif

      if stdnetu->gestel > 0 .and. stdnetu->gekere > stdnetu->gestel
         //Verander wagwoord
         cLocScr := savescreen( 0 , 0, 24, 79 )
         if cLanType() == "A"
            fScrBood(23,"U bestaande wagwoord het verstryk.")
            fScrWait(24)
            fScrBood(23,"U gaan nou geleentheid kry om 'n nuwe wagwoord te tik.")
         else
            fScrBood(23,"Your existing password has expired.")
            fScrWait(24)
            fScrBood(23,"You now have an opportunity to type a new password.")
         endif
         fScrWait(24)
         //Bestaande wagwoord
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik u bestaande wagwoord.")
         else
            fScrBood(24,"Type your existing password.")
         endif
         cWagw := space(10)
         cWag1 := cWagw
         cWag2 := cWagw
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 10, "12345678901234567890 xxxxxxxxxx", 4, "nuwe wagwoord" )
            @11, nBoxCoor say "  Bestaande wagwoord"
            @12, nBoxCoor say "       Nuwe wagwoord"
            @13, nBoxCoor say "2de ml Nuwe wagwoord"
         else
            nBoxCoor := fBoxCent( 10, "12345678901234567890 xxxxxxxxxx", 4, "new password" )
            @11, nBoxCoor say "   Existing password"
            @12, nBoxCoor say "        New password"
            @13, nBoxCoor say " Repeat New password"
         endif
         setcolor( cColPass() )
         @11, nBoxCoor+21 get cWagw pict "@!"
         setcolor( cColNorm() )
         set cursor on
         read
         set cursor off
         if lastkey() == K_ESC .or. cWagw == space(10)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Toets wagwoorde
         if cWagw == stdnetu->gewagw
         else
            //wagwoorde stem nie ooreen
            if cLanType() == "A"
               fScrWait(24,"Wagwoord onbekend")
            else
               fScrWait(24,"Password unknown")
            endif
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Eerste wagwoord
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik u nuwe wagwoord vir die eerste maal.")
         else
            fScrBood(24,"Type a new password for the first time.")
         endif
         setcolor( cColPass() )
         @12, nBoxCoor+21 get cWag1 pict "@!"
         setcolor( cColNorm() )
         set cursor on
         read
         set cursor off
         if lastkey() == K_ESC .or. cWag1 == space(10)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         if cWag1 == stdnetu->genaam
            if cLanType() == "A"
               fScrBood(23,"Nuwe wagwoord mag nie dieselfde as die Netwerknaam wees nie.")
            else
               fScrBood(23,"New password may not be the same as the Network name.")
            endif
            fScrWait(24)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         if cWag1 == cWagw
            if cLanType() == "A"
               fScrBood(23,"Nuwe wagwoord mag nie dieselfde as die bestaande wagwoord wees nie.")
            else
               fScrBood(23,"New password may not be the same as the existing password.")
            endif
            fScrWait(24)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Tweede wagwoord
         if cLanType() == "A"
            fScrBood(24,"Bevestig u nuwe wagwoord deur dit vir die tweede maal te tik.")
         else
            fScrBood(24,"Confirm your new password by typing it a second time.")
         endif
         setcolor( cColPass() )
         @13, nBoxCoor+21 get cWag2 pict "@!"
         setcolor( cColNorm() )
         set cursor on
         read
         set cursor off
         if lastkey() == K_ESC .or. cWag2 == space(10)
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
         //Toets wagwoorde
         //Toets wagwoorde
         if cWag1 == cWag2
            //wagwoorde stem ooreen
            if rlock()
               stdnetu->gewagw := cWag1
               stdnetu->gekere := 0
               dbUnlock()
               if cLanType() == "A"
                  fScrWait(24,"U nuwe wagwoord is aanvaar")
               else
                  fScrWait(24,"Your new password accepted")
               endif
            else
               if cLanType() == "A"
                  fScrWait(24,"Wagwoord is nie aanvaar - Netwerkfout")
               else
                  fScrWait(24,"Password not accepted - Network error")
               endif
            endif
         else
            //wagwoorde stem nie ooreen
            if cLanType() == "A"
               fScrWait(24,"Nuwe wagwoorde stem nie ooreen")
            else
               fScrWait(24,"New passwords do not agree")
            endif
         endif
         restscreen( 0, 0, 24, 79, cLocScr )
         loop
      endif

      //Vra die wagwoord
      cLocScr := savescreen( 0 , 0, 24, 79 )
      //Eerste wagwoord
      fScrBood(23)
      if cLanType() == "A"
         fScrBood(24,"Tik u wagwoord.")
      else
         fScrBood(24,"Type your password.")
      endif
      cWagw := "          "
      if cLanType() == "A"
         nBoxCoor := fBoxCent( 12, "wagwoord xxxxxxxxxx", 1 )
         @12, nBoxCoor say "Wagwoord"
      else
         nBoxCoor := fBoxCent( 12, "password xxxxxxxxxx", 1 )
         @12, nBoxCoor say "Password"
      endif
      setcolor( cColPass() )
      @12, nBoxCoor+9 get cWagw pict "@!"
      setcolor( cColNorm() )
      set cursor on
      read
      set cursor off
      if lastkey() == K_ESC .or. cWagw == space(10)
         restscreen( 0, 0, 24, 79, cLocScr )
         loop
      endif
      //Toets wagwoorde
      if cWagw == stdnetu->gewagw
         //wagwoorde stem ooreen
         if rlock()
            //Vul stdnetu leer
            if stdnetu->gestel > 0
               stdnetu->gekere++
            endif
            stdnetu->gedatu := dAppDate()
            //Vul public veranderlikes
            cNetNaam := stdnetu->genaam
            cNetKort := trim(stdnetu->gekort)
            cNetWaar := stdnetu->gewaar
            cNetLede := stdnetu->gelede
            cNetAanv := stdnetu->geaanv
            cNetGebo := stdnetu->gegebo
            cNetPres := stdnetu->gepres
            cNetKeur := stdnetu->gekeur
            cNetOord := stdnetu->geoord
            cNetSkra := stdnetu->geskra
            lReturn := .t.
            lLoop := .f.
            dbUnlock()
         else
            if cLanType() == "A"
               fScrWait(24,"Wagwoord is nie aanvaar - Netwerkfout")
            else
               fScrWait(24,"Password not accepted - Network error")
            endif
            restscreen( 0, 0, 24, 79, cLocScr )
            loop
         endif
      else
         //wagwoorde stem nie ooreen
         if cLanType() == "A"
            fScrWait(24,"Wagwoord onbekend")
         else
            fScrWait(24,"Password unknown")
         endif
         restscreen( 0, 0, 24, 79, cLocScr )
         loop
      endif
      restscreen( 0, 0, 24, 79, cLocScr )

   elseif nKey == K_INS
      //Insert means add a record to the dbf
      if fAdd()
         cBrowse:refreshall()
      endif

   elseif nKey == K_ALT_E
      //Insert means change a record
      if fEdit()
         cBrowse:refreshall()
      endif

   elseif nKey == K_DEL
      //Insert means delete a record
      if fDelete()
         cBrowse:refreshall()
      endif

   elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122
      //Means locate a record
      cLocate := upper( chr( nKey ) ) + space(9)
      cLocScr := savescreen( 11, 0, 14, 79 )
      keyboard chr( K_RIGHT )
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent( 12, "Naam? xxxxxxxxxx", 1, "vind" )
         @12, nBoxCoor say "Naam?" get cLocate pict "@!"
      else
         nBoxCoor := fBoxCent( 12, "Name? xxxxxxxxxx", 1, "find" )
         @12, nBoxCoor say "Name?" get cLocate pict "@!"
      endif
      set cursor on
      read
      set cursor off
      restscreen( 11, 0, 14, 79, cLocScr )
      if lastkey() == K_ESC
      else
         locate for trim( cLocate ) $ stdnetu->genaam
         if eof()
            go top
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
return lReturn

/*************************************************************************/
STATIC FUNCTION fAdd()

//Funksie om te bewaar of te verander

//Veranderlikes
local lReturn := .f. //logocal return
local getlist := {}  //get object
local cCurSke := savescreen( 0, 0, 24, 79 ) //Bewaar skerm
local nRekord := recno() //Huidige rekordnommer
local nCol    := 0 //kolom koordinate
local cNaam   := "          " //Naam
local cWagw   := cNaam //Wagwoord
local cWaar   := cNaam //Waardes
local nStel   := 0
local cKort   := "    "
local cLede   := cNaam
local cAanv   := cNaam
local cGebo   := cNaam
local cPres   := cNaam
local cKeur   := cNaam
local cOord   := cNaam
local cSkra   := cNaam
local lLoop   := .t.

//Vra eers die genaam en gewagw
fScrBood(23)
if cLanType() == "A"
   fScrBood(24,"Tik u Netwerknaam!  [Esc]=Netwerkgebruikers")
   nCol := fBoxCent( 11, "wagwoord xxxxxxxxxx", 2 )
   @11, nCol say "    Naam" get cNaam pict "@!"
   @12, nCol say "Wagwoord"
else
   fScrBood(24,"Type your Network Name!  [Esc]=Network users")
   nCol "= fBoxCent( 11, "password xxxxxxxxxx", 2 )
   @11, nCol say "    Name" get cNaam pict "@!"
   @12, nCol say "Password"
endif
set cursor on
read
set cursor off
if lastkey() == K_ESC .or. cNaam == "          "
   restscreen( 0, 0, 24, 79, cCurSke )
   return lReturn
endif
//Vra die wagwoord
if cLanType() == "A"
   fScrBood(24,"Tik u wagwoord!  [Esc]=Netwerkgebruikers")
else
   fScrBood(24,"Type your password!  [Esc]=Network users")
endif
setcolor( cColPass() )
@12, nCol+9 get cWagw pict "@!"
set cursor on
read
set cursor off
setcolor( cColNorm() )
if lastkey() == K_ESC .or. cWagw == "          "
   restscreen( 0, 0, 24, 79, cCurSke )
   return lReturn
endif
//Vind die naam
if cNaam == "ALBERT    " .and. cWagw == "ERGMAKLIK1"
else
   go top
   locate for cNaam == stdnetu->genaam
   if eof()
      if cLanType() == "A"
         fScrWait(24,"U Netwerknaam is onbekend")
      else
         fScrWait(24,"Your Network name is unknown")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
   if cWagw == stdnetu->gewagw
   else
      if cLanType() == "A"
         fScrWait(24,"Wagwoord ongeldig")
      else
         fScrWait(24,"Password invalid")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
   if "X" $ stdnetu->gewaar
   else
      if cLanType() == "A"
         fScrWait(24,"U het geen toegangsregte")
      else
         fScrWait(24,"You have no right of admission")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
endif

//Vra die nuwe besonderhede
cNaam := space(10)

//Skerm
restscreen( 0, 0, 24, 79, cCurSke )
nCol := fBoxCent(  7, "12345678901234567890 xxxxxxxxxx", 13, "gebruikersbesonderhede" )

//Vra die nuwe gebruiker
lLoop := .t.
do while lLoop

   //Skerm
   if cLanType() == "A"
      fScrBood(23,"Tik die besonderhede van die nuwe netwerkgebruiker.")
      fScrBood(24,"A=Add B=Backup D=Delete E=Edit I=Index P=Print R=Restore S=Struct X=Super")
   else
      fScrBood(23,"Type the details for the new network user.")
      fScrBood(24,"A=Add B=Backup D=Delete E=Edit I=Index P=Print R=Restore S=Struct X=Super")
   endif

   //Vra
   if cLanType() == "A"
      @ 9, nCol say "    Naam van persoon" get cNaam pict "@!"
      @10, nCol say "            Kortnaam" get cKort pict "@!"
      @11, nCol say "Nuwe wagwoord (maal)" get nStel pict "999"
      @12, nCol say "      Algemene regte" get cWaar pict "@!"
      @13, nCol say "          Lede regte" get cLede pict "@!"
      @14, nCol say "   Aanvanklike regte" get cAanv pict "@!"
      @15, nCol say "     Geboortes regte" get cGebo pict "@!"
      @16, nCol say "     Prestasie regte" get cPres pict "@!"
      @17, nCol say "      Keurings regte" get cKeur pict "@!"
      @18, nCol say "     Oordragte regte" get cOord pict "@!"
      @19, nCol say "    Skrappings regte" get cSkra pict "@!"
   else
      @ 9, nCol say "      Name of person" get cNaam pict "@!"
      @10, nCol say "          Short name" get cKort pict "@!"
      @11, nCol say "New password (times)" get nStel pict "999"
      @12, nCol say "      General rights" get cWaar pict "@!"
      @13, nCol say "       Member rights" get cLede pict "@!"
      @14, nCol say "      Initial rights" get cAanv pict "@!"
      @15, nCol say "       Births rights" get cGebo pict "@!"
      @16, nCol say "  Performance rights" get cPres pict "@!"
      @17, nCol say "   Inspection rights" get cKeur pict "@!"
      @18, nCol say "     Transfer rights" get cOord pict "@!"
      @19, nCol say "      Culling rights" get cSkra pict "@!"
   endif
   set curs on
   read
   set curs off

   //Toetse - Escape or NIL data
   if lastkey() == K_ESC .or. cNaam == space(10) .or. cKort == "    "
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif

   //Toetse - Naam bestaan reeds
   go top
   locate for stdnetu->genaam == cNaam
   if !( eof() )
      fScrBood(23)
      if cLanType() == "A"
         fScrWait(24,"Naam bestaan reeds")
      else
         fScrWait(24,"Name already exists")
      endif
      loop
   endif

   //Toetse - Kortnaam bestaan reeds
   go top
   locate for stdnetu->gekort == cKort
   if !( eof() )
      fScrBood(23)
      if cLanType() == "A"
         fScrWait(24,"Kortnaam bestaan reeds")
      else
         fScrWait(24,"Short name already exists")
      endif
      keyboard chr( K_ENTER )
      loop
   endif

   //Add record
   append blank
   if rlock()
      stdnetu->genaam := cNaam
      stdnetu->gekort := cKort
      stdnetu->gewaar := cWaar
      stdnetu->gestel := nStel
      stdnetu->geLede := cLede
      stdnetu->geAanv := cAanv
      stdnetu->geGebo := cGebo
      stdnetu->gePres := cPres
      stdnetu->geKeur := cKeur
      stdnetu->geOord := cOord
      stdnetu->geskra := cSkra

      dbUnlock()
      lReturn := .t.
      exit
   endif

enddo

restscreen( 0, 0, 24, 79, cCurSke )
return lReturn

/*************************************************************************/
STATIC FUNCTION fEdit()

//Funksie om te verander

//Veranderlikes
local lReturn := .f. //logocal return
local getlist := {}  //get object
local cCurSke := savescreen( 0, 0, 24, 79 ) //Bewaar skerm
local nRekord := recno() //Huidige rekordnommer
local nCol    := 0 //kolom koordinate
local cNaam   := "          " //Naam
local cWagw   := cNaam //Wagwoord
local cWaar   := cNaam //Waardes
local nStel   := 0
local cKort   := "    "
local cLede   := cNaam
local cAanv   := cNaam
local cGebo   := cNaam
local cPres   := cNaam
local cKeur   := cNaam
local cOord   := cNaam
local cSkra   := cNaam
local lLoop   := .t.

//Vra eers die genaam en gewagw
fScrBood(23)
if cLanType() == "A"
   fScrBood(24,"Tik u Netwerknaam!  [Esc]=Netwerkgebruikers")
   nCol := fBoxCent( 11, "wagwoord xxxxxxxxxx", 2 )
   @11, nCol say "    Naam" get cNaam pict "@!"
   @12, nCol say "Wagwoord"
else
   fScrBood(24,"Type your Network name!  [Esc]=Network users")
   nCol := fBoxCent( 11, "password xxxxxxxxxx", 2 )
   @11, nCol say "    Name" get cNaam pict "@!"
   @12, nCol say "Password"
endif
set cursor on
read
set cursor off
if lastkey() == K_ESC .or. cNaam == "          "
   restscreen( 0, 0, 24, 79, cCurSke )
   return lReturn
endif
//Vra die wagwoord
if cLanType() == "A"
   fScrBood(24,"Tik u wagwoord!  [Esc]=Netwerkgebruikers")
else
   fScrBood(24,"Type your password!  [Esc]=Network users")
endif
setcolor( cColPass() )
@12, nCol+9 get cWagw pict "@!"
set cursor on
read
set cursor off
setcolor( cColNorm() )
if lastkey() == K_ESC .or. cWagw == "          "
   restscreen( 0, 0, 24, 79, cCurSke )
   return lReturn
endif
//Vind die naam
if cNaam == "ALBERT    " .and. cWagw == "ERGMAKLIK1"
else
   go top
   locate for cNaam == stdnetu->genaam
   if eof()
      if cLanType() == "A"
         fScrWait(24,"U Netwerknaam is onbekend")
      else
         fScrWait(24,"Your Network name is unknown")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
   if cWagw == stdnetu->gewagw
   else
      if cLanType() == "A"
         fScrWait(24,"Wagwoord ongeldig")
      else
         fScrWait(24,"Password invalid")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
   if "X" $ stdnetu->gewaar
   else
      if cLanType() == "A"
         fScrWait(24,"U het geen toegangsregte")
      else
         fScrWait(24,"You do not have right of admission")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
endif

//Vra die nuwe besonderhede
goto nRekord
cNaam := stdnetu->genaam
cKort := stdnetu->gekort
nStel := stdnetu->gestel
cWaar := stdnetu->gewaar
cLede := stdnetu->gelede
cAanv := stdnetu->geaanv
cGebo := stdnetu->gegebo
cPres := stdnetu->gepres
cKeur := stdnetu->gekeur
cOord := stdnetu->geoord
cSkra := stdnetu->geskra

//Skerm
restscreen( 0, 0, 24, 79, cCurSke )
nCol := fBoxCent(  7, "12345678901234567890 xxxxxxxxxx", 13, "gebruikersbesonderhede" )

//Vra die nuwe gebruiker
lLoop := .t.
do while lLoop

   //Skerm
   if cLanType() == "A"
      fScrBood(23,"Tik die besonderhede van die nuwe netwerkgebruiker.")
   else
      fScrBood(23,"Type the details of the new network user.")
   endif
   fScrBood(24,"A=Add B=Backup D=Delete E=Edit I=Index P=Print R=Restore S=Struct X=Super")

   //Vra
   if cLanType() == "A"
      @ 9, nCol say "    Naam van persoon " + cNaam
      @10, nCol say "            Kortnaam " + cKort
      @11, nCol say "Nuwe wagwoord (maal)" get nStel pict "999"
      @12, nCol say "      Algemene regte" get cWaar pict "@!"
      @13, nCol say "          Lede regte" get cLede pict "@!"
      @14, nCol say "   Aanvanklike regte" get cAanv pict "@!"
      @15, nCol say "     Geboortes regte" get cGebo pict "@!"
      @16, nCol say "     Prestasie regte" get cPres pict "@!"
      @17, nCol say "      Keurings regte" get cKeur pict "@!"
      @18, nCol say "     Oordragte regte" get cOord pict "@!"
      @19, nCol say "    Skrappings regte" get cSkra pict "@!"
   else
      @ 9, nCol say "      Name of person" + cNaam
      @10, nCol say "          Short name" + cKort
      @11, nCol say "New password (times)" get nStel pict "999"
      @12, nCol say "      General rights" get cWaar pict "@!"
      @13, nCol say "       Member rights" get cLede pict "@!"
      @14, nCol say "      Initial rights" get cAanv pict "@!"
      @15, nCol say "        Birth rights" get cGebo pict "@!"
      @16, nCol say "  Performance rights" get cPres pict "@!"
      @17, nCol say "   Inspection rights" get cKeur pict "@!"
      @18, nCol say "     Transfer rights" get cOord pict "@!"
      @19, nCol say "      Culling rights" get cSkra pict "@!"
   endif
   set curs on
   read
   set curs off

   //Toetse - Escape or NIL data
   if lastkey() == K_ESC .or. cNaam == space(10) .or. cKort == "    "
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif

   //Edit record
   if rlock()
      //stdnetu->genaam := cNaam
      //stdnetu->gekort := cKort
      stdnetu->gewaar := cWaar
      stdnetu->gestel := nStel
      stdnetu->geLede := cLede
      stdnetu->geAanv := cAanv
      stdnetu->geGebo := cGebo
      stdnetu->gePres := cPres
      stdnetu->geKeur := cKeur
      stdnetu->geOord := cOord
      stdnetu->geskra := cSkra
      dbUnlock()
      lReturn := .t.
      exit
   endif

enddo

restscreen( 0, 0, 24, 79, cCurSke )
return lReturn

/*************************************************************************/
STATIC FUNCTION fDelete()

//Funksie om te skrap

//Veranderlikes
local lReturn := .f. //logocal return
local getlist := {}  //get object
local cCurSke := savescreen( 0, 0, 24, 79 ) //Bewaar skerm
local nRekord := recno() //Huidige rekordnommer
local nCol    := 0 //kolom koordinate
local cNaam   := space(10)
local cWagw   := cNaam
local lLoop   := .t.

//Vra eers die genaam en gewagw
fScrBood(23)
if cLanType() == "A"
   fScrBood(24,"Tik u Netwerknaam!  [Esc]=Netwerkgebruikers")
   nCol := fBoxCent( 11, "wagwoord xxxxxxxxxx", 2 )
   @11, nCol say "    Naam" get cNaam pict "@!"
   @12, nCol say "Wagwoord"
else
   fScrBood(24,"Type a Network name!  [Esc]=Network users")
   nCol := fBoxCent( 11, "password xxxxxxxxxx", 2 )
   @11, nCol say "    Name" get cNaam pict "@!"
   @12, nCol say "Password"
endif
set cursor on
read
set cursor off
if lastkey() == K_ESC .or. cNaam == "          "
   restscreen( 0, 0, 24, 79, cCurSke )
   return lReturn
endif
//Vra die wagwoord
if cLanType() == "A"
   fScrBood(24,"Tik u wagwoord!  [Esc]=Netwerkgebruikers")
else
   fScrBood(24,'Type your password!  [Esc]=Network users")
endif
setcolor( cColPass() )
@12, nCol+9 get cWagw pict "@!"
set cursor on
read
set cursor off
setcolor( cColNorm() )
if lastkey() == K_ESC .or. cWagw == "          "
   restscreen( 0, 0, 24, 79, cCurSke )
   return lReturn
endif
//Vind die naam
if cNaam == "ALBERT    " .and. cWagw == "ERGMAKLIK1"
else
   go top
   locate for cNaam == stdnetu->genaam
   if eof()
      if cLanType() == "A"
         fScrWait(24,"U Netwerknaam is onbekend")
      else
         fScrWait(24,"Your Network name is unknown")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
   if cWagw == stdnetu->gewagw
   else
      if cLanType() == "A"
         fScrWait(24,"Wagwoord ongeldig")
      else
         fScrWait(24,"Password invalid")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
   if "X" $ stdnetu->gewaar
   else
      if cLanType() == "A"
         fScrWait(24,"U het geen toegangsregte")
      else
         fScrWait(24,"You have no right of admission")
      endif
      goto nRekord
      restscreen( 0, 0, 24, 79, cCurSke )
      return lReturn
   endif
endif

//Skuif
goto nRekord

//Skerm
fScrBood(23)
if cLanType() == "A"
   if fJaNee( 24, "Moet "+trim( stdnetu->genaam )+" geskrap word?" )
else
   if fJaNee( 24, "Should "+trim( stdnetu->genaam )+" be deleted?" )
endif
   if rlock()
      delete
      lReturn := .t.
      dbUnlock()
   endif
endif

restscreen( 0, 0, 24, 79, cCurSke )
return lReturn

/*************************************************************************/
STATIC FUNCTION cColPass

//Funksie om die wagwoord kleur te bepaal

//Waardes
local cReturn := NIL //die nuwe kleur
local nFcom := at( ",", cColNorm() )
local nLcom := rat( ",", cColNorm() )
local cTuss := substr( cColNorm(), nFcom+1, (nLcom-nFcom)-1 )
local nSlas := at( "/", cTuss )
local cColo := "N" //right( cTuss, nSlas+1 )  //left( cTuss, nSlas-1 )

//Bou die nuwe kleur
cReturn := left( cColNorm(), nFcom )
cReturn := cReturn + cColo + "/" + cColo
cReturn := cReturn + "," + right( cColNorm(), len( cColNorm())-nLcom )

return cReturn
