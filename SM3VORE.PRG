// SM3VORE.PRG
// Program om Vorm E te druk
// Kopiereg (c) 1993 A van Rensburg
// 06-09-93 04:26am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "fileio.ch"

/******************************************************************************/
FUNCTION sm3vore( nTop, nLeft, nBott, aSend, cFind )

   // Veranderlikes
   local cCscr      := savescreen(0,0,24,79)
   local aCdbf      := fATopen()
   local nWatt      := 1
   local aRecv      := {}
   local nScrl      := 0
   local nRigh      := 77
   local bBrow      := NIL
   local aCols      := {}
   local i          := 0
   local nKeyp      := 0
   local cRetu      := space(12)
   local nReko      := 0
   local lIdnr      := .f.
   local aDatu      := {}
   local cTfil      := cDd()+"sm3vore.txt"
   local nCopy      := 2
   local cSeek      := ""
   local cBood      := ""
   local nBoxc      := 0
   local lMove     := .f.
   local cTest      := ""
   local bTest      := NIL
   local getlist    := {}
   local cOpsk      := ""
   local nChoi := 0
   local aTest := {}
   local aPscr := {}
   local nCurr := 1
   local aPsen := {}
   local aPrec := {}
   local cBrep := ""


   //private cTest := ""
   private cData := ""
   private cHead := ""
   private cRasn := ""

   // Values
   aadd(aTest,ctod(""))
   aadd(aTest,ctod(""))
   aadd(aTest,ctod(""))
   aadd(aTest,ctod(""))

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   begin sequence

      // Kry die rasnaam
      cOpsk := fRasNaam(substr(cTotNaam(),149,3),"HEADDL")
      if empty(cOpsk)
         cRasn := fRasNaam(substr(cTotNaam(),149,3))
         if cLanType() == "A"
            cOpsk := "Die "+cRasn+" Beestelersgenootskap van S.A."
         else
            cOpsk := "The "+cRasn+" Cattle Breeders Society of S.A."
         endif
      endif

      // Parameters
      nTop    := if( nTop  == NIL, 3, nTop  )
      nLeft   := if( nLeft == NIL, 2, nLeft )
      nBott   := if( nBott == NIL,21, nBott )
      if aSend == NIL
         aSend := {}
         aadd(aSend,{"sm3vore","idnr"      })
         aadd(aSend,{"sm3data","geslag"    })
         aadd(aSend,{"sm3data","gebdatum"  })
         aadd(aSend,{"sm3data","uitkdatum" })
         aadd(aSend,{"sm3data","uitkrede"  })
         aadd(aSend,{"sm3vore","druk"      })
      endif

      // Build the get array
      aadd(aPsen,{"sm3data","uitkdatum" })
      aadd(aPsen,{"sm3data","uitkrede"  })

      // Veldbeskrywings
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrWbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField( aSend )
      aPrec := fGetField( aPsen )

      // Vra een of groep diere
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
      endif
      nWatt := fNewMenu(nWatt,"SM3VORE")
      fScrBood(23)
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption(nWatt))
      else
         fScrOpsk( 1, "Option "+cOption(nWatt))
      endif

      do case

         case nWatt == 1

            // Een dier
            lIdnr := .t.

         case nWatt == 2

            // Groep
            cTest := sm3groe()
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No group selection requirements have been specified!")
               endif
               break
            endif

         case nWatt == 3

            // Seleksiegroep
            cTest := sm3selg()
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No selection group requirements have been specified!")
               endif
               break
            endif

         case nWatt == 4

            // Bestaande diere

         otherwise

            break

      endcase

      //Open datalˆers
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Datalˆers word geopen")
      else
         fScrWbood(24,"Data files being opened")
      endif

      // Waar-is-dier kodes
      aCdbf := fATopen(aCdbf,cDd(),"sm3waar")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Vorm E
      aCdbf := fATopen(aCdbf,cDd(),"sm3vore",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Hoofleer
      aCdbf := fATopen(aCdbf,cDd(),"sm3data",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Soek diere if groep en seleksiegroep
      if nWatt == 2 .or. nWatt == 3

         // Waardes
         aPrec[1,14] := ctod("")
         aPrec[2,14] := "  "
         bTest := &("{|| "+cTest+" }")

         // Skerm
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
            nBoxc := fBoxCent(10,space(30),5,"Skrappings")
         else
            fScrOpsk(,"Option "+cOption())
            nBoxc := fBoxCent(10,space(30),5,"Cullings")
         endif
         @11,nBoxc say aPrec[ 1][6] get aPrec[ 1][14] pict aPrec[ 1][10] ;
            when(fWuitkdatum()) ;
            valid(fVuitkdatum(getlist,aPrec))
         @13,nBoxc say aPrec[ 2][6] get aPrec[ 2][14] pict aPrec[ 2][10] ;
            when(fWuitkrede()) ;
            valid(fVuitkrede(getlist,aPrec))
         set cursor on
         read
         set cursor off

         restscreen(0,0,24,79,cCscr)
         if lastkey() == K_ESC .or. empty(aPrec[1,14])
            break
         endif

         // Skerm
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Diere word uitgesoek")
         else
            fScrWbood(24,"Animals being sorted")
         endif

         // Skep 'n teksleer met uitgesoekte diere
         select SM3DATA
         go top
         do while !eof()

            if eval(bTest)

               // Add to the main file
               // Reason left herd
               if SM3DATA->uitkrede $ cWaarisd()
                  SM3DATA->uitkrede = aPrec[2,14]
               endif
               // Date left herd
               if empty(SM3DATA->uitkdatum)
                  SM3DATA->uitkdatum = aPrec[1,14]
               endif

               // Add to Form E file
               select SM3VORE
               seek SM3DATA->idnr
               if eof()

                  dbappend()
                  SM3VORE->idnr  := SM3DATA->idnr

               endif

            endif

            // Next
            select SM3DATA
            skip

         enddo

         // Select
         select SM3VORE
         go top

      else

         select SM3VORE

      endif

      // Set relations
      set relation to SM3VORE->idnr into SM3DATA
      go top

      // Skerm
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      // Kry die breedte van venster
      for i = 1 to len(aRecv)
         // Lengte
         nScrl := nScrl + aRecv[i,4] + 1
         // Kolomme
         cData := aRecv[i,1] + aRecv[i,2]
         cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
      next

      // Bepaal regterkantste lyn
      nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

      // Teken die box
      if cLanType() == "A"
         fBox( nTop, nLeft, nBott, nRigh, "VORM E (SKRAPPINGS)" )
      else
         fBox( nTop, nLeft, nBott, nRigh, "FORM E (CULLINGS)" )
      endif
      setcolor( cColNorm() )

      // Bou die tBrowse
      bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Plaas kolomme oor na die browse object
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Main loop
      do while nKeyp <> K_ESC

         // Skerm
         if cLanType() == "A"
            fScrBood( 23, "[Esc]=Menu  [Ins] =Nuwe     [AltF]=Elektronies [A-Z]=Vind")
            fScrBood( 24, "[Del]=Skrap [AltE]=Verander [AltP]=Druk                  ")
         else
            fScrBood( 23, "[Esc]=Menu   [Ins]= New  [AltF]=Electronic [A-Z]=Find")
            fScrBood( 24, "[Del]=Delete [AltE]=Edit [AltP]=Print                ")
         endif

         // Stabilize
         FullStabilize(bBrow)
         if lMove
            do while recno() <> nCurr
               bBrow:up()
               FullStabilize(bBrow)
            enddo
            lMove := .f.
         endif

         // If single animals is to be asked
         if lIdnr
            lIdnr := .f.
            keyboard chr(K_INS)
         endif

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         // The keypresses
         if nKeyp == K_ENTER

            // Enter means return kode
            cRetu := fieldget(1)
            keyboard chr(K_ESC)

         elseif nKeyp == K_INS

            // Insert means add a record to the .dbf
            nCurr := recno()
            if fACvore()
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := recno()
            if fACvore(recno())
               lMove := .t.
               nCurr := recno()
               bBrow:refreshall()
            else
               goto nCurr
            endif

         elseif nKeyp == K_DEL

            // Delete means delete a record
            if fDelete(aRecv)
               bBrow:refreshall()
            endif

         elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"

            // Means locate a record
            if fLocate(aRecv,nKeyp)
               bBrow:refreshall()
            endif

         elseif nKeyp == K_ALT_F

            // Alt F means print
            aPscr := fASaveScr()

            // Menu to ask which records to print
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Skrappingslys" )
            else
               fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Culling list" )
            endif

            nChoi := fNewMenu(nChoi,"SM3VORP")
            fARestScr(aPscr)

            if nChoi == 1

               // Unprinted records
               bTest := &("{|| empty(SM3VORE->druk) }")

            elseif nChoi == 2

               // Printed records
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"[Esc]=Skrappingslys")
                  fScrBood(maxrow(),"Tik die skrap en/of drukdatums wat gestuur moet word!")
                  nBoxc := fBoxCent(10,space(30),6,"EPOS SKRAPPINGS")
                  @11,nBoxc say "Vanaf skrapdatum" get aTest[1]
                  @12,nBoxc say "  tot skrapdatum" get aTest[2]
                  @13,nBoxc say " Vanaf drukdatum" get aTest[3]
                  @14,nBoxc say "   tot drukdatum" get aTest[4]
               else
                  fScrBood(maxrow()-1,"[Esc]=Culling list")
                  fScrBood(maxrow(),"Type the culling and/or printed dates to be posted!")
                  nBoxc := fBoxCent(10,space(30),6,"EMAIL CULLINGS")
                  @11,nBoxc say "From culling date" get aTest[1]
                  @12,nBoxc say "  to culling date" get aTest[2]
                  @13,nBoxc say "From printed date" get aTest[3]
                  @14,nBoxc say "  to printed date" get aTest[4]
               endif
               setcursor(1)
               read
               setcursor(0)

               if lastkey() <> K_ESC
                  // Clean out the variable
                  cTest := ""

                  // Added 01-29-97 10:38am
                  if !empty(aTest[1])
                     //cTest += "SM3VORE->datum>=ctod('"+dtoc(aTest[1])+"').and."
                     // 12-17-97 11:04am Albert
                     cTest += "SM3DATA->uitkdatum>=ctod('"+dtoc(aTest[1])+"').and."
                  endif
                  if !empty(aTest[2])
                     //cTest += "SM3VORE->datum<=ctod('"+dtoc(aTest[2])+"').and."
                     // 12-17-97 11:04am Albert
                     cTest += "SM3DATA->uitkdatum<=ctod('"+dtoc(aTest[2])+"').and."
                  endif
                  if !empty(aTest[3])
                     cTest += "SM3VORE->druk>=ctod('"+dtoc(aTest[3])+"').and."
                  endif
                  if !empty(aTest[4])
                     cTest += "SM3VORE->druk<=ctod('"+dtoc(aTest[4])+"').and."
                  endif
                  if !empty(cTest)
                     if right(cTest,5) == ".and."
                        cTest := left(cTest,len(cTest)-5)
                     endif
                     bTest := &("{|| "+cTest+" }")
                  endif
               endif
            endif

            if !empty(bTest)

               fARestScr(aPscr)

               // Skep die leer

               // Alt F means create electronic notofication
               cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

               if cBrep $ "JYjy"

                  // Breedplan format
                  //if fDiskBrem()
                  //   bBrowse:refreshall()
                  //endif

               else

                  // Iris matings

                  // Added 13-04-25 07:34 (From Downloads/Studbook/EDH20130424.PDF)
                  if fDiskIris(bTest)
                     bBrow:refreshall()
                  endif

                  // Merk ongedrukte diere
                  if nChoi == 1
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWbood(24,"Geskrapte diere word in die hooflˆer gemerk")
                     else
                        fScrWbood(24,"Cancelled animals being marked in the main file")
                     endif
                     select SM3VORE
                     go top
                     do while !eof()
                        if empty(SM3VORE->druk)
                           SM3VORE->druk := dAppDate()
                        endif
                        skip
                     enddo
                     keyboard chr(K_ESC)
                  else
                     select SM3VORE
                     go top
                     bBrow:refreshall()
                  endif

               endif

               // Restore the screen
               fARestScr(aPscr)

            else

               // Apply the key to the browse
               ApplyKey(bBrow, nKeyp)

            endif

         elseif nKeyp == K_ALT_P

            // Alt P means print
            aPscr := fASaveScr()

            // Menu to ask which records to print
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Skrappingslys" )
            else
               fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Culling list" )
            endif
            nChoi := fNewMenu(nChoi,"SM3VORP")
            fARestScr(aPscr)
            if nChoi == 1
               // Unprinted records
               bTest := &("{|| empty(SM3VORE->druk) }")
            elseif nChoi == 2
               // Printed records
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"[Esc]=Skrappingslys")
                  fScrBood(maxrow(),"Tik die skrap en/of drukdatums wat gedruk moet word!")
                  nBoxc := fBoxCent(10,space(30),6,"DRUK SKRAPPINGS")
                  @11,nBoxc say "Vanaf skrapdatum" get aTest[1]
                  @12,nBoxc say "  tot skrapdatum" get aTest[2]
                  @13,nBoxc say " Vanaf drukdatum" get aTest[3]
                  @14,nBoxc say "   tot drukdatum" get aTest[4]
               else
                  fScrBood(maxrow()-1,"[Esc]=Culling list")
                  fScrBood(maxrow(),"Type the culling and/or printed dates to be printed!")
                  nBoxc := fBoxCent(10,space(30),6,"PRINT CULLINGS")
                  @11,nBoxc say "From culling date" get aTest[1]
                  @12,nBoxc say "  to culling date" get aTest[2]
                  @13,nBoxc say "From printed date" get aTest[3]
                  @14,nBoxc say "  to printed date" get aTest[4]
               endif
               setcursor(1)
               read
               setcursor(0)
               if lastkey() <> K_ESC
                  // Clean out the variable
                  cTest := ""
                  // Added 01-29-97 10:38am
                  if !empty(aTest[1])
                     //cTest += "SM3VORE->datum>=ctod('"+dtoc(aTest[1])+"').and."
                     // 12-17-97 11:04am Albert
                     cTest += "SM3DATA->uitkdatum>=ctod('"+dtoc(aTest[1])+"').and."
                  endif
                  if !empty(aTest[2])
                     //cTest += "SM3VORE->datum<=ctod('"+dtoc(aTest[2])+"').and."
                     // 12-17-97 11:04am Albert
                     cTest += "SM3DATA->uitkdatum<=ctod('"+dtoc(aTest[2])+"').and."
                  endif
                  if !empty(aTest[3])
                     cTest += "SM3VORE->druk>=ctod('"+dtoc(aTest[3])+"').and."
                  endif
                  if !empty(aTest[4])
                     cTest += "SM3VORE->druk<=ctod('"+dtoc(aTest[4])+"').and."
                  endif
                  if !empty(cTest)
                     if right(cTest,5) == ".and."
                        cTest := left(cTest,len(cTest)-5)
                     endif
                     bTest := &("{|| "+cTest+" }")
                  endif
               endif
            endif

            if !empty(bTest)

               fARestScr(aPscr)

               // Aantal kopiee
               nCopy := 1                        // fCopies(2) 07-05-28 12:17
               for i = 1 to nCopy
                  if !fPrint(cOpsk,bTest)
                     i := 100
                  endif
               next

               if nChoi == 1
                  fScrBood(23)
                  if cLanType() == "A"
                     fScrWbood(24,"Geskrapte diere word in die hooflˆer gemerk")
                  else
                     fScrWbood(24,"Cancelled animals being marked in the main file")
                  endif
                  select SM3VORE
                  go top
                  do while !eof()
                     if empty(SM3VORE->druk)
                        SM3VORE->druk := dAppDate()
                     endif
                     skip
                  enddo
                  keyboard chr(K_ESC)
               else
                  select SM3VORE
                  go top
                  bBrow:refreshall()
               endif

            endif

            // Restore the screen
            fARestScr(aPscr)

         else

            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

   // Herstel
   restscreen(0,0,24,79,cCscr)
   fATclose(aCdbf)
   cOption(-1)

return cRetu

/******************************************************************************/
STATIC FUNCTION fACVore(nReko)

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
      aadd(aSend,{"SM3VORE","idnr"     })
      aadd(aSend,{"SM3DATA","uitkrede" })
      aadd(aSend,{"SM3DATA","uitkdatum"})
      aRecv := fGetField(aSend)

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if nReko == 0
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"BEWAAR NUWE SKRAPPINGS" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"ENTER A NEW CULL" )
         endif
      else
         if cLanType() == "A"
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"VERANDER SKRAPPINGS" )
         else
            nBoxc := fBoxCent(nLine,space(60),len(aRecv)+2,"EDIT A CULL" )
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
                  aadd(aRepe,"uitkrede" )
                  aadd(aRepe,"uitkdatum")
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
            when(fWuitkrede()) ;
            valid(fVuitkrede(getlist,aRecv))
         @nLine+ 3,nBoxc say aRecv[ 3,FLD_DESC] get aRecv[ 3,FLD_CARG] ;
            pict aRecv[ 3,FLD_PICT]+"@K" ;
            when(fWuitkdatum()) ;
            valid(fVuitkdatum(getlist,aRecv))

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
               if "SM3VORE" $ aRecv[i,DBF_NAME]
                  fieldput(aRecv[i,13],aRecv[i,14])
               endif
            next

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

            // Select the active file
            select SM3VORE

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
         fScrBood(maxrow()  ,"Tik die ID NOMMER van die geskrapte dier!")
      else
         fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of living animals")
         fScrBood(maxrow()  ,"Type the ID NUMBER of the culled animal!")
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
      aCdbf := fATopen(aCdbf,cDd(),"SM3VORE")
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
      select SM3VORE
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
            fScrBood(maxrow()-1,"Dier bestaan reeds in die SKRAPPINGS lˆer!")
         else
            fScrBood(maxrow()-1,"Animal does exist in the CULLS file!")
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
               fScrBood(maxrow()-1,"REDE waarom dier geskrap is, is onbekend!")
            else
               fScrBood(maxrow()-1,"REASON why animal was culled is unknown!")
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
      fScrBood(maxrow()  ,"Tik die DATUM waarop die dier geskrap is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the DATE on which the animal was culled!")
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
            fScrBood(maxrow()-1,"DATUM waarop dier geskrap is, is verpligtend!")
         else
            fScrBood(maxrow()-1,"DATE on which animal was culled is compulsory!")
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
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde "+alltrim(aRecv[1][6])+" verwyder word vanaf die vorm e lys?"
   else
      cBood := "Should above-mentioned "+alltrim(aRecv[1][6])+" be removed from the form e list?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
      delete
      skip
      if eof()
         go top
      endif
      lReturn := .t.
   endif

return lReturn

/******************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local cData := ""
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cData := upper(chr(nKeyp)) + space(aRecv[1][4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[1][6] get cData pict aRecv[1][10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cData == space(aRecv[1][4])
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   set softseek on
   seek cData
   set softseek off
   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(cOpsk,bTest)

   //Verklaar
   local getlist := {}
   local lRetu := .t.
   local nTota := 0
   local lLoop := .t.
   local nCoun := 1
   local nReko := 0
   local cOps2 := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   begin sequence

      //Toets of drukker gereed is
      if fPrnReady() == K_ESC
         lRetu := .f.
         break
      endif

      // Normal Printing
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
      nMidc := nWidt - 29
      //Skerm
      fScrBood(23)

      //Skuif die databasis
      select SM3VORE
      go top

      //Tel aantal velde
      nTota := lastrec()

      //Skerm
      if cLanType() == "A"
         fScrbood(24,"Vorm E (Skrappings) word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(24,"Form E (Cullings) form being printed!  [Esc]=Stop printer.")
      endif

      //Skakel die drukker aan
      fPrnOn()

      //Doen die loop
      lLoop := .t.
      do while lLoop


         //Opskrifte
         if prow() = 0
            fPrnCod( cPcod )

            if cLanType() == "A"
               @prow()+nTopl,(nWidt/2)-len(cOpsk)/2 say upper(cOpsk)
               if substr(cTotNaam(),149,3) == "213"
                  //Bonsmara
                  cOps2 := "VORM E"
               else
                  cOps2 := "SKRAPPINGSLYS"
               endif
               @prow()+1,(nWidt/2)-len(cOps2)/2 say cOps2
               @prow()+1,    1 say cGebNaam()
               @prow()  , nMidc say "             Verslag: " + cOption()
               @prow()+1,    1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
               @prow()+1,    1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "              Bladsy: " + ltrim(str(nBlad))
               @prow()+1,    1 say trim(substr(cTotNaam(),81,40))
               @prow()+1,    1 say substr(cTotNaam(),121,4)
               @prow()+2,    1 say upper("Skrap asseblief volgende diere van Genootskap se rekords.")
               @prow()+1,    1 say repl("=",nWidt)
               @prow()+1,    1 say "                                            "
               @prow()+1,    1 say "    Skrap                                   "
               @prow()+1,    1 say "### datum    Id nommer    Reg.Nr.    Ges Wid"
               @prow()+1,    1 say "--- -------- ------------ ---------- --- ---"
               //                   1   5        14           27
            else
               @prow()+nTopl,(nWidt/2)-len(cOpsk)/2 say upper(cOpsk)
               if substr(cTotNaam(),149,3) == "213"
                  //Bonsmara
                  cOps2 := "FORM E"
               else
                  cOps2 := "CULLING LIST"
               endif
               @prow()+1,(nWidt/2)-len(cOps2)/2 say cOps2
               @prow()+1,    1 say cGebNaam()
               @prow()  , nMidc say "              Report: " + cOption()
               @prow()+1,    1 say substr(cTotNaam(),1,40)
               @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
               @prow()+1,    1 say substr(cTotNaam(),41,40)
               @prow()  , nMidc say "                Page: " + ltrim(str(nBlad))
               @prow()+1,    1 say trim(substr(cTotNaam(),81,40))
               @prow()+1,    1 say substr(cTotNaam(),121,4)
               @prow()+2,    1 say upper("Please cancel above animals from Society records.")
               @prow()+1,    1 say repl("=",nWidt)
               @prow()+1,    1 say "                                            "
               @prow()+1,    1 say "    Cull                                    "
               @prow()+1,    1 say "### date     Id number    Reg.No.    Sex Wia"
               @prow()+1,    1 say "--- -------- ------------ ---------- --- ---"
               //                   1   5        14           27
            endif
         endif

         //Toets of drukker moet stop
         if fPrnStop() = K_ESC
            lRetu := .f.
            lLoop := .f.
            exit
         endif

         //Data
         if eval(bTest)
            @prow()+1,       1 say str(nCoun,3,0)
            nCoun++
            @prow()  ,pcol()+1 say SM3DATA->uitkdatum
            @prow()  ,pcol()+1 say SM3VORE->idnr
            // Remove Bonsmara 02-08-27 11:43
            //if substr(cTotNaam(),149,3) == "213"
            //   //Bonsmara
            //   @prow()  ,pcol()+1 say SM3DATA->kalfbnr
            //else
            @prow()  ,pcol()+1 say SM3DATA->reknr
            @prow()  ,pcol()+2 say SM3DATA->geslag
            // Added where is animal code on 12-08-29 08:42
            @prow()  ,pcol()+2 say SM3DATA->uitkrede
            //endif
         endif

         //Skerm
         // fPrnOff()
         // if nTota > 0
         //    setcolor( cColBott() )
         //    if cLanType() == "A"
         //       @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
         //    else
         //       @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
         //    endif
         //    setcolor( cColNorm() )
         //    nReko++
         // endif
         // fPrnOn()

         //Volgende rekord
         skip

         //Toets vir einde van bladsy
         if prow() >= nPrnl .or. eof()

            //Print onderste lyn
            @prow()+1,  1 say repl( "=",  nWidt )
            @prow()+1,  1 say cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++

            //Indien eof()
            if eof()
               lLoop := .f.
            endif

         endif
      enddo

      fPrnOff()

   end

   //Herstel
   select SM3VORE
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskIris(bTest)

   // Program to create electronic form e file
   // According to EDV20130424.PDF at Downloads/Studbook
   // 13-06-11 07:54

   // Declare
   local lRetu := .t.
   local nTota := 0
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nHdel := 0
   local cStr  := ""
   local cData := ""
   local i     := 0
   local nLen  := 0
   local cIcar := ""
   local nBoxc := 0
   local nMfil := 0
   local nCoun := 1
   local nSeqn := 1
   local cSeqn := ""

   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      nSeqn := STDWAAR->elecsq + 1
      if nSeqn > 999
         nSeqn := 1
      endif
      do while !rlock()
      enddo
      STDWAAR->elecsq := nSeqn
      cSeqn := right("00"+alltrim(str(nSeqn)),3)

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3WAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      set relation to SM3DATA->UITKREDE into SM3WAAR

      // Set the relationship
      select SM3VORE
      set relation to SM3VORE->IDNR into SM3DATA
      go top

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"C"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"C"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese skrappingslˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic cancellation file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skrappingslˆer word voorberei")
      else
         fScrWbood(maxrow(),"Cancellation file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Skrappingslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create cancellation file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Skrappingslˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to cancellation file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Start writing the data to the file

      // Write the data
      select SM3VORE
      go top

      // Tel aantal velde
      nTota := lastrec()

      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(nCoun,nTota)+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(nCoun,nTota)+"% Completed"      )
         endif

         // The actual write
         if eval(bTest)

            if val(SM3DATA->reknr) > 0 .and. !empty(SM3DATA->uitkdatum)

               // Header
               cStr := "C"                       //1
               cStr += substr(alltrim(cIcar),1,3)// Breed code
               cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
               cStr += "S"
               cStr += cSeqn
               cStr += padr("SM"+alltrim(cVersion()),10) // Version number
               cStr += "CANC"                    // Document code
               cStr += "C"                       // Action type

               // Participant number
               cStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member numbercStr += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
               //cStr += alltrim(cIcar)                  // Breed code
               cStr += "000"

               // Computer number
               cStr += padl(alltrim(SM3DATA->reknr),10,"0") // Computer number

               // Id number
               cStr += alltrim(cIcar)            // Breed code
               if SM3DATA->geslag $ "1FVKHC"
                  cStr += "F"
               else
                  cStr += "M"
               endif
               //cStr += SM3DATA->geslag //Replace on 14-01-22 12:54
               cStr += fId(SM3DATA->idnr,.t.)
               cStr += space(1)

               // Date in
               cData := dtos(SM3DATA->uitkdatum)
               cStr += right(cData,2)
               cStr += substr(cData,5,2)
               cStr += left(cData,4)

               // Official reason left herd
               if !empty(SM3WAAR->koof)
                  if SM3WAAR->koof $ "01z02z03z04"
                     cStr += SM3WAAR->koof
                  else
                     cStr += "03"
                  endif
               else
                  cStr += "03"
               endif

               // End of line
               cStr += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStr)

               if nLen != len(cStr)
                  fScrWBood(maxrow(),"File Write Error : "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif

            endif

         endif

         // Next record
         nCoun++
         select SM3VORE
         skip

      enddo

      // Close the file
      fclose(nHdel)

      // Test if file was created
      if !file(cFile)

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Skrappingslˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Cancellation file was not created!")
         endif

      else

         // Display note on the screen for removable medium
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam C"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Dekkingslˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name C"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing matings was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Skrappings epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Cancellations email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Skrappings Kennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Skrappings Kennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile + chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van skrappings vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Cancellation Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Cancellation Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic cancellation notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

