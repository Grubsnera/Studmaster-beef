// Application: StudMaster for Beef Cattle
//   File Name: STDDATA.PRG
// Description: Program to test data file structures
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-29-94      05:16:19am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stddata

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local aNews := {}

    if cLanType() == "A"
        fScrOpsk( 1, "Opsie "+cOption())
    else
        fScrOpsk( 1, "Option "+cOption())
    endif

   begin sequence

      // Open the fields file
      aCdbf := fATopen(aCdbf,,"STDFIEL",,"tdb")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      // Set order to field numbers
      ordsetfocus("FLDORDE")

      // Open the data files file
      aCdbf := fATopen(aCdbf,,"STDDBFS",,"tdb")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // Loop to get the file name to test
      select STDDBFS
      go top
      do while !eof()

         // Do for not empty file names
         if !empty(STDDBFS->dbfname)

            // Seek in the fields file
            select STDFIEL
            seek STDDBFS->dbfname
            if found()

               // Fill an array with file structure
               asize(aNews,0)
               dbeval({|| aadd(aNews,;
                  {trim(STDFIEL->fldname),;
                  STDFIEL->fldtype,;
                  STDFIEL->fldleng,;
                  STDFIEL->flddeci})},,;
                  {|| STDFIEL->dbfname==STDDBFS->dbfname})

               // Test the file structure
               if !stdconv(cDd(),;
                     trim(STDDBFS->dbfname),;
                     "DBF",;
                     aNews,;
                     trim(iif(cLanType()=="A",STDDBFS->dbfbesk,STDDBFS->dbfdesc)))
                  lRetu := .f.
                  break
               endif

            endif

         endif

         // Next
         select STDDBFS
         skip

      enddo

   end

   // Reset
   fATclose(aCdbf)

return lRetu
