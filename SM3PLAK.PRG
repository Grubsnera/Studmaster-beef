//SM3PLAK.PRG
//Program om plakkers menu vertoon
//Kopiereg (c) 1992 A van Rensburg
//16:11 10 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/*************************************************************************/
FUNCTION sm3plak()

	LOCAL nCh    := 3
	LOCAL aVelde := {}
   	LOCAL aCscr  := {}
	LOCAL nDummy := 0

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
  		nCh := fNewMenu( nCh, "SM3PLAK" )
      	aCscr := fASaveScr()
  		if cLanType() == "A"
		  	fScrOpsk(1,"Opsie "+cOption(nCh))
		else
		  	fScrOpsk(1,"Option "+cOption(nCh))
		endif

   		do case
      		case nCh = 1
        		//Bepaal plakkergroottes
        		sm3labg()

      		case nCh = 2
        		//Bewaar plakkergroottes
        		asize( aVelde, 0 )
        		aadd( aVelde, { "sm3labe", "laname" })
        		aadd( aVelde, { "sm3labe", "laaccr" })
        		aadd( aVelde, { "sm3labe", "lastar" })
        		aadd( aVelde, { "sm3labe", "lawidt" })
        		aadd( aVelde, { "sm3labe", "lacolb" })
        		aadd( aVelde, { "sm3labe", "laheig" })
        		aadd( aVelde, { "sm3labe", "labetw" })
        		aadd( aVelde, { "sm3labe", "latype" })
        		nDummy := sm3labe( 3, 3, 20, aVelde )

      		case nCh = 3
        		//Druk plakkers
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
            			//Watter etiket
            			asize( aVelde, 0 )
            			aadd( aVelde, { "sm3labe", "laname" })
            			aadd( aVelde, { "sm3labe", "laaccr" })
            			aadd( aVelde, { "sm3labe", "lastar" })
            			aadd( aVelde, { "sm3labe", "lawidt" })
            			aadd( aVelde, { "sm3labe", "lacolb" })
            			aadd( aVelde, { "sm3labe", "laheig" })
            			aadd( aVelde, { "sm3labe", "labetw" })
            			aadd( aVelde, { "sm3labe", "latype" })
            			nDummy := sm3labe( 3, 3, 20, aVelde )
            			if nDummy > 0
	              			//Druk
    	          			sm3labp(nDummy)
            			endif
          			endif
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

