//Example use of tBrowseArray()
//Browse names of files in current directory

#include "directry.ch"
#include "inkey.ch"

#xtrans GetSetBlock( <v> ) => {|x| if( x == NIL, <v>, <v> := x ) }

function testarr

//Veranderlikes
local aDir := directory( "*.*" )
local i
local tba
local c

//Create tBrowse for arrays
tba := tBrowseArray( 10, 20, 15, 32, aDir, GetSetBlock( i ) )

//Define a cloumn for viewing file names
c := tbColumnNew( "FILE NAME", {|| adir[i][F_NAME] } )

c:width := 12

tba:addColumn( c )

@ 09,18 clear to 16,33
@ 09,18 to 16,33 double

tbKeyProcess( tba )

return NIL

/***************************************************************************/
FUNCTION tbKeyProcess( b )
local nKey
while .t.
   while !b:stabilize()
      if nextkey() <> 0
         exit
      endif
   end
   nKey := inkey(0)
   do case
   case nKey == K_UP
        b:up()
   case nKey == K_DOWN
        b:down()
   case nKey == K_PGUP
        b:pageup()
   case nKey == K_PGDN
        b:pagedown()
   case nKey == K_ESC
        exit
   endcase
end
return nKey