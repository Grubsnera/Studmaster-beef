//SM3LOAD.PRG
//Program om stoetmeester data om te skakel
//Kopiereg (C) 1992 A van Rensburg
//06-20-93 03:53am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3load

//Verklaar
local cCscr := savescreen(0,0,24,79)
local cFiln := ""
local cIndn := ""
local aFiel := {}
local cData := ""
local lCont := .t.
local cVel1 := ""
local cVel2 := ""
local cVel3 := ""

//Dekbesonderhede*****************************/

//Kyk of dekleer bestaan
if file(cDd()+"sm3dekk.dbf") .and. !file(cDd()+"sm3dekd.con")

  //Skerm
  fScrBood(23)
  if cLanType() == "A"
    fScrWbood(24,"Dekdatums word bewaar")
  else
    fScrWbood(24,"Mating dates being saved")
  endif

  //Kyk of leer bestaan
  cFiln := cDd()+"sm3dekd.con"
  if !file(cFiln)
    //Skep dekdatums
    asize(aFiel,0)
    aadd(aFiel,{"idnr"     ,"C",12,0})
    aadd(aFiel,{"dekdat"   ,"D", 8,0})
    aadd(aFiel,{"tipede"   ,"C", 1,0})
    aadd(aFiel,{"bulid"    ,"C",12,0})
    aadd(aFiel,{"teelgroep","C",12,0})
    dbcreate(cFiln,aFiel)
  endif

  //Open .dbf
  ferase(cDd()+"sm3dekd"+cIndeExt())
  dbusearea(.t.,,cDd()+"sm3dekd.con")
  if neterr()
    dbcloseall()
  else

    //Indeks leer
    cIndn := cDd()+"sm3dekd"+ordbagext()
    index on sm3dekd->idnr to (cIndn)

    //Open dekleer
    dbusearea(.t.,,cDd()+"sm3dekk")
    if neterr()
      dbcloseall()
    else
      //Loop deur hele leer
      do while !eof()
        cData := SM3DEKK->idmoer
        if len(alltrim(cData)) > 0
          select SM3DEKD
          seek cData
          if eof()
            append blank
          endif
          if SM3DEKK->datumin > SM3DEKD->dekdat
            do while !rlock()
            enddo
            SM3DEKD->idnr := SM3DEKK->idmoer
            SM3DEKD->dekdat := SM3DEKK->datumin
            SM3DEKD->tipede := SM3DEKK->vaarkode
            SM3DEKD->bulid := SM3DEKK->idvaar
            SM3DEKD->teelgroep := SM3DEKK->teelgroep
          endif
          select SM3DEKK
        endif
        skip
      enddo
      dbcloseall()

    endif

  endif

endif

//Herstel
dbcloseall()

//Fase d data*******************/

//Kyk of hoofleer bestaan
if file(cDd()+"sm3data.dbf") .and. !file(cDd()+"sm3fasi.con")

  //Skerm
  fScrBood(23)
  if cLanType() == "A"
    fScrWbood(24,"Fase C&D data word uitgesoek")
  else
    fScrWbood(24,"Phase C&D data being sorted")
  endif

  //Kyk of leer bestaan
  cFiln := cDd()+"sm3fasi.con"
  if !file(cFiln)
    //Skep indeksgroepe
    asize(aFiel,0)
    aadd(aFiel,{"idnr"    ,"C",12,0})
    aadd(aFiel,{"fasekode","C", 6,0})
    aadd(aFiel,{"eindat"  ,"D", 8,0})
    aadd(aFiel,{"einmas"  ,"N", 3,0})
    aadd(aFiel,{"daeint"  ,"N", 3,0})
    aadd(aFiel,{"tydgen"  ,"N", 3,0})
    aadd(aFiel,{"rangor"  ,"N", 3,0})
    aadd(aFiel,{"gdtgdt"  ,"N", 4,0})
    aadd(aFiel,{"gdtind"  ,"N", 3,0})
    aadd(aFiel,{"gdogdo"  ,"N", 4,0})
    aadd(aFiel,{"gdoind"  ,"N", 3,0})
    dbcreate(cFiln,aFiel)
  endif

  //Open .dbf
  ferase(cDd()+"sm3fasi"+cIndeExt())
  dbusearea(.t.,,cDd()+"sm3fasi.con")
  if neterr()
    dbcloseall()
  else

    //Indeks leer
    cIndn := cDd()+"sm3fasi"+ordbagext()
    index on sm3fasi->idnr to (cIndn)

    //Open dekleer
    dbusearea(.t.,,cDd()+"sm3data")
    if neterr()
      dbcloseall()
    else
      //Loop deur hele leer
      do while !eof()
        if SM3DATA->fasekode <> "      "
          cData := SM3DATA->idnr
          if len(alltrim(cData)) > 0
            select SM3FASI
            seek cData
            if eof()
              append blank
            endif
            do while !rlock()
            enddo
            SM3FASI->idnr     := SM3DATA->idnr
            SM3FASI->fasekode := SM3DATA->fasekode
            SM3FASI->eindat   := SM3DATA->dat365
            SM3FASI->einmas   := SM3DATA->mas365
            SM3FASI->daeint   := SM3DATA->oud365
            SM3FASI->tydgen   := SM3DATA->aan365
            SM3FASI->rangor   := SM3DATA->ple365
            SM3FASI->gdtgdt   := SM3DATA->gdo365
            SM3FASI->gdtind   := SM3DATA->ind365
            SM3FASI->gdogdo   := SM3DATA->gdo540
            SM3FASI->gdoind   := SM3DATA->ind540
          endif
        endif
        select SM3DATA
        skip
      enddo
      dbcloseall()

    endif

  endif

endif
dbcloseall()

return NIL
