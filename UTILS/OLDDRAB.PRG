//SM3DRAB.PRG
//Program om dragtigheidsondersoeke te bewaar
//Kopiereg (c) 1992 A van Rensburg
//15:45 29 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3drab(cFind)

   //Veranderlikes
   local lMore   := .t.
   local nBoxc   := 0
   local dDate   := ctod("")
   local cToFile := cDd()+"sm3tydi.dbf"
   local cData   := ""
   local cDekk   := ""
   local cTydi   := ""
   local cIdnr   := ""
   local nLoop   := 1
   local aSend   := {}
   local aRecv   := {}
   local i       := 0
   local nLine   := 0
   local dDekk   := ctod("")
   local dGebd   := ctod("")
   local lDrag   := .f.

   //Verklaar - private
   private cOudeer := 365
   private cRustyd := 30
   private cNordra := 274
   private cMindra := 266
   private cMakdra := 308
   private cSiklus := 21

   //Skerm
   fScrOpsk()

   //Vra die datum waarop dragtigheidsondersoeke gedoen gaan word
   lMore := .t.
   do while lMore
      fScrBood(23,"[Esc]=Menu")
      if cLanType() == "A"
         fScrBood(24,"Tik die datum waarop dragtigheidsondersoeke gedoen gaan word!")
         nBoxc := fBoxCent(11,"Datum van dragtigheidsondersoek? xxxxxxxx",3,"bewaar dragtigheidresultate")
         @12,nBoxc say "Datum van dragtigheidsondersoek?" get dDate
      else
         fScrBood(24,"Type the date on which the pregnancy diagnosis will be done!")
         nBoxc := fBoxCent(11,"Date of pregnancy diagnosis? xxxxxxxx",3,"Enter pregnancy diagnosis results")
         @12,nBoxc say "Date of pregnancy diagnosis?" get dDate
      endif
      set cursor on
      read
      set cursor off
      if lastkey() == K_ESC
         return NIL
      endif
      if dDate == ctod("")
         if cLanType() == "A"
            fScrBood(23,"Datum waarop dragtigheidsondersoeke gedoen is, is verpligtend!")
         else
            fScrBood(23,"Date on which pregnancy diagnosis was done is compulsory!")
         endif
         fScrWait(24)
         loop
      endif
      lMore := .f.
   enddo

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aadd(aSend,{"sm3tydi","idnr"  })
   aadd(aSend,{"sm3data","dragda"})
   aadd(aSend,{"sm3data","dragwe"})
   aRecv := fGetField(aSend)
   aRecv := fFillBlank(aRecv)

   //Bepaal standaard dekwaardes
   if cLanType() == "A"
      fScrWbood(24,"Standaardwaardes word gelees")
   else
      fScrWbood(24,"Default values being read")
   endif
   cData := fTOpen(cDd(),"sm3rass",,"dbf",,.t.,.f.)
   if left(cData,1) == "f"
      return NIL
   endif
   locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
   if !eof()
      cOudeer := SM3RASS->oudeer
      cRustyd := SM3RASS->rustyd
      cNordra := SM3RASS->nordra
      cMindra := SM3RASS->mindra
      cMakdra := SM3RASS->makdra
      cSiklus := SM3RASS->siklus
   endif
   fTClose(cData)

   //Open die stdmenu.tmp - gaan verander - use exclusive
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cDekk := fTOpen(cDd(),"sm3dekk",,,,.t.,.f.)
   if left( cDekk, 1 ) == "f"
      return NIL
   endif
   set order to 2

   //Skuif die databasis
   if cFind == NIL
      if cLanType() == "A"
         fScrBood(23,"Kalfseisoen onbekend!")
      else
         fScrBood(23,"Calving season unknown!")
      endif
      fScrWait(24)
      fTClose(cDekk)
      return NIL
   else
      seek cFind
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Geen inligting vir die kalfseisoen kon gevind word nie!")
         else
            fScrBood(23,"No information could be found for the calving season!")
         endif
         fScrWait(24)
         fTClose(cDekk)
         return NIL
      endif
   endif

   //Soek diere
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kalfseisoen se dekkings word uitgesoek!")
   else
      fScrWbood(24,"Calving season matings being sorted!")
   endif
   copy to (cToFile) fields idnr,idmoer,teelgroep while SM3DEKK->teelgroep == cFind

   //Open die hoofleer
   cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   if left(cData,1) == "f"
      fTClose(cDekk)
      return NIL
   endif

   //Open tydelike leer
   cTydi := fTOpen(cDd(),"sm3tydi",,,,.f.,.f.)
   if left( cTydi, 1 ) == "f"
      fTClose(cDekk)
      fTClose(cData)
      return NIL
   endif
   replace all idnr with idmoer

   //Verwyder dubbels
   go top
   do while !eof()
      if SM3TYDI->idnr == cIdnr
         delete
      else
         cIdnr := SM3TYDI->idnr
      endif
      skip
   enddo
   go top
   set relation to IDNR into SM3DATA, to TEELGROEP+IDMOER into SM3DEKK

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(10,space(50),5,"Bewaar dragtigheidresultate vir "+trim(cFind)+" kalfseisoen.")
   else
      nBoxc := fBoxCent(10,space(50),5,"Enter pregnancy diagnosis results for "+trim(cFind)+" calving season.")
   endif
   nLine := 10
   @11,nBoxc say aRecv[1][6]
   @12,nBoxc say aRecv[2][6]
   @13,nBoxc say aRecv[3][6]

   //Vertoon elke dier
   do while nLoop > 0

      do case

         case nLoop == 1
            //Id nommer
            //Bewaar dragtigheiddatum
            if SM3DATA->dragda == ctod("") .or. SM3DATA->dragda <= SM3DATA->dekdat
               aRecv[2][14] := dDate
            else
               aRecv[2][14] := SM3DATA->dragda
            endif
            //Kry bestaande dier se inligting
            aRecv[1][14] := SM3TYDI->idnr
            aRecv[3][14] := SM3DATA->dragwe
            setcolor(cColInve())
            for i = 1 to len(aRecv)
               @nLine+i,nBoxc+21 say transform(aRecv[i][14],aRecv[i][10])
            next
            setcolor(cColNorm())
            nLoop := 3

         case nLoop == 2
            //Datum
            fScrBood(23,"[Esc]=Menu")
            if cLanType() == "A"
               fScrBood(24,"Tik die datum waarop die dragtigheidsondersoek gedoen is!")
            else
               fScrBood(24,"Type the date on which the pregnancy diagnosis was done!")
            endif
            @nLine+2,nBoxc+21 get aRecv[2][14] pict aRecv[2][10]
            set cursor on
            read
            set cursor off
            do case
               case lastkey() == K_ESC
                  nLoop := 0
               case aRecv[2][14] == ctod("")
                  if cLanType() == "A"
                     fScrBood(23,"Datum is verpligtend!")
                  else
                     fScrBood(23,"Date is compulsory!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 3
            //Dragtig
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Menu  "+D_UPARR+"=Datum  [PgUp]=Vorige dier  [Enter]=Volgende dier")
               fScrBood(24,"Hoeveel weke is die dier dragtig? (0=Nie dragtig)")
            else
               fScrBood(23,"[Esc]=Menu  "+D_UPARR+"=Date  [PgUp]=Prev.animal  [Enter]=Next animal")
               fScrBood(24,"How many weeks pregnant? (0=Not pregnant)")
            endif
            @nLine+3,nBoxc+21 get aRecv[3][14] pict aRecv[3][10] //valid(aRecv[3][14]$" 0123456JYN")
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  nLoop := 0
               case lastkey() == K_UP
                  nLoop--
               case lastkey() == K_PGUP
                  if recno() > 1
                     skip -1
                     nLoop := 1
                  endif
                  //case aRecv[3][14] == 0
                  //  skip
                  //  if eof()
                  //    nLoop := 0
                  //  else
                  //    nLoop := 1
                  //  endif
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         otherwise

            //Stoor die data
            //select SM3DATA
            //do while !rlock()
            //enddo
            //SM3DATA->dragda := aRecv[2][14]
            //SM3DATA->dragti := aRecv[3][14]
            //select SM3DEKK
            //do while SM3DEKK->teelgroep == SM3TYDI->teelgroep .and. SM3DEKK->idmoer == SM3TYDI->idmoer
            //  do while !rlock()
            //  enddo
            //  SM3DEKK->dragtig := aRecv[3][14]
            //  skip
            //enddo

            if aRecv[3,14] <= 0

               //Nie dragtig

               select SM3DEKK
               do while SM3DEKK->teelgroep == SM3TYDI->teelgroep .and. SM3DEKK->idmoer == SM3TYDI->idmoer
                  do while !rlock()
                  enddo
                  SM3DEKK->dragtig := " "
                  SM3DEKK->dragwe := 0
                  skip
               enddo
               select SM3DATA
               do while !rlock()
               enddo
               SM3DATA->dragda := aRecv[2][14]
               SM3DATA->dragti := "N"
               SM3DATA->dragwe := 0

            else

               //Dragtig

               //Bewaar in hoofleer
               select SM3DATA
               do while !rlock()
               enddo
               SM3DATA->dragda := aRecv[2][14]
               SM3DATA->dragwe := aRecv[3][14]
               if cLanType() == "A"
                  SM3DATA->dragti := "J"
               else
                  SM3DATA->dragti := "Y"
               endif

               //Bepaal van wie die koei dragtig is
               dDekk := aRecv[2,14] - aRecv[3,14]*7
               dGebd := dDekk + cNordra
               lDrag := .f.
               select SM3DEKK
               do while SM3DEKK->teelgroep == SM3TYDI->teelgroep .and. SM3DEKK->idmoer == SM3TYDI->idmoer
                  do while !rlock()
                  enddo
                  if cLanType() == "A"
                     SM3DEKK->dragtig := "J"
                  else
                     SM3DEKK->dragtig := "Y"
                  endif
                  SM3DEKK->dragwe  := 0
                  if dGebd >= SM3DEKK->datumin+cMindra .and. dGebd <= SM3DEKK->datumuit+cMakdra
                     //Dekking geldig
                     if lDrag == .f.
                        lDrag := .t.
                        SM3DEKK->dragwe    := aRecv[3,14]
                        SM3DATA->dekdat    := dDekk
                        SM3DATA->tipede    := SM3DEKK->vaarkode
                        SM3DATA->teelgroep := SM3DEKK->teelgroep
                        SM3DATA->bulid     := SM3DEKK->idvaar
                     endif
                  endif
                  skip
               enddo
            endif

            //Volgende dier
            select SM3TYDI
            skip
            if eof()
               nLoop := 0
            else
               nLoop := 1
            endif

      endcase

   enddo

   //Herstel
   fTClose(cDekk)
   fTClose(cData)
   fTClose(cTydi)
   return NIL

