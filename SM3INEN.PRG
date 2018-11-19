// Application: StudMaster for Beef Cattle
//   File Name: SM3INEN.PRG
// Description: Program to handle the innoculation program.
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 09-05-94      08:30:36am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3inen( nTopp, nLeft, nBott, aVeld, cFind )

   // Veranderlikes
   local aCscr      := fASaveScr()               // Skerm
   local aCdbf      := fATopen()                 // Databasis
   local cCcur      := setcursor(0)              // Cursor
   local aOpsk      := {}                        // Opskrifte
   local nScrl      := 0                         // Totale lengte van die velde
   local nBoxc      := 0                         // Waar begin en eindig die box
   local nRigh      := maxcol()-3                // Regterkantste lyn
   local bBrow      := NIL                       // Browse object
   local aCols      := {}                        // Kolomme array
   local i          := 1                         // Counter
   local lMore      := .t.                       // Logical looper
   local nKeyp      := 1                         // Keypress
   local cRetu      := cFind                     // Return value
   local nOldRecord := 1                         // Current record number
   local lMoved     := .F.                       // .T. if index key moved
   local cCoun      := ""
   local lCounted   := .f.
   local nPeriod    := nDayActi()

   private cData := ""                           //Column data fields for tbrowse
   private cHead := ""                           //Heading of tbrowse

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   begin sequence

      // Parameters
      nTopp := if(nTopp==NIL,         3,nTopp)
      nLeft := if(nLeft==NIL,         2,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)
      aVeld := if(aVeld==NIL,        {},aVeld)
      cFind := if(cFind==NIL,        "",cFind)

      // Skerm - veldbeskrywings
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd(aVeld,{"SM3INEN","merk"})
         aadd(aVeld,{"SM3INEN","kode"})
         aadd(aVeld,{"SM3INEN","besk"})
         aadd(aVeld,{"SM3INEN","tydp"})
         aadd(aVeld,{"SM3INEN","tbes"})
         aadd(aVeld,{"SM3INEN","gesl"})
         aadd(aVeld,{"SM3INEN","comp"})
         aadd(aVeld,{"SM3INEN","aant"})
      endif
      aOpsk := fGetField(aVeld)

      // Skerm - open dataleers
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Datalˆers word geopen")
      else
         fScrBood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3ACTI",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3INEN",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Skuif die databasis
      if !empty(cFind)
         seek cFind
         if eof()
            go top
         endif
      endif

      // Count the action
      if lastrec() > 0
         lCounted := .t.
         fActions(nPeriod)
      endif

      // Kry die totale lengte van die velde om die
      // breedte van die venster te bepaal
      for i = 1 to len( aOpsk )
         // Lengte
         nScrl := nScrl + aOpsk[i,4] + 1
         // Kolomme
         cData := aOpsk[i,1] + aOpsk[i,2]
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
      next

      // Bepaal regterkantste lyn
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Clear the screen
      if empty(nTopp)
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

      // Teken die box
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, "AKSIELYS" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "ATTENTION LIST" )
      endif
      setcolor( cColNorm() )

      // Bou die tBrowse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Plaas kolomme oor na die browse object
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Skerm
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc]=Menu  [Enter]=Vertoon  [Ins ]=Nuwe      [Del]=Skrap  [AltR ]=Bereken  ")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [AltP ]=Druk     [AltE]=Verander  [A-Z]=Vind   [Space]=MerkAanAf")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Enter]=View   [Ins ]=New   [Del]=Delete  [AltR ]=Recalculate")
         fScrBood(maxrow()  , "[F1 ]=Help  [AltP ]=Print  [AltE]=Edit  [A-Z]=Find    [Space]=Mark toggle")
      endif

      // Freeze
      // bBrow:freeze := 1

      // Main loop
      do while nKeyp <> K_ESC

         // Stabilize
         FullStabilize(bBrow)
         if lMoved
            do while recno() <> nOldRecord
               bBrow:up()
               FullStabilize(bBrow)
            enddo
            lMoved := .F.
         endif

         // Display the record number
         cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            fView(4,52,maxrow()-4,,SM3INEN->kode)
            //cRetu := fieldget(2)
            //nKeyp := K_ESC

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nOldRecord := recno()
            if fAddInen()
               lCounted := .f.
               lMoved := .t.
               nOldRecord := recno()
               bBrow:refreshall()
            else
               goto nOldRecord
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nOldRecord := recno()
            if fAddInen(recno())
               lCounted := .f.
               lMoved := .t.
               nOldRecord := recno()
               bBrow:refreshall()
            else
               goto nOldRecord
            endif

         elseif nKeyp == K_ALT_R
            // Alt R means recalculate
            if fActions(nPeriod)
               bBrow:refreshall()
               lCounted := .t.
            endif

         elseif nKeyp == K_SPACE
            // Space means toggle mark
            if empty(SM3INEN->merk)
               SM3INEN->merk := chr(251)
            else
               SM3INEN->merk := " "
            endif
            bBrow:refreshcurrent()

         elseif nKeyp == K_ALT_P
            // Alt P means print a record
            if !lCounted
               if fActions(nPeriod)
                  bBrow:refreshall()
                  lCounted := .t.
                  FullStabilize(bBrow)
               endif
            endif
            fPrint(nPeriod)

         elseif nKeyp == K_ALT_V
            // Alt V means view
            fView(4,52,maxrow()-4,,SM3INEN->kode)

         elseif nKeyp == K_DEL
            // Insert means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_F1
            // Help
            do help with "sm3inen",1,"oorsig"

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               lMoved := .T.
               nOldRecord := recno()
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
   setcursor( cCcur )

return cRetu

/******************************************************************************/
STATIC FUNCTION fAddInen(nReko)

   // Veranderlikes
   local GetList := {}                           // Getlist
   local aCscr   := fASaveScr()                  // Current screen
   local aCdbf   := fATopen()
   local aSend   := {}                           // Field descriptions
   local aRecv   := {}
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
      if empty(aRecv)
         asize(aSend,0)
         aadd(aSend,{"SM3INEN","kode"})          // 1
         aadd(aSend,{"SM3INEN","besk"})          // 2
         aadd(aSend,{"SM3INEN","tydp"})          // 3
         aadd(aSend,{"SM3INEN","tipe"})          // 4
         aadd(aSend,{"SM3INEN","gesl"})          // 5
         aadd(aSend,{"SM3INEN","comp"})          // 6
         aRecv := fGetField(aSend)
      endif

      // Bou veranderlikes
      // Lyn om te vertoon
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"BEWAAR NUWE AKSIE-ITEM" )
         else
            nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"ENTER NEW ATTENTION ITEM" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER AKSIE-ITEM" )
         else
            nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT ATTENTION ITEM" )
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
                  aRecv[ 1,14] := space(aRecv[ 1,4])
               else
                  aRecv := fFillBlank(aRecv)
               endif

            else

               // Edit a record by filling the array with current values
               for i := 1 to len(aRecv)
                  select select(strtran(aRecv[i,1],"->",""))
                  aRecv[i,14] := fieldget(aRecv[i,13])
               next

            endif

         else

            // Clear the get array
            lClear := .t.

         endif

         // Vertoon en get velde
         @nLine+ 1,nBoxc say aRecv[ 1,6] get aRecv[ 1,14] pict aRecv[ 1,10] ;
            valid(fVkode(getlist,aRecv,nReko))
         @nLine+ 2,nBoxc say aRecv[ 2,6] get aRecv[ 2,14] pict aRecv[ 2,10]
         @nLine+ 3,nBoxc say aRecv[ 3,6] get aRecv[ 3,14] pict aRecv[ 3,10]
         @nLine+ 4,nBoxc say aRecv[ 4,6] get aRecv[ 4,14] pict aRecv[ 4,10]
         @nLine+ 5,nBoxc say aRecv[ 5,6] get aRecv[ 5,14] pict aRecv[ 5,10]
         @nLine+ 6,nBoxc say aRecv[ 6,6] get aRecv[ 6,14] pict aRecv[ 6,10]

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

            // Save the entry
            lRetu := .t.
            do while !rlock()
            enddo
            for i := 1 to len(aRecv)
               select select(strtran(aRecv[i,1],"->",""))
               fieldput(aRecv[i,13],aRecv[i,14])
            next
            SM3INEN->merk := chr(251)
            if cLanType() == "A"
               do case
                  case SM3INEN->tipe == "B"
                     SM3INEN->tbes := "Dae na geboorte"
                  case SM3INEN->tipe == "C"
                     SM3INEN->tbes := "Dae na dek"
                  case SM3INEN->tipe == "D"
                     SM3INEN->tbes := "Dae na dragtigondersoek"
                  case SM3INEN->tipe == "E"
                     SM3INEN->tbes := "Dae na laaste kalf"
               endcase
            else
               do case
                  case SM3INEN->tipe == "B"
                     SM3INEN->tbes := "Days after birth"
                  case SM3INEN->tipe == "C"
                     SM3INEN->tbes := "Days after mating"
                  case SM3INEN->tipe == "D"
                     SM3INEN->tbes := "Days after pd test"
                  case SM3INEN->tipe == "E"
                     SM3INEN->tbes := "Days after last calf"
               endcase
            endif
            commit

            // Store the current record number
            nPrev := recno()

            // Next new record
            if nReko == 0

               // Repeat the previous data
               // lRepeat := .t.

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
STATIC FUNCTION fVkode(getlist,aRecv,nReko)

   // Declare
   local nFocu := 1
   local lRetu := .t.
   local aCscr := fASaveScr()
   local cSeek := ""
   local i     := 1
   local aDisp := aclone(aRecv)
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

            // If new sale and not in herd - do not allow
            select SM3INEN
            set order to 1
            seek getlist[nFocu]:varget()

            if eof()

               //Animal unknown - allow to enter

            else

               if nReko == recno()

                  // Edit - allow

               else

                  lRetu := .f.

                  // Display the found data
                  for i := 2 to len(aRecv)
                     select select(strtran(aRecv[i,1],"->",""))
                     getlist[i]:varput(fieldget(aRecv[i,13]))
                     getlist[i]:display()
                  next

                  // Display the message
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Inskrywing bestaan reeds!")
                  else
                     fScrBood(maxrow()-1,"Entry does exist!")
                  endif
                  fScrWait(maxrow())

                  // Restore the original data
                  for i := 2 to len(aRecv)
                     getlist[i]:varput(aDisp[i,14])
                     getlist[i]:display()
                  next

               endif


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
      cBood := "Moet bogenoemde AKSIE geskrap word?"
   else
      cBood := "Should above-mentioned ACTION be deleted?"
   endif
   fScrBood(maxrow()-1, "("+trim(SM3INEN->kode)+") "+trim(SM3INEN->besk) )
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
   cKeyp += space(5)
   keyboard chr(K_RIGHT)

   // Vra die soekveranderlike
   fScrBood(maxrow()-1)
   if cLanType() == "A"
      fScrBood(maxrow(),"Tik die KODE van die aksie waarvoor gesoek word!")
      nBoxc := fBoxCent(maxrow()/2,"Vind? xxxxxx",1)
      @maxrow()/2, nBoxc say "Vind?" get cKeyp pict "@!"
   else
      fScrBood(maxrow(),"Type the CODE of the action being searched for!")
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
STATIC FUNCTION fActions(nPeriod)

   // Function to count the actions

   // Declare
   local lRetu := .f.
   local aCscr := fASavescr(maxrow()-1,0,maxrow(),maxcol())
   local aCdbf := fATopen()
   local lFind := .f.
   local dFind := ctod("")
   begin sequence

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Aksies word getel")
      else
         fScrWbood(maxrow(),"Actions being counted")
      endif

      // Delete all records from the action file
      select SM3ACTI
      zap

      // Empty all the counts in the action programme file
      select SM3INEN
      go top
      do while !eof()
         SM3INEN->aant := 0
         skip
      enddo

      // Open the main file
      aCdbf := fATopen(aCdbf,cDd(),"SM3VEEA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      set order to 7

      // Do the loop
      do while !eof()

         // Screen
         fScrBood(maxrow()-1,SM3DATA->idnr)

         // Loop through the actions file
         select SM3INEN
         go top
         do while !eof()

            // Test actions
            do case

               case !empty(SM3INEN->comp)

                  // Build a search string
                  if SM3INEN->tipe == "B"
                     dFind := SM3DATA->gebdatum+SM3INEN->tydp
                  elseif SM3INEN->tipe == "C"
                     dFind := SM3DATA->dekdat+SM3INEN->tydp
                  elseif SM3INEN->tipe == "D"
                     dFind := SM3DATA->dragda+SM3INEN->tydp
                  elseif SM3INEN->tipe == "E"
                     dFind := SM3DATA->lkalfdatum+SM3INEN->tydp
                  endif

                  // Do not accept if not liable
                  if dAppDate() >= dFind

                     // Compulsory entries
                     if empty(SM3INEN->gesl)

                        // Locate animals in veterinary file
                        select SM3VEEA
                        seek SM3DATA->idnr
                        if eof()
                           // Add to actions
                           SM3INEN->aant++
                           select SM3ACTI
                           dbappend()
                           SM3ACTI->idnr := SM3DATA->idnr
                           SM3ACTI->code := SM3INEN->kode
                           SM3ACTI->date := dFind
                        else
                           lFind := .f.
                           do while SM3VEEA->idnr == SM3DATA->idnr
                              if SM3VEEA->siekte == SM3INEN->kode .and. ;
                                    SM3VEEA->datum > dFind
                                 lFind := .t.
                              endif
                              skip
                           enddo
                           // No entry found - add to list
                           if !lFind
                              SM3INEN->aant++
                              select SM3ACTI
                              dbappend()
                              SM3ACTI->idnr := SM3DATA->idnr
                              SM3ACTI->code := SM3INEN->kode
                              SM3ACTI->date := dFind
                           endif
                        endif

                     else

                        // Only animals of a certain sex
                        if SM3DATA->geslag == SM3INEN->gesl

                           // Locate animals in veterinary file
                           select SM3VEEA
                           seek SM3DATA->idnr
                           if eof()
                              // Add to actions
                              SM3INEN->aant++
                              select SM3ACTI
                              dbappend()
                              SM3ACTI->idnr := SM3DATA->idnr
                              SM3ACTI->code := SM3INEN->kode
                              SM3ACTI->date := dFind
                           else
                              lFind := .f.
                              do while SM3VEEA->idnr == SM3DATA->idnr
                                 if SM3VEEA->siekte == SM3INEN->kode .and. ;
                                       SM3VEEA->datum > dFind
                                    lFind := .t.
                                 endif
                                 skip
                              enddo
                              // No entry found - add to list
                              if !lFind
                                 SM3INEN->aant++
                                 select SM3ACTI
                                 dbappend()
                                 SM3ACTI->idnr := SM3DATA->idnr
                                 SM3ACTI->code := SM3INEN->kode
                                 SM3ACTI->date := dFind
                              endif
                           endif

                        endif

                     endif

                  endif

               case SM3INEN->tipe == "B" .and. ;
                     SM3DATA->gebdatum + SM3INEN->tydp >= dAppDate() .and. ;
                     SM3DATA->gebdatum + SM3INEN->tydp <= dAppDate()+nPeriod

                  // Days after birth

                  if empty(SM3INEN->gesl)
                     SM3INEN->aant++
                     select SM3ACTI
                     dbappend()
                     SM3ACTI->idnr := SM3DATA->idnr
                     SM3ACTI->code := SM3INEN->kode
                     SM3ACTI->date := SM3DATA->gebdatum + SM3INEN->tydp
                  else
                     if SM3DATA->geslag == SM3INEN->gesl
                        SM3INEN->aant++
                        select SM3ACTI
                        dbappend()
                        SM3ACTI->idnr := SM3DATA->idnr
                        SM3ACTI->code := SM3INEN->kode
                        SM3ACTI->date := SM3DATA->gebdatum + SM3INEN->tydp
                     endif
                  endif

               case SM3INEN->tipe == "C" .and. ;
                     SM3DATA->dekdat + SM3INEN->tydp >= dAppDate() .and. ;
                     SM3DATA->dekdat + SM3INEN->tydp <= dAppDate()+nPeriod

                  // Days after mating

                  if empty(SM3INEN->gesl)
                     SM3INEN->aant++
                     select SM3ACTI
                     dbappend()
                     SM3ACTI->idnr := SM3DATA->idnr
                     SM3ACTI->code := SM3INEN->kode
                     SM3ACTI->date := SM3DATA->dekdat + SM3INEN->tydp
                  else
                     if SM3DATA->geslag == SM3INEN->gesl
                        SM3INEN->aant++
                        select SM3ACTI
                        dbappend()
                        SM3ACTI->idnr := SM3DATA->idnr
                        SM3ACTI->code := SM3INEN->kode
                        SM3ACTI->date := SM3DATA->dekdat + SM3INEN->tydp
                     endif
                  endif

               case SM3INEN->tipe == "D" .and. ;
                     SM3DATA->dragda + SM3INEN->tydp >= dAppDate() .and. ;
                     SM3DATA->dragda + SM3INEN->tydp <= dAppDate()+nPeriod

                  // Days after pd test

                  if empty(SM3INEN->gesl)
                     SM3INEN->aant++
                     select SM3ACTI
                     dbappend()
                     SM3ACTI->idnr := SM3DATA->idnr
                     SM3ACTI->code := SM3INEN->kode
                     SM3ACTI->date := SM3DATA->dragda + SM3INEN->tydp
                  else
                     if SM3DATA->geslag == SM3INEN->gesl
                        SM3INEN->aant++
                        select SM3ACTI
                        dbappend()
                        SM3ACTI->idnr := SM3DATA->idnr
                        SM3ACTI->code := SM3INEN->kode
                        SM3ACTI->date := SM3DATA->dragda + SM3INEN->tydp
                     endif
                  endif

               case SM3INEN->tipe == "E" .and. ;
                     SM3DATA->lkalfdatum + SM3INEN->tydp >= dAppDate() .and. ;
                     SM3DATA->lkalfdatum + SM3INEN->tydp <= dAppDate()+nPeriod

                  // Days after last calf

                  if empty(SM3INEN->gesl)
                     SM3INEN->aant++
                     select SM3ACTI
                     dbappend()
                     SM3ACTI->idnr := SM3DATA->idnr
                     SM3ACTI->code := SM3INEN->kode
                     SM3ACTI->date := SM3DATA->lkalfdatum + SM3INEN->tydp
                  else
                     if SM3DATA->geslag == SM3INEN->gesl
                        SM3INEN->aant++
                        select SM3ACTI
                        dbappend()
                        SM3ACTI->idnr := SM3DATA->idnr
                        SM3ACTI->code := SM3INEN->kode
                        SM3ACTI->date := SM3DATA->lkalfdatum + SM3INEN->tydp
                     endif
                  endif

            endcase

            // Next
            select SM3INEN
            skip

         enddo

         // Next
         select SM3DATA
         skip

      enddo
      lRetu := .t.

   end
   // Reset
   fATclose(aCdbf)
   fARestscr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fView(nTopp,nLeft,nBott,aVeld,cFind)

   // Veranderlikes
   local aCscr      := fASaveScr()               // Skerm
   local aCdbf      := fATopen()                 // Databasis
   local aOpsk      := {}                        // Opskrifte
   local i          := 1                         // Counter
   local nScrl      := 0                         // Totale lengte van die velde
   local aCols      := {}                        // Kolomme array
   local nRigh      := maxcol()-3                // Regterkantste lyn
   local bBrow      := NIL                       // Browse object
   local nKeyp      := 1                         // Keypress
   local cRetu      := ""
   local cCoun      := ""
   local nCurr      := 0

   private cData := ""                           //Column data fields for tbrowse
   private cHead := ""                           //Heading of tbrowse

   begin sequence

      // Parameters
      nTopp := if(nTopp==NIL,         5,nTopp)
      nLeft := if(nLeft==NIL,        50,nLeft)
      nBott := if(nBott==NIL,maxrow()-4,nBott)
      aVeld := if(aVeld==NIL,        {},aVeld)

      // Skerm - veldbeskrywings
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd(aVeld,{"SM3ACTI","idnr"})
         aadd(aVeld,{"SM3ACTI","date"})
      endif
      aOpsk := fGetField(aVeld)

      // Open data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Datalˆers word geopen")
      else
         fScrBood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3ACTI")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      cmfilter("SM3ACTI->code == SM3INEN->kode")
      go top

      // Kry die totale lengte van die velde om die
      // breedte van die venster te bepaal
      for i = 1 to len( aOpsk )
         // Lengte
         nScrl := nScrl + aOpsk[i,4] + 1
         // Kolomme
         cData := aOpsk[i,1] + aOpsk[i,2]
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
      next

      // Bepaal regterkantste lyn
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Clear the screen
      if empty(nTopp)
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

      // Teken die box
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, trim(SM3INEN->besk) )
      else
         fBox( nTopp, nLeft, nBott, nRigh, trim(SM3INEN->besk) )
      endif
      setcolor( cColNorm() )

      // Bou die tBrowse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Plaas kolomme oor na die browse object
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Skerm
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc ]=Aksies             ")
         fScrBood(maxrow()  , "[AltV]=Opdateer veeartseny")
      else
         fScrBood(maxrow()-1, "[Esc ]=Actions          ")
         fScrBood(maxrow()  , "[AltV]=Update veterinary")
      endif

      // Main loop
      do while nKeyp <> K_ESC

         // Stabilize
         FullStabilize(bBrow)

         // Display the record number
         cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            cRetu := fieldget(1)
            nKeyp := K_ESC

         elseif nKeyp == K_ALT_V
            // Alt V means update the veterinary file
            nCurr := recno()
            if fAddView()
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
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

return cRetu

/******************************************************************************/
STATIC FUNCTION fPrint(nPeriod)

   // Declare
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local aOpsk := {}
   local nTota := 1
   local lLoop := .t.
   local i     := 1
   local nReko := 1
   local cPrnl := ""
   local lRecn := .t.
   local cSubh := ""
   local nCoun := 1
   local cSeek := ""
   local aSeek := {}
   local nTel  := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   private cData := ""

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

      // Determine the print width
      if lRecn
         nWidt := 5
      else
         nWidt := 0
      endif
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,4] + 1
      next

      if nWidt <= nPrnWidt()
         // Normal
         cPcod := cPrnNorm()
         nWidt := nPrnWidt()
         nTopl := nPrnLine()
         nPrnl := nPrnPrnl()
         nPagl := nPrnLeng()
      else
         // Condense
         cPcod := cPrnCond()
         nWidt := nPrnCwid()
         nTopl := nPrnLine()
         if nPrnLptp() < 8
            nPrnl := nPrnPrnl()
            nPagl := nPrnLeng()
         else
            nPrnl := nPrcPrnl()
            nPagl := nPrcLeng()
         endif
      endif

      nMidc := nWidt - 29

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
         cHdln := "Aksielys vir die periode " + dtoc(dAppDate()) + " tot " + dtoc(dAppDate()+nPeriod) + "."
      else
         fScrbood(maxrow(),"ATTENTION LIST being printed!  [Esc]=Stop printer.")
         cHdln := "Attention list for the period " + dtoc(dAppDate()) + " to " + dtoc(dAppDate()+nPeriod) + "."
      endif

      //Skakel die drukker aan
      fPrnOn()

      // The loop
      lLoop := .t.
      do while lLoop


         //Opskrifte
         if prow() = 0
            fPrnCod( cPcod )

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
               @prow()  ,nWidt-len(cHdln)+1 say cHdln
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
               @prow()  ,nWidt-len(cHdln)+1 say cHdln
            endif
            @prow()+1,  1 say repl( "=", nWidt )

            // 1e Lyn van opskrif
            if lRecn
               cPrnl := "     "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,7]),aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 2e Lyn van opskrif
            if lRecn
               cPrnl := "     "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,8]),aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 3e Lyn van opskrif
            if lRecn
               cPrnl := "#### "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,9]),aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 4e Lyn van opskrif
            if lRecn
               cPrnl := "---- "
            else
               cPrnl := ""
            endif
            for i = 1 to len(aOpsk)
               cPrnl += repl("-",aOpsk[i,4]) + " "
            next
            @prow()+1,1 say left(cPrnl,nWidt)
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
            @prow()+1,1 say left(cPrnl,nWidt)
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
         if prow() >= nPrnl .or. eof()
            //Print onderste lyn
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnCod( cPrnNorm() )
            fPrnEjec()
            //fPrnOff()
            nBlad++
            //cSubh := ""

            //Indien eof()
            if eof()
               lLoop := .f.
            endif

         endif

      enddo

      fPrnOff()

   end

   // Herstel
   select SM3ACTI
   set relation to
   fATclose(aCdbf)
   fARestScr(aCscr)

return NIL

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Database File: \SM3\SM3INEN.DBF
//   Last Update: 10/17/95
//     # Records: 5
//      # Fields: 8  Bytes/Record: 58
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Field  FieldName  Type  Width  Decimals
//ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ
//   1    KODE        C    004     000
//   2    BESK        C    020     000
//   3    TIPE        C    001     000
//   4    TBES        C    020     000
//   5    TYDP        N    004     000
//   6    GESL        C    001     000
//   7    MERK        C    001     000
//   8    AANT        N    004     000
//   9    COMP        C    001     000
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Database File: \SM3\SM3ACTI.DBF
//   Last Update: 10/17/95
//     # Records: 371
//      # Fields: 3  Bytes/Record: 27
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Field  FieldName  Type  Width  Decimals
//ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ
//   1    IDNR        C    012     000
//   2    CODE        C    006     000
//   3    DATE        D    008     000
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

/******************************************************************************/
STATIC FUNCTION fAddView

   // Declare
   local getList := {}
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aSend := {}
   local aRecv := {}
   local nLine := 0
   local nBoxc := 0
   local lLoop := .t.
   local lClea := .t.
   local lRepe := .f.
   local i     := 0
   local nPrev := 1
   local cMess := ""
   local nData := 0
   local aRepe := {}
   local nMenu := 1
   local cData := ""
   local nDeel := 1
   local nFiel := 1
   begin sequence

      // Get the fields
      asize(aSend,0)
      aadd(aSend,{"SM3VEEA","datum" })
      aadd(aSend,{"SM3VEEA","behand"})
      aadd(aSend,{"SM3VEEA","dosis" })
      aadd(aSend,{"SM3VEEA","koste" })
      aRecv := fGetField(aSend)

      // Skerm - open dataleers
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VEEA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE VEEARTSENY-INLIGTING" )
      else
         nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW VETERINARY INLIGTING" )
      endif

      // The get
      lLoop := .t.
      do while lLoop

         // Fill with blanks
         aRecv := fFillBlank(aRecv)

         // Vertoon en get velde
         @nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
            pict aRecv[ 1,FLD_PICT] ;
            when(fWdatum(getlist,aRecv)) ;
            valid(fVdatum(getlist,aRecv))
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT] ;
            when(fWbehand()) ;
            valid(fVbehand(getlist,aRecv))
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT] ;
            when(fWdosis())
         @nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
            pict aRecv[ 4,FLD_PICT] ;
            when(fWkoste(getlist,aRecv))

         // The get
         set cursor on
         read
         set cursor off

         // The actions
         if lastkey() == K_ENTER

            lRetu := .t.

            // Screen
            if cLanType() == "A"
               fScrWbood(maxrow(),"Veeartsenylˆer word bygewerk")
            else
               fScrWbood(maxrow(),"Veterinary file being updated")
            endif

            // Add action to the diseases file
            select SM3SIEK
            seek SM3ACTI->code
            if eof()
               dbappend()
               SM3SIEK->kode := SM3ACTI->code
            endif

            // Loop all the animals
            select SM3ACTI
            go top
            do while !eof()

               // Add the record
               select SM3VEEA
               dbappend()
               SM3VEEA->idnr   := SM3ACTI->idnr
               SM3VEEA->siekte := SM3ACTI->code
               for i := 1 to len(aRecv)
                  if "SM3VEEA" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next
               dbunlock()
               dbcommit()

               // Next record
               select SM3ACTI
               skip

               // Screen
               if cmkeycount() > 0
                  setcolor( cColBott() )
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,str((cmkeyno()/cmkeycount())*100,4,0)+" % Voltooi")
                  else
                     fScrBood(maxrow()-1,str((cmkeyno()/cmkeycount())*100,4,0)+" % Completed")
                  endif
                  setcolor( cColNorm() )
               endif

            enddo

         endif

         lLoop := .f.

      enddo

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWdatum(aGets,aRecv)

   // Function to control entry to the date

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"datum")

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Aksielys")
      fScrBood(maxrow()  ,"Tik die DATUM waarop die diere behandel is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Action list")
      fScrBood(maxrow()  ,"Type the DATE on which the animals were treated!")
   endif

   // Todays date
   aGets[nFiel]:varput(dAppDate())
   aGets[nFiel]:updatebuffer()

return lRetu

/******************************************************************************/
STATIC FUNCTION fVdatum(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nFiel := fEnum(aRecv,"datum")

   begin sequence

      if empty(aGets[nFiel]:varget())

         // Exit to view
         keyboard chr(K_ESC)
         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWbehand

   // Function to control entry to the treatment

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Aksielys  "+D_DNARR+"=Lys van behandelings")
      fScrBood(maxrow()  ,"Tik die KODE van die behandeling!")
   else
      fScrBood(maxrow()-1,"[Esc]=Action list  "+D_DNARR+"=List of treatments")
      fScrBood(maxrow()  ,"Type the CODE of the treatment!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVbehand(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := fEnum(aRecv,"behand")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3BEHA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         cData := sm3beha(10,,,,aGets[nFiel]:varget())
         if !empty(cData)
            aGets[nFiel]:varput(cData)
            aGets[nFiel]:updatebuffer()
            if lastkey() == K_ESC
               lRetu := .f.
            endif
         else
            lRetu := .f.
            break
         endif

      elseif empty(aGets[nFiel]:varget())

         // No number given
         if cLanType() == "A"
            fScrBood(maxrow()-1,"BEHANDELINGSKODE is verpligtend!")
         else
            fScrBood(maxrow()-1,"TREATMENT CODE is compulsory!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break

      else

         // See if code is valid
         select SM3BEHA
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"BEHANDELINGSKODE is onbekend!")
            else
               fScrBood(maxrow()-1,"TREATMENT CODE is unknown!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break
         endif

      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWdosis

   // Function to control entry to the dose

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Aksielys")
      fScrBood(maxrow()  ,"Tik die AANTAL EENHEDE gebruik vir die behandeling!")
   else
      fScrBood(maxrow()-1,"[Esc]=Action list")
      fScrBood(maxrow()  ,"Type the NUMBER OF UNITS used to treat the animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWkoste(aGets,aRecv)

   // Function to control entry to the cost

   // Declare
   local lRetu := .t.
   local cBeha := aGets[fEnum(aRecv,"behand")]:varget()
   local nBeha := 0
   local nDosi := aGets[fEnum(aRecv,"dosis")]:varget()
   local nFiel := fEnum(aRecv,"koste")
   local nKost := 0
   local aCdbf := fATopen()

   // Open the data files
   aCdbf := fATopen(aCdbf,cDd(),"SM3BEHA")
   if !aCdbf[len(aCdbf),1]
      lRetu := .f.
      break
   endif

   // Get the cost per unit
   seek cBeha
   nBeha := SM3BEHA->pdos

   // Calculate the cost
   if nBeha > 0 .and. nDosi > 0
      nKost := nBeha*nDosi
      if nKost > 0 .and. nKost <= 99999.99
         aGets[nFiel]:varput(nKost)
         aGets[nFiel]:display()
      endif
   endif

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Aksielys")
      fScrBood(maxrow()  ,"Tik die KOSTE van die behandeling!")
   else
      fScrBood(maxrow()-1,"[Esc]=Action list")
      fScrBood(maxrow()  ,"Type the COST of the treatment!")
   endif

   // Restore
   fATclose(aCdbf)

return lRetu
