// Application: StudMaster for Beef Cattle
//   File Name: STDFILE.PRG
// Description: Program to ask for a file
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-19-95 03:49pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "fileio.ch"

/******************************************************************************/
FUNCTION stdfile(cFile,lTest)

   // Declare
   local getlist := {}
   local cRetu := ""
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local nBoxc := 0
   local lLoop := .t.
   local nHand := 0
   begin sequence

      // Values
      cFile := iif(empty(cFile),"DATA.CSV",cFile)
      lTest := iif(empty(lTest),.t.,lTest)

      // Get the current drive
      cDriv := padr(cDd()+cFile,40)

      // The loop to ask the get
      lLoop := .t.
      do while lLoop

         // Ask for the drive letter
         if cLanType() = "A"
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow()  ,"Tik die volledige roete en lˆernaam!")
            nBoxc := fBoxCent(11,"Roete & Lˆernaam? "+space(40),3)
            @12,nBoxc say "Roete & Lˆernaam?" get cDriv pict "@!"
         else
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow()  ,"Type the complete path and file name!")
            nBoxc := fBoxCent(11,"Path & File name? "+space(40),3)
            @12,nBoxc say "Path & File name?" get cDriv pict "@!"
         endif
         setcursor(1)
         read
         setcursor(0)

         // If escaped
         if lastkey() == K_ESC
            break
         endif

         // If A: or B: drives
         if left(cDriv,2) $ "A:zB:"

            // Message to insert disk
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Plaas 'n disket in die "+left(cDriv,2)+" disketaandrywer!")
            else
               fScrBood(maxrow()-1,"Insert a diskette into the "+left(cDriv,2)+" disk drive!")
            endif
            fScrWait(maxrow())
            if lastkey() == K_ESC
               break
            endif

            // If test the existance of diskette
            if lTest

               // Create a file on disk to check it
               nHand := fcreate(trim(cDriv), FC_NORMAL)
               if ferror() == 0

                  // Erase the file and exit
                  ferase(trim(cDriv))
                  cRetu := trim(cDriv)
                  break

               else

                  // Display the write error
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Disketaandrywer is nie gereed nie! Rede: "+fFileError())
                  else
                     fScrBood(maxrow()-1,"Disk drive is not ready! Reason: "+fFileError())
                  endif
                  fScrWait(maxrow())

               endif

            else

               // Return drive letter - do not test if drive is ready
               cRetu := trim(cDriv)
               break

            endif

         elseif left(cDriv,3) $ "C:\zD:\zE:\zF:\zG:\zH:\zI:\zJ:\zK:\zL:\zX:\"

            // Hard drive file

            // If test the existance of diskette
            if lTest

               // Create a file on disk to check it
               nHand := fcreate(trim(cDriv), FC_NORMAL)
               if ferror() == 0

                  // Erase the file and exit
                  ferase(trim(cDriv))
                  cRetu := trim(cDriv)
                  break

               else

                  // Display the write error
                  if cLanType() == "A"
                     fScrBood(maxrow()-1,"Roete & Lˆernaam is nie toelaatbaar! Rede: "+fFileError())
                  else
                     fScrBood(maxrow()-1,"Path & File name are not allowed! Reason: "+fFileError())
                  endif
                  fScrWait(maxrow())

               endif

            else

               // Return drive letter - do not test if drive is ready
               cRetu := trim(cDriv)
               break

            endif

         else

            // Unacceptable drives
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Slegs dryfletters A: of B: is aanvaarbaar!")
            else
               fScrBood(maxrow()-1,"Only drive letters A: or B: is acceptable!")
            endif
            fScrWait(maxrow())

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return cRetu
