//STDSUBF.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION StdSubf()

   local nCh := 1
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
      nCh := fNewMenu( nCh, "STDSUBF" )
      cOption(nCh)
      aCscr := fASaveScr()

      do case

         case nCh = 1
            // Lees massa teelwaardes
            sm3bimp()

         case nCh = 2
            // Breeding policy
            sm3poli()

         case nCh = 3
            // Blup vaaropsommings
            sm3sire()

         case nCh = 4
            // Blup nageslagopsommings
            sm3epro()

         otherwise
            // Exit to hoofmenu
            cOption(-1)
            exit

      endcase

      //Herstel menu
      fARestScr(aCscr)
      cOption(-1)
   enddo

return NIL
