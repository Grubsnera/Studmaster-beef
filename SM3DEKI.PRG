//SM3DEKI.PRG
//Program om ki te stoor
//Kopiereg (c) 1992 A van Rensburg
//11:21 22 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//*************************************************************************/
FUNCTION sm3deki(aRecv,nBoxc)

//Funksie om kunsmatige en inovulasies te vra

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
      //Koeinommer
      select SM3DATA
      if len(trim(cTest)) > 0
        //Seleksiegroep
        if cLanType() == "A"
          fScrBood(23,"[Esc]=Stop proses")
          if aRecv[3][14] == "3"
            fScrWbood(24,"Groep koeie om te KI word uitgesoek")
          else
            fScrWbood(24,"Groep koeie om te inovuleer word uitgesoek")
          endif
        else
          fScrBood(23,"[Esc]=Stop process")
          if aRecv[3][14] == "3"
            fScrWbood(24,"Sorting group of cows for AI")
          else
            fScrWbood(24,"Sorting group of cows for inovulation")
          endif
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
          //aRecv[1][14] := SM3DATA->idnr
        endif
      endif
      if aRecv[1][14] $ "ESCAPED     NOTHING     UPARROW     "
        aRecv[1][14] := space(12)
      endif
      //Vra
      if cLanType() == "A"
        if aRecv[3][14] == "3"
          aRecv[1][14] := sm3idnr( aRecv[1][14],11,nBoxc,"Koei id nommer","Tik die koeinommer om te KI.",,,.t.)
        else
          aRecv[1][14] := sm3idnr( aRecv[1][14],11,nBoxc,"Draer id nommer","Tik die draer koeinommer om te inovuleer.",,,.t.)
        endif
      else
        if aRecv[3][14] == "3"
          aRecv[1][14] := sm3idnr( aRecv[1][14],11,nBoxc,"Cow id number","Type the cow number for AI.",,,.t.)
        else
          aRecv[1][14] := sm3idnr( aRecv[1][14],11,nBoxc,"Recipient id number","Type the number of the recipient cow for inovulation.",,,.t.)
        endif
      endif
      do case
        case left(aRecv[1][14],9) == "CANCELLED"
          //Escaped
          arecv[1][14] := "ESCAPED     "
          nLoop := 0
        case left(aRecv[1][14],3) == "NOT"
          //Geen nommer gekies
          if cLanType() == "A"
            fScrBood(23,"Koeinommer is verpligtend")
          else
            fScrBood(23,"Cow number is compulsory")
          endif
          fScrWait(24)
        case left(aRecv[1][14],3) == "UPA"
          //Up arrow pressed
          arecv[1][14] := "UPARROW     "
          nLoop := 0
        otherwise
          //Gaan voort
          //Met of sonder bevestiging
          if len(cTest) > 0 .and. lBeves
            if cLanType() == "A"
              if aRecv[3][14] == "3"
                fScrBood(23,"Bevestig dat koei kunsmatig ge‹nsemineer moet word!")
              else
                fScrBood(23,"Bevestig dat draer koei geinovuleer moet word!")
              endif
              if fJaNee( 24, "Bevestig?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
                endif
                loop
              endif
            else
              if aRecv[3][14] == "3"
                fScrBood(23,"Confirm that cow must be artificially inseminated!")
              else
                fScrBood(23,"Confirm that recipient cow must be inovulated!")
              endif
              if fJaNee( 24, "Confirm?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
                endif
                loop
              endif
            endif
          endif
          //Toets geslag
          if SM3DATA->geslag <> "1"
            //Geslag verkeerd
            if cLanType() == "A"
              fScrBood(23,"Koei is op rekenaar as 'n manlike dier!")
            else
              fScrBood(23,"Cow is on computer as a male animal!")
            endif
            fScrWait(24)
            if len(cTest) > 0
              select SM3DATA
              skip
            endif
            loop
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
                    cBood := "Bull "+trim(aRecv[2][14])+" is the grandfather of the cow being mated! (Father's side)"
                  case i == 6
                    cBood := "Bull "+trim(aRecv[2][14])+" is the grandfather of the cow being mated! (Mother's side)"
                  case i == 8 .or. i == 10
                    cBood := "Bull "+trim(aRecv[2][14])+" is the great-grandfather of the cow being mated! (Father's side)"
                  case i == 12 .or. i == 14
                    cBood := "Bull "+trim(aRecv[2][14])+" is the great-grandfather of the cow being mated! (Mother's side)"
                  otherwise
                    cBood := "Bull "+trim(aRecv[2][14])+" appears in the ancestors of the cow being mated!"
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
                  nLoop := 1
                endif
                loop
              endif
            else
              if fJaNee( 24, "Accept?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
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
                  nLoop := 1
                endif
                loop
              endif
            else
              fScrBood(23,"Bull "+trim(aRecv[2][14])+" is a brother of the cow being mated!")
              if fJaNee( 24, "Accept?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
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
                  nLoop := 1
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
                  nLoop := 1
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
                  nLoop := 1
                endif
                loop
              endif
            else
              fScrBood(23,"Cow where is animal code indicates she is no longer in the herd!")
              if fJaNee( 24, "Accept?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
                endif
                loop
              endif
            endif
          endif

          //Bewaar
          nKoer := recno()
          nLoop++
      endcase

    case nLoop == 2
      //Ki datum
      if cLanType() == "A"
        fScrBood(23,"[Esc]=Kalfseisoen  [F1]=Hulp")
        if aRecv[3][14] == "3"
          fScrBood(24,"Tik die datum waarop koei ge‹nsemineer is.")
          //Vra
          @12,nBoxc say "            KI datum" get aRecv[4][14] pict aRecv[4][10]
        else
          fScrBood(24,"Tik die datum waarop draer koei geinovuleer is.")
          //Vra
          @12,nBoxc say "     Inovulasiedatum" get aRecv[4][14] pict aRecv[4][10]
        endif
      else
        fScrBood(23,"[Esc]=Calving season  [F1]=Help")
        if aRecv[3][14] == "3"
          fScrBood(24,"Type the date on which the cow was inseminated.")
          //Vra
          @12,nBoxc say "             AI date" get aRecv[4][14] pict aRecv[4][10]
        else
          fScrBood(24,"Type the date on which the recipient cow was inovulated.")
          //Vra
          @12,nBoxc say "    Inovulation date" get aRecv[4][14] pict aRecv[4][10]
        endif
      endif
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
          if len(cTest) == 0
            nLoop--
          endif
        case aRecv[4][14] == ctod("")
          if cLanType() == "A"
            fScrBood(23,"Datum is verpligtend!")
          else
            fScrBood(23,"Date is compulsory!")
          endif
          fScrWait(24)

        case lastkey() == K_ENTER

          aRecv[5][14] := aRecv[4][14]

          //Toets of koei nog in kudde is
          if SM3DATA->uitkdatum <> ctod("") .and. aRecv[4][14] >= SM3DATA->uitkdatum
            if cLanType() == "A"
              fScrBood(23,"Koei het die kudde verlaat op "+dtoc(SM3DATA->uitkdatum)+"!")
              if fJaNee( 24, "Aanvaar?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
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
                  nLoop := 1
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
                  nLoop := 1
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
                  nLoop := 1
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
                  nLoop := 1
                endif
                loop
              endif
            else
              fScrBood(23,"Cow already calved on "+dtoc(SM3DATA->lkalfdatum)+"!")
              if fJaNee( 24, "Accept?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
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
                    nLoop := 1
                  endif
                  loop
                endif
              else
                fScrBood(23,"Cow rested less than "+ltrim(str(cRustyd,3,0))+" days since last calf!")
                if fJaNee( 24, "Accept?",,.f.)
                else
                  if len(cTest) > 0
                    select SM3DATA
                    skip
                    nLoop := 1
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
                    nLoop := 1
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
                    nLoop := 1
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
                  nLoop := 1
                endif
                loop
              endif
            else
              fScrBood(23,"Cow was only mated "+ltrim(str(aRecv[4][14]-SM3DATA->dekdat,3,0))+" days ago to bull "+trim(SM3DATA->bulid)+"!")
              if fJaNee( 24, "Accept?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
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
                  nLoop := 1
                endif
                loop
              endif
            else
              fScrBood(23,"Cow mated on "+dtoc(SM3DEKK->datumin)+" to bull "+trim(SM3DEKK->idvaar)+"!")
              if fJaNee( 24, "Accept?",,.f.)
              else
                if len(cTest) > 0
                  select SM3DATA
                  skip
                  nLoop := 1
                endif
                loop
              endif
            endif
          endif
          nLoop++
      endcase

    case nLoop == 3
      //Insemineerder
      if cLanType() == "A"
        fScrBood(23,"[Esc]=Kalfseisoen  [F1]=Hulp")
        fScrBood(24,"Tik die verlangde besonderhede.")
      else
        fScrBood(23,"[Esc]=Calving season  [F1]=Help")
        fScrBood(24,"Type the requested information.")
      endif
      //Vra
      if cLanType() == "A"
        if aRecv[3][14] == "3"
          @13,nBoxc say aRecv[10][6] get aRecv[10][14] pict aRecv[10][10]
        else
          @13,nBoxc say "        Inovuleerder" get aRecv[10][14] pict aRecv[10][10]
        endif
      else
        if aRecv[3][14] == "3"
          @13,nBoxc say aRecv[10][6] get aRecv[10][14] pict aRecv[10][10]
        else
          @13,nBoxc say "          Inovulator" get aRecv[10][14] pict aRecv[10][10]
        endif
      endif
      @14,nBoxc say aRecv[12][6] get aRecv[12][14] pict aRecv[12][10]
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
        case lastkey() == K_ENTER
          nLoop++
      endcase

    case nLoop == 4 .and. aRecv[3][14] == "4"
      //Skenker
      //Vra
      if cLanType() == "A"
        aRecv[11][14] := sm3idnr( aRecv[11][14],15,nBoxc,"Skenker id nommer","Tik die skenkerkoei se id nommer.",,,.t.)
      else
        aRecv[11][14] := sm3idnr( aRecv[11][14],15,nBoxc,"Donor id number","Type the id number of the donor cow.",,,.t.)
      endif
      do case
        case left(aRecv[11][14],9) == "CANCELLED"
          //Escaped
          arecv[11][14] := "ESCAPED     "
          nLoop := 0
        case left(aRecv[11][14],3) == "NOT"
          //Geen nommer gekies
          if cLanType() == "A"
            fScrBood(23,"Skenker id nommer is verpligtend")
          else
            fScrBood(23,"Donor id number is compulsory")
          endif
          fScrWait(24)
        case left(aRecv[11][14],3) == "UPA"
          //Up arrow pressed
          nLoop--
        otherwise
          //Gaan voort
          //Toets geslag
          if SM3DATA->geslag <> "1"
            //Geslag verkeerd
            if cLanType() == "A"
              fScrBood(23,"Koei is op rekenaar as 'n manlike dier!")
            else
              fScrBood(23,"Cow is on computer as a male animal!")
            endif
            fScrWait(24)
            loop
          endif
          if aRecv[11][14] == aRecv[1][14]
            //Skenker en draer kan nie dieselfde dier wees nie.
            if cLanType() == "A"
              fScrBood(23,"Skenkerkoei is dieselfde as die draerkoei!")
            else
              fScrBood(23,"Donor cow is the same as the recipient cow!")
            endif
            fScrWait(24)
            loop
          endif
          nLoop++
      endcase

    otherwise
      //By almal
      fScrBood(23)
      if cLanType() == "A"
        fScrWbood(24,"Data word in deklˆer bewaar")
      else
        fScrWbood(24,"Data being entered in mating file")
      endif
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
      seek aRecv[1][14]
      do while !rlock()
      enddo
      SM3DATA->dekdat    := aRecv[4][14]
      SM3DATA->tipede    := aRecv[3][14]
      SM3DATA->teelgroep := aRecv[6][14]
      SM3DATA->bulid     := aRecv[2][14]
      commit

      //Maak skoon
      aRecv[1][14] := space(12)
      arecv[12][14] := space(20)

      //Indien groep
      if len(trim(cTest)) > 0
        select SM3DATA
        skip
      endif

      nLoop := 1

  endcase

enddo

//Herstel
return aRecv

