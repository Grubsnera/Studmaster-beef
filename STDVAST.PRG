//STDVAST.PRG
//Program om vaste inligting te bewaar
//Kopiereg (c) 1991 A van Rensburg
//18:26 15 Nov,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/**************************************************************************/
FUNCTION stdvast()

   //Veranderlikes
   LOCAL nCh := 1                                //Keuse tussen een of alle dataleers
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
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Menu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Menu." )
      endif

      // Kry opsienommer
      nCh := fNewMenu( nCh, "STDVAST" )
      cOption(nCh)
      aCscr := fASaveScr()

      //Die opsies
      do case
         case nCh = 1
            //Naam en Adres
            stdnaam()

         case nCh = 2
            //Kuddekenmerk
            sm3kalf()

         case nCh = 3
            //Standaardwaardes
            sm3stan()

         case nCh = 4
            //Ras
            sm3selr()

         case nCh = 5
            //Dekwaardes
            sm3stad()

         case nCh = 6
            //Lewendige diere merke
            sm3wisd()

         case nCh = 7
            //Opskrifte
            sm3opsk()

         case nCh = 8
            // Id number format
            //sm3idfo("Ask")
            sm3idma()

         case nCh = 9
            // Attention list
            sm3acti()

         case nCh = 10
            // Palmtop
            sm3padi()

         case nCh = 11
            // Wordpad
            sm3word()

         case nCh = 12
            // Electronic post
            sm3mail()

         case nCh = 13
            // Email address
            sm3maad()

         otherwise
            // Exit to sub-menu
            cOption(-1)
            exit

      endcase

      //Herstel
      fARestScr(aCscr)
      cOption(-1)
   enddo

return NIL

