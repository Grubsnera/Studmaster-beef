//sm3addr.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"
#include "common.ch"

/**************************************************************************/
FUNCTION sm3addr()

   	LOCAL nCh    := 1
   	LOCAL aVelde := {}
   	LOCAL aCscr  := {}
   	LOCAL cDummy

    if cLanType() == "A"
        fScrOpsk( 1, "Opsie "+cOption())
    else
        fScrOpsk( 1, "Option "+cOption())
    endif

   	do while TRUE
      	//Sluit alle .dbf lˆers
   	  	dbcloseall()

      	// Vertoon hulpskerm
      	if cLanType() == "A"
         	fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Menu." )
      	else
         	fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Menu." )
      	endif

      	// Kry opsienommer
      	nCh := fNewMenu( nCh, "sm3addr" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

      	do case
         	case nCh = 1
            	//Adresse
            	asize( aVelde, 0)
            	aadd( aVelde, {"sm3klie" , "kode"})
            	aadd( aVelde, {"sm3klie" , "naam"})
            	aadd( aVelde, {"sm3klie" , "htel"})
            	aadd( aVelde, {"sm3klie" , "wtel"})
            	aadd( aVelde, {"sm3klie" , "adr1"})
            	aadd( aVelde, {"sm3klie" , "adr2"})
            	aadd( aVelde, {"sm3klie" , "adr3"})
            	aadd( aVelde, {"sm3klie" , "posk"})
            	aadd( aVelde, {"sm3klie" , "kudvv"})
            	aadd( aVelde, {"sm3klie" , "kudkl"})
            	aadd( aVelde, {"sm3klie" , "kontak"})
            	aadd( aVelde, {"sm3klie" , "tipe"})
            	aadd( aVelde, {"sm3klie" , "datum2"})
            	cdummy := sm3klie(3,2,20,aVelde)

         	case nCh = 2
            	//Adrestipes
            	asize( aVelde, 0)
            	aadd( aVelde, {"sm3tipe" , "tipe"})
            	aadd( aVelde, {"sm3tipe" , "beskr"})
            	aadd( aVelde, {"sm3tipe" , "aantal"})
            	cdummy := sm3tipe(3,2,20,aVelde)

         	case nCh = 3
            	sm3verm()

         	case nCh = 4
            	sm3plak()

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

