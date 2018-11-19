//SM3VERM.PRG
//Program om verslag menu vertoon
//Kopiereg (c) 1992 A van Rensburg
//08:59 11 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION sm3verm()

	LOCAL nCh    := 1
   	LOCAL aCscr  := {}
	LOCAL aVelde := {}

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
    		fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " sleutels en druk " + D_ENTER + ". Druk [Esc] vir vorige skerm." )
  		else
    		fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". Press [Esc] for the Main menu." )
  		endif

  		// Kry opsienommer
  		nCh := fNewMenu( nCh, "SM3VERM" )
      	aCscr := fASaveScr()
  		if cLanType() == "A"
		  	fScrOpsk(1,"Opsie "+cOption(nCh))
		else
		  	fScrOpsk(1,"Option "+cOption(nCh))
		endif

   		do case
      		case nCh = 1
        		//Telefoonlys
        		//Toets of drukker gereed is
        		fScrBood(23)
        		if fPrnReady() == K_ESC
	           		cOption(-1)
					exit
        		else
          			//Adrestipes
          			asize( aVelde, 0 )
          			aadd( aVelde, { "sm3tipe", "merk" })
          			aadd( aVelde, { "sm3tipe", "tipe" })
          			aadd( aVelde, { "sm3tipe", "beskr" })
          			aadd( aVelde, { "sm3tipe", "aantal" })
          			if sm3merk( 3, 3, 20, aVelde )
            			//Druk
            			asize( aVelde, 0 )
            			aadd( aVelde, { "sm3klie", "kode" })
            			aadd( aVelde, { "sm3klie", "naam" })
            			aadd( aVelde, { "sm3klie", "htel" })
            			aadd( aVelde, { "sm3klie", "wtel" })
            			aadd( aVelde, { "sm3klie", "kontak" })
            			sm3verl(aVelde,"Telefoonlys.")
          			endif
        		endif

      		case nCh = 2
        		//Verkorte adreslys
        		//Toets of drukker gereed is
        		fScrBood(23)
        		if fPrnReady() == K_ESC
	           		cOption(-1)
					exit
        		else
          			//Adrestipes
          			asize( aVelde, 0 )
          			aadd( aVelde, { "sm3tipe", "merk" })
          			aadd( aVelde, { "sm3tipe", "tipe" })
          			aadd( aVelde, { "sm3tipe", "beskr" })
          			aadd( aVelde, { "sm3tipe", "aantal" })
          			if sm3merk( 3, 3, 20, aVelde )
            			//Druk
            			asize( aVelde, 0 )
            			aadd( aVelde, { "sm3klie", "naam" })
            			aadd( aVelde, { "sm3klie", "adr1" })
            			aadd( aVelde, { "sm3klie", "adr2" })
            			aadd( aVelde, { "sm3klie", "adr3" })
            			aadd( aVelde, { "sm3klie", "posk" })
            			sm3verl(aVelde,"Verkorte adreslys.")
          			endif
        		endif

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

