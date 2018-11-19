//SM3MEGR.PRG
//Program om groep diere te merk
//Kopiereg (c) 1993 A van Rensburg
//06-25-93 02:08pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3megr(cMark,lSele)

  //Veranderlikes
  local cMerk := ""
  local cHoof := ""
  local cTest := ""

  //Waardes
  lSele := if(lSele==NIL,.t.,lSele)

  //Merk moet bestaan
  if cMark == NIL .or. len(trim(cMark)) == 0
    return NIL
  endif

  if lSele
    //Vra die seleksiegroep
    cTest := sm3selg()
    if len(trim(cTest)) == 0
      if cLanType() == "A"
        fScrWait(24,"Geen seleksie-vereistes is gespesifiseer nie!")
      else
        fScrWait(24,"No selection requirements have been specified!")
      endif
      return NIL
    endif
  else
    //Vra die groep
    cTest := sm3groe()
    if len(trim(cTest)) == 0
      if cLanType() == "A"
        fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
      else
        fScrWait(24,"No group selection requirements have been specified!")
      endif
      return NIL
    endif
  endif

  //Maak dataleers oop
  fScrBood(23)
  if cLanType() == "A"
    fScrWbood(24,"Datalˆers word geopen")
  else
    fScrWbood(24,"Data files being opened")
  endif
  cHoof := fTOpen(cDd(),"sm3data")
  if left(cHoof,1) == "f"
    return NIL
  endif
  cMerk := fTOpen(cDd(),"sm3merk")
  if left(cMerk,1) == "f"
    fTClose(cHoof)
    return NIL
  endif

  //Soek die merk in merke leer
  seek cMark
  if eof()
    if cLanType() == "A"
      fScrBood(23,"Merk onbekend!")
    else
      fScrBood(23,"Mark unknown!")
    endif
    fScrWait(24)
    fTClose(cMerk)
    fTClose(cHoof)
    return NIL
  endif
  select SM3DATA
  go top

  //Skerm
  fScrBood(23,"Aantal gemerk: "+ltrim(str(SM3MERK->aant)))
  fScrWbood(24,"Diere word uitgesoek en gemerk met "+cMark)

  //Gaan deur hele leer
  do while !eof()

    //Indien voldoen aan vereistes
    if &cTest
      do while !rlock()
      enddo
      if SM3DATA->toggle1 <> cMark
        SM3DATA->toggle1 := cMark
        //Bewaar merk in merke leer
        select SM3MERK
        do while !rlock()
        enddo
        SM3MERK->aant++
      else
        SM3DATA->toggle1 := cMark
      endif
    endif

    select SM3DATA
    skip

  enddo

  //Herstel
  fTClose(cMerk)
  fTClose(cHoof)
  return NIL

