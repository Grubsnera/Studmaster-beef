// Application: StudMaster for Beef Cattle
//   File Name: SM3DATU.PRG
// Description: Program to dates for year 2000 problem
//   Copyright: (c) 2001 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 01-05-08 09:04

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3datu

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local aNews := {}
   local i     := 0
   local dDate := ctod("")

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

               // Screen
               fScrBood(maxrow()-1,iif(cLantype()=="A","Datums word nagegaan en herstel","Dates being checked and corrected"))
               fScrBood(maxrow(),trim(iif(cLanType()=="A",STDDBFS->dbfbesk,STDDBFS->dbfdesc)))

               // Fill an array with file structure
               asize(aNews,0)
               dbeval({|| aadd(aNews,;
                  {trim(STDFIEL->fldname),;
                  STDFIEL->fldtype,;
                  STDFIEL->fldleng,;
                  STDFIEL->flddeci})},,;
                  {|| STDFIEL->dbfname==STDDBFS->dbfname})

               // Open the database file
               aCdbf := fATopen(aCdbf,cDd(),STDDBFS->dbfname,,,,.f.)
               if !aCdbf[len(aCdbf),1]
                  // Next file if cannot be opened
                  aCdbf := asize(aCdbf,len(aCdbf)-1)
                  select STDDBFS
                  skip
                  loop
               endif

               for i := 1 to len(aNews)

                  // If date field
                  if aNews[i,2] == "D"

                     do while !eof()

                        // Check the date
                        dDate := fieldget(i)
                        if !empty(dDate)
                           if year(dDate) >= 1900 .and. year(dDate) <= 1930
                              fieldput(i,ctod(left(dtoc(dDate),6)+"20"+right(dtoc(dDate),2)))
                           endif
                        endif

                        // Next record
                        skip

                     enddo

                  endif

               next

               // Delete old file
               dbclosearea()
               aCdbf := asize(aCdbf,len(aCdbf)-1)

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
