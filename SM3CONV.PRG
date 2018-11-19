// Application: StudMaster for Beef Cattle
//   File Name: SM3CONV.PRG
// Description: Program to convert version 3 data
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-23-94      06:42:43am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3conv

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local cFile := ""
   local lLoop := .t.
   local aMenu := {}
   begin sequence

      // Only do if version 3 files exist
      if file(cDd()+"sm3info.dbf")

         // Values
         cFile := cDd()+"STDWAAR.DBF"

         // Create STDWAAR.DBF if does not exist
         if !file(cFile)

            // Create data drive file if not exist
            copy file STDWAAR.tdb to (cFile)
            lNewFile(.t.)

         endif

         // Open drives file
         lLoop := .t.
         do while lLoop
            aCdbf := fATopen(aCdbf,cDd(),"STDWAAR",,,,.f.)
            if !aCdbf[len(aCdbf),1]
               asize(aCdbf,len(aCdbf)-1)
               if cLanType() == "A"
                  aMenu := {"Retry","Quit"}
                  if alert("STDWAAR.DBF lˆer kon nie geopen word nie!",aMenu) # 1
                     lRetu := .f.
                     break
                  endif
               else
                  aMenu := {"Retry","Quit"}
                  if alert("STDWAAR.DBF file could not be opened!",aMenu) # 1
                     lRetu := .f.
                     break
                  endif
               endif
            else
               lLoop := .f.
            endif
         enddo

         // Open file
         aCdbf := fATopen(aCdbf,cDd(),"SM3INFO")
         select STDWAAR
         if !aCdbf[len(aCdbf),1]
         else
            STDWAAR->genaam := SM3INFO->naam1
            STDWAAR->adres1 := SM3INFO->naam2
            STDWAAR->adres2 := SM3INFO->adres1
            STDWAAR->adres3 := SM3INFO->adres2
            STDWAAR->poskod := SM3INFO->poskode
            STDWAAR->prnorm := SM3INFO->ten
            STDWAAR->prcond := SM3INFO->sev
            STDWAAR->kudvvo := SM3INFO->kudvv
            STDWAAR->kudkkl := SM3INFO->kudkl
            STDWAAR->prelid := SM3INFO->prelid
            STDWAAR->streek := SM3INFO->prestreek
            STDWAAR->jaarle := SM3INFO->jaarletter
            STDWAAR->kalfbn := SM3INFO->kbnr
            STDWAAR->kalfbe := SM3INFO->kode64
            STDWAAR->kalfbl := SM3INFO->kode65
            STDWAAR->oudmaa := SM3INFO->oudmaand
            STDWAAR->raskod := SM3INFO->ras
         endif

      endif

   end

   // Reset
   if len(aCdbf) > 0
      fATclose(aCdbf)
   endif
   if file(cDd()+"SM3INFO.DBF")
      ferase(cDd()+"SM3INFO.DBF")
   endif

   // Other files
   if lNewFile()
      sm3crea()
      sm3load()
   endif

return lRetu
