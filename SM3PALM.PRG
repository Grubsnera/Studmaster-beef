// Application: StudMaster for Beef Cattle
//   File Name: SM3PALM.PRG
// Description: Program menu for palmtop
//   Copyright: (c) 1919 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-08-19      14:26:57

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3palm

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nCh   := 1
   begin sequence

      // Menu function display
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif

      do while .t.

         // Close all files
         dbcloseall()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Vorige menu")
         else
            fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Previous menu")
         endif

         // Kry opsienommer
         nCh := fNewMenu(nCh,"SM3PALM")
         aCscr := fASaveScr()
         if cLanType() == "A"
            fScrOpsk(1,"Opsie "+cOption(nCh))
         else
            fScrOpsk(1,"Option "+cOption(nCh))
         endif

         do case

            case nCh = 1
               // Receive births
               sm3parb()

            case nCh = 2
               // Receive weights
               sm3parw()

            case nCh = 3
               // Receive remarks
               sm3palr()

            otherwise

               // Exit
               cOption(-1)
               exit

         endcase

         // Reset screen
         fARestScr(aCscr)
         cOption(-1)

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
