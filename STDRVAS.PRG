//STDRVAS.PRG
//Program om vaste inligting te bewaar
//Kopiereg (c) 1991 A van Rensburg
//18:26 15 Nov,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION stdrvas()

//Veranderlikes
LOCAL nCh := 1                                   //Keuse tussen een of alle dataleers
LOCAL lMor
LOCAL cScr

lMor := .T.
do while lMor

  //Sluit alle .dbf leers
  close all

  // Vertoon hulpskerm
  if cLanType() == "A"
    fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Menu." )
  else
    fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Menu." )
  endif

  // Kry opsienommer
  nCh := fNewMenu( nCh, "STDRVAS" )

  // Bewaar skerm
  cScr := savescreen(0,0,24,79)

  //Die opsies
  do case

    case nCh = 0
      // Exit
      return NIL

    case nCh = 1
      //Skermkleure
      stdcolo()

    case nCh = 2
      //Drukkerkodes
      stddruk()

  endcase

  //Herstel
  restscreen(0,0,24,79,cScr)

enddo

return NIL

