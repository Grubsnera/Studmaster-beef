// Application: StudMaster for Beef Cattle
//   File Name: SM3MAAD.PRG
// Description: Program to ask electronic mail defaults
//   Copyright: (c) 2005 Agricultural Data Control
//      Author: Albert van Rensburg
//  Created on: 05-08-10 10:47

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "fileio.ch"

/******************************************************************************/
FUNCTION sm3maad

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local nHand := 0
   local lLoop := .t.
   local getlist := {}
   begin sequence

      // Open data file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Loop
      do while lLoop

         // Screen
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Terug sonder om te bewaar")
            fScrBood(maxrow(),"Na watter epos adres moet elektroniese lˆers versend word?" )
            nBoxc := fBoxCent(11,"Epos adres "+space(40),3)
            @12,nBoxc say "Epos adres" get STDWAAR->mailad pict "@S40"
         else
            fScrOpsk(,"Option "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Exit without changing")
            fScrBood(maxrow(),"To which email address should files be mailed?" )
            nBoxc := fBoxCent(11,"Email address "+space(40),3)
            @12,nBoxc say "Email address" get STDWAAR->mailad pict "@S40"
         endif

         // The read
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // If entered
         if lastkey() == K_ESC
            exit
         endif

         if lastkey() == K_ENTER

            // Save the data

            // Update the public
            cMailAdd(alltrim(STDWAAR->mailad))
            lLoop := .f.

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
