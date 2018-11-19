//STDCOLO.PRG
//Program om skermkleure te stel
//Kopiereg (c) 1991 A van Rensburg
//18:12 19 Sep,1991

#include "inkey.ch"
#include "albert.ch"

FUNCTION stdcolo

   //Veranderlikes
   LOCAL cCurScr := fCurScreen()
   LOCAL nLoop := 1
   LOCAL cColTemp
   LOCAL cColo
   local getlist := {}

    if cLanType() == "A"
        fScrOpsk( 1, "Opsie "+cOption())
    else
        fScrOpsk( 1, "Option "+cOption())
    endif

   //Toets of kleurskerm gehak is
   if !(iscolor())
      fScrBood( 23 )
      if cLanType() == "A"
         fScrWait( 24, "Skermkleure kan net op kleurskerms gestel word" )
      else
         fScrWait( 24, "Screen colours may only be set for coloured screens" )
      endif
      return NIL
   endif

   //Open .dbf
   cColo := fTOpen( cDd(), "STDWAAR", , , , .f., .f. )
   if left( cColo, 1 ) == "f"
      fSetScreen( cCurScr )
      return NIL
   endif

   //Loop
   do while nLoop >= 1

      //Opskrif
      if cLanType() == "A"
       	fScrOpsk( , "Opsie "+cOption())
      else
       	fScrOpsk( , "Option "+cOption())
      endif

      //Raam
      if cLanType() == "A"
         fBox( 3, 4, 20, 45, "Skermkleure", cColNorm() )
      else
         fBox( 3, 4, 20, 45, "Screen colours", cColNorm() )
      endif

      //Menu raam
      if cLanType() == "A"
         fBox( 3, 55, 10, 75, "menukleure", cColMenu() )
      else
         fBox( 3, 55, 10, 75, "menu colours", cColMenu() )
      endif
      setcolor( cColMenu() )
      if cLanType() == "A"
         @ 4,57 say "A - Opsie 1      "
         @ 6,57 say "C - Opsie 3      "
         @ 7,57 say "D - Opsie 4      "
         @ 8,57 say "E - Opsie 5      "
         @ 9,57 say "F - Opsie 6      "
      else
         @ 4,57 say "A - Option 1     "
         @ 6,57 say "C - Option 3     "
         @ 7,57 say "D - Option 4     "
         @ 8,57 say "E - Option 5     "
         @ 9,57 say "F - Option 6     "
      endif
      cColTemp := trim( STDWAAR->menble ) + "/" + ;
         trim( STDWAAR->menbag )
      setcolor( cColTemp )
      if cLanType() == "A"
         @ 5,57 say "B - Opsie 2      "
      else
         @ 5,57 say "B - Option 2     "
      endif

      //Help raam
      if cLanType() == "A"
         fBox( 13, 55, 20, 75, "Hulpkleure", cColHelp() )
      else
         fBox( 13, 55, 20, 75, "Help colours", cColHelp() )
      endif
      setcolor( cColHelp() )
      if cLanType() == "A"
         @15,57 say "Die hulpskerms"
         @16,57 say "sal in hierdie"
         @17,57 say "kleure vertoon"
         @18,57 say "word."
      else
         @15,57 say "Help screens  "
         @16,57 say "will be dis-  "
         @17,57 say "played in     "
         @18,57 say "these colours."
      endif

      //Skerm
      setcolor( cColNorm() )
      if cLanType() == "A"
         @ 4, 5 say "                Normale letter"
         @ 5, 5 say "     Normale letter agtergrond"
         @ 6, 5 say "             Omgekeerde letter"
         @ 7, 5 say "  Omgekeerde letter agtergrond"
         @ 8, 5 say "                     Skermraam"
         @ 9, 5 say "             Menu opsie letter"
         @10, 5 say "         Menu opsie agtergrond"
         @11, 5 say "           Menu venster letter"
         @12, 5 say "                  Menu venster"
         @13, 5 say "                Opskrif letter"
         @14, 5 say "     Opskrif letter agtergrond"
         @15, 5 say "             Onderskrif letter"
         @16, 5 say "  Onderskrif letter agtergrond"
         @17, 5 say "              Hulpskerm letter"
         @18, 5 say "             Hulpskerm venster"
         @19, 5 say "                    Agtergrond"
      else
         @ 4, 5 say "              Standard letters"
         @ 5, 5 say "    Standard letter background"
         @ 6, 5 say "               Inverse letters"
         @ 7, 5 say "     Inverse letter background"
         @ 8, 5 say "                  Screen frame"
         @ 9, 5 say "                   Menu option"
         @10, 5 say "        Menu option background"
         @11, 5 say "           Menu window letters"
         @12, 5 say "                   Menu window"
         @13, 5 say "                      Headings"
         @14, 5 say "           Headings background"
         @15, 5 say "           Inscription letters"
         @16, 5 say "Inscription letters background"
         @17, 5 say "           Help screen letters"
         @18, 5 say "            Help screen window"
         @19, 5 say "                    Background"
      endif



      setcolor( cColInve() )
      @ 4, 36 say STDWAAR->norlet
      @ 5, 36 say STDWAAR->noragt
      @ 6, 36 say STDWAAR->norgle
      @ 7, 36 say STDWAAR->norgag
      @ 8, 36 say STDWAAR->norbor
      @ 9, 36 say STDWAAR->menble
      @10, 36 say STDWAAR->menbag
      @11, 36 say STDWAAR->menlet
      @12, 36 say STDWAAR->menagt
      @13, 36 say STDWAAR->hedlet
      @14, 36 say STDWAAR->hedagt
      @15, 36 say STDWAAR->botlet
      @16, 36 say STDWAAR->botagt
      @17, 36 say STDWAAR->hellet
      @18, 36 say STDWAAR->helagt
      @19, 36 say STDWAAR->agtagt

      setcolor( cColNorm() )

      do case

         case nLoop == 1
            //Normale letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die normale letter kleur." )
               @ 4, 5 say "                Normale letter" get STDWAAR->norlet pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour     [F1]=Help" )
               fScrBood( 24, "Type the standard letter colour.")
               @ 4, 5 say "               Standard letter" get STDWAAR->norlet pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->norlet := fNextColor( STDWAAR->norlet )
               fSetColor()
               loop
            endif
            nLoop++

         case nLoop == 2
            //Normale letter agtergrond
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die normale letter agtergrond kleur." )
               @ 5, 5 say "     Normale letter agtergrond" get STDWAAR->noragt pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu   [Enter]=Accept  " + D_DNARR + "=Next colour   [F1]=Help")
               fScrBood( 24, "Type the standard letter background colour.")
               @ 5, 5 say "    Standard letter background" get STDWAAR->noragt pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->noragt := fNextColor( STDWAAR->noragt )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 3
            //Normale letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die omgekeerde letter kleur." )
               @ 6, 5 say "             Omgekeerde letter" get STDWAAR->norgle pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the inverse letter colour." )
               @ 6, 5 say "                Inverse letter" get STDWAAR->norgle pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->norgle := fNextColor( STDWAAR->norgle )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 4
            //Normale letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die omgekeerde letter agtergrond kleur." )
               @ 7, 5 say "  Omgekeerde letter agtergrond" get STDWAAR->norgag pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the inverse letter background colour." )
               @ 7, 5 say "     Inverse letter background" get STDWAAR->norgag pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->norgag := fNextColor( STDWAAR->norgag )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 5
            //Skermraam
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die skermraam kleur." )
               @ 8, 5 say "                     Skermraam" get STDWAAR->norbor pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu   [Enter]=Accept  " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the screen border colour." )
               @ 8, 5 say "                 Screen border" get STDWAAR->norbor pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            STDWAAR->mensha := STDWAAR->norbor
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->norbor := fNextColor( STDWAAR->norbor )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 6
            //Menu opsie
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die menu opsie letter kleur." )
               @ 9, 5 say "             Menu opsie letter" get STDWAAR->menble pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the menu option letter colour." )
               @ 9, 5 say "                   Menu option" get STDWAAR->menble pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->menble := fNextColor( STDWAAR->menble )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 7
            //Menu opsie letter agtergrond
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die menu opsie agtergrond kleur." )
               @10, 5 say "         Menu opsie agtergrond" get STDWAAR->menbag pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the menu option background colour." )
               @10, 5 say "        Menu option background" get STDWAAR->menbag pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->menbag := fNextColor( STDWAAR->menbag )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 8
            //Menu venster letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die menu venster letter." )
               @11, 5 say "           Menu venster letter" get STDWAAR->menlet pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR +"=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the menu window letter." )
               @11, 5 say "            Menu window letter" get STDWAAR->menlet pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->menlet := fNextColor( STDWAAR->menlet )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 9
            //Menu venster
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die menu venster kleur." )
               @12, 5 say "                  Menu venster" get STDWAAR->menagt pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the menu window colour." )
               @12, 5 say "                   Menu window" get STDWAAR->menagt pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->menagt := fNextColor( STDWAAR->menagt )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 10
            //Opskrif letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die opskrif letter kleur." )
               @13, 5 say "                Opskrif letter" get STDWAAR->hedlet pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the headings colour." )
               @13, 5 say "                      Headings" get STDWAAR->hedlet pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->hedlet := fNextColor( STDWAAR->hedlet )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 11
            //Opskrif letter agtergrond
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die opskrif letter agtergrond kleur." )
               @14, 5 say "     Opskrif letter agtergrond" get STDWAAR->hedagt pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the headings background colour." )
               @14, 5 say "           Headings background" get STDWAAR->hedagt pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->hedagt := fNextColor( STDWAAR->hedagt )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 12
            //Opskrif letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die onderskrif letter kleur." )
               @15, 5 say "             Onderskrif letter" get STDWAAR->botlet pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the inscription letter colour." )
               @15, 5 say "           Inscription letters" get STDWAAR->botlet pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->botlet := fNextColor( STDWAAR->botlet )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 13
            //Onderskrif letter agtergrond
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die onderskrif letter agtergrond kleur." )
               @16, 5 say "  Onderskrif letter agtergrond" get STDWAAR->botagt pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the inscription letter background colour." )
               @16, 5 say " Inscription letter background" get STDWAAR->botagt pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->botagt := fNextColor( STDWAAR->botagt )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 14
            //Hulpskerm letter
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die hulpskerm letter kleur." )
               @17, 5 say "              Hulpskerm letter" get STDWAAR->hellet pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrBood( 24, "Type the help screen letter colour." )
               @17, 5 say "            Help screen letter" get STDWAAR->hellet pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->hellet := fNextColor( STDWAAR->hellet )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 15
            //Hulpskerm venster
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die hulpskerm venster kleur." )
               @18, 5 say "             Hulpskerm venster" get STDWAAR->helagt pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrbood( 24, "Type the help screen window colour." )
               @18, 5 say "            Help screen window" get STDWAAR->helagt pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->helagt := fNextColor( STDWAAR->helagt )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop++

         case nLoop == 16
            //Agtergrond
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  [Enter]=Aanvaar  " + D_DNARR + "=Volgende kleur  [F1]=Hulp" )
               fScrBood( 24, "Tik die agtergrond kleur." )
               @19, 5 say "                    Agtergrond" get STDWAAR->agtagt pict "@!"
            else
               fScrBood( 23, "[Esc]=Menu  [Enter]=Accept   " + D_DNARR + "=Next colour   [F1]=Help" )
               fScrbood( 24, "Type the background colour." )
               @18, 5 say "                    Background" get STDWAAR->agtagt pict "@!"
            endif
            set cursor on
            readexit(.t.)
            read
            readexit(.f.)
            set cursor off
            //Escape
            if lastkey() == K_ESC
               fSetColor()
               nLoop := 0
               loop
            endif
            //Volgende kleur
            if lastkey() == K_DOWN
               STDWAAR->agtagt := fNextColor( STDWAAR->agtagt )
               fSetColor()
               loop
            endif
            //Volgende kleur
            if lastkey() == K_UP
               fSetColor()
               nLoop--
               loop
            endif
            nLoop := 0

      endcase

      //Kleure
      fSetcolor()

   enddo

   fTClose( cColo )
   fSetScreen( cCurScr )
return NIL

/**********************************************************************/
STATIC FUNCTION fNextColor( cColor )
   //Funksie om volgende kleur te return

   cColor := alltrim( cColor )

   do case
      case cColor == "N"
         cColor := "B"
      case cColor == "B"
         cColor := "G"
      case cColor == "G"
         cColor := "BG"
      case cColor == "BG"
         cColor := "R"
      case cColor == "R"
         cColor := "RB"
      case cColor == "RB"
         cColor := "GR"
      case cColor == "GR"
         cColor := "W"
      case cColor == "W"
         cColor := "N+"
      case cColor == "N+"
         cColor := "B+"
      case cColor == "B+"
         cColor := "G+"
      case cColor == "G+"
         cColor := "BG+"
      case cColor == "BG+"
         cColor := "R+"
      case cColor == "R+"
         cColor := "RB+"
      case cColor == "RB+"
         cColor := "GR+"
      case cColor == "GR+"
         cColor := "W+"
      case cColor == "W+"
         cColor := "N"
      otherwise
         cColor := "W"
   endcase

   cColor := padr( cColor, 3 )

return cColor

