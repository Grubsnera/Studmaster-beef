//SM3INKU.PRG
//Program om diere in kudde uit te soek
//Kopiereg (C) 1992 A van Rensburg
//10:16 13 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3inku

//Verklaar
local cCscr := savescreen(0,0,24,79)
local cInku := cDd()+"sm3inku.dbf"
local cData := ""

//Skerm
fScrBood(23)
if cLanType() == "A"
   fScrWbood(24,"In kudde diere word uitgesoek")
else
   fScrWbood(24,"In herd animals being selected")
endif

//Open .dbf
cData := fTOpen(cDd(),"sm3data")
if left( cData, 1 ) == "f"
   return NIL
endif

//Soek uit
copy to (cInku) fields idnr,idvaar for SM3DATA->uitkrede $ cWaarisd()

//Herstel
fTClose(cData)
restscreen(0,0,24,79,cCscr)
return NIL
