// SM3PRIN.PRG
// Program to handle static on printer codes
// Copyright (c) 1994 Tarragon Computing cc
// 07-28-94 01:44pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3prin(cAction,nItem,aValue)

   // Declare
   local aCscr      := NIL
   local aCdbf      := NIL
   static aPrinter  := NIL
   begin sequence

      // Initialize
      if empty(aPrinter)
         if empty(aValue)
            cAction := "Read"
         else
            aPrinter := aValue
            break
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
         aPrinter := STDWAAR->idform
         if empty(aPrinter)
            aPrinter := "1"
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
         nChoice := val(aPrinter)
         nChoice := fNewMenu(nChoice,"SM3IDFO")
         do case
            case nChoice == 1
               aPrinter := "1"
            case nChoice == 2
               aPrinter := "2"
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
         STDWAAR->idform := aPrinter

      elseif upper(cAction) == "WRITE"

         // Write the value to the .dbf if acceptable

         if aValue $ "12"

            // Open the file
            aCdbf := fATopen()
            aCdbf := fATopen(aCdbf,cDd(),"stdwaar")
            if !aCdbf[len(aCdbf),1]
               break
            endif

            // Save the value
            aPrinter := left(aValue,1)

            // Write the value
            do while !rlock()
            enddo
            STDWAAR->idform := aPrinter

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

return aPrinter
