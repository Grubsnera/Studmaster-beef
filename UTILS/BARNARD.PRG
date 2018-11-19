//BARNARD.PRG
//Program to update Studmaster V4.00 performance records
//with MultiBeef performance record file
//Kopiereg (c) 1994 Tarragon
//07-26-94 10:10pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION barnard

   // Veranderlikes
   local nBoxCoor := 0
   local aDbfCrea := {}
   local nAanvaar := 0
   local nVerwerp := 0
   local nStamboo := 0
   local cIdnomm  := ""
   local cData    := 0
   local nData    := 0

   // Verklaar publiek
   public cAppName := "Veedata->StudMaster"
   public cOwnFone := "Pretoria (012) 3338399"
   public cGebNaam := "Tarragon Computing BK"
   public cColNorm := "W+/N,N/W,N"
   public cColMenu := "N/W,W+/N,N"
   public cColHead := "N/W,N/W,N"
   public cColBott := "N/W,N/W,N"
   public cColInve := "N/W,W/N,N"
   public cColHelp := "N/W,W+/N,N"
   public cColTopl := "W+/N,N/W,N"
   public dAppDate := date()
   public cDd      := space(30)
   public cPrnNorm := padr("chr(15)",40)
   public cPrnCond := padr("chr(18)",40)
   public nPrnLeng := 66
   public cBegCol  := setcolor()
   public cLanType := "A"

   // Omgewing
   set cursor off
   set conf on
   set date brit
   set scoreboard off
   set deleted on
   set message to maxrow()

   //Prestasieleer************************************************************

   // Skerm
   fScrOpsk()
   fScrWbood(24,"Hooflˆer rekenaarnommer word nagegaan")

   // Open die hoofleer
   dbusearea(.t.,,"sm3data")
   do while !eof()
      fScrBood(23,SM3DATA->idnr+" "+fPercent(recno(),lastrec())+"% Voltooi")
      if !empty(SM3DATA->reknr)
         SM3DATA->reknr := padl(alltrim(SM3DATA->reknr),10,"0")
      endif
      skip
   enddo
   go top
   fScrOpsk()
   fScrWbood(24,"Hooflˆer word ge‹ndeks op rekenaarnommer")
   index on REKNR to BARNARD

   // Open die prestasielˆer
   dbusearea(.t.,,"nsvpres")
   set relation to IDNOMM into SM3DATA
   go top

   // Die loop

   // Skerm
   fScrWbood(24,"Prestasielˆer se data word omgeskakel")
   nBoxCoor := fBoxCent(10,space(50),5,"PRESTASIEDATA" )
   @ 11, nBoxCoor say "                Aantal diere  " + ltrim(str(lastrec()))

   do while !eof()

      // Skerm
      @ 12, nBoxCoor say "                Huidige dier  " + ltrim(str(recno()))
      @ 13, nBoxCoor say "         Persentasie voltooi  " + ltrim(str((recno()/lastrec())*100))

      select SM3DATA
      if !eof()

         // Lock
         do while !rlock()
         enddo

         // Voorspeen
         if NSVPRES->intipe == "A1 "
            SM3DATA->kod100 := NSVPRES->inkode
            SM3DATA->dat100 := NSVPRES->indatu
            SM3DATA->mas100 := NSVPRES->inmass
            SM3DATA->aan100 := NSVPRES->inggro
            SM3DATA->ple100 := NSVPRES->inrang
            SM3DATA->gma100 := NSVPRES->ingmas
            SM3DATA->gdo100 := NSVPRES->ingdoo
            SM3DATA->ind100 := NSVPRES->ininde
            nData := NSVPRES->indatu - SM3DATA->gebdatum
            if nData > 0 .and. nData < 999
               SM3DATA->oud100 := nData
            endif
         endif

         // Speen
         if NSVPRES->intipe == "A2 "
            SM3DATA->kod205 := NSVPRES->inkode
            SM3DATA->dat205 := NSVPRES->indatu
            SM3DATA->mas205 := NSVPRES->inmass
            SM3DATA->aan205 := NSVPRES->inggro
            SM3DATA->ple205 := NSVPRES->inrang
            SM3DATA->gma205 := NSVPRES->ingmas
            SM3DATA->gdo205 := NSVPRES->ingdoo
            SM3DATA->ind205 := NSVPRES->ininde
            SM3DATA->mamoergeb := NSVPRES->inkmag
            SM3DATA->mamoerspe := NSVPRES->inkmai
            SM3DATA->mpresind := NSVPRES->inkkli
            nData := NSVPRES->indatu - SM3DATA->gebdatum
            if nData > 0 .and. nData < 999
               SM3DATA->oud205 := nData
            endif
         endif

         // Jaar
         if NSVPRES->intipe == "B1 "
            SM3DATA->kod365 := NSVPRES->inkode
            SM3DATA->dat365 := NSVPRES->indatu
            SM3DATA->mas365 := NSVPRES->inmass
            SM3DATA->aan365 := NSVPRES->inggro
            SM3DATA->ple365 := NSVPRES->inrang
            SM3DATA->gma365 := NSVPRES->ingmas
            SM3DATA->gdo365 := NSVPRES->ingdoo
            SM3DATA->ind365 := NSVPRES->ininde
            nData := NSVPRES->indatu - SM3DATA->gebdatum
            if nData > 0 .and. nData < 999
               SM3DATA->oud365 := nData
            endif
         endif

         // 18 maande
         if NSVPRES->intipe == "B2 "
            SM3DATA->kod540 := NSVPRES->inkode
            SM3DATA->dat540 := NSVPRES->indatu
            SM3DATA->mas540 := NSVPRES->inmass
            SM3DATA->aan540 := NSVPRES->inggro
            SM3DATA->ple540 := NSVPRES->inrang
            SM3DATA->gma540 := NSVPRES->ingmas
            SM3DATA->gdo540 := NSVPRES->ingdoo
            SM3DATA->ind540 := NSVPRES->ininde
            nData := NSVPRES->indatu - SM3DATA->gebdatum
            if nData > 0 .and. nData < 999
               SM3DATA->oud540 := nData
            endif
         endif

         // Fase C & D
         if "D" $ NSVPRES->intipe .or. ;
               "C" $ NSVPRES->intipe

            // Maak eers die jaarsyfers skoon
            SM3DATA->kod365 := "  "
            SM3DATA->dat365 := ctod("")
            SM3DATA->mas365 := 0
            SM3DATA->aan365 := 0
            SM3DATA->ple365 := 0
            SM3DATA->gma365 := 0
            SM3DATA->gdo365 := 0
            SM3DATA->ind365 := 0
            SM3DATA->oud365 := 0

            // Maak eers 18 maande syfers skoon
            SM3DATA->kod540 := "  "
            SM3DATA->dat540 := ctod("")
            SM3DATA->mas540 := 0
            SM3DATA->aan540 := 0
            SM3DATA->ple540 := 0
            SM3DATA->gma540 := 0
            SM3DATA->gdo540 := 0
            SM3DATA->ind540 := 0
            SM3DATA->oud540 := 0

            // Fase C & D data
            SM3DATA->gdoind := NSVPRES->ininde
            SM3DATA->gdogdo := NSVPRES->ingdoo
            SM3DATA->gdtind := NSVPRES->ingdti
            SM3DATA->gdtgdt := NSVPRES->ingdtt
            SM3DATA->rangor := NSVPRES->inrang
            SM3DATA->tydgen := NSVPRES->inggro
            SM3DATA->einmas := NSVPRES->inmass
            SM3DATA->eindat := NSVPRES->indatu
            SM3DATA->aanmas := NSVPRES->inaanm
            SM3DATA->aandat := NSVPRES->inaand
            SM3DATA->voeromseti := NSVPRES->infcin
            SM3DATA->voeromset  := NSVPRES->infcra
            SM3DATA->begmassa   := NSVPRES->inbegm
            SM3DATA->begdatum   := NSVPRES->inbegd
            SM3DATA->fasekode   := NSVPRES->intipe

         endif

      endif

      // Volgende dier
      select NSVPRES
      skip

   enddo
   close all

   // Herstel
   ferase("barnard.ntx")
   ferase("nsvpres.dbf")
   set curs on
   setcolor(cBegCol)

return NIL

/**************************************************************************/
FUNCTION fScrOpsk( nSet, cBood )

/*
Funksie om die skerm vanaf die heel boonste lyn te teken
0 = Hele skerm
1 = Slegs die naam van gebruiker lyn (lyn 1)
*/

   LOCAL cOldColor := setcolor()

   // Indien geen waarde = 0
   nSet := IF( nSet == NIL, 0, nSet )
   cBood := if( cBood==NIL, "", cBood )

   IF nSet = 0

      // Teken die hele skerm

      // Heel boonste lyn
      //fScrBood( 0, TRIM( cAppName ), cColNorm )
      #ifdef AFR
         fScrBood( 0, trim( cAppName ) + ". Kopiereg (c) Tarragon "+str(year(dAppDate),4,0)+". Alle Regte Voorbehou.", cColTopl )
      #else
         fScrBood( 0, trim( cAppName ) + ". Copyright (c) Tarragon "+str(year(dAppDate),4,0)+". All Rights Reserved.", cColTopl )
      #endif

      // Opskriflyn
      fScrBood( 1, " "+cGebNaam, cColHead, 1 )
      fScrWord( 1, 79-len(fDtow(dAppDate)), fDtow(dAppDate), cColHead )
      if len( cBood ) > 0
         cBood := "  " + cBood + "  "
         fScrWord( 1, 39-int(len(cBood)/2), cBood, cColHead )
      endif

      // Lyne 2 tot 22
      setcolor("W+/N")
      @ 2,0,22,79 box "±±±±±±±±±"

      // Instruksielyne
      fScrBood(23)
      fScrBood(24)

   elseif nSet = 1

      // Teken slegs die gebruiker naam lyn
      fScrBood( 1, " "+cGebNaam, cColHead, 1 )

      fScrWord( 1, 79-len(fDtow(dAppDate)), fDtow(dAppDate), cColHead )

   endif

   setcolor(cOldColor)

return NIL

/**************************************************************************/
FUNCTION fScrBood( nLine, cBood, cColor, nType )

/*
Funksie om lyn op enige plek van die skerm te vertoon
nLine = Op watter skermlyn (NIL = 24)
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott)
nType = Tipe (NIL = 0 = Centre) (1 = Left justify) (2 = Right justify)
*/

   LOCAL cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, 24, nLine )
   cBood := if( cBood == NIL, space(80), cBood )
   cColor := if( cColor == NIL, cColBott, cColor )
   nType := if( nType == NIL, 0, nType)

   cOldColor := SETCOLOR(cColor)

   // Boodskap tipe
   if nType = 1
      // Left
      cBood := padr( cBood, 80 )
   elseif nType = 2
      // Right
      cBood := padl( cBood, 80 )
   else
      // Centre
      cBood := padc( cBood, 80 )
   endif

   // Teken lyn
   @ nLine, 0 say cBood

   setcolor(cOldColor)
return NIL

/*************************************************************************/
FUNCTION fScrWbood( nLine, cBood, cColor, nType )

/*
Funksie om lyn op enige plek van die skerm te vertoon
nLine = Op watter skermlyn (NIL = 24)
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott)
nType = Tipe (NIL = 0 = Centre) (1 = Left justify) (2 = Right justify)
*/

   local cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, 24, nLine )
   #ifdef AFR
      cBood := if( cBood == NIL, "Wag asseblief!", cBood + " ... wag asseblief!" )
   #else
      cBood := if( cBood == NIL, "Please wait!", cBood + " ... please wait!" )
   #endif
   cColor := if( cColor == NIL, cColBott, cColor )
   nType := if( nType == NIL, 0, nType)

   cOldColor := setcolor(cColor)

   // Boodskap tipe
   if nType = 1
      // Left
      cBood := padr( cBood, 80 )
   elseif nType = 2
      // Right
      cBood := padl( cBood, 80 )
   else
      // Centre
      cBood := padc( cBood, 80 )
   endif

   // Teken lyn
   @ nLine, 0 say cBood

   setcolor(cOldColor)
return NIL

/*************************************************************************/
FUNCTION fScrWait( nLine, cBood, cColor, nType, nTime, lTone )

/*
Funksie om lyn op enige plek van die skerm te vertoon en dan te wag vir
enige sleutel.
nLine = Op watter skermlyn (NIL = 24)
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott)
nType = Tipe (NIL = 0 = Centre) (1 = Left justify) (2 = Right justify)
*/

   local cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, 24, nLine )
   #ifdef AFR
      cBood := if( cBood == NIL, "Druk enige sleutel . . .", trim( cBood ) + " ... Druk enige sleutel." )
   #else
      cBood := if( cBood == NIL, "Press any key . . .", trim( cBood ) + " ... Press any key." )
   #endif
   cColor := if( cColor == NIL, cColBott, cColor )
   nType := if( nType == NIL, 0, nType)
   nTime := if( nTime == NIL, 0, nTime)
   lTone := if( lTone == NIL, .t., lTone )

   cOldColor := setcolor(cColor)

   //Moet Tone gespeel word
   if lTone
      tone( 300, 1 )
   endif

   // Boodskap tipe
   if nType = 1
      // Left
      cBood := padr( cBood, 80 )
   elseif nType = 2
      // Right
      cBood := padl( cBood, 80 )
   else
      // Centre
      cBood := padc( cBood, 80 )
   endif

   // Teken lyn
   @ nLine, 0 say cBood

   // Wag
   inkey(nTime)

   setcolor(cOldColor)
return NIL

/*************************************************************************/
FUNCTION fScrWord( nLine, nColum, cBood, cColor)

/*
Funksie om lyn op enige plek van die skerm te vertoon
nLine = Op watter skermlyn (NIL = 24)
nColum = Op watter kolom (NIL = 79)
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott)
*/

   local cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, 24, nLine )
   nColum := if( nColum == NIL, 79, nColum )
   cBood := if( cBood == NIL, "", cBood )
   cColor := if( cColor == NIL, cColBott, cColor )

   cOldColor := setcolor(cColor)

   // Teken lyn
   @ nLine, nColum say cBood

   setcolor(cOldColor)
return NIL

/*************************************************************************/
FUNCTION fDtow( dDate )

/*
Funksie om enige datum na woorde te verander
*/
   local cConvDate,cDay,cMon,cYear

   dDate := if(dDate == NIL, date(), dDate )

   // Dag
   cDay := str( day( dDate ), 2, 0)

   // Maand
   do case
         #ifdef AFR
         case month( dDate ) = 1
            cMon := "Januarie"
         case month( dDate ) = 2
            cMon := "Februarie"
         case month( dDate ) = 3
            cMon := "Maart"
         case month( dDate ) = 4
            cMon := "April"
         case month( dDate ) = 5
            cMon := "Mei"
         case month( dDate ) = 6
            cMon := "Junie"
         case month( dDate ) = 7
            cMon := "Julie"
         case month( dDate ) = 8
            cMon := "Augustus"
         case month( dDate ) = 9
            cMon := "September"
         case month( dDate ) = 10
            cMon := "Oktober"
         case month( dDate ) = 11
            cMon := "November"
         case month( dDate ) = 12
            cMon := "Desember"
         #else
         case month( dDate ) = 1
            cMon := "January"
         case month( dDate ) = 2
            cMon := "February"
         case month( dDate ) = 3
            cMon := "March"
         case month( dDate ) = 4
            cMon := "April"
         case month( dDate ) = 5
            cMon := "May"
         case month( dDate ) = 6
            cMon := "June"
         case month( dDate ) = 7
            cMon := "July"
         case month( dDate ) = 8
            cMon := "August"
         case month( dDate ) = 9
            cMon := "September"
         case month( dDate ) = 10
            cMon := "October"
         case month( dDate ) = 11
            cMon := "November"
         case month( dDate ) = 12
            cMon := "December"
         #endif
   endcase

   // Jaar
   cYear := str(year(dDate),4,0)

   //if cTaaVoor = "A"
   cConvDate := cDay + " " + cMon + " " + cYear
   //else
   //   cConvDate := cMon + " " + cDay + " " + cYear
   //endif

RETURN cConvDate

/***************************************************************************/
FUNCTION fBoxShadow( nTop, nLeft, nBottom, nRight );

      LOCAL nShadTop, nShadLeft, nShadBottom, nShadRight

   nShadTop   := nShadBottom := MIN(nBottom + 1, MAXROW())
   nShadLeft  := nLeft + 1
   nShadRight := MIN(nRight + 1, MAXCOL())

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
      TRANSFORM( SAVESCREEN(nShadTop, nShadLeft, nShadBottom, nShadRight),;
      REPLICATE("X", nShadRight - nShadLeft + 1 ) ) )

   nShadTop    := nTop + 1
   nShadLeft   := nShadRight := MIN(nRight + 1, MAXCOL())
   nShadBottom := nBottom

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
      TRANSFORM( SAVESCREEN(nShadTop,  nShadLeft , nShadBottom,  nShadRight),;
      REPLICATE("X", nShadBottom - nShadTop + 1 ) ) )

RETURN NIL

/***************************************************************************/
FUNCTION fBoxCent( nLine, cBood, nAmount, cHeading, cColor )
/*
Funksie om die koordinate van 'n boodskaplyn te bereken en die
box te vertoon
*/

   local nTop, nLeft, nBottom, nRight

   nLine := if( nLine == NIL, 12, nLine )
   cBood := if( cBood == NIL, space(40), cBood )
   nAmount := if( nAmount == NIL, 1, nAmount )
   cHeading := if( cHeading == NIL, "", cHeading )
   cColor := if( cColor == NIL, cColNorm, cColor )

   // Bepaal koordinate
   nTop := nLine - 1
   nLeft := 39 - ( len(cBood) / 2 ) - 2
   nBottom := nLine + (nAmount-1) + 1
   nRight := nLeft + len(cBood) + 4

   // Teken die box
   fBox ( nTop, nLeft, nBottom, nRight, cHeading, cColor )

return nLeft + 2

/***************************************************************************/
FUNCTION fBox( nTop, nLeft, nBottom, nRight, cHeading, cColor )

   local cOldColor, cBoxChar := "ÕÍ¸³¾ÍÔ³"

   // Toets of koordinate bestaan
   nTop := if( nTop = NIL, 3, nTop )
   nLeft := if( nLeft = NIL, 3, nLeft )
   nBottom := if( nBottom = NIL, 20, nBottom )
   nRight := if( nRight = NIL, 76, nRight )
   cHeading := if( cHeading = NIL, "", cHeading )
   cColor := if( cColor = NIL, cColNorm, cColor )

   // Bewaar vorige skermkleur
   cOldcol := SETCOLOR( cColor )

   // Vertoon die raam
   @ nTop, nLeft, nBottom, nRight BOX cBoxchar+SPACE(1)
   if len(trim(cHeading)) > 0
      SETCOLOR( cColHead )
      @ nTop, nLeft + 2 SAY " " + ALLTRIM(UPPER(cHeading)) + " "
      SETCOLOR( cColor )
   endif

   // Vertoon 'n skaduwee van die raam
   fBoxShadow( nTop, nLeft, nBottom, nRight )

RETURN NIL

/***************************************************************************/
FUNCTION fPrnReady

/*
Funksie om te toets of die drukker gereed is of nie.
---> return nKeyPress
*/

   LOCAL nKeyPress := 0

   IF !( isprinter() )
      #ifdef AFR
         fScrBood( 24, "Drukker is nie gereed nie!  Skakel drukker aan of druk [Esc]." )
      #else
         fScrBood( 24, "Printer is not ready! Switch printer on or press [Esc]." )
      #endif
   ENDIF

   DO WHIL !( isprinter() ) .and. nKeyPress <> 27
      nKeyPress = INKEY()
   ENDDO

   fScrBood( 24 )

RETURN nKeyPress

/***************************************************************************/
FUNCTION fPrnOn(nPort)

/*
Funksie om drukker aan te skakel
*/

   if !empty(nPort)
      if nPort == 2
         set printer to LPT2
      elseif nPort == 3
         set printer to LPT3
      else
         set printer to LPT1
      endif
   endif
   set device to print
   set console off

RETURN NIL

/***************************************************************************/
FUNCTION fPrnOff

/*
Funksie om drukker af te skakel
*/

   set printer to
   set device to screen
   set console on

RETURN NIL

/***************************************************************************/
FUNCTION fPercent( nTop, nBottom )

/*
Funksie om 'n persentasiewaarde te bereken van twee syfers
en 'n character waarde terug te stuur
*/

   // Toets of albei waardes het
   nTop := if( nTop==NIL, 1, nTop )
   nBottom := if( nBottom==NIL, 1, nBottom )

   //Onder mag nie nul wees nie
   if nBottom == 0
      nBottom := 1
   endif

RETURN alltrim( str( int( (nTop/nBottom)*100 ), 3, 0 ) )

/***************************************************************************/
FUNCTION fPrnStop

/*
Funksie om die drukker te stop indien esc gedruk was
*/

   LOCAL nKeyPress

   nKeyPress := inkey()

   if nKeyPress = 27
      @ prow()+1, 1 say &cPrnNorm
      #ifdef AFR
         @ prow()+2, 1 say "Verslag doelbewus be‰indig!"
      #else
         @ prow()+2, 1 say "Report purposely stopped!"
      #endif
      @ prow()+3, 1 say cAppName
      //Ejec
      @ prow()+(nPrnLeng-prow()),1 say ""
      setprc( 0, 0 )
      fPrnOff()
   endi

RETURN nKeyPress

/***************************************************************************/
FUNCTION fJaNee( nLyn, cBood, cColor, lLogic )

/*
Funksie om op enige lyn van die skerm enige boodskap te vertoon met
'n (JA) of (Nee) vraag daarna. Die funksie stuur dan 'n logiese ant-
woord terug
*/

   LOCAL cOldCol, cOldScr, lReturn, nKeyPress

   // Kyk of al die waardes bestaan
   nLyn := if( nLyn = NIL, 24, nLyn )
   cBood := if( cBood = NIL, "", cBood )
   cColor := if( cColor = NIL, cColBott, cColor )
   lLogic := if( lLogic == NIL, .t., lLogic )

   // Bewaar huidige waardes
   cOldCol := setcolor( cColor )
   cOldScr := savescreen( 23, 0, 24, 79 )
   lReturn := .f.

   // Teken skerm
   if lLogic
      fScrBood( 23 )
   endif
   #ifdef AFR
      fScrBood( nLyn, cBood + " (J)a (N)ee" )
   #else
      fScrBood( nLyn, cBood + " (Y)es (N)o" )
   #endif

   // Wag vir sleuteldruk
   nKeyPress := inkey(0)

   // Indien wel J
   if nKeyPress = K_UP_J .or. nKeyPress = K_LO_J .or. nKeyPress = K_UP_Y .or. nKeyPress = K_LO_Y
      lReturn = .t.
   endif

   // Herstel
   setcolor( cOldCol )
   restscreen( 23, 0, 24, 79, cOldScr )

return lReturn

/**************************************************************************/
FUNCTION fCurScreen

/*
Funksie om die huidige waardes van skerm te bewaar
*/

   local cStack := ""

   cStack := chr( set( _SET_CURSOR ) ) + ;
      chr( row() ) + ;
      chr( col() ) + ;
      pad( setcolor(), 20 )

return cStack

/**************************************************************************/
FUNCTION fSetScreen( cStack )

/*
Funksie om die huidige waardes van 'n skerm te herstel
*/

   // Herstel skerm waardes
   setcursor( asc( substr( cStack, 1, 1 ) ) )
   @ asc( substr( cStack, 2, 1 ) ), ;
      asc( substr( cStack, 3, 1 ) ) say ""
   setcolor( substr( cStack, 4, 20 ) )

return NIL

/*************************************************************************/
FUNCTION ForceStable(browse)

   //Force a complete stabilization of a TBrowse.

   do while .not. browse:stabilize()
   enddo

return NIL

/**************************************************************************/
FUNCTION ApplyKey(browse, nKey)

   //Apply one keystroke to the browse.

   DO CASE
      CASE nKey == K_DOWN
         browse:down()
      CASE nKey == K_PGDN
         browse:pageDown()
      CASE nKey == K_CTRL_PGDN
         browse:goBottom()
      CASE nKey == K_UP
         browse:up()
      CASE nKey == K_PGUP
         browse:pageUp()
      CASE nKey == K_CTRL_PGUP
         browse:goTop()
      CASE nKey == K_RIGHT
         browse:right()
      CASE nKey == K_LEFT
         browse:left()
      CASE nKey == K_HOME
         browse:home()
      CASE nKey == K_END
         browse:end()
      CASE nKey == K_CTRL_LEFT
         browse:panLeft()
      CASE nKey == K_CTRL_RIGHT
         browse:panRight()
      CASE nKey == K_CTRL_HOME
         browse:panHome()
      CASE nKey == K_CTRL_END
         browse:panEnd()
   ENDCASE

return NIL

/**************************************************************************/
FUNCTION fPrnCod( cCtrlCode )
   LOCAL nRow, nCol, lPrinter
   lPrinter := SET(_SET_PRINTER, .T.)            // SET PRINTER ON
   nRow = PROW()                                 // Save printhead position
   nCol = PCOL()
   //
   ?? cCtrlCode                                  // Send control code
   //
   SETPRC(nRow, nCol)
   SET(_SET_PRINTER, lPrinter)                   // Restore printer setting
RETURN ""                                        // Return a null ("") string

//****************************************************************************
FUNCTION tBrowseArray( nTr, nLc, nBr, nRc, aArray, bGetSetIndex )

   //Create a generic tBrowse

   //Veranderlikes
   local tB := tBrowseNew( nTr, nLc, nBr, nRc )

   //Waardes
   if eval( bGetSetIndex ) == NIL
      eval( bGetSetIndex, 1 )
   endif

   //Top of array : element == 1
   tB:goTopBlock := {|| eval( bGetSetIndex, 1 ) }

   //Bottom of array
   tB:goBottomBlock := {|| eval( bGetSetIndex, len( aArray ) ) }

   //Movement in array : based on amount to move and current element
   tB:skipBlock := {|nMove| skipelement( nMove, aArray, bGetSetIndex ) }

   //Herstel
return tB

//****************************************************************************
STATIC FUNCTION skipelement( nMove, aArray, bIndex )

   //Source file is tBrowseArray()

   if nMove > 0
      //Move down requested amount or as much as possible
      nMove := min( nMove, len( aArray ) - eval( bIndex ) )
   else
      //Move up requested amount
      nMove := max( nMove, 1 - eval( bIndex ) )
   endif

   //Set current element to new position
   eval( bIndex, eval( bIndex ) + nMove )

   //Herstel - return amount moved
return nMove

//**************************************************************************
FUNCTION ZER(n1,n2)
   local nResult := 0
   if n2 <> 0
      nResult := n1/n2
   endif
   //@23,0 say ltrim(str(n1))
   //@24,0 say ltrim(str(n2))
   //inkey(0)
return nResult
