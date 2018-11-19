// Application: StudMaster for Beef Cattle
//   File Name: SM3MAIL.PRG
// Description: Program to ask electronic mail defaults
//   Copyright: (c) 1996 by Q Data Consulting (Pty) Ltd, Q Farm Division
//      Author: Albert van Rensburg
//  Created on: 07-18-96 08:49am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "fileio.ch"

/******************************************************************************/
FUNCTION sm3mail

   // Declare
   local lRetu := .f.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local cFile := ""
   local cChar := ""
   local nSlas := 0
   local cDire := ""
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
            fScrBood(maxrow(),"Op watter plek moet elektroniese pos lˆers bewaar word?" )
            nBoxc := fBoxCent(11,"Elektroniese pos subgids "+space(30),3)
            @12,nBoxc say "Elektroniese pos subgids" get STDWAAR->mailta pict "@!@S30"
         else
            fScrOpsk(,"Option "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Exit without changing")
            fScrBood(maxrow(),"In which directory should electronic post be prepared?" )
            nBoxc := fBoxCent(11,"Electronic post subdirectory "+space(30),3)
            @12,nBoxc say "Electronic post subdirectory" get STDWAAR->mailta pict "@!@S30"
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
            if !empty(STDWAAR->mailta)

               // Complete the directory
               if right(alltrim(STDWAAR->mailta),1) <> "\"
                  STDWAAR->mailta := alltrim(STDWAAR->mailta)+"\"
               endif

               // Added to create subdirectories
               nSlas := 0
               cDire := ""
               cFile := alltrim(STDWAAR->mailta)
               do while !empty(cFile)
                  cChar := left(cFile,1)
                  cFile := right(cFile,len(cFile)-1)
                  if cChar == "\"
                     nSlas++
                     if nSlas > 1
                        // Create the directory
                        o_md(cDire)
                     endif
                  endif
                  cDire += cChar
               enddo

               // Create a file on disk to check it
               nHand := fcreate(alltrim(STDWAAR->mailta)+"test.txt", FC_NORMAL)
               if ferror() == 0

                  // Erase the file and exit
                  ferase(alltrim(STDWAAR->mailta)+"test.txt")

               else

                  // Display the write error
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Subgids nie korrek! Rede: "+fFileError())
                  else
                     fScrBood(maxrow()-1,"Incorrect subdirectory! Reason: "+fFileError())
                  endif
                  fScrWait(maxrow())
                  loop

               endif


            endif

            // Update the public
            cMailTar(alltrim(STDWAAR->mailta))
            lLoop := .f.

         else

            // Save the data
            if !empty(STDWAAR->mailta)

               // Complete the directory
               if right(alltrim(STDWAAR->mailta),1) <> "\"
                  STDWAAR->mailta := alltrim(STDWAAR->mailta)+"\"
               endif

               // Added to create subdirectories
               nSlas := 0
               cDire := ""
               cFile := alltrim(STDWAAR->mailta)
               do while !empty(cFile)
                  cChar := left(cFile,1)
                  cFile := right(cFile,len(cFile)-1)
                  if cChar == "\"
                     nSlas++
                     if nSlas > 1
                        // Create the directory
                        o_md(cDire)
                     endif
                  endif
                  cDire += cChar
               enddo

               // Create a file on disk to check it
               nHand := fcreate(alltrim(STDWAAR->mailta)+"test.txt", FC_NORMAL)
               if ferror() == 0

                  // Erase the file and exit
                  ferase(alltrim(STDWAAR->mailta)+"test.txt")

               else

                  // Display the write error
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Subgids nie korrek! Rede: "+fFileError())
                  else
                     fScrBood(maxrow()-1,"Incorrect subdirectory! Reason: "+fFileError())
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
