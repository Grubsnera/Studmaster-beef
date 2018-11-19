//STDSUBH.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
// 5:08am Jan 11,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION StdSubh()

   local nCh    := 1
   local aCscr  := {}

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   do while TRUE
      //Sluit alle .dbf leers
      dbcloseall()

      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Hoofmenu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Main menu." )
      endif

      // Kry opsienommer
      nCh := fNewMenu( nCh, "STDSUBH" )
      cOption(nCh)
      aCscr := fASaveScr()

      do case
         case nCh = 1
            //Verander vaste inligting
            stdvast()

         case nCh = 2
            //Herskep Indekse
            stdinde(TRUE)
            stdindx()

         case nCh = 3
            //Koeigemiddeldes
            sm3gemm()

         case nCh = 4
            //Skrap en verander
            sm3idid()

         case nCh = 5
            //Bereken maandouderdomme
            sm3maan()

         case nCh = 6
            //Skep diskette
            sm3flop()

         case nCh = 7
            //Lees diskette
            sm3impo()

         case nCh = 8
            //Dubbel id nommers
            sm3dubb()

         case nCh = 9
            //Korrespondensie
            sm3lett()

         case nCh = 10
            // Feed conversion to kleiber
            sm3vokl()

         case nCh = 11
            // Calculate inbreed coefficient - total herd
            sm3coef()

         case nCh = 12
            // Calculate inbreed coefficient - future progeny
            sm3cfpi()

         case nCh = 13
            // Calculate animal presense percentages
            sm3voor()

         case nCh = 14
            // Reset AI Dates - this function is only there to reset AI dates
            // if they were cleared when a birth was entered after the AI information
            // for the next pregnancy was entered into the system - this problem should
            // not happen any more in ver 4.12b
            sm3raid()

         case nCh = 15
            // Change all 1900-1930 dates to 2000
            sm3datu()

         otherwise
            // Exit
            cOption(-1)
            exit

      endcase

      //Herstel menu
      fARestScr(aCscr)
      cOption(-1)
   enddo

return NIL

