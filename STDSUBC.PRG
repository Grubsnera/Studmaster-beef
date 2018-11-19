// STDSUBC.PRG
// Program om submenu te vertoon
// Kopiereg (c) 1991 A van Rensburg
// 09-05-95 09:52am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION StdSubc()

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
         	fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". Press [Esc] for the Main menu." )
      	endif

      	// Kry opsienommer
      	nCh := fNewMenu( nCh, "STDSUBC" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

        do case
            case nCh = 1
               	//bewaar massas
               	sm3weeg()

            case nCh = 2
               	// Mass report
               	sm3gema()

            case nCh = 3
               	//Gdt verslag
               	sm3gere()

            case nCh = 4
               	// Production report
               	sm3prod()

            case nCh = 5
               	sm3addr()

            case nCh = 6
               	// Purchases
               	sm3purc()

            case nCh = 7
               	// Sales
               	sm3sale()

            case nCh = 8
               	// Electronic scales
               	sm3scal()

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
