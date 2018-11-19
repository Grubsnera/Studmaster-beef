//Fasegrp.prg
//Program om fase B data wat met die V4.00 weergawe van die beesprogram
//na Fase C & D plekke geskuif is, terug te skuif na die Fase B plekke.
//05-13-94 09:32pm

/*
Mnr. Sigwart van Namibia 05-13-94 09:33pm
*/

/****************************************************************************/
FUNCTION fasegrp(cData)

   //Verklaar
   local cFile := ""

   //Omgewing
   set talk off
   clear screen

   //Waardes
   cData := if(cData==NIL,"c:\sm3\",cData)

   //Open die datalˆer
   cFile := cData+"sm3data"
   use (cFile)

   //Loop
   do while !eof()

      //Skerm
      @5,5 say str((recno()/lastrec())*100,3,0) + "% Voltooi"

      //Slegs diere met fasekodes wat nie C & D is nie
      if !empty(SM3DATA->fasekode)
         if "C" $ SM3DATA->fasekode .or. "D" $ SM3DATA->fasekode
         else
            SM3DATA->dat365 := SM3DATA->eindat
            SM3DATA->mas365 := SM3DATA->einmas
            SM3DATA->oud365 := SM3DATA->daeint
            SM3DATA->aan365 := SM3DATA->tydgen
            SM3DATA->ple365 := SM3DATA->rangor
            SM3DATA->gdo365 := SM3DATA->gdtgdt
            SM3DATA->ind365 := SM3DATA->gdtind
            SM3DATA->gdo540 := SM3DATA->gdogdo
            SM3DATA->ind540 := SM3DATA->gdoind
            if empty(SM3DATA->indekskode)
               SM3DATA->indekskode := SM3DATA->fasekode
            endif
            SM3DATA->fasekode := space(6)
            SM3DATA->eindat := ctod("")
            SM3DATA->einmas := 0
            SM3DATA->daeint := 0
            SM3DATA->tydgen := 0
            SM3DATA->rangor := 0
            SM3DATA->gdtgdt := 0
            SM3DATA->gdtind := 0
            SM3DATA->gdogdo := 0
            SM3DATA->gdoind := 0
         endif
      endif

      //Volgende
      select sm3data
      skip

   enddo

   //Einde
   dbcloseall()
   return NIL
