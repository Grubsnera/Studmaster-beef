// Application: StudMaster for Beef Cattle
//   File Name: SM3BIMP.PRG
// Description: Program to display blup import submenu
//   Copyright: (c) 1999 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 03-30-99      10:54:00am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3bimp

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nChoi := 1
   local cBrep := ""
   begin sequence

      // Menu option display
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif

      // Loop to display the menu
      do while TRUE

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Vorige menu")
         else
            fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Previous menu" )
         endif

         // Display menu
         nChoi := fNewMenu(nChoi,"SM3BIMP")
         cOption(nChoi)
         aCscr := fASaveScr()

         do case

            case nChoi == 1
               // Import herd breeding values
               cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
               if cBrep $ "JYjy"
                  // Breedplan format
                  sm3bree()
               else
                  // Iris format
                  sm3blpi()
               endif

            case nChoi == 2
               // Import breed sire summary breeding values
               //sm3bsii()                         // Blup SIre Import
               // Import herd breeding values
               cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
               if cBrep $ "JYjy"
                  // Breedplan format
                  sm3bree()
               else
                  // Iris format
                  sm3blp2()
               endif

            otherwise
               cOption(-1)
               exit

         endcase

         fARestScr(aCscr)
         cOption(-1)

      enddo

   end

   // Reset
   // fARestScr(aCscr)

return lRetu
