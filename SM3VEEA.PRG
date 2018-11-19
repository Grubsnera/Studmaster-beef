// Application: StudMaster for Beef Cattle
//   File Name: SM3VEEA.PRG
// Description: Program to manage veterinary files
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-13-95 11:59am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3veea(nTopp,nLeft,nBott,aVeld,cFind)

   // Declare
   local cRetu := ""
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lClea := .f.
   local aOpsk := {}
   local i     := 0
   local nScrl := 0
   local cHead := ""
   local aCols := {}
   local nRigh := 0
   local bBrow := NIL
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 1
   local cCoun := ""
   local lAver := .f.
   local oCols := NIL
   local nAver := 0
   local nTell := 1
   local lFilt := .f.

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

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
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aVeld)
         aadd(aVeld,{"SM3VEEA","idnr"     })
         aadd(aVeld,{"SM3DATA","geslag"   })
         aadd(aVeld,{"SM3DATA","gebdatum" })
      endif

      // Build the get array
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VEEV")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VEEA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      ordsetfocus("SM3VEEU")
      dbsetrelation("SM3DATA",{|| SM3VEEA->idnr },"SM3VEEA->idnr")

      // Move the record pointer
      if !empty(cFind)
         set soft on
         seek cFind
         set soft off
         if eof()
            go top
         endif
      else
         go top
      endif

      // Calculate window width
      for i = 1 to len( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,4] + 1
         // Columns
         cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
         if "FUNCTION" $ aOpsk[i,1]
            aadd(aCols,TBColumnNew(cHead,&("{||"+aOpsk[i,2]+"}")))
         else
            aadd(aCols,TBColumnNew(cHead,fieldwblock(aOpsk[i,2],select(strtran(aOpsk[i,1],"->","")))))
         endif
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Clear the screen
      if lClea
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

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "VEEARTSENY" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "VETERINARY" )
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
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins]=Nuwe veeartseny   [A-Z ]=Vind")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [Del]=Skrap veeartseny  [AltP]=Druk")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins]=New veterinary     [A-Z ]=Find ")
         fScrBood(maxrow()  , "[F1 ]=Help  [Del]=Delete veterinary  [AltP]=Print")
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
         cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means return Id number and exit
            //cRetu := fieldget(1)
            //nKeyp := K_ESC
            sm3veel(4,10,,,SM3VEEA->idnr)

         elseif nKeyp == K_F1
            // Help
            do help with "SM3VEEA",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddVeea()
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fAddVeea(recno())
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint()
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

return cRetu

/******************************************************************************/
STATIC FUNCTION fDelete

   // Function to delete records

   // Declare
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local lRetu := .f.
   local cBood := ""
   local cIdnr := SM3VEEA->idnr

   // Screen
   if cLanType() == "A"
      cBood := "Moet bogenoemde dier se VEEARTSENY-INLIGTING geskrap word?"
   else
      cBood := "Should above-mentioned animal's VETERINARY INFORMATION be deleted?"
   endif
   fScrBood(maxrow()-1,trim(fieldget(1)))
   if fJaNee(maxrow(),cBood,,.f. )

      // Normal order
      ordsetfocus("SM3VEEA")
      seek cIdnr

      // The loop to delete all veterinary entries
      do while !eof()

         // The delete
         if rlock()
            delete
            dbUnlock()
            lRetu := .t.
         endif

         // Next seek
         seek cIdnr

      enddo

      // Back to unique order
      set soft on
      seek cIdnr
      set soft off
      if eof()
         go top
      endif

   endif

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fLocate(cKeyp)

   // Function to locate any record

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nBoxc := 0

   // Field length
   cKeyp += space(11)
   keyboard chr(K_RIGHT)

   // Ask the data to locate
   fScrBood(maxrow()-1)
   if cLanType() == "A"
      fScrBood(maxrow(),"Tik die ID NOMMER van die dier waarna gesoek word!")
      nBoxc := fBoxCent(maxrow()/2,"Vind? "+space(len(cKeyp)),1)
      @maxrow()/2, nBoxc say "Vind?" get cKeyp pict "@!"
   else
      fScrBood(maxrow(),"Type the ID NUMBER of the animal being searched for!")
      nBoxc := fBoxCent(maxrow()/2,"Find?"+space(len(cKeyp)),1)
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
STATIC FUNCTION fAddVeea(nReko)

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
   local cIdnr := SM3VEEA->idnr
   begin sequence

      // Values
      nReko := iif(empty(nReko),0,nReko)

      // Ask which animals
      if nReko == 0
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Veeartseny" )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Veterinary" )
         endif
         nMenu := fNewMenu(nMenu,"ADDVEEA")
         fARestScr(aCscr)
         do case

            case nMenu == 1
               // Single animals

            case nMenu == 2
               // Index group
               cData := sm3indg(4)
               if empty(cData)
                  break
               endif
               if !sm3pick("IND",cData)
                  break
               endif

            case nMenu == 3
               // Phase group
               cData := sm3fasg(4)
               if empty(cData)
                  break
               endif
               if !sm3pick("PHA",cData)
                  break
               endif

            case nMenu == 4
               // Group
               cData := sm3groe()
               if empty(cData)
                  break
               endif
               if !sm3pick("GRP",cData)
                  break
               endif

            case nMenu == 5
               // Selection group
               cData := sm3selg()
               if empty(cData)
                  break
               endif
               if !sm3pick("SEL",cData)
                  break
               endif

            case nMenu == 6
               // Previous group
               if !sm3pick()
                  break
               endif

            otherwise
               // Exit
               break
         endcase
      endif

      // Get the fields
      asize(aSend,0)
      aadd(aSend,{"SM3VEEA","idnr"  })
      aadd(aSend,{"SM3VEEA","datum" })
      aadd(aSend,{"SM3VEEA","siekte"})
      aadd(aSend,{"SM3VEEA","behand"})
      aadd(aSend,{"SM3VEEA","dosis" })
      aadd(aSend,{"SM3VEEA","koste" })
      //aadd(aSend,{"SM3VEEA","arts" })
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE VEEARTSENY-INLIGTING" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW VETERINARY INLIGTING" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER VEEARTSENY-INLIGTING" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT VETERINARY INFORMATION" )
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
                  aadd(aRepe,"datum")
                  aadd(aRepe,"siekte")
                  aadd(aRepe,"behand")
                  aadd(aRepe,"dosis")
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
            when(fWidnr(nReko,nMenu)) ;
            valid(fVidnr(getlist,aRecv,nReko))
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT] ;
            when(fWdatum()) ;
            valid(fVdatum(getlist,aRecv))
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT] ;
            when(fWsiekte()) ;
            valid(fVsiekte(getlist,aRecv))
         @nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
            pict aRecv[ 4,FLD_PICT] ;
            when(fWbehand()) ;
            valid(fVbehand(getlist,aRecv))
         @nLine+ 5,nBoxc say aRecv[ 5,FLD_DESC] get aRecv[ 5,FLD_CARG] ;
            pict aRecv[ 5,FLD_PICT] ;
            when(fWdosis())
         @nLine+ 6,nBoxc say aRecv[ 6,FLD_DESC] get aRecv[ 6,FLD_CARG] ;
            pict aRecv[ 6,FLD_PICT] ;
            when(fWkoste(getlist,aRecv))
         //@nLine+ 7,nBoxc say aRecv[ 7,FLD_DESC] get aRecv[ 7,FLD_CARG] ;
         //   pict aRecv[ 7,FLD_PICT] ;
         //   when(fWarts())

         // The get
         set cursor on
         read
         set cursor off

         // Reset the database
         fATclose(aCdbf)

         // The actions
         if lastkey() == K_ENTER

            lRetu := .t.

            if nMenu == 1

               // Single animal

               // Add or edit record
               if nReko == 0
                  // Add
                  dbappend()
               else
                  // Edit
                  do while !rlock()
                  enddo
               endif
               for i := 1 to len(aRecv)
                  if "SM3VEEA" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next
               dbunlock()
               dbcommit()
               cIdnr := SM3VEEA->idnr

               // Update the vet file
               if nReko == 0 .and. SM3VEEA->arts $ "JY"
                  select SM3VEEV
                  dbappend()
                  SM3VEEV->idnr   := SM3VEEA->idnr
                  SM3VEEV->datum  := SM3VEEA->datum
                  SM3VEEV->siekte := SM3VEEA->siekte
                  SM3VEEV->behand := SM3VEEA->behand
                  dbunlock()
                  dbcommit()
               endif

            else

               // Selection of animals

               // Open the pick list
               aCdbf := fATopen(aCdbf,cDd(),"SM3PICK")
               if !aCdbf[len(aCdbf),1]
                  lRetu := .f.
                  break
               endif

               // Screen
               if cLanType() == "A"
                  fScrWbood(maxrow(),"Diere se veeartseny-inligting word bewaar")
               else
                  fScrWbood(maxrow(),"Saving veterinary information information")
               endif

               // Loop the animals in the pick list
               do while !eof()

                  // Screen
                  fScrBood(maxrow()-1,SM3PICK->idnr)

                  // Update the file
                  select SM3VEEA
                  dbappend()
                  SM3VEEA->idnr := SM3PICK->idnr
                  for i := 2 to len(aRecv)
                     if "SM3VEEA" $ aRecv[i,DBF_NAME]
                        fieldput(aRecv[i,13],aRecv[i,14])
                     endif
                  next
                  dbunlock()
                  dbcommit()
                  cIdnr := SM3VEEA->idnr

                  // Update the vet file
                  if nReko == 0 .and. SM3VEEA->arts $ "JY"
                     select SM3VEEV
                     dbappend()
                     SM3VEEV->idnr   := SM3VEEA->idnr
                     SM3VEEV->datum  := SM3VEEA->datum
                     SM3VEEV->siekte := SM3VEEA->siekte
                     SM3VEEV->behand := SM3VEEA->behand
                     dbunlock()
                     dbcommit()
                  endif

                  // Next
                  select SM3PICK
                  skip

               enddo

               // Close the file
               select SM3PICK
               dbclosearea()
               aCdbf := asize(aCdbf,len(aCdbf)-1)

            endif

            // Select the active file
            select SM3VEEA
            seek cIdnr
            if eof()
               go top
            endif

            // Store the current record number
            nPrev := recno()

            // Next new record
            if nReko == 0 .and. nMenu == 1

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
STATIC FUNCTION fWidnr(nReko,nMenu)

   // Function to control entry to the id number field

   // Declare
   local lRetu := .t.

   // If an edit
   if nReko > 0 .or. nMenu > 1
      lRetu := .f.
   else
      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Veeartseny  "+D_DNARR+"=Lys van lewende diere")
         fScrBood(maxrow()  ,"Tik die ID NOMMER van die dier!")
      else
         fScrBood(maxrow()-1,"[Esc]=Veterinary  "+D_DNARR+"=List of living animals")
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
            cData := sm3idnu(3,,,"LEWENDE DIERE","SM3YDAT",aGets[nFiel]:varget())
         else
            cData := sm3idnu(3,,,"LIVING ANIMALS","SM3YDAT",aGets[nFiel]:varget())
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

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWdatum

   // Function to control entry to the date

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Veeartseny")
      fScrBood(maxrow()  ,"Tik die DATUM waarop die dier behandel is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Veterinary")
      fScrBood(maxrow()  ,"Type the DATE on which the animal was treated!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVdatum(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nFiel := fEnum(aRecv,"datum")

   begin sequence

      if empty(aGets[nFiel]:varget())

         // No number given - allow
         if cLanType() == "A"
            fScrBood(maxrow()-1,"DATUM waarop dier behandel is, is verpligtend!")
         else
            fScrBood(maxrow()-1,"DATE on which animal was treated is compulsory!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWsiekte

   // Function to control entry to the disease

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Veeartseny  "+D_DNARR+"=Lys van siektes")
      fScrBood(maxrow()  ,"Tik die KODE van die siekte waarvoor die dier behandel is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Veterinary  "+D_DNARR+"=List of diseases")
      fScrBood(maxrow()  ,"Type the CODE of the disease for which the animal was treated!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVsiekte(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := fEnum(aRecv,"siekte")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         cData := sm3siek(10,,,,aGets[nFiel]:varget())
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
            fScrBood(maxrow()-1,"SIEKTEKODE is verpligtend!")
         else
            fScrBood(maxrow()-1,"DISEASE CODE is compulsory!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break

      else

         // See if code is valid
         select SM3SIEK
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"KODE van die siekte is onbekend!")
            else
               fScrBood(maxrow()-1,"CODE of the disease is unknown!")
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
STATIC FUNCTION fWbehand

   // Function to control entry to the treatment

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Veeartseny  "+D_DNARR+"=Lys van behandelings")
      fScrBood(maxrow()  ,"Tik die KODE van die behandeling!")
   else
      fScrBood(maxrow()-1,"[Esc]=Veterinary  "+D_DNARR+"=List of treatments")
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
      fScrBood(maxrow()-1,"[Esc]=Veeartseny")
      fScrBood(maxrow()  ,"Tik die AANTAL EENHEDE gebruik vir die behandeling!")
   else
      fScrBood(maxrow()-1,"[Esc]=Veterinary")
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
      fScrBood(maxrow()-1,"[Esc]=Veeartseny")
      fScrBood(maxrow()  ,"Tik die KOSTE van die behandeling!")
   else
      fScrBood(maxrow()-1,"[Esc]=Veterinary")
      fScrBood(maxrow()  ,"Type the COST of the treatment!")
   endif

   // Restore
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWarts

   // Function to control entry to the vet

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Veeartseny")
      fScrBood(maxrow()  ,"Tik [J]a indien die veearts die dier moet sien met sy volgende besoek!")
   else
      fScrBood(maxrow()-1,"[Esc]=Veterinary")
      fScrBood(maxrow()  ,"Type [Y]es if the vet must see this animal on his next visit!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aOpsk)

   // Function to print veterinary for more than one animal

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nMenu := 5
   local cData := ""
   local aVeld := {}
   local i     := 0
   local cPrnl := ""
   local cIdnr := ""
   local nCspa := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   begin sequence

      // Test availability of printer
      if fPrnReady(maxrow()-1) == K_ESC
         break
      endif

      // Ask which animals to print
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Veeartseny" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Veterinary" )
      endif
      nMenu := fNewMenu(nMenu,"PRIVEEA")
      fARestScr(aCscr)
      do case

         case nMenu == 1
            // Index group
            cData := sm3indg(4)
            if empty(cData)
               break
            endif
            if !sm3pick("IND",cData)
               break
            endif

         case nMenu == 2
            // Phase group
            cData := sm3fasg(4)
            if empty(cData)
               break
            endif
            if !sm3pick("PHA",cData)
               break
            endif

         case nMenu == 3
            // Group
            cData := sm3groe()
            if empty(cData)
               break
            endif
            if !sm3pick("GRP",cData)
               break
            endif

         case nMenu == 4
            // Selection group
            cData := sm3selg()
            if empty(cData)
               break
            endif
            if !sm3pick("SEL",cData)
               break
            endif

         case nMenu == 5
            // Previous group
            if !sm3pick()
               break
            endif

         otherwise
            // Exit
            break
      endcase

      // Screen - fields to print
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Drukuitleg word bepaal")
      else
         fScrBood(maxrow(),"Print outlay being determined")
      endif
      if empty(aOpsk)
         aadd(aVeld,{"SM3VEEA","idnr"     })
         aadd(aVeld,{"SM3VEEA","datum"    })
         aadd(aVeld,{"SM3SIEK","besk"     })
         aadd(aVeld,{"SM3BEHA","besk"     })
         aadd(aVeld,{"SM3VEEA","dosis"    })
         aadd(aVeld,{"SM3VEEA","koste"    })
         aOpsk := fGetField(aVeld)
      endif

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3PICK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3BEHA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VEEA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen - Mark animals for printing
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere word gemerk")
      else
         fScrWbood(maxrow(),"Animals being marked")
      endif

      // Remove all marks
      select SM3VEEA
      do while !eof()
         if rlock()
            SM3VEEA->tipe := " "
         endif
         // Next record
         select SM3VEEA
         skip
      enddo

      // Add marks
      select SM3PICK
      do while !eof()

         // Mark animals
         select SM3VEEA
         seek SM3PICK->idnr
         do while SM3VEEA->idnr == SM3PICK->idnr

            // Mark the record
            if rlock()
               SM3VEEA->tipe := "P"
            endif

            // Next record
            select SM3VEEA
            skip

         enddo

         // Next record
         select SM3PICK
         skip

      enddo

      // Set relations
      select SM3VEEA
      dbsetrelation("SM3BEHA",{|| SM3VEEA->behand },"SM3VEEA->behand")
      dbsetrelation("SM3SIEK",{|| SM3VEEA->siekte },"SM3VEEA->siekte")
      go top

      // Determine the print width
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,FLD_LENG] + nCspa
      next

      if nWidt <= nPrnWidt()
         // Normal
         cPcod := cPrnNorm()
         nWidt := nPrnWidt()
         nTopl := nPrnLine()
         nPrnl := nPrnPrnl() - 3
         nPagl := nPrnLeng()
      else
         // Condense
         cPcod := cPrnCond()
         nWidt := nPrnCwid()
         nTopl := nPrnLine()
         if nPrnLptp() < 8
            nPrnl := nPrnPrnl() - 3
            nPagl := nPrnLeng()
         else
            nPrnl := nPrcPrnl() - 3
            nPagl := nPrcLeng()
         endif
      endif

      nMidc := nWidt - 29

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"VEEARTSENY word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Veeartseny-inligting vir groepe diere."
      else
         fScrbood(maxrow(),"VETERINARY being printed!  [Esc]=Stop printer.")
         cHdln := "Veterinary information for groups of animals."
      endif

      // Switch printer on
      fPrnOn()

      // The loop
      do while SM3VEEA->(!eof())


         // Headings
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

            // 1st heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,7]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 2nd heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,8]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 3rd heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,9]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 4th heading line
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cPrnl += repl("-",aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

         endif

         // Stop printer
         if fPrnStop() = K_ESC
            lRetu := .f.
            break
         endif

         // Data
         if !empty(SM3VEEA->tipe)
            cPrnl := ""
            for i = 1 to len(aOpsk)
               cData := aOpsk[i,1] + aOpsk[i,2]
               if aOpsk[i,3] == "D"
                  cPrnl += dtoc(&(cData)) + space(nCspa)
               elseif aOpsk[i,3] == "N"
                  cPrnl += str(&(cData),aOpsk[i,4],aOpsk[i,5]) + space(nCspa)
                  // Add totals
                  select select(strtran(aOpsk[i,1],"->",""))
                  if fieldget(aOpsk[i,FLD_NUMB]) > 0
                     aOpsk[i,FLD_COUN]++
                     aOpsk[i,FLD_TOTA] += fieldget(aOpsk[i,FLD_NUMB])
                  endif
               else
                  if upper(cData) == "SM3VEEA->IDNR" .and. SM3VEEA->idnr == cIdnr
                     cPrnl := space(aOpsk[i,FLD_LENG]) + space(nCspa)
                  else
                     cPrnl += &(cData) + space(nCspa)
                  endif
               endif
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // Print totals
            cIdnr := SM3VEEA->idnr
            select SM3VEEA
            skip
            if SM3VEEA->idnr <> cIdnr

               // Print totals

               // Totals line
               cPrnl := ""
               for i = 1 to len(aOpsk)
                  if aOpsk[i,FLD_TYPE] == "N"
                     cPrnl += repl("-",aOpsk[i,FLD_LENG]) + space(nCspa)
                  else
                     cPrnl += space(aOpsk[i,FLD_LENG]) + space(nCspa)
                  endif
               next
               @prow()+1,1 say left(cPrnl,nWidt)

               // Totals
               cPrnl := ""
               for i = 1 to len(aOpsk)
                  if aOpsk[i,FLD_TYPE] == "N"
                     // Calc the average for all numeric cols
                     cPrnl += transform(aOpsk[i,FLD_TOTA],aOpsk[i,FLD_PICT]) + space(nCspa)
                  else
                     // Fill footings with spaces for all other cols
                     cPrnl += space(aOpsk[i,FLD_LENG]) + space(nCspa)
                  endif
               next
               @prow()+1,1 say left(cPrnl,nWidt)

               // Totals line
               cPrnl := ""
               for i = 1 to len(aOpsk)
                  if aOpsk[i,FLD_TYPE] == "N"
                     cPrnl += repl("-",aOpsk[i,FLD_LENG]) + space(nCspa)
                  else
                     cPrnl += space(aOpsk[i,FLD_LENG]) + space(nCspa)
                  endif
               next
               @prow()+1,1 say left(cPrnl,nWidt)

               // Zero totals
               for i = 1 to len(aOpsk)
                  aOpsk[i,FLD_COUN] := 0
                  aOpsk[i,FLD_TOTA] := 0
               next

            endif
            skip -1

         endif

         // Screen
         select SM3VEEA
         // fPrnOff()
         // if cmkeycount() > 0
         //    setcolor( cColBott() )
         //    if cLanType() == "A"
         //       fScrBood(maxrow()-1,str((cmkeyno()/cmkeycount())*100,4,0)+" % Voltooi")
         //    else
         //       fScrBood(maxrow()-1,str((cmkeyno()/cmkeycount())*100,4,0)+" % Completed")
         //    endif
         //    setcolor( cColNorm() )
         // endif
         // fPrnOn()

         // Next record
         select SM3VEEA
         skip

         // End of page or end of file
         if prow() >= nPrnl .or. SM3VEEA->(eof())
            // Bottom line
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++
         endif
      enddo

      fPrnOff()

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
