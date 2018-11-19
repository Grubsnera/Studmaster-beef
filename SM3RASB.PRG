// Application: StudMaster for Beef Cattle
//   File Name: SM3RASB.PRG
// Description: Program to update breed file with Breedplan breed code
//   Copyright: (c) 2005 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 05-08-01 16:16

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3rasb(cRask,cVeld,cWaar)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFiel := 0
   begin sequence

      // Waardes
      cRask := if(cRask==NIL,"",cRask)
      cVeld := if(cVeld==NIL,"",cVeld)
      cWaar := if(cVeld==NIL,"",cWaar)

      altd()

      // Open dryfleer
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Vind die ras
      if empty(cRask)
         go bottom
         skip
      else
         locate for SM3RASS->raskod = cRask
      endif

      // Stoor die data
      nFiel := fieldpos(cVeld)
      if !empty(nFiel)
         do while !rlock()
         enddo
         fieldput(nFiel,cWaar)
      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
