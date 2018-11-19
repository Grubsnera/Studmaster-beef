//sm3sucb.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"

/**************************************************************************/
FUNCTION fsm3sucb

   LOCAL nCh := 1
   LOCAL cScr
   LOCAL lMor
   LOCAL aVelde := {}
   LOCAL cDummy

   lMor := .T.
   do while lMor

      //Sluit alle .dbf lˆers
      close all

      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Hoofmenu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Main menu.")
      endif

      // Kry opsienommer
      nCh := fNewMenu( nCh, "sm3sucb" )

      // Bewaar skerm
      cScr := savescreen(0,0,24,79)

      do case

         case nCh = 0
            // Exit to hoofmenu
            return NIL

         case nCh = 1
            //Getalle
            asize( aVelde, 0)
            aadd( aVelde, {"sm3aank" , "idnr"})
            aadd( aVelde, {"sm3aank" , "datum"})
            aadd( aVelde, {"sm3aank" , "massa"})
            aadd( aVelde, {"sm3aank" , "adreskode"})
            aadd( aVelde, {"sm3aank" , "bedrag"})
            aadd( aVelde, {"sm3aank" , "graad"})
            cdummy := sm3aank(4,4,20,aVelde)

         case nCh = 2

            // Sales
            sm3sale()

      endcase

      //Herstel hoofmenu
      restscreen(0,0,24,79,cScr)

   enddo

return NIL

