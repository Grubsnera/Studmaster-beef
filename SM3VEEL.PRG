// Application: StudMaster for Beef Cattle
//   File Name: SM3VEEL.PRG
// Description: Program to display a single animal's veterinary file
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-13-95 02:16pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3veel(nTopp,nLeft,nBott,aVeld,cFind)

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

      // Id number must be displayed
      if empty(cFind)
         break
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
         aadd(aVeld,{"SM3VEEA","datum"    })
         aadd(aVeld,{"SM3SIEK","besk"     })
         aadd(aVeld,{"SM3BEHA","besk"     })
         aadd(aVeld,{"SM3VEEA","dosis"    })
         aadd(aVeld,{"SM3VEEA","koste"    })
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIEK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3BEHA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VEEA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      cmfilter("SM3VEEA->idnr=='"+cFind+"'")
      dbsetrelation("SM3SIEK",{|| SM3VEEA->siekte },"SM3VEEA->siekte")
      dbsetrelation("SM3BEHA",{|| SM3VEEA->behand },"SM3VEEA->behand")

      // Move the record pointer
      go top

      // Calculate averages and totals
      // Loop through all the columns to clear totals etc.
      for i := 1 to len(aOpsk)
         aOpsk[i,FLD_COUN] := 0
         aOpsk[i,FLD_TOTA] := 0
      next
      do while !eof()

         // The calculation
         for i := 1 to len(aOpsk)
            if aOpsk[i,FLD_TYPE] == "N"
               select select(strtran(aOpsk[i,1],"->",""))
               if fieldget(aOpsk[i,FLD_NUMB]) > 0
                  aOpsk[i,FLD_COUN]++
                  aOpsk[i,FLD_TOTA] += fieldget(aOpsk[i,FLD_NUMB])
               endif
            endif
         next

         // Next record
         select SM3VEEA
         skip

      enddo

      // Go to top of file
      select SM3VEEA
      go top

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
         fScrOpsk()
      endif

      // Draw the box
      if cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "VEEARTSENY VIR "+trim(cFind) )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "VETERINARY FOR "+trim(cFind) )
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

      // Add all the column footings
      for i := 1 to len(aOpsk)
         oCols := bBrow:getcolumn(i)
         oCols:footsep := "Í"
         if i == 1
            // First column to show headings
            if cLanType() == "A"
               oCols:footing := padl("Totaal:",aOpsk[i,FLD_LENG])
            else
               oCols:footing := padl("Total:",aOpsk[i,FLD_LENG])
            endif
         elseif aOpsk[i,FLD_TYPE] == "N"
            // Calc the average for all numeric cols
            oCols:footing := transform(aOpsk[i,FLD_TOTA],aOpsk[i,FLD_PICT])
         else
            // Fill footings with spaces for all other cols
            oCols:footing := space(aOpsk[i,FLD_LENG])
         endif
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins]=Nuwe veeartseny                         ")
         fScrBood(maxrow()  , "[F1 ]=Hulp  [Del]=Skrap veeartseny  [AltP]=Druk veeartseny")
      else
         fScrBood(maxrow()-1, "[Esc]=Menu  [Ins ]=New veterinary                           ")
         fScrBood(maxrow()  , "[F1 ]=Help  [Del]=Delete veterinary  [AltP]=Print veterinary")
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
            do help with "SM3VEEL",1,"oorsig"

         elseif nKeyp == K_DEL
            // Delete means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := recno()
            if fAddVeea(,cFind)
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fAddVeea(recno(),cFind)
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_P
            // Alt P means print
            if fPrint(aOpsk)
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

   // Screen
   if cLanType() == "A"
      cBood := "Moet bogenoemde VEEARTSENY-INSKRYWING geskrap word?"
   else
      cBood := "Should above-mentioned VETERINARY ENTRY be deleted?"
   endif
   fScrBood(maxrow()-1,trim(SM3VEEA->idnr)+" - "+trim(SM3VEEA->siekte)+" - "+trim(SM3VEEA->behand))
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
STATIC FUNCTION fAddVeea(nReko,cIdnr)

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
      aadd(aSend,{"SM3VEEA","datum" })
      aadd(aSend,{"SM3VEEA","siekte"})
      aadd(aSend,{"SM3VEEA","behand"})
      aadd(aSend,{"SM3VEEA","dosis" })
      aadd(aSend,{"SM3VEEA","koste" })
      //aadd(aSend,{"SM3VEEA","arts"  })
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
                  //aRepe := {}
                  //aadd(aRepe,"datum")
                  //aRecv := fFillBlank(aRecv,aRepe)
                  aRecv := fFillBlank(aRecv)
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
            when(fWdatum()) ;
            valid(fVdatum(getlist,aRecv))
         @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
            pict aRecv[ 2,FLD_PICT] ;
            when(fWsiekte()) ;
            valid(fVsiekte(getlist,aRecv))
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT] ;
            when(fWbehand()) ;
            valid(fVbehand(getlist,aRecv))
         @nLine+ 4,nBoxc say aRecv[ 4,FLD_DESC] get aRecv[ 4,FLD_CARG] ;
            pict aRecv[ 4,FLD_PICT] ;
            when(fWdosis())
         @nLine+ 5,nBoxc say aRecv[ 5,FLD_DESC] get aRecv[ 5,FLD_CARG] ;
            pict aRecv[ 5,FLD_PICT] ;
            when(fWkoste(getlist,aRecv))
         //@nLine+ 6,nBoxc say aRecv[ 6,FLD_DESC] get aRecv[ 6,FLD_CARG] ;
         //   pict aRecv[ 6,FLD_PICT] ;
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

            // Single animal

            // Add or edit record
            if nReko == 0
               // Add
               dbappend()
               SM3VEEA->idnr := cIdnr
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

            // Select the active file
            select SM3VEEA

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

   // Function to print

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aVeld := {}
   local i     := 0
   local cPrnl := ""
   local cData := ""
   local cIdnr := ""
   local lPrin := .t.
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
         aadd(aVeld,{"SM3VEEA","datum"    })
         aadd(aVeld,{"SM3SIEK","besk"     })
         aadd(aVeld,{"SM3BEHA","besk"     })
         aadd(aVeld,{"SM3VEEA","dosis"    })
         aadd(aVeld,{"SM3VEEA","koste"    })
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
         nPrnl := nPrnPrnl() - 2
         nPagl := nPrnLeng()
      else
         // Condense
         cPcod := cPrnCond()
         nWidt := nPrnCwid()
         nTopl := nPrnLine()
         if nPrnLptp() < 8
            nPrnl := nPrnPrnl() - 2
            nPagl := nPrnLeng()
         else
            nPrnl := nPrcPrnl() - 2
            nPagl := nPrcLeng()
         endif
      endif

      nMidc := nWidt - 29

      // Select the dfata file
      go top

      // Screen
      if cLanType() == "A"
         fScrbood(maxrow(),"VEEARTSENY word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Veeartseny vir "+trim(SM3VEEA->idnr)+"."
      else
         fScrbood(maxrow(),"VETERINARY being printed!  [Esc]=Stop printer.")
         cHdln := "Veterinary for "+trim(SM3VEEA->idnr)+"."
      endif
      cIdnr := trim(SM3VEEA->idnr)

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
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,7]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 2nd heading line
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,8]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 3rd heading line
            cPrnl := "####" + space(nCspa)
            for i = 1 to len(aOpsk)
               cPrnl += padr(trim(aOpsk[i,9]),aOpsk[i,4]) + space(nCspa)
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // 4th heading line
            cPrnl := "----" + space(nCspa)
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
         cPrnl := padl(alltrim(str(cmkeyno())),4) + space(nCspa)
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

            // Totals line
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               if aOpsk[i,FLD_TYPE] == "N"
                  cPrnl += repl("-",aOpsk[i,FLD_LENG]) + space(nCspa)
               else
                  cPrnl += space(aOpsk[i,FLD_LENG]) + space(nCspa)
               endif
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // Totals
            cPrnl := "    " + space(nCspa)
            for i = 1 to len(aOpsk)
               if i == 1
                  // First column to show headings
                  if cLanType() == "A"
                     cPrnl += padr("Totaal:",aOpsk[i,FLD_LENG]) + space(nCspa)
                  else
                     cPrnl += padr("Total:",aOpsk[i,FLD_LENG]) + space(nCspa)
                  endif
               elseif aOpsk[i,FLD_TYPE] == "N"
                  // Calc the average for all numeric cols
                  cPrnl += transform(aOpsk[i,FLD_TOTA],aOpsk[i,FLD_PICT]) + space(nCspa)
               else
                  // Fill footings with spaces for all other cols
                  cPrnl += space(aOpsk[i,FLD_LENG]) + space(nCspa)
               endif
            next
            @prow()+1,1 say left(cPrnl,nWidt)

            // Bottom line
            @prow()+1, 1 say repl("=",nWidt)
            @prow()+1, 1 say cAppName()
            @prow()+(nPagl-3-prow()),nWidt-len(cIdnr) say cIdnr
            fPrnEjec()
            //fPrnOff()
            nBlad++

         endif

      enddo

      fPrnOff()

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu
