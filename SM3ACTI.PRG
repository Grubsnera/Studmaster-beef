// Application: StudMaster for Beef Cattle
//   File Name: SM3ACTI.PRG
// Description: Program to change attention list standard values
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-19-95 10:30am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3acti

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local getlist := {}
   begin sequence

      // Open data file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Terug sonder om te bewaar")
         fScrBood(maxrow(),"Tik die aantal dae vir aksielys aksie waarskuwings." )
         nBoxc := fBoxCent(11,"Aantal dae 123",3)
         @12,nBoxc say "Aantal dae" get STDWAAR->dayact
      else
         fScrOpsk(,"Option "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Exit without changing")
         fScrBood(maxrow(),"Type the number of days to warn of attention list actions." )
         nBoxc := fBoxCent(11,"Number of days 123",3)
         @12,nBoxc say "Number of days" get STDWAAR->dayact
      endif

      // The read
      set(_SET_CURSOR,1)
      read
      set(_SET_CURSOR,0)

      // If entered
      if lastkey() == K_ENTER

         // Save the data

         // Cannot be zero - default to zero
         if empty(STDWAAR->dayact)
            STDWAAR->dayact := 7
         endif

         // Update the public
         nDayActi(STDWAAR->dayact)

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
