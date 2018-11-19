// Application: StudMaster for Beef Cattle
//   File Name: STDDATU.PRG
// Description: Program to ask todays date
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-22-94      07:22:30pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stddatu(dDate)

   // Declare
   local getlist := {}
   local lLoop := .t.
   local nBoxc := 0

   begin sequence

      // Screen
      fScrOpsk()

      // Loop to ask the date
      do while lLoop

         // The read
         if cLanType() == "A"
            nBoxc := fBoxCent( 12, "Vandag se datum? 1234567890" )
            fScrBood(maxrow()-1)
            fScrBood(maxrow(),"Tik vandag se datum in DD/MM/JJJJ formaat.")
            @ 12, nBoxc say "Vandag se datum?" get dDate
         else
            nBoxc := fBoxCent( 12, "Todays date? 1234567890" )
            fScrBood(maxrow()-1)
            fScrBood(maxrow(),"Type todays date in DD/MM/YYYY format.")
            @ 12, nBoxc say "Todays date?" get dDate
         endif
         set cent on
         set curs on
         read
         set curs off
         set cent off

         // The tests
         if lastkey() == K_ESC

            // Escaped
            dDate := ctod("")
            break

         elseif empty(dAppDate())

            // Empty not allowed
            if cLanType() == "A"
               fScrWait(maxrow(),"Vandag se datum is verpligtend!")
            else
               fScrWait(maxrow(),"Todays date is compulsory!")
            endif
            loop

         endif

         dAppDate(dDate)
         lLoop := .f.

      enddo

   end

return dDate
