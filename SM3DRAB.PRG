// Application: StudMaster for Beef Cattle
//   File Name: SM3DRAB.PRG
// Description: Program ask single or group pd entries
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-03-95      11:25:41pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3drab

   // Declare
   local lRetu := .t.
   local nChoi := 1
   local aCscr := fASaveScr()
   begin sequence

      // Menu to ask single or season
      nChoi := fNewMenu(nChoi,"SM3DRAB")
      if nChoi == 1

         // Single entries
         sm3pres()

      elseif nChoi == 2

         // Calving season
         sm3preg()


      endif

   end
   // Reset
   fARestScr(aCscr)

return lRetu
