// Application: StudMaster for Beef Cattle
//   File Name: STDSERI.PRG
// Description: Function to change the programs serial number by writing the
//            : serial.txt file in the program directory
//   Copyright: (c) 1998 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 04-28-98      10:08:26am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdseri

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local nBoxc := 0
   local cSeri := space(10)

   begin sequence

      // Skerm
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow(), "Tik die reeksnommer van die program.")
         nBoxc := fBoxCent(11,"Reeksnommer? xxxxxxxxxx",3,"Reeksnommer")
      else
         fScrOpsk( , "Option "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow(), "Type the serial number of the program.")
         nBoxc := fBoxCent(11,"Serial number? xxxxxxxxxx",3,"Serial number")
      endif

      // Vra die reeksnommer
      setcolor(cColNorm())
      if cLanType() == "A"
         @ 12, nBoxc say "Reeksnommer?" get cSeri pict "@!"
      else
         @ 12, nBoxc say "Serial number?" get cSeri pict "@!"
      endif
      set cursor on
      read
      set curs off

      // Save the data
      if lastkey() == K_ENTER .and. !empty(cSeri)

         // Open the serial number file
         aCdbf := fATopen(aCdbf,,"SM3SERI",,"TDB","SM3SERI")
         if !aCdbf[len(aCdbf),1]
            break
         endif

         // Save the value
         cSeri := alltrim(cSeri)
         do while !rlock()
         enddo
         SM3SERI->sernum := crypt(alltrim(cSeri),"sernum")
         if cSeri == "SMA0000" .or. cSeri == "SME0000"
            // Empty the licensed user
            SM3SERI->userna := ""
         endif
         dbunlock()
         cReeNomm(cSeri)

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

   // Set the file date back to .exe date & time
   setfdati("sm3seri.tdb",filedate(exename()),filetime(exename()))

return lRetu
