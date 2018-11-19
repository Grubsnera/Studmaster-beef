//SM3LABG.PRG
//Program om grootte van plakkers te bepaal
//Kopiereg (c) 1992 A van Rensburg
//17:56 10 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3labg

	//Verklaar
	local i   := 0
	local j   := 0
	local s   := "123456789="
   	local aCscr  := {}
	local nCh := 1

	//Menu
	nCh := fNewMenu( nCh, "SM3LABG" )
	if nCh == 0
	   	return NIL
	endif

    aCscr := fASaveScr()
  	if cLanType() == "A"
		fScrOpsk(1,"Opsie "+cOption(nCh))
	else
		fScrOpsk(1,"Option "+cOption(nCh))
	endif

	//Toets of drukker gereed is
	if fPrnReady() == K_ESC
	   	return NIL
	endif

	fPrnOn()
	do case
  		case nCh == 2
    		fPrnCod( cPrnCond() )
    		s := repl( s, 13 )
  		case nCh == 3
    		fPrnCod( cPrnNorm() )
    		s := repl( s, 4 )
  		otherwise
    		fPrnCod( cPrnNorm() )
    		s := repl( s, 8 )
	endcase

	fPrnOff()
	set print on
	set cons off
	for i = 1 to 20
    	? s
	next
	set cons on
	set print off

	fPrnOn()
	fPrnCod( cPrnNorm() )
	fPrnOff()

	//Herstel
	cOption(-1)
    fARestScr(aCscr)

return NIL

