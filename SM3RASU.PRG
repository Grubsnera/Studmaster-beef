// Application: StudMaster for Beef Cattle
//   File Name: SM3RASU.PRG
// Description: Program to update the breeds file
//   Copyright: (c) 1996 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-07-96      10:00:36am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3rasu

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cFild := cDd()+"SM3RASS.DBF"
   local cFilo := cDd()+"SM3RASS.OLD"
   local cFilt := "SM3RASS.tdb"

    if cLanType() == "A"
        fScrOpsk( 1, "Opsie "+cOption())
    else
        fScrOpsk( 1, "Option "+cOption())
    endif

   begin sequence

      // Copy the current file to an old file
      ferase(cFilo)
      copy file (cFild) to (cFilo)
      ferase(cFild)

      // Copy the temp file to the current file
      copy file (cFilt) to (cFild)

      // Open the new current file
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS",,,"NEW",.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Open the old file
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS",,"OLD","OLD",.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Loop the old file and transfer data to new file
      do while !eof()

         // Select the new file
         select NEW
         locate for NEW->rasnaa == OLD->rasnaa
         if !eof()

            // Update the new file from the old file
            if !empty(OLD->kalfst)
               NEW->kalfst := OLD->kalfst
            endif
            if !empty(OLD->kalfge)
               NEW->kalfge := OLD->kalfge
            endif
            if !empty(OLD->identi)
               NEW->identi := OLD->identi
            endif
            if !empty(OLD->subafd)
               NEW->subafd := OLD->subafd
            endif
            if !empty(OLD->tipies)
               NEW->tipies := OLD->tipies
            endif
            if !empty(OLD->oudeer)
               NEW->oudeer := OLD->oudeer
            endif
            if !empty(OLD->rustyd)
               NEW->rustyd := OLD->rustyd
            endif
            if !empty(OLD->nordra)
               NEW->nordra := OLD->nordra
            endif
            if !empty(OLD->mindra)
               NEW->mindra := OLD->mindra
            endif
            if !empty(OLD->makdra)
               NEW->makdra := OLD->makdra
            endif
            if !empty(OLD->siklus)
               NEW->siklus := OLD->siklus
            endif
            if !empty(OLD->daedra)
               NEW->daedra := OLD->daedra
            endif
            if !empty(OLD->headbn)
               NEW->headbn := OLD->headbn
            endif
            if !empty(OLD->headcl)
               NEW->headcl := OLD->headcl
            endif
            if !empty(OLD->headil)
               NEW->headil := OLD->headil
            endif
            if !empty(OLD->headtl)
               NEW->headtl := OLD->headtl
            endif
            if !empty(OLD->headdl)
               NEW->headdl := OLD->headdl
            endif
            if !empty(OLD->dratip)
               NEW->dratip := OLD->dratip
            endif
            if !empty(OLD->breeds)
               NEW->breeds := OLD->breeds
            endif
            if !empty(OLD->breedp)
               NEW->breedp := OLD->breedp
            endif

         endif

         // Next breed
         select OLD
         skip

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
