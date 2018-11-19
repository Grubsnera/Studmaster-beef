// Application: StudMaster for Beef Cattle
//   File Name: SM3EDIT.PRG
// Description: Program to decide on the initial data entry screen
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-03-95      10:06:16pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION sm3edit

   // Declare
   local lRetu  := TRUE
   local aCscr  := {}
   local aCdbf  := fATopen()
   local nChoi  := 1
   local aVeld  := {}
   local aDisp  := {}
   local nKeus  := 1
   local cTest  := ""

   begin sequence

      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif

      // Loop to display the menu
      do while TRUE

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Vorige menu")
         else
            fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Previous menu" )
         endif

         // Display menu
         nChoi := fNewMenu(nChoi,"SM3EDIT")
         cOption(nChoi)
         aCscr := fASaveScr()

         do case

            case nChoi == 1
               // All information
               sm3alma()

            case nChoi == 2
               // Certain information
               cTest := ""
               asize(aVeld,0)
               aadd(aVeld,{"sm3seke","kode"})
               aadd(aVeld,{"sm3seke","besk"})
               aDisp := sm3seke(3,5,21,aVeld)

               // Carry on with routine
               if !empty(aDisp)

                  // Screen
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". [Esc]=Vorige menu" )
                  else
                     fScrBood(maxrow()-1,"Choose with "+D_DNARR+D_UPARR+" keys and press "+D_ENTER+". [Esc]=Previous menu" )
                  endif

                  // Display menu
                  nKeus := fNewMenu(nKeus,"SM3SEKG")
                  cOption(nKeus)

                  // The choices
                  do case
                     case nKeus == 1
                        // Single animals
                        sm3sekg(aDisp,cTest)

                     case nKeus == 2
                        // Group
                        // Ask the group
                        cTest := sm3groe()

                        if empty(cTest)
                           if cLanType() == "A"
                              fScrWait(maxrow(),"Geen groepvereistes is gespesifiseer nie!")
                           else
                              fScrWait(maxrow(),"No group requirements have been specified!")
                           endif
                        else
                           // Group of animals
                           sm3sekg(aDisp,cTest)
                        endif

                     case nKeus == 3

                        // Selection group

                        // Get the selection
                        cTest := sm3selg()

                        if empty(cTest)
                           if cLanType() == "A"
                              fScrWait(maxrow(),"Geen seleksievereistes is gespesifiseer nie!")
                           else
                              fScrWait(maxrow(),"No selection requirements have been specified!")
                           endif
                        else
                           // Selection group
                           sm3sekg(aDisp,cTest)
                        endif

                     case nKeus == 4
                        // Index group
                        // Get the selection
                        cTest := sm3indg()

                        if empty(cTest)
                           if cLanType() == "A"
                              fScrWait(maxrow(),"Geen indeksgroep is gespesifiseer nie!")
                           else
                              fScrWait(maxrow(),"No index group have been specified!")
                           endif
                        else
                           cTest := "SM3DATA->indekskode='"+cTest+"'"
                           // Selection group
                           sm3sekg(aDisp,cTest)
                        endif

                     case nKeus == 5
                        // Phase group
                        // Get the selection
                        cTest := sm3fasg()

                        if empty(cTest)
                           if cLanType() == "A"
                              fScrWait(maxrow(),"Geen fasegroep is gespesifiseer nie!")
                           else
                              fScrWait(maxrow(),"No phase group have been specified!")
                           endif
                        else
                           cTest := "SM3DATA->fasekode='"+cTest+"'"

                           // Selection group
                           sm3sekg(aDisp,cTest)
                        endif
                  endcase

                  cOption(-1)
               endif

            case nChoi == 3
               // Pedigree
               sm3stam()

            case nChoi == 4
               // Notes
               sm3note()

            otherwise
               cOption(-1)
               exit
         endcase

         fARestScr(aCscr)
         cOption(-1)
      enddo

   end

   // Reset
   fATclose(aCdbf)

return lRetu
