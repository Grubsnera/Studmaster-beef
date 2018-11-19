//SM3MAAN.PRG
//Program om maandouderdomme te bereken
//Kopiereg (c) 1993 A van Rensburg
//14:58 21 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//****************************************************************************/
FUNCTION sm3maan

   //Veranderlikes
   local cBood := ""
   local cVeeg := ""
   local cTabe := ""
   local cData := ""
   local cWeeg := ""
   local dData := ctod("")
   local cSeek := ""
   local nReko := 1
   local nTota := 1
   local nData := 0
   local lVeeg := .f.

   //Vra of veegetalle ook bereken moet word
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
      cBood := "Moet veegetalle bereken word?"
   else
      fScrOpsk(,"Option "+cOption())
      cBood := "Should stock count be done?"
   endif

   if fJaNee(24,cBood)
      cVeeg := fTOpen(cDd(),"sm3veeg",,,,.f.)
      if left(cVeeg,1) == "f"
         cVeeg := ""
         cTabe := ""
      else
         cTabe := fTOpen(cDd(),"sm3tabe",,,,.f.)
         if left(cTabe,1) == "f"
            cTabe := ""
         else
            //Maak skoon
            replace all SM3TABE->aantal with 0,;
               SM3TABE->geneni with 0,;
               SM3TABE->genef0 with 0,;
               SM3TABE->genef1 with 0,;
               SM3TABE->genef2 with 0,;
               SM3TABE->genef3 with 0,;
               SM3TABE->genef4 with 0,;
               SM3TABE->genef5 with 0,;
               SM3TABE->genesp with 0,;
               SM3TABE->aanmas with 0,;
               SM3TABE->totmas with 0,;
               SM3TABE->gemmas with 0
            go top
         endif
      endif
   endif

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif

   // Open the masses file
   cWeeg := fTOpen(cDd(),"sm3weeg",,,,.f.)
   if left(cWeeg,1) == "f"
      return NIL
   endif
   ordsetfocus(2)                                // to get latest weigh date

   cData := fTOpen(cDd(),"sm3data",,,,.f.)
   if left(cData,1) == "f"
      return NIL
   endif
   nTota := lastrec()

   // Set reations
   dbsetrelation("SM3WEEG",{|| SM3DATA->idnr },"SM3DATA->idnr")

   //Loop deur hele leer
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Maandouderdomme word bereken")
   else
      fScrWbood(24,"Month ages being calculated")
   endif
   do while !eof()

      if nTota > 0
         setcolor( cColBott() )
         if cLanType() == "A"
            @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
         else
            @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
         endif
         setcolor( cColNorm() )
         nReko++
      endif

      //Vat vandag se datum of datum uit kudde
      dData := dAppDate()
      if !empty(SM3DATA->uitkdatum)
         dData := SM3DATA->uitkdatum
      endif

      //Bereken en stoor ouderdom
      nData := int((dData - SM3DATA->gebdatum)/30.4375)
      if nData >= 0 .and. nData <= 999
         SM3DATA->mouderdom := nData
      else
         SM3DATA->mouderdom := 999
      endif

      //Bereken veegetalle
      if len(alltrim(cTabe)) > 0 .and. SM3DATA->uitkrede $ cWaarisd()
         cSeek := SM3DATA->geslag + str(SM3DATA->mouderdom,4,0)
         select SM3TABE
         set soft on
         seek cSeek
         set soft off

         //Gaan een terug
         if SM3DATA->mouderdom < SM3TABE->vanoud
            skip -1
         endif

         if SM3DATA->geslag == SM3TABE->geslag

            lVeeg := .t.
            //Bewaar aantal
            SM3TABE->aantal++
            //Bewaar generasies
            do case
               case SM3DATA->generasie $ "F zF0"
                  SM3TABE->genef0++
               case SM3DATA->generasie $ "F1z A "
                  SM3TABE->genef1++
               case SM3DATA->generasie $ "F2z B "
                  SM3TABE->genef2++
               case SM3DATA->generasie $ "F3z C "
                  SM3TABE->genef3++
               case SM3DATA->generasie $ "F4z D "
                  SM3TABE->genef4++
               case SM3DATA->generasie $ "F5z E "
                  SM3TABE->genef5++
               case SM3DATA->generasie $ "SP"
                  SM3TABE->genesp++
               otherwise
                  SM3TABE->geneni++
            endcase

            // Tel laaste massas bymekaar
            if SM3WEEG->massa > 0
               SM3TABE->aanmas++
               SM3TABE->totmas += SM3WEEG->massa
            endif

         endif
      endif

      //Escape
      if inkey() == K_ESC
         lVeeg := .f.
         select SM3DATA
         go bottom
      endif

      //Volgende
      select SM3DATA
      skip

   enddo

   //Bewaar veegetalle
   if lVeeg
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Veegetalle word bewaar")
      else
         fScrWbood(24,"Stock count figures being saved")
      endif
      select SM3TABE
      go top
      do while !eof()
         select SM3VEEG
         seek dtos(dAppDate())+"    0"
         if eof()
            append blank
            SM3VEEG->datumm := dAppDate()
            SM3VEEG->beskry := repl("-",20)
            SM3VEEG->geslag := " "
            SM3VEEG->vanoud := 0
         endif
         cSeek := dtos(dAppDate())+SM3TABE->geslag+str(SM3TABE->vanoud)
         seek cSeek
         if found()
            if SM3TABE->aantal <= 0
               delete
               go bottom
               skip
            endif
         else
            if SM3TABE->aantal <= 0
            else
               append blank
            endif
         endif

         //Bewaar
         SM3VEEG->datumm := dAppDate()
         SM3VEEG->beskry := SM3TABE->beskry
         SM3VEEG->vanoud := SM3TABE->vanoud
         SM3VEEG->geslag := SM3TABE->geslag
         SM3VEEG->aantal := SM3TABE->aantal
         SM3VEEG->waar01 := SM3TABE->waar01 * SM3TABE->aantal
         SM3VEEG->waar02 := SM3TABE->waar02 * SM3TABE->aantal
         SM3VEEG->waar03 := SM3TABE->waar03 * SM3TABE->aantal
         SM3VEEG->geneni := SM3TABE->geneni
         SM3VEEG->genef0 := SM3TABE->genef0
         SM3VEEG->genef1 := SM3TABE->genef1
         SM3VEEG->genef2 := SM3TABE->genef2
         SM3VEEG->genef3 := SM3TABE->genef3
         SM3VEEG->genef4 := SM3TABE->genef4
         SM3VEEG->genef5 := SM3TABE->genef5
         SM3VEEG->genesp := SM3TABE->genesp

         // Bewaar gemiddelde massa
         if SM3TABE->aanmas > 0 .and. SM3TABE->totmas > 0
            nData := SM3TABE->totmas / SM3TABE->aanmas
            if nData > 0 .and. nData  <= 9999
               SM3VEEG->gemmas := nData
            endif
         endif

         //Volgende
         select SM3TABE
         skip

      enddo
   endif

   //Herstel
   fTClose(cData)
   if len(alltrim(cTabe)) > 0
      fTClose(cVeeg)
      fTClose(cTabe)
   endif
return NIL

