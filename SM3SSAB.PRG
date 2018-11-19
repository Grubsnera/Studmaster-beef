//SM3SSAB.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1992 A van Rensburg
//14:24 28 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION Sm3Ssab()

   	LOCAL nCh    := 1
   	LOCAL aCscr  := {}
   	LOCAL aVelde := {}
   	LOCAL cDummy

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
      	nCh := fNewMenu( nCh, "SM3SSAB" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

        do case
            case nCh = 1
            	//Bewaar dekinligting
            	sm3dekk()

            case nCh = 2
            	//Verander deklinligting
            	sm3dekv()

            case nCh = 3
            	//Bewaar dragtigheidsondersoeke
            	sm3preg()

            case nCh = 4
            	//Bewaar bul besig inligting
            	sm3hdek()

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
