//STDSUBG.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION StdSubg()

   	local nCh    := 1
   	local aCscr  := {}
   	local aVelde := {}
   	local cDummy

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
      	nCh := fNewMenu( nCh, "STDSUBG" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

        do case
            case nCh == 1
               	//dagboek
               	asize( aVelde, 0)
               	aadd( aVelde, { "sm3kale", "datum" })
               	aadd( aVelde, { "sm3kale", "handeling"})
               	cDummy := sm3kale(3,2,20,aVelde,dAppDate())

            case nCh == 2
               	//Jaarlikse dagboek
               	asize( aVelde, 0)
               	aadd( aVelde, { "sm3jaar", "dagdag" })
               	aadd( aVelde, { "sm3jaar", "maandd" })
               	aadd( aVelde, { "sm3jaar", "handel" })
               	cDummy := sm3jaar(3,2,20,aVelde)

            case nCh == 3
               	// Diseases
               	sm3siek()

            case nCh == 4
               	// Treatments
               	sm3beha()

            case nCh == 5
               	// Veterinary
               	sm3veea()

            case nCh == 6
               	// Innoculation program
               	sm3inen()

            otherwise
               	// Exit to hoofmenu
	        	cOption(-1)
            	exit

         	endcase

      	//Herstel hoofmenu
      	fARestScr(aCscr)
	  	cOption(-1)
   	enddo

return NIL

