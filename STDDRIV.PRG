// Application: StudMaster for Beef Cattle
//   File Name: STDDRIV.PRG
// Description: Program to ask for a drive letter
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-24-95      09:13:07am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "fileio.ch"

/******************************************************************************/
FUNCTION stddriv(lTest)

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
      lTest := iif(empty(lTest),.t.,lTest)

      // Open the standard file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Get the current drive
      cDriv := STDWAAR->dryfle
      if cDriv $ " :  "
         cDriv := "A:"
      endif

      // The loop to ask the get
      lLoop := .t.
      do while lLoop

         // Ask for the drive letter
         if cLanType() = "A"
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow()  ,"Tik die letter van die disketaandrywer!")
            nBoxc := fBoxCent(11,"Disketaandrywer? x",3)
            @12,nBoxc say "Disketaandrywer?" get cDriv pict "!:"
         else
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow()  ,"Type the letter of the disk drive!")
            nBoxc := fBoxCent(11,"Disk drive? x",3)
            @12,nBoxc say "Disk drive?" get cDriv pict "!:"
         endif
         setcursor(1)
         read
         setcursor(0)

         // If escaped
         if lastkey() == K_ESC
            break
         endif

         // If A: or B: drives
         //if cDriv $ "A:zB:"

         // Save the drive letter
         if rlock()
            STDWAAR->dryfle := cDriv
            dbunlock()
         endif

         // Message to insert disk
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Plaas 'n disket in die "+cDriv+" disketaandrywer!")
         else
            fScrBood(maxrow()-1,"Insert a diskette into the "+cDriv+" disk drive!")
         endif
         fScrWait(maxrow())
         if lastkey() == K_ESC
            break
         endif

         // If test the existance of diskette
         if lTest

            // Create a file on disk to check it
            nHand := fcreate(cDriv+"\temp.txt", FC_NORMAL)
            if ferror() == 0

               // Erase the file and exit
               ferase(cDriv+"\temp.txt")
               cRetu := cDriv
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
            cRetu := cDriv
            break

         endif

         //else

         // Unacceptable drives
         //if cLanType() == "A"
         // fScrBood(maxrow()-1,"Slegs dryfletters A: of B: is aanvaarbaar!")
         //else
         // fScrBood(maxrow()-1,"Only drive letters A: or B: is acceptable!")
         //endif
         //fScrWait(maxrow())

         //endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return cRetu
