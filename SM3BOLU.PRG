// Application: StudMaster for Beef Cattle
//   File Name: SM3BOLU.PRG
// Description: Program to read id numbers and masses from the bolus
//   Copyright: (c) 2000 Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 00-06-17 16:13

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION sm3bolu

   // Function to download data

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local aDire := {}
   local aFile := {}
   local cFile := ""
   local nChoi := 1
   local aDbfs := {}
   local dDate := ctod("")
   local i     := 0
   local nBoxc := 0
   local cMode := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      // Array of files
      if !file("bolus.txt")
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geen bolus massalˆers kon gevind word nie!")
         else
            fScrBood(maxrow()-1,"No bolus mass files could be found!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      cFile := "bolus.txt"

      // Create a temporary trutest file
      aDbfs := {}
      aadd(aDbfs,{"IDNU"   ,"C",12,0})
      aadd(aDbfs,{"MASS"   ,"N", 6,1})
      aadd(aDbfs,{"DATE"   ,"C",10,0})
      aadd(aDbfs,{"TIME"   ,"C", 5,0})
      aadd(aDbfs,{"CDAT"   ,"D", 8,0})
      ferase("bolus.dbf")
      dbcreate("bolus.dbf",aDbfs)

      // Append the file
      aCdbf := fATopen(aCdbf,,"BOLUS",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      append from &(cFile) delimited
      go top

      // Open the handheld mass file
      aCdbf := fATopen(aCdbf,cDd(),"SM3MASH",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      zap

      // Loop the original read file
      select BOLUS
      go top
      do while !eof()

         // Convert the date
         BOLUS->cdat := ctod(right(BOLUS->date,2) +"/"+ ;
            substr(BOLUS->date,6,3) + ;
            left(BOLUS->date,4))

         // Skip if deleted
         if deleted()
            skip
            loop
         endif

         // Skip if no mass
         if empty(BOLUS->mass)
            skip
            loop
         endif

         // Skip if no date
         if empty(BOLUS->date)
            skip
            loop
         endif

         // Save the data
         select SM3MASH
         dbappend()
         SM3MASH->skaalid := BOLUS->idnu
         SM3MASH->mass    := BOLUS->mass
         SM3MASH->date    := BOLUS->cdat

         // Next record
         select BOLUS
         skip

      enddo

      // Close the files
      select BOLUS
      dbclosearea()
      ferase("bolus.dbf")
      select SM3MASH
      dbclosearea()
      aCdbf := asize(aCdbf,len(aCdbf)-2)

      // Do the actual transfer to the studmaster files
      if sm3mash()

         // Delete the ascii file
         ferase(cFile)

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCdbf)

return lRetu
