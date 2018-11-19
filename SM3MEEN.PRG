//SM3MEEN.PRG
//Program om enkel diere te merk
//Kopiereg (c) 1993 A van Rensburg
//06-24-93 06:05am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3meen(cMark)

   //Veranderlikes
   local cMerk := ""
   local cHoof := ""
   local nBoxc := 0
   local lLoop := .t.
   local cIdnr := space(12)

   //Merk moet bestaan
   if cMark == NIL .or. empty(alltrim(cMark))
      return NIL
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

   //Skerm
   if cLanType() == "A"
	  fScrOpsk(,"Opsie "+cOption())
      nBoxc := fBoxCent(11,space(33),3,"MERK ENKEL DIERE")
   else
	  fScrOpsk(,"Option "+cOption())
      nBoxc := fBoxCent(11,space(33),3,"MARK SINGLE ANIMALS")
   endif

   //Die loop
   lLoop := .t.
   do while lLoop

      //Vra die Id nommer om te merk
      select SM3DATA
      cIdnr := sm3idnr(,12,nBoxc)

      do case

         case "CANCELLED" $ cIdnr
            //Escaped
            lLoop := .f.

         case "NOTHING" $ cIdnr
            //Nothing
            lLoop := .f.

         case SM3DATA->toggle1 == cMark
            //Merk dieselfde - los net so

         case empty(SM3DATA->toggle1)
            //Bewaar merk in hoofleer
            do while !rlock()
            enddo
            SM3DATA->toggle1 := cMark
            //Bewaar merk in merke leer
            select SM3MERK
            do while !rlock()
            enddo
            SM3MERK->aant++

         case !(empty(SM3DATA->toggle1))
            //Dier reeds gemerk met ander tipe merk
            //Op die oomblik dieselfde as geen merk
            //Bewaar merk in hoofleer
            do while !rlock()
            enddo
            SM3DATA->toggle1 := cMark
            //Bewaar merk in merke leer
            select SM3MERK
            do while !rlock()
            enddo
            SM3MERK->aant++

      endcase

   enddo

   //Herstel
   fTClose(cMerk)
   fTClose(cHoof)
return NIL

