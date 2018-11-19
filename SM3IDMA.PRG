// Application: StudMaster for Beef Cattle
//   File Name: SM3IDMA.PRG
// Description: Program to ask Id number format
//   Copyright: (c) 1997 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-30-97      07:32:00am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION SM3IDMA

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nChoi := val(cIdForm())
   local cMask := cIdMask()
   local nBoxc := 0

   begin sequence
      // Display the current selection
      if cLanType() == "A"
         fScrOpsk(1 ,"Opsie "+cOption())
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      else
         fScrOpsk(1 ,"Option "+cOption())
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      endif

      // Options
      nChoi := fNewMenu(nChoi,"SM3IDFO")
      if cLanType() == "A"
         fScrOpsk(1, "Opsie "+cOption(nChoi))
      else
         fScrOpsk(1, "Option "+cOption(nChoi))
      endif

      do case
         case nChoi == 1
            cIdForm("1")
            if cLanType() == "A"
               cIdMask("KKKKJJ-VVVV")
            else
               cIdMask("HHHHYY-SSSS")
            endif
         case nChoi == 2
            cIdForm("2")
            if cLanType() == "A"
               cIdMask("JJ-VVVVKKKK")
            else
               cIdMask("YY-SSSSHHHH")
            endif
         case nChoi == 3
            cIdForm("3")
         otherwise
            break
      endcase

      // Get the mask if other Id format
      if cIdForm() == "3"

         cMask := padr(cIdMask(),12)

         // Screen
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Terug sonder om te bewaar")
            fScrBood(maxrow(),"Watter formaat moet die Id nommer aanneem?" )
            nBoxc := fBoxCent(11,"Id nommer formaat "+space(12),3)
            @12,nBoxc say "Id nommer formaat" get cMask pict "@!" valid(fVmask(cMask))
         else
            fScrOpsk(,"Option "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Exit without changing")
            fScrBood(maxrow(),"Which format must the Id number be in?" )
            nBoxc := fBoxCent(11,"Id number format "+space(12),3)
            @12,nBoxc say "Id number format" get cMask pict "@!"
         endif

         // The read
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // If entered
         if lastkey() == K_ENTER
            if !empty(cMask)
               cIdMask(cMask)
            else
               cIdForm("1")
               if cLanType() == "A"
                  cIdMask("KKKKJJ-VVVV")
               else
                  cIdMask("HHHHYY-SSSS")
               endif
            endif
         else
            break
         endif

      endif

      // Open data file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Save the data
      STDWAAR->idform := cIdForm()
      STDWAAR->idmask := cIdMask()

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)
   cOption(-1)

return lRetu

/******************************************************************************/
STATIC FUNCTION fVMask(cMask)

   local aCscr := fASaveScr()
   local lRetu := .t.
   local i := 1

   for i := 1 to len(cMask)
      if substr(cMask,i,1) $ "HKYJSV-/. "
      else
         lRetu := .f.
      endif
   next

   // Warning
   if !lRetu
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Slegs een van die volgende karakters word toegelaat! (K)udde (J)aar (V)olg")
      else
         fScrBood(maxrow()-1,"Only the following characters are allowed! (H)erd (Y)ear (S)equence")
      endif
      fScrWait(maxrow())
   endif

   fARestScr(aCscr)

return lRetu
