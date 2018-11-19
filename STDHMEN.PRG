//STDHMEN.PRG
//Program om hoofmenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//16:35 15 Nov,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/**************************************************************************/
FUNCTION StdHmen

   // Funksie om die hoofmenu van enige program te vertoon

   //Verklaar
   local nChoice := 1
   local aCscr   := {}
   local aVelde  := {}
   local cDumm   := ""

   if val(substr(cReeNomm(),4,4)) > 0
      fScrOpsk(,cReeNomm())
   else
      fScrOpsk(,"DEMO")
   endif

   // Begin die loop
   do while TRUE
      dbcloseall()

      //Set key waardes
      if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
         // set key K_SH_TAB to stdconf
         set key K_ALT_X to stdconf
         set key K_ALT_Z to stdedit
      endif

      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] om program te be‰indig." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] to exit program." )
      endif

      // Kry opsienommer
      nChoice := fNewMenu( nChoice, "HOOFMENU" )

      //Set key waardes
      set key K_SH_TAB to

      // Bewaar skerm
      aCscr := fASaveScr()
      cOption(-9999)

      if nChoice < 1
         cOption(17)
      elseif nChoice = 11
         cOption(17)
      else
         cOption(nChoice)
      endif

      do case
         case nChoice = 1
            //Submenu A
            stdsuba()

         case nChoice = 2
            //Submenu B
            stdsubb()

         case nChoice = 3
            //Submenu C
            stdsubc()

         case nChoice = 4                        //d
            //Seleksies
            stdsubd()

         case nChoice = 5                        //e
            //Drukverslae
            stdsube()

         case nChoice = 6                        //f
            //blup teelwaardes
            stdsubf()

         case nChoice = 7                        //g
            //Dagboek
            stdsubg()

         case nChoice = 8                        //h
            //Kudde
            stdsubh()

         case nChoice = 9                        //i
            //Rekenaar
            stdsubi()

         case nChoice = 10                       //j
            //Programindeks
            asize( aVelde, 0)
            if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
               if cLanType() == "A"
                  aadd( aVelde, { "stddexa", "kode" })
                  aadd( aVelde, { "stddexa", "besk" })
                  aadd( aVelde, { "stddexa", "opsi" })
               else
                  aadd( aVelde, { "stddexe", "kode" })
                  aadd( aVelde, { "stddexe", "besk" })
                  aadd( aVelde, { "stddexe", "opsi" })
               endif
            else
               if cLanType() == "A"
                  aadd( aVelde, { "stddexa", "besk" })
                  aadd( aVelde, { "stddexa", "opsi" })
               else
                  aadd( aVelde, { "stddexe", "besk" })
                  aadd( aVelde, { "stddexe", "opsi" })
               endif
            endif
            cDumm := stddexi(3,2,20,aVelde)
            if cDumm == NIL
               //Moet niks doen
            else
               //Gaan na die opsie
               keyboard trim(cDumm)
            endif

         otherwise
            //Exit
            if ! StdExit()
               exit
            endif

      endcase

      // Herstel hoofmenu
      fARestScr(aCscr)
   enddo

return NIL

