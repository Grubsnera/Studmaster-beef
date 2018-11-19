//SM3WAID.PRG
//Program om waar is dier kodes op te roep
//Kopiereg (C) 1992 A van Rensburg
//16:08 21 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
PROCEDURE sm3waid( cProc, nLine, cVar )
//Program om waar is dier kodes op te roep
//sm3data leer moet oop wees en by die betrokke dier staan

//Verklaar
local cLwid := ""
local lLoop := .t.
local aVelde := {}

//Roep waar is dier program
asize( aVelde, 0 )
aadd( aVelde, { "sm3waar", "kode" })
aadd( aVelde, { "sm3waar", "besk" })
cLwid := sm3waar( 5, 5, 21, aVelde, GetList[20]:varget() )

//Werk sm3data leer by
if len( trim( cLwid ) ) > 0 .and. cVar == "AEENN[21][14]"
   GetList[20]:varput( cLwid )
   GetList[20]:display()
endif

//Herstel
return
