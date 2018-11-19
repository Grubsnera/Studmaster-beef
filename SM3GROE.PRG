//SM3GROE.PRG
//Program om 'n seleksiegroep te bou vanaf enkele velde
//Kopiereg (c) 1992 A van Rensburg
//16:14 30 Mar,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3groe( nTop, nLef )

	//Verklaar
	local getlist  := {}
	local aCscr    := {}
	local dD001    := ctod("  /  /  ")
	local dD002    := ctod("  /  /  ")
	local cGesl    := " "
	local cWaar    := "  "
	local nLoop    := 1
	local cReturn  := ""

	//Skerm
	if cLanType() == "A"
    	fScrOpsk( , "Opsie "+cOption())
	else
    	fScrOpsk( , "Option "+cOption())
	endif

	aCscr := fASaveScr()

	//Waardes
	nTop := if( nTop==NIL, 7, nTop )
	nLef := if( nLef==NIL, 15, nLef )

	//Skerm
	if cLanType() == "A"
  		fBox( nTop, nLef, nTop+10, nLef+47, "GROEP DIERE" )
  		@nTop+2, nLef+2 say "      Diere gebore na watter datum?"
  		@nTop+4, nLef+2 say "    Diere gebore voor watter datum?"
  		@nTop+6, nLef+2 say "           Diere van watter geslag?"
  		@nTop+8, nLef+2 say "Diere met watter Waar is dier kode?"
	else
  		fBox( nTop, nLef, nTop+10, nLef+47, "GROUP OF ANIMALS" )
  		@nTop+2, nLef+2 say "      Animals born after what date?"
  		@nTop+4, nLef+2 say "     Animals born before what date?"
  		@nTop+6, nLef+2 say "               Animals of what sex?"
  		@nTop+8, nLef+2 say " Animals with Where is animal code?"
	endif

	do while nLoop > 0
  		do case
    		case nLoop == 1
      			//Eerste datum
      			if cLanType() == "A"
        			fScrBood(23,"Diere gebore na watter datum moet geselekteer word?")
        			fScrBood(24,"[Esc]=Terug")
        			@nTop+2, nLef+2 say "      Diere gebore na watter datum?" get dD001
      			else
        			fScrBood(23,"Animals born after what date must be selected?")
        			fScrBood(24,"[Esc]=Return")
        			@nTop+2, nLef+2 say "      Animals born after what date?" get dD001
      			endif
      			readexit(.t.)
      			set cursor on
      			read
      			set cursor off
      			readexit(.f.)
      			do case
        			case lastkey() == K_ESC
    	      			nLoop := 0
        			case lastkey() == K_ENTER
	          			nLoop := 2
      			endcase

    		case nLoop == 2
      			//Tweede datum
      			if cLanType() == "A"
        			fScrBood(23,"Diere gebore voor watter datum moet geselekteer word?")
        			fScrBood(24,"[Esc]=Terug  "+D_UPARR+"=Eerste datum" )
        			@nTop+4, nLef+2 say "    Diere gebore voor watter datum?" get dD002
      			else
        			fScrBood(23,"Animals born before what date must be selected?")
        			fScrBood(24,"[Esc]=Return  "+D_UPARR+"=First date" )
        			@nTop+4, nLef+2 say "     Animals born before what date?" get dD002
      			endif
      			readexit(.t.)
      			set cursor on
      			read
      			set cursor off
      			readexit(.f.)
      			do case
        			case lastkey() == K_ESC
          				nLoop := 0
    	   			case lastkey() == K_UP
        	  			nLoop := 1
        			case lastkey() == K_ENTER
	          			nLoop := 3
      			endcase

    		case nLoop == 3
      			//Geslag
      			if cLanType() == "A"
        			fScrBood(23,"Diere van watter geslag moet geselekteer word?")
        			fScrBood(24,"[Esc]=Terug  "+D_UPARR+"=Tweede datum" )
        			@nTop+6, nLef+2 say "           Diere van watter geslag?" get cGesl pict "!"
      			else
        			fScrBood(23,"Animals of what sex should be selected?")
        			fScrBood(24,"[Esc]=Return  "+D_UPARR+"=Second date" )
        			@nTop+6, nLef+2 say "               Animals of what sex?" get cGesl pict "!"
      			endif
      			readexit(.t.)
      			set cursor on
      			read
      			set cursor off
      			readexit(.f.)
      			do case
        			case lastkey() == K_ESC
	          			nLoop := 0
        			case lastkey() == K_UP
          				nLoop := 2
        			case lastkey() == K_ENTER
          				nLoop := 4
      			endcase

    		case nLoop == 4
      			//Geslag
      			if cLanType() == "A"
        			fScrBood(23,"Diere met watter WAAR IS_DIER kode moet geselekteer word?")
        			fScrBood(24,"[Esc]=Terug  "+D_UPARR+"=Geslag" )
        			@nTop+8, nLef+2 say "Diere met watter Waar is dier kode?" get cWaar pict "!!"
      			else
        			fScrBood(23,"Animals with what WHERE IS ANIMAL code should be selected?")
        			fScrBood(24,"[Esc]=Return  "+D_UPARR+"=Sex" )
        			@nTop+8, nLef+2 say "Animals with what Where is animal code?" get cWaar pict "!!"
      			endif
      			readexit(.t.)
      			set cursor on
      			read
      			set cursor off
      			readexit(.f.)
      			do case
        			case lastkey() == K_ESC
	          			nLoop := 0
        			case lastkey() == K_UP
    	      			nLoop := 3
        			case lastkey() == K_ENTER
        	  			nLoop := 0
      			endcase
  		endcase
	enddo

	//Bou die soekstring
	if dD001 <> ctod("  /  /  ")
	  	cReturn := cReturn + 'SM3DATA->gebdatum>=ctod("'+dtoc(dD001)+'").and.'
	endif
	if dD002 <> ctod("  /  /  ")
  		cReturn := cReturn + 'SM3DATA->gebdatum<=ctod("'+dtoc(dD002)+'").and.'
	endif
	if cGesl <> " "
	  	cReturn := cReturn + 'SM3DATA->geslag=="'+cGesl+'".and.'
	endif
	if cWaar <> "  "
  		cReturn := cReturn + 'SM3DATA->uitkrede=="'+cWaar+'".and.'
	endif

	//Vat laaste .and. weg
	cReturn := left( cReturn, len( cReturn ) - 5 )

	//Herstel
	fARestScr(aCscr)

return cReturn

