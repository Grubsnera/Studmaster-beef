// Application: StudMaster for Beef Cattle
//   File Name: SM3ANMA.PRG
// Description: Program to produce an analitical mating report
//   Copyright: (c) 1996 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-18-96      03:27:43pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3anma

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   begin sequence



   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
