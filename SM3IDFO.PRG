// Application: StudMaster for Beef Cattle
//   File Name: SM3IDFO.PRG
// Description: Program to handle static on id number format
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-20-94      05:18:34am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3idfo(cAction,cValue)

   // Declare
   local aCscr      := NIL
   local aCdbf      := NIL
   local nChoice    := 1
   static cIdFormat := NIL
   begin sequence

      // Initialize
      if empty(cIdFormat)
         if empty(cValue)
            cAction := "Read"
         else
            if cValue $ "123"
               cIdFormat := left(cValue,1)
               break
            else
               cAction := "Read"
            endif
         endif
      endif

      // Actions
      if empty(cAction)

         // Return the current value

      elseif upper(cAction) == "READ"

         // Read the value from the .dbf

         // Open the file
         aCdbf := fATopen()
         aCdbf := fATopen(aCdbf,cDd(),"stdwaar")
         if !aCdbf[len(aCdbf),1]
            break
         endif

         // Read the value
         cIdFormat := STDWAAR->idform
         if empty(cIdFormat)
            cIdFormat := "1"
         endif

      elseif upper(cAction) == "ASK"

         // Ask the value the write to the .dbf
         aCscr := fASavescr()

         // Screen
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
         endif

         // Options
         nChoice := val(cIdFormat)
         nChoice := fNewMenu(nChoice,"SM3IDFO")
         do case
            case nChoice == 1
               cIdFormat := "1"
            case nChoice == 2
               cIdFormat := "2"
            case nChoice == 3
               cIdFormat := "3"
            otherwise
               break
         endcase

         // Open the file
         aCdbf := fATopen()
         aCdbf := fATopen(aCdbf,cDd(),"stdwaar")
         if !aCdbf[len(aCdbf),1]
            break
         endif

         // Write the value
         do while !rlock()
         enddo
         STDWAAR->idform := cIdFormat

      elseif upper(cAction) == "WRITE"

         // Write the value to the .dbf if acceptable

         if cValue $ "123"

            // Open the file
            aCdbf := fATopen()
            aCdbf := fATopen(aCdbf,cDd(),"stdwaar")
            if !aCdbf[len(aCdbf),1]
               break
            endif

            // Save the value
            cIdFormat := left(cValue,1)

            // Write the value
            do while !rlock()
            enddo
            STDWAAR->idform := cIdFormat

         endif

      endif

   end

   // Reset
   if !empty(aCdbf)
      fATclose(aCdbf)
   endif
   if !empty(aCscr)
      fARestscr(aCscr)
   endif

return cIdFormat
