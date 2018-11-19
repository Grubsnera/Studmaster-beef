// Application: StudMaster for Beef Cattle
//   File Name: STDREGN.PRG
// Description: Program to change registered name
//   Copyright: (c) 2001 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 01-06-22 08:48

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdregn

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local lLoop := .t.
   local cName := space(40)
   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk(,"Lisensiehouer")
      else
         fScrOpsk(,"Licensed User")
      endif

      // Only registered programs
      if val(substr(cReeNomm(),4,5)) < 1
         if cLanType() == "A"
            nBoxc := fBoxCent(11,space(50),4,"Nota")
            @12,nBoxc say "Die Naam van die Lisensiehouer of Gebruiker kan nie"
            @13,nBoxc say "in die demonstrasieprogram verander word nie!"
            fScrBood(maxrow()-1)
            fScrWait(maxrow())
         else
            nBoxc := fBoxCent(11,space(50),4,"Note")
            @12,nBoxc say "The Name of the Licensed User cannot be changed in"
            @13,nBoxc say "the demonstration program!"
            fScrBood(maxrow()-1)
            fScrWait(maxrow())
         endif
         break
      endif

      // Notice to re-register the program
      if cLanType() == "A"
         nBoxc := fBoxCent(11,space(50),5,"Nota")
         @12,nBoxc say "Neem asseblief kennis dat indien die Naam van die  "
         @13,nBoxc say "Lisensiehouer verander word, die program weer      "
         @14,nBoxc say "geregistreer moet word!                            "
         fScrBood(maxrow()-1)
      else
         nBoxc := fBoxCent(11,space(51),4,"Note")
         @12,nBoxc say "Please note that you will have to re-register the  "
         @13,nBoxc say "program if you change the Name of the Licensed User!"
         fScrBood(maxrow()-1)
      endif

      // Ask to proceed or not
      if cLanType() == "A"
         if !(fJaNee( maxrow(), "Wil u voortgaan?"))
            break
         endif
      else
         if !(fJaNee( maxrow(), "Do you want to proceed?"))
            break
         endif
      endif

      // Loop to ask for the user name
      do while lLoop

         // Skerm
         if cLanType() == "A"
            fScrOpsk(,"Opsie "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow(), "Tik die Naam van die Lisensiehouer van die program.")
            nBoxc := fBoxCent(11,"Lisensiehouer? "+space(40),3,"Lisensiehouer")
         else
            fScrOpsk( , "Option "+cOption())
            fScrBood(maxrow()-1,"[Esc]=Menu")
            fScrBood(maxrow(), "Type the Name of the Licensed User.")
            nBoxc := fBoxCent(11,"Licensed User? "+space(40),3,"Licensed User")
         endif

         // Vra die reeksnommer
         setcolor(cColNorm())
         if cLanType() == "A"
            @ 12, nBoxc say "Lisensiehouer?" get cName
         else
            @ 12, nBoxc say "Licensed User?" get cName
         endif
         set cursor on
         read
         set curs off

         // Save the data
         if lastkey() == K_ENTER .and. !empty(cName)

            // Open the serial number file
            aCdbf := fATopen(aCdbf,,"SM3SERI",,"TDB","SM3SERI")
            if !aCdbf[len(aCdbf),1]
               break
            endif

            // Save the value
            cName := alltrim(cName)
            do while !rlock()
            enddo
            SM3SERI->userna := crypt(alltrim(cName),"userna")
            dbunlock()
            cRegNaam(cName)

            lLoop := .f.

         endif

         lLoop := .f.

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

   // Reset file dates etc
   setfdati("SM3SERI.TDB",filedate(exename()),filetime(exename()))

return lRetu
