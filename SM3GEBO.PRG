//SM3GEBO.PRG
//Program om nuwe geboortes aan te teken
//Kopiereg (c) 1992 A van Rensburg
// 8:54pm Sep 29,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION sm3gebo

   //Veranderlikes
   local aSend := {}
   local aRecv := {}
   local cData := {}
   local nBoxc := 0
   local nLine := 0
   local nLoop := 1
   local lOver := .t.
   local aMoer := {}
   local aVaar := {}
   local aDekk := {}
   local aVeld := {}
   local nCh   := 1
   local cCscr := ""
   local cCarr := ""
   local cNcar := 0
   local nCarr := 0
   local cFile := ""
   local cOdbf := ""
   local cWaarid := "IK"
   local i     := 0
   local cIdle := 0
   local getlist := {}

   //Verklaar - private
   private cOudeer := 365
   private cRustyd := 30
   private cNordra := 274
   private cMindra := 266
   private cMakdra := 308
   private cSiklus := 21
   private cKalfst := "01"
   private cKalfge := "09"
   private cIdenti := "16  "
   private cSubafd := "  "
   private cTipies := "  "
   private cBreekk := "-"
   private cCompos := "N"
   private cNagebo := "   "
   private cAniTyp := " "
   private cEyepig := "  "

   //Opskrif
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
      cWaarid := "IK"
   else
      fScrOpsk( , "Option "+cOption())
      cWaarid := "IH"
   endif

   //Waardes
   aMoer := {0,space(12),space(2),space(2),0,0,space(2)}
   aVaar := {0,space(12),space(2),space(2),0,0,space(2)}
   //[1] = rekordnommer
   //[2] = id nommer
   //[3] = generasie
   //[4] = familiekode
   //[5] = Aantal kalwers
   //[6] = Breed composition
   //[7] = Temporary mark

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being found")
   endif
   aadd(aSend,{"sm3data","idmoer"    })          //1
   aadd(aSend,{"sm3data","gebdatum"  })          //2
   aadd(aSend,{"sm3data","idvaar"    })          //3
   aadd(aSend,{"sm3data","idnr"      })          //4
   aadd(aSend,{"sm3data","idnaam"    })          //5
   aadd(aSend,{"sm3data","kalfbnr"   })          //6
   aadd(aSend,{"sm3data","geslag"    })          //7
   aadd(aSend,{"sm3data","generasie" })          //8
   aadd(aSend,{"sm3data","gebmassa"  })          //9
   aadd(aSend,{"sm3data","vaarkode"  })          //10
   aadd(aSend,{"sm3data","gebstat"   })          //11
   aadd(aSend,{"sm3data","kalfgem"   })          //12
   aadd(aSend,{"sm3data","kalfstat"  })          //13
   aadd(aSend,{"sm3data","ident"     })          //14
   aadd(aSend,{"sm3data","tipies"    })          //15
   aadd(aSend,{"sm3data","subafd"    })          //16
   aadd(aSend,{"sm3data","idatum"    })          //17
   aadd(aSend,{"sm3data","mamoergeb" })          //18
   aadd(aSend,{"sm3data","bloedlyn"  })          //19
   aadd(aSend,{"sm3data","indekskode"})          //20
   aadd(aSend,{"sm3data","uitkrede"  })          //21
   aadd(aSend,{"sm3data","tweeling"  })          //22
   aadd(aSend,{"sm3data","niereg"    })          //23
   aadd(aSend,{"sm3data","toggle2"   })          //24
   aadd(aSend,{"sm3data","dataan"    })          //25
   aadd(aSend,{"sm3data","skenker"   })          //26
   aadd(aSend,{"sm3data","draer"     })          //27
   aadd(aSend,{"sm3data","gebmasv"   })          //28
   aadd(aSend,{"sm3data","compos"    })          //29
   aadd(aSend,{"sm3data","kuddek"    })          //30
   aadd(aSend,{"sm3data","jaarle"    })          //31
   aadd(aSend,{"sm3data","volgno"    })          //32
   aadd(aSend,{"sm3data","kalfno"    })          //33
   aadd(aSend,{"sm3data","moerou"    })          //34
   aadd(aSend,{"sm3data","nagebo"    })          //35
   aadd(aSend,{"sm3data","type"      })          //36
   aadd(aSend,{"sm3data","toggle1"   })          //37
   aadd(aSend,{"sm3data","eyepig"    })          //38
   aadd(aSend,{"sm3data","michip"    })          //39

   aRecv := fGetField(aSend)

   //Id nommer beskrywing
   if cLanType() == "A"
      aRecv[4,6] := "      Kalf id nommer"
   else
      aRecv[4,6] := "      Calf id number"
   endif

   //Dekwaardes word opgesoek
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
      cKalfst := SM3RASS->kalfst
      cKalfge := SM3RASS->kalfge
      cIdenti := SM3RASS->identi
      cSubafd := SM3RASS->subafd
      cTipies := SM3RASS->tipies
      cBreekk := SM3RASS->breekk
      cCompos := SM3RASS->askcom
      cNagebo := SM3RASS->nagebo
      cAniTyp := SM3RASS->type
      cEyepig := SM3RASS->eyepig
   endif
   fTClose(cData)

   //Datalˆers word geopen
   cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   if left(cData,1) == "f"
      return NIL
   endif

   //Demonstrasieprogram
   if "0000" $ cReeNomm() .and. lastrec() > 200 .or. ;
         len(trim(cReeNomm())) <= 0 .and. lastrec() > 200
      if cLanType() == "A"
         fScrBood(23,"Nuwe diere kan nie met die demonstrasieprogram bygevoeg word nie!")
         fScrWait(24)
      else
         fScrBood(23,"New animals cannot be added with the demonstration program!")
         fScrWait(24)
      endif
      //Herstel
      fTClose(cData)
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      fBox( 3, 1, maxrow()-3, maxcol()-2, "bewaar nuwe geboortes", cColNorm() )
   else
      fBox( 3, 1, maxrow()-3, maxcol()-2, "enter new births", cColNorm() )
   endif
   @ 5,4  say aRecv[ 1][6]
   @ 6,4  say aRecv[ 2][6]
   @ 7,4  say aRecv[ 3][6]

   @ 9,4  say aRecv[30][6]
   @10,4  say aRecv[31][6]
   @11,4  say aRecv[32][6]
   @12,4  say aRecv[ 4][6]
   @13,4  say aRecv[ 5][6]
   @14,4  say aRecv[39][6]
   @15,4  say aRecv[ 7][6]
   @16,4  say aRecv[ 8][6]
   @17,4  say aRecv[ 9][6]
   @18,4  say aRecv[10][6]
   @19,4  say aRecv[11][6]
   @20,4  say aRecv[13][6]

   if cLanType() == "A"
      @ 4,41 say padl("Koei se generasie",20)
      @ 5,41 say padl("Koei aantal kalwers",20)
      @ 6,41 say padl("Koei tydelike merk",20)
   else
      @ 4,41 say padl("Generation of cow",20)
      @ 5,41 say padl("Cow amount of calves",20)
      @ 6,41 say padl("Cow temporary mark",20)
   endif

   if cCompos $ "JY"
      @ 7,41 say aRecv[29][6]
   endif
   @ 8,41 say aRecv[12][6]
   @ 9,41 say aRecv[38][6]
   @10,41 say aRecv[14][6]
   @11,41 say aRecv[15][6]
   @12,41 say aRecv[16][6]
   @13,41 say aRecv[35][6]
   @14,41 say aRecv[36][6]
   @15,41 say aRecv[17][6]
   @16,41 say aRecv[18][6]
   @17,41 say aRecv[19][6]
   @18,41 say aRecv[37][6]
   @19,41 say aRecv[20][6]
   @20,41 say aRecv[21][6]

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Koeinommer
            //Maak velde skoon
            if lOver
               select SM3DATA
               go bottom
               skip
               for i = 1 to len(aRecv)
                  aRecv[i][14] := fieldget(aRecv[i][13])
               next
               //Bewaar standaardwaardes
               aRecv[11][14] := "1"              //Enkeling
               aRecv[12][14] := cKalfge
               aRecv[13][14] := cKalfst
               aRecv[14][14] := cIdenti
               aRecv[15][14] := cTipies
               aRecv[16][14] := cSubafd
               aRecv[21][14] := cWaarid
               aRecv[35][14] := cNagebo
               aRecv[36][14] := cAniTyp
               aRecv[38][14] := cEyepig

               //Kry die volgende kalfnommer
               fWvolg(aRecv,fEnum(aRecv,"volgno"))

               //Skoon besonderhede
               aMoer := {0,space(12),space(2),space(2),0,0,space(2)}
               aVaar := {0,space(12),space(2),space(2),0,0,space(2)}

               //Vertoon
               setcolor(cColInve())

               @ 5, 4+21 say transform(aRecv[ 1][14],aRecv[ 1][10])
               @ 6, 4+21 say transform(aRecv[ 2][14],aRecv[ 2][10])
               @ 7, 4+21 say transform(aRecv[ 3][14],aRecv[ 3][10])

               @ 9, 4+21 say transform(aRecv[30][14],aRecv[30][10])
               @10, 4+21 say transform(aRecv[31][14],aRecv[31][10])
               @11, 4+21 say transform(aRecv[32][14],aRecv[32][10])
               @12, 4+21 say transform(aRecv[ 4][14],aRecv[ 4][10])
               @13, 4+21 say transform(aRecv[ 5][14],"@!S20")
               @14, 4+21 say transform(aRecv[39][14],aRecv[39][10])
               @15, 4+21 say transform(aRecv[ 7][14],aRecv[ 7][10])
               @16, 4+21 say transform(aRecv[ 8][14],aRecv[ 8][10])
               @17, 4+21 say transform(aRecv[ 9][14],aRecv[ 9][10])
               @18, 4+21 say transform(aRecv[10][14],aRecv[10][10])
               @19, 4+21 say transform(aRecv[11][14],aRecv[11][10])
               @20, 4+21 say transform(aRecv[13][14],aRecv[13][10])

               @ 4,41+21 say aMoer[3]
               @ 5,41+21 say str(aMoer[5],3,0)
               @ 6,41+21 say aMoer[7]

               if cCompos $ "JY"
                  @ 7,41+21 say transform(aRecv[29][14],aRecv[29][10])
               endif
               @ 8,41+21 say transform(aRecv[12][14],aRecv[12][10])
               @ 9,41+21 say transform(aRecv[38][14],aRecv[38][10])
               @10,41+21 say transform(aRecv[14][14],aRecv[14][10])
               @11,41+21 say transform(aRecv[15][14],aRecv[15][10])
               @12,41+21 say transform(aRecv[16][14],aRecv[16][10])
               @13,41+21 say transform(aRecv[35][14],aRecv[35][10])
               @14,41+21 say transform(aRecv[36][14],aRecv[36][10])
               @15,41+21 say transform(aRecv[17][14],aRecv[17][10])
               @16,41+21 say transform(aRecv[18][14],aRecv[18][10])
               @17,41+21 say transform(aRecv[19][14],aRecv[19][10])
               @18,41+21 say transform(aRecv[37][14],aRecv[37][10])
               @19,41+21 say transform(aRecv[20][14],aRecv[20][10])
               @20,41+21 say transform(aRecv[21][14],aRecv[21][10])

               setcolor(cColNorm())

            endif
            lOver := .t.
            //Gaan na vorige rekord
            if aMoer[1] > 0
               goto aMoer[1]
            endif
            //Vra die koeinommer
            if cLanType() == "A"
               aRecv[1][14] := sm3idnr( aRecv[1][14], 5, 4,"Koei id nommer","Tik koei se id nommer wat gekalf het.",,,.t.)
            else
               aRecv[1][14] := sm3idnr( aRecv[1][14], 5, 4,"Cow id number","Type id number of cow that calved.",,,.t.)
            endif
            do case
               case aRecv[1][14] == "CANCELLED   "
                  //Escaped
                  nLoop := 0
               case aRecv[1][14] == "NOTHING     "
                  //Geen nommer gekies
                  nLoop := 0
               otherwise
                  //Gaan voort
                  //Geslag
                  if SM3DATA->geslag <> "1"
                     if cLanType() == "A"
                        fScrBood(23,"Koei is op rekenaar as 'n manlike dier!")
                     else
                        fScrBood(23,"Cow is on computer as a male animal!")
                     endif
                     fScrWait(24)
                     lOver := .f.
                     loop
                  endif
                  //Koei moet dragtig wees
                  if SM3DATA->dragti == "N"
                     if cLanType() == "A"
                        fScrBood(23,"Volgens rekord is die koei nie dragtig nie!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"According to records this cow is not pregnant!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  //Koei moet 'n in kudde merk he
                  if SM3DATA->uitkrede $ cWaarisd()
                  else
                     if cLanType() == "A"
                        fScrBood(23,"Volgens waar-is-dier kode is die koei nie meer in kudde nie!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"According to where-is-animal code the cow is no longer in herd!")
                        if fJaNee( 24, "Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  //Bewaar koei-inligting in array
                  aMoer := {recno(),SM3DATA->idnr,SM3DATA->generasie,SM3DATA->bloedlyn,SM3DATA->kalfaantal,SM3DATA->compos,SM3DATA->toggle1}
                  //Vertoon
                  //Vertoon
                  setcolor(cColInve())
                  @ 4,41+21 say aMoer[3]
                  @ 5,41+21 say aMoer[5]
                  @ 6,41+21 say aMoer[7]
                  setcolor(cColNorm())
                  nLoop++
            endcase

         case nLoop == 2
            //Geboortedatum
            //Skerm
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Koeinommer  "+D_UPARR+"=Koeinommer")
               fScrBood(24,"Tik die datum waarop die kalf gebore is!")
            else
               fScrBood(23,"[Esc]=Cow number  "+D_UPARR+"=Cow number")
               fScrBood(24,"Type the date on which the calf was born!")
            endif
            //Read
            @ 6, 4 say aRecv[2][6] get aRecv[2][14] pict aRecv[2][10]
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Wat volgende
            do case
               case lastkey() == K_ESC
                  //Escaped
                  nLoop := 1
               case lastkey() == K_UP
                  //Uparrow
                  lOver := .f.
                  nLoop := 1
               case lastkey() == K_ENTER
                  //Doen toetse
                  //Datum moet bekend wees
                  if aRecv[2][14] == ctod("")
                     if cLanType() == "A"
                        fScrBood(23,"Geboortedatum moet bekend wees!")
                        fScrWait(24)
                     else
                        fScrBood(23,"Birth date must be known!")
                        fScrWait(24)
                     endif
                     loop
                  endif
                  //Koei moet in kudde wees
                  if aRecv[2][14] < SM3DATA->uitkdatum
                     if cLanType() == "A"
                        fScrBood(23,"Koei het kudde op "+dtoc(SM3DATA->uitkdatum)+" verlaat!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"Cow left herd on "+dtoc(SM3DATA->uitkdatum)+" !")
                        if fJaNee( 24, " Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  //Koei kalf voor haar eie geboortedatum
                  if aRecv[2][14] <= SM3DATA->gebdatum
                     if cLanType() == "A"
                        fScrBood(23,"Koei is eers gebore op "+dtoc(SM3DATA->gebdatum)+"!")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"Cow only born on "+dtoc(SM3DATA->gebdatum)+"!")
                        if fJaNee( 24, " Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  //Koei kalf voor haar laaste kalf
                  if aRecv[2][14] < SM3DATA->lkalfdatum
                     if cLanType() == "A"
                        fScrBood(23,"Koei het reeds op "+dtoc(SM3DATA->lkalfdatum)+" gekalf! (Kalf "+trim(SM3DATA->lkalfn)+")")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"Cow calved on "+dtoc(SM3DATA->lkalfdatum)+" ! (Kalf "+trim(SM3DATA->lkalfn)+")")
                        if fJaNee( 24, " Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  //Koei op laaste kalfdatum gekalf
                  if aRecv[2][14] == SM3DATA->lkalfdatum
                     //Vra of die dier een van tweeling ens is
                     if fJaNee( 24, if(cLanType()=="A","Is kalf een van 'n twee- of meerling?","Is calf one of a twin or multiple?"),,.t.)
                        //Vra dmv menu wat?
                        //Vra of data bewaar moet word
                        cCscr := savescreen(0,0,24,79)
                        if cLanType() == "A"
                           fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu" )
                        else
                           fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu" )
                        endif
                        //Kry opsienommer
                        nCh := 1
                        nCh := fNewMenu( nCh, "SM3TWEE" )
                        restscreen(0,0,24,79,cCscr)
                        do case
                           case nCh == 1
                              //Tweeling
                              aRecv[11][14] := "2"
                           case nCh == 2
                              //Drieling
                              aRecv[11][14] := "3"
                           case nCh == 3
                              //Vierling
                              aRecv[11][14] := "4"
                           otherwise
                              loop
                        endcase
                     else
                        if cLanType() == "A"
                           fScrBood(23,"Koei het reeds op "+dtoc(SM3DATA->lkalfdatum)+" gekalf! (Kalf "+trim(SM3DATA->lkalfn)+")")
                           if fJaNee( 24, "Aanvaar?",,.f.)
                           else
                              loop
                           endif
                        else
                           fScrBood(23,"Cow calved on "+dtoc(SM3DATA->lkalfdatum)+" ! (Kalf "+trim(SM3DATA->lkalfn)+")")
                           if fJaNee( 24, " Accept?",,.f.)
                           else
                              loop
                           endif
                        endif
                     endif
                  elseif aRecv[2][14] < SM3DATA->lkalfdatum+cMindra
                     //Koei interkalfperiode te kort
                     if cLanType() == "A"
                        fScrBood(23,"Koei het slegs "+ltrim(str(aRecv[2][14]-SM3DATA->lkalfdatum,3,0))+" dae gelede gekalf! (Kalf "+trim(SM3DATA->lkalfn)+")")
                        if fJaNee( 24, "Aanvaar?",,.f.)
                        else
                           loop
                        endif
                     else
                        fScrBood(23,"Cow only calved "+ltrim(str(aRecv[2][14]-SM3DATA->lkalfdatum,3,0))+" days ago! (Kalf "+trim(SM3DATA->lkalfn)+")")
                        if fJaNee( 24, " Accept?",,.f.)
                        else
                           loop
                        endif
                     endif
                  endif
                  aDekk := fDekkings(aRecv[1][14],aRecv[2][14])
                  aRecv[ 3][14] := aDekk[1]      //Vaar
                  aRecv[10][14] := aDekk[2]      //Vaarkode
                  aRecv[17][14] := aDekk[3]      //Dekdatum
                  aRecv[20][14] := aDekk[4]      //Kalfseisoen
                  aRecv[26][14] := aDekk[5]      //Skenkerkoei
                  nLoop++
            endcase

         case nLoop == 3
            //Vaarnommer
            //Gaan na vorige rekord
            if aVaar[1] > 0
               goto aVaar[1]
            endif
            if cLanType() == "A"
               aRecv[3][14] := sm3idnr( aRecv[3][14],7,4,"Pa se id nommer","Tik die pa van die kalf se id nommer.",,,.t.)
            else
               aRecv[3][14] := sm3idnr( aRecv[3][14],7,4,"Sire's id number","Type the id number of the sire of the calf.",,,.t.)
            endif
            do case
               case aRecv[3][14] == "CANCELLED   "
                  //Escaped
                  aRecv[3][14] := space(12)
                  nLoop := 1
               case aRecv[3][14] == "UPARROW     "
                  //Uparrow
                  aRecv[3][14] := space(12)
                  nLoop--
               case aRecv[3][14] == "NOTHING     "
                  //Geen nommer gekies
                  aRecv[3][14] := space(12)
                  nLoop++
               otherwise
                  //Gaan voort
                  //Geslag
                  if aRecv[3][14] <> space(12)
                     if SM3DATA->geslag <> "2"
                        if cLanType() == "A"
                           fScrBood(23,"Pa van kalf is op rekenaar as 'n vroulike dier!")
                        else
                           fScrBood(23,"Sire of calf is on computer as a female animal!")
                        endif
                        fScrWait(24)
                        loop
                     endif
                  endif
                  //Bewaar bul-inligting in array
                  aVaar := {recno(),SM3DATA->idnr,SM3DATA->generasie,SM3DATA->bloedlyn,SM3DATA->kalfaantal,SM3DATA->compos,SM3DATA->toggle1}
                  nLoop++
            endcase

         case nLoop == 4
            //Ander inligting

            // Calculate the Id number

            // Work out the breed composition
            if cCompos $ "JY"
               aRecv[29,14] = int((aMoer[6]+aVaar[6])/2)
            endif

            //Skerm
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Begin van voor af  [F1]=Hulp")
               fScrBood(24,"Tik die verlangde besonderhede.")
            else
               fScrBood(23,"[Esc]=Start again  [F1]=Help")
               fScrBood(24,"Type the information requested.")
            endif

            //Read
            @ 9, 4+21 get aRecv[30][14] pict aRecv[30][10] when(fWkudd(aRecv)) //valid(fVidnr(aRecv,4))
            @10, 4+21 get aRecv[31][14] pict aRecv[31][10] when(fWjaar(aRecv)) //valid(fVidnr(aRecv,4))
            @11, 4+21 get aRecv[32][14] pict aRecv[32][10] when(fWvolg(aRecv)) // valid(fVidnr(aRecv,4))
            @12, 4+21 get aRecv[ 4][14] pict aRecv[ 4][10] when(fWidnr(aRecv)) valid(fVidnr(aRecv,4))

            // If bonsmara - change field heading
            if substr(cTotNaam(),149,3) == "213"
               // Bonsmara
               if cLanType() == "A"
                  @13, 4    say "     Enige opmerking" get aRecv[5][14] pict "@!S20"
               else
                  @13, 4    say "          Any remark" get aRecv[5][14] pict "@!S20"
               endif
            else
               // Else
               // @13, 4+21 get aRecv[ 5][14] pict aRecv[ 5][10] when(fWnaam(aRecv,5))
               @13, 4+21 get aRecv[ 5][14] pict "@!S20" when(fWnaam(aRecv,5))
            endif
            @14, 4+21 get aRecv[39][14] pict aRecv[39][10] // when(fWkalb(aRecv,6)) valid(fVkalb(aRecv,6))
            @15, 4+21 get aRecv[ 7][14] pict aRecv[ 7][10] valid(aRecv[7][14]$" 123") //Geslag
            @16, 4+21 get aRecv[ 8][14] pict aRecv[ 8][10] when(fWgene(aRecv,8,aMoer,aVaar))
            @17, 4+21 get aRecv[ 9][14] pict aRecv[ 9][10] // Geboortemassa
            @18, 4+21 get aRecv[10][14] pict aRecv[10][10] valid(aRecv[10][14]$" 1234") //Vaarkode
            @19, 4+21 get aRecv[11][14] pict aRecv[11][10] valid(aRecv[11][14]$" 123456") //Geboortestatus
            @20, 4+21 get aRecv[13][14] pict aRecv[13][10] when(fWksta(aRecv,13)) valid(aRecv[13][14]$"  z01z02z03z04z05z06z07z08z10") //Kalfstatus

            if cCompos $ "JY"
               @ 7,41+21 get aRecv[29][14] pict aRecv[29][10]
            endif
            @ 8,41+21 get aRecv[12][14] pict aRecv[12][10] when(fWkgem(aRecv,12))
            @ 9,41+21 get aRecv[38][14] pict aRecv[38][10] when(fWeyep(aRecv,38)) valid(aRecv[38][14]$"  z11z12z13z21z22z23z31z32z33") // Oogpigmentasie
            @10,41+21 get aRecv[14][14] pict aRecv[14][10] when(fWiden(aRecv,14))
            @11,41+21 get aRecv[15][14] pict aRecv[15][10] when(fWtipi(aRecv,15))
            @12,41+21 get aRecv[16][14] pict aRecv[16][10] when(fWsuba(aRecv,16))
            @13,41+21 get aRecv[35][14] pict aRecv[35][10] when(fWnage(aRecv,35)) // Na geboorte opmerking
            @14,41+21 get aRecv[36][14] pict aRecv[36][10] when(fWtype(aRecv,36)) // Diertipe
            @15,41+21 get aRecv[17][14] pict aRecv[17][10] //Datum dek ki
            @16,41+21 get aRecv[18][14] pict aRecv[18][10] //Moedermassa
            @17,41+21 get aRecv[19][14] pict aRecv[19][10] when(fWbloe(aRecv,19,aMoer,aVaar)) //Familiekode
            @18,41+21 get aRecv[37][14] pict aRecv[37][10] //Tydelike merk

            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Waarheen nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  nLoop := 1
               case lastkey() == K_UP
                  //Uparrow
                  nLoop--
               case lastkey() == K_ENTER
                  //Enter
                  nLoop++
            endcase

         case nLoop == 5
            //Indeksgroep
            //Skerm
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Begin van voor af  "+D_DNARR+"=Bestaande indeksgroepe  [F1]=Hulp")
               fScrBood(24,"Tik die indeksgroep waarin die kalf prestasiegetoets gaan word.")
            else
               fScrBood(23,"[Esc]=Start again  "+D_DNARR+"=Existing index groups  [F1]=Help")
               fScrBood(24,"Type the index group in which the calf is to be performance tested.")
            endif
            //Read
            @19,41+21 get aRecv[20][14] pict aRecv[20][10] valid(fIndegrp(aRecv[20][14],41))
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Waarheen nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  nLoop := 1
               case lastkey() == K_UP
                  //Uparrow
                  nLoop--
               case lastkey() == K_DOWN
                  //Roep bestaande groepe
                  asize( aVeld, 0 )
                  aadd( aVeld, { "sm3indg", "kode" })
                  aadd( aVeld, { "sm3indg", "besk" })
                  aRecv[20][14] := sm3indg( 4, 45, 20, aVeld, aRecv[20][14] )
               case lastkey() == K_ENTER
                  //Enter
                  nLoop++
            endcase

         case nLoop == 6
            //Waar is dier kode
            //Skerm
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Begin van voor af  "+D_DNARR+"=Waar-is-dier kodes  [F1]=Hulp")
               fScrBood(24,"Tik die nuwe kalf se waar is dier kode.")
            else
               fScrBood(23,"[Esc]=Start again  "+D_DNARR+"=Where-is-animal codes  [F1]=Help")
               fScrBood(24,"Type the where is animal code for the new born calf.")
            endif
            //Read
            @20,41+21 get aRecv[21][14] pict aRecv[21][10] valid(fWaarisd(aRecv[21][14],41))
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            //Waarheen nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  nLoop := 1
               case lastkey() == K_UP
                  //Uparrow
                  nLoop--
               case lastkey() == K_DOWN
                  //Roep kodes
                  asize( aVeld, 0 )
                  aadd( aVeld, { "sm3waar", "kode" })
                  aadd( aVeld, { "sm3waar", "besk" })
                  aRecv[21][14] := sm3waar( 5, 5, 21, aVeld, aRecv[21][14] )
               case lastkey() == K_ENTER
                  //Enter
                  cWaarid := aRecv[21][14]
                  nLoop++
            endcase

         otherwise

            //Vra of data bewaar moet word
            cCscr := savescreen(0,0,24,79)
            if cLanType() == "A"
               fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu" )
            else
               fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu" )
            endif
            //Kry opsienommer
            nCh := 1
            nCh := fNewMenu( nCh, "SM3GEBO" )
            restscreen(0,0,24,79,cCscr)
            do case
               case nCh == 1
                  //Druk en registreer
                  aRecv[24][14] := "G"
                  aRecv[25][14] := aRecv[2][14]
               case nCh == 2
                  //Druk en nie registreer
                  aRecv[23][14] := "1"
                  aRecv[24][14] := "G"
                  aRecv[25][14] := aRecv[2][14]
               case nCh == 3
                  //Druk en nie registreer maar wel kommersieel
                  aRecv[23][14] := "C"
                  aRecv[24][14] := "G"
                  aRecv[25][14] := aRecv[2][14]
               case nCh == 4
                  //Nie druk en nie registreer
                  aRecv[23][14] := "1"
                  aRecv[25][14] := aRecv[2][14]
                  aRecv[ 6][14] := space(8)
               case nCh == 5
                  //Herstel huidige data
                  nLoop := 1
                  lOver := .f.
                  loop
               case nCh == 6
                  //Begin van voor af met nuwe kalf
                  nLoop := 1
                  loop
               otherwise
                  //Menu
                  nLoop := 0
                  loop
            endcase

            //Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Kalf se data word bewaar")
            else
               fScrBood(24,"Data for calf being saved")
            endif

            //Indien tweeling, meerling
            if aRecv[11][14] $ "23456"
               //Soek die ma
               select SM3DATA
               seek aRecv[1][14]
               if !eof()
                  //Kry die laaste kalf
                  if SM3DATA->lkalfn <> space(12)
                     cCarr := SM3DATA->lkalfn
                     seek cCarr
                     if SM3DATA->gebdatum == aRecv[2][14] .and. !eof()
                        do while !rlock()
                        enddo
                        SM3DATA->gebstat  := aRecv[11][14]
                        SM3DATA->tweeling := aRecv[7][14]
                        aRecv[22][14]     := SM3DATA->geslag
                     endif
                  endif
               endif
            endif

            //Bereken geboortemassaverhouding
            if aRecv[18][14] > 0 .and. aRecv[9][14] > 0
               if round((aRecv[9][14]/aRecv[18][14])*100,1) >  0.0 .and. ;
                     round((aRecv[9][14]/aRecv[18][14])*100,1) <= 99.9
                  aRecv[28][14] := round((aRecv[9][14]/aRecv[18][14])*100,1)
               endif
            endif

            //Bewaar die data in hoofleer - kalf
            //Indien inovulasie - ruil skenker en draer om
            if aRecv[10][14] == "4" .and. aRecv[26][14] <> space(12)
               aRecv[27][14] := aRecv[ 1][14]    //Draer word moeder
               aRecv[ 1][14] := aRecv[26][14]    //Moeder word skenker
            endif
            select SM3DATA
            append blank
            do while !rlock()
            enddo
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i][13], aRecv[i][14] )
            next

            //Bewaar die data in hoofleer - moeder
            //Indien inovulasie - Maak moeder weer draer
            if aRecv[10][14] == "4" .and. aRecv[27][14] <> space(12)
               aRecv[1][14] := aRecv[27][14]
            endif
            select SM3DATA
            seek aRecv[1][14]
            do while !rlock()
            enddo
            SM3DATA->lkalfdatum := aRecv[2][14]
            SM3DATA->lkalfn     := aRecv[4][14]

            if ! EMPTY(SM3DATA->dekdat) .AND. aRecv[2,14] > SM3DATA->dekdat
               SM3DATA->dekdat     := ctod("")
               SM3DATA->tipede     := " "
               SM3DATA->dragda     := ctod("")
               SM3DATA->dragti     := " "
               SM3DATA->bulid      := space(12)
               SM3DATA->teelgroep  := space(6)
               SM3DATA->dragwe     := 0
            endif

            //Bewaar volgende beskikbare kalfboeknommer
            //if substr(cTotNaam(),149,3) == "213" .and. ; //Bonsmara
            //      aRecv[6][14] <> space(8)
            if !empty(aRecv[6][14])
               cCarr := ""
               cNcar := ""
               for i = 1 to 8
                  if isalpha(substr(aRecv[6][14],i,1))
                     cCarr := cCarr + substr(aRecv[6][14],i,1)
                  endif
                  if substr(aRecv[6][14],i,1) $ "1234567890"
                     cNcar := cNcar + substr(aRecv[6][14],i,1)
                  endif
               next
               //Open die leer
               cOdbf := fTOpen()
               cFile := fTOpen(cDd(),"stdwaar",,,,.t.,.f.)
               if left(cFile,1) == "f"
               else
                  if cCarr == alltrim(STDWAAR->kalfbn) .and. ;
                        val(cNcar) == STDWAAR->kalfbe
                     do while !rlock()
                     enddo
                     STDWAAR->kalfbe++
                  endif
               endif
               //Sluit leers
               fTClose(cFile)
               fTClose(cOdbf)
            endif

            // Bewaar volgende kalfnommer
            if val(aRecv[fEnum(aRecv,"volgno"),14]) > 0
               cOdbf := fTOpen()
               cFile := fTOpen(cDd(),"stdwaar",,,,.t.,.f.)
               if left(cFile,1) == "f"
               else
                  altd()
                  do while !rlock()
                  enddo
                  cIdle := len(alltrim(aRecv[fEnum(aRecv,"volgno"),14]))
                  if len(ltrim(str(val(aRecv[fEnum(aRecv,"volgno"),14])+1))) > cIdle
                     cIdle := len(ltrim(str(val(aRecv[fEnum(aRecv,"volgno"),14])+1)))
                  endif
                  //Bewaar volgende nommer
                  STDWAAR->volgid := padl(ltrim(str(val(aRecv[fEnum(aRecv,"volgno"),14])+1)),cIdle,"0")
               endif
               //Sluit leers
               fTClose(cFile)
               fTClose(cOdbf)
            endif

            //Bewaar massas in wegingsleer
            if aRecv[ 9][14] > 0 .or. aRecv[18][14] > 0
               //Open die leer
               cOdbf := fTOpen()
               cFile := fTOpen(cDd(),"sm3weeg")
               if left(cFile,1) == "f"
               else

                  //Geboortemassa
                  if aRecv[ 9][14] > 0 .and. aRecv[2][14] <> ctod("")
                     seek aRecv[4][14] + dtos(aRecv[2][14])
                     if eof()
                        append blank
                     endif
                     do while !rlock()
                     enddo
                     SM3WEEG->idnr      := aRecv[4][14]
                     SM3WEEG->weegdatum := aRecv[2][14]
                     SM3WEEG->massa     := aRecv[9][14]
                  endif

                  //Moermassa
                  if aRecv[18][14] > 0 .and. aRecv[2][14] <> ctod("")
                     seek aRecv[1][14] + dtos(aRecv[2][14])
                     if eof()
                        append blank
                     endif
                     do while !rlock()
                     enddo
                     SM3WEEG->idnr      := aRecv[ 1][14]
                     SM3WEEG->weegdatum := aRecv[ 2][14]
                     SM3WEEG->massa     := aRecv[18][14]
                  endif
               endif
               //Sluit leers
               fTClose(cFile)
               fTClose(cOdbf)
            endif

            dbcommitall()

            //Bereken koeigemiddeldes
            sm3koei(aRecv[1][14])

            nLoop := 1

      endcase

   enddo

   //Herstel
   fTClose(cData)

return NIL

//****************************************************************************/
STATIC FUNCTION fDekkings(cMoer,dGebd)

   //Funksie om pa te soek in deklys

   //Verklaar
   local aVaar[5]
   local cOdbf := fTOpen()
   local cDekk := ""
   local aBull := {}
   local aDekt := {}
   local nBoxc := 0
   local cCscr := ""
   local nCh   := 1

   //Waardes
   aVaar[1] := space(12)                         //Vaar id nommer
   aVaar[2] := "1"                               //Vaarkode
   aVaar[3] := ctod("")                          //Dekdatum
   aVaar[4] := space(6)                          //Kalfseisoen
   aVaar[5] := space(12)                         //Skenkerkoei

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Pa van kalf word in die deklys gesoek")
   else
      fScrWbood(24,"Looking for sire of calf in mating list")
   endif

   //Dataleer
   cDekk := fTOpen(cDd(),"sm3dekk",,,,.t.,.f.)
   if left(cDekk,1) == "f"
      return aVaar
   endif

   //Soek ma
   seek cMoer
   if eof()
      //Moeder nie in deklys
      if cLanType() == "A"
         fScrBood(23,"Ma van kalf kom gladnie in die dekkingslˆer voor nie!")
      else
         fScrBood(23,"Mother of calf does not appear in the mating file!")
      endif
      fScrWait(24)
   else
      //Moeder wel in deklys
      //Kry dekkings
      do while SM3DEKK->idmoer == cMoer
         //Indien datum uit nul is, maak datum uit dieselfde as datum in
         if empty(SM3DEKK->datumuit)
            if dGebd >= SM3DEKK->datumin+cMindra .and. ;
                  dGebd <= SM3DEKK->datumin+cMakdra
               //Dekking geldig
               do case
                  case SM3DEKK->vaarkode == "3"
                     if cLanType() == "A"
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede kunsmatig ge‹nsemineer op "+dtoc(SM3DEKK->datumin),62))
                     else
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago artificially insiminated on "+dtoc(SM3DEKK->datumin),62))
                     endif
                  case SM3DEKK->vaarkode == "4"
                     if cLanType() == "A"
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede ge‹novuleer op "+dtoc(SM3DEKK->datumin),62))
                     else
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago inovulated on "+dtoc(SM3DEKK->datumin),62))
                     endif
                  otherwise
                     if cLanType() == "A"
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede natuurlike gedek op "+dtoc(SM3DEKK->datumin),62))
                     else
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago natural service on "+dtoc(SM3DEKK->datumin),62))
                     endif
               endcase
               aadd(aDekt,{SM3DEKK->vaarkode,SM3DEKK->datumin,SM3DEKK->teelgroep,SM3DEKK->donor})
            endif
         else
            if dGebd >= SM3DEKK->datumin+cMindra .and. ;
                  dGebd <= SM3DEKK->datumuit+cMakdra
               //Dekking geldig
               do case
                  case SM3DEKK->vaarkode == "3"
                     if cLanType() == "A"
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede kunsmatig ge‹nsemineer op "+dtoc(SM3DEKK->datumin),62))
                     else
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago artificially insiminated on "+dtoc(SM3DEKK->datumin),62))
                     endif
                  case SM3DEKK->vaarkode == "4"
                     if cLanType() == "A"
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede ge‹novuleer op "+dtoc(SM3DEKK->datumin),62))
                     else
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago inovulated on "+dtoc(SM3DEKK->datumin),62))
                     endif
                  otherwise
                     if cLanType() == "A"
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede natuurlike gedek op "+dtoc(SM3DEKK->datumin),62))
                     else
                        aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago natural service on "+dtoc(SM3DEKK->datumin),62))
                     endif
               endcase
               aadd(aDekt,{SM3DEKK->vaarkode,SM3DEKK->datumin,SM3DEKK->teelgroep,SM3DEKK->donor})
            endif
         endif
         skip
      enddo
      //Kry bulle
      if len(aBull) == 0
         //Geen vader in deklys
         if cLanType() == "A"
            fScrBood(23,"Geen pa kon in die deklys opgespoor word nie!")
            fScrWait(24,"Moontlik is die geboortedatum verkeerd")
         else
            fScrBood(23,"No sire could be traced in the mating list!")
            fScrWait(24,"The birth date is possibly incorrect")
         endif
      elseif len(aBull) == 1
         //Slegs een vader
         aVaar[1] := left(aBull[1],12)
         aVaar[2] := aDekt[1][1]
         aVaar[3] := aDekt[1][2]
         aVaar[4] := aDekt[1][3]
         aVaar[5] := aDekt[1][4]
      else
         //Vertoon moontlike vaders en kies een
         cCscr := savescreen(0,0,24,79)
         if cLanType() == "A"
            fScrBood(23,"[Esc]=Nie een van die pa's nie")
            fScrBood(24,"Kies een van die pa's met die op- en afpyltjies en druk "+D_ENTER)
            nBoxc := fBoxCent(15,space(62),5,"MOONTLIKE PA'S")
         else
            fScrBood(23,"[Esc]=None of the sires")
            fScrBood(24,"Choose one of the sires with the up and down arrows and press "+D_ENTER)
            nBoxc := fBoxCent(15,space(62),5,"POSSIBLE SIRES")
         endif
         nCh := achoice(15,nBoxc,19,nBoxc+62,aBull)
         if nCh > 0
            aVaar[1] := left(aBull[nCh],12)
            aVaar[2] := aDekt[nCh][1]
            aVaar[3] := aDekt[nCh][2]
            aVaar[4] := aDekt[nCh][3]
            aVaar[5] := aDekt[nCh][4]
         endif
         restscreen(0,0,24,79,cCscr)
      endif
   endif

   //Herstel
   fTClose(cDekk)
   fTClose(cOdbf)
return aVaar

/******************************************************************************/
STATIC FUNCTION fWkudd(aRecv)

   // Function to pre-validate the herd designation mark

   // Declare variables
   local lRetu := .t.
   local nElem := fEnum(aRecv,"kuddek")

   // Only when empty
   if empty(aRecv[nElem,14])
      aRecv[nElem,14] := substr(cTotNaam(),125,4)
      lRetu := .f.
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWjaar(aRecv)

   // Function to pre-validate the year letter

   // Declare variables
   local lRetu := .t.
   local nElem := fEnum(aRecv,"jaarle")
   local nDate := fEnum(aRecv,"gebdatum")

   // Only when empty
   if empty(aRecv[nElem,14])
      aRecv[nElem,14] := substr(dtos(aRecv[nDate,14]),3,2)
      lRetu := .f.
   endif

return lRetu

//**************************************************************************/
STATIC FUNCTION fWvolg(aRecv)

   //Kry die volgende kalf se nommer

   //Verklaar
   local lRetu := .t.
   // local aCdbf := fATopen()
   local cOdbf := fTOpen()
   local cWaar := ""
   local cData := space(11)
   local nElem := fEnum(aRecv,"volgno")

   if empty(aRecv[nElem,14])

      //Open die leer
      cWaar := fTOpen(cDd(),"stdwaar",,,,.t.,.f.)
      if left(cWaar,1) == "f"
         return lRetu
      endif

      //Kry die id nommer
      aRecv[nElem][14] := left(STDWAAR->volgid,4)

      //Herstel
      fTClose(cWaar)
      fTClose(cOdbf)

   endif

   //Herstel

return lRetu

//**************************************************************************/
STATIC FUNCTION fWidnr(aRecv)

   //Kry die volgende kalf se nommer

   //Verklaar
   local lRetu := .t.
   local cData := space(11)
   local nElem := fEnum(aRecv,"idnr")
   local nHbeg := 1
   local nYbeg := 1
   local nSbeg := 1
   local cMask := padr(cIdMask(),12)
   local i := 0

   //if len(alltrim(aRecv[nElem][14])) == 0

   // Build the Id number
   if cIdform() == "3"

      // Other formats

      // Build the variables
      for i := 1 to len(cMask)
         if substr(cMask,i,1) $ "HK"
            cMask := stuff(cMask,i,1,substr(aRecv[fEnum(aRecv,"kuddek"),14],nHbeg,1))
            nHbeg++
         elseif substr(cMask,i,1) $ "YJ"
            cMask := stuff(cMask,i,1,substr(aRecv[fEnum(aRecv,"jaarle"),14],nYbeg,1))
            nYbeg++
         elseif substr(cMask,i,1) $ "SV"
            cMask := stuff(cMask,i,1,substr(aRecv[fEnum(aRecv,"volgno"),14],nSbeg,1))
            nSbeg++
         endif
      next
      aRecv[nElem][14] := cMask

   elseif cIdform() == "2"
      // Multibreed format
      aRecv[nElem][14] := alltrim(aRecv[fEnum(aRecv,"jaarle"),14]) + ;
         cBreekk + ;
         padl(alltrim(aRecv[fEnum(aRecv,"volgno"),14]),4,"0") + ;
         alltrim(aRecv[fEnum(aRecv,"kuddek"),14])
   else
      // Studmaster format
      if len(trim(aRecv[fEnum(aRecv,"volgno"),14])) >= 4
         aRecv[nElem][14] := alltrim(aRecv[fEnum(aRecv,"kuddek"),14]) + ;
            alltrim(aRecv[fEnum(aRecv,"jaarle"),14]) + ;
            cBreekk + ;
            padl(alltrim(aRecv[fEnum(aRecv,"volgno"),14]),4,"0")
      else
         aRecv[nElem][14] := alltrim(aRecv[fEnum(aRecv,"kuddek"),14]) + ;
            alltrim(aRecv[fEnum(aRecv,"jaarle"),14]) + ;
            cBreekk + ;
            padl(alltrim(aRecv[fEnum(aRecv,"volgno"),14]),3,"0")
      endif
   endif

   //endif

   //Herstel
   aRecv[nElem,14] := PADR(aRecv[nElem,14],12," ")

return lRetu

//**************************************************************************/
STATIC FUNCTION fVidnr(aRecv,nElem)

   //Kyk of kalf nie reeds bestaan nie

   //Verklaar
   local lRetu := .t.
   local cOdbf := fTOpen()
   local cCscr := savescreen(23,0,24,79)

   //Open die leer
   select SM3DATA
   set order to 1

   if len(trim(aRecv[nElem,14])) == 0
      if cLanType() == "A"
         fScrBood(23,"Kalf Id nommer is verpligtend!")
      else
         fScrBood(23,"Calf Id number is compulsory!")
      endif
      fScrWait(24)
      lRetu := .f.
   else
      seek aRecv[nElem][14]
      if !eof()
         if cLanType() == "A"
            fScrBood(23,"Die kalf is reeds op rekenaar!")
         else
            fScrBood(23,"This calf is already on computer!")
         endif
         fScrWait(24)
         lRetu := .f.
      endif
   endif

   //Herstel
   restscreen(23,0,24,79,cCscr)
   fTClose(cOdbf)
return lRetu

//**************************************************************************/
STATIC FUNCTION fWnaam(aRecv,nElem)

   //Kyk of naam gevra moet word of nie

   //Verklaar
   local lRetu := .t.
   local cData := fId(aRecv[4][14],.t.)
   local cTemp := ""

   //Moet vra?
   if substr(cTotNaam(),149,3) == "213"          //Bonsmara
      lRetu := .f.
   elseif substr(cTotNaam(),149,3) == "244"      //Wagyu
      // Added 17-11-08 13:50
      if len(alltrim(aRecv[nElem][14])) == 0
         aRecv[nElem][14] := trim(substr(cTotNaam(),129,20)) //Voorvoegsel
         aRecv[nElem][14] := aRecv[nElem][14] + trim(aRecv[31][14]) //Jaartal
         cTemp := right("000" + trim(aRecv[32][14]),4)
         aRecv[nElem][14] := aRecv[nElem][14] + cTemp //Volgnommer
         aRecv[nElem][14] := padr(aRecv[nElem][14],aRecv[nElem][4]) //Maak regte lengte
         keyboard chr(K_END)
      endif
   else
      if len(alltrim(aRecv[nElem][14])) == 0
         aRecv[nElem][14] := trim(substr(cTotNaam(),129,20)) + " " //Voorvoegsel
         aRecv[nElem][14] := aRecv[nElem][14] + trim(aRecv[31][14]) + " " //Jaartal
         aRecv[nElem][14] := aRecv[nElem][14] + trim(aRecv[32][14]) //Volgnommer
         aRecv[nElem][14] := padr(aRecv[nElem][14],aRecv[nElem][4]) //Maak regte lengte
         // Replaced 07-05-22 10:54
         // Name was not given correctly
         // Now use data directly from keyboard entry
         //aRecv[nElem][14] := aRecv[nElem][14] + trim(substr(cData,5,2)) + " " //Jaartal
         //aRecv[nElem][14] := aRecv[nElem][14] + trim(right(cData,4)) //Volgnommer
         //aRecv[nElem][14] := padr(aRecv[nElem][14],aRecv[nElem][4]) //Maak regte lengte
         keyboard chr(K_END)
      endif
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWkalb(aRecv,nElem)

   //Kyk of kalfboeknommer gevra moet word

   //Verklaar
   local lRetu := .t.
   local cOdbf := fTOpen()
   local cWaar := ""
   local cCscr := ""
   begin sequence

      //Moet vra?
      //if substr(cTotNaam(),149,3) == "213"          //Bonsmara

      if empty(aRecv[nElem][14])

         //Skerm
         cCscr := savescreen(23,0,24,79)

         //Open die leer
         cWaar := fTOpen(cDd(),"stdwaar",,,,.t.,.f.)
         if left(cWaar,1) == "f"
            break
         endif

         if empty(STDWAAR->kalfbn) .or. empty(STDWAAR->kalfbe) .or. empty(STDWAAR->kalfbl)
            lRetu := .f.
            if substr(cTotNaam(),149,3) == "213" //Bonsmara
               //Kalfboeknommers onbekend
               if cLanType() == "A"
                  fScrBood(23,"Skakel die genootskap om 'n reeks rekenaar kalfboeknommers te kry!")
                  fScrWait(24,"Bewaar hierdie nommers by Diverse kudde handelinge")
               else
                  fScrBood(23,"Contact the society for a series of computer calf book numbers!")
                  fScrWait(24,"Enter these numbers at Sundry herd options")
               endif
            endif
            break

         elseif STDWAAR->kalfbe <= STDWAAR->kalfbl

            //Kalfboeknommers is beskikbaar
            aRecv[nElem][14] := padr(alltrim(STDWAAR->kalfbn)+padl(ltrim(str(STDWAAR->kalfbe)),4,"0"),aRecv[nElem][4])

            //Kalfboeknommers raak min
            if STDWAAR->kalfbl - STDWAAR->kalfbe < 100
               if cLanType() == "A"
                  fScrBood(23,"Daar is nog "+ltrim(str(STDWAAR->kalfbl-STDWAAR->kalfbe,3,0))+" kalfboeknommers in u huidige reeks beskikbaar!")
                  fScrWait(24)
               else
                  fScrBood(23,"There are "+ltrim(str(STDWAAR->kalfbl-STDWAAR->kalfbe,3,0))+" calf book numbers left in the current series!")
                  fScrWait(24)
               endif
            endif

         else

            //Kalfboeknommers klaar
            if cLanType() == "A"
               fScrBood(23,"Die reeks kalfboeknommers aan u toegeken is klaar!")
               fScrWait(24)
            else
               fScrBood(23,"The calf book number series is finished!")
               fScrWait(24)
            endif

         endif

         //Herstel
         fTClose(cWaar)
         fTClose(cOdbf)
         restscreen(23,0,24,79,cCscr)

      endif

   end
   //Herstel

return lRetu

//**************************************************************************/
STATIC FUNCTION fVkalb(aRecv,nElem)

   //Kyk of kalfboeknommer nie reeds bestaan nie

   //Verklaar
   local lRetu := .t.
   local cOdbf := fTOpen()
   local cCscr := savescreen(23,0,24,79)

   //Open die leer
   if len(trim(aRecv[nElem][14])) > 0
      select SM3DATA
      set order to 6
      seek padl(alltrim(aRecv[nElem][14]),10,"0")
      if !eof()
         if cLanType() == "A"
            fScrBood(23,"Die kalfboeknommer is reeds gebruik en behoort aan "+trim(SM3DATA->idnr)+"!")
         else
            fScrBood(23,"The calf book number has been used and belongs to "+trim(SM3DATA->idnr)+"!")
         endif
         fScrWait(24)
         lRetu := .f.
      endif
   endif

   //Herstel
   restscreen(23,0,24,79,cCscr)
   fTClose(cOdbf)
return lRetu

//**************************************************************************/
STATIC FUNCTION fWgene(aRecv,nElem,aMoer,aVaar)

   //Bereken die kalf se nuwe generasie

   //Verklaar
   local lRetu := .t.

   if len(alltrim(aRecv[nElem][14])) == 0
      //Bonsmara
      if substr(cTotNaam(),149,3) == "213"       //Bonsmara
         if     aVaar[3] == "SP" .and. "F"  $ aMoer[3]
            aRecv[nElem][14] := "A "
         elseif aVaar[3] == "SP" .and. "A"  $ aMoer[3]
            aRecv[nElem][14] := "B "
         elseif aVaar[3] == "SP" .and. "B"  $ aMoer[3]
            aRecv[nElem][14] := "SP"
         elseif aVaar[3] == "SP" .and. "SP" $ aMoer[3]
            aRecv[nElem][14] := "SP"
         endif
         //Angus
         //Added 17-11-08 13:49
      elseif substr(cTotNaam(),149,3) == "211"   //Angus
         if aVaar[3] == "SP" .and. "A"  $ aMoer[3]
            aRecv[nElem][14] := "B "
         elseif aVaar[3] == "SP" .and. "B"  $ aMoer[3]
            aRecv[nElem][14] := "SP"
         elseif aVaar[3] == "SP" .and. "SP" $ aMoer[3]
            aRecv[nElem][14] := "SP"
         endif
         //Brahman
      elseif substr(cTotNaam(),149,3) == "214"   //Brahman
         if     aVaar[3] == "SP" .and. "A"  $ aMoer[3]
            aRecv[nElem][14] := "B "
         elseif aVaar[3] == "SP" .and. "B"  $ aMoer[3]
            aRecv[nElem][14] := "C "
         elseif aVaar[3] == "SP" .and. "C"  $ aMoer[3]
            aRecv[nElem][14] := "D "
         elseif aVaar[3] == "SP" .and. "D"  $ aMoer[3]
            aRecv[nElem][14] := "E "
         elseif aVaar[3] == "SP" .and. "E"  $ aMoer[3]
            aRecv[nElem][14] := "SP"
         elseif aVaar[3] == "SP" .and. "SP" $ aMoer[3]
            aRecv[nElem][14] := "SP"
         endif
      elseif substr(cTotNaam(),149,3) == "225"   //Nguni
         if "A" $ aVaar[3] .or. "A"  $ aMoer[3]
            aRecv[nElem][14] := "B "
         elseif "B" $ aVaar[3] .or. "B"  $ aMoer[3]
            aRecv[nElem][14] := "SP"
         elseif "SP" $ aVaar[3] .or. "SP"  $ aMoer[3]
            aRecv[nElem][14] := "SP"
         endif
      endif
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWkgem(aRecv,nElem)

   //Kyk of gemak van kalwing gevra moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cKalfge)) == 0
      lRetu := .f.
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWksta(aRecv,nElem)

   //Kyk of kalfstatus gevra moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cKalfst)) == 0
      lRetu := .f.
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWiden(aRecv,nElem)

   //Kyk of identifikasie moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cIdenti)) == 0
      lRetu := .f.
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWeyep(aRecv,nElem)

   // Kyk of oogpigmentasie moet word

   // Verklaar
   local lRetu := .t.

   // Moet vra?
   if len(alltrim(cEyepig)) == 0
      lRetu := .f.
   endif

   // Herstel

return lRetu

//**************************************************************************/
STATIC FUNCTION fWsuba(aRecv,nElem)

   //Kyk of subafdeling gevra moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cSubafd)) == 0
      lRetu := .f.
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWnage(aRecv,nElem)

   //Kyk of na geboorte gevra moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cNagebo)) == 0
      lRetu := .f.
   endif

   //Herstel

return lRetu

//**************************************************************************/
STATIC FUNCTION fWtype(aRecv,nElem)

   //Kyk of diertipe gevra moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cAniTyp)) == 0
      lRetu := .f.
   endif

   //Herstel

return lRetu

//**************************************************************************/
STATIC FUNCTION fWtipi(aRecv,nElem)

   //Kyk of tipies gevra moet word

   //Verklaar
   local lRetu := .t.

   //Moet vra?
   if len(alltrim(cTipies)) == 0
      lRetu := .f.
   endif

   //Herstel
return lRetu

//**************************************************************************/
STATIC FUNCTION fWbloe(aRecv,nElem,aMoer,aVaar)

   //Bereken die kalf se familiekode

   //Verklaar
   local lRetu := .t.

   if len(alltrim(aRecv[nElem][14])) == 0
      // Removed for Burkhard Herrman 09-07-31 10:13
      //if aVaar[4] <> "  "
      //   aRecv[nElem][14] := aVaar[4]
      //else
      aRecv[nElem][14] := aMoer[4]
      //endif
   endif

   //Herstel
return lRetu

//******************************************************************************/
STATIC FUNCTION fIndegrp(cData,nBoxc)

   //Verklaar
   local getlist := {}
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local cDbfs   := fTOpen()
   local cFile   := ""
   local lLoop   := .t.

   //Nul data
   if cData == "      "
      return lRetu
   endif

   //Open .dbf
   cFile := fTOpen( cDd(), "sm3indg", , "dbf", , .t., .f. )
   if left( cFile, 1 ) == "f"
   else
      select SM3INDG
      seek cData
      if eof()
         //Skerm
         if cLanType() == "A"
            fScrWbood(23,"Indeksgroep is onbekend!")
            if fJaNee(24,"Moet die indeksgroep bewaar word?",,.f.)
               append blank
               do while !rlock()
               enddo
               SM3INDG->kode := cData
               lLoop := .t.
               do while lLoop
                  fScrBood(23)
                  fScrBood(24,"Tik 'n kort beskrywing van die indeksgroep!")
                  @20,41 say "Indeksgrp beskrywing" get SM3INDG->besk pict "@S15"
                  set cursor on
                  read
                  set cursor off
                  lLoop := .f.
               enddo
            endif
         else
            fScrWbood(23,"Index group is unknown!")
            if fJaNee(24,"Should the index group be saved?",,.f.)
               append blank
               do while !rlock()
               enddo
               SM3INDG->kode := cData
               lLoop := .t.
               do while lLoop
                  fScrBood(23)
                  fScrBood(24,"Type a short description for the index group!")
                  @20,41 say "Index group descript" get SM3INDG->besk pict "@S15"
                  set cursor on
                  read
                  set cursor off
                  lLoop := .f.
               enddo
            endif
         endif
      endif
   endif

   //Herstel
   fTClose(cFile)
   fTClose(cDbfs)
   restscreen(0,0,24,79,cCscr)
return lRetu

/******************************************************************************/
STATIC FUNCTION fWaarisd(cData,nBoxc)

   //Verklaar
   local getlist := {}
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local cDbfs   := fTOpen()
   local cFile   := ""
   local lLoop   := .t.

   //Nul data
   if cData == "  "
      return lRetu
   endif

   //Open .dbf
   cFile := fTOpen( cDd(), "sm3waar", , "dbf", , .t., .f. )
   if left( cFile, 1 ) == "f"
   else
      select SM3WAAR
      seek cData
      if eof()
         //Skerm
         if cLanType() == "A"
            fScrWbood(23,"Waar is dier kode is onbekend!")
            if fJaNee(24,"Moet die waar is dier kode bewaar word?",,.f.)
               append blank
               do while !rlock()
               enddo
               SM3WAAR->kode := cData
               lLoop := .t.
               do while lLoop
                  fScrBood(23)
                  fScrBood(24,"Tik 'n kort beskrywing van die waar is dier kode!")
                  @20,41 say "WaarIsDierBeskrywing" get SM3WAAR->besk pict "@S15"
                  set cursor on
                  read
                  set cursor off
                  lLoop := .f.
               enddo
            endif
         else
            fScrWbood(23,"Where is animal code is unknown!")
            if fJaNee(24,"Should the where is animal code be saved?",,.f.)
               append blank
               do while !rlock()
               enddo
               SM3WAAR->kode := cData
               lLoop := .t.
               do while lLoop
                  fScrBood(23)
                  fScrBood(24,"Type a short description for the where is animal code!")
                  @20,41 say "WhereIsAnimalDescrip" get SM3WAAR->besk pict "@S15"
                  set cursor on
                  read
                  set cursor off
                  lLoop := .f.
               enddo
            endif
         endif
      endif
   endif

   //Herstel
   fTClose(cFile)
   fTClose(cDbfs)
   restscreen(0,0,24,79,cCscr)
return lRetu


