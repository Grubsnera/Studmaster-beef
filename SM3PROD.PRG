// Application: StudMaster for Beef Cattle
//   File Name: SM3PROD
// Description: Program to calculate production
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-25-95 03:37pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3prod

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local lLoop := .t.
   local dDa1a := ctod("")
   local dDa1b := ctod("")
   local dDa2a := ctod("")
   local dDa2b := ctod("")
   local nPurn := 0
   local nPurm := 0
   local nPuri := 0
   local nSaln := 0
   local nSalm := 0
   local nSali := 0
   local nOpen := 0
   local nOpem := 0
   local nClon := 0
   local nClom := 0
   local nProd := 0
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nBlad := 1
   local cHdln := ""
   local getlist := {}

   begin sequence

      // Ask the data to be printed
      if cLanType() == "A"
		 fScrOpsk(,"Opsie "+cOption())
         nBoxc := fBoxCent(5,space(40),9,"PRODUKSIEVERSLAG")
      else
		 fScrOpsk(,"Option "+cOption())
         nBoxc := fBoxCent(5,space(40),9,"PRODUCTION REPORT")
      endif
      lLoop := .t.
      do while lLoop
         if cLanType() == "A"
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow()  ,"Tik die besonderhede soos verlang!")
            @ 6,nBoxc say "     Beginvoorraad begindatum" get dDa1a
            @ 7,nBoxc say "      Beginvoorraad einddatum" get dDa1b
            @ 9,nBoxc say "      Eindvoorraad begindatum" get dDa2a
            @10,nBoxc say "       Eindvoorraad einddatum" get dDa2b
            @12,nBoxc say "            Produksie-eenhede" get nProd pict "9999"
         else
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow()  ,"Type the required particulars!")
            @ 6,nBoxc say "  Opening stock starting date" get dDa1a
            @ 7,nBoxc say "    Opening stock ending date" get dDa1b
            @ 9,nBoxc say "  Closing stock starting date" get dDa2a
            @10,nBoxc say "    Closing stock ending date" get dDa2b
            @12,nBoxc say "             Production units" get nProd pict "9999"
         endif
         setcursor(1)
         read
         setcursor(0)

         // If escaped
         if lastkey() == K_ESC
            break
         endif

         // Tests
         if empty(dDa1b)
            dDa1b := dDa1a
         endif
         if empty(dDa2b)
            dDa2b := dDa2a
         endif

         if dDa1a > dDa2a .or. dDa1b > dDa2a
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Begindatums moet vroe‰r as die einddatum wees!")
            else
               fScrBood(maxrow()-1,"First dates should be earlier than the last date!")
            endif
            fScrWait(maxrow())
            loop
         endif

         if dDa1b < dDa1a .or. dDa2b < dDa2a
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Die vanaf datums moet vroe‰r as die tot datums wees!")
            else
               fScrBood(maxrow()-1,"The from dates should be earlier than the too dates!")
            endif
            fScrWait(maxrow())
            loop
         endif

         lLoop := .f.

      enddo

      // Open the data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3AANK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Count purchases
      if cLanType() == "A"
         fScrWbood(maxrow(),"Aankope word bereken")
      else
         fScrWbood(maxrow(),"Purchases being calculated")
      endif
      select SM3AANK
      go top
      do while !eof()

         // Screen
         if cmkeyno()%10 == 0
            if cLanType() == "A"
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Voltooi")
            else
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Completed")
            endif
         endif

         // Count if between boundaries
         if SM3AANK->datum >= dDa1a .and. SM3AANK->datum <= dDa2b
            nPurn++
            nPurm += SM3AANK->massa
            nPuri += SM3AANK->bedrag
         endif

         // Next record
         select SM3AANK
         skip

      enddo

      // Count sales
      if cLanType() == "A"
         fScrWbood(maxrow(),"Verkope word bereken")
      else
         fScrWbood(maxrow(),"Sales being calculated")
      endif
      select SM3VERK
      go top
      do while !eof()

         // Screen
         if cmkeyno()%10 == 0
            if cLanType() == "A"
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Voltooi")
            else
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Completed")
            endif
         endif

         // Count if between boundaries
         if SM3VERK->datum >= dDa1a .and. SM3VERK->datum <= dDa2b
            nSaln++
            nSalm += SM3VERK->massa
            nSali += SM3VERK->bedrag
         endif

         // Next record
         select SM3VERK
         skip

      enddo

      // Count stock
      if cLanType() == "A"
         fScrWbood(maxrow(),"Begin- en eindvoorraad word bereken")
      else
         fScrWbood(maxrow(),"Opening and closing stock being calculated")
      endif
      select SM3WEEG
      go top
      do while !eof()

         // Screen
         if cmkeyno()%100 == 0
            if cLanType() == "A"
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Voltooi")
            else
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Completed")
            endif
         endif

         // Count opening stock if between boundaries
         if SM3WEEG->weegdatum >= dDa1a .and. SM3WEEG->weegdatum <= dDa1b
            nOpen++
            nOpem += SM3WEEG->massa
         endif

         // Count closing stock if between boundaries
         if SM3WEEG->weegdatum >= dDa2a .and. SM3WEEG->weegdatum <= dDa2b
            nClon++
            nClom += SM3WEEG->massa
         endif

         // Next record
         select SM3WEEG
         skip

      enddo

      // Display
      if cLanType() == "A"
		 fScrOpsk(,"Opsie "+cOption())
         nBoxc := fBoxCent(6,space(60),14,"PRODUKSIE VIR DIE PERIODE "+dtoc(dDa1a)+" tot "+dtoc(dDa2b))
         @ 7,nBoxc say "                       Aantal      Kilogram          Bedrag"
         @ 8,nBoxc say "                       ------      --------      ----------"
         @ 9,nBoxc say "    Beginvoorraad     "
         @ 9,col()+1 say padl(alltrim(str(nOpen,6,0)),6)+"     "
         @ 9,col()+1 say padl(alltrim(str(nOpem,8,0)),8)
         @10,nBoxc say "        + Aankope     "
         @10,col()+1 say padl(alltrim(str(nPurn,6,0)),6)+"     "
         @10,col()+1 say padl(alltrim(str(nPurm,8,0)),8)+"     "
         @10,col()+1 say padl(alltrim(str(nPuri,10,2)),10)
         @11,nBoxc say "        - Verkope     "
         @11,col()+1 say padl(alltrim(str(nSaln,6,0)),6)+"     "
         @11,col()+1 say padl(alltrim(str(nSalm,8,0)),8)+"     "
         @11,col()+1 say padl(alltrim(str(nSali,10,2)),10)
         @12,nBoxc say "     Eindvoorraad     "
         @12,col()+1 say padl(alltrim(str(nClon,6,0)),6)+"     "
         @12,col()+1 say padl(alltrim(str(nClom,8,0)),8)+"     "
         @13,nBoxc say "                       ------      --------      ----------"
         @14,nBoxc say "        Produksie     "
         @14,col()+1 say space(6)+"     "
         @14,col()+1 say padl(alltrim(str( (nClom+nSalm)-(nOpem+nPurm) ,8,0)),8)
         @15,nBoxc say "          Eenhede     "
         @15,col()+1 say space(6)+"     "
         @15,col()+1 say padl(alltrim(str( nProd ,8,0)),8)
         @16,nBoxc say "                                   --------               "
         @17,nBoxc say "Produksie/Eenheid     "
         if nProd <= 0
            nProd := 1
         endif
         @17,col()+1 say space(6)+"     "
         @17,col()+1 say padl(alltrim(str( ((nClom+nSalm)-(nOpem+nPurm))/nProd ,8,1)),8)
         @18,nBoxc say "                                   ========               "
      else
		 fScrOpsk(,"Option "+cOption())
         nBoxc := fBoxCent(6,space(60),14,"PRODUCTION FOR THE PERIOD "+dtoc(dDa1a)+" to "+dtoc(dDa2b))
         @ 7,nBoxc say "                       Number      Kilogram          Amount"
         @ 8,nBoxc say "                       ------      --------      ----------"
         @ 9,nBoxc say "    Opening stock     "
         @ 9,col()+1 say padl(alltrim(str(nOpen,6,0)),6)+"     "
         @ 9,col()+1 say padl(alltrim(str(nOpem,8,0)),8)
         @10,nBoxc say "      + Purchases     "
         @10,col()+1 say padl(alltrim(str(nPurn,6,0)),6)+"     "
         @10,col()+1 say padl(alltrim(str(nPurm,8,0)),8)+"     "
         @10,col()+1 say padl(alltrim(str(nPuri,10,2)),10)
         @11,nBoxc say "          - Sales     "
         @11,col()+1 say padl(alltrim(str(nSaln,6,0)),6)+"     "
         @11,col()+1 say padl(alltrim(str(nSalm,8,0)),8)+"     "
         @11,col()+1 say padl(alltrim(str(nSali,10,2)),10)
         @12,nBoxc say "    Closing stock     "
         @12,col()+1 say padl(alltrim(str(nClon,6,0)),6)+"     "
         @12,col()+1 say padl(alltrim(str(nClom,8,0)),8)+"     "
         @13,nBoxc say "                       ------      --------      ----------"
         @14,nBoxc say "       Production     "
         @14,col()+1 say space(6)+"     "
         @14,col()+1 say padl(alltrim(str( (nClom+nSalm)-(nOpem+nPurm) ,8,0)),8)
         @15,nBoxc say "            Units     "
         @15,col()+1 say space(6)+"     "
         @15,col()+1 say padl(alltrim(str( nProd ,8,0)),8)
         @16,nBoxc say "                                   --------               "
         @17,nBoxc say "  Production/Unit     "
         if nProd <= 0
            nProd := 1
         endif
         @17,col()+1 say space(6)+"     "
         @17,col()+1 say padl(alltrim(str( ((nClom+nSalm)-(nOpem+nPurm))/nProd ,8,1)),8)
         @18,nBoxc say "                                   ========               "
      endif

      // Keypresses
      lLoop := .t.
      do while lLoop

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"[Esc ]=Menu")
            fScrBood(maxrow()  ,"[AltP]=Druk")
         else
            fScrBood(maxrow()-1,"[Esc ]=Menu ")
            fScrBood(maxrow()  ,"[AltP]=Print")
         endif

         // Wait
         inkey(0)

         // What to do
         do case

            case lastkey() == K_ESC

               // Escape

               lLoop := .f.

            case lastkey() == K_ALT_P

               // Print

               // Test availability of printer
               if fPrnReady(maxrow()-1) == K_ESC
                  loop
               endif

               // Screen
               fScrBood(maxrow()-1)
               if cLanType() == "A"
                  fScrWbood(maxrow(),"Produksieverslag word gedruk")
               else
                  fScrWbood(maxrow(),"Production report being printed")
               endif

               // Switch printer on
               fPrnOn()
               fPrnCod( cPrnNorm() )
      			nWidt := nPrnWidt()
      			nTopl := nPrnLine()
   				nMidc := nWidt - 29
               nBlad := 1

               // Heading
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
      				cHdln := "PRODUKSIE VIR DIE PERIODE "+dtoc(dDa1a)+" TOT "+dtoc(dDa2b)
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
      				cHdln := "PRODUCTION FOR THE PERIOD "+dtoc(dDa1a)+" TO "+dtoc(dDa2b)
               	@prow()  ,nWidt-len(cHdln)+1 say cHdln
            	endif
               @prow()+1,  1 say repl( "=", nWidt )

               // Data
               if cLanType() == "A"
                  @prow()+2,1 say "                       Aantal      Kilogram          Bedrag"
                  @prow()+1,1 say "                       ------      --------      ----------"
                  @prow()+1,1 say "    Beginvoorraad     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nOpen,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nOpem,8,0)),8)
                  @prow()+1,1 say "        + Aankope     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nPurn,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nPurm,8,0)),8)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nPuri,10,2)),10)
                  @prow()+1,1 say "        - Verkope     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nSaln,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nSalm,8,0)),8)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nSali,10,2)),10)
                  @prow()+1,1 say "     Eindvoorraad     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nClon,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nClom,8,0)),8)+"     "
                  @prow()+1,1 say "                       ------      --------      ----------"
                  @prow()+1,1 say "        Produksie     "
                  @prow()  ,pcol()+1 say space(6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str( (nClom+nSalm)-(nOpem+nPurm) ,8,0)),8)
                  @prow()+1,1 say "          Eenhede     "
                  @prow()  ,pcol()+1 say space(6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str( nProd ,8,0)),8)
                  @prow()+1,1 say "                                   --------               "
                  @prow()+1,1 say "Produksie/Eenheid     "
                  if nProd <= 0
                     nProd := 1
                  endif
                  @prow()  ,pcol()+1 say space(6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str( ((nClom+nSalm)-(nOpem+nPurm))/nProd ,8,1)),8)
                  @prow()+1,1 say "                                   ========               "
               else
                  @prow()+2,1 say "                       Number      Kilogram          Amount"
                  @prow()+1,1 say "                       ------      --------      ----------"
                  @prow()+1,1 say "    Opening stock     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nOpen,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nOpem,8,0)),8)
                  @prow()+1,1 say "      + Purchases     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nPurn,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nPurm,8,0)),8)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nPuri,10,2)),10)
                  @prow()+1,1 say "          - Sales     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nSaln,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nSalm,8,0)),8)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nSali,10,2)),10)
                  @prow()+1,1 say "    Closing stock     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nClon,6,0)),6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str(nClom,8,0)),8)+"     "
                  @prow()+1,1 say "                       ------      --------      ----------"
                  @prow()+1,1 say "       Production     "
                  @prow()  ,pcol()+1 say space(6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str( (nClom+nSalm)-(nOpem+nPurm) ,8,0)),8)
                  @prow()+1,1 say "            Units     "
                  @prow()  ,pcol()+1 say space(6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str( nProd ,8,0)),8)
                  @prow()+1,1 say "                                   --------               "
                  @prow()+1,1 say "  Production/Unit     "
                  if nProd <= 0
                     nProd := 1
                  endif
                  @prow()  ,pcol()+1 say space(6)+"     "
                  @prow()  ,pcol()+1 say padl(alltrim(str( ((nClom+nSalm)-(nOpem+nPurm))/nProd ,8,1)),8)
                  @prow()+1,1 say "                                   ========               "
               endif

               // Bottom
               @prow()+2, 1 say repl("=",nWidt)
               @prow()+1, 1 say cAppName()
               fPrnEjec()
               fPrnOff()

         endcase

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
