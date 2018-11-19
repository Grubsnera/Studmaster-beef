// Application: StudMaster for Beef Cattle
//   File Name: SM3SCAL.PRG
// Description: Program to launch scale menu
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 09-07-95      08:24:23am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3scal

   // Declare
   local aCscr := {}
   local nCh   := 1

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   do while TRUE
      // Close all files
      dbcloseall()

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Vorige menu")
      else
         fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Previous menu")
      endif

      // Kry opsienommer
      nCh := fNewMenu(nCh,"SM3SCAL")
      aCscr := fASaveScr()
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nCh))
      else
         fScrOpsk(1,"Option "+cOption(nCh))
      endif

      do case
         case nCh = 1
            // Trutest
            sm3trut()

         case nCh = 2
            // Ruddweigh - KD1
            sm3rudd()

         case nCh = 3
            // Libra - LS2
            sm3libr()

         case nCh = 4
            // Inventaurus
            //sm3inve()
            sm3bolu()

         case nCh = 5
            // Psion Handheld computer
            // sm3psion()
             sm3palm()

         otherwise
            // Exit
            cOption(-1)
            exit

      endcase

      // Reset screen
      fARestScr(aCscr)
      cOption(-1)
   enddo

return NIL
