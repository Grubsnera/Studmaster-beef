//SM3DEKK.PRG
//Program vir dekbesonderhede te bewaar
//Kopiereg (c) 1992 A van Rensburg
//11:47 21 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//***************************************************************************/
FUNCTION sm3dekk

   //Verklaar
   local getlist := {}
   local aSend   := {}
   local aRecv   := {}
   local cData   := ""
   local cDekk   := ""
   local i       := 1
   local nLoop   := 1
   local nBoxc   := 0
   local nBulr   := 0
   local nCh     := 1
   local nTipe   := 1
   local aVelde  := {}
   local cKalfs  := "      "

   //Standaardwaardes
   private cTest   := ""
   private cOudeer := 365
   private cRustyd := 30
   private cNordra := 274
   private cMindra := 266
   private cMakdra := 308
   private cSiklus := 21
   private lBeves  := .t.

   //Skerm
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
      nBoxc := fBoxCent(5,space(50),5,"Belangrike nota")
      @ 6, nBoxc say "Gebruik altyd die ENKEL KOEI opsie. Die ander twee"
      @ 7, nBoxc say "word gebruik wanneer  koeie  in  spesifieke groepe"
      @ 8, nBoxc say "ingedeel is.                                      "
   else
      fScrOpsk(,"Option "+cOption())
      nBoxc := fBoxCent(5,space(50),5,"Important note")
      @ 6, nBoxc say "Always use the SINGLE COW option. The other "
      @ 7, nBoxc say "two are used when cows have been sorted into"
      @ 8, nBoxc say "specific groups.                            "
   endif

   //Vra een koei, groep of seleksiegroep
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] om terug te gaan." )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] to return." )
   endif
   nTipe := fNewMenu( nTipe, "SM3DEKKa" )
   cOption(nTipe)

   do case

      case nTipe == 1
         //Een dier
      case nTipe == 2
         //Groep
         cTest := sm3groe()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif

			cOption(-1)
            return NIL
         endif
      case nTipe == 3
         //Seleksiegroep
         cTest := sm3selg()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No selection group requirements have been specified!")
            endif

			cOption(-1)
            return NIL
         endif
      otherwise
         //Herstel
         cOption(-1)
         return NIL
   endcase

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   //Vra met of sonder bevestiging
   if nTipe >= 2
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] om terug te gaan." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] to return." )
      endif
      nCh := 1
      nCh := fNewMenu( nCh, "SM3DEKKb" )
	  cOption(nCh)

      do case
         case nCh == 1
         case nCh == 2
            lBeves := .f.
         otherwise
            //Herstel
			cOption(-2)
			return NIL
      endcase
   endif

   //Standaardwaardes
   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
      fScrWbood(24,"Dekkingswaardes word gelees")
   else
      fScrOpsk(1,"Option "+cOption())
      fScrWbood(24,"Mating values being read")
   endif

   //Open leer
   cData := fTOpen(cDd(),"sm3rass",,"dbf",,.t.,.f.)
   if left(cData,1) == "f"
	  if nTipe > 1
	  	 cOption(-2)
	  else
         cOption(-1)
	  endif

      return NIL
   endif
   //Vind die regte ras
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

   //Lees veldbeskrywings
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word gelees")
   else
      fScrWbood(24,"Field descriptions being read")
   endif
   asize(aSend,0)
   aadd(aSend,{"sm3dekk","idmoer"})
   aadd(aSend,{"sm3dekk","idvaar"})
   aadd(aSend,{"sm3dekk","vaarkode"})
   aadd(aSend,{"sm3dekk","datumin"})
   aadd(aSend,{"sm3dekk","datumuit"})
   aadd(aSend,{"sm3dekk","teelgroep"})
   aadd(aSend,{"sm3dekk","dragtig"})
   aadd(aSend,{"sm3dekk","gekalf"})
   aadd(aSend,{"sm3dekk","idnr"})
   aadd(aSend,{"sm3dekk","insem"})
   aadd(aSend,{"sm3dekk","donor"})
   aadd(aSend,{"sm3dekk","opmerk"})
   aRecv := fGetField(aSend)

   //Open data
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data",,"dbf",,.t.,.f.)
   if left(cData,1) == "f"
	  if nTipe > 1
	  	 cOption(-2)
	  else
         cOption(-1)
	  endif

      return NIL
   endif
   cDekk := fTOpen(cDd(),"sm3dekk",,"dbf",,.t.,.f.)
   if left(cData,1) == "f"
      fTClose(cData)
	  if nTipe > 1
	  	 cOption(-2)
	  else
         cOption(-1)
	  endif

      return NIL
   endif

   nLoop := 1
   do while nLoop > 0

      //Skerm
      if nLoop == 1
         select SM3DEKK
         go bottom
         skip
         for i = 1 to len(aRecv)
            aRecv[i][14] := fieldget(aRecv[i][13])
         next
         select SM3DATA
         if cLanType() == "A"
            do case
               case nTipe == 2
                  nBoxc := fBoxCent(7,space(50),10,"Dek groep koeie")
               case nTipe == 3
                  nBoxc := fBoxCent(7,space(50),10,"Dek seleksiegroep koeie")
               otherwise
                  nBoxc := fBoxCent(7,space(50),10,"Dek enkel koeie")
            endcase
         else
            do case
               case nTipe == 2
                  nBoxc := fBoxCent(7,space(50),10,"Mating group of cows")
               case nTipe == 3
                  nBoxc := fBoxCent(7,space(50),10,"Mating selection group of cows")
               otherwise
                  nBoxc := fBoxCent(7,space(50),10,"Mating single cow")
            endcase
         endif
      endif

      //Vra die besonderhede
      do case

         case nLoop == 1
            //Kalfseisoen
            //Standaard
            if cKalfs <> "      "
               aRecv[6][14] := cKalfs
               cKalfs := "      "
            endif
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Menu  [F1]=Hulp  "+D_DNARR+"=Kalfseisoene")
               fScrBood(24,"Tik 'n kalfseisoenkode wanneer die koeie gaan kalf.")
            else
               fScrBood(23,"[Esc]=Menu  [F1]=Help  "+D_DNARR+"=Calving seasons")
               fScrBood(24,"Type a calving season code when cows should calve.")
            endif
            //Vra
            @ 8,nBoxc say aRecv[6][6] get aRecv[6][14] pict aRecv[6][10] valid(fTeelgrp(aRecv[6][14],nBoxc))
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Nou
            do case
               case lastkey() == K_ESC
                  nLoop := 0
               case lastkey() == K_DOWN
                  //Vertoon kalfseisoene
                  cKalfs := sm3teeg(4,,,,aRecv[6][14])
               case aRecv[6][14] == space(6)
                  nLoop := 0
               case lastkey() == K_ENTER
                  //Bewaar kalfseisoen in leer
                  //Volgende vraag
                  nLoop++
            endcase

         case nLoop == 2
            //Dekkode
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Menu  [F1]=Hulp  "+D_UPARR+"=Kalfseisoen")
               fScrBood(24,"Tik die dekkode of manier waarop die koeie gedek is.")
            else
               fScrBood(23,"[Esc]=Menu  [F1]=Help  "+D_UPARR+"=Calving season")
               fScrBood(24,"Type the service code or means by which the cow was mated.")
            endif
            //Vra
            @ 9,nBoxc say aRecv[3][6] get aRecv[3][14] pict aRecv[3][10]
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Nou
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case aRecv[3][14] == " "
                  if cLanType() == "A"
                     fScrBood(23,"Dekkode is verpligtend!")
                  else
                     fScrBood(23,"Service code is compulsory!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  //Kyk of die regte kode
                  if aRecv[3][14] $ "1234"
                     //Volgende vraag
                     nLoop++
                  else
                     if cLanType() == "A"
                        fScrBood(23,"Dekkode is onbekend!")
                     else
                        fScrBood(23,"Service code is unknown!")
                     endif
                     fScrWait(24)
                  endif
            endcase

         case nLoop == 3
            //Bulnommer
            select SM3DATA
            if nBulr > 0
               goto nBulr
            endif
            //Vra
            if cLanType() == "A"
               aRecv[2][14] := sm3idnr( aRecv[2][14],10,nBoxc,"Bul id nommer","Tik die bulnommer gebruik.",,,.t.)
            else
               aRecv[2][14] := sm3idnr( aRecv[2][14],10,nBoxc,"Bull id number","Type id number of the bull.",,,.t.)
            endif
            do case
               case left(aRecv[2][14],9) == "CANCELLED"
                  //Escaped
                  nLoop := 1
                  if nBulr > 0
                     goto nBulr
                  else
                     go bottom
                     skip
                  endif
                  aRecv[2][14] := SM3DATA->idnr
               case left(aRecv[2][14],3) == "NOT"
                  //Geen nommer gekies
                  if cLanType() == "A"
                     fScrBood(23,"Bulnommer is verpligtend")
                  else
                     fScrBood(23,"Bull number is compulsory")
                  endif
                  fScrWait(24)
                  if nBulr > 0
                     goto nBulr
                  else
                     go bottom
                     skip
                  endif
                  aRecv[2][14] := SM3DATA->idnr
               case left(aRecv[2][14],3) == "UPA"
                  //Up arrow pressed
                  nLoop--
                  if nBulr > 0
                     goto nBulr
                  else
                     go bottom
                     skip
                  endif
                  aRecv[2][14] := SM3DATA->idnr
               case SM3DATA->geslag <> "2"
                  //Geslag verkeerd
                  if cLanType() == "A"
                     fScrBood(23,"Bul is op rekenaar as 'n vroulike dier!")
                  else
                     fScrBood(23,"Bull is on computer as a female animal!")
                  endif
                  fScrWait(24)
               otherwise
                  //Gaan voort
                  //Toets of bul se waar is dier kode reg is
                  if SM3DATA->uitkrede $ cWaarisd()
                  else
                     if cLanType() == "A"
                        fScrBood(23,"Bul se waar is dier kode toon aan dat hy nie meer in kudde is nie!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"Bull where is animal code indicates that he is no longer in the herd!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  //Toets datum uit kudde
                  if SM3DATA->uitkdatum <> ctod("")
                     if cLanType() == "A"
                        fScrBood(23,"Bul het die kudde verlaat op "+dtoc(SM3DATA->uitkdatum)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"Bull left herd on "+dtoc(SM3DATA->uitkdatum)+"!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  nBulr := recno()
                  nLoop := 4
            endcase

         case nLoop == 4
            //Verdere vrae
            do case
               case aRecv[3][14] == "3"
                  aRecv := sm3deki(aRecv,nBoxc)
               case aRecv[3][14] == "4"
                  aRecv := sm3deki(aRecv,nBoxc)
               otherwise
                  aRecv := sm3dena(aRecv,nBoxc)
            endcase
            //Aksies
            if len(cTest) > 0
               nLoop := 0
            else
               do case
                  case left(aRecv[1][14],3) == "UPA"
                     nLoop := 3
                  otherwise
                     nLoop := 1
               endcase
            endif

      endcase

   enddo

   //Herstel
   if nTipe > 1
   	  cOption(-2)
   else
      cOption(-1)
   endif

   fTClose(cDekk)
   fTClose(cData)

return NIL

//******************************************************************************/
STATIC FUNCTION fTeelgrp(cData,nBoxc)

   //Verklaar
   local getlist := {}
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local cDbfs   := fTOpen()
   local cFile   := ""

   //Nul data
   if cData == "      "
      return lRetu
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kalfseisoen word bewaar")
   else
      fScrWbood(24,"Calving season being entered")
   endif

   //Open .dbf
   cFile := fTOpen( cDd(), "sm3teeg", , "dbf", , .t., .f. )
   if left( cFile, 1 ) == "f"
   else
      select SM3TEEG
      seek cData
      if eof()
         append blank
         do while !rlock()
         enddo
         SM3TEEG->kode := cData
         fScrBood(23)
         if cLanType() == "A"
            fSCrBood(24,"Tik 'n kort beskrywing van die kalfseisoen!")
            @9,nBoxc say "Kalfseisoen beskrywi" get SM3TEEG->besk
         else
            fSCrBood(24,"Type a short description for the calving season!")
            @9,nBoxc say "Calving season descr" get SM3TEEG->besk
         endif
         set cursor on
         read
         set cursor off
      endif
   endif

   //Herstel
   fTClose(cFile)
   fTClose(cDbfs)
   restscreen(0,0,24,79,cCscr)
return lRetu

