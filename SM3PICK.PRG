// Application: StudMaster for Beef Cattle
//   File Name: SM3PICK.PRG
// Description: Program to display a pick list
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 08-17-95      10:32:43pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3pick(cType,cTest,cInde)

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aSend := {}
   local aRecv := {}
   local i     := 0
   local nScrl := 0
   local nTopp := 3
   local nLeft := maxcol()-26
   local nBott := maxrow()-4
   local nRigh := maxcol()-3
   local bBrow := NIL
   local aCols := {}
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 0
   local cCoun := ""
   local cHead := ""

   if cLanType() == "A"
      fScrOpsk(1, "Opsie "+cOption())
   else
      fScrOpsk(1, "Option "+cOption())
   endif

   begin sequence

      // Values
      cType := iif(empty(cType),"",cType)
      cTest := iif(empty(cTest),"",cTest)
      if upper(cType) == "SEL"
         cInde := iif(empty(cInde),"SM3DATA",cInde)
      else
         cInde := iif(empty(cInde),"SM3YDAT",cInde)
      endif

      // Turn cursor off
      setcursor(0)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aSend)
         aadd(aSend,{"SM3PICK","idnr"     })
         aadd(aSend,{"SM3DATA","geslag"   })
         aadd(aSend,{"SM3DATA","uitkrede" })
      endif
      aRecv := fGetField(aSend)

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
      aCdbf := fATopen(aCdbf,cDd(),"SM3PICK",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen - fill
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere word uitgesoek")
      else
         fScrWbood(maxrow(),"Animals being selected")
      endif
      // Fill the file with animals
      if upper(cType) == "IND" .and. !empty(cTest)

         // Index group data
         if cLanType() == "A"
            cHead := "INDEKSGROEP "+trim(cTest)
         else
            cHead := "INDEX GROUP "+trim(cTest)
         endif
         select SM3PICK
         zap
         select SM3DATA
         ordsetfocus(3)
         seek cTest
         do while SM3DATA->indekskode == cTest .and. !eof()
            if empty(SM3DATA->idnr)
            else
               select SM3PICK
               dbappend()
               SM3PICK->idnr := SM3DATA->idnr
            endif
            select SM3DATA
            skip
         enddo

      elseif upper(cType) == "PHA" .and. !empty(cTest)

         // Phase group data
         if cLanType() == "A"
            cHead := "FASEGROEP "+trim(cTest)
         else
            cHead := "PHASE GROUP "+trim(cTest)
         endif
         select SM3PICK
         zap
         select SM3DATA
         ordsetfocus(2)
         seek cTest
         do while SM3DATA->fasekode == cTest .and. !eof()
            if empty(SM3DATA->idnr)
            else
               select SM3PICK
               dbappend()
               SM3PICK->idnr := SM3DATA->idnr
            endif
            select SM3DATA
            skip
         enddo

      elseif upper(cType) == "GRP" .and. !empty(cTest)

         // Group and selection group data
         if cLanType() == "A"
            cHead := "GROEP"
         else
            cHead := "GROUP"
         endif
         select SM3PICK
         zap
         select SM3DATA
         ordsetfocus(cInde)
         do while !eof()
            if empty(SM3DATA->idnr)
            else
               if &(cTest)
                  select SM3PICK
                  dbappend()
                  SM3PICK->idnr := SM3DATA->idnr
               endif
            endif
            select SM3DATA
            skip
         enddo

      elseif upper(cType) == "SEL" .and. !empty(cTest)

         // Group and selection group data
         if cLanType() == "A"
            cHead := "SELEKSIEGROEP"
         else
            cHead := "SELECTION GROUP"
         endif
         select SM3PICK
         zap
         select SM3DATA
         ordsetfocus(cInde)
         do while !eof()
            if empty(SM3DATA->idnr)
            else
               if &(cTest)
                  select SM3PICK
                  dbappend()
                  SM3PICK->idnr := SM3DATA->idnr
               endif
            endif
            select SM3DATA
            skip
         enddo

      elseif upper(cType) == "ALL"

         // All animals
         if cLanType() == "A"
            cHead := "ALLE DIERE"
         else
            cHead := "ALL ANIMALS"
         endif
         select SM3PICK
         zap
         select SM3DATA
         ordsetfocus(cInde)
         do while !eof()
            if empty(SM3DATA->idnr)
            else
               select SM3PICK
               dbappend()
               SM3PICK->idnr := SM3DATA->idnr
            endif
            select SM3DATA
            skip
         enddo

      endif

      // Set relations
      select SM3DATA
      ordsetfocus(1)
      select SM3PICK
      dbsetrelation("SM3DATA",{|| SM3PICK->idnr },"SM3PICK->idnr")
      go top

      // Calculate window width
      for i = 1 to len(aRecv)
         // Length
         nScrl := nScrl+aRecv[i,FLD_LENG]+3
         // Columns
         aadd(aCols,TBColumnNew(,fieldwblock(aRecv[i,FLD_NAME],select(strtran(aRecv[i,DBF_NAME],"->","")))))
      next

      // Calculate right hand column
      nLeft := if(nRigh-nScrl<3,3,nRigh-nScrl)

      // Screen
      if cLanType() == "A"
         cHead := iif(empty(cHead),"LYS VAN DIERE",cHead)
      else
         cHead := iif(empty(cHead),"LIST OF ANIMALS",cHead)
      endif

      // Draw the box
      fBox(nTopp,nLeft,nBott,nRigh,cHead)
      setcolor( cColNorm() )

      // Build the browse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:colsep := " ³ "

      // Build the browse columns
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Vorige skerm           [Ins]=Voeg dier by lys     ")
         fScrBood(maxrow()  ,+D_ENTER+"=Aanvaar lys van diere  [Del]=Verwyder dier uit lys")
      else
         fScrBood(maxrow()-1,"[Esc]=Previous screen         [Ins]=Add an animal to the list     ")
         fScrBood(maxrow()  ,+D_ENTER+"=Accept list of animals  [Del]=Delete an animal from the list")
      endif

      // Freeze
      // bBrow:freeze := 1

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
         cCoun := padl("["+ltrim(str(cmxkeyno()))+"/"+ltrim(str(cmxkeycount()))+"]",12,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            lRetu := .t.
            nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "sm3pick",1,"oorsig"

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddPick()
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fAddPick(nReko)

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

      // Values
      nReko := iif(empty(nReko),0,nReko)

      // Get the fields
      asize(aSend,0)
      aadd(aSend,{"SM3PICK","idnr"     })
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"NUWE DIER" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"NEW ANIMAL" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER DIER" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT ANIMAL" )
         endif
      endif

      // The get
      lLoop := .t.
      do while lLoop

         if lClea

            // Get the current values
            if nReko == 0

               // Insert a new record
               if lRepe
                  lRepe := .f.
                  aRepe := {}
                  //aadd(aRepe,"adreskode")
                  aRecv := fFillBlank(aRecv,aRepe)
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
            lClea := .t.

         endif

         // Vertoon en get velde
         @nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
            pict aRecv[ 1,FLD_PICT] ;
            when(fWidnr(nReko)) ;
            valid(fVidnr(getlist,aRecv,nReko))

         // The get
         set cursor on
         read
         set cursor off

         // Reset the database
         fATclose(aCdbf)

         // The actions
         if lastkey() == K_ENTER

            lRetu := .t.

            // Add or edit record in the sales file
            if nReko == 0
               // Add
               dbappend()
            else
               // Edit
               do while !rlock()
               enddo
            endif
            for i := 1 to len(aRecv)
               if "SM3PICK" $ aRecv[i,DBF_NAME]
                  fieldput(aRecv[i,13],aRecv[i,14])
               endif
            next

            dbunlock()
            dbcommit()

            // Select the active file
            select SM3PICK

            // Store the current record number
            nPrev := recno()

            // Next new record
            if nReko == 0

               // Repeat the previous data
               lRepe := .t.

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
                  lClea := .f.
                  loop
               endif

            endif

         endif

         lLoop := .f.

      enddo

   end

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWidnr(nReko)

   // Function to control entry to the id number field

   // Declare
   local lRetu := .t.

   // If an edit
   if nReko > 0
      lRetu := .f.
   else
      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van diere")
         fScrBood(maxrow()  ,"Tik die ID NOMMER van die dier!")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of animals")
         fScrBood(maxrow()  ,"Type the ID NUMBER of the animal!")
      endif

   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVidnr(aGets,aRecv,nReko)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local i     := 1
   local aDisp := aclone(aRecv)
   local nFiel := fEnum(aRecv,"idnr")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         if cLanType() == "A"
            cData := sm3idnu(3,,,"LYS VAN DIERE","SM3DATA",aGets[nFiel]:varget())
         else
            cData := sm3idnu(3,,,"LIST OF ANIMALS","SM3DATA",aGets[nFiel]:varget())
         endif
         if !empty(cData)
            aGets[nFiel]:varput(cData)
            aGets[nFiel]:updatebuffer()
         else
            lRetu := .f.
            break
         endif

      elseif empty(aGets[nFiel]:varget())

         // No number given - exit to browse
         keyboard chr(K_ESC)
         lRetu := .f.
         break

      endif

      // Locate data
      select SM3PICK
      seek aGets[nFiel]:varget()
      if eof()

         // Animal not in file - allow

         // Test for animal in main file
         select SM3DATA
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Dier bestaan nie in die hooflˆer nie!")
            else
               fScrBood(maxrow()-1,"Animal does not exist in the main file!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break

         endif

      else

         // Animal is in file - do not allow

         // Move the pointer in the main file
         select SM3DATA
         seek aGets[nFiel]:varget()

         // Display the found data
         for i := 1 to len(aRecv)
            select select(strtran(aRecv[i,DBF_NAME],"->",""))
            aGets[i]:varput(fieldget(aRecv[i,FLD_NUMB]))
            if aGets[i]:hasfocus()
               aGets[i]:updatebuffer()
            else
               aGets[i]:display()
            endif
         next

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dier bestaan reeds in die KIESLYS lˆer!")
         else
            fScrBood(maxrow()-1,"Animal does exist in the PICK LIST file!")
         endif
         fScrWait(maxrow())

         // Restore the original data
         for i := 1 to len(aRecv)
            aGets[i]:varput(aDisp[i,FLD_CARG])
            if aGets[i]:hasfocus()
               aGets[i]:updatebuffer()
            else
               aGets[i]:display()
            endif
         next

         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

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
      cBood := "Moet bogenoemde dier uit die lys geskrap word?"
   else
      cBood := "Should above-mentioned animal be removed from the list?"
   endif
   fScrBood(maxrow()-1,trim(fieldget(1)))
   if fJaNee(maxrow(),cBood,,.f. )
      if rlock()
         delete
         dbUnlock()
         skip
         if eof()
            go bottom
         endif
         lRetu := .t.
      endif
   endif

   // Reset
   fARestScr(aCscr)

return lRetu
