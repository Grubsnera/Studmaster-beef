//SM3DENA.PRG
//Program om natuurlike dekkings te bewaar
//Kopiereg (c) 1992 A van Rensburg
//11:26 22 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3dena(aRecv,nBoxc)

   //Funksie om natuurlike dekkings te vra

   //Verklaar
   local getlist := {}
   local nLoop   := 1
   local nKoer   := 0
   local i       := 0
   local aStam   := {}
   local aBroe   := {}
   local aSeun   := {}
   local cBood   := ""

   //Databasis
   select SM3DATA
   go top

   //Die vrae
   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Begindatum
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Kalfseisoen  [F1]=Hulp")
               fScrBood(24,"Tik die datum waarop die bul by die koeie gesit is.")
            else
               fScrBood(23,"[Esc]=Calving season  [F1]=Help")
               fScrBood(24,"Type the date when the bull was put with the cows.")
            endif
            //Vra
            @11,nBoxc say aRecv[4][6] get aRecv[4][14] pict aRecv[4][10]
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Nou
            do case
               case lastkey() == K_ESC
                  arecv[1][14] := "ESCAPED     "
                  nLoop := 0
               case lastkey() == K_UP
                  arecv[1][14] := "UPARROW     "
                  nLoop := 0
               case aRecv[4][14] == ctod("")
                  if cLanType() == "A"
                     fScrBood(23,"Datum in is verpligtend!")
                  else
                     fScrBood(23,"Date in is compulsory!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 2
            //Datum uit
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Kalfseisoen  [F1]=Hulp")
               fScrBood(24,"Tik die datum waarop die bul by die koeie weggeneem is.")
            else
               fScrBood(23,"[Esc]=Calving season  [F1]=Help")
               fScrBood(24,"Type the date when the bull left the cows.")
            endif
            //Vra
            @12,nBoxc say aRecv[5][6] get aRecv[5][14] pict aRecv[5][10]
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Nou
            do case
               case lastkey() == K_ESC
                  arecv[1][14] := "ESCAPED     "
                  nLoop := 0
               case lastkey() == K_UP
                  nLoop--
               case aRecv[5][14] == ctod("")
                  if cLanType() == "A"
                     fScrBood(23,"Datum uit is verpligtend!")
                  else
                     fScrBood(23,"Date out is compulsory!")
                  endif
                  fScrWait(24)
               case aRecv[5][14] < aRecv[4][14]
                  if cLanType() == "A"
                     fScrBood(23,"Datum uit mag nie vroe‰r as die datum in wees nie!")
                  else
                     fScrBood(23,"Date out may not be earlier than date in!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 3
            //Koeinommer
            select SM3DATA
            if len(trim(cTest)) > 0
               //Seleksiegroep
               if cLanType() == "A"
                  fScrBood(23,"[Esc]=Stop proses")
                  fScrWbood(24,"Groep koeie om te dek word uitgesoek")
               else
                  fScrBood(23,"[Esc]=Stop process")
                  fScrWbood(24,"Sorting group of cows to be mated")
               endif
               do while !eof()
                  if &cTest. .and. SM3DATA->geslag == "1" .and. SM3DATA->idnr <> space(12)
                     exit
                  endif
                  skip
               enddo
               if inkey() == K_ESC
                  go bottom
                  skip
               endif
               if eof()
                  nLoop := 0
                  loop
               endif
               aRecv[1][14] := SM3DATA->idnr
               keyboard chr(K_ENTER)
            else
               if nKoer > 0
                  goto nKoer
               endif
            endif
            if aRecv[1][14] $ "ESCAPED     NOTHING     UPARROW     "
               aRecv[1][14] := space(12)
            endif
            //Vra
            if cLanType() == "A"
               aRecv[1][14] := sm3idnr( aRecv[1][14],13,nBoxc,"Koei id nommer","Tik die koeinommer wat gedek is.",,,.t.)
            else
               aRecv[1][14] := sm3idnr( aRecv[1][14],13,nBoxc,"Cow id number","Type the id number of mated cow.",,,.t.)
            endif

            do case

               case left(aRecv[1][14],9) == "CANCELLED"
                  //Escaped
                  nLoop := 0

               case left(aRecv[1][14],3) == "NOT"
                  //Geen nommer gekies
                  if cLanType() == "A"
                     fScrBood(23,"Koeinommer is verpligtend")
                  else
                     fScrBood(23,"Cow number is compulsory")
                  endif
                  fScrWait(24)
                  if nKoer > 0
                     goto nKoer
                  else
                     go bottom
                     skip
                  endif
                  aRecv[1][14] := SM3DATA->idnr

               case left(aRecv[1][14],3) == "UPA"
                  //Up arrow pressed
                  nLoop--
                  if nKoer > 0
                     goto nKoer
                  else
                     go bottom
                     skip
                  endif
                  aRecv[1][14] := SM3DATA->idnr

               case SM3DATA->geslag <> "1"
                  //Geslag verkeerd
                  if cLanType() == "A"
                     fScrBood(23,"Koei is op rekenaar as 'n manlike dier!")
                  else
                     fScrBood(23,"Cow is on computer as a male animal!")
                  endif
                  fScrWait(24)

               otherwise
                  //Gaan voort

                  //Met of sonder bevestiging
                  if len(cTest) > 0 .and. lBeves
                     if cLanType() == "A"
                        fScrBood(23,"Bevestig dat koei gedek moet word!")
                        if fJaNee( 24, "Bevestig?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Confirm that cow should be mated!")
                        if fJaNee( 24, "Confirm?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Toets voorgeslagte
                  fScrBood(23)
                  if cLanType() == "A"
                     fScrWbood(24,"Koei se nageslag, broers en stamboom word opgesoek")
                  else
                     fScrWbood(24,"Checking progeny, brothers and pedigree of cow")
                  endif
                  aStam := fStamboom(aRecv[1][14])
                  aBroe := fBroers(aRecv[1][14])
                  aSeun := fSeuns(aRecv[1][14])
                  cBood := ""
                  for i = 1 to len(aStam)
                     if aStam[i][1] == aRecv[2][14]
                        if cLanType() == "A"
                           do case
                              case i == 2
                                 cBood := "Bul "+trim(aRecv[2][14])+" is die pa van die koei wat tans gedek word!"
                              case i == 4
                                 cBood := "Bul "+trim(aRecv[2][14])+" is die oupa van die koei wat tans gedek word! (Vaderskant)"
                              case i == 6
                                 cBood := "Bul "+trim(aRecv[2][14])+" is die oupa van die koei wat tans gedek word! (Moederskant)"
                              case i == 8 .or. i == 10
                                 cBood := "Bul "+trim(aRecv[2][14])+" is die oupagrootjie van die koei wat tans gedek word! (Vaderskant)"
                              case i == 12 .or. i == 14
                                 cBood := "Bul "+trim(aRecv[2][14])+" is die oupagrootjie van die koei wat tans gedek word! (Moederskant)"
                              otherwise
                                 cBood := "Bul "+trim(aRecv[2][14])+" kom voor in die voorgeslag van die koei wat tans gedek word!"
                           endcase
                        else
                           do case
                              case i == 2
                                 cBood := "Bull "+trim(aRecv[2][14])+" is the sire of the cow being mated!"
                              case i == 4
                                 cBood := "Bull "+trim(aRecv[2][14])+" is the grandfather of the cow being mated! (Father-side)"
                              case i == 6
                                 cBood := "Bull "+trim(aRecv[2][14])+" is the grandfather of the cow being mated! (Mother-side)"
                              case i == 8 .or. i == 10
                                 cBood := "Bull "+trim(aRecv[2][14])+" is the great-grandfather of the cow being mated! (Father-side)"
                              case i == 12 .or. i == 14
                                 cBood := "Bull "+trim(aRecv[2][14])+" is the great-grandfather of the cow being mated! (Mother-side)"
                              otherwise
                                 cBood := "Bull "+trim(aRecv[2][14])+" appears in the ancestors of the cow being mated"
                           endcase
                        endif
                        exit
                     endif
                  next
                  if len(cBood) > 0
                     fScrBood(23,cBood)
                     if cLanType() == "A"
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif
                  //Toets broers
                  if ascan(aBroe,arecv[2][14]) > 0
                     if cLanType() == "A"
                        fScrBood(23,"Bul "+trim(aRecv[2][14])+" is 'n broer van die koei wat tans gedek word!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Bull "+trim(aRecv[2][14])+" is a brother to the cow being mated!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif
                  //Toets seuns
                  if ascan(aSeun,arecv[2][14]) > 0
                     if cLanType() == "A"
                        fScrBood(23,"Bul "+trim(aRecv[2][14])+" is 'n seun van die koei wat tans gedek word!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Bull "+trim(aRecv[2][14])+" is a son of the cow being mated!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Toets of koei se waar is dier kode reg is
                  if SM3DATA->uitkrede $ cWaarisd()
                  else
                     if cLanType() == "A"
                        fScrBood(23,"Koei se waar is dier kode toon aan dat sy nie meer in kudde is nie!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Cow where is animal code indicates that she is no longer in the herd!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Toets of koei nog in kudde is
                  if SM3DATA->uitkdatum <> ctod("") .and. aRecv[4][14] >= SM3DATA->uitkdatum
                     if cLanType() == "A"
                        fScrBood(23,"Koei het die kudde verlaat op "+dtoc(SM3DATA->uitkdatum)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Cow left the herd on "+dtoc(SM3DATA->uitkdatum)+"!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Toets of nie weer gedek voor vorige dekdatum
                  if aRecv[4][14] < SM3DATA->dekdat
                     if cLanType() == "A"
                        fScrBood(23,"Koei was reeds gedek op "+dtoc(SM3DATA->dekdat)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Cow already mated on "+dtoc(SM3DATA->dekdat)+"!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Toets of nie weer gedek voor laaste kalfdatum
                  if aRecv[4][14] < SM3DATA->lkalfdatum
                     if cLanType() == "A"
                        fScrBood(23,"Koei het reeds gekalf op "+dtoc(SM3DATA->lkalfdatum)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Cow calved on "+dtoc(SM3DATA->dekdat)+"!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Rusdae
                  if SM3DATA->lkalfdatum <> ctod("")
                     if aRecv[4][14] < SM3DATA->lkalfdatum + cRustyd
                        if cLanType() == "A"
                           fScrBood(23,"Koei het minder as "+ltrim(str(cRustyd,3,0))+" gerus na haar laaste kalf!")
                           if fJaNee( 24, "Aanvaar?",,.f.)
                           else
                              if len(cTest) > 0
                                 select SM3DATA
                                 skip
                              endif
                              loop
                           endif
                        else
                           fScrBood(23,"Cow has rested less than "+ltrim(str(cRustyd,3,0))+" days since her last calf!")
                           if fJaNee( 24, "Accept?",,.f.)
                           else
                              if len(cTest) > 0
                                 select SM3DATA
                                 skip
                              endif
                              loop
                           endif
                        endif
                     endif
                  endif

                  //Koeiouderdom
                  if SM3DATA->gebdatum <> ctod("")
                     if aRecv[4][14] < SM3DATA->gebdatum + cOudeer
                        if cLanType() == "A"
                           fScrBood(23,"Koei is jonger as "+ltrim(str(cOudeer,3,0))+" dae oud!")
                           if fJaNee( 24, "Aanvaar?",,.f.)
                           else
                              if len(cTest) > 0
                                 select SM3DATA
                                 skip
                              endif
                              loop
                           endif
                        else
                           fScrBood(23,"Cow is less than "+ltrim(str(cOudeer,3,0))+" days old!")
                           if fJaNee( 24, "Accept?",,.f.)
                           else
                              if len(cTest) > 0
                                 select SM3DATA
                                 skip
                              endif
                              loop
                           endif
                        endif
                     endif
                  endif

                  //Toets indien binne siklus weer gedek
                  if aRecv[4][14] > SM3DATA->dekdat .and. aRecv[4][14] < SM3DATA->dekdat+cSiklus
                     if cLanType() == "A"
                        fScrBood(23,"Koei is slegs "+ltrim(str(aRecv[4][14]-SM3DATA->dekdat,3,0))+" dag(e) gelede gedek deur "+trim(SM3DATA->bulid)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Cow only mated "+ltrim(str(aRecv[4][14]-SM3DATA->dekdat,3,0))+" days ago to bull "+trim(SM3DATA->bulid)+"!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Toets of nie reeds gedek op dieselfde datum
                  select SM3DEKK
                  seek aRecv[1][14] + dtos(aRecv[4][14])
                  if eof()
                     select SM3DATA
                  else
                     select SM3DATA
                     if cLanType() == "A"
                        fScrBood(23,"Koei op "+dtoc(SM3DEKK->datumin)+" gedek deur "+trim(SM3DEKK->idvaar)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     else
                        fScrBood(23,"Cow mated on "+dtoc(SM3DEKK->datumin)+" to "+trim(SM3DEKK->idvaar)+"!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           if len(cTest) > 0
                              select SM3DATA
                              skip
                           endif
                           loop
                        endif
                     endif
                  endif

                  //Bewaar
                  nKoer := recno()
                  nLoop++
            endcase

         otherwise
            //By almal
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Koei word in deklˆer bewaar")
            else
               fScrWbood(24,"Cow being entered in mating file")
            endif
            aRecv[7][14] := "1"                  //beteken wel dragtig
            //Bewaar in dekleer
            select SM3DEKK
            seek aRecv[1][14] + dtos(aRecv[4][14])
            if eof()
               append blank
            endif
            do while !rlock()
            enddo
            for i = 1 to len(aRecv)
               fieldput(aRecv[i][13],aRecv[i][14])
            next
            commit

            //Bewaar in hoofleer
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->dekdat    := aRecv[4][14]
            SM3DATA->tipede    := aRecv[3][14]
            SM3DATA->teelgroep := aRecv[6][14]
            SM3DATA->bulid     := aRecv[2][14]
            commit

            //Maak skoon
            aRecv[1][14] := space(12)

            //Indien groep
            if len(trim(cTest)) > 0
               select SM3DATA
               skip
            endif

            nLoop := 3

      endcase

   enddo

   //Herstel
return aRecv

