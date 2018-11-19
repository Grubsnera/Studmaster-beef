// Application: StudMaster for Beef Cattle
//   File Name: SM3WORD.PRG
// Description: Program to enter the wordpad directory
//   Copyright: (c) 1906 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-02-06      13:50:00

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3word

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local nHand := 0
   local lLoop := .t.
   local getlist := {}
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
            fScrBood(maxrow(),"Op watter plek is die WORDPAD.EXE program te vinde?" )
            nBoxc := fBoxCent(11,"Wordpad subgids "+space(40),3)
            @12,nBoxc say "Wordpad subgids" get STDWAAR->wordpd pict "@!@S40"
         else
            fScrOpsk(,"Option "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Exit without changing")
            fScrBood(maxrow(),"In which directory can WORDPAD.EXE be found?" )
            nBoxc := fBoxCent(11,"Wordpad subdirectory "+space(40),3)
            @12,nBoxc say "Wordpad subdirectory" get STDWAAR->wordpd pict "@!@S40"
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
            if !empty(STDWAAR->wordpd)

               // Complete the directory
               if right(alltrim(STDWAAR->wordpd),1) <> "\"
                  STDWAAR->wordpd := alltrim(STDWAAR->wordpd)+"\"
               endif

               // Create a file on disk to check it
               if file(alltrim(STDWAAR->wordpd)+"wordpad.exe")

                  // File exist

               else

                  // Display the write error
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Subgids nie korrek!")
                  else
                     fScrBood(maxrow()-1,"Incorrect subdirectory!")
                  endif
                  fScrWait(maxrow())
                  loop

               endif


            endif

            // Update the public
            cWordPad(alltrim(STDWAAR->wordpd))
            lLoop := .f.

         else

            // Save the data
            if !empty(STDWAAR->wordpd)

               // Complete the directory
               if right(alltrim(STDWAAR->wordpd),1) <> "\"
                  STDWAAR->wordpd := alltrim(STDWAAR->wordpd)+"\"
               endif

               // Create a file on disk to check it
               if file(alltrim(STDWAAR->wordpd)+"wordpad.exe")

                  // File exist

               else

                  // Display the write error
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Subgids nie korrek!")
                  else
                     fScrBood(maxrow()-1,"Incorrect subdirectory!")
                  endif
                  fScrWait(maxrow())
                  loop

               endif

            endif

            // Exit
            lLoop := .f.

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
