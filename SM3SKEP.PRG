//SM3SKEP.PRG
//Program om stoetmeester data om te skakel
//Kopiereg (C) 1993 A van Rensburg
//14:26 03 Feb,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3skep

   //Verklaar
   local cData := ""
   local cFile := ""

    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   //Kyk of dekleer bestaan
   if file(cDd()+"sm3dekd.con")
      //Tydelike dekleer bestaan

      //Skerm
      if cLanType() == "A"
         fScrWbood(24,"Dekdata word omgeskakel")
      else
         fScrWbood(24,"Mating data being converted")
      endif

      //Open leers
      cData := fTOpen(cDd(),"sm3data",,,,.f.)
      if left(cData,1) == "f"
         return NIL
      endif

      //Open leers
      cFile := fTOpen(cDd(),"sm3dekd",,"con")
      if left(cFile,1) == "f"
         fTClose(cData)
         return NIL
      endif
      set relation to SM3DEKD->IDNR into SM3DATA
      go top

      //Gaan deur hele leer
      do while !eof()

         //Skerm
         if lastrec() > 0
            setcolor(cColBott())
            if cLanType() == "A"
               @23,35 say fPercent(recno()/lastrec()) + "% Voltooi"
            else
               @23,35 say fPercent(recno()/lastrec()) + "% Completed"
            endif
            setcolor(cColNorm())
         endif

         //Indien gedek na laaste kalf
         if SM3DEKD->dekdat > SM3DATA->lkalfdatum
            SM3DATA->dekdat    := SM3DEKD->dekdat
            SM3DATA->tipede    := SM3DEKD->tipede
            SM3DATA->bulid     := SM3DEKD->bulid
            SM3DATA->teelgroep := SM3DEKD->teelgroep
         endif

         //Volgende
         select SM3DEKD
         skip

      enddo

      //Sluit leers
      fTClose(cFile)
      fTClose(cData)

      //Vee leer uit
      ferase(cDd()+"sm3dekd.con")

   endif

   //Kyk of fase d bestaan
   if file(cDd()+"sm3fasi.con")
      //Tydelike fase leer bestaan

      //Skerm
      if cLanType() == "A"
         fScrWbood(24,"Fase D data word omgeskakel")
      else
         fScrWbood(24,"Phase D data being converted")
      endif

      //Open leers
      cData := fTOpen(cDd(),"sm3data",,,,.f.)
      if left(cData,1) == "f"
         return NIL
      endif

      //Open leers
      cFile := fTOpen(cDd(),"sm3fasi",,"con")
      if left(cFile,1) == "f"
         fTClose(cData)
         return NIL
      endif
      set relation to SM3FASI->IDNR into SM3DATA
      go top

      //Gaan deur hele leer
      do while !eof()

         //Skerm
         if lastrec() > 0
            setcolor(cColBott())
            if cLanType() == "A"
               @23,35 say fPercent(recno()/lastrec()) + "% Voltooi"
            else
               @23,35 say fPercent(recno()/lastrec()) + "% Completed"
            endif
            setcolor(cColNorm())
         endif

         //Bewaar fase data
         SM3DATA->eindat := SM3FASI->eindat
         SM3DATA->einmas := SM3FASI->einmas
         SM3DATA->daeint := SM3FASI->daeint
         SM3DATA->tydgen := SM3FASI->tydgen
         SM3DATA->rangor := SM3FASI->rangor
         SM3DATA->gdtgdt := SM3FASI->gdtgdt
         SM3DATA->gdtind := SM3FASI->gdtind
         SM3DATA->gdogdo := SM3FASI->gdogdo
         SM3DATA->gdoind := SM3FASI->gdoind

         //Maak ou fase data skoon
         SM3DATA->mas365 := 0
         SM3DATA->gma365 := 0
         SM3DATA->gdo365 := 0
         SM3DATA->ind365 := 0
         SM3DATA->aan365 := 0
         SM3DATA->ple365 := 0
         SM3DATA->oud365 := 0
         SM3DATA->dat365 := ctod("")
         SM3DATA->mas540 := 0
         SM3DATA->gma540 := 0
         SM3DATA->gdo540 := 0
         SM3DATA->ind540 := 0
         SM3DATA->aan540 := 0
         SM3DATA->ple540 := 0
         SM3DATA->oud540 := 0
         SM3DATA->dat540 := ctod("")

         //Volgende
         select SM3FASI
         skip

      enddo

      //Sluit leers
      fTClose(cFile)
      fTClose(cData)

      //Vee leer uit
      ferase(cDd()+"sm3fasi.con")

   endif


   //Herstel
return NIL

