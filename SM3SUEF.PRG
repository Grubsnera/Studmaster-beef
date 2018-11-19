//SM3SUEF.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1993 A van Rensburg
//14:18 21 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION sm3suef()

	LOCAL nCh := 1
   	LOCAL aCscr  := {}

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
    		fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
  		else
    		fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
  		endif

  		// Kry opsienommer
  		nCh := fNewMenu( nCh, "SM3SUEF" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

   		do case
      		case nCh = 1
        		//Veegetalle
        		sm3veeg()

      		case nCh = 2
        		//Tabelle
        		sm3tabe()

      		case nCh = 3
        		//Veegetalle
        		keyboard "J"
        		sm3maan()

            otherwise
            	// Exit
	        	cOption(-1)
            	exit

   		endcase

  		//Herstel menu
      	fARestScr(aCscr)
	  	cOption(-1)
	enddo

return NIL

