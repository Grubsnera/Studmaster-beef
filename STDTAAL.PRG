//STDTAAL.PRG
//Program om taal te verander
//Kopiereg (c) 1991 A van Rensburg
//09:28 17 Sep,1992

#include "inkey.ch"

//*************************************************************************/
FUNCTION stdtaal

//Veranderlikes
local lLogic := .t.
local cTaal

if cLanType() == "A"
    fScrOpsk( , "Opsie "+cOption())
else
    fScrOpsk( , "Option "+cOption())
endif

//Open leer
cTaal := fTOpen( cDd(), "STDWAAR", , , , .f., .f. )
if left( cTaal, 1 ) == "f"
   return NIL
endif

//Verander taal
if STDWAAR->lantyp == "A"
  STDWAAR->lantyp := "E"
  cLanType("E")
else
  STDWAAR->lantyp := "A"
  cLanType("A")
endif

fTClose( cTaal )
return NIL

