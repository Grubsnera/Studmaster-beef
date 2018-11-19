
// Old SM3SIEK.PRG replaced by a new one 28/9/95

//SM3SIEK.PRG
//Program om Siektes te bewaar en skrap
//Kopiereg (c) 1992 A van Rensburg
//12:44pm May 26,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3Siek( nTop, nLeft, nBottom, aVelde, cFind )

   //Veranderlikes
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := Setcursor(0)                 //Cursor
   LOCAL aAdraOp := {}                           //Plaas opskrifte
   local aSiekOp := {}
   LOCAL nScrlen := 0                            //Totale lengte van die veld
   LOCAL nBoxCoo := 0                            //Waar begin en endig die boks
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i                                       //Counter
   LOCAL lMore                                   //Logical looper
   LOCAL nKey                                    //Keypress
   LOCAL cReturn := cFind                        //Return value
   LOCAL lLogic                                  //Diverse logic carrier
   LOCAL cSiek
   local cLocate := ""
   local cLocScr := ""
   local nBoxCoor := 0
   local getlist := {}

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 4, nBottom )
   cFind := if( cFind == NIL, "     ", cFind )

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrBood(24,"Screen outlay being determined")
   endif

   //Kry die veldbeskrywings
   //aVelde is array met velde wat vertoon moet word
   //aSiekOp is array met volledige veldbesonderhede
   aSiekOp := fGetfield( aVelde )

   //Kry totale lengte van velde om breedte van venster te bepaal
   for i = 1 to len( aSiekOp )
      //Lengte
      nScrlen := nScrlen + aSiekOp[i,4] + 1

      //Kolomme
      cData := aSiekOp[i,1] + aSiekOp[i,2]
      cHead := aSiekOp[i,7] + ";" + aSiekOp[i,8] + ";" + aSiekOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die boks
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "SIEKTES" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "DISEASES" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas Kolomme oor na die browse object
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
   cSiek := fTOpen( cDd(), "SM3SIEK", , "dbf", , .t., .f. )
   if left(cSiek, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurscr )
      restscreen( 0, 0, 24, 79, cCurske )
      return cReturn
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

   //Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar  [Alt E]=Verander  [A - Z]=Vind       " )
         fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [Alt P]=Druk      [Alt X]=Behandeling" )
      else
         fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [Alt E]=Edit   [A - Z]=Find     ")
         fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [Alt P]=Print  [Alt X]=Treatment")
      endif

      //Vries
      //cBrowse:Freeze := 2

      //Sabilize display until stable or key is pressed
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
         // Everything's done -- wait for a key
         nKey := Inkey(0)
      endif

      if nKey == K_ESC
         // Esc means Leave
         lMore := .f.

      elseif nKey == K_ENTER
         //Enter means return kode and exit
         cReturn := fieldget(1) + " " + fieldget(2) + " "
         lMore := .f.

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_X
         //Display Behandeling
         fBehand()
         cBrowse:refreshall()


      elseif nKey == K_ALT_P
         //Alt P means print a record
         fPrint()
         //Vra of hoeveelhede nul gemaak moet word.
         if cLanType() == "A"
            if fJaNee(24,"Moet hoeveelheid nul gemaak word?",,)
               go top
               if flock()
                  do while !eof()
                     SM3SIEK->voor := 0
                     skip
                  enddo
                  go top
               else
               endif
            endif
         else
            if fJaNee(24,"Should quantity be made zero?",,)
               go top
               if flock()
                  do while !eof()
                     SM3SIEK->voor := 0
                     skip
                  enddo
                  go top
               else
               endif
            endif
         endif

         cBrowse:refreshall()

      elseif nKey ==K_ALT_E
         //Alt E means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_DEL
         // Del means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "SM3DISE",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + "  "
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik die gedeelte van die kode waarvoor gesoek moet word.")
         else
            fScrBood(24,"Type a section of the code which should be found.)                  ")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter Kode? xxx", 1 )
            @12, nBoxCoor say "Vind watter Kode?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find what Code? xxx", 1 )
            @12, nBoxCoor say "Find what Code? " get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
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
   fTClose( cSiek )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurske )
   setcursor( cCurCur )

return cReturn

/**************************************************************************/
STATIC FUNCTION fAddChg

   //Veranderlikes
   LOCAL Getlist := {}
   LOCAL cCurSke := Savescreen( 0, 0, 24, 79 )
   LOCAL aSend   := {}
   LOCAL aRecv   := {}
   LOCAL nRekord := 0
   LOCAL aData   := {}
   LOCAL nBoxCoor:= 0
   LOCAL nLoop   := 0
   LOCAL lLoop   := .t.
   LOCAL i       := 1
   LOCAL lReturn := .f.
   LOCAL aVelde  := {}
   LOCAL aBeha   := {}

   //Kry die velde benodig
   asize( aSend, 0 )
   aadd( aSend, { "sm3siek", "kode" })
   aadd( aSend, { "sm3siek", "besk" })
   aadd( aSend, { "sm3siek", "B1"  })
   aadd( aSend, { "sm3siek", "B2"  })
   aadd( aSend, { "sm3siek", "B3"  })
   aadd( aSend, { "sm3siek", "B4"  })
   aadd( aSend, { "sm3siek", "B5"  })
   aadd( aSend, { "sm3siek", "B6"  })
   aadd( aSend, { "sm3siek", "B7"  })
   aadd( aSend, { "sm3siek", "B8"  })
   aadd( aSend, { "sm3siek", "B9"  })
   aadd( aSend, { "sm3siek", "B10" })
   aadd( aSend, { "sm3siek", "voor" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
   else
      nRekord := recno()
   endif

   //Lees data
   for i = 1 to len( aRecv )
      aRecv[i][14] := Fieldget( aRecv[i,13] )
   next

   //Skerm
   if cLanType() == "A"
      nBoxCoor := fBoxCent( 6, space(40), 14, "BEWAAR/VERANDER SIEKTES" )
   else
      nBoxCoor := fBoxCent( 6, space(40), 14, "ENTER/EDIT DISEASES" )
   endif

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @  7, nBoxCoor say aRecv[1 ,6]
   @  8, nBoxCoor say aRecv[2 ,6]
   @  9, nBoxCoor say aRecv[3 ,6]
   @ 10, nBoxCoor say aRecv[4 ,6]
   @ 11, nBoxCoor say aRecv[5 ,6]
   @ 12, nBoxCoor say aRecv[6 ,6]
   @ 13, nBoxCoor say aRecv[7 ,6]
   @ 14, nBoxCoor say aRecv[8 ,6]
   @ 15, nBoxCoor say aRecv[9 ,6]
   @ 16, nBoxCoor say aRecv[10,6]
   @ 17, nBoxCoor say aRecv[11,6]
   @ 18, nBoxCoor say aRecv[12,6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @  7, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
         @  8, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
         @  9, nBoxCoor+21 say transform( aRecv[3][14] , aRecv[3][10]  )
         @ 10, nBoxCoor+21 say transform( aRecv[4][14] , aRecv[4][10]  )
         @ 11, nBoxCoor+21 say transform( aRecv[5][14] , aRecv[5][10]  )
         @ 12, nBoxCoor+21 say transform( aRecv[6][14] , aRecv[6][10]  )
         @ 13, nBoxCoor+21 say transform( aRecv[7][14] , aRecv[7][10]  )
         @ 14, nBoxCoor+21 say transform( aRecv[8][14] , aRecv[8][10]  )
         @ 15, nBoxCoor+21 say transform( aRecv[9][14] , aRecv[9][10]  )
         @ 16, nBoxCoor+21 say transform( aRecv[10][14], aRecv[10][10] )
         @ 17, nBoxCoor+21 say transform( aRecv[11][14], aRecv[11][10] )
         @ 18, nBoxCoor+21 say transform( aRecv[12][14], aRecv[12][10] )
         setcolor(cColNorm())
      endif

      do case
         case nLoop == 1
            //Siektekode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektes." )
               fScrBood( 24, "Tik die siektekode." )
            else
               fScrBood( 23, "[Esc]=Return to diseases." )
               fScrBood( 24, "Type the disease code." )
            endif
            @  7, nBoxCoor say aRecv[1,6] get aRecv[1][14] pict aRecv[1,10]
            set curs on
            read
            set curs off
            //Return to master
            if lastkey() == K_ESC .or. aRecv[1][14] == space(3)
               if eof()
                  go top
               endif
               nLoop := 0
               loop
            endif
            lReturn := .t.
            //Toets of die rekord reeds bestaan
            seek upper(aRecv[1][14])
            //Dieselfde rekord
            if eof()
               if nRekord > 0
                  goto nRekord
               endif
               nLoop++
               loop
            else
               if nRekord > 0 .and. nRekord == recno()
                  nLoop++
               else
                  //Vul data
                  for i = 1 to len( aRecv )
                     aRecv[i][14] := fieldget( aRecv[i,13] )
                  next
                  //Vertoon data
                  setcolor(cColInve())
                  @  7, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
                  @  8, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
                  @  9, nBoxCoor+21 say transform( aRecv[3][14] , aRecv[3][10]  )
                  @ 10, nBoxCoor+21 say transform( aRecv[4][14] , aRecv[4][10]  )
                  @ 11, nBoxCoor+21 say transform( aRecv[5][14] , aRecv[5][10]  )
                  @ 12, nBoxCoor+21 say transform( aRecv[6][14] , aRecv[6][10]  )
                  @ 13, nBoxCoor+21 say transform( aRecv[7][14] , aRecv[7][10]  )
                  @ 14, nBoxCoor+21 say transform( aRecv[8][14] , aRecv[8][10]  )
                  @ 15, nBoxCoor+21 say transform( aRecv[9][14] , aRecv[9][10]  )
                  @ 16, nBoxCoor+21 say transform( aRecv[10][14], aRecv[10][10] )
                  @ 17, nBoxCoor+21 say transform( aRecv[11][14], aRecv[11][10] )
                  @ 18, nBoxCoor+21 say transform( aRecv[12][14], aRecv[12][10] )
                  setcolor(cColNorm())
                  fScrBood( 23 )
                  if cLanType() == "A"
                     fScrwait( 24, "Siekte is reeds op rekenaar!" )
                  else
                     fScrWait( 24, "Disease already on computer!" )
                  endif
                  if nRekord > 0
                     goto nRekord
                  else
                     go bottom
                     skip
                  endif
               endif
            endif

            //Vul data
            for i = 1 to len( aRecv )
               aRecv[i][14] := fieldget( aRecv[i,13] )
            next

         case nLoop == 2
            //Beskrywing van Siekte
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode." )
               fScrBood( 24, "Tik 'n beskrywing van die siekte." )
            else
               fScrBood( 23, "[Esc]=Return to disease code." )
               fScrBood( 24, "Type a description of the disease." )
            endif
            @  8, nBoxCoor say aRecv[2,6] get aRecv[2][14] pict aRecv[2,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_ENTER
                  if aRecv[2][14] == space(25)
                     if cLanType() == "A"
                        fScrBood(23, "Die beskrywing is verpligtend.")
                     else
                        fScrBood(23, "The description is compulsory.")
                     endif
                     fScrBood(24)
                     loop
                  endif
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 3
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @  9, nBoxCoor say aRecv[3,6] get aRecv[3][14] pict aRecv[3,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0)
                  aadd( aBeha, {"sm3beha" ,"kode" })
                  aadd( aBeha, {"sm3beha" ,"besk" })
                  aadd( aBeha, {"sm3beha" ,"pakk" })
                  aadd( aBeha, {"sm3beha" ,"prys" })
                  aadd( aBeha, {"sm3beha" ,"pdos" })
                  aadd( aBeha, {"sm3beha" ,"tdos" })
                  aRecv[3][14] := left(sm3beha(4,4,20,aBeha,aRecv[3][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 4
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 10, nBoxCoor say aRecv[4,6] get aRecv[4][14] pict aRecv[4,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[4][14] := left(sm3beha(4,4,20,aBeha,aRecv[4][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 5
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 11, nBoxCoor say aRecv[5,6] get aRecv[5][14] pict aRecv[5,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[5][14] := left(sm3beha(4,4,20,aBeha,aRecv[5][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 6
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 12, nBoxCoor say aRecv[6,6] get aRecv[6][14] pict aRecv[6,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[6][14] := left(sm3beha(4,4,20,aBeha,aRecv[6][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 7
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 13, nBoxCoor say aRecv[7,6] get aRecv[7][14] pict aRecv[7,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[7][14] := left(sm3beha(4,4,20,aBeha,aRecv[7][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 8
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling")
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 14, nBoxCoor say aRecv[8,6] get aRecv[8][14] pict aRecv[8,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[8][14] := left(sm3beha(4,4,20,aBeha,aRecv[8][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 9
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 15, nBoxCoor say aRecv[9,6] get aRecv[9][14] pict aRecv[9,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[9][14] := left(sm3beha(4,4,20,aBeha,aRecv[9][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 10
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @  16, nBoxCoor say aRecv[10,6] get aRecv[10][14] pict aRecv[10,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[10][14] := left(sm3beha(4,4,20,aBeha,aRecv[10][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 11
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 17, nBoxCoor say aRecv[11,6] get aRecv[11][14] pict aRecv[11,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[11][14] := left(sm3beha(4,4,20,aBeha,aRecv[11][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 12
            //Behandelingskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na siektekode  "+D_DNARR+"=Behandeling" )
               fScrBood( 24, "Tik die behandeling." )
            else
               fScrBood( 23, "[Esc]=Return to disease code  "+D_DNARR+"=Treatment" )
               fScrBood( 24, "Type the treatment." )
            endif
            @ 18, nBoxCoor say aRecv[12,6] get aRecv[12][14] pict aRecv[12,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Display Behandeling
                  asize( aBeha, 0 )
                  aadd( aBeha, { "sm3beha", "kode" })
                  aadd( aBeha, { "sm3beha", "besk" })
                  aadd( aBeha, { "sm3beha", "pakk" })
                  aadd( aBeha, { "sm3beha", "prys" })
                  aadd( aBeha, { "sm3beha", "pdos" })
                  aadd( aBeha, { "sm3beha", "tdos" })
                  aRecv[12][14] := left(sm3beha(4,4,20,aBeha,aRecv[12][14]),3)
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         otherwise
            //Bewaar rekord
            if nRekord > 0
               goto nRekord
            else
               appe blank
            endif

            lLoop := .T.
            do while lLoop
               if rlock()
                  for i = 1 to len( aRecv )
                     //Bewaar die data
                     fieldput( aRecv[i,13], aRecv[i][14] )
                     //Maak datavelde skoon
                     do case
                        case aRecv[i][3]  == "N"
                           aRecv[i][14] := 0
                        case aRecv[i][3]  == "D"
                           aRecv[i][14] := ctod("  /  /  ")
                        otherwise
                           aRecv[i][14] := space( aRecv[i,4] )
                     endcase
                  next
                  commit
                  exit
               endif
            enddo

            if nRekord = 0
               nLoop := 1
            else
               nRekord = 0
               nLoop := 0
            endif
      endcase
   enddo

   //Herstel
   restscreen( 0,0,24,79, cCurske )
return lReturn

/**************************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige produktipe totaal en al te skrap

   //Verklaar
   LOCAL lReturn := .f.

   fScrBood( 23, Trim( SM3SIEK->kode ) + " - " + trim( SM3SIEK->besk ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde siekte geskrap word?", , .f. )
         if rlock()
            delete
            dbUnlock()
            skip
            if eof()
               go top
            endif
            lReturn := .t.
         endif
      endif
   else
      if fJaNee( 24, "Should above-mentioned disease be deleted?", , .f. )
         if rlock()
            delete
            dbUnlock()
            skip
            if eof()
               go top
            endif
            lReturn := .t.
         endif
      endif
   endif


return lReturn

/***********************************************************************/
STATIC FUNCTION fPrint

   //Verklaar
   LOCAL aVelde  := {}
   LOCAL aDbfOp  := {}
   LOCAL cWaar   := NIL
   LOCAL nTotaal := 1
   LOCAL lLoop   := .t.
   LOCAL nI      := 1
   LOCAL nBladsy := 1
   LOCAL nRekord := 1

   PRIVATE cData

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif

   //Kry die velde wat gedruk moet word
   asize( aVelde, 0 )
   aadd( aVelde, { "sm3siek", "kode" } )
   aadd( aVelde, { "sm3siek", "besk" } )
   aadd( aVelde, { "sm3siek", "voor" })
   aadd( aVelde, { "sm3siek", "b1" } )
   aadd( aVelde, { "sm3siek", "b2" } )
   aadd( aVelde, { "sm3siek", "b3" })
   aadd( aVelde, { "sm3siek", "b4" } )
   aadd( aVelde, { "sm3siek", "b5" } )
   aadd( aVelde, { "sm3siek", "b6" })
   aadd( aVelde, { "sm3siek", "b7" })
   aadd( aVelde, { "sm3siek", "b8" } )
   aadd( aVelde, { "sm3siek", "b9" } )
   aadd( aVelde, { "sm3siek", "b10" })
   aDbfOp := fGetField( aVelde )

   nTotaal := lastrec()
   go top

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrbood(24,"Siektes word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Diseases being printed!  [Esc]=Stop printer." )
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := .t.
   do while lLoop


      //Opskrifte
      if prow() = 0

         fPrnCod( cPrnNorm() )
         @prow()+1,  1 say upper( cGebNaam() )
         if cLanType() == "A"
            @prow()  , 50 say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,  1 say upper( "Siektes." )
            @prow()  , 50 say "              Bladsy: " + str( nBladsy, 8 )
         else
            @prow()  , 50 say "                Date: " + dtoc( dAppDate() )
            @prow()+1,  1 say upper( "Diseases." )
            @prow()  , 50 say "                Page: " + str( nBladsy, 8 )
         endif
         @prow()+1,  1 say repl( "=", 79 )
         //1e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] )
            endif
         next
         //2e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4])
            endif
         next
         //3e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4])
            endif
         next
         //4e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say repl( "-", aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say repl( "-", aDbfOp[nI,4] )
            endif
         next
         @prow()+1,  1 say repl( "=", 79 )

      endif

      //Toets of drukker moet stop
      If fPrnStop() = K_ESC
         fTClose( cWaar )
         return NIL
      endif

      //Data
      for nI = 1 to len( aDbfOp )
         cData := aDbfOp[nI,1] + aDbfOp[nI,2]
         if nI == 1
            @prow()+1,  1 say &cData
         else
            @prow()  ,pcol()+1 say &cData
         endif
      next

      //Skerm
      // fPrnOff()
      // if nTotaal > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Vol"
      //    else
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Com"
      //    endif
      //    setcolor( cColNorm() )
      //    nRekord++
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnLeng() .or. eof()

         //Print onderste lyn
         @prow()+1,  1 say repl( "=", 79 )
         @prow()+1,  1 say cAppName()
         fPrnCod( cPrnNorm() )

         // Form Feed
         fPrnEjec()
         nBladsy++

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   go top
return NIL

/**************************************************************************/
FUNCTION fBehand

   //Veranderlikes
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cBehDbf := fTOpen()                     //Databasis
   LOCAL cSiekte
   LOCAL aBeha[10]
   LOCAL cBeha
   LOCAL cTemp
   local nBoxCoor := 0

   //Display Behandeling
   //Open die .dbf
   cBeha := fTOpen( cDd(), "SM3BEHA", , "dbf", , .t., .f. )
   if left(cBeha, 1 ) == "f"
      fTClose( cBehDbf )
      fSetScreen( cCurscr )
      restscreen( 0, 0, 24, 79, cCurske )
      return NIL
   endif

   cSiekte := SM3SIEK->besk
   //Skerm
   if cLanType() == "A"
      nBoxCoor := fBoxCent( 6, space(30), 12, "Behandelings vir "+cSiekte )
   else
      nBoxCoor := fBoxCent( 6, space(30), 12, "Treatments for   "+cSiekte )
   endif
   setcolor(cColNorm())

   //Soekstring
   cTemp := SM3SIEK->b1
   select SM3BEHA
   seek cTemp
   aBeha[1] := cTemp+"  "+SM3BEHA->besk
   @  7, nBoxCoor say aBeha[1]

   cTemp := SM3SIEK->b2
   select SM3BEHA
   seek cTemp
   aBeha[2] := cTemp+"  "+SM3BEHA->besk
   @  8, nBoxCoor say aBeha[2]

   cTemp := SM3SIEK->b3
   select SM3BEHA
   seek cTemp
   aBeha[3] := cTemp+"  "+SM3BEHA->besk
   @  9, nBoxCoor say aBeha[3]

   cTemp := SM3SIEK->b4
   select SM3BEHA
   seek cTemp
   aBeha[4] := cTemp+"  "+SM3BEHA->besk
   @ 10, nBoxCoor say aBeha[4]

   cTemp := SM3SIEK->b5
   select SM3BEHA
   seek cTemp
   aBeha[5] := cTemp+"  "+SM3BEHA->besk
   @ 11, nBoxCoor say aBeha[5]

   cTemp := SM3SIEK->b6
   select SM3BEHA
   seek cTemp
   aBeha[6] := cTemp+"  "+SM3BEHA->besk
   @ 12, nBoxCoor say aBeha[6]

   cTemp := SM3SIEK->b7
   select SM3BEHA
   seek cTemp
   aBeha[7] := cTemp+"  "+SM3BEHA->besk
   @ 13, nBoxCoor say aBeha[7]

   cTemp := SM3SIEK->b8
   select SM3BEHA
   seek cTemp
   aBeha[8] := cTemp+"  "+SM3BEHA->besk
   @ 14, nBoxCoor say aBeha[8]

   cTemp := SM3SIEK->b9
   select SM3BEHA
   seek cTemp
   aBeha[9] := cTemp+"  "+SM3BEHA->besk
   @ 15, nBoxCoor say aBeha[9]

   cTemp := SM3SIEK->b10
   select SM3BEHA
   seek cTemp
   aBeha[10] := cTemp+"  "+SM3BEHA->besk
   @ 16, nBoxCoor say aBeha[10]

   //Herstel
   fScrBood(23)
   fScrWait()
   fTClose( cBeha )
   fTClose( cBehDbf )
   go top
return NIL

