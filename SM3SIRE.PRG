// Application: StudMaster for Beef Cattle
//   File Name: SM3SIRE.PRG
// Description: Program to display sire summary
//   Copyright: (c) 1930 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-01-30      13:01:57

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3sire( nTop, nLeft, nBott, aSend, cFind )

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local nKeyp := 0
   local nCurr := 0
   local nReko := 0
   local cHead := ""
   local getlist := {}

   private cData := ""
   private cInde := ""
   private cFilt := ""
   private lUniq := .t.
   private lAsce := .t.

   begin sequence

      // Option menu
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif

      // Parameters
      nTop    := if( nTop  == NIL, 3, nTop  )
      nLeft   := if( nLeft == NIL, 2, nLeft )
      nBott   := if( nBott == NIL,21, nBott )
      if aSend == NIL
         aSend := {}
         aadd(aSend,{"sm3sire","id"       })
         aadd(aSend,{"sm3sire","regno"    })
         // aadd(aSend,{"sm3sire","order"    })
         aadd(aSend,{"sm3sire","bird"     })
         aadd(aSend,{"sm3sire","birdacc"  })
         aadd(aSend,{"sm3sire","birm"     })
         aadd(aSend,{"sm3sire","birmacc"  })
         aadd(aSend,{"sm3sire","wead"     })
         aadd(aSend,{"sm3sire","weadacc"  })
         aadd(aSend,{"sm3sire","weam"     })
         aadd(aSend,{"sm3sire","weamacc"  })
         aadd(aSend,{"sm3sire","yea"      })
         aadd(aSend,{"sm3sire","yeaacc"   })
         aadd(aSend,{"sm3sire","m18"      })
         aadd(aSend,{"sm3sire","m18acc"   })
         aadd(aSend,{"sm3sire","adg"      })
         aadd(aSend,{"sm3sire","adgacc"   })
         aadd(aSend,{"sm3sire","fcr"      })
         aadd(aSend,{"sm3sire","fcracc"   })
         aadd(aSend,{"sm3sire","klb"      })
         aadd(aSend,{"sm3sire","klbacc"   })
         aadd(aSend,{"sm3sire","scr"      })
         aadd(aSend,{"sm3sire","scracc"   })
         aadd(aSend,{"sm3sire","shd"      })
         aadd(aSend,{"sm3sire","shdacc"   })
      endif

      // Veldbeskrywings
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrWbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField( aSend )

      // Open datalˆers
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Datalˆers word geopen")
      else
         fScrWbood(24,"Data files being opened")
      endif

      aCdbf := fATOpen(aCdbf,cDd(),"SM3SIRE")
      if ! aCdbf[len(aCdbf),1]
         fATClose(aCdbf)
         break
      endif

      // Kry die breedte van venster
      for i = 1 to len(aRecv)
         //Lengte
         nScrl := nScrl + aRecv[i,4] + 1
         //Kolomme
         cData := aRecv[i,1] + aRecv[i,2]
         cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
      next

      // Bepaal regterkantste lyn
      nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

      // Skerm
      // Teken die box
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
         fBox( nTop, nLeft, nBott, nRigh, "BLUP VAAROPSOMMING" )
      else
         fScrOpsk( ,"Option "+cOption())
         fBox( nTop, nLeft, nBott, nRigh, "BLUP SIRE SUMMARY" )
      endif
      setcolor( cColNorm() )

      //Bou die tBrowse
      bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      //Plaas kolomme oor na die browse object
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Freeze
      bBrow:freeze := 3

      // Main loop
      do while .t.

         // Skerm
         if cLanType() == "A"
            fScrBood( 23, "[ Esc]=Menu  [AltF]=Filter " )
            fScrBood( 24, "             [AltS]=Sorteer" )
         else
            fScrBood( 23, "[ Esc]=Menu  [AltF]=Filter" )
            fScrBood( 24, "             [AltS]=Sort  " )
         endif

         FullStabilize(bBrow)
         // Stabilize the display until it's stable or a key is pressed

         if bBrow:stable
            nKeyp := InKey(0)
         endif

         if nKeyp == K_ESC
            // Esc means leave
            break
         endif

         if nKeyp == K_ALT_S
            // Alt S means sort
            cInde := ""
            if fSort(aRecv,bBrow:colpos)
               bBrow:refreshall()
            endif
         endif

         if nKeyp == K_ALT_F
            // Alt F means filter
            if fFilter(aRecv)
               bBrow:refreshall()
            endif
         endif

         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fSort(aRecv,nMenu)

   // Funksie om leer te sorteer

   // Verklaar
   local cCscr := savescreen(0,0,24,79)
   local i     := 1
   local nBoxc := 1
   local aMenu := {}
   local cText := ""
   local cNeg  := ""
   local cdata := ""
   local cIndf := cDd()+"sm3sirs"+ordbagext()
   local nReko := 1
   local cMenuCol := IIF( cMenuCol==NIL, cColMenu(), cMenuCol )
   local aKeys := {{K_ALT_F10,{|a,n,o,i| IIF(a[n,1] == " ", a[n,1]:=CHR(++i), NIL), o:RefreshCurrent() }},;
      {K_ALT_F9, {|a,n,o,i| IIF(a[n,1] != " ", fReset(a,ASC(a[n,1])), NIL), IIF(a[n,1] != " ", IIF(i > 48, i--, i := 48), NIL), a[n,1]:=" ", o:RefreshAll() }}}

   //Waardes
   nMenu := if(nMenu==NIL,1,nMenu)
   //cInde := if(cInde==NIL,"",cInde)
   //cFilt := if(cFilt==NIL,"",cFilt)
   //lUniq := if(lUniq==NIL,.t.,lUniq)

   // Display menu
   if empty(cInde)

      lAsce := .t.

      // Bou die menu om te vertoon
      for i = 1 to len(aRecv)
         aadd(aMenu,{" ",padr(ltrim(aRecv[i,FLD_DESC]),20),i})
      next

      // Vertoon die menu
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Los net so")
         fScrBood(24,"[Alt-F10]=Merk   [Alt-F9]=Verwyder Merk")
      else
         fScrBood(23,"[Esc]=Leave as is")
         fScrBood(24,"[Alt-F10]=Mark   [Alt-F9]=Remove Mark")
      endif

      if cLanType() == "A"
         nMenu := LPICKLIST(aMenu,06,15,22,65,{1,2},"Merk veld(e) waarop gesorteer moet word...",aKeys,,,cMenuCol)
      else
         nMenu := LPICKLIST(aMenu,06,15,22,65,{1,2},"Mark field(s) on which to sort...",aKeys,,,cMenuCol)
      endif

      if nMenu = nil .or. nMenu = 0
         restscreen(0,0,24,79,cCscr)
         return .f.
      endif

      ASORT(aMenu,,, { |x,y| x[1] < y[1] })

   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Data word gesorteer")
   else
      fScrWbood(24,"Data being sorted")
   endif

   // Databasis
   select SM3SIRE
   dbclearindex()
   go top

   // Vul databasis met sorteerveld
   do while !eof()

      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say fPercent(nReko,lastrec())+"% Voltooi"
      else
         @23,35 say fPercent(nReko,lastrec())+"% Completed"
      endif
      setcolor(cColNorm())
      nReko++
      do while !rlock()
      enddo
      SM3SIRE->sort := ""
      cData := ""

      // Build sort field ito menu
      if empty(cInde)

         // Kies die regte databasis
         for i := 1 TO LEN(aMenu)

            if aMenu[i,1] != " "

               cText := aRecv[aMenu[i,3],DBF_NAME]
               cText := strtran(cText,"->")
               cText := alltrim(cText)
               select select(cText)

               do case

                  case aRecv[aMenu[i,3],FLD_TYPE] == "C" //Character
                     cData += padr(fieldget(aRecv[aMenu[i,3],FLD_NUMB]),aRecv[aMenu[i,3],FLD_LENG])

                  case aRecv[aMenu[i,3],FLD_TYPE] == "N" //Numeric
                     cData += right( str( 1000000 + (fieldget(aRecv[aMenu[i,3],FLD_NUMB]) - 100000) ) ,12)

                  case aRecv[aMenu[i,3],FLD_TYPE] == "D" //Date
                     cData += padr(dtos(fieldget(aRecv[aMenu[i,3],FLD_NUMB])),8)

                  otherwise                      //Nie een van bogenoemde
                     cData += SM3SIRE->id

               endcase

            endif

         next

      else

         // Fill sort field ito nominated field in cInde

         if cInde == "id"
            cData := fieldget(fieldpos("id"))
         else
            cData := right( str( 1000000 + (fieldget(fieldpos(cInde)) - 100000) ) ,12)
         endif

      endif

      select SM3SIRE
      SM3SIRE->sort := cData+SM3SIRE->id
      skip

   enddo

   select SM3SIRE
   go top

   // Bou indeks
   if empty(cFilt)

      // No filter

      if lUniq

         if lAsce

            // Unique index
            index on SM3SIRE->sort to (cIndf) unique

         else

            // Unique index
            index on SM3SIRE->sort to (cIndf) unique desc

         endif


      else

         if lAsce

            // Include all record index
            index on SM3SIRE->sort to (cIndf)

         else

            // Include all record index
            index on SM3SIRE->sort to (cIndf) desc

         endif


      endif

   else

      // Set filter

      if lUniq

         if lAsce

            // Unique index
            index on SM3SIRE->sort to (cIndf) unique for &cFilt.

         else

            // Unique index
            index on SM3SIRE->sort to (cIndf) unique for &cFilt. desc

         endif

      else

         if lAsce

            // Include all record index
            index on SM3SIRE->sort to (cIndf) for &cFilt.

         else

            // Include all record index
            index on SM3SIRE->sort to (cIndf) for &cFilt. desc

         endif

      endif

   endif

   select SM3SIRE
   //dbclearindex()
   //dbsetindex(cIndf)
   go top

   restscreen(0,0,24,79,cCscr)

return .t.

/******************************************************************************/
STATIC FUNCTION fFilter(aRecv)

   // Function to display only selected animals

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nChoi := 1
   local nPoli := 2
   local lSele := .t.
   local nMinn := 0
   local nMaxx := 0
   local nAccu := 0

   begin sequence

      // Display menu of which animals to filter
      if cLanType() == "A"
         fScrBood(maxrow()-1, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Lys van vaars." )
      else
         fScrBood(maxrow()-1, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=List of sires." )
      endif
      nChoi := fNewMenu( nChoi, "SM3SIREF" )

      do case

         case nChoi = 1

            // All animals - remove filter

            cInde := "id"
            cFilt := ""
            lUniq := .t.
            lAsce := .t.
            break

         case nChoi = 2

            // Breeding policy

            // Menu to ask which policy
            fARestScr(aCscr)
            if cLanType() == "A"
               fScrBood(maxrow()-1, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + "." )
            else
               fScrBood(maxrow()-1, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + "." )
            endif
            nPoli := fNewMenu( nPoli, "SM3SIREP" )

            // Open the policy file
            aCdbf := fATOpen(aCdbf,cDd(),"SM3POLI")
            if ! aCdbf[len(aCdbf),1]
               fATClose(aCdbf)
               break
            endif

            // Goto to the corresponding record
            if nPoli >= 1 .and. nPoli <= 4
               goto nPoli
            else
               break
            endif

            // Loop the animals
            select SM3SIRE
            set index to
            go top
            do while !eof()

               // Unmark the animal
               do while !rlock()
               enddo
               SM3SIRE->mark := ""

               // Birdir
               if SM3POLI->birdirs == "X" .and. lSele == .t.
                  nMinn := iif(empty(SM3POLI->birdirm),-9999.99,SM3POLI->birdirm)
                  nMaxx := iif(empty(SM3POLI->birdirx),99999.99,SM3POLI->birdirx)
                  nAccu := SM3POLI->birdira
                  if !empty(nAccu)
                     if SM3SIRE->bird >= nMinn .and. SM3SIRE->bird <= nMaxx .and. SM3SIRE->birdacc >= nAccu
                     else
                        lSele := .f.
                     endif
                  else
                     if SM3SIRE->bird >= nMinn .and. SM3SIRE->bird <= nMaxx
                     else
                        lSele := .f.
                     endif
                  endif
               endif

               // Birmat
               if SM3POLI->birmats == "X" .and. lSele == .t.
                  nMinn := iif(empty(SM3POLI->birmatm),-9999.99,SM3POLI->birmatm)
                  nMaxx := iif(empty(SM3POLI->birmatx),99999.99,SM3POLI->birmatx)
                  nAccu := SM3POLI->birmata
                  if empty(nAccu)
                     if SM3SIRE->birm >= nMinn .and. SM3SIRE->birm <= nMaxx .and. SM3SIRE->birmacc >= nAccu
                     else
                        lSele := .f.
                     endif
                  else
                     if SM3SIRE->birm >= nMinn .and. SM3SIRE->birm <= nMaxx
                     else
                        lSele := .f.
                     endif
                  endif
               endif

               // Weadir
               if SM3POLI->weadirs == "X" .and. lSele == .t.
                  nMinn := iif(empty(SM3POLI->weadirm),-9999.99,SM3POLI->weadirm)
                  nMaxx := iif(empty(SM3POLI->weadirx),99999.99,SM3POLI->weadirx)
                  nAccu := SM3POLI->weadira
                  if !empty(nAccu)
                     if SM3SIRE->wead >= nMinn .and. SM3SIRE->wead <= nMaxx .and. SM3SIRE->weadacc >= nAccu
                     else
                        lSele := .f.
                     endif
                  else
                     if SM3SIRE->wead >= nMinn .and. SM3SIRE->wead <= nMaxx
                     else
                        lSele := .f.
                     endif
                  endif
               endif

               // Weamat
               if SM3POLI->weamats == "X" .and. lSele == .t.
                  nMinn := iif(empty(SM3POLI->weamatm),-9999.99,SM3POLI->weamatm)
                  nMaxx := iif(empty(SM3POLI->weamatx),99999.99,SM3POLI->weamatx)
                  nAccu := SM3POLI->weamata
                  if !empty(nAccu)
                     if SM3SIRE->weam >= nMinn .and. SM3SIRE->weam <= nMaxx .and. SM3SIRE->weamacc >= nAccu
                     else
                        lSele := .f.
                     endif
                  else
                     if SM3SIRE->weam >= nMinn .and. SM3SIRE->weam <= nMaxx
                     else
                        lSele := .f.
                     endif
                  endif
               endif

               // Yeadir
               if SM3POLI->yeadirs == "X" .and. lSele == .t.
                  nMinn := iif(empty(SM3POLI->yeadirm),-9999.99,SM3POLI->yeadirm)
                  nMaxx := iif(empty(SM3POLI->yeadirx),99999.99,SM3POLI->yeadirx)
                  nAccu := SM3POLI->yeadira
                  if !empty(nAccu)
                     if SM3SIRE->yea >= nMinn .and. SM3SIRE->yea <= nMaxx .and. SM3SIRE->yeaacc >= nAccu
                     else
                        lSele := .f.
                     endif
                  else
                     if SM3SIRE->yea >= nMinn .and. SM3SIRE->yea <= nMaxx
                     else
                        lSele := .f.
                     endif
                  endif
               endif

               // M18dir
               if SM3POLI->m18dirs == "X" .and. lSele == .t.
                  nMinn := iif(empty(SM3POLI->m18dirm),-9999.99,SM3POLI->m18dirm)
                  nMaxx := iif(empty(SM3POLI->m18dirx),99999.99,SM3POLI->m18dirx)
                  nAccu := SM3POLI->m18dira
                  if !empty(nAccu)
                     if SM3SIRE->m18 >= nMinn .and. SM3SIRE->m18 <= nMaxx .and. SM3SIRE->m18acc >= nAccu
                     else
                        lSele := .f.
                     endif
                  else
                     if SM3SIRE->m18 >= nMinn .and. SM3SIRE->m18 <= nMaxx
                     else
                        lSele := .f.
                     endif
                  endif
               endif


               // Mark the animal
               if lSele
                  SM3SIRE->mark := "*"
               else
                  lSele := .t.
               endif

               // Next record
               select SM3SIRE
               skip

            enddo


            // Do the filter and sort
            cInde := "id"
            cFilt := "!empty(mark)"
            lUniq := .t.
            lAsce := .t.
            break

         case nChoi = 3

            // Birth direct
            cInde := "bird"
            cFilt := "trait = padr('Birth Direct',30)"
            lUniq := .f.
            lAsce := .t.
            break

         case nChoi = 4

            // Birth maternal
            cInde := "birm"
            cFilt := "trait = padr('Birth Maternal',30)"
            lUniq := .f.
            lAsce := .t.
            break

         case nChoi = 5

            // Wean direct
            cInde := "wead"
            cFilt := "trait = padr('Wean Direct',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 6

            // Wean maternal
            cInde := "weam"
            cFilt := "trait = padr('Wean Maternal',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 7

            // Year
            cInde := "yea"
            cFilt := "trait = padr('Year Old',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 8

            // 18 Months
            cInde := "m18"
            cFilt := "trait = padr('18 Months',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 9

            // Feed conversion ratio
            cInde := "fcr"
            cFilt := "trait = padr('Ph-C Feed Conversion Ratio',30)"
            lUniq := .f.
            lAsce := .t.
            break

         case nChoi = 10

            // Average daily gain
            cInde := "adg"
            cFilt := "trait = padr('Ph-D Average Daily Gain',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 11

            // Kleiber
            cInde := "klb"
            cFilt := "trait = padr('Ph-D Kleiber',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 12

            // Scrotum circumference
            cInde := "scr"
            cFilt := "trait = padr('Ph-D Scrotum Circumference',30)"
            lUniq := .f.
            lAsce := .f.
            break

         case nChoi = 13

            // Shoulder height
            cInde := "shd"
            cFilt := "trait = padr('Ph-D Shoulder Height',30)"
            lUniq := .f.
            lAsce := .f.
            break

      endcase

      cInde := ""
      lAsce := .t.

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

   // Display the sort
   if !empty(cInde)
      fSort(aRecv)
   endif


return lRetu
