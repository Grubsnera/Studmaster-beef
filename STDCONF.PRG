//STDCONF.PRG
//Program om die verskillende standaardleer te verander
//Kopiereg (c) 1991 A van Rensburg
//08:51 30 Aug,1991

#include "inkey.ch"
#include "albert.ch"

PROCEDURE stdconf

   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )
   LOCAL cCurScr := fCurScreen()
   LOCAL nConfCh
   LOCAL aVelde := {}
   LOCAL cConfScr
   LOCAL lMore := .t.
   local cDummy := ""

   fScrOpsk()

   // Veranderlikes
   nConfCh := 1

   // Begin die loop
   do whil lMore

      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir vorige skerm." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for previous screen." )
      endif

      // Kry opsienommer
      nConfCh := fNewMenu( nConfCh, "STDCONF" )

      // Bewaar skerm
      cConfScr := savescreen(0,0,24,79)

      do case

         case nConfCh = 1
            //Menus
            cDummy := stdmenu()

         case nConfCh = 2
            //Databasisse
            cDummy := stddbfs()

         case nConfCh = 3
            //Velde
            cDummy := stdfiel()

         case nConfCh = 4
            //Indeksleers
            cDummy := stdntxs( 3, 4, 20 )

         otherwise
            //Exit
            lMore := .f.
            loop

      endcase

      // Herstel hoofmenu
      restscreen(0,0,24,79,cConfScr)

   enddo

   //Herstel
   restscreen( 0, 0, 24, 79, cCurSke )
   fSetScreen( cCurScr )

return

