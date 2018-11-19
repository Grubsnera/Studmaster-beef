// Application: StudMaster for Beef Cattle
//   File Name: SM3PADI.PRG
// Description: Function to set palmtop directory
//   Copyright: (c) 1919 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-08-19      14:43:25

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3padi

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lLoop := .t.
   local nBoxc := 0

   begin sequence

      // Open data file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Loop
      do while lLoop

         // Screen
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Terug sonder om te bewaar")
            fScrBood(maxrow(),"Op watter plek is die PALMTOP lˆers te vinde?" )
            nBoxc := fBoxCent(11,"Palmtop subgids "+space(40),3)
            @12,nBoxc say "Palmtop subgids" get STDWAAR->palmdi pict "@!@S40"
         else
            fScrOpsk(,"Option "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Exit without changing")
            fScrBood(maxrow(),"In which directory can the PALMTOP files be found?" )
            nBoxc := fBoxCent(11,"Palmtop subdirectory "+space(40),3)
            @12,nBoxc say "Palmtop subdirectory" get STDWAAR->palmdi pict "@!@S40"
         endif

         // The read
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // If entered
         if lastkey() == K_ESC
            exit
         endif

         if lastkey() == K_ENTER

            // Save the data
            if !empty(STDWAAR->palmdi)

               // Complete the directory
               if right(alltrim(STDWAAR->palmdi),1) == "\"
                  STDWAAR->palmdi := left(alltrim(STDWAAR->palmdi),len(alltrim(STDWAAR->palmdi))-1)
               endif

               // See if directory already exist
               if o_direxist(alltrim(STDWAAR->palmdi))
                  // Directory already exist
                  // Exit
               else
                  // Make a new directory
                  if o_md(alltrim(STDWAAR->palmdi))
                     // Could create a new directory
                  else
                     // Fault - no directory could be created
                     if cLanType() == "A"
                        fScrBood(maxrow()-1,"Die PALMTOP subgids  kon nie geopen word nie. Rede onbekend!" )
                     else
                        fScrBood(maxrow()-1,"The PALMTOP directory could not be created. Reason unknown!" )
                     endif
                     fScrWait(maxrow())
                     loop
                  endif
               endif

            else
               STDWAAR->palmdi := "C:\MBDATA"
               loop
            endif

            // Update the public
            cPalmDir(alltrim(STDWAAR->palmdi))
            lLoop := .f.

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
