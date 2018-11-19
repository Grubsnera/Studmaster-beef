//SM3MERM.PRG
//Program om nageslag opsommings te vertoon
//Kopiereg (c) 1993 A van Rensburg
//10:24 02 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/****************************************************************************/
FUNCTION sm3merm

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
        	fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Vorige menu." )
    	else
        	fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Previous menu." )
    	endif

    	// Kry opsienommer
    	nCh := fNewMenu( nCh, "SM3MERM" )
  		aCscr := fASaveScr()
		if cLanType() == "A"
    		fScrOpsk( 1, "Opsie "+cOption(nCh))
		else
    		fScrOpsk( 1, "Option "+cOption(nCh))
		endif

       	do case
        	case nCh = 1
            	//Merk enkel diere
            	sm3meen(sm3mark())

        	case nCh = 2
            	//Merk groep diere
            	sm3megr(sm3mark(),.f.)

        	case nCh = 3
            	//Merk seleksiegroep diere
            	sm3megr(sm3mark(),.t.)

        	case nCh = 4
            	// Mark one animals pedigree
            	sm3mspe(sm3mark())

        	case nCh = 5
            	// Mark one animals progeny
            	sm3mspr(sm3mark())

      		otherwise
        		//Exit
        		cOption(-1)
        		exit

       	endcase

    	//Herstel menu
  		fARestScr(aCscr)
  		cOption(-1)
	enddo

return NIL

