//SM3FASB.PRG
//Program om beginmassas te bewaar
//Kopiereg (C) 1993 A van Rensburg
//04-20-93 12:17pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3fasb

   //Verklaar
   local cFasg := ""
   local cFasd := ""
   local cData := ""
   local cWeeg := ""
   local nAmou := 0
   local nAant := 0
   local nTota := 0
   local nBoxc := 0
   local aSend := {}
   local aRecv := {}
   local i     := 0
   local dDate := ctod("")
   local getlist := {}

   //Berei die fasegroep voor
   cFasg := sm3fasf()
   if len(trim(cfasg)) <= 0
	  cOption(-1)
	  return NIL
   endif

   // Screen
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   //Toets of data gevind is
   ferase(cDd()+"fasd"+cIndeExt())
   cFasd := fTOpen(cDd(),"fasd")
   if left(cFasd,1) == "f"
	  cOption(-1)
      return NIL
   endif

   if lastrec() <= 0
      fTClose(cFasd)
      if cLanType() == "A"
         fScrBood(23,"Geen diere vir Fase D berekeninge gevind nie!")
      else
         fScrBood(23,"No animals found for Phase D calculations!")
      endif
      fScrWait(24)
	  cOption(-1)
      return NIL
   endif

   //Kry velde
   aadd(aSend,{"sm3data","idnr"})
   aadd(aSend,{"sm3data","begdatum"})
   aadd(aSend,{"sm3data","begmassa"})

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open dataleers
   if cLanType() == "A"
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrWbood( 24, "Data files being opened" )
   endif
   cWeeg := fTOpen(cDd(),"sm3weeg")
   if left(cWeeg,1) == "f"
      fTClose(cFasd)
	  cOption(-1)
      return NIL
   endif
   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      fTClose(cWeeg)
      fTClose(cFasd)
	  cOption(-1)
      return NIL
   endif
   select FASD
   go top
   set relation to FASD->IDNR into SM3DATA

   //Bereken syfers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Totale en gemiddeldes word bereken")
   else
      fScrWbood(24,"Totals and averages being calculated")
   endif
   do while !eof()
      nAmou++
      if SM3DATA->begmassa > 0
         nAant++
         nTota += SM3DATA->begmassa
      endif
      //Volgende
      select FASD
      skip
   enddo
   go top

   //Teken skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(6,space(50),13,"FASE D BEGINMASSA EN DATUM")
      @ 7,nBoxc say "           Fasegroep"
      @ 8,nBoxc say "Aant. diere in groep"
      @ 9,nBoxc say "    Diere met massas"
      @10,nBoxc say " Gem. massa per dier"
      @11,nBoxc say "        Totale massa"
   else
      nBoxc := fBoxCent(6,space(50),13,"PHASE D STARTING MASS AND DATE")
      @ 7,nBoxc say "         Phase group"
      @ 8,nBoxc say "No. animals in group"
      @ 9,nBoxc say " Animals with masses"
      @10,nBoxc say " Ave.mass per animal"
      @11,nBoxc say "          Total mass"
   endif
   @13,nBoxc say repl("Ä",52)
   @15,nBoxc say aRecv[1,6]

   //Die loop
   do while !eof()

      //Skerm
      setcolor(cColInve())
      @ 7,nBoxc+21 say cFasg
      @ 8,nBoxc+21 say str(nAmou,10,0)
      @ 9,nBoxc+21 say str(nAant,10,0)
      if nAant > 0
         @10,nBoxc+21 say str(nTota/nAant,10,0)
      else
         @10,nBoxc+21 say str(0,10,0)
      endif
      @11,nBoxc+21 say str(nTota,10,0)
      @15,nBoxc+21 say SM3DATA->idnr
      setcolor(cColNorm())

      //Totale en gemiddeldes trek af
      if SM3DATA->begmassa > 0
         nAant := nAant - 1
         nTota := nTota - SM3DATA->begmassa
      endif

      //Lees die huidige dier se data
      select SM3DATA
      for i := 1 to len(aRecv)
         aRecv[i,14] := fieldget(aRecv[i,13])
      next
      select FASD

      if dDate <> ctod("")
         aRecv[2,14] := dDate
      endif

      //Vra die vrae
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  [PgUp]=Vorige dier  [F1]=Hulp")
         fScrBood(24,"Tik die Fase D beginmassa en weegdatum!")
      else
         fScrBood(23,"[Esc]=Menu  [PgUp]=Previous animal  [F1]=Help")
         fScrBood(24,"Type the Phase D starting mass and weigh date!")
      endif
      @16,nBoxc say aRecv[2,6] get aRecv[2,14] pict aRecv[2,10]
      @17,nBoxc say aRecv[3,6] get aRecv[3,14] pict aRecv[3,10]
      set cursor on
      read
      set cursor off

      //Totale en gemiddeldes
      if aRecv[3,14] > 0
         nAant++
         nTota += aRecv[3,14]
      endif

      //Keys
      do case

         case lastkey() == K_ESC
            //Escaped - return
            go bottom
            skip
            loop

         case lastkey() == K_ENTER

            //Entered - bewaar
            select SM3DATA
            do while !rlock()
            enddo
            for i := 2 to len(aRecv)
               fieldput(aRecv[i,13],aRecv[i,14])
            next
            dDate := aRecv[2,14]

            //Bewaar vorige massa
            if SM3DATA->vormassa == 0 .and. SM3DATA->vordatum == ctod("")
               SM3DATA->vormassa := aRecv[3,14]
               SM3DATA->vordatum := aRecv[2,14]
            endif

            //Bewaar eind massa
            if SM3DATA->einmas == 0 .and. SM3DATA->eindat == ctod("")
               SM3DATA->einmas := aRecv[3,14]
               SM3DATA->eindat := aRecv[2,14]
            endif

            //Totale en gemiddeldes
            if SM3DATA->begmassa > 0 .and. SM3DATA->begdatum <> ctod("")
               select SM3WEEG
               seek SM3DATA->idnr + dtos(SM3DATA->begdatum)
               if eof()
                  append blank
               endif
               do while !rlock()
               enddo
               SM3WEEG->idnr := SM3DATA->idnr
               SM3WEEG->massa := SM3DATA->begmassa
               SM3WEEG->weegdatum := SM3DATA->begdatum
            endif

            select FASD
            skip

            //Waarsku indien laaste dier
            if eof()
               if cLanType() == "A"
                  fScrBood(23,"Hierdie is die laaste dier van die groep!")
                  fScrBood(24,"Druk enige sleutel...")
               else
                  fScrBood(23,"This is the last animal in the group!")
                  fScrBood(24,"Press any key...")
               endif
               inkey(0)
            else
               keyboard chr(K_ENTER)
            endif

         case lastkey() == K_PGUP
            //Page up - vorige dier
            select FASD
            skip -1
            if bof()
               go top
            endif
            keyboard chr(K_ENTER)

      endcase

   enddo

   //Herstel
   cOption(-1)
   fTClose(cFasd)
   fTClose(cData)
   fTClose(cWeeg)

return NIL

