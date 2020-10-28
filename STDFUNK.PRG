// Application: StudMaster for Beef Cattle
//   File Name: STDFUNK.PRG
// Description: Standard functions
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-23-94      01:22:29pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION fScrOpsk( nSett, cBood )

   // Function to paint the complete screen

   // nSett values
   // 0, NIL = Complete screen
   // 1      = Line 1 only

   // Declare
   local cOldc := setcolor()
   local cData := ""
   local i     := 0

   // Values
   nSett := IF(empty(nSett), 0,nSett)
   cBood := if(empty(cBood),"",cBood)

   if nSett = 0

      // Whole screen
      if empty(cAgtChar())
         dispbox(0,0,maxrow(),maxcol(),"         ",cColAgte())
      else
         for i := 1 to 9
            cData += cAgtChar()
         next
         dispbox(0,0,maxrow(),maxcol(),cData,cColAgte())
      endif

      // Top line
      if cLanType() == "A"
         fScrBood(0,trim(cAppName())+". Kopiereg ADC 1987-"+left(dtos(dAppDate()),4)+". Alle Regte Voorbehou.", cColTopl() )
      else
         fScrBood(0,trim(cAppName())+". Copyright ADC 1987-"+left(dtos(dAppDate()),4)+". All Rights Reserved.", cColTopl() )
      endif

      // Heading line
      fScrBood( 1, " "+cGebNaam(), cColHead(), 1 )
      fScrWord( 1, maxcol()-len(fDtow(dAppDate())), fDtow(dAppDate()), cColHead() )
      if !empty(cBood)
         cBood := " "+cBood+" "
         fScrWord( 1, int(maxcol()/2)-int(len(cBood)/2), cBood, cColHead() )
      endif

      // Instruction lines
      fScrBood(maxrow()-1)
      fScrBood(maxrow())

   elseif nSett = 1

      // Teken slegs die gebruiker naam lyn
      cBood := PADR(cGebNaam(),MAXCOL()/2-LEN(cBood)/2," ")+ALLTRIM(cBood)
      fScrBood( 1, cBood, cColHead(), 1)
      fScrWord( 1, maxcol()-len(fDtow(dAppDate())), fDtow(dAppDate()), cColHead() )

   endif

   setcolor(cOldc)

return NIL

/**************************************************************************/
FUNCTION fScrBood( nLine, cBood, cColor, nType )

/*
Funksie om lyn op enige plek van die skerm te vertoon
nLine = Op watter skermlyn (NIL = maxrow())
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott())
nType = Tipe (NIL = 0 = Centre) (1 = Left justify) (2 = Right justify)
*/

   LOCAL cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, maxrow(), nLine )
   cBood := if( cBood == NIL, space(80), cBood )
   cColor := if( cColor == NIL, cColBott(), cColor )
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
   if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
      @ nLine,75 say str(memory(0),4,0)
   endif

   setcolor(cOldColor)
return NIL

/*************************************************************************/
FUNCTION fScrWbood( nLine, cBood, cColor, nType )

/*
Funksie om lyn op enige plek van die skerm te vertoon
nLine = Op watter skermlyn (NIL = maxrow())
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott())
nType = Tipe (NIL = 0 = Centre) (1 = Left justify) (2 = Right justify)
*/

   local cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, maxrow(), nLine )
   if cLanType() == "A"
      cBood := if( cBood == NIL, "Wag asseblief!", cBood + " ... wag asseblief!" )
   else
      cBood := if( cBood == NIL, "Please wait!", cBood + " ... please wait!" )
   endif
   cColor := if( cColor == NIL, cColBott(), cColor )
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
   if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
      @ nLine,75 say str(memory(0),4,0)
   endif

   setcolor(cOldColor)
return NIL

/*************************************************************************/
FUNCTION fScrWait( nLine, cBood, cColor, nType, nTime, lTone )

/*
Funksie om lyn op enige plek van die skerm te vertoon en dan te wag vir
enige sleutel.
nLine = Op watter skermlyn (NIL = maxrow())
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott())
nType = Tipe (NIL = 0 = Centre) (1 = Left justify) (2 = Right justify)
*/

   local cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, maxrow(), nLine )
   if cLanType() == "A"
      cBood := if( cBood == NIL, "Druk enige sleutel . . .", trim( cBood ) + " ... Druk enige sleutel." )
   else
      cBood := if( cBood == NIL, "Press any key . . .", trim( cBood ) + " ... Press any key." )
   endif
   cColor := if( cColor == NIL, cColBott(), cColor )
   nType := if( nType == NIL, 0, nType)
   nTime := if( nTime == NIL, 0, nTime)
   lTone := if( lTone == NIL, FALSE, lTone )

   cOldColor := setcolor(cColor)

   //Moet Tone gespeel word
   //if lTone
   //   tone( 300, 1 )
   //endif

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
   if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
      @ nLine,75 say str(memory(0),4,0)
   endif

   // Wag
   inkey(nTime)

   setcolor(cOldColor)

return NIL

/*************************************************************************/
FUNCTION fScrWord( nLine, nColum, cBood, cColor)

/*
Funksie om lyn op enige plek van die skerm te vertoon
nLine = Op watter skermlyn (NIL = maxrow())
nColum = Op watter kolom (NIL = maxcol())
cBood = Boodskap (NIL = Blank)
cColor = Kleur (NIL = cColBott())
*/

   local cOldColor

   // Indien geen waardes
   nLine := if( nLine == NIL, maxrow(), nLine )
   nColum := if( nColum == NIL, maxcol(), nColum )
   cBood := if( cBood == NIL, "", cBood )
   cColor := if( cColor == NIL, cColBott(), cColor )

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
   if cLanType() == "A"
      do case
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
      endcase
   else
      do case
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
      endcase
   endif

   // Jaar
   cYear := str( year( dDate ), 4, 0 )

   //if cTaaVoor = "A"
   cConvDate := cDay + " " + cMon + " " + cYear
   //else
   //   cConvDate := cMon + " " + cDay + " " + cYear
   //endif

RETURN cConvDate

/*************************************************************************/
FUNCTION fMonn( cDate )

/*
Funksie om maand om te skakel na numeries
*/
   // Declare
   local dRetu,cDay,cMon,cYear,nPos1,nPos2

   // Populate local if empty
   cDate := if(cDate == NIL, "00-000-00", cDate )
   nPos1 := at("-",cDate)
   nPos2 := rat("-",cDate)

   // Dag
   cDay := substr(cDate,1,nPos1-1)

   // Maand
   do case
      case upper(substr(cDate,nPos1+1,3)) = "JAN"
         cMon := "01"
      case upper(substr(cDate,nPos1+1,3)) = "FEB"
         cMon := "02"
      case upper(substr(cDate,nPos1+1,3)) = "MAR"
         cMon := "03"
      case upper(substr(cDate,nPos1+1,3)) = "APR"
         cMon := "04"
      case upper(substr(cDate,nPos1+1,3)) = "MAY"
         cMon := "05"
      case upper(substr(cDate,nPos1+1,3)) = "JUN"
         cMon := "06"
      case upper(substr(cDate,nPos1+1,3)) = "JUL"
         cMon := "07"
      case upper(substr(cDate,nPos1+1,3)) = "AUG"
         cMon := "08"
      case upper(substr(cDate,nPos1+1,3)) = "SEP"
         cMon := "09"
      case upper(substr(cDate,nPos1+1,3)) = "OCT"
         cMon := "10"
      case upper(substr(cDate,nPos1+1,3)) = "NOV"
         cMon := "11"
      case upper(substr(cDate,nPos1+1,3)) = "DEC"
         cMon := "12"
   endcase

   // Jaar
   cYear := substr(cDate,nPos2+1,2)


   dRetu := ctod(cDay + "/" + cMon + "/" + cYear)

RETURN dRetu


/**************************************************************************/
FUNCTION fNewMenu( nChoice, cMenuNaam, cMenuCol, aMenu )

   LOCAL cOldCol, nTop, nLeft, nBottom, nRight
   LOCAL cBoxScr, cBoxChar
   LOCAL nMenuRow, nMenuCol
   local i := 0

   // Toets of menunaam wel gegee is
   if cMenuNaam == NIL .and. aMenu == NIL
      return 0
   endif

   // Kyk of parameters wel gegee is
   nChoice := if( nChoice==NIL, 1, nChoice )
   cMenuCol := if( cMenuCol==NIL, cColMenu(), cMenuCol )

   // Ander veranderlikes
   cBoxChar := "ÕÍ¸³¾ÍÔ³"

   if aMenu == NIL
      aMenu := fBouMenu(cMenuNaam)
   endif

   // Bewaar vorige skermkleur
   cOldCol := SETCOLOR( cMenuCol )

   //Bepaal die vier venster koordinate
   nTop    := aMenu[1,4]
   nLeft   := aMenu[1,5]
   nBottom := nTop + LEN( aMenu ) + 1
   nRight  := nLeft + LEN( aMenu[1,2] ) + 3

   // Vertoon die raam
   @ nTop, nLeft, nBottom, nRight BOX cBoxchar + space(1)
   SETCOLOR( cColHead() )
   if len(trim(aMenu[1,1])) > 0
      @ nTop, nLeft + 2 say " " + trim(upper(aMenu[1,1])) + " "
   endif
   SETCOLOR( cMenuCol )

   // Vertoon 'n skaduwee van die raam
   fBoxShadow( nTop, nLeft, nBottom, nRight )

   // Bepaal die begin ry en kolom van die eerste opsie
   // om sodoende die menu te sentreer
   nMenuRow := nTop + 1                          //int( ( ( nBottom - nTop ) - len( aMenu ) ) / 2 ) + 1
   nMenuCol := nLeft + 2                         //int( ( ( nRight - nLeft ) - len( aMenu[nChoice,2] ) ) / 2 ) + 1

   // Vertoon keuses
   for i := 1 to len( aMenu )
      @ nMenuRow++, nMenuCol prompt aMenu[i,2] message padc(aMenu[i,3],80)
   next

   // Kry die keuse
   menu to nChoice

   // Reset the old color
   setcolor( cOldCol )

return nChoice

/******************************************************************************/
FUNCTION fBouMenu(cMenunaam)

   // Function to open the menu file

   // Declare
   local aMenu := {}
   local aCdbf := fATopen()
   begin sequence

      // Open file
      aCdbf := fATopen(aCdbf,,"STDMENU",,"tdb")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      aMenu = fGetPrompt(cMenunaam)

   end

   // Reset
   fATclose(aCdbf)

return aMenu

/******************************************************************************/
FUNCTION fGetPrompt(cMenunaam)

   // Function to build the array

   #define INKEY_VAL(cMenunaam) PAD(UPPER(cMenunaam), LEN(stdmenu->mennaam))

   // Declare
   local aMenu   := {}
   local nCrec   := recno()
   local bWhiArg := NIL
   local nArrLen := 0
   local i       := 0
   begin sequence

      seek INKEY_VAL(cMenunaam)

      bWhiArg := {||INKEY_VAL(stdmenu->mennaam) == INKEY_VAL(cMenunaam)}

      if cLanType() == "A"
         dbeval({||aadd(aMenu, {stdmenu->menopsk,;
            trim(stdmenu->menopsi),;
            trim(stdmenu->menbood),;
            stdmenu->menrows,stdmenu->mencols} )},,bWhiArg)
      else
         dbeval({||AADD(aMenu, {stdmenu->menhead,;
            trim(stdmenu->menprom),;
            trim(stdmenu->menmess),;
            stdmenu->menrows,stdmenu->mencols} )},,bWhiArg)
      endif

      // Get the longest array
      for i = 1 to len( aMenu )
         nArrLen := max( nArrLen, len( aMenu[i,2] ) )
      next

      // Is the heading longer?
      nArrLen := max( nArrLen, len( trim( aMenu[1,1] ) ) + 2 )

      // Pad the array prompts
      for i = 1 to len( aMenu )
         aMenu[i,2] := padr( aMenu[i,2], nArrLen )
      next

   end

   // Reset
   goto nCrec

return aMenu

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
   cColor := if( cColor == NIL, cColNorm(), cColor )

   // Bepaal koordinate
   nTop := nLine - 1
   nLeft := 39 - ( len(cBood) / 2 ) - 2
   nBottom := nLine + (nAmount-1) + 1
   nRight := nLeft + len(cBood) + 4

   // Teken die box
   fBox ( nTop, nLeft, nBottom, nRight, cHeading, cColor )

return nLeft + 2

/******************************************************************************/
FUNCTION fBox( nTop, nLeft, nBottom, nRight, cHeading, cColor, lShadow )

   // Declare
   local cOldCol
   local cBoxChar := "ÕÍ¸³¾ÍÔ³"

   // Toets of koordinate bestaan
   nTop := if( nTop = NIL, 3, nTop )
   nLeft := if( nLeft = NIL, 3, nLeft )
   nBottom := if( nBottom = NIL, 20, nBottom )
   nRight := if( nRight = NIL, 76, nRight )
   cHeading := if( cHeading = NIL, "", cHeading )
   cColor := if( cColor = NIL, cColNorm(), cColor )
   lShadow := iif(lShadow=NIL,TRUE,lShadow)

   // Bewaar vorige skermkleur
   cOldcol := SETCOLOR( cColor )

   // Vertoon die raam
   @ nTop, nLeft, nBottom, nRight BOX cBoxchar+SPACE(1)
   if len(trim(cHeading)) > 0
      SETCOLOR( cColHead() )
      @ nTop, nLeft + 2 SAY " " + ALLTRIM(UPPER(cHeading)) + " "
      SETCOLOR( cColor )
   endif

   // Vertoon 'n skaduwee van die raam
   if lShadow
      fBoxShadow( nTop, nLeft, nBottom, nRight )
   endif

RETURN NIL

/******************************************************************************/
FUNCTION fPrnReady(nLine)

/*
Funksie om te toets of die drukker gereed is of nie.
---> return nKeyPress
*/

   LOCAL cDevice   := "LPT"+ALLTRIM(STR(nPrnLptp(),4,0))
   LOCAL nKeyPress := 0

   IF nLine != NIL
      fScrBood(nLine)
   ENDIF

   if nPrnLptp() < 8

      // Normal print to printer

      SET(_SET_PRINTFILE,cDevice)

      IF ! ( PRINTREADY( nPrnLptp()) )
         IF cLanType() == "A"
            fScrBood( maxrow(), "Drukker is nie gereed nie!  Skakel drukker aan of druk [Esc]." )
         ELSE
            fScrBood( maxrow(), "Printer is not ready! Switch printer on or press [Esc]." )
         ENDIF
      ENDIF

      DO WHILE ! ( PRINTREADY(nPrnLptp()) ) .AND. nKeyPress <> 27
         nKeyPress = INKEY()
      ENDDO

      //PRINTSEND( &(cPrnInit()), nPrnLptp() )       // Initialize the printer
      fScrBood( MAXROW() )

   else

      // Printing to wordpad file


   endif


RETURN nKeyPress

/***************************************************************************/
FUNCTION fPrnOn(cFile,lAddi)

   // Funksie om drukker aan te skakel

   local cData := ""

   static nSecs

   if nPrnLptp() < 8

      // Values
      lAddi := iif(lAddi==NIL,FALSE,lAddi)

      if cFile == NIL
         //Drukker
         if nPrnLptp() == 2
            set printer to LPT2
         elseif nPrnLptp() == 3
            set printer to LPT3
         elseif nPrnLptp() == 4
            set printer to LPT4
         else
            set printer to LPT1
         endif
         set printer on
         set device to print
         set console off
         //fPrnCod(cPrnInit())
      else
         // Leer
         if lAddi
            set printer to (cFile) additive
         else
            set printer to (cFile)
         endif
         set device to print
         set console off
      endif

   else

      // Wordpad file

      //if empty(nSecs)
      //   nSecs := seconds() - 10
      //endif

      //if seconds() - nSecs < 5
      //
      //   // Carry on with previous printout
      //   set printer to "Output.dat" additive
      //   set device to print
      //   set console off
      //   setprc(0,0)
      //   pPrnAddi := .t.
      //
      //else

      // Start new printout
      set printer to "Output.dat"
      set device to print
      set console off
      setprc(0,0)
      // pPrnAddi := .f.

      //endif

      //nSecs := seconds()

   endif


RETURN NIL

/***************************************************************************/
FUNCTION fPrnOff(cFile)

   // Funksie om drukker af te skakel

   local cChar := ""
   local cData := ""
   local nOldf := 0
   local nNewf := 0
   local lLoop := .t.
   local aFile := {}
   local aScrn := {}

   if nPrnLptp() < 8

      // Normal printer

      if cFile == NIL
         //Drukker
         set device to screen
         set console on
         set printer off
      else
         //Leer
      endif

   elseif nPrnLptp() = 8

      // Usb printer

      // Disable printer
      set device to screen
      set console on
      set printer off

      // See if printt.exe exist
      if file("printt.exe")
         swpruncmd("printt.exe")
      else
         IF cLanType() == "A"
            fScrBood(maxrow()-1,"PRINTT.EXE Program kon nie opgespoor word nie!")
         else
            fScrBood(maxrow()-1,"PRINTT.EXE Program could not be located!")
         endif
         fScrWait(maxrow())
      endif

   else

      // Wordpad document

      set printer to
      set device to screen
      set console on


      nOldf := fopen("Output.dat")
      if nOldf == -1
         // Error opening file
      else
         // Rename previous .rtf files
         if file("Wordpad5.rtf")
            // Delete the file
            ferase("Wordpad5.rtf")
         endif
         if file("Wordpad4.rtf")
            // Rename the file
            frename("Wordpad4.rtf","Wordpad5.rtf")
         endif
         if file("Wordpad3.rtf")
            // Rename the file
            frename("Wordpad3.rtf","Wordpad4.rtf")
         endif
         if file("Wordpad2.rtf")
            // Rename the file
            frename("Wordpad2.rtf","Wordpad3.rtf")
         endif
         if file("Wordpad1.rtf")
            // Rename the file
            frename("Wordpad1.rtf","Wordpad2.rtf")
         endif
         if file("Wordpad.rtf")
            // Rename the file
            frename("Wordpad.rtf","Wordpad1.rtf")
         endif
         // Carry on to convert file
         nNewf := fcreate("Wordpad.rtf")
         if nNewf == -1
            // Cannot open new file
         else
            // Carry on creating the new file

            // Write the intial line
            cData := "{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fmodern\fprq1\fcharset0 Courier New Bold;}{\f1\fnil\fprq2\fcharset0 BaseMonoNarrowReg;}}"+chr(13)+chr(10)
            fwrite(nNewf,cData)

            // Read characters from text file
            cData := ""
            do while lLoop

               cChar := freadstr(nOldf,1)
               if cChar == ""
                  lLoop := .f.
                  cData += "}"+chr(13)+chr(10)
                  fwrite(nNewf,cData)
               else
                  cData += cChar
                  // @maxrow(),1 say asc(right(cData,1))
                  if right(cData,1) == chr(10)
                     if right(cData,7) == "\page"+chr(13)+chr(10)
                        fwrite(nNewf,cData)
                        cData := ""
                     elseif right(cData,10) == "\f1\fs16"+chr(13)+chr(10)
                        cData := left(cData,len(cData)-2)
                        cData += "\par"+chr(13)+chr(10)
                        fwrite(nNewf,cData)
                        cData := ""
                     elseif right(cData,10) == "\f0\fs22"+chr(13)+chr(10)
                        cData := left(cData,len(cData)-2)
                        cData += "\par"+chr(13)+chr(10)
                        fwrite(nNewf,cData)
                        cData := ""
                     else
                        // Normal line end
                        cData := left(cData,len(cData)-2)
                        cData += "\par"+chr(13)+chr(10)
                        fwrite(nNewf,cData)
                        cData := ""
                     endif
                  endif
               endif

            enddo
            fclose(nNewf)
         endif
         fclose(nOldf)
      endif

      // Activate wordpad

      // See if wordpad.exe exist
      if file(cWordPad()+"wordpad.exe")
         if upper(left(cPrnInit(),2)) == "/P"
            overlay(cWordPad()+"wordpad.exe Wordpad.rtf /p",100)
         else
            overlay(cWordPad()+"wordpad.exe Wordpad.rtf",100)
         endif
      else
         IF cLanType() == "A"
            fScrBood(maxrow()-1,"WORDPAD.EXE Program kon nie opgespoor word nie!")
         else
            fScrBood(maxrow()-1,"WORDPAD.EXE Program could not be located!")
         endif
         fScrWait(maxrow())
      endif

   endif


return nil

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

RETURN ltrim( str( int( (nTop/nBottom)*100 ), 3, 0 ) )

/***************************************************************************/
FUNCTION fPrnStop

/*
Funksie om die drukker te stop indien esc gedruk was
*/

   LOCAL nKeyPress

   nKeyPress := inkey()

   if nKeyPress = 27
      @ prow()+1, 1 say fPrnCod( cPrnNorm() )
      if cLanType() == "A"
         @ prow()+2, 1 say "Verslag doelbewus be‰indig!"
      else
         @ prow()+2, 1 say "Report purposely stopped!"
      endif
      @ prow()+3, 1 say cAppName()
      fPrnEjec()
      fPrnOff()
   endif

RETURN nKeyPress

/******************************************************************************/
FUNCTION fPrnEjec( nLine )

   // Function to form feed the page

   if nPrnLptp() < 8
      if empty(cPrnInit())
         // Default values
         nLine := iif(empty(nLine),nPrnLeng(),nLine)
         @prow()+(nLine - prow()),1 say ""
         setprc( 0, 0 )
         if nPrnWait() > 0
            inkey(nPrnWait())
         endif
      else
         fPrnCod(cPrnInit())
         setprc( 0, 0 )
         if nPrnWait() > 0
            inkey(nPrnWait())
         endif
      endif
   else
      // Wordpad eject
      @prow(),pcol() say "\page"+chr(13)+chr(10)
      setprc( 0, 0 )
   endif

return NIL

/***************************************************************************/
FUNCTION fJaNee( nLyn, cBood, cColor, lLogic, lTone , cYesNo)

/*
Funksie om op enige lyn van die skerm enige boodskap te vertoon met
'n (JA) of (Nee) vraag daarna. Die funksie stuur dan 'n logiese ant-
woord terug
*/

   LOCAL cOldCol, cOldScr, lReturn, nKeyPress

   // Kyk of al die waardes bestaan
   nLyn := if( nLyn = NIL, maxrow(), nLyn )
   cBood := if( cBood = NIL, "", cBood )
   cColor := if( cColor = NIL, cColBott(), cColor )
   lLogic := if( lLogic == NIL, TRUE, lLogic )
   lTone  := if( lTone  == NIL, TRUE, lTone  )
   cYesNo := if( cYesNo == NIL, if(cLanType()=="A"," (J)a (N)ee"," (Y)es (N)o"), cYesNo)

   // Bewaar huidige waardes
   cOldCol := setcolor( cColor )
   cOldScr := savescreen( maxrow()-1, 0, maxrow(), maxcol() )
   lReturn := FALSE

   //Moet Tone gespeel word
   //if lTone
   //   tone( 300, 1 )
   //endif

   // Teken skerm
   if lLogic
      fScrBood( maxrow()-1 )
   endif
   fScrBood( nLyn, cBood + cYesNo )

   // Wag vir sleuteldruk
   nKeyPress := inkey(0)

   // Indien wel J
   if nKeyPress = K_UP_J .or. nKeyPress = K_LO_J .or. nKeyPress = K_UP_Y .or. nKeyPress = K_LO_Y
      lReturn = TRUE
   endif

   // Herstel
   setcolor( cOldCol )
   restscreen( maxrow()-1, 0, maxrow(), maxcol(), cOldScr )

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
      setcolor()

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
   setcolor( substr( cStack, 4, 40 ) )

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
FUNCTION fGetField( aVelde )

   //Funksie om enige .dbf leer se veldbeskrywings ens te kry

   LOCAL aFields := {}
   LOCAL cCurDbf := fTOpen()                     //Huidige .dbf leer
   LOCAL cCurScr := fCurScreen()                 //Huidige skerm waardes
   LOCAL cCurSke := savescreen( maxrow()-1, 0, maxrow(), maxcol() ) //Huidige skerm
   LOCAL cFielSt
   LOCAL lLogic
   LOCAL i
   LOCAL cSearch

   //Skerm
   //fScrBood( maxrow()-1, "" )
   if cLanType() == "A"
      //fScrWbood( maxrow(), "Opskrifte en Veldbeskrywings word opgesoek" )
   else
      //fScrWbood( maxrow(), "Headings and field descriptions being sorted" )
   endif

   //Open velde leer
   cFielSt := fTOpen( , "stdfiel", , "tdb", "stdfiel", TRUE, FALSE )
   if left( cFielSt, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, maxrow(), maxcol(), cCurSke )
      return aFields
   endif

   //Kry die velde
   for i = 1 to len(aVelde)

      cSearch := padr(upper(alltrim(aVelde[i,1])),8) + padr(upper(alltrim(aVelde[i,2])),10)

      seek cSearch

      if !eof()
         //Laai die databasis besonderhede
         if cLanType() == "A"
            aadd( aFields, { ;
               trim(stdfiel->dbfname) + "->",;
               trim(stdfiel->fldname),;          //2  Veldnaam
               stdfiel->fldtype,;                //3  Veldtipe
               stdfiel->fldleng,;                //4  Veldleng
               stdfiel->flddeci,;                //5  Velddesimaal
               padl(trim(stdfiel->fldbesk),20),; //6  Veldbeskrywing
               left(stdfiel->fldops1, stdfiel->fldleng),; //7  Opskrif 1
               left(stdfiel->fldops2, stdfiel->fldleng),; //8  Opskrif 2
               left(stdfiel->fldops3, stdfiel->fldleng),; //9  Opskrif 3
               trim(stdfiel->fldpict),;          //10 Picture
               0,;                               //11 Amount
               0,;                               //12 Total
               val(stdfiel->fldorde),;           //13 Field number
               NIL,;                             //14 Cargo
               trim(stdfiel->fldfunc) } )        //15 Function
         else
            aadd( aFields, { ;
               trim(stdfiel->dbfname) + "->",;
               trim(stdfiel->fldname),;          //2  Veldnaam
               stdfiel->fldtype,;                //3  Veldtipe
               stdfiel->fldleng,;                //4  Veldlengte
               stdfiel->flddeci,;                //5  Velddesimaal
               padl(trim(stdfiel->flddesc),20),; //6  Veldbeskrywing
               left(stdfiel->fldhed1, stdfiel->fldleng),; //7  Opskrif 1
               left(stdfiel->fldhed2, stdfiel->fldleng),; //8  Opskrif 2
               left(stdfiel->fldhed3, stdfiel->fldleng),; //9  Opskrif 3
               trim(stdfiel->fldpict),;          //10 Picture
               0,;                               //11 Amount
               0,;                               //12 Total
               val(stdfiel->fldorde),;           //13 Field number
               NIL,;                             //14 Cargo
               trim(stdfiel->fldfunc) } )        //15 Function
         endif
      endif

   next

   //Herstel
   fTClose( cFielSt )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( maxrow()-1, 0, maxrow(), maxcol(), cCurSke )
return aFields

/**************************************************************************/
FUNCTION fGetDbf(cDbfName)

   //Funksie om enige .dbf leer se veldbeskrywings ens te kry

   LOCAL aFiel := {}
   LOCAL cCdbf := fTOpen()
   LOCAL cCscr := fCurScreen()
   LOCAL cCske := savescreen( maxrow()-1, 0, maxrow(), maxcol() )
   LOCAL cFiel := ""

   //Open velde leer
   cFiel := fTOpen(,"stdfiel",,"tdb","stdfiel",TRUE,FALSE)
   if left(cFiel,1) == "f"
      fTClose(cCdbf)
      fSetScreen(cCscr)
      restscreen(0,0,maxrow(),maxcol(),cCske)
      return aFiel
   endif
   set order to 2

   //Kry die velde
   cDbfName := padr(upper(alltrim(cDbfName)),8)
   seek cDbfName
   do while trim(cDbfName) $ STDFIEL->dbfname

      //Laai die databasis besonderhede
      if cLanType() == "A"
         aadd( aFiel, { ;
            trim(stdfiel->dbfname) + "->",;
            trim(stdfiel->fldname),;             //2  Veldnaam
            stdfiel->fldtype,;                   //3  Veldtipe
            stdfiel->fldleng,;                   //4  Veldleng
            stdfiel->flddeci,;                   //5  Velddesimaal
            padl(trim(stdfiel->fldbesk),20),;    //6  Veldbeskrywing
            left(stdfiel->fldops1, stdfiel->fldleng),; //7  Opskrif 1
            left(stdfiel->fldops2, stdfiel->fldleng),; //8  Opskrif 2
            left(stdfiel->fldops3, stdfiel->fldleng),; //9  Opskrif 3
            trim(stdfiel->fldpict),;             //10 Picture
            0,;                                  //11 Amount
            0,;                                  //12 Total
            val(stdfiel->fldorde),;              //13 Field number
            NIL,;                                //14 Cargo
            trim(stdfiel->fldfunc) } )           //15 Function
      else
         aadd( aFiel, { ;
            trim(stdfiel->dbfname) + "->",;
            trim(stdfiel->fldname),;             //2  Veldnaam
            stdfiel->fldtype,;                   //3  Veldtipe
            stdfiel->fldleng,;                   //4  Veldlengte
            stdfiel->flddeci,;                   //5  Velddesimaal
            padl(trim(stdfiel->flddesc),20),;    //6  Veldbeskrywing
            left(stdfiel->fldhed1, stdfiel->fldleng),; //7  Opskrif 1
            left(stdfiel->fldhed2, stdfiel->fldleng),; //8  Opskrif 2
            left(stdfiel->fldhed3, stdfiel->fldleng),; //9  Opskrif 3
            trim(stdfiel->fldpict),;             //10 Picture
            0,;                                  //11 Amount
            0,;                                  //12 Total
            val(stdfiel->fldorde),;              //13 Field number
            NIL,;                                //14 Cargo
            trim(stdfiel->fldfunc) } )           //15 Function
      endif

      skip
   enddo

   //Herstel
   fTClose(cFiel)
   fTClose(cCdbf)
   fSetScreen(cCscr)
   restscreen(maxrow()-1,0,maxrow(),maxcol(),cCske)
return aFiel

/**************************************************************************/
FUNCTION fPrnCod( cCtrlCode )
   LOCAL nRow, nCol, lPrinter
   lPrinter := SET(_SET_PRINTER, TRUE)           // SET PRINTER ON
   nRow = PROW()                                 // Save printhead position
   nCol = PCOL()
   //
   @ PROW(),PCOL() SAY &cCtrlCode                // Send control code
   //
   SETPRC(nRow, nCol)
   SET(_SET_PRINTER, lPrinter)                   // Restore printer setting
RETURN ""                                        // Return a null ("") string

/******************************************************************************/
FUNCTION fCreateDbf(cDbfn,cDbfd)

   // Function to create .dbf files from the STDSFIEL.tdb file

   // Declare
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local aStru := {}
   local cNewf := ""
   begin sequence

      // Values
      cDbfn := padr(upper(alltrim(cDbfn)),8)
      cNewf := cDd() + trim(cDbfn) + ".dbf"

      // Open
      aCdbf := fATopen(aCdbf,,"STDFIEL",,"tdb")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Find the structure
      seek cDbfn

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),trim(cDbfd)+" lˆer word geskep")
      else
         fScrWbood(maxrow(),trim(cDbfd)+" file being created")
      endif

      // Fill array with structure
      dbeval( {|| aadd( aStru, ;
         { trim(STDFIEL->fldname),;
         STDFIEL->fldtype,;
         STDFIEL->fldleng,;
         STDFIEL->flddeci } ) },,;
         {|| STDFIEL->dbfname==cDbfn} )

      // Create the file
      dbcreate(cNewf,aStru)

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return NIL

/****************************************************************************/
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

/****************************************************************************/
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

/**************************************************************************/
FUNCTION fMoerData(cField,cType)

   //Funksie om die moer se data te gaan haal

   //Verklaar
   local xData
   local cId
   local nCurRecord
   local nCurOrder
   local nCurSelect

   // Defaults
   cType := iif(empty(cType),"",cType)

   //Toets of dataleers oop is
   if select("sm3data") == 0
      if cType == "D"
         return ctod("")
      elseif cType == "N"
         return 0
      else
         return ""
      endif
   endif

   //Bewaar huidige stellings
   nCurSelect = select()
   select select("sm3data")
   nCurRecord = recno()
   nCurOrder = indexord()

   //Bou moernommer om te soek
   cId = SM3DATA->idmoer

   //Set index order
   set order to 1
   seek cId
   if eof()
      //Herstel
      set order to nCurOrder
      goto nCurRecord
      select (nCurSelect)
      if cType == "D"
         return ctod("")
      elseif cType == "N"
         return 0
      else
         return ""
      endif
   endif

   //Moer gekry - stoor data
   xData = &cField

   //Herstel
   set order to nCurOrder
   goto nCurRecord
   select (nCurSelect)

RETURN xData

/**************************************************************************/
FUNCTION fVaarData(cField,cType)

   //Funksie om die vaar se data te gaan haal

   //Verklaar
   local xData
   local cId
   local nCurRecord
   local nCurOrder
   local nCurSelect

   // Defaults
   cType := iif(empty(cType),"",cType)

   //Toets of dataleers oop is
   if select("sm3data") == 0
      if cType == "D"
         return ctod("")
      elseif cType == "N"
         return 0
      else
         return ""
      endif
   endif

   //Bewaar huidige stellings
   nCurSelect = select()
   select select("sm3data")
   nCurRecord = recno()
   nCurOrder = indexord()

   //Bou vaarnommer om te soek
   cId = SM3DATA->idvaar

   //Set index order
   set order to 1
   seek cId
   if eof()
      //Herstel
      set order to nCurOrder
      goto nCurRecord
      select (nCurSelect)
      if cType == "D"
         return ctod("")
      elseif cType == "N"
         return 0
      else
         return ""
      endif
   endif

   //Vaar gekry - stoor data
   xData = &cField

   //Herstel
   set order to nCurOrder
   goto nCurRecord
   select (nCurSelect)

RETURN xData

/**************************************************************************/
FUNCTION fAnimData(cIdnr,cField,cType)

   // Funksie om data van enige dier te gaan haal

   //Verklaar
   local xData
   local cId
   local nCurRecord
   local nCurOrder
   local nCurSelect

   // Defaults
   cIdnr := iif(empty(cIdnr),"",cIdnr)
   cType := iif(empty(cType),"",cType)

   //Toets of dataleers oop is
   if select("sm3data") == 0
      if cType == "D"
         return ctod("")
      elseif cType == "N"
         return 0
      else
         return ""
      endif
   endif

   //Bewaar huidige stellings
   nCurSelect = select()
   select select("sm3data")
   nCurRecord = recno()
   nCurOrder = indexord()

   //Bou moernommer om te soek
   if empty(cIdnr)
      cId = SM3DATA->idnr
   else
      cId := cIdnr
   endif

   //Set index order
   set order to 1
   seek cId
   if eof()
      //Herstel
      set order to nCurOrder
      goto nCurRecord
      select (nCurSelect)
      if cType == "D"
         return ctod("")
      elseif cType == "N"
         return 0
      else
         return ""
      endif
   endif

   //Moer gekry - stoor data
   xData = &cField

   //Herstel
   set order to nCurOrder
   goto nCurRecord
   select (nCurSelect)

RETURN xData


/******************************************************************************/
FUNCTION fId(cId,lZero)

   // Function to calculate the official Id number

   // Declare
   local nPosv := 0
   local cVolg := ""
   local cJaar := ""
   local cKudd := ""
   local cRetu := space(10)
   local aCdbf := fATopen()
   local cBrec := ""
   local cIdfo := ""
   local cCoun := ""
   begin sequence

      cBrec := alltrim(fRasNaam(substr(cTotNaam(),149,3),"BREEDS"))

      // Id cannot be empty
      if len(trim(cId)) == 0
         break
      endif

      // Open the main file
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")

      if !aCdbf[len(aCdbf),1]

         // Calculate from variable - file could not be opened

         if cIdForm() == "2"

            // Id number in yy-sssshhhh format
            cJaar := alltrim(substr(cId,1,2))
            cVolg := alltrim(str(val(substr(cId,3,4))))
            cKudd := alltrim(substr(cId,8,5))

         else

            // Id number in hhhhyy-ssss format

            nPosv=at('-',cId)
            if nPosv=0
               nPosv=at('/',cId)
            endi
            if nPosv > 0
               nPosv = nPosv + 1
               cVolg = alltrim(str(val(substr(cId,nPosv,4)),4,0))
               cJaar = alltrim(substr(cId,nPosv-3,2))
               cKudd = alltrim(substr(cId,1,nPosv-4))
               if substr(cTotNaam(),149,3) = '211' .and. "R" $ right(alltrim(cId),2)
                  cVolg = cVolg + 'R'
               endif
            else
               nPosv=len(alltrim(cId))
               *---Kry die posisie van die cVolgommer
               if substr(cTotNaam(),149,3) = "211"
                  do whil substr(cId,nPosv,1) $ "0123456789.,;:R"
                     nPosv=nPosv-1
                  endd
               else
                  do whil substr(cId,nPosv,1) $ "0123456789.,;:"
                     nPosv=nPosv-1
                  endd
               endif
               cVolg = alltrim(str(val(substr(cId,nPosv+1,4)),4,0))
               cJaar = alltrim(substr(cId,nPosv,1))
               cKudd = alltrim(substr(cId,1,nPosv-1))
               if substr(cTotNaam(),149,3) = '211' .and. "R" $ right(alltrim(cId),2)
                  cVolg = cVolg + 'R'
               endif
            endif

         endif

      else

         // Locate the animal
         seek cId
         if found()

            // Animal found

            // File is open
            if empty(SM3DATA->jaarle) .or. empty(SM3DATA->volgno) .or. ;
                  val(SM3DATA->volgno) <= 0

               if cIdForm() == "2"

                  // Id number in yy-sssshhhh format
                  cJaar := alltrim(substr(cId,1,2))
                  cVolg := alltrim(str(val(substr(cId,3,4))))
                  cKudd := alltrim(substr(cId,8,5))

               else

                  // Build from parameter
                  // Calculate - empty fields
                  nPosv=at('-',cId)
                  if nPosv=0
                     nPosv=at('/',cId)
                  endi
                  if nPosv > 0
                     nPosv = nPosv + 1
                     cVolg = alltrim(str(val(substr(cId,nPosv,4)),4,0))
                     cJaar = alltrim(substr(cId,nPosv-3,2))
                     cKudd = alltrim(substr(cId,1,nPosv-4))
                     if substr(cTotNaam(),149,3) = '211' .and. "R" $ right(alltrim(cId),2)
                        cVolg = cVolg + 'R'
                     endif
                  else
                     nPosv=len(alltrim(cId))
                     *---Kry die posisie van die cVolgommer
                     if substr(cTotNaam(),149,3) = "211"
                        do whil substr(cId,nPosv,1) $ "0123456789.,;:R"
                           nPosv=nPosv-1
                        endd
                     else
                        do whil substr(cId,nPosv,1) $ "0123456789.,;:"
                           nPosv=nPosv-1
                        endd
                     endif
                     cVolg = alltrim(str(val(substr(cId,nPosv+1,4)),4,0))
                     cJaar = alltrim(substr(cId,nPosv,1))
                     cKudd = alltrim(substr(cId,1,nPosv-1))
                     if substr(cTotNaam(),149,3) = '211' .and. "R" $ right(alltrim(cId),2)
                        cVolg = cVolg + 'R'
                     endif

                  endif

               endif

            else

               // cVolg := alltrim(SM3DATA->volgno)
               cVolg := alltrim(str(val(SM3DATA->volgno)))
               cJaar := alltrim(SM3DATA->jaarle)
               cKudd := alltrim(SM3DATA->kuddek)
               if empty(cKudd)
                  cKudd := substr(cTotNaam(),125,4)
               endif

            endif

         else

            // Animal not found

            if cIdForm() == "2"

               // Id number in yy-sssshhhh format
               cJaar := alltrim(substr(cId,1,2))
               cVolg := alltrim(str(val(substr(cId,3,4))))
               cKudd := alltrim(substr(cId,8,5))

            else

               // Id number in hhhhyy-ssss format

               nPosv=at('-',cId)
               if nPosv=0
                  nPosv=at('/',cId)
               endi
               if nPosv > 0
                  nPosv = nPosv + 1
                  cVolg = alltrim(str(val(substr(cId,nPosv,4)),4,0))
                  cJaar = alltrim(substr(cId,nPosv-3,2))
                  cKudd = alltrim(substr(cId,1,nPosv-4))
                  if substr(cTotNaam(),149,3) = '211' .and. "R" $ right(alltrim(cId),2)
                     cVolg = cVolg + 'R'
                  endif
               else
                  nPosv=len(alltrim(cId))
                  *---Kry die posisie van die cVolgommer
                  if substr(cTotNaam(),149,3) = "211"
                     do whil substr(cId,nPosv,1) $ "0123456789.,;:R"
                        nPosv=nPosv-1
                     endd
                  else
                     do whil substr(cId,nPosv,1) $ "0123456789.,;:"
                        nPosv=nPosv-1
                     endd
                  endif
                  cVolg = alltrim(str(val(substr(cId,nPosv+1,4)),4,0))
                  cJaar = alltrim(substr(cId,nPosv,1))
                  cKudd = alltrim(substr(cId,1,nPosv-1))
                  if substr(cTotNaam(),149,3) = '211' .and. "R" $ right(alltrim(cId),2)
                     cVolg = cVolg + 'R'
                  endif
               endif

            endif

         endif

      endif

   end

   // Build the correct id number

   if cIsoCoun() == "NAM"

      // All Namibian numbers to go in YY-SSSSHHHH format
      altd()
      cRetu := padr(cJaar,2) + "-" + padl(cVolg,4,"0") + padr(cKudd,4)

   elseif !empty(cBrec)

      // Numbers in Breedplan format

      if cBrec == "SBBS"
         // Simbra
         if SM3DATA->generasie == "F1"
            cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg) + "A"
         elseif SM3DATA->generasie == "F2"
            cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg) + "B"
         elseif SM3DATA->generasie == "F3"
            cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg) + "C"
         elseif SM3DATA->generasie == "SP"
            cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg)
         else
            cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg) + alltrim(SM3DATA->generasie)
         endif
      elseif cBrec == "SASG"
         cRetu := alltrim(cKudd) + alltrim(cJaar) + padl(cVolg,4,"0")
      elseif cBrec == "SAWY"
         cRetu := alltrim(cKudd) + alltrim(cJaar) + padl(cVolg,4,"0")
      else
         cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg)
      endif

   else

      // All other numbers in Iris format

      if lZero

         // Pad sequence numbers with zeros

         // Changed 02-02-07 11:02 for iris
         // cRetu := padr(cKudd,4) + padr(cJaar,2) + padr(cVolg,5)

         cRetu := padr(cKudd,4) + padr(cJaar,2) + padl(cVolg,4,"0")

      else

         // Id numbers should not be padded with zeros
         cRetu := alltrim(cKudd) + alltrim(cJaar) + alltrim(cVolg)

      endif

   endif

   // Reset
   fATclose(aCdbf)

return cRetu

/******************************************************************************/
FUNCTION fTOpen( cDriv, cName, cYear, cExte, cAlia, lShar, lRead, nTryy, lOpin )

   //Funksie om 'n leer oop te maak indien die leer nie oop is nie of
   //Om 'n bestaande leer te gebruik indien die leer reeds oop is.
   //Die funksie return 'n character string met die leerbesonderhede
   //indien die leer wel oop was.

   //Return string
   //Karakter 1        : t indien wel suksesvol oopgemaak
   //                  : f indien nie suksesvol oopgemaak
   //Karakter 2        : f indien die leer nuut oopgemaak is en weer toegemaak moet word
   //                  : t indien nie nuut oopgemaak en weer herstel moet word
   //Karakter 345      : Die werkarea
   //Karakter 67890123 : Die rekordnommer
   //Karakter 45       : Die indeksleer order
   //         6789012

   //Verklaar veranderlikes
   //LOCAL cCurSke := savescreen(maxrow()-1, 0, maxrow(), maxcol() ) //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cReturn := "ff  0       0 0"            //Die return sting
   LOCAL i

   //Toets veranderlikes
   cDriv := if( cDriv == NIL, "", cDriv )
   cYear := if( cYear == NIL, "", cYear )
   cExte := if( cExte == NIL, ".dbf", "."+cExte )
   cAlia := if( cAlia == NIL, cName, cAlia )
   lShar := if( lShar == NIL, TRUE, lShar )
   lRead := if( lRead == NIL, FALSE, lRead )
   nTryy := if( nTryy == NIL, 5, nTryy )
   lOpin := if( lOpin == NIL, TRUE, lOpin )

   //Toets die naam van die leer
   //Indien 'n leernaam nie gegee is nie, return die huidige oop leer se status
   if cName == NIL
      if used()
         cReturn := stuff( cReturn, 2, 1, "t" )
         cReturn := stuff( cReturn, 3, 3, str( select(), 3, 0 ) )
         cReturn := stuff( cReturn, 6, 8, str( recno(), 8, 0 ) )
         cReturn := stuff( cReturn, 14, 2, str( indexord() , 2, 0 ) )
      endif
      fSetScreen( cCurScr )
      //restscreen(maxrow()-1, 0, maxrow(), maxcol(), cCurSke )
      return cReturn
   endif

   //Skerm
   if cLanType() == "A"
      //fScrWbood( maxrow(), upper( cName+cYear ) + " datalˆer word geopen" )
   else
      //fScrWbood( maxrow(), upper( cName+cYear ) + " data file being opened" )
   endif

   //Kyk of die leer wat oopgemaak moet word reeds oop is of nie
   if select( cAlia ) > 0
      //Leer is reeds oop
      select select( cAlia )
      //Stoor die huidige besonderhede
      cReturn := stuff( cReturn, 2, 1, "t" )
      cReturn := stuff( cReturn, 3, 3, str( select(), 3, 0 ) )
      cReturn := stuff( cReturn, 6, 8, str( recno(), 8, 0 ) )
      cReturn := stuff( cReturn, 14, 2, str( indexord() , 2, 0 ) )
      //Indien leer nie eerste keer oopgemaak kan word nie - probeer aantal kere
      for i = 1 to nTryy
         dbusearea( FALSE,, cDriv+cName+cYear+cExte, cAlia, lShar, lRead )
         if neterr()
            //Netwerkfout - probeer weer
            inkey(1)
            if lastkey() = K_ESC
               exit
            endif
            //Skerm
            if cLanType() == "A"
               fScrWbood( maxrow(), upper( cName+cYear ) + " datalˆer in gebruik! (" +str(i,3)+ ") [ESC]=Stop" )
            else
               fScrWbood( maxrow(), upper( cName+cYear ) + " data file in use! (" +str(i,3)+ ") [ESC]=Stop" )
            endif
         else
            //Suksesvol oopgemaak
            cReturn := stuff( cReturn, 1, 1, "t" )
            //use
            //select val( substr( cReturn, 3, 3 ) )
            //Open indeksleers
            if lOpin
               //fIOpen( cDriv, cName, cYear )
            endif
            exit
         endif
      next
   else
      //Leer nie oop - maak oop
      //Indien leer nie eerste keer oopgemaak kan word nie - probeer aantal kere
      for i = 1 to nTryy
         dbusearea( TRUE,, cDriv+cName+cYear+cExte, cAlia, lShar, lRead )
         if neterr()
            //Netwerkfout - probeer weer
            inkey(1)
            if lastkey() = K_ESC
               exit
            endif
            //Skerm
            if cLanType() == "A"
               fScrWbood( maxrow(), upper( cName+cYear ) + " datalˆer in gebruik! (" +str(i,3)+ ") [ESC]=Stop" )
            else
               fScrWbood( maxrow(), upper( cName+cYear ) + " data file in use! (" +str(i,3)+ ") [ESC]=Stop" )
            endif
         else
            //Suksesvol oopgemaak
            cReturn := stuff( cReturn, 1, 1, "t" )
            cReturn := stuff( cReturn, 3, 3, str( select(), 3, 0 ) )
            //Open indeksleers
            if lOpin
               // fIOpen( cDriv, cName, cYear )
            endif
            exit
         endif
      next
   endif

return cReturn

/*************************************************************************/
FUNCTION fTClose( cReturn )

   //Funksie om die return string se leer te herstel soos dit was voor die tyd
   //Die funksie return NIL

   if substr( cReturn, 2, 1 ) == "t"
      //Leer moet herstel word
      if val( substr( cReturn, 3, 3 ) ) > 0
         //Werkarea bestaan
         //Selekteer die werksarea
         select val(substr(cReturn,3,3))
         //Indeksorde
         if val(substr(cReturn,14,2)) > 0
            set order to val(substr(cReturn,14,2))
         else
            set index to
         endif
         //Rekordnommer
         if val(substr(cReturn,6,8)) > 0
            goto val(substr(cReturn,6,8))
         else
            go top
         endif
      endif
   else
      //Leer moet toegemaak word
      if val( substr( cReturn, 3, 3 ) ) > 0
         //Werkarea bestaan
         //Selekteer die werksarea
         select (val(substr(cReturn,3,3)))
         dbclosearea()
      endif
   endif

return NIL

//**************************************************************************/
FUNCTION fCopies(nCopy)

   //Funksie om aantal kopiee te vra

   //Verklaar
   local getlist := {}
   local cCscr := savescreen(0,0,maxrow(),maxcol())
   local nBoxc := 0

   //Waardes
   nCopy := if(nCopy==NIL,1,nCopy)

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,"Hoeveel afskrifte? xx",3)
   else
      nBoxc := fBoxCent(11,"How many copies? xx",3)
   endif
   fScrBood(maxrow()-1)
   if cLanType() == "A"
      fScrBood(maxrow(),"Hoeveel afskrifte moet gedruk word?")
      @12,nBoxc say "Hoeveel afskrifte?" get nCopy pict "99"
   else
      fScrBood(maxrow(),"How many copies should be printed?")
      @12,nBoxc say "How many copies?" get nCopy pict "99"
   endif
   set cursor on
   read
   set cursor off

   if LASTKEY() == K_ESC
      nCopy := 0
   endif

   //Herstel
   restscreen(0,0,maxrow(),maxcol(),cCscr)
return nCopy

//**************************************************************************/
FUNCTION ZER(n1,n2)
   local nResult := 0
   if n2 <> 0
      nResult := n1/n2
   endif
   //@maxrow()-1,0 say ltrim(str(n1))
   //@maxrow(),0 say ltrim(str(n2))
   //inkey(0)
return nResult

/***************************************************************************/
FUNCTION stdnotc(cHead,aMess)

   //Funksie om 'n boodskap op die skerm te vertoon

   //Verklaar
   local nLeng := 0
   local nBoxc := 0
   local nData := 0
   local i     := 0

   //Kyk of daar boodskappe is
   cHead := if(cHead==NIL,"",cHead)
   if aMess == NIL
      return NIL
   endif
   if len(aMess) < 1
      return NIL
   endif

   //Bepaal die langste boodskap
   for i := 1 to len(aMess)
      if len(trim(aMess[i])) > nLeng
         nLeng := len(trim(aMess[i]))
      endif
   next

   //Bepaal middel
   nData := ((maxrow()-2)/2) - int(len(aMess)/2)

   //Skerm
   nBoxc := fBoxCent(nData,space(nLeng),len(aMess)+2,cHead,cColNorm())

   //Teken die nota
   for i := 1 to len(aMess)
      @nData+i,nBoxc say aMess[i]
   next

   //Herstel
return NIL

/****************************************************************************/
FUNCTION fFileError

   // Function to display file error messages

   // Declare
   local cBood := ""

   // The messages
   if cLanType() == "A"

      do case
         case ferror() == 2
            cBood := "Lˆer onbekend"
         case ferror() == 3
            cBood := "Lˆerroete onbekend"
         case ferror() == 4
            cBood := "Te veel oop lˆers"
         case ferror() == 5
            cBood := "Toegang geweier"
         case ferror() == 6
            cBood := "Ongeldige lˆerhandvatsel"
         case ferror() == 8
            cBood := "Nie genoeg geheue"
         case ferror() == 15
            cBood := "Ongeldige dryf gespesifiseer"
         case ferror() == 19
            cBood := "Disket is skryfbeskermd"
         case ferror() == 21
            cBood := "Dryf is nie gereed nie"
         case ferror() == 23
            cBood := "Data CRC fout"
         case ferror() == 29
            cBood := "Skryffout"
         case ferror() == 30
            cBood := "Leesfout"
         case ferror() == 32
            cBood := "Lˆersluit verbreking"
         case ferror() == 33
            cBood := "Sluit verbreking"
      endcase

      // Empty
      if empty(cBood)
         cBood := "Onbekende lˆerfout"
      endif

   else

      do case
         case ferror() == 2
            cBood := "File not found"
         case ferror() == 3
            cBood := "Path not found"
         case ferror() == 4
            cBood := "Too many files open"
         case ferror() == 5
            cBood := "Access denied"
         case ferror() == 6
            cBood := "Invalid handle"
         case ferror() == 8
            cBood := "Insufficient memory"
         case ferror() == 15
            cBood := "Invalid drive specified"
         case ferror() == 19
            cBood := "Attempted to write to a write-protected disk"
         case ferror() == 21
            cBood := "Drive not ready"
         case ferror() == 23
            cBood := "Data CRC error"
         case ferror() == 29
            cBood := "Write fault"
         case ferror() == 30
            cBood := "Read fault"
         case ferror() == 32
            cBood := "Sharing violation"
         case ferror() == 33
            cBood := "Lock Violation"
      endcase

      // Empty
      if empty(cBood)
         cBood := "Unknown file error"
      endif

   endif

return cBood

/****************************************************************************/
FUNCTION fASaveScr(nTopp,nLeft,nBott,nRigh)

   // Function to save current screen settings

   // Declare
   local aCscr[1][9]

   // Defaults
   nTopp := if(nTopp==NIL,0,nTopp)
   nLeft := if(nLeft==NIL,0,nLeft)
   nBott := if(nBott==NIL,maxrow(),nBott)
   nRigh := if(nRigh==NIL,maxcol(),nRigh)

   // Screen coordinates
   aCscr[1, 1] := nTopp                          //Top line
   aCscr[1, 2] := nLeft                          //Left column
   aCscr[1, 3] := nBott                          //Bottom row
   aCscr[1, 4] := nRigh                          //Right column
   aCscr[1, 5] := savescreen(nTopp,nLeft,nBott,nRigh) //Current screen
   aCscr[1, 6] := setcolor()                     //Current color
   aCscr[1, 7] := setcursor()                    //Current cursor
   aCscr[1, 8] := row()                          //Current cursor row
   aCscr[1, 9] := col()                          //Current cursor column

return aCscr

/****************************************************************************/
FUNCTION fARestScr(aCscr)

   // Funksie om skerm te herstel

   // Array moet bestaan
   if aCscr == NIL
   else
      // Repair
      restscreen(aCscr[1, 1],aCscr[1, 2],aCscr[1, 3],aCscr[1, 4],aCscr[1, 5])
      setcolor(aCscr[1, 6])
      setpos(aCscr[1, 8],aCscr[1, 9])
      setcursor(aCscr[1, 7])
   endif

return NIL

/******************************************************************************/
FUNCTION fATOpen(aRetu,cDriv,cName,cYear,cExte,cAlia,lShar,lRead)

   // Function to open tables (files) and return opened status

   // Return array
   // Element  1 : TRUE If succesfully opened
   //           : FALSE If not succesfully opened
   // Element  2 : FALSE If file must be closed after usage
   //           : TRUE If file must be left open and restored
   // Element  3 : Workarea
   // Element  4 : Record number
   // Element  5 : Index file order
   // Element  6 : Filter condition
   // Element  7 : 1st Relation expression
   // Element  8 : 1st Relation alias
   // Element  9 : 2nd Relation expression
   // Element 10 : 2nd Relation alias
   // Element 11 : 3rd Relation expression
   // Element 12 : 3rd Relation alias
   // Element 13 : 4th Relation expression
   // Element 14 : 4th Relation alias
   // Element 15 : 5th Relation expression
   // Element 16 : 5th Relation alias

   // Declare
   local aCscr   := fASaveScr()
   local i       := 0
   local nLength := 0
   local lLoop := TRUE
   local aMenu := {"Retry","Quit"}

   begin sequence

      // Values
      aRetu := if(aRetu==NIL,{}    ,aRetu)
      cDriv := if(cDriv==NIL,""    ,cDriv)
      cYear := if(cYear==NIL,""    ,cYear)
      cExte := if(cExte==NIL,".dbf","."+cExte)
      cAlia := if(cAlia==NIL,cName ,cAlia)
      lShar := if(lShar==NIL,TRUE   ,lShar)
      lRead := if(lRead==NIL,FALSE   ,lRead)

      // Make array one bigger
      aadd(aRetu,{FALSE,FALSE,0,0,0,"","",0,"",0,"",0,"",0,"",0})
      nLength := len(aRetu)

      // If no file name given, return current open file status
      if empty(cName)
         if used()
            aRetu[nLength, 1] := FALSE
            aRetu[nLength, 2] := TRUE
            aRetu[nLength, 3] := select()
            aRetu[nLength, 4] := recno()
            aRetu[nLength, 5] := indexord()
            aRetu[nLength, 6] := dbfilter()
            aRetu[nLength, 7] := dbrelation(1)
            aRetu[nLength, 8] := dbrselect(1)
            aRetu[nLength, 9] := dbrelation(2)
            aRetu[nLength,10] := dbrselect(2)
            aRetu[nLength,11] := dbrelation(3)
            aRetu[nLength,12] := dbrselect(3)
            aRetu[nLength,13] := dbrelation(4)
            aRetu[nLength,14] := dbrselect(4)
            aRetu[nLength,15] := dbrelation(5)
            aRetu[nLength,16] := dbrselect(5)
         endif
         break
      endif

      // Loop if want to retry
      lLoop := TRUE
      do while lLoop

         // Check wheter file already in use
         if select(cAlia) > 0

            // File already open
            if lShar

               select select(cAlia)

               // Save parameters
               aRetu[nLength, 1] := TRUE
               aRetu[nLength, 2] := TRUE
               aRetu[nLength, 3] := select()
               aRetu[nLength, 4] := recno()
               aRetu[nLength, 5] := indexord()
               aRetu[nLength, 6] := dbfilter()
               aRetu[nLength, 7] := dbrelation(1)
               aRetu[nLength, 8] := dbrselect(1)
               aRetu[nLength, 9] := dbrelation(2)
               aRetu[nLength,10] := dbrselect(2)
               aRetu[nLength,11] := dbrelation(3)
               aRetu[nLength,12] := dbrselect(3)
               aRetu[nLength,13] := dbrelation(4)
               aRetu[nLength,14] := dbrselect(4)
               aRetu[nLength,15] := dbrelation(5)
               aRetu[nLength,16] := dbrselect(5)

               // Set std values
               dbclearrel()
               dbclearfil()
               ordsetfocus(1)
               go top
               lLoop := FALSE

            else

               // Cannot be opened exclusively - Say that
               // Network error - cannot open
               fScrBood(maxrow()-1)
               fScrBood(maxrow())
               if cLanType() == "A"
                  if alert(trim(cDriv+cName+cYear+cExte)+" kon nie oopgemaak word nie!",aMenu) <> 1
                     break
                  else
                     loop
                  endif
               else
                  if alert(trim(cDriv+cName+cYear+cExte)+" could not be opened!",aMenu) <> 1
                     break
                  else
                     loop
                  endif
               endif

            endif

         else

            // File not in use - Open
            dbusearea(TRUE,,cDriv+cName+cYear+cExte,cAlia,lShar,lRead)
            if neterr()

               // Network error - cannot open
               fScrBood(maxrow()-1)
               fScrBood(maxrow())
               if cLanType() == "A"
                  if alert(trim(cDriv+cName+cYear+cExte)+" kon nie oopgemaak word nie!",aMenu) <> 1
                     break
                  else
                     loop
                  endif
               else
                  if alert(trim(cDriv+cName+cYear+cExte)+" could not be opened!",aMenu) <> 1
                     break
                  else
                     loop
                  endif
               endif

            else

               // Opening succesful
               aRetu[nLength, 1] := TRUE
               aRetu[nLength, 2] := FALSE
               aRetu[nLength, 3] := select()
               aRetu[nLength, 4] := recno()
               aRetu[nLength, 5] := indexord()
               aRetu[nLength, 6] := dbfilter()
               aRetu[nLength, 7] := dbrelation(1)
               aRetu[nLength, 8] := dbrselect(1)
               aRetu[nLength, 9] := dbrelation(2)
               aRetu[nLength,10] := dbrselect(2)
               aRetu[nLength,11] := dbrelation(3)
               aRetu[nLength,12] := dbrselect(3)
               aRetu[nLength,13] := dbrelation(4)
               aRetu[nLength,14] := dbrselect(4)
               aRetu[nLength,15] := dbrelation(5)
               aRetu[nLength,16] := dbrselect(5)

               lLoop := FALSE

            endif

         endif

      enddo

   end

   // Reset
   fARestScr(aCscr)

return aRetu

/******************************************************************************/
FUNCTION fATClose(aCdbf)

   // Function to restore dbf status

   // Declare
   local i := 0
   private cRele := ""
   private cRelt := ""
   private cFilt := ""

   begin sequence

      for i := len(aCdbf) to 1 step -1

         if aCdbf[i,2]
            // File must be restored
            if aCdbf[i,3] > 0
               select (aCdbf[i,3])
               // Index order
               if aCdbf[i,5] > 0
                  dbsetorder(aCdbf[i,5])
               else
                  dbclearind()
               endif
               // Relation 1
               if !empty(aCdbf[i,8])
                  cRele := aCdbf[i,7]
                  cRelt := alias(aCdbf[i,8])
                  set relation to &cRele INTO &cRelt
               endif
               // Relation 2
               if !empty(aCdbf[i,10])
                  cRele := aCdbf[i,9]
                  cRelt := alias(aCdbf[i,10])
                  set relation to &cRele INTO &cRelt additive
               endif
               // Relation 3
               if !empty(aCdbf[i,12])
                  cRele := aCdbf[i,11]
                  cRelt := alias(aCdbf[i,12])
                  set relation to &cRele INTO &cRelt additive
               endif
               // Relation 4
               if !empty(aCdbf[i,14])
                  cRele := aCdbf[i,13]
                  cRelt := alias(aCdbf[i,14])
                  set relation to &cRele INTO &cRelt additive
               endif
               // Relation 5
               if !empty(aCdbf[i,16])
                  cRele := aCdbf[i,15]
                  cRelt := alias(aCdbf[i,16])
                  set relation to &cRele INTO &cRelt additive
               endif
               // Filter condition
               if !empty(aCdbf[i,6])
                  cFilt := aCdbf[i,6]
                  //set filter to &cFilt
                  cmfilter(cFilt)
               else
                  dbclearfilter()
               endif
               // Record number
               if aCdbf[i,4] > 0
                  goto aCdbf[i,4]
               else
                  go top
               endif
            endif
         else
            // Leer moet toegemaak word
            if aCdbf[i,3] > 0
               select (aCdbf[i,3])
               dbclearind()
               dbclearrel()
               dbclearfilter()
               dbclosearea()
            endif
         endif

      next

   end

   // Reset

return NIL

/******************************************************************************/
FUNCTION FullStabilize(bBrow)
   do while !bBrow:stabilize()
   enddo
RETURN bBrow:stable

/******************************************************************************/
FUNCTION KeyStabilize(bBrow)
   do while nextkey() == 0 .AND. !bBrow:stabilize()
   enddo
RETURN bBrow:stable

/******************************************************************************/
FUNCTION fFillBlank(aRecv,aRepe)

   // Function to fill get array with blanks

   // Declare
   local i := 0

   // Values
   aRepe := iif(empty(aRepe),{},aRepe)

   // Make Scan array upper case
   for i := 1 to len(aRepe)
      aRepe[i] := upper(aRepe[i])
   next

   // The loop
   for i := 1 to len(aRecv)

      if aScan(aRepe,upper(aRecv[i,FLD_NAME])) > 0
      else
         if aRecv[i,3] == "N"
            // Numeric
            aRecv[i,14] := 0
         elseif aRecv[i,3] == "D"
            // Date
            aRecv[i,14] := ctod("")
         else
            // Character
            aRecv[i,14] := space(aRecv[i,4])
         endif
      endif

   next

return aRecv

/******************************************************************************/
FUNCTION fEnum(aArra,cFiel)

   // Function to return the element number of a field

return ascan(aArra,{|aArra|upper(aArra[2])==upper(cFiel)})

/******************************************************************************/
FUNCTION stod(cDate)

   // Function to convert a string to date

   // Declare
   local dRetu := ctod("")

   if val(left(cDate,4)) >= 1900 .and. ;
         val(left(cDate,4)) <= 2099 .and. ;
         val(substr(cDate,5,2)) >= 1 .and. ;
         val(substr(cDate,5,2)) <= 12 .and. ;
         val(right(cDate,2)) >= 1 .and. ;
         val(right(cDate,2)) <= 31
      dRetu := ctod(right(cDate,2)+"/"+substr(cDate,5,2)+"/"+left(cDate,4))
   endif

return dRetu

/******************************************************************************/
FUNCTION stodl(cDate)

   // Function to convert a string to date

   // Declare
   local dRetu := ctod("")

   if val(left(cDate,4)) >= 1900 .and. ;
         val(left(cDate,4)) <= 2099 .and. ;
         val(substr(cDate,6,2)) >= 1 .and. ;
         val(substr(cDate,6,2)) <= 12 .and. ;
         val(right(cDate,2)) >= 1 .and. ;
         val(right(cDate,2)) <= 31
      dRetu := ctod(right(cDate,2)+"/"+substr(cDate,6,2)+"/"+left(cDate,4))
   endif

return dRetu

/******************************************************************************/
FUNCTION dtod(dDate)

   // Function to convert a string to date

   // Declare
   local cRetu := ""

   if empty(dDate)
   else
      cRetu := padl(alltrim(str(day(dDate))),2,"0")
      cRetu += padl(alltrim(str(month(dDate))),2,"0")
      cRetu += left(dtos(dDate),4)
   endif

return cRetu

/******************************************************************************/
FUNCTION dtosdmy(dDate)

   // Function to convert a date to dmy string

   // Declare
   local cRetu := space(8)

   if empty(dDate)
   else
      cRetu := right(dtos(dDate),2)
      cRetu += substr(dtos(dDate),5,2)
      cRetu += left(dtos(dDate),4)
   endif

return cRetu

/******************************************************************************/
FUNCTION fDataLocate(cFile,cLocf,cLocd,cFiel)

   // Funksie om data te verkry

   // Veranderlikes
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFpos := 0
   local cData := ""
   local cRetu := ""

   begin sequence

      altd()

      // Waardes
      cFile := if(cFile==NIL,"",cFile)
      cLocf := if(cLocf==NIL,"",cLocf)
      cLocd := if(cLocd==NIL,"",cLocd)
      cFiel := if(cFiel==NIL,"",cFiel)

      // Exit if empty
      if empty(cFile) .or. empty(cLocd) .or. empty(cLocf) .or. empty(cFiel)
         break
      endif

      // Open dryfleer
      aCdbf := fATopen(aCdbf,cDd(),cFile)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Vind die rekord
      do while !eof()
         nFpos := fieldpos(cLocf)
         cData := fieldget(nFpos)
         if cData == cLocd
            // Kry die data
            cRetu = &cFiel
            break
         endif
         skip
      enddo

   end

   //Herstel
   fATclose(aCdbf)
   fARestScr(aCscr)

return cRetu

/******************************************************************************/
FUNCTION fFilePick(cMess,cDire,cSpec,cOrdo,cOrdd)

   // Function to pick a file to work with

   // 07-05-23 10:52

   // Return values
   // "" No files were found to display or some other problem
   // "Esc" Files were found, but escaped not to choose any file
   // "Full file with path" File was chosen

   // Variables
   local aCscr := fASaveScr()
   local aDire := {}
   local aDirs := {}
   local nOrdo := 1
   local aMenu := {}
   local i     := 0
   local nBoxc := 0
   local cRetu := ""

   begin sequence

      // Values
      cMess := if(cMess==NIL,"",cMess)           // Message top of window
      cDire := if(cDire==NIL,cDd(),cDire)        // Directory to display
      cSpec := if(cSpec==NIL,"*.*",cSpec)        // Files to display
      cOrdo := if(cOrdo==NIL,"N",cOrdo)          // Sort field
      cOrdd := if(cOrdd==NIL,"A",cOrdd)          // Sort order ascending / descending

      // Exit if empty
      if empty(cDire) .or. empty(cOrdo) .or. empty(cOrdd) .or. empty(cSpec)
         break
      endif

      // Build array of files
      aDire := directory(cDire+cSpec)

      // Determine order direction
      if cOrdd == "D"
         if cOrdo == "S"
            aDirs := asort(aDire,,, { |x, y| x[F_SIZE] > y[F_SIZE] })
         elseif cOrdo == "D"
            aDirs := asort(aDire,,, { |x, y| x[F_DATE] > y[F_DATE] })
         elseif cOrdo == "T"
            aDirs := asort(aDire,,, { |x, y| x[F_TIME] > y[F_TIME] })
         else
            aDirs := asort(aDire,,, { |x, y| x[F_NAME] > y[F_NAME] })
         endif
      else
         if cOrdo == "S"
            aDirs := asort(aDire,,, { |x, y| x[F_SIZE] < y[F_SIZE] })
         elseif cOrdo == "D"
            aDirs := asort(aDire,,, { |x, y| x[F_DATE] < y[F_DATE] })
         elseif cOrdo == "T"
            aDirs := asort(aDire,,, { |x, y| x[F_TIME] < y[F_TIME] })
         else
            aDirs := asort(aDire,,, { |x, y| x[F_NAME] < y[F_NAME] })
         endif
      endif

      if len(aDirs) > 0

         // Found more than one file - display menu to choose from

         // Create menu array
         for i := 1 to len(aDirs)
            aadd(aMenu,padr(aDirs[i,F_NAME],12)+" "+dtoc(aDirs[i,F_DATE])+" "+aDirs[i,F_TIME]+" "+padl(alltrim(str(aDirs[i,F_SIZE])),10))
         next

         // Display the menu
         fScrOpsk()
         nBoxc := fBoxCent(4,space(40),16,cMess)
         fScrBood(maxrow()-1,"[Esc]=Menu")
         if cLanType() = "A"
            fScrBood(maxrow()  ,"Kies lˆer met " + D_DNARR + D_UPARR + " pyltjies en druk " + D_ENTER )
         else
            fScrBood(maxrow()  ,"Choose file with " + D_DNARR + D_UPARR + " arrow keys and press " + D_ENTER )
         endif
         i := achoice(5,nBoxc,19,nBoxc+40,aMenu)
         if i > 0
            cRetu := cDire+aDirs[i,F_NAME]
         else
            cRetu := "Esc"
         endif

      endif

   end

   // Herstel
   fARestScr(aCscr)

return cRetu

/******************************************************************************/
FUNCTION fConvIrisId(cData)

   // Function to convert a an Iris idno to Studmaster Idnr

   // Declare
   local cRetu := space(12)
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local cIdno := ""

   // Build the id number to locate
   cKudd := alltrim(substr(cData,5,4))           // Hdm
   cJaar := alltrim(substr(cData,9,2))           // Year
   cVolg := alltrim(str(val(substr(cData,11,4))))// Sequence
   if isdigit(cJaar)
      cIdno := cKudd + cJaar + "-"
   else
      cIdno := cKudd + cJaar
   endif
   if val(cVolg) < 10
      cIdno += "00" + cVolg
   elseif val(cVolg) < 100
      cIdno += "0" + cVolg
   else
      cIdno += cVolg
   endif

   // If no number
   if empty(cKudd) .or. empty(cJaar) .or. empty(cVolg) .or. empty(val(cVolg))
      // Do nothing
   else
      // Store the id
      cRetu := cIdno
   endif

return cRetu
