//STDSUBD.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//10:07 20 Dec,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION StdSubd()

	local nCh    := 1
	local aVelde := {}
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
  		nCh := fNewMenu( nCh, "STDSUBD" )
  		cOption(nCh)
  		aCscr := fASaveScr()

    	do case
      		case nCh = 1
        		//Waar is dier kodes
        		asize( aVelde, 0 )
        		aadd( aVelde, { "sm3waar", "kode" })
        		aadd( aVelde, { "sm3waar", "besk" })
            aadd( aVelde, { "sm3waar", "koof" })
        		sm3waar( 5, 5, 21, aVelde )

      		case nCh = 2
        		//Opmerkings
        		asize( aVelde, 0 )
        		aadd( aVelde, { "sm3opmk", "kode" })
        		aadd( aVelde, { "sm3opmk", "besk" })
        		sm3opme( 5, 5, 21, aVelde )

      		case nCh = 3
        		//Akkeurredes
        		sm3rede()

      		case nCh = 4
        		//Merk diere menu
        		sm3merm()

            case nCh = 5
            // Visuele beoordeling
            sm3visu()

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

