//SM3WISD.PRG
//Program om lewendige diere kodes te vra
//Kopiereg (c) 1993 A van Rensburg
//10:59 27 Feb,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3wisd

   //Verklaar
   local cKode := space(29)
   local nBoxCoor := 0
   local getlist := {}

   //Open leer
   use (cDd()+"STDWAAR") new
   cKode := strtran(left(STDWAAR->velded,29),"."," ")

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   //Vra die kalfboeknommers
   if cLanType() == "A"
      fScrBood( 23 )
      fScrBood( 24, "Tik die waar-is-dier kodes wat aandui dat 'n dier lewendig is." )
      nBoxCoor := fBoxCent(11, space(50),  3, "WAAR-IS-DIER KODES" )
   else
      fScrBood( 23 )
      fScrBood( 24, "Enter the where-is-animal codes that indicate live animals." )
      nBoxCoor := fBoxCent(11, space(50),  3, "WHERE-IS-ANIMAL CODES" )
   endif
   setcolor(cColNorm())
   if cLanType() == "A"
      @ 12, nBoxCoor say "  Waar-is-dier kodes" get cKode pict "!!-!!-!!-!!-!!-!!-!!-!!-!!-!!"
   else
      @ 12, nBoxCoor say "Where-is-animal codes" get cKode pict "!!-!!-!!-!!-!!-!!-!!-!!-!!-!!"
   endif
   set cursor on
   read
   set curs off

   if lastkey() == K_ENTER
      if cKode == space(29) .or. cKode == "  -  -  -  -  -  -  -  -  -  "
      else
         //Bewaar
         STDWAAR->velded := cKode
         cWaarisd(strtran(cKode," ","?"))
      endif
   endif

   //Herstel
   dbcloseall()
return NIL

