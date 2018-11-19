//STDSUBE.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION StdSube()

   local nCh0   := 1
   local nCh1   := 1
   local aScr0  := {}
   local aScr1  := {}

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
      nCh0 := fNewMenu( nCh0, "STDSUBE" )
      cOption(nCh0)
      aScr0 := fASaveScr()

      do case
         case nCh0 = 1
            //Weeglys
            sm3wely()

         case nCh0 = 2
            //Eie verslag
            sm3ownr()

         case nCh0 = 3
            //Nageslag
            sm3prog()

         case nCh0 = 4
            //Stambome
            // Kry opsienommer
            if cLanType() == "A"
               fScrOpsk( 1, "Opsie "+cOption())
            else
               fScrOpsk( 1, "Option "+cOption())
            endif

            nCh1 := fNewMenu( nCh1, "SM35GEN" )
            cOption(nCh1)
            aScr1 := fASaveScr()

            DO CASE
               CASE nCh1 = 1
                  sm3pedi()
               CASE nCh1 = 2
                  sm35gen()
            ENDCASE

            //Herstel menu
            fARestScr(aScr1)
            cOption(-1)

         case nCh0 = 5
            //Algehele opsomming
            sm3voll()

         case nCh0 = 6
            //Veegetalle
            sm3suef()

         case nCh0 = 7
            //Veilingskatalogus
            sm3auct()

         case nCh0 = 8
            //Inspeksielys
            sm3insp()

         case nCh0 = 9
            //Oordragte
            sm3oord()

         case nCh0 = 10
            //Vorm e
            sm3vore()

         case nCh0 = 11
            // EBV Nageslag
            sm3epro()

         otherwise
            // Exit to hoofmenu
            cOption(-1)
            exit

      endcase

      //Herstel menu
      fARestScr(aScr0)
      cOption(-1)

   enddo

return NIL
