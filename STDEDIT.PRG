//STDEDIT.PRG
//Program om editor op te roep
//Kopiereg (c) 1992 A van Rensburg
// 8:26pm Sep 27,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
PROCEDURE stdedit

   //Verklaar
   local cCurScr := savescreen(0,0,24,79)
   local cPath := ""

   //Kry die dos path
   cPath = gete("PATH")
   if len(alltrim(cPath)) > 0
      set path to (cPath)
   endif

   //Editor
   if file("me.exe")
      //Multi-Edit
      swpruncmd("me")
   elseif file("ne.com")
      //Norton editor
      swpruncmd("ne &(cFileNam())")
   elseif file("edit.com")
      //Dos editor
      swpruncmd("edit &(cFileNam())")
   endif

   //Herstel
   set path to
   restscreen(0,0,24,79,cCurScr)
return

