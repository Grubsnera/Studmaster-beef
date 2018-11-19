// Application: StudMaster for Beef Cattle
//   File Name: SM3SALE.PRG
// Description: Program to manage sales
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 08-12-95      11:56:07am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3sale(nTopp,nLeft,nBott,aVeld,cFind)

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
         fScrOpsk(1,"Opsie "+cOption())
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrOpsk(1,"Option "+cOption())
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif

      // Check the own reports
      aCdbf := fATopen(aCdbf,cDd(),"SM3EIEV")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      if cLanType() == "A"
         seek "VERKOP"
      else
         seek "SALES "
      endif
      if found()
         aadd(aVeld,{"SM3VERK","idnr"     })
         for i = 1 to 40
            if !empty(substr(SM3EIEV->veld,nTell,10)) .and. !empty(substr(SM3EIEV->veld,nTell+10,10))
               aadd(aVeld,{trim(substr(SM3EIEV->veld,nTell,10)),trim(substr(SM3EIEV->veld,nTell+10,10))})
            endif
            nTell := nTell + 20
         next
      else
         if empty(aVeld)
            aadd(aVeld,{"SM3VERK","idnr"     })
            aadd(aVeld,{"SM3DATA","geslag"   })
            aadd(aVeld,{"SM3VERK","massa"    })
            aadd(aVeld,{"SM3VERK","bedrag"   })
            aadd(aVeld,{"SM3VERK","ipklew"   })
            aadd(aVeld,{"SM3VERK","uitsla"   })
            aadd(aVeld,{"SM3VERK","ipkkou"   })
            aadd(aVeld,{"SM3DATA","uitkrede" })
            aadd(aVeld,{"SM3DATA","uitkdatum"})
            aadd(aVeld,{"SM3VERK","adreskode"})
            aadd(aVeld,{"SM3KLIE","naam"     })
            aadd(aVeld,{"SM3VERK","graad"    })
         endif
      endif

      // Close the own reports file
      fATclose(aCdbf)
      asize(aCdbf,len(aCdbf)-1)

      // Build the get array
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3OORD")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VORE")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      dbsetrelation("SM3DATA",{|| SM3VERK->idnr }     ,"SM3VERK->idnr"     )
      dbsetrelation("SM3KLIE",{|| SM3VERK->adreskode },"SM3VERK->adreskode")

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
         IF cLanType() == "A"
            fScrOpsk( ,"Opsie "+cOption())
         ELSE
            fScrOpsk( ,"Option "+cOption())
         ENDIF
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "VERKOPE" )
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
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=Nuwe verkope  [Del]=Skrap  [AltT]=Totale  [AltB]=Bereken")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [AltE]=Verander      [A-Z]=Vind   [AltP]=Druk    [AltF]=Filter ")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=New sales  [Del]=Delete  [AltT]=Totals  [AltB]=Calculate")
         fScrBood(maxrow()  , "[F1 ]=Help  [AltE]=Edit       [A-Z]=Find    [AltP]=Print   [AltF]=Filter   ")
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
            cRetu := fieldget(1)
            nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "SM3SALE",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               if lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               endif
               bBrow:refreshall()
            endif

         elseif upper(chr(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            if fLocate(upper(chr(nKeyp)))
               lFilt := .f.
               lMove := .t.
               nCurr := recno()
               if lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               endif
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddSale()
               lFilt := .f.
               lMove := .t.
               nCurr := recno()
               if lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               endif
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            lFilt := .f.
            if fAddSale(recno())
               lFilt := .f.
               lMove := .t.
               nCurr := recno()
               if lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               endif
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_T
            // Alt T means toggle totals and averages
            if lAver
               lAver := .f.
               // Remove all the column footings
               for i := 1 to len(aOpsk)
                  oCols := bBrow:getcolumn(i)
                  oCols:footsep := ""
                  oCols:footing := ""
               next
            else
               lAver := .t.
               // Do the actual calculation
               fAverage(aOpsk,bBrow)
            endif
            bBrow:configure()

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint(aOpsk,lAver)
               bBrow:refreshall()
            endif

         elseif nKeyp == K_ALT_F
            // Alt F means set a filter
            if lFilt
               lFilt := .f.
               cmclrfilter()
               if lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               endif
               bBrow:refreshall()
            else
               if fFilter()
                  lFilt := .t.
                  if lAver
                     fAverage(aOpsk,bBrow)
                     bBrow:configure()
                  endif
                  bBrow:refreshall()
               endif
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

   // Screen
   if cLanType() == "A"
      cBood := "Moet bogenoemde dier se VERKOOPSINLIGTING geskrap word?"
   else
      cBood := "Should above-mentioned animal's SALES INFORMATION be deleted?"
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
      cmclrfilter()
      ordsetfocus(1)
      set soft on
      seek cKeyp
      set soft off
      if eof()
         go top
      endif
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fAddSale(nReko)

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

      // Ask which animals
      if nReko == 0
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Verkope" )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Sales" )
         endif
         nMenu := fNewMenu(nMenu,"ADDSALE")
         fARestScr(aCscr)
         if cLanType() == "A"
            fScrOpsk(1,"Opsie "+cOption(nMenu))
         else
            fScrOpsk(1,"Option "+cOption(nMenu))
         endif

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
      aadd(aSend,{"SM3VERK","idnr"     })
      aadd(aSend,{"SM3VERK","adreskode"})
      aadd(aSend,{"SM3DATA","uitkrede" })
      aadd(aSend,{"SM3DATA","uitkdatum"})
      aadd(aSend,{"SM3VERK","massa"    })
      aadd(aSend,{"SM3VERK","ipklew"   })
      aadd(aSend,{"SM3VERK","bedrag"   })
      aadd(aSend,{"SM3VERK","uitsla"   })
      aadd(aSend,{"SM3VERK","kouema"   })
      aadd(aSend,{"SM3VERK","oordra"   })
      aadd(aSend,{"SM3VERK","skrapp"   })
      aadd(aSend,{"SM3VERK","graad"    })
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE VERKOPE" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER NEW SALES" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER VERKOOPSINLIGTING" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT SALES INFORMATION" )
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
                  aadd(aRepe,"adreskode")
                  aadd(aRepe,"uitkrede" )
                  aadd(aRepe,"uitkdatum")
                  aadd(aRepe,"uitsla"   )
                  aadd(aRepe,"oordra"   )
                  aadd(aRepe,"skrapp"   )
                  aadd(aRepe,"graad"    )
                  aadd(aRepe,"ipklew"   )
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
            pict aRecv[ 2,FLD_PICT]+"@K" ;
            when(fWadreskode()) ;
            valid(fVadreskode(getlist,aRecv))
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT]+"@K" ;
            when(fWuitkrede()) ;
            valid(fVuitkrede(getlist,aRecv))
         @nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
            pict aRecv[ 4,FLD_PICT]+"@K" ;
            when(fWuitkdatum()) ;
            valid(fVuitkdatum(getlist,aRecv))
         @nLine+ 5,nBoxc say aRecv[ 5,FLD_DESC] get aRecv[ 5,FLD_CARG] ;
            pict aRecv[ 5,FLD_PICT] ;
            when(fWmassa(getlist,aRecv))
         @nLine+ 6,nBoxc say aRecv[ 6,FLD_DESC] get aRecv[ 6,FLD_CARG] ;
            pict aRecv[ 6,FLD_PICT] ;
            when(fWipklew()) ;
            valid(fVipklew(getlist,aRecv))
         @nLine+ 7,nBoxc say aRecv[ 7,FLD_DESC] get aRecv[ 7,FLD_CARG] ;
            pict aRecv[ 7,FLD_PICT] ;
            when(fWbedrag())
         @nLine+ 8,nBoxc say aRecv[ 8,FLD_DESC] get aRecv[ 8,FLD_CARG] ;
            pict aRecv[ 8,FLD_PICT] ;
            when(fWuitsla()) ;
            valid(fVuitsla(getlist,aRecv))
         @nLine+ 9,nBoxc say aRecv[ 9,FLD_DESC] get aRecv[ 9,FLD_CARG] ;
            pict aRecv[ 9,FLD_PICT] ;
            when(fWkouema()) ;
            valid(fVkouema(getlist,aRecv))
         @nLine+10,nBoxc say aRecv[10,FLD_DESC] get aRecv[10,FLD_CARG] ;
            pict aRecv[10,FLD_PICT] ;
            when(fWoordra(getlist,aRecv,nReko))
         @nLine+11,nBoxc say aRecv[11,FLD_DESC] get aRecv[11,FLD_CARG] ;
            pict aRecv[11,FLD_PICT] ;
            when(fWskrapp(getlist,aRecv,nReko))
         @nLine+12,nBoxc say aRecv[12,FLD_DESC] get aRecv[12,FLD_CARG] ;
            pict aRecv[12,FLD_PICT]+"@K" ;
            when(fWgraad())

         // The get
         set cursor on
         read
         set cursor off

         // Reset the database
         fATclose(aCdbf)
         cmclrfilter()

         // The actions
         if lastkey() == K_ENTER

            lRetu := .t.

            if nMenu == 1

               // Single animal

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
                  if "SM3VERK" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next

               // Calculate the live income per kg
               if empty(SM3VERK->ipklew) .and. SM3VERK->massa > 0 .and. SM3VERK->bedrag > 0
                  nData := SM3VERK->bedrag / SM3VERK->massa
                  if nData > 0 .and. nData <= 999.99
                     SM3VERK->ipklew := nData
                  endif
               endif

               // Calculate the live income per kg
               if SM3VERK->kouema > 0 .and. SM3VERK->bedrag > 0
                  nData := SM3VERK->bedrag / SM3VERK->kouema
                  if nData > 0 .and. nData <= 999.99
                     SM3VERK->ipkkou := nData
                  endif
               endif

               dbunlock()
               dbcommit()

               // Update the main file
               select SM3DATA
               do while !rlock()
               enddo
               for i := 1 to len(aRecv)
                  if "SM3DATA" $ aRecv[i,DBF_NAME]
                     fieldput(aRecv[i,13],aRecv[i,14])
                  endif
               next
               dbunlock()
               dbcommit()

               // Update the transfers file if new record
               if nReko == 0 .and. SM3VERK->oordra $ "JY"
                  select SM3OORD
                  dbappend()
                  SM3OORD->idnr := SM3VERK->idnr
                  dbunlock()
                  dbcommit()
               endif

               // Update the cancellation file if new record
               if nReko == 0 .and. SM3VERK->skrapp $ "JY"
                  select SM3VORE
                  dbappend()
                  SM3VORE->idnr := SM3VERK->idnr
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

               // Get the menu prompt
               if aRecv[fEnum(aRecv,"massa"),FLD_CARG] > 1500
                  nDeel := 2
               else
                  nDeel := 1
               endif

               // Ask totals or averages
               if cLanType() == "A"
                  fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Verkope" )
               else
                  fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". [Esc]=Sales" )
               endif
               nDeel := fNewMenu(nDeel,"ADDSALF")
               fARestScr(aCscr)
               do case

                  case nDeel == 1
                     // Normal

                  case nDeel == 2
                     // Divide figures by number of animals
                     if cmkeycount() > 0
                        // Mass
                        nFiel := fEnum(aRecv,"massa")
                        nData := aRecv[nFiel,FLD_CARG]/cmkeycount()
                        if nData > 0 .and. nData <= 9999999
                           aRecv[nFiel,FLD_CARG] := nData
                        endif
                        // Amount
                        nFiel := fEnum(aRecv,"bedrag")
                        nData := aRecv[nFiel,FLD_CARG]/cmkeycount()
                        if nData > 0 .and. nData <= 9999999.99
                           aRecv[nFiel,FLD_CARG] := nData
                        endif
                        // Carcase mass
                        nFiel := fEnum(aRecv,"kouema")
                        nData := aRecv[nFiel,FLD_CARG]/cmkeycount()
                        if nData > 0 .and. nData <= 9999999
                           aRecv[nFiel,FLD_CARG] := nData
                        endif
                     endif

                  otherwise
                     lRetu := .f.
                     break

               endcase

               // Screen
               if cLanType() == "A"
                  fScrWbood(maxrow(),"Diere se verkoopsinligting word bewaar")
               else
                  fScrWbood(maxrow(),"Saving sales information")
               endif

               // Loop the animals in the pick list
               do while !eof()

                  // Screen
                  fScrBood(maxrow()-1,SM3PICK->idnr)

                  // Update the sales file
                  select SM3VERK
                  seek SM3PICK->idnr
                  if eof()
                     dbappend()
                     SM3VERK->idnr := SM3PICK->idnr
                  else
                     do while !rlock()
                     enddo
                  endif
                  for i := 2 to len(aRecv)
                     if "SM3VERK" $ aRecv[i,DBF_NAME]
                        fieldput(aRecv[i,13],aRecv[i,14])
                     endif
                  next
                  // Calculate the live income per kg
                  if empty(SM3VERK->ipklew) .and. SM3VERK->massa > 0 .and. SM3VERK->bedrag > 0
                     nData := SM3VERK->bedrag / SM3VERK->massa
                     if nData > 0 .and. nData <= 999.99
                        SM3VERK->ipklew := nData
                     endif
                  endif
                  // Calculate the live income per kg
                  if SM3VERK->kouema > 0 .and. SM3VERK->bedrag > 0
                     nData := SM3VERK->bedrag / SM3VERK->kouema
                     if nData > 0 .and. nData <= 999.99
                        SM3VERK->ipkkou := nData
                     endif
                  endif
                  dbunlock()
                  dbcommit()

                  // Update the main file
                  select SM3DATA
                  do while !rlock()
                  enddo
                  for i := 1 to len(aRecv)
                     if "SM3DATA" $ aRecv[i,DBF_NAME]
                        // if empty(fieldget(aRecv[i,13]))
                        do while !rlock()
                        enddo
                        fieldput(aRecv[i,13],aRecv[i,14])
                        // endif
                     endif
                  next
                  dbunlock()
                  dbcommit()

                  // Update the transfers file if new record
                  if nReko == 0 .and. SM3VERK->oordra $ "JY"
                     select SM3OORD
                     seek SM3PICK->idnr
                     if eof()
                        dbappend()
                     else
                        do while !rlock()
                        enddo
                     endif
                     SM3OORD->idnr := SM3VERK->idnr
                     dbunlock()
                     dbcommit()
                  endif

                  // Update the cancellation file if new record
                  if nReko == 0 .and. SM3VERK->skrapp $ "JY"
                     select SM3VORE
                     seek SM3PICK->idnr
                     if eof()
                        dbappend()
                     else
                        do while !rlock()
                        enddo
                     endif
                     SM3VORE->idnr := SM3VERK->idnr
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
            select SM3VERK

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
   cOption(-1)
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
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van lewende diere")
         fScrBood(maxrow()  ,"Tik die ID NOMMER van die verkoopte dier!")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of living animals")
         fScrBood(maxrow()  ,"Type the ID NUMBER of the sold animal!")
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
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

      // Locate data
      select SM3VERK
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
         else

            // Fill with data from the main file
            if SM3DATA->uitkrede $ cWaarisd()
            else
               aGets[fEnum(aRecv,"uitkrede")]:varput(SM3DATA->uitkrede)
               aGets[fEnum(aRecv,"uitkdatum")]:varput(SM3DATA->uitkdatum)
            endif

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
            fScrBood(maxrow()-1,"Dier bestaan reeds in die VERKOPE lˆer!")
         else
            fScrBood(maxrow()-1,"Animal does exist in the SALES file!")
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
STATIC FUNCTION fWadreskode

   // Function to control entry to the buyer

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van kopers")
      fScrBood(maxrow()  ,"Tik die ADRESKODE van die koper van die dier dier!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of buyers")
      fScrBood(maxrow()  ,"Type the ADDRESS CODE of the buyer of the animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVadreskode(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := fEnum(aRecv,"adreskode")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         cData := sm3klie(10,,,,aGets[nFiel]:varget())
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

         // No number given - allow

      else

         // See if code is valid
         select SM3KLIE
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"ADRESKODE van koper is onbekend!")
            else
               fScrBood(maxrow()-1,"ADDRESS CODE of buyer is unknown!")
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
STATIC FUNCTION fWuitkrede

   // Function to control entry to the reason

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van waar-is-dier kodes")
      fScrBood(maxrow()  ,"Tik die REDE waarom die dier verkoop is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of where-is-animal codes")
      fScrBood(maxrow()  ,"Type the REASON why an animal was sold!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitkrede(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := fEnum(aRecv,"uitkrede")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3WAAR")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         cData := sm3waar(11,,,,aGets[nFiel]:varget())
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

         // No number given - allow
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dit is wel voordelig om 'n REDE verkoop te verskaf!")
         else
            fScrBood(maxrow()-1,"It is better to supply a REASON why animal was sold!")
         endif
         fScrWait(maxrow())

      else

         // See if code is valid
         select SM3WAAR
         seek aGets[nFiel]:varget()
         if eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"REDE waarom dier verkoop is, is onbekend!")
            else
               fScrBood(maxrow()-1,"REASON why animal was sold is unknown!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
            break
         endif

      endif

      // Code may not indicate living animal
      if !empty(aGets[nFiel]:varget())
         if aGets[nFiel]:varget() $ cWaarisd()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"REDE uit kan nie 'n lewende dier aandui nie!")
            else
               fScrBood(maxrow()-1,"REASON out cannot indicate a living animal!")
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
STATIC FUNCTION fWuitkdatum

   // Function to control entry to the date

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die DATUM waarop die dier verkoop is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the DATE on which the animal was sold!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitkdatum(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nFiel := fEnum(aRecv,"uitkdatum")

   begin sequence

      if empty(aGets[nFiel]:varget())

         // No number given - allow
         if cLanType() == "A"
            fScrBood(maxrow()-1,"DATUM waarop dier verkoop is, is verpligtend!")
         else
            fScrBood(maxrow()-1,"DATE on which animal was sold is compulsory!")
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
STATIC FUNCTION fWmassa(aGets,aRecv)

   // Function to control entry to the mass

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"idnr")
   local aCdbf := fATopen()

   // Open the data files
   aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG")
   if !aCdbf[len(aCdbf),1]
      lRetu := .f.
      break
   endif
   ordsetfocus("sm3wee2")

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die MASSA van die dier op die verkoopdatum!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the MASS of the animal on the selling date!")
   endif

   // Kry die laaste massa van die dier
   if empty(aGets[fEnum(aRecv,"massa")]:varget())

      select SM3WEEG
      seek aGets[fEnum(aRecv,"idnr")]:varget()
      if !eof()
         aGets[fEnum(aRecv,"massa")]:varput(SM3WEEG->massa)
         aGets[fEnum(aRecv,"massa")]:display()
      endif

   endif

   // Herstel
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWipklew

   // Function to control entry to the rc per kilogram

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die INKOMSTE/KG van die dier op die verkoopdatum!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the INCOME/KG of the animal on the selling date!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVipklew(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"ipklew")
   local nData := 0

   begin sequence

      if !empty(aGets[nFiel]:varget()) .and. ;
            !empty(aGets[fEnum(aRecv,"massa")]:varget())

         // Calculate the income
         nData := aGets[fEnum(aRecv,"massa")]:varget() * ;
            (aGets[nFiel]:varget())

         // Save the mass
         if nData > 0 .and. nData <= 9999999.99
            aGets[fEnum(aRecv,"bedrag")]:varput(nData)
            aGets[fEnum(aRecv,"bedrag")]:display()
         endif

      endif

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fWbedrag

   // Function to control entry to the income

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die BEDRAG wat ontvang is vir die dier!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the AMOUNT received for the animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWuitsla

   // Function to control entry to the slaughter percentage

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die UITSLAGPERSENTASIE indien die dier geslag is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the SLAUGHTER PERCENTAGE if the animal was slaughtered!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitsla(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"uitsla")
   local nData := 0

   begin sequence

      if !empty(aGets[nFiel]:varget()) .and. ;
            !empty(aGets[fEnum(aRecv,"massa")]:varget())

         // Calculate the carcase mass
         nData := aGets[fEnum(aRecv,"massa")]:varget() * ;
            (aGets[nFiel]:varget()/100)

         // Save the mass
         if nData > 0 .and. nData <= 9999
            aGets[fEnum(aRecv,"kouema")]:varput(nData)
            aGets[fEnum(aRecv,"kouema")]:display()
         endif

      endif

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fWkouema

   // Function to control entry to the carcas mass

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die KARKASMASSA indien die dier geslag is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the CARCASE MASS if the animal was slaughtered!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVkouema(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"kouema")
   local nData := 0

   begin sequence

      if !empty(aGets[nFiel]:varget()) .and. ;
            !empty(aGets[fEnum(aRecv,"massa")]:varget()) .and. ;
            empty(aGets[fEnum(aRecv,"uitsla")]:varget())

         // Calculate the slaughter percentage
         nData := ( aGets[fEnum(aRecv,"kouema")]:varget() / ;
            aGets[fEnum(aRecv,"massa")]:varget() ) * 100

         // Save the mass
         if nData > 0 .and. nData <= 99.9
            aGets[fEnum(aRecv,"uitsla")]:varput(nData)
            aGets[fEnum(aRecv,"uitsla")]:display()
         endif

      endif

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fWoordra(aGets,aRecv,nReko)

   // Function to control entry to the transfer field

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"oordra")

   // Ask only if sold to somebody
   if empty(aGets[fEnum(aRecv,"adreskode")]:varget()) .or. ;
         nReko > 0
      lRetu := .f.
   else
      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Tik [J]a indien die dier oorgedra moet word aan 'n geregistreerde teler!")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Type [Y]es if animal is to be transferred to another registered breeder!")
      endif
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWskrapp(aGets,aRecv,nReko)

   // Function to control entry to the cancellation field

   // Declare
   local lRetu := .t.
   local nFiel := fEnum(aRecv,"skrapp")

   // Ask only if not transferred
   if nReko == 0
      if aGets[fEnum(aRecv,"oordra")]:varget() $ "JY"
         aGets[nFiel]:varput(" ")
         aGets[nFiel]:display()
         lRetu := .f.
      else
         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow()  ,"Tik [J]a indien die dier op die skrappingslys (Vorm E) moet verskyn!")
         else
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow()  ,"Type [Y]es if animal is to be listed on the cancellation (Form E) list!")
         endif
      endif
   else
      lRetu := .f.
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWgraad

   // Function to control entry to the remark

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik enige OPMERKING oor die verkoop van die dier!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type any REMARK regarding the sale of the animal!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fAverage(aRecv,bBrow)

   // Function to calculate averages

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local nReko := recno()
   local i     := 0
   local oCols := NIL
   local cEbvf := ""
   local cEbvp := ""
   local cEbvc := ""

   // Build the ebv fields variable
   cEbvf := "BIRDIR"
   cEbvf += ",BIRMAT"
   cEbvf += ",WEADIR"
   cEbvf += ",WEAMAT"
   cEbvf += ",WEACOM"
   cEbvf += ",YEADIR"
   cEbvf += ",M18DIR"
   cEbvf += ",OEKDIR"
   cEbvf += ",TKPDIR"
   //cEbvf += ",EOCDIR"
   //cEbvf += ",EOCMAT"
   cEbvf += ",ADGDIR"
   cEbvf += ",PCFCRD"
   cEbvf += ",KLEDIR"
   cEbvf += ",SCRDIR"
   cEbvf += ",HGTDIR"
   cEbvf += ",LGTDIR"
   cEbvf += ",FINDIR"
   cEbvf += ",MCWDIR"
   cEbvf += ",CARDIR"
   cEbvf += ",RIBDIR"

   begin sequence

      // Loop through all the columns to clear totals etc.
      for i := 1 to len(aRecv)
         aRecv[i,FLD_COUN] := 0
         aRecv[i,FLD_TOTA] := 0
      next

      // Set the data file
      go top

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Totale en gemiddeldes word bereken")
      else
         fScrWbood(maxrow(),"Totals and averages being calculated")
      endif

      // Loop through the file
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrbood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
         else
            fScrbood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
         endif

         // Loop through all the columns
         for i := 1 to len(aRecv)
            if aRecv[i,FLD_TYPE] == "N"
               select select(strtran(aRecv[i,1],"->",""))
               //if fieldget(aRecv[i,FLD_NUMB]) > 0
               //   aRecv[i,FLD_COUN]++
               //   aRecv[i,FLD_TOTA] += fieldget(aRecv[i,FLD_NUMB])
               //endif
               if strtran(aRecv[i,DBF_NAME],"->","") == "SM3DATA" .and. aRecv[i,FLD_NAME] $ cEbvf
                  if !empty(SM3DATA->analdate)
                     aRecv[i,FLD_COUN]++
                     aRecv[i,FLD_TOTA]+= fieldget(aRecv[i,FLD_NUMB])
                  endif
               elseif fieldget(aRecv[i,FLD_NUMB]) <> 0
                  aRecv[i,FLD_COUN]++
                  aRecv[i,FLD_TOTA]+= fieldget(aRecv[i,FLD_NUMB])
               else
               endif
            endif
         next

         // Next record
         select SM3VERK
         skip

      enddo

      goto nReko

      // Add all the column footings
      for i := 1 to len(aRecv)
         oCols := bBrow:getcolumn(i)
         oCols:footsep := "Í"
         if i == 1
            // First column to show headings
            if cLanType() == "A"
               oCols:footing := padl("Gemiddeld:",aRecv[i,FLD_LENG])+";"+;
                  padl("Totaal:",aRecv[i,FLD_LENG])
            else
               oCols:footing := padl("Average:",aRecv[i,FLD_LENG])+";"+;
                  padl("Total:",aRecv[i,FLD_LENG])
            endif
         elseif aRecv[i,FLD_TYPE] == "N"
            // Calc the average for all numeric cols
            oCols:footing := transform(zer(aRecv[i,FLD_TOTA],aRecv[i,FLD_COUN]),aRecv[i,FLD_PICT])+";"+;
               transform(aRecv[i,FLD_TOTA],aRecv[i,FLD_PICT])
         else
            // Fill footings with spaces for all other cols
            oCols:footing := space(aRecv[i,FLD_LENG])+";"+;
               space(aRecv[i,FLD_LENG])
         endif
      next

   end

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aOpsk,lAver)

   // Function to print

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nReko := recno()
   local aVeld := {}
   local i     := 0
   local cPrnl := ""
   local cData := ""
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

      // Screen - fields to print
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Drukuitleg word bepaal")
      else
         fScrBood(maxrow(),"Print outlay being determined")
      endif
      if empty(aOpsk)
         aadd(aVeld,{"SM3VERK","idnr"     })
         aadd(aVeld,{"SM3DATA","geslag"   })
         aadd(aVeld,{"SM3VERK","massa"    })
         aadd(aVeld,{"SM3VERK","bedrag"   })
         aadd(aVeld,{"SM3VERK","ipklew"   })
         aadd(aVeld,{"SM3VERK","uitsla"   })
         aadd(aVeld,{"SM3VERK","kouema"   })
         aadd(aVeld,{"SM3VERK","ipkkou"   })
         aadd(aVeld,{"SM3DATA","uitkrede" })
         aadd(aVeld,{"SM3DATA","uitkdatum"})
         aadd(aVeld,{"SM3VERK","adreskode"})
         aadd(aVeld,{"SM3KLIE","naam"     })
         aadd(aVeld,{"SM3VERK","graad"    })
         aOpsk := fGetField(aVeld)
      endif

      // Determine the print width
      for i := 1 to len(aOpsk)
         nWidt += aOpsk[i,FLD_LENG] + nCspa
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

      if lAver
         nPrnl -= 3
      endif

      // Select the dfata file
      go top

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"VERKOPE word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Verkope."
      else
         fScrbood(maxrow(),"SALES being printed!  [Esc]=Stop printer.")
         cHdln := "Sales."
      endif

      // Switch printer on
      fPrnOn()

      // The loop
      do while !eof()


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
         cPrnl := ""
         for i = 1 to len(aOpsk)
            cData := aOpsk[i,1] + aOpsk[i,2]
            if aOpsk[i,3] == "D"
               cPrnl += dtoc(&(cData)) + space(nCspa)
            elseif aOpsk[i,3] == "N"
               cPrnl += str(&(cData),aOpsk[i,4],aOpsk[i,5]) + space(nCspa)
            else
               cPrnl += &(cData) + space(nCspa)
            endif
         next
         @prow()+1,1 say left(cPrnl,nWidt)

         // Screen
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
         select SM3VERK
         skip

         // End of page or end of file
         if prow() >= nPrnl .or. eof()

            // Averages and totals
            if lAver .and. eof()
               // Bottom line
               cPrnl := ""
               for i = 1 to len(aOpsk)
                  cPrnl += repl("-",aOpsk[i,4]) + space(nCspa)
               next
               @prow()+1,1 say left(cPrnl,nWidt)

               // Averages
               cPrnl := ""
               for i := 1 to len(aOpsk)
                  if aOpsk[i,FLD_TYPE] == "N"
                     if aOpsk[i,FLD_COUN] > 0
                        cPrnl += transform((aOpsk[i,FLD_TOTA]/aOpsk[i,FLD_COUN]),aOpsk[i,FLD_PICT])
                     else
                        cPrnl += space(aOpsk[i,FLD_LENG])
                     endif
                  else
                     cPrnl += space(aOpsk[i,FLD_LENG])
                  endif
                  cPrnl += space(nCspa)
               next
               if cLanType() == "A"
                  cPrnl := strtran(cPrnl,space(len("Gemiddeldes:")),"Gemiddeldes:",1,1)
               else
                  cPrnl := strtran(cPrnl,space(len("Averages:")),"Averages:",1,1)
               endif
               @prow()+1,1 say left(cPrnl,nWidt)

               // Totals
               cPrnl := ""
               for i := 1 to len(aOpsk)
                  if aOpsk[i,FLD_TYPE] == "N"
                     if aOpsk[i,FLD_TOTA] > 0
                        cPrnl += transform(aOpsk[i,FLD_TOTA],aOpsk[i,FLD_PICT])
                     else
                        cPrnl += space(aOpsk[i,FLD_LENG])
                     endif
                  else
                     cPrnl += space(aOpsk[i,FLD_LENG])
                  endif
                  cPrnl += space(nCspa)
               next
               if cLanType() == "A"
                  cPrnl := strtran(cPrnl,space(len("Totale:")),"Totale:",1,1)
               else
                  cPrnl := strtran(cPrnl,space(len("Totals:")),"Totals:",1,1)
               endif
               @prow()+1,1 say left(cPrnl,nWidt)

            endif

            // Bottom line
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++
         endif

      enddo

      fPrnOff()

      goto nReko

   end

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fFilter

   // Function to display only selected records

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local cTest := ""
   local nBoxc := 0
   local dFrom := ctod("")
   local dToto := ctod("")
   local cWhom := SM3VERK->adreskode
   local cSele := " "
   local getlist := {}

   begin sequence

      // The screen
      if cLanType() == "A"
         nBoxc := fBoxCent(10,"Verkope vanaf watter datum? xx/xx/xx",6,"Filter")
         @11,nBoxc say "Verkope vanaf watter datum?" get dFrom
         @12,nBoxc say "          Tot watter datum?" get dToto
         @13,nBoxc say "          Vir watter koper?" get cWhom pict "@!@K"
         @14,nBoxc say "             Seleksiegroep?" get cSele pict "!"
      else
         nBoxc := fBoxCent(10,"Sales from which date? xx/xx/xx",6,"Filter")
         @11,nBoxc say "Sales from which date?" get dFrom
         @12,nBoxc say "        To which date?" get dToto
         @13,nBoxc say "      For which buyer?" get cWhom pict "@!@K"
         @14,nBoxc say "      Selection group?" get cSele pict "!"
      endif

      // The read
      setcursor(1)
      read
      setcursor(0)

      // Escaped
      if lastkey() == K_ESC
         break
      endif

      // Build the search array
      if !empty(dFrom)
         cTest += "SM3DATA->uitkdatum>=ctod('"+dtoc(dFrom)+"').and."
      endif
      if !empty(dToto)
         cTest += "SM3DATA->uitkdatum<=ctod('"+dtoc(dToto)+"').and."
      endif
      if !empty(cWhom)
         cTest += "SM3VERK->adreskode=='"+cWhom+"'.and."
      endif
      if cSele $ "JY"
         cTest += sm3selg(,,,,,.t.)
      endif

      // If no search
      if empty(cTest)
         break
      endif

      // Remove the last and from the search string
      if right(cTest,5) == ".and."
         cTest := left(cTest,len(cTest)-5)
      endif

      // Screen
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Diere word uitgesoek")
      else
         fScrWbood(maxrow(),"Animals being selected")
      endif

      // Set the filter
      lRetu := .t.
      //@23,0 say right(cTest,50)
      //inkey(0)
      cmfilter(cTest)
      go top

   end

   // Reset
   fARestScr(aCscr)

return lRetu
