//STDSUBI.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
// 5:08am Jan 11,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION StdSubi()

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
      	nCh := fNewMenu( nCh, "STDSUBI" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

        do case
            case nCh = 1

               	//Toets data
               	stdinde(TRUE)
               	stddata()
               	sm3rasu()

               	//Herskep Indekse
               	stdindx()
               	dbcloseall()
               	sm3skep()
               	keyboard chr(K_ESC)

            case nCh = 2
               	//Herskep Indekse
               	stdinde(TRUE)
               	stdindx()
               	dbcloseall()
               	sm3skep()
               	keyboard chr(K_ESC)

            case nCh = 3
               	//Skermkleure
               	stdcolo()

            case nCh = 4
               	//Drukkerkodes
                  stdpset(,,,,nPrnCode())
                  //stddruk()

            case nCh = 5
               	//Aantal rekords
               	stdaand()

            case nCh = 6
               	//Taalvoorkeur
               	stdtaal()

            case nCh = 7
               	//Stelselinligting
               	stdsyst()

            case nCh = 8
               	//About
               	if cLanType() == "A"
                  	stdabou("StoetMeester vir Vleisbeeste")
               	else
                  	stdabou("StudMaster for Beef cattle")
               	endif

            case nCh = 9
               	//Serie kommunikasie
               	stdserc()

            case nCh = 10
                  // Serial number
                  stdseri()

            case nCh = 11
                  // Licensed User
                  stdregn()

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

