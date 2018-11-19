// Application: StudMaster for Beef Cattle
//   File Name: STD.PRG
// Description: Starting program
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-20-94      05:07:26am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION std


   local cDruk := ""

   public pPrnNorm := "\f0\fs22"
   public pPrnCond := "\f1\fs16"
   public pPrnAddi := .f.

   begin sequence


      // Set environment
      clear screen
      set cursor off
      set conf on
      set date brit
      set epoch to 1940
      set scoreboard off
      set deleted on
      set message to maxrow()
      cmxAutoOrder(1)

      // Program wide static variables
      sm3idfo(,"1")

      // Startup values
      if !stdstar()
         break
      endif

      // Data drive function stddryf() inside stdstar()

      // Today's date function stddatu() inside stdstar()

      // Serial number get
      //if !stdreek()
      //   break
      //endif
      if !stdsern()
         break
      endif

      // Convert StudMaster Version 3 data
      if !sm3conv()
         break
      endif

      // User standard values
      if !stdwaar()
         break
      endif

      // Enter the serrial number

      // User codes
      //if !stdkode("jna")
      //   break
      //endif
      if !stdcode()
         break
      endif

      // Create sample files
      if !stdsamp()
         break
      endif

      // Create standard index files
      if !stdinde(iif(file(cDd()+"FILEINTE.TXT"),.t.,.f.))
         break
      endif

      // Test data file structures
      if file(cDd()+"FILEINTE.TXT")
         if !stddata()
            break
         endif
         // Update the breeds file
         sm3rasu()
         // Update the breeds file with breedplan breed code
         sm3rasb(substr(cTotNaam(),149,3),"BREEDS",substr(cTotNaam(),192,10))
         if !empty(substr(cTotNaam(),192,10))
            sm3rasb(substr(cTotNaam(),149,3),"BREEDP","Y")
         endif
      endif

      // Create index files
      if file(cDd()+"FILEINTE.TXT")
         if !stdindx()
            break
         endif
      endif

      // Erase the file integrity check file
      ferase(cDd()+"FILEINTE.TXT")

      // Initialize the printer
      if empty(cPrnStar())
      else
         // Toets of drukker gereed is
         if fPrnReady() == K_ESC
         else
            // Send the initialization string to the printer
            fPrnOn()
            fPrnCod(cPrnStar())
            fPrnOff()
         endif
      endif

      // Put annual diary entries in diary
      if lTestDia()
         sm3ooja()
      endif

      // Test for diary entries
      sm3isda()

      // Menus
      //ft_minit()
      //ft_mcursor(.t.)
      //ft_mshowcrs()
      stdhmen()

   end

   // Reset
   set curs on
   setcolor(cColBegi())
   clear screen

return NIL
