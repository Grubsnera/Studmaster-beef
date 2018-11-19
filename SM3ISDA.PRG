// Application: StudMaster for Beef Cattle
//   File Name: SM3ISDA.PRG
// Description: Program to check for diary entries
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-29-94      12:42:02pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3isda

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local dDate := dAppDate() + nDayDiar()
   local nBoxc := 0
   begin sequence

      // See if index file exist
      if !file(cDd()+"SM3KALE"+ordbagext())
         lRetu := .f.
         break
      endif

      // Open diary file
      aCdbf := fATopen(aCdbf,cDd(),"SM3KALE")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // Search for today
      set soft on
      seek dtos(dAppDate())
      set soft off

      // If diary entries exist
      if SM3KALE->datum >= dAppDate() .and. SM3KALE->datum <= dDate
         fScrOpsk()
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            nBoxc := fBoxCent(11,space(50),3,"DAGBOEKINSKRYWING!!!")
            @12, nBoxc say "Daar is dagboekinskrywings in die volgende "+ltrim(str(nDayDiar(),3,0))+" dae!"
            if fJaNee(maxrow(),"Vertoon dagboekinskrywings?",,.f.)
               keyboard "GA"
            endif
         else
            nBoxc := fBoxCent(11,space(50),3,"DIARY ENTRY!!!")
            @12, nBoxc say "There are diary entries in the next 14 days!"
            if fJaNee(maxrow(),"Display diary entries?",,.f.)
               keyboard "GA"
            endif
         endif
      endif

   end

   // Reset
   fATclose(aCdbf)

return lRetu
