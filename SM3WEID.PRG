//SM3WEID.PRG
//Program om weegdatumgrense te bereken en te bewaar
//Kopiereg (c) 1992 A van Rensburg
//12:04 26 Mar,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/***************************************************************************/
FUNCTION sm3weid

   //Verklaar
   local getlist := {}
   local cSm3Kale := ""
   local cSm3Data := ""
   local cSm3Indg := ""
   local cCurDbf  := ""
   local lLoop    := .t.
   local h001     := space(12)
   local h002     := space(12)
   local d001     := ctod("  /  /  ")
   local d002     := ctod("  /  /  ")
   local cData    := ""
   local lData    := .f.
   local lLoo2    := .t.
   local cIndg    := "      "
   local aVelde   := {}
   local lVraa    := .f.
   local nAant    := 1
   local dDate    := ctod("")
   local cBood    := ""
   local lBest    := .f.
   local lLaas    := .f.

   //Skerm
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   //Open .dbf
   if cLanType() == "A"
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrWbood( 24, "Data files being opened" )
   endif
   cSm3Kale := fTOpen( cDd(), "sm3kale", , "dbf", , .t. )
   if left( cSm3Kale, 1 ) == "f"
      return NIL
   endif
   cSm3Data := fTOpen( cDd(), "sm3data", , "dbf", , .t. )
   if left( cSm3Data, 1 ) == "f"
      fTClose( cSm3Kale )
      return NIL
   endif

   lLoop := .t.
   do while lLoop

      //.dbf
      select SM3DATA

      //Skerm
      if cLanType() == "A"
         fBox( 3, 2, maxrow()-3, maxcol()-3, "Bereken weegdatumgrense", cColNorm() )
      else
         fBox( 3, 2, maxrow()-3, maxcol()-3, "Calculate weigh date boundaries", cColNorm() )
      endif

      //Vra die ID nommers
      if cLanType() == "A"
         h001 := sm3idnr( h001, 5, 4, "    Idnr oudste kalf", "Tik die ID nommer van die oudste kalf van die groep en druk "+D_ENTER, "OUDSTE KALF", .f. )
      else
         h001 := sm3idnr( h001, 5, 4, "   Id no oldest calf", "Type the ID number of the oldest calf in the group and press "+D_ENTER, "OLDEST CALF", .f. )
      endif
      do case
         case left( h001, 9 ) == "CANCELLED"
            lLoop := .f.
            loop
         case left( h001, 3 ) == "NOT"
            lLoop := .f.
            loop
      endcase
      //Kalf moet bestaan
      seek h001
      if eof()
         fScrBood(23)
         if cLanType() == "A"
            fScrWait(24,"Oudste kalf onbekend!")
         else
            fScrWait(24,"Oldest calf unknown!")
         endif
         loop
      endif
      //Kalf moet geboortedatum he
      if SM3DATA->gebdatum == ctod("  /  /  ")
         fScrBood(23)
         if cLanType() == "A"
            fScrWait(24,"Oudste kalf het nie 'n geboortedatum nie!")
         else
            fScrWait(24,"Oldest calf has no date of birth!")
         endif
         loop
      endif
      d001 := SM3DATA->gebdatum
      //Skerm
      if cLanType() == "A"
         @ 5,37 say "    Geboortedatum"
      else
         @ 5,37 say "    Date of birth"
      endif
      setcolor( cColInve() )
      @ 5,55 say d001
      setcolor( cColNorm() )

      //Tweede nommer
      if cLanType() == "A"
         h002 := sm3idnr( h002, 7, 4, "   Idnr jongste kalf", "Tik die ID nommer van die jongste kalf van die groep en druk "+D_ENTER, "Jongste kalf", .f. )
      else
         h002 := sm3idnr( h002, 7, 4, "   Id no youngest calf", "Type the ID number of the youngest calf of the group and press "+D_ENTER, "Youngest calf", .f. )
      endif
      do case
         case left( h002, 9 ) == "CANCELLED"
            lLoop := .f.
            loop
         case left( h002, 3 ) == "NOT"
            lLoop := .f.
            loop
      endcase
      //Kalf moet bestaan
      seek h002
      if eof()
         fScrBood(23)
         if cLanType() == "A"
            fScrWait(24,"Jongste kalf onbekend!")
         else
            fScrWait(24,"Youngest calf unknown!")
         endif
         keyboard chr(13)
         loop
      endif
      //Kalf moet geboortedatum he
      if SM3DATA->gebdatum == ctod("  /  /  ")
         fScrBood(23)
         if cLanType() == "A"
            fScrWait(24,"Jongste kalf het nie 'n geboortedatum nie!")
         else
            fScrWait(24,"Youngest calf has no date of birth!")
         endif
         keyboard chr(13)
         loop
      endif
      d002 := SM3DATA->gebdatum
      //Skerm
      if cLanType() == "A"
         @ 7,37 say "    Geboortedatum"
      else
         @ 7,37 say "    Date of birth"
      endif
      setcolor( cColInve() )
      @ 7,55 say d002
      setcolor( cColNorm() )
      //Oudste kalf se datum nie groter as jongste kalf se datum
      if d001 > d002
         fScrBood(23)
         if cLanType() == "A"
            fScrWait(24,"Die oudste kalf is nie die oudste nie!")
         else
            fScrWait(24,"The oldest calf is not the oldest!")
         endif
         loop
      endif

      //Skerm
      if cLanType() == "A"
         @10, 4 say "  Voorspeen (100dae)          tot            Beste          "
         @12, 4 say "      Speen (205dae)          tot            Beste          "
         @14, 4 say "       Jaar (365dae)          tot            Beste          "
         @16, 4 say "  18 Maande (540dae)          tot            Beste          "
      else
         @10, 4 say "    Prewean (100days)         to             Best          "
         @12, 4 say "       Wean (205days)         to             Best          "
         @14, 4 say "       Year (365days)         to             Best          "
         @16, 4 say "  18 Months (540days)         to             Best          "
      endif

      //Kleur
      setcolor( cColInve() )

      //Voorspeen
      if d002+51 > d001+150
         @10,25 say "00/00/00"
         @10,38 say "00/00/00"
         @10,55 say "00/00/00"
      else
         lVraa := .t.
         @10,25 say d002+51
         @10,38 say d001+150
         @10,55 say (d002+51)+int( ( (d001+150) - (d002+51) ) /2 )
      endif

      //Speen
      if d002+151 > d001+250
         @12,25 say "00/00/00"
         @12,38 say "00/00/00"
         @12,55 say "00/00/00"
      else
         lVraa := .t.
         @12,25 say d002+151
         @12,38 say d001+250
         @12,55 say (d002+151)+int( ( (d001+250) - (d002+151) ) /2 )
      endif

      //Jaar
      if d002+316 > d001+415
         @14,25 say "00/00/00"
         @14,38 say "00/00/00"
         @14,55 say "00/00/00"
      else
         lVraa := .t.
         @14,25 say d002+316
         @14,38 say d001+415
         @14,55 say (d002+316)+int( ( (d001+415) - (d002+316) ) /2 )
      endif

      //18 maande
      if d002+491 > d001+590
         @16,25 say "00/00/00"
         @16,38 say "00/00/00"
         @16,55 say "00/00/00"
      else
         lVraa := .t.
         @16,25 say d002+491
         @16,38 say d001+590
         @16,55 say (d002+491)+int( ( (d001+590) - (d002+491) ) /2 )
      endif

      //Kleur
      setcolor( cColNorm() )

      //Vra of datums in dagboek bewaar moet word
      if lVraa

         fScrBood(23)
         if cLanType() == "A"
            cBood := "Moet vroegste datums in die dagboek bewaar word?"
         else
            cBood := "Should earliest dates be entered in the diary?"
         endif

         if fJaNee(24,cBood)

            //Bewaar in dagboek

            //.dbf
            select SM3KALE

            //Voorspeen
            if d002+51 > d001+150
            else
               //Bou waarde
               dDate := d002+51
               if cLanType() == "A"
                  cData := "100d Weeg " + trim(h001) + " tot " + trim(h002) + " voor " + dtoc(d001+150)
               else
                  cData := "100d Weigh " + trim(h001) + " to " + trim(h002) + " before " + dtoc(d001+150)
               endif
               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //Speen
            if d002+151 > d001+250
            else
               //Bou waarde
               dDate := d002+151
               if cLanType() == "A"
                  cData := "205d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+250)
               else
                  cData := "205d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+270)
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //Jaar
            if d002+316 > d001+415
            else
               //Bou waarde
               dDate := d002+316
               if cLanType() == "A"
                  cData := "365d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+415)
               else
                  cData := "365d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+415)
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //18 Maande
            if d002+491 > d001+590
            else
               //Bou waarde
               dDate := d002+491
               if cLanType() == "A"
                  cData := "540d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+590)
               else
                  cData := "540d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+590)
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

         endif

      else

         if cLanType() == "A"
            fScrBood(23,"Groep kalwers kan nie saam geweeg word nie!")
         else
            fScrBood(23,"Group of calves cannot be weighed together!")
         endif
         fScrWait(24)

      endif

      if lVraa

         fScrBood(23)
         if cLanType() == "A"
            cBood := "Moet beste datums ook in die dagboek bewaar word?"
         else
            cBood := "Should best dates also be entered into the diary?"
         endif

         if fJaNee(24,cBood)
            //Bewaar in dagboek

            //.dbf
            select SM3KALE

            //Voorspeen
            if d002+51 > d001+150
            else
               //Bou waarde
               dDate := (d002+51)+int(((d001+150)-(d002+51))/2)
               if cLanType() == "A"
                  cData := "100d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+150) + " (Beste)"
               else
                  cData := "100d Weigh " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+150) + " (Best)"
               endif
               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //Speen
            if d002+151 > d001+250
            else
               //Bou waarde
               dDate := (d002+151)+int(((d001+250)-(d002+151))/2)
               if cLanType() == "A"
                  cData := "205d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+250) + " (Beste)"
               else
                  cData := "205d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+250) + " (Best)"
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //Jaar
            if d002+316 > d001+415
            else
               //Bou waarde
               dDate := (d002+316)+int(((d001+415)-(d002+316))/2)
               if cLanType() == "A"
                  cData := "365d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+415) + " (Beste)"
               else
                  cData := "365d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+415) + " (Best)"
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //18 Maande
            if d002+491 > d001+590
            else
               //Bou waarde
               dDate := (d002+491)+int(((d001+590)-(d002+491))/2)
               if cLanType() == "A"
                  cData := "540d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " voor " + dtoc(d001+590) + " (Beste)"
               else
                  cData := "540d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " before " + dtoc(d001+590) + " (Best)"
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

         endif

      endif

      if lVraa

         fScrBood(23)
         if cLanType() == "A"
            cBood := "Moet laaste datums ook in die dagboek bewaar word?"
         else
            cBood := "Should last dates also be entered into the diary?"
         endif

         if fJaNee(24,cBood)
            //Bewaar in dagboek

            //.dbf
            select SM3KALE

            //Voorspeen
            if d002+51 > d001+150
            else
               //Bou waarde
               dDate := d001+150
               if cLanType() == "A"
                  cData := "100d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " laaste kans"
               else
                  cData := "100d Weigh " + trim(h001) + " to " + trim(h002) + ;
                     " last chance"
               endif
               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //Speen
            if d002+151 > d001+250
            else
               //Bou waarde
               dDate := d001+250
               if cLanType() == "A"
                  cData := "205d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " laaste kans"
               else
                  cData := "205d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " last chance"
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //Jaar
            if d002+316 > d001+415
            else
               //Bou waarde
               dDate := d001+415
               if cLanType() == "A"
                  cData := "365d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " laaste kans"
               else
                  cData := "365d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " last chance"
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

            //18 Maande
            if d002+491 > d001+590
            else
               //Bou waarde
               dDate := d001+634
               if cLanType() == "A"
                  cData := "540d Weeg " + trim(h001) + " tot " + trim(h002) + ;
                     " laaste kans"
               else
                  cData := "540d Weight " + trim(h001) + " to " + trim(h002) + ;
                     " last chance"
               endif

               //Kyk of datum reeds bestaan
               seek dtos(dDate)
               if eof()
                  //Sit by indien nie bestaan
                  appe blank
                  SM3KALE->datum     := dDate
                  SM3KALE->handeling := cData
               else
                  //Datum bestaan wel
                  lData := .f.
                  //Kyk of handeling reeds bestaan
                  do while SM3KALE->datum == dDate
                     if SM3KALE->handeling == cData
                        lData := .t.
                     endif
                     skip
                  enddo
                  if lData == .f.
                     //Handeling bestaan nie
                     appe blank
                     SM3KALE->datum     := dDate
                     SM3KALE->handeling := cData
                  endif
               endif
            endif

         endif

      endif

      //Vra of groep diere in indeksgroep geplaas moet word
      if lVraa
         fScrBood(23)
         if cLanType() == "A"
            cBood := "Moet bogenoemde groep diere in 'n indeksgroep geplaas word?"
         else
            cBood := "Should above-mentioned group of animals be placed in an index group?"
         endif
         if fJaNee(24,cBood)
            //Bewaar in indeksgroep
            lLoo2 := .t.
            do while lLoo2

               //Vra die indeksgroep
               if cLanType() == "A"
                  fScrBood( 23, "[Esc]=Moenie diere in groep plaas  "+D_DNARR+"=Bestaande indeksgroepe" )
                  fScrBood( 24, "Tik 'n beskrywende INDEKSGROEPKODE vir die groep diere." )
                  @19, 4 say "         Indeksgroep" get cIndg pict "@!"
               else
                  fScrBood( 23, "[Esc]=Do not place animals in group  "+D_DNARR+"=Existing index groups" )
                  fScrBood( 24, "Type a descriptive INDEX GROUP CODE for the group of animals." )
                  @19, 4 say "         Index group" get cIndg pict "@!"
               endif
               readexit(.t.)
               set cursor on
               read
               set cursor off
               readexit(.f.)

               do case
                  case lastkey() == K_ESC
                     //Exit
                     exit
                  case lastkey() == K_ENTER .and. cIndg <> "      "
                     //Bewaar kode in groepleer en by elke dier

                     //Bewaar indeksgroep in indeksgroepleer
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWbood(24,"Indeksgroep word in indeksgroepelˆer bewaar")
                     else
                        fScrWbood(24,"Index group being placed in index group file")
                     endif
                     cCurDbf := fTOpen()
                     cSm3Indg := fTOpen( cDd(), "sm3indg", , "dbf", , .t. )
                     if left( cSm3Indg, 1 ) == "f"
                     else
                        seek cIndg
                        if eof()
                           append blank
                           SM3INDG->kode := cIndg
                           if cLanType() == "A"
                              SM3INDG->besk := "Bereken weegdatums  "
                           else
                              SM3INDG->besk := "Calc weighing dates "
                           endif
                        endif
                        fTClose( cSm3Indg )
                     endif
                     fTClose( cCurDbf )

                     //Plaas kalwers in indeksgroepe
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWbood(24,"Kalwers word in indeksgroepe ingedeel")
                     else
                        fScrWbood(24,"Calves being entered into index groups")
                     endif
                     select SM3DATA
                     go top
                     setcolor( cColBott() )
                     do while !eof()
                        if cLanType() == "A"
                           @23,45 say fPercent( nAant, lastrec() ) + "% voltooi"
                        else
                           @23,45 say fPercent( nAant, lastrec() ) + "% completed"
                        endif
                        if SM3DATA->gebdatum >= d001 .and. SM3DATA->gebdatum <= d002
                           if rlock()
                              @23,30 say SM3DATA->idnr
                              SM3DATA->indekskode := cIndg
                              dbUnlock()
                           endif
                        endif
                        nAant++
                        skip
                     enddo
                     setcolor( cColNorm() )
                     go top
                     lLoo2 := .f.
                  case lastkey() == K_DOWN
                     //Vertoon reeds bestaande indeksgroepe
                     asize( aVelde, 0 )
                     aadd( aVelde, { "sm3indg", "kode" })
                     aadd( aVelde, { "sm3indg", "besk" })
                     cIndg := sm3indg( 4, 45, 20, aVelde, cIndg )
               endcase

            enddo

         endif

      endif

      //Herstel waardes
      h001  := space(12)
      h002  := space(12)
      d001  := ctod("  /  /  ")
      d002  := ctod("  /  /  ")
      cIndg := "      "
      lVraa := .f.

   enddo

   //Herstel
return NIL

