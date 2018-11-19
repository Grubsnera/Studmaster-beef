// Application: StudMaster for Beef Cattle
//   File Name: SM3BSII.PRG
// Description: Program to import blup sire summary data
//   Copyright: (c) 1999 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 03-30-99      11:30:50am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3bsii

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local cPath := space(30)
   local cFile := space(8)
   local cExte := space(3)
   local cFull := ""
   local lBrea := .t.

   begin sequence

      // Build the file name
      // In this case is the breed number plus the word sire with dbf extention
      cPath := padr("A:\",30)
      cFile := padr("SIRES"+substr(cTotNaam(),149,3),8)
      cExte := padr("CSV",3)

      do while .t.

         lBrea := .f.

         // Paint the screen
         if cLanType() = "A"
            fScrOpsk(,"Opsie "+cOption())
            nBoxc := fBoxCent(11,space(50),5,"LEES VAAR TEELWAARDES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik die volledige lˆerbesonderhede.")
         else
            fScrOpsk(,"Option "+cOption())
            nBoxc := fBoxCent(11,space(50),5,"IMPORT SIRE BREEDING VALUES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow(),"Type file's particulars.")
         endif

         // Get the file name
         @ 12,nBoxc say " Roetbeskrywing" get cPath pict "@!"
         @ 13,nBoxc say "       Lˆernaam" get cFile pict "@!"
         @ 14,nBoxc say "Lˆeruitbreiding" get cExte pict "@!"
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // If escaped
         if lastkey() == K_ESC
            lBrea := .t.
            exit
         endif

         // Test the validity of the file name
         if right(alltrim(cPath),1) == "\"
         cFull := alltrim(cPath)+alltrim(cFile)+"."+alltrim(cExte)
         else
         cFull := alltrim(cPath)+"\"+alltrim(cFile)+"."+alltrim(cExte)
         endif
         if !file(alltrim(cFull))
            if cLanType() = "A"
               fScrBood(maxrow()-1,"Die lˆer "+cFull+" bestaan nie ?")
               fScrWait(maxrow())
            else
               fScrBood(maxrow()-1,"The file "+cFull+" does not exist ?")
               fScrWait(maxrow())
            endif
         else
            exit
         endif

      enddo

      // If escaped
      if lBrea
         break
      endif

      // Open the data files
      // File to update
      aCdbf := fATopen(aCdbf,cDd(),"SM3SIRE",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap

      // Screen
      if cLanType() = "A"
         fScrWbood(maxrow()-1,"Ras se vaaropsomming teelwaardes word gelees")
      else
         fScrWbood(maxrow()-1,"Breed's sire summary breeding values being read")
      endif

      // Impoert the data
      append from (alltrim(cFull)) deli

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow()-1,ltrim(str(recno()))+" Vaars se teelwaardes is gelees.")
      else
         fScrBood(maxrow()-1,ltrim(str(recno()))+" Sire breeding values were imported.")
      endif
      fScrWait(maxrow())

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
