// Application: StudMaster for Beef Cattle
//   File Name: STDINDX.PRG
// Description: Program to create index files
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-29-94      06:24:41am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdindx

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local aCdbf := fATopen()
   local nReko := 0
   local aNdbf := {}
   private cExpr := ""
   private cCond := ""
   private cUniq := ""

    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   begin sequence

      // Screen
      fScrBood(maxrow()-1)

      // Open the fields file
      aCdbf := fATopen(aCdbf,,"STDNTXS",,"tdb")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

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
            select STDNTXS
            seek STDDBFS->dbfname
            if found()

               // Do not open the index file automatically
               cmxAutoOpen(.f.)

               // Open the data file to be indexed
               aNdbf := fATopen(aNdbf,cDd(),trim(STDDBFS->dbfname),,,,.f.)

               // Open the index file automatically
               cmxAutoOpen(.t.)

               // If error trying to open file
               if !aNdbf[len(aNdbf),1]
                  lRetu := .f.
                  break
               endif

               // Erase the current index file
               ferase(cDd()+trim(STDDBFS->dbfname)+ordBagExt())

               // Loop to create the index file
               select STDNTXS
               do while STDNTXS->dbfname == STDDBFS->dbfname

                  // Screen
                  if cLanType() == "A"
                     fScrWbood(maxrow(),trim(STDNTXS->ntxbesk)+" indekslˆer word geskep")
                  else
                     fScrWbood(maxrow(),trim(STDNTXS->ntxdesc)+" index file being created")
                  endif

                  // Select file to be indexed
                  select (trim(STDDBFS->dbfname))

                  // Create the index
                  cExpr := trim(STDNTXS->ntxexpr)
                  cCond := trim(STDNTXS->ntxcond)
                  cUniq := trim(STDNTXS->ntxuniq)
                  if !empty(cUniq)
                     set(_SET_UNIQUE,.t.)
                  endif
                  if empty(STDNTXS->ntxcond)
                     index on &cExpr tag (trim(STDNTXS->ntxname)) eval ntxprogress(recno(),lastrec()) every 200
                  else
                     index on &cExpr tag (trim(STDNTXS->ntxname)) for &cCond eval ntxprogress(recno(),lastrec()) every 200
                  endif
                  set(_SET_UNIQUE,.f.)

                  // Next
                  select STDNTXS
                  skip

               enddo

               // Close the file that was indexed
               fATclose(aNdbf)
               asize(aNdbf,0)

            endif

         endif

         // Next
         select STDDBFS
         skip

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION ntxprogress(nReko,nAant)

   // Function to display index creation progress

   // Declare
   local lRetu := .t.

   // Do not show if less than 200 records
   if nAant < 200
      fScrBood(maxrow()-1)
   else
      if cLanType() == "A"
         fScrBood(maxrow()-1,fPercent(nReko,nAant)+"% Voltooi")
      else
         fScrBood(maxrow()-1,fPercent(nReko,nAant)+"% Completed")
      endif
   endif

return lRetu
