// Application: StudMaster for Beef Cattle
//   File Name: SM3SALE.PRG
// Description: Program to handle sales information.
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 09-07-94      02:26:43pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3verk( nTopp, nLeft, nBott, aVeld, cFind )

   // Declare
   local aCscr := fASaveScr()                    // Current screen
   local aCdbf := fATopen()                      // Current dbfs
   local cCcur := setcursor(0)                   // Current cursor
   local aOpsk := {}                             // Fields array
   local nScrl := 0                              // Total field length
   local nBoxc := 0                              // Box starting column
   local nRigh := maxcol()-3                     // Right column
   local bBrow := NIL                            // Browse object
   local aCols := {}                             // Columns array
   local i     := 1                              // Counter
   local nKeyp := 1                              // Keypress
   local cRetu := cFind                          // Return value
   local nCurr := 1                              // Current record number
   local lMove := .f.                            // .T. if index key moved
   local cCoun := ""                             // Record display counter
   local cHead := ""                             //Heading of tbrowse
   local lClea := .f.
   local lCoun := .f.
   begin sequence

      // Test if screen must be cleaned
      if empty(nTopp)
         lClea := .t.
      endif

      // Parameters
      nTopp := if(nTopp==NIL,         3,nTopp)
      nLeft := if(nLeft==NIL,         2,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)
      aVeld := if(aVeld==NIL,        {},aVeld)
      cFind := if(cFind==NIL,        "",cFind)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd(aVeld,{"SM3VERK","idnr"     })
         aadd(aVeld,{"SM3DATA","geslag"   })
         aadd(aVeld,{"SM3DATA","uitkrede" })
         aadd(aVeld,{"SM3DATA","uitkdatum"})
         aadd(aVeld,{"SM3VERK","massa"    })
         aadd(aVeld,{"SM3VERK","bedrag"   })
         aadd(aVeld,{"SM3VERK","adreskode"})
      endif
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Datalˆers word geopen")
      else
         fScrBood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      set relation to SM3VERK->IDNR into SM3DATA

      // Move the record pointer
      if !empty(cFind)
         seek cFind
         if eof()
            go top
         endif
      endif

      // Calculate window width
      for i = 1 to len( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,4] + 1
         // Columns
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         aadd( aCols, TBColumnNew( cHead, fieldwblock(aOpsk[i,2],select(strtran(aOpsk[i,1],"->","")))))
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Clear the screen
      if lClea
         fScrOpsk()
      endif

      // Draw the box
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, "VERKOPE" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "SALES" )
      endif
      setcolor( cColNorm() )

      // Build the browse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Build the browse columns
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=Nuwe      [Del]=Skrap")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [AltE]=Verander  [A-Z]=Vind ")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=New   [Del]=Delete")
         fScrBood(maxrow()  , "[F1 ]=Help  [AltE]=Edit  [A-Z]=Find  ")
      endif

      // Freeze
      bBrow:freeze := 1

      // Main loop
      do while nKeyp <> K_ESC

         // Stabilize
         FullStabilize(bBrow)
         if lMove
            do while recno() <> nCurr
               bBrow:up()
               FullStabilize(bBrow)
            enddo
            lMove := .f.
         endif

         // Display the record number
         // cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         // @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            cRetu := fieldget(1)
            nKeyp := K_ESC

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddVerk()
               lCoun := .f.
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fAddVerk(recno())
               lCoun := .f.
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_P
            // Alt P means print a record
            // if !lCoun
            //    if fActions(nPeriod)
            //       bBrow:refreshall()
            //       lCoun := .t.
            //       FullStabilize(bBrow)
            //    endif
            // endif
            // fPrint(nPeriod)

         elseif nKeyp == K_DEL
            // Insert means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_F1
            // Help
            do help with "sm3verk",1,"oorsig"

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            endif

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

   // Herstel
   fATclose(aCdbf)
   fARestScr(aCscr)
   setcursor(cCcur)

return cRetu

/******************************************************************************/
STATIC FUNCTION fAddVerk(nReko)

   // Veranderlikes
   local GetList := {}                           // Getlist
   local aCscr   := fASaveScr()                  // Current screen
   local aCdbf   := fATopen()
   local aVeld   := {}                           // Field descriptions
   local aOpsk   := {}
   local nBoxc   := 0                            // Window box starting column
   local lLoop   := .t.                          // Loop variable
   local i       := 1                            // For variable
   local lRetu   := .f.                          // Return value
   local nLine   := 0                            // Line to display get on
   local lRepeat := .f.                          // Repeat function
   local lClear  := .t.
   local nPrev   := 0
   local cMess   := ""
   begin sequence

      // Values
      nReko := iif(empty(nReko),0,nReko)

      // Kry die velde benodig
      if empty(aOpsk)
         asize(aVeld,0)
         aadd(aVeld,{"SM3VERK","idnr"     })
         aadd(aVeld,{"SM3VERK","adreskode"})
         aadd(aVeld,{"SM3DATA","uitkdatum"})
         aadd(aVeld,{"SM3VERK","massa"    })
         aadd(aVeld,{"SM3VERK","bedrag"   })
         aadd(aVeld,{"SM3DATA","uitkrede" })
         aOpsk := fGetField(aVeld)
      endif

      // Bou veranderlikes
      // Lyn om te vertoon
      nLine := maxrow()/2-int(len(aOpsk)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(50),len(aOpsk)+2,"BEWAAR NUWE VERKOPE" )
         else
            nBoxc := fBoxCent(nLine,space(50),len(aOpsk)+2,"ENTER NEW SALE" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(50),len(aOpsk)+2,"VERANDER VERKOPE" )
         else
            nBoxc := fBoxCent(nLine,space(50),len(aOpsk)+2,"EDIT SALE" )
         endif
      endif

      // Vra die vrae
      lLoop := .t.
      do while lLoop

         if lClear

            // Get the current values
            if nReko == 0

               // Insert a new record
               if lRepeat
                  lRepeat := .f.
                  aOpsk[ 1,14] := space(aOpsk[ 1,4]) // Clean out the id number
               else
                  aOpsk := fFillBlank(aOpsk)
               endif

            else

               // Edit a record by filling the array with current values
               for i := 1 to len(aOpsk)
                  select select(strtran(aOpsk[i,1],"->",""))
                  aOpsk[i,14] := fieldget(aOpsk[i,13])
               next

            endif

         else

            // Clear the get array
            lClear := .t.

         endif

         // Vertoon en get velde
         @nLine+ 1,nBoxc say aOpsk[ 1,6] get aOpsk[ 1,14] pict aOpsk[ 1,10] ;
            when(fWidnr(nReko)) ;
            valid(fVidnr(getlist,aOpsk,nReko))
         @nLine+ 2,nBoxc say aOpsk[ 2,6] get aOpsk[ 2,14] pict aOpsk[ 2,10]
         @nLine+ 3,nBoxc say aOpsk[ 3,6] get aOpsk[ 3,14] pict aOpsk[ 3,10]
         @nLine+ 4,nBoxc say aOpsk[ 4,6] get aOpsk[ 4,14] pict aOpsk[ 4,10]
         @nLine+ 5,nBoxc say aOpsk[ 5,6] get aOpsk[ 5,14] pict aOpsk[ 5,10]
         @nLine+ 6,nBoxc say aOpsk[ 6,6] get aOpsk[ 6,14] pict aOpsk[ 6,10]

         // The get
         readexit(.t.)
         set cursor on
         read
         set cursor off
         readexit(.f.)

         // Reset the database
         fATclose(aCdbf)

         // The actions
         if lastkey() == K_ENTER

            // Add a new record
            if nReko == 0
               dbappend()
            endif

            // Save the entry in sales file
            lRetu := .t.
            //do while !rlock()
            //enddo
            for i := 1 to len(aOpsk)
               select select(strtran(aOpsk[i,1],"->",""))
               if rlock()
                  fieldput(aOpsk[i,13],aOpsk[i,14])
               endif
               unlock
            next
            select SM3DATA
            commit
            select SM3VERK
            commit

            // Store the current record number
            nPrev := recno()

            // Next new record
            if nReko == 0

               // Repeat the previous data
               lRepeat := .t.

               loop

            endif

         else

            // Activate the correct previous record
            if !empty(nPrev)
               goto nPrev
            endif

            // Escaped
            if updated()

               // Warn that data will be lost
               if cLanType() == "A"
                  cMess := "Kan veranderings verlore gaan?"
               else
                  cMess := "Ok to lose changes?"
               endif
               if !fJaNee(maxrow(),cMess)
                  lClear := .f.
                  loop
               endif

            endif

         endif

         lLoop := .f.

      enddo

   end
   // Herstel
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWidnr(nReko)

   // When the id number

   // Declare
   local lRetu  := .t.

   if nReko > 0

      lRetu := .f.

   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVidnr(getlist,aOpsk,nReko)

   // Declare
   local nFocu := 1
   local lRetu := .t.
   local aCscr := fASaveScr()
   local cSeek := ""
   local i     := 1
   local aDisp := aclone(aOpsk)
   begin sequence

      // Determine the get with focus
      for nFocu := 1 to len(getlist)
         if getlist[nFocu]:hasfocus
            exit
         endif
      next

      // The cases
      do case

         case empty(getlist[nFocu]:varget())

            // No number given - exit to browse
            keyboard chr(K_ESC)

         otherwise

            // Test data in sales file
            select SM3VERK
            set order to 1
            seek getlist[nFocu]:varget()
            if eof()

               // Animal not in sales file - allow
            else

               if nReko == recno()

                  // Edit - allow

               else

                  lRetu := .f.

                  // Display the found data
                  for i := 2 to len(aOpsk)
                     select select(strtran(aOpsk[i,1],"->",""))
                     getlist[i]:varput(fieldget(aOpsk[i,13]))
                     getlist[i]:display()
                  next

                  // Screen
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Dier is reeds in die verkopelˆer!")
                  else
                     fScrBood(maxrow()-1,"Animal already in the sales file!")
                  endif
                  fScrWait(maxrow())

                  // Restore the original data
                  for i := 2 to len(aOpsk)
                     getlist[i]:varput(aDisp[i,14])
                     getlist[i]:display()
                  next

                  break

               endif

            endif

            // Test data in main file
            select SM3DATA
            set order to 1
            seek getlist[nFocu]:varget()

            if eof()

               // Animal unknown
               lRetu := .f.
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"Dier is onbekend!")
               else
                  fScrBood(maxrow()-1,"Animal is unknown!")
               endif
               fScrWait(maxrow())

            elseif SM3DATA->uitkrede $ cWaarisd()

               // Animal exist and in herd - allow

            else

               // Animal no longer in the herd - do not allow
               lRetu := .f.
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"Dier het reeds die kudde op " + dtoc(SM3DATA->uitkdatum) + " verlaat!")
               else
                  fScrBood(maxrow()-1,"Animal left the herd on " + dtoc(SM3DATA->uitkdatum) + "!")
               endif
               fScrWait(maxrow())

            endif

      endcase

   end

   // Herstel
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDelete

   // Function to delete records

   // Declare
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local lRetu := .f.
   local cBood := ""

   // Screen
   if cLanType() == "A"
      cBood := "Moet bogenoemde VERKOPING geskrap word?"
   else
      cBood := "Should above-mentioned SALE be deleted?"
   endif
   fScrBood(maxrow()-1,SM3VERK->idnr)
   if fJaNee(maxrow(),cBood,,.f. )
      if rlock()
         delete
         dbUnlock()
         skip
         if eof()
            go top
         endif
         lRetu := .t.
      endif
   endif

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fLocate(cKeyp)

   // Function to locate any record

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nBoxc := 0
   local getlist := {}

   // Field length
   cKeyp += space(11)
   keyboard chr(K_RIGHT)

   // Vra die soekveranderlike
   fScrBood(maxrow()-1)
   if cLanType() == "A"
      fScrBood(maxrow(),"Tik die ID NOMMER van die dier waarvoor gesoek word!")
      nBoxc := fBoxCent(maxrow()/2,"Vind? xxxxxx",1)
      @maxrow()/2, nBoxc say "Vind?" get cKeyp pict "@!"
   else
      fScrBood(maxrow(),"Type the ID NUMBER of the animals being searched for!")
      nBoxc := fBoxCent(maxrow()/2,"Find? xxxxxx",1)
      @maxrow()/2, nBoxc say "Find?" get cKeyp pict "@!"
   endif

   // Read
   set cursor on
   read
   set cursor off
   fARestScr(aCscr)

   // To do
   if lastkey() == K_ESC
      lRetu := .f.
   else
      set soft on
      seek cKeyp
      set soft off
      if eof()
         go top
      endif
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(nPeriod)

   // Declare
   local nPrnW := nPrnWidt()
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local aOpsk := {}
   local nTota := 1
   local lLoop := .t.
   local i     := 1
   local nBlad := 1
   local nReko := 1
   local nCols := 50
   local nLeng := 79
   local cPrnl := ""
   local lRecn := .t.
   local lAver := .f.
   local cHead := ""
   local nBoxc := 0
   local aTscr := {}
   local nWidt := 0
   local cSubh := ""
   local nCoun := 1
   local cSeek := ""
   local aSeek := {}
   local nTel  := 1
   private cData := ""
   private cPrnt := ""

   begin sequence

      // Test availability of printer
      fScrBood(maxrow()-1)
      if fPrnReady() == K_ESC
         break
      endif

      // See if there is own report
      if cLanType() == "A"
         cSeek := "AKSIES"
      else
         cSeek := "ACTION"
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3EIEV")
      if !aCdbf[len(aCdbf),1]
      else
         seek cSeek
         if found()
            nTel := 1
            for i = 1 to 40
               if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
                  aadd(aSeek,{trim(substr(SM3EIEV->veld,nTel,10)),trim(substr(SM3EIEV->veld,nTel+10,10))})
               endif
               nTel := nTel + 20
            next
         endif
      endif

      // Screen - fields to print
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Drukuitleg word bepaal")
      else
         fScrBood(maxrow(),"Print outlay being determined")
      endif
      if empty(aOpsk)
         aadd(aVeld,{"SM3ACTI","date"})
         aadd(aVeld,{"SM3ACTI","idnr"})
         for i := 1 to len(aSeek)
            aadd(aVeld,{aSeek[i,1],aSeek[i,2]})
         next
      endif
      aOpsk := fGetField(aVeld)

      // Headings
      if cLanType() == "A"
         cHead := "Aksielys vir die periode " + dtoc(dAppDate()) + " tot " + dtoc(dAppDate()+nPeriod) + "."
      else
         cHead := "Attention list for the period " + dtoc(dAppDate()) + " to " + dtoc(dAppDate()+nPeriod) + "."
      endif

      // Determine the print width
      nLeng := nPrnW-1
      nCols := nPrnW-20
      cPrnt := cPrnNorm()
      if lRecn
         nWidt := 5
      else
         nWidt := 0
      endif
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,4] + 1
      next
      if nWidt > nPrnWidt
         nLeng := nPrnCwid()
         nCols := nLeng-19
         cPrnt := cPrnCond()
      endif

      // Open the database files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      select SM3ACTI
      set relation to SM3ACTI->IDNR into SM3DATA, to SM3ACTI->CODE into SM3INEN
      go top
      nTota := lastrec()

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"AKSIELYS word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(maxrow(),"ATTENTION LIST being printed!  [Esc]=Stop printer.")
      endif

      //Skakel die drukker aan
      fPrnOn()

      // The loop
      lLoop := .t.
      do while lLoop


         //Opskrifte
         if prow() = 0

            fPrnCod( cPrnt )
            @prow()+1,  1 say upper( cGebNaam() )
            if cLanType() == "A"
               @prow()  ,nCols say "     Datum: " + dtoc( dAppDate() )
               @prow()+1,    1 say cHead
               @prow()  ,nCols say "    Bladsy: " + ltrim( str( nBlad, 8 ) )
            else
               @prow()  ,nCols say "      Date: " + dtoc( dAppDate() )
               @prow()+1,    1 say cHead
               @prow()  ,nCols say "      Page: " + ltrim( str( nBlad, 8 ) )
            endif
            @prow()+1,  1 say repl( "=", nLeng )

            // 1e Lyn van opskrif
            if lRecn
               cPrnl := "     "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,7]),aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nLeng)

            // 2e Lyn van opskrif
            if lRecn
               cPrnl := "     "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,8]),aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nLeng)

            // 3e Lyn van opskrif
            if lRecn
               cPrnl := "#### "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,9]),aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nLeng)

            // 4e Lyn van opskrif
            if lRecn
               cPrnl := "---- "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += repl("-",aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nLeng)

            // 5e Lyn van opskrif
            @prow()+1,1 say repl("=",nLeng)

         endif

         // Stop printer
         if fPrnStop() = K_ESC
            break
         endif

         // Advance if action not to be printed
         do while empty(SM3INEN->merk) .and. !eof()
            select SM3ACTI
            skip
            nReko++
         enddo

         // Print subheading
         if !eof()
            if SM3ACTI->code == cSubh
            else
               cSubh := SM3ACTI->code
               @prow()+1,1 say ""
               @prow()+1,1 say trim(SM3INEN->besk)
               @prow()+1,1 say repl("-",len(trim(SM3INEN->besk)))
               nCoun := 1
            endif
         endif

         // Data
         if !eof()
            if lRecn
               cPrnl := str(nCoun,4,0) + " "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cData := aOpsk[i,1] + aOpsk[i,2]
               if aOpsk[i,3] == "D"
                  cPrnl += dtoc(&cData) + " "
               elseif aOpsk[i,3] == "N"
                  cPrnl += str(&cData,aOpsk[i,4],aOpsk[i,5]) + " "
               else
                  cPrnl += &cData + " "
               endif
            next
            @prow()+1,1 say left(cPrnl,nLeng)
            nCoun++
         endif

         // Skerm
         // fPrnOff()
         // if nTota > 0
         //    setcolor( cColBott() )
         //    if cLanType() == "A"
         //       fScrBood(maxrow()-1,str((nReko/nTota)*100,4,0)+" % Voltooi")
         //    else
         //       fScrBood(maxrow()-1,str((nReko/nTota)*100,4,0)+" % Completed")
         //    endif
         //    setcolor( cColNorm() )
         //    nReko++
         // endif
         // fPrnOn()

         // Volgende rekord
         select SM3ACTI
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnLeng()-8 .or. eof()

            //Print averages if exist
            if eof() .and. lAver
               //Averages
               if lRecn
                  cPrnl := "     "
               else
                  cPrnl := ""
               endif
               for i := 1 to len(aOpsk)
                  if empty(aOpsk[i,11])
                     cPrnl += repl(" ",aOpsk[i,4]) + " "
                  else
                     cPrnl += str(aOpsk[i,12]/aOpsk[i,11],aOpsk[i,4],aOpsk[i,5]) + " "
                  endif
               next
               if cLanType() == "A"
                  cPrnl := strtran(cPrnl,space(12),"Gemiddeldes:",1,1)
               else
                  cPrnl := strtran(cPrnl,space( 9),"Averages:",1,1)
               endif
               @prow()+2,1 say left(cPrnl,nLeng)
               //Totals
               if lRecn
                  cPrnl := "     "
               else
                  cPrnl := ""
               endif
               for i := 1 to len(aOpsk)
                  if empty(aOpsk[i,11])
                     cPrnl += repl(" ",aOpsk[i,4]) + " "
                  else
                     cPrnl += str(aOpsk[i,12],aOpsk[i,4],aOpsk[i,5]) + " "
                  endif
               next
               if cLanType() == "A"
                  cPrnl := strtran(cPrnl,space(7),"Totale:",1,1)
               else
                  cPrnl := strtran(cPrnl,space(7),"Totals:",1,1)
               endif
               @prow()+1,1 say left(cPrnl,nLeng)
            endif

            //Print onderste lyn
            @prow()+1, 1 say repl("=",nLeng)
            @prow()+1, 1 say cAppName()
            fPrnCod( cPrnNorm() )

            // Form feed
            fPrnEjec()
            //fPrnOff()
            nBlad++
            cSubh := ""

            //Indien eof()
            if eof()
               lLoop := .f.
            endif

         endif

      enddo

      fPrnOff()

   end
   //Herstel
   select SM3ACTI
   set relation to
   fATclose(aCdbf)
   fARestScr(aCscr)
return NIL

