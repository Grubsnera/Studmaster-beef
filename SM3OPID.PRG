//SM3OPID.PRG
//Program om waar is dier kodes op te roep
//Kopiereg (C) 1992 A van Rensburg
//16:08 21 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
PROCEDURE sm3opid( cProc, nLine, cVar )
//Program om opmerkingskodes op te roep
//sm3data leer moet oop wees en by die betrokke dier staan

//Verklaar
local cOpme := ""
local lLoop := .t.
local aVelde := {}
local cData := ""

//Roep opmerkings program
asize( aVelde, 0 )
aadd( aVelde, { "sm3opmk", "kode" })
aadd( aVelde, { "sm3opmk", "besk" })
if left( Getlist[18]:varget(), 2 ) <> "  "
   cOpme := sm3opme( 5, 5, 21, aVelde, left( GetList[18]:varget(), 2 ) )
elseif left( Getlist[19]:varget(), 2 ) <> "  "
   cOpme := sm3opme( 5, 5, 21, aVelde, left( GetList[19]:varget(), 2 ) )
else
   cOpme := sm3opme( 5, 5, 21, aVelde )
endif

//Werk sm3data leer by
if len( trim( cOpme ) ) > 0 .and. cVar == "AEENN[19][14]"
   cData := GetList[18]:varget()
   if cOpme $ cData .or. cOpme $ GetList[19]:varget()
   else
      if cData == space(14)
         cData := "  -  -  -  -  "
      endif
      cData := strtran( cData, "  ", cOpme, 1, 1 )
      GetList[18]:varput( cData )
      GetList[18]:display()
   endif
endif

//Werk sm3data leer by
if len( trim( cOpme ) ) > 0 .and. cVar == "AEENN[20][14]"
   cData := GetList[19]:varget()
   if cOpme $ cData .or. cOpme $ GetLIst[18]:varget()
   else
      if cData == space(14)
         cData := "  -  -  -  -  "
      endif
      cData := strtran( cData, "  ", cOpme, 1, 1 )
      GetList[19]:varput( cData )
      GetList[19]:display()
   endif
endif

//Herstel
return
