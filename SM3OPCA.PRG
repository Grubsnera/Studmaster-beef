//SM3OPCA.PRG
//Program om opsommende deklys voor te berei
//Kopiereg (c) 1992 A van Rensburg
//21:55 14 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION sm3opca(cFind)

   //Veranderlikes
   local cCscr := savescreen(23,0,24,79)
   local lRetu := .f.
   local cDeko := ""
   local cDekk := ""
   local cData := " "
   local lKalw := .f.

   //Open dataleers
   fScrBood(23)
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrOpsk( , "Option "+cOption())
      fScrWbood(24,"Data files being opened")
   endif

   cDeko := fTOpen(cDd(),"sm3deko",,,,.f.)
   if left(cDeko,1) == "f"
      return lRetu
   endif
   //Maak leer skoon
   zap

   cDekk := fTOpen(cDd(),"sm3dekk")
   if left( cDekk, 1 ) == "f"
      fTClose(cDeko)
      return lRetu
   endif
   set order to 2

   //Skuif die databasis
   if cFind == NIL
      fTClose(cDeko)
      fTClose(cDekk)
      return lRetu
   else
      seek cFind
      if eof()
         fTClose(cDeko)
         fTClose(cDekk)
         return lRetu
      endif
   endif

   //Maak rekord oop vir Totale teelgroep
   lRetu := .t.
   select SM3DEKO
   append blank
   SM3DEKO->teelgroep := cFind

   //Soek diere
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kalfseisoen se berekeninge word gedoen!")
   else
      fScrWbood(24,"Calving season calculations being done!")
   endif

   //Die loop
   select SM3DEKK
   do while SM3DEKK->teelgroep == cFind

      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say SM3DEKK->idmoer + "(Rondte 2)"
      else
         @23,35 say SM3DEKK->idmoer + "(Round 2)"
      endif
      setcolor(cColNorm())

      //Toets datumin wel bestaan
      if SM3DEKK->datumin == ctod("")
         skip
         loop
      endif

      // Dekopsommingleer
      select SM3DEKO
      go top

      // Aantal dekkings totale groep
      SM3DEKO->aandek++

      // Aantal koeie
      if SM3DEKK->idmoer <> cData

         cData := SM3DEKK->idmoer
         lKalw := .f.
         SM3DEKO->aankoe++

      	// Aantal dragtig
      	if SM3DEKK->dragtig $ "JY123456*"
         	SM3DEKO->aandra++
      	endif

      	//Aantal kalwings
      	if SM3DEKK->kalwer > 0 .and. !lKalw
         	lKalw := .t.
         	SM3DEKO->aangeb+= SM3DEKK->kalwer
         	SM3DEKO->aanspe+= SM3DEKK->speenn
         	SM3DEKO->aanwaa+= SM3DEKK->waaris
         	if SM3DEKK->vaarkode == "3"
            	SM3DEKO->aankii+= SM3DEKK->kalwer
         	elseif SM3DEKK->vaarkode == "4"
            	SM3DEKO->aanino+= SM3DEKK->kalwer
         	else
            	SM3DEKO->aannat+= SM3DEKK->kalwer
         	endif
      	endif
      endif


      select SM3DEKK
      skip

   enddo

   //Verskeie bulle se syfers
   select SM3DEKK
   set order to 3
   seek cFind
   cData := " "

   do while SM3DEKK->teelgroep == cFind

      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say SM3DEKK->idmoer + "(Rondte 3)"
      else
         @23,35 say SM3DEKK->idmoer + "(Round 3)"
      endif
      setcolor(cColNorm())

      //Toets datumin wel bestaan
      if SM3DEKK->datumin == ctod("")
         skip
         loop
      endif

      //Dekopsommingleer
      select SM3DEKO

      //Kyk of bul bestaan
      seek cFind+SM3DEKK->idvaar
      if eof()
         append blank
         SM3DEKO->teelgroep := cFind
         Sm3DEKO->idvaar    := SM3DEKK->idvaar
         cData := " "
      endif

      //Aantal dekkings een bul
      SM3DEKO->aandek++

      //Aantal koeie
      if SM3DEKK->idmoer <> cData
         cData := SM3DEKK->idmoer
         lKalw := .f.
         SM3DEKO->aankoe++

      	//Aantal dragtig
      	if SM3DEKK->dragtig $ "JY123456*"
         	SM3DEKO->aandra++
      	endif

      	//Aantal kalwings
      	if SM3DEKK->kalwer > 0 .and. !lKalw
         	lKalw := .t.
         	SM3DEKO->aangeb+= SM3DEKK->kalwer
         	SM3DEKO->aanspe+= SM3DEKK->speenn
         	SM3DEKO->aanwaa+= SM3DEKK->waaris
         	if SM3DEKK->vaarkode == "3"
            	SM3DEKO->aankii+= SM3DEKK->kalwer
         	elseif SM3DEKK->vaarkode == "4"
            	SM3DEKO->aanino+= SM3DEKK->kalwer
         	else
            	SM3DEKO->aannat+= SM3DEKK->kalwer
         	endif
      	endif
      endif

      select SM3DEKK
      skip

   enddo

   //Bereken persentasies
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Persentasies word bereken")
   else
      fScrWbood(24,"Percentages being calculated")
   endif
   select SM3DEKO
   go top
   do while !eof()

      SM3DEKO->perdra := val(fpercent(SM3DEKO->aandra,SM3DEKO->aankoe))
      SM3DEKO->pergeb := val(fpercent(SM3DEKO->aangeb,SM3DEKO->aankoe))
      SM3DEKO->pernat := val(fpercent(SM3DEKO->aannat,SM3DEKO->aangeb))
      SM3DEKO->perkii := val(fpercent(SM3DEKO->aankii,SM3DEKO->aangeb))
      SM3DEKO->perino := val(fpercent(SM3DEKO->aanino,SM3DEKO->aangeb))
      SM3DEKO->perspe := val(fpercent(SM3DEKO->aanspe,SM3DEKO->aankoe))
      SM3DEKO->perspg := val(fpercent(SM3DEKO->aanspe,SM3DEKO->aangeb))

      skip
   enddo

   //Herstel
   fTClose(cDeko)
   fTClose(cDekk)
   restscreen(23,0,24,79)
return lRetu
