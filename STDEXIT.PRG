//STDEXIT.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//16:53 15 Nov,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/***********************************************************************/
FUNCTION StdExit()

   local nCh   := 1
   local aCscr := {}
   local lRetu := TRUE
   local cWaar := ""

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
      nCh := fNewMenu( nCh, "STDEXIT" )
      cOption(nCh)
      aCscr := fASaveScr()

      do case
         case nCh = 1

            // Formatteer en rugsteun
            if stdrugs()

               //Bewaar die datum
               cWaar := fTOpen(cDd(),"stdwaar",,,,FALSE)
               if left(cWaar,1) == "f"
               else
                  STDWAAR->datumb := dAppDate()
                  fTClose(cWaar)
               endif

               nCh := 4

            endif

         case nCh = 2

            //Rugsteun
            if stdback()

               //Bewaar die datum
               cWaar := fTOpen(cDd(),"stdwaar",,,,FALSE)
               if left(cWaar,1) == "f"
               else
                  STDWAAR->datumb := dAppDate()
                  fTClose(cWaar)
               endif

               nCh := 4

            endif

         case nCh = 3

            //Restore
            if stdrest()
               //Toets data
               stdinde(TRUE)
               stddata()
               sm3rasu()

               //Herskep Indekse
               stdinde(FALSE)
               stdindx()
               dbcloseall()
               sm3skep()

               cOption(-1)
               exit
            endif

         case nCh = 4

            //Verlaat program heeltemal
            lRetu := FALSE
            cOption(-1)
            exit

         case nCh = 5

            // Rugsteun with email
            if stdbace()

               // Bewaar die datum
               cWaar := fTOpen(cDd(),"stdwaar",,,,FALSE)
               if left(cWaar,1) == "f"
               else
                  STDWAAR->datumb := dAppDate()
                  fTClose(cWaar)
               endif

               nCh := 4

            endif

         otherwise
            //Vertoon die hoofmenu
            cOption(-1)
            exit

      endcase

      //Herstel hoofmenu
      fARestScr(aCscr)
      cOption(-1)
   enddo

return lRetu

