//SM3SSAC.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1992 A van Rensburg
//10:23pm Sep 28,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION Sm3Ssac()

   	LOCAL nCh    := 1
   	LOCAL aCscr  := {}
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
      	nCh := fNewMenu( nCh, "SM3SSAC" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

       	do case
           	case nCh = 1
               	//Verwantskappe
               	sm3verw()

           	case nCh = 2
               	//Deklys
               	//Kry die kalfseisoen
               	cDummy := sm3teeg()

               	if len(alltrim(cDummy)) > 0
                  	sm3dekl(,,,,cDummy)
               	endif

           	case nCh = 3
               	//Dragtigheidsondersoek
               	//Kry die kalfseisoen
               	cDummy := sm3teeg()

               	if len(alltrim(cDummy)) > 0
                  	sm3drag(,,,,cDummy)
               	endif

           	case nCh = 4
               	//Geboorte-aantekening
               	//Kry die kalfseisoen
               	cDummy := sm3teeg()

               	if len(alltrim(cDummy)) > 0
                  	sm3geba(,,,,cDummy)
               	endif

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
