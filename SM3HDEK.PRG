//SM3HDEK.PRG
//Program om handdek datums te bewaar
//Kopiereg (c) 1992 A van Rensburg
//20:19 28 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION sm3hdek

   //Veranderlikes
   local aSend := {}
   local aHdek := {}
   local cData := ""
   local nBoxc := 0
   local lLoop := .t.
   local i     := 1
   local nReko := 0
   local dCdat := ctod("")
   local getlist := {}

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrOpsk(,"Option "+cOption())
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aadd(aSend,{"sm3data","idnr"    })            //1
   aadd(aSend,{"sm3data","dekdat"  })            //2
   aHdek := fGetField(aSend)

   //Datalˆers word geopen
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(10,space(50),5,"HANDDEK DATUM")
   else
      nBoxc := fBoxCent(10,space(50),5,"HAND-MATED DATE")
   endif
   @11,nBoxc say aHdek[ 1][6]
   @13,nBoxc say aHdek[ 2][6]

   lLoop := .t.
   do while lLoop

      //Koeinommer

      //Maak velde skoon
      go bottom
      skip
      for i = 1 to len(aHdek)
         aHdek[i][14] := fieldget(aHdek[i][13])
      next

      //Vertoon
      setcolor(cColInve())
      @11,nBoxc+21 say transform(aHdek[ 1][14],aHdek[ 1][10])
      @13,nBoxc+21 say transform(aHdek[ 2][14],aHdek[ 2][10])
      setcolor(cColNorm())

      //Gaan na vorige rekord
      if nReko > 0
         goto nReko
      endif

      //Vra die koeinommer
      if cLanType() == "A"
         aHdek[1][14] := sm3idnr( aHdek[1][14],11,nBoxc,"Koei id nommer","Tik koei se id nommer waarvan die handdek datum bekend is.",,,.t.)
      else
         aHdek[1][14] := sm3idnr( aHdek[1][14],11,nBoxc,"Cow id number","Type id number of cow where hand-mate date is known.",,,.t.)
      endif

      do case

         case aHdek[1][14] == "CANCELLED   "
            //Escaped
            lLoop := .f.

         case aHdek[1][14] == "NOTHING     "
            //Geen nommer gekies
            lLoop := .f.

         otherwise
            //Gaan voort
            nReko := recno()

            //Geslag
            if SM3DATA->geslag <> "1"
               if cLanType() == "A"
                  fScrBood(23,"Koei is op rekenaar as 'n manlike dier!")
               else
                  fScrBood(23,"Cow is on computer as a male animal!")
               endif
               fScrWait(24)
               loop
            endif

            //Koei moet gedek wees
            if SM3DATA->dekdat <> ctod("") .and. ;
                  SM3DATA->tipede $ "12"
            else
               if cLanType() == "A"
                  fScrBood(23,"Koei moet reeds natuurlik gedek wees!")
               else
                  fScrBood(23,"Cow has already been mated naturally!")
               endif
               fScrWait(24)
               loop
            endif

            //Vra die handdek datum
            dCdat := SM3DATA->dekdat
            aHdek[2][14] := SM3DATA->dekdat
            @13,nBoxc say aHdek[ 2][6] get aHdek[ 2][14] pict aHdek[ 2][10]
            set cursor on
            read
            set cursor off
            if lastkey() == K_ESC .or. aHdek[2][14] == ctod("")
               aHdek[2][14] := dCdat
            endif
            //Bewaar
            do while !rlock()
            enddo
            SM3DATA->dekdat := aHdek[2][14]

      endcase

   enddo

   //Herstel
   fTClose(cData)
return NIL

