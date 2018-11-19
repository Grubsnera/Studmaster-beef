// Application: StudMaster for Beef Cattle
//   File Name: SM3VOKL.PRG
// Description: Program to move feed conversion to kleiber
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 03-02-95      08:52:59am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3vokl

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()

    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   begin sequence
      // Open the data file
      fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The loop to change the data
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,SM3DATA->idnr+" "+fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi")
            fScrWbood(maxrow()  ,"Fase D bulle se voeromsetsyfers word geskuif na kleibersyfers")
         else
            fScrBood(maxrow()-1,SM3DATA->idnr+" "+fPercent(cmxkeyno(),cmxkeycount())+"% Cpmpleted")
            fScrWbood(maxrow()  ,"Phase D bull feed conversion data being moved to kleiber data")
         endif

         // The action
         if "D" $ SM3DATA->fasekode

            if empty(SM3DATA->kleiberi) .and. !empty(SM3DATA->voeromseti)

               do while !rlock()
               enddo

               SM3DATA->kleiber := SM3DATA->voeromset
               SM3DATA->kleiberi := SM3DATA->voeromseti
               SM3DATA->voeromseti := 0
               SM3DATA->voeromset := 0

            endif

         endif

         // Next record
         select SM3DATA
         skip

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
