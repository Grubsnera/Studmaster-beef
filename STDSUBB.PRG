//STDSUBB.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION StdSubb()

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
      nCh := fNewMenu( nCh, "STDSUBB" )
      cOption(nCh)
      aCscr := fASaveScr()

      do case
         case nCh = 1
            //Bereken weegdatums
            cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
            if cBrep $ "JYjy"
               // Breedplan format
               sm3weib()
            else
               // Iris format
               sm3weid()
            endif

         case nCh = 2
            //Bewaar massas
            sm3mass()

         case nCh = 3
            //Bewaar moeder massas
            sm3moem()

         case nCh = 4
            //Bereken indekse
            sm3indc()

         case nCh = 5
            //Indeksverslag
            sm3inda()

         case nCh = 6
            //Sit bulle in toets
            sm3fasi()

         case nCh = 7
            //Bewaar beginmassa
            sm3fasb()

         case nCh = 8
            //Bewaar eindmassa
            sm3fase()

         case nCh = 9
            //Bereken indekse
            sm3fasc()

         case nCh = 10
            // Druk massas verslag
            sm3fasm()

         case nCh = 11
            //Vertoon fase d kostes
            sm3fask()

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

