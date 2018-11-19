//SM3KOEI.PRG
//Program om koeigemiddeldes te bereken
//Kopiereg (c) 1992 A van Rensburg
//11:45 02 Oct,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3koei(cIdnr)

   //Veranderlikes
   local cOdbf := fTOpen()
   local cData := ""
   local aBere := {}
   local cGesl := " "
   local nTell := 1
   local dGebd := ctod("")
   local aKoei := {}
   local i     := 0
   local nCarr := 0
   local nCalf := 1
   local nData := 0
   local nCalc := 0

   private cFunc := ""

   //Waardes
   if cIdnr == NIL
      return NIL
   endif

   //Ken waardes toe
   //Koei
   aadd(aKoei,{ctod("") , 21})                   // 1 Laaste kalfdatum
   aadd(aKoei,{0        , 22})                   // 2 Aantal kalwers
   aadd(aKoei,{0        ,122})                   // 3 Aantal embrio kalwers
   aadd(aKoei,{0        , 26})                   // 4 Gemiddelde kalfinterval
   aadd(aKoei,{0        , 27})                   // 5 Speenindeks aantal
   aadd(aKoei,{0        , 28})                   // 6 Gemiddelde speenindeks
   aadd(aKoei,{0        , 29})                   // 7 Ouderdom eerste kalf
   aadd(aKoei,{space(12),106})                   // 8 Laaste kalf id nommer
   aadd(aKoei,{0        ,107})                   // 9 Gemiddelde voorspeenindeks
   aadd(aKoei,{0        ,108})                   //10 Gemiddelde jaarindeks
   aadd(aKoei,{0        ,109})                   //11 Gemiddelde 18 maande indeks
   aadd(aKoei,{0        ,110})                   //12 Speenpersentasie
   aadd(aKoei,{0        ,116})                   //13 Retensiepersentasie
   aadd(aKoei,{0        ,123})                   //14 Simdeks
   aadd(aKoei,{0        ,111})                   //15 Gemiddelde gdt indeks
   aadd(aKoei,{0        , 30})                   //16 Mees waarskynlike produksievermo‰
   aadd(aKoei,{0        , 31})                   //17 Produksie per produktiewe jaar
   aadd(aKoei,{0        , 33})                   //18 Gemiddelde doeltreffendheidsindeks
   aadd(aKoei,{0        , 34})                   //19 Gemiddelde geboortemassa verhouding
   aadd(aKoei,{0        , 35})                   //20 Goedkeur persentasie
   aadd(aKoei,{0        ,124})                   //21 Gemiddelde geboortemassa
   aadd(aKoei,{0        ,125})                   //22 Aantal kalwings
   aadd(aKoei,{0        ,144})                   //23 Ouderdom laaste kalf
   aadd(aKoei,{0        ,145})                   //24 Gemiddelde speenmassa verhouding
   aadd(aKoei,{0        ,146})                   //25 Gemiddelde gdo indeks
   aadd(aKoei,{0        ,156})                   //26 Dae laas gekalf
   aadd(aKoei,{0        ,183})                   //27 Gemiddelde Dragtigheids periode
   aadd(aKoei,{0        ,198})                   //28 Gemiddelde kalf tot speen indeks
   aadd(aKoei,{0        ,199})                   //29 Gemiddelde speen tot speen indeks
   aadd(aKoei,{0        ,200})                   //30 Gemiddelde vov indeks
   aadd(aKoei,{0        ,218})                   //31 Reproduksie-indeks

   //Berekeninge
   aadd(aBere,ctod(""))                          // 1 Eerste kalfdatum
   aadd(aBere,ctod(""))                          // 2 Laaste kalfdatum
   aadd(aBere,0)                                 // 3 Aantal kalwers
   aadd(aBere,0)                                 // 4 Aantal embrio kalwers
   aadd(aBere,space(12))                         // 5 Laaste kalfnommer
   aadd(aBere,0)                                 // 6 Speenaantal
   aadd(aBere,0)                                 // 7 Totale speenindekse
   aadd(aBere,0)                                 // 8 Voorspeenaantal
   aadd(aBere,0)                                 // 9 Totale voorspeen
   aadd(aBere,0)                                 //10 Jaaraantal
   aadd(aBere,0)                                 //11 Jaartotaal
   aadd(aBere,0)                                 //12 18 maande aantal
   aadd(aBere,0)                                 //13 18 maande totaal
   aadd(aBere,0)                                 //14 Retensie aantal
   aadd(aBere,0)                                 //15 Aantal kalwings
   aadd(aBere,0)                                 //16 Aantal doeltreffendheid indeks aantal
   aadd(aBere,0)                                 //17 Totale doeltreffendheidsindeks
   aadd(aBere,0)                                 //18 Aantal geboortemassaverhouding
   aadd(aBere,0)                                 //19 Totale geboortemassaverhouding
   aadd(aBere,0)                                 //20 Aantal diere gekeur
   aadd(aBere,0)                                 //21 Totale diere goedgekeur
   aadd(aBere,0)                                 //22 Aantal geboortemassas
   aadd(aBere,0)                                 //23 Totale geboortemassa
   aadd(aBere,0)                                 //24 Totale gekorrigeerde speenmassa
   aadd(aBere,0)                                 //25 gdo aantal
   aadd(aBere,0)                                 //26 gdo totaal
   aadd(aBere,0)                                 //27 gdt aantal
   aadd(aBere,0)                                 //28 gdt totaal
   aadd(aBere,0)                                 //29 Aantal vroulike nageslag
   aadd(aBere,0)                                 //30 Aantal speenmassaverhouding
   aadd(aBere,0)                                 //31 Totale speenmasseverhouding
   aadd(aBere,0)                                 //32 Aantal dragtigheids periode
   aadd(aBere,0)                                 //33 Totale dragtigheids periodespeenmasseverhouding
   aadd(aBere,0)                                 //34 Aantal kalf tot speen
   aadd(aBere,0)                                 //35 Totaal kalf tot speen
   aadd(aBere,0)                                 //36 Aantal speen tot speen
   aadd(aBere,0)                                 //37 Totaal speen tot speen
   aadd(aBere,0)                                 //38 Aantal vir gem vov
   aadd(aBere,0)                                 //39 Totaal vir gem vov

   //Open .dbf
   //cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   //if left(cData,1)=="f"
   //   fTClose(cOdbf)
   //   return NIL
   //endif

   //Kyk of dier bestaan
   seek cIdnr
   if eof()
      //Herstel
      //fTClose(cData)
      fTClose(cOdbf)
      return NIL
   else
      cGesl := SM3DATA->geslag
      dGebd := SM3DATA->gebdatum
      if cGesl $ "12"

         // Doen enkele berekeninge van die dier self

         // Lock the record
         do while !rlock()
         enddo

         //Geboortemassaverhouding bereken
         if SM3DATA->gebmassa > 0 .and. SM3DATA->mamoergeb > 0
            nCarr := round((SM3DATA->gebmassa/SM3DATA->mamoergeb)*100,1)
            if nCarr >= 0 .and. nCarr <= 99.9
               SM3DATA->gebmasv := nCarr
            else
               SM3DATA->gebmasv := 0
            endif
         else
            SM3DATA->gebmasv := 0
         endif

         //Speenmassaverhouding bereken
         if SM3DATA->gma205 > 0 .and. SM3DATA->mamoerspe > 0
            nCarr := round((SM3DATA->gma205/SM3DATA->mamoerspe)*100,1)
            if nCarr >= 0 .and. nCarr <= 99.9
               SM3DATA->spnmasvhd := nCarr
            else
               SM3DATA->spnmasvhd := 0
            endif
         else
            SM3DATA->spnmasvhd := 0
         endif

         dbunlock()

      else
         //Herstel
         //fTClose(cData)
         fTClose(cOdbf)
         return NIL
      endif
   endif

   //Stel indeks
   if cGesl == "1"
      set order to 4
      cFunc := "SM3DATA->idmoer=='"+cIdnr+"'"
   else
      set order to 5
      cFunc := "SM3DATA->idvaar=='"+cIdnr+"'"
   endif

   //Kyk of dier kalwers het
   seek cIdnr
   if eof()
      //Dier het geen nageslag
      //Kry oorspronklike dier
      set order to 1
      seek cIdnr
      if !eof()
         //Maak alle nageslag syfers skoon
         do while !rlock()
         enddo
         for i = 1 to len(aKoei)
            fieldput(aKoei[i,2],aKoei[i,1])
         next
      endif
   endif

   //Bereken syfers
   do while &cFunc

      //Record lock
      do while ! rlock()
      enddo

      //Skerm
      setcolor(cColBott())
      if cGesl == "1"
         @23,30 say trim(SM3DATA->idmoer) + " - " + SM3DATA->idnr + space(12)
      else
         @23,30 say trim(SM3DATA->idvaar) + " - " + SM3DATA->idnr + space(12)
      endif
      setcolor(cColNorm())

      //Indien embrio kalf
      if SM3DATA->vaarkode == "4"
         if cGesl == "1"
            if SM3DATA->idmoer == SM3DATA->draer
               aBere[4]++
            else
               aBere[4]++
               SM3DATA->kalfinterv := 0
               skip
               loop
            endif
         else
            aBere[4]++
         endif
      endif

      // If not embrio calf - calculate the umpteenth calf
      if SM3DATA->vaarkode <> "4"
         if cGesl == "1"
            if nCalf < 99
               SM3DATA->kalfno := nCalf
            else
               SM3DATA->kalfno := 99
            endif
            nCalf++
         endif
      endif

      // If not embrio calf - calculate the age of the mother in months
      if SM3DATA->vaarkode <> "4"
         if cGesl == "1" .and. !empty(dGebd) .and. !empty(SM3DATA->gebdatum)
            if SM3DATA->gebdatum > dGebd
               nData := int((SM3DATA->gebdatum - dGebd) / 30.4166)
               if nData > 0 .and. nData <= 999
                  SM3DATA->moerou := nData
               endif
            endif
         endif
      endif

      //Aantal kalwers
      aBere[3]++

      //Aantal kalwings
      if cGesl == "1"
         //Slegs vroulik
         if aBere[2] == SM3DATA->gebdatum
         else
            aBere[15]++
         endif
      endif

      //Kalfinterval
      if cGesl == "1"

         //Slegs vroulik
         if aBere[3] = 1
            SM3DATA->kalfinterv := 0
         else
            if aBere[2] <= SM3DATA->gebdatum        .and. ;
                  SM3DATA->gebdatum - aBere[2] >= 0    .and. ;
                  SM3DATA->gebdatum - aBere[2] <= 9999
               SM3DATA->kalfinterv := SM3DATA->gebdatum - aBere[2]
            endif
         endif
      endif

      //Eerste kalfdatum
      if aBere[1] == ctod("")
         aBere[1] := SM3DATA->gebdatum
      endif

      //Laaste kalfdatum
      aBere[2] := SM3DATA->gebdatum

      //Laaste kalf
      aBere[5] := SM3DATA->idnr

      //Voorspeenindeks
      if SM3DATA->ind100 > 0
         aBere[8]++
         aBere[9] += SM3DATA->ind100
      endif

      //Speenindeks
      if SM3DATA->ind205 > 0
         aBere[6]++
         aBere[7] += SM3DATA->ind205
      endif

      //Jaarindeks
      if SM3DATA->ind365 > 0
         aBere[10]++
         aBere[11] += SM3DATA->ind365
      endif

      //18 Maande indeks
      if SM3DATA->ind540 > 0
         aBere[12]++
         aBere[13] += SM3DATA->ind540
      endif

      //Gdo indeks
      if SM3DATA->gdoind > 0
         aBere[25]++
         aBere[26] += SM3DATA->gdoind
      endif

      //Gdt indeks
      if SM3DATA->gdtind > 0
         aBere[27]++
         aBere[28] += SM3DATA->gdtind
      endif

      //Vov indeks
      if SM3DATA->voeromseti > 0
         aBere[38]++
         aBere[39] += SM3DATA->voeromseti
      endif

      //Retensie aantal
      if SM3DATA->geslag == "1"
         aBere[29]++
         if SM3DATA->uitkrede $ cWaarisd()
            aBere[14]++
         endif
      endif

      //Doeltreffendheidsindeks
      if SM3DATA->mpresind > 0
         aBere[16]++
         aBere[17] += SM3DATA->mpresind
      endif

      // Kalf tot speen doeltreffendheidsindeks
      if SM3DATA->klfspnind > 0
         aBere[34]++
         aBere[35] += SM3DATA->klfspnind
      endif

      // Speen tot speen doeltreffendheidsindeks
      if SM3DATA->spnspnind > 0
         aBere[36]++
         aBere[37] += SM3DATA->spnspnind
      endif

      //Geboortemassaverhouding bereken
      if SM3DATA->gebmassa > 0 .and. SM3DATA->mamoergeb > 0
         nCarr := round((SM3DATA->gebmassa/SM3DATA->mamoergeb)*100,1)
         if nCarr >= 0 .and. nCarr <= 99.9
            SM3DATA->gebmasv := nCarr
         endif
      endif

      //Geboortemassaverhouding
      if SM3DATA->gebmasv > 0
         aBere[18]++
         aBere[19] += SM3DATA->gebmasv
      endif

      //Speenmassaverhouding bereken
      if SM3DATA->gma205 > 0 .and. SM3DATA->mamoerspe > 0
         nCarr := round((SM3DATA->gma205/SM3DATA->mamoerspe)*100,1)
         if nCarr >= 0 .and. nCarr <= 99.9
            SM3DATA->spnmasvhd := nCarr
         endif
      endif

      //Goedkeurpersentasie
      if SM3DATA->gekeur <> " "
         aBere[20]++
         if SM3DATA->gekeur $ "JY"
            aBere[21]++
         endif
      endif

      //Geboortemassa
      if SM3DATA->gebmassa > 0
         aBere[22]++
         aBere[23] += SM3DATA->gebmassa
      endif

      //Gekorrigeerde speenmassa
      if SM3DATA->geslag == "1"
         aBere[24] += round(SM3DATA->gma205*1.07,0)
      elseif SM3DATA->geslag == "3"
         aBere[24] += round(SM3DATA->gma205*1.04,0)
      else
         aBere[24] += SM3DATA->gma205
      endif

      //Speenmassaverhouding bereken
      if SM3DATA->gma205 > 0 .and. SM3DATA->mamoerspe > 0
         nCarr := round((SM3DATA->gma205/SM3DATA->mamoerspe)*100,1)
         if nCarr >= 0 .and. nCarr <= 99.9
            SM3DATA->spnmasvhd := nCarr
         endif
      endif

      //Geboortemassaverhouding
      if SM3DATA->spnmasvhd > 0
         aBere[30]++
         aBere[31] += SM3DATA->spnmasvhd
      endif

      //Dragtigheids periode
      if SM3DATA->gestation > 0
         aBere[32]++
         aBere[33] += SM3DATA->gestation
      endif

      //Volgende kalf
      select SM3DATA
      skip

   enddo

   //Bereken syfers

   //Laaste kalfdatum
   aKoei[1,1] := aBere[2]

   // Days since last calving
   if cGesl == "1"
      if !empty(aBere[2])
         if dAppDate() - aBere[2] > 0 .and. dAppDate() - aBere[2] <= 9999
            aKoei[26,1] := dAppDate() - aBere[2]
         endif
      endif
   endif

   //Aantal kalwers
   if aBere[3] >= 0 .and. aBere[3] <= 999
      aKoei[2,1] := aBere[3]
   endif

   //Aantal inov kalwers
   if aBere[4] >= 0 .and. aBere[4] <= 999
      aKoei[3,1] := aBere[4]
   endif

   //Gemiddelde kalfinterval
   if cGesl == "1"
      //Slegs vroulik
      if aBere[2] - aBere[1] > 0 .and. aBere[15] > 1
         nCarr := round( (aBere[2]-aBere[1]) / (aBere[15]-1) ,0)
         if nCarr >= 0 .and. nCarr <= 9999
            aKoei[4,1] := nCarr
         endif
      endif
   else
      aKoei[4,1] := 0
   endif

   //Speenindeks aantal
   if aBere[6] >= 0 .and. aBere[6] <= 999
      aKoei[5,1] := aBere[6]
   endif

   //Gemiddelde speenindeks
   if aBere[6] > 0
      nCarr := round(aBere[7]/aBere[6],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[6,1] := nCarr
      endif
   endif

   //Ouderdom eerste kalf
   nCarr := aBere[1]-dGebd
   nCarr := round(nCarr/30.4375,0)
   if nCarr >= 0 .and. nCarr <= 99
      aKoei[7,1] := nCarr
   endif

   //Ouderdom laaste kalf
   nCarr := aBere[2]-dGebd
   if file("BEEFM.SET")
      nCarr := round(nCarr/365.25,0)
   else
      nCarr := round(nCarr/30.4375,0)
   endif
   if nCarr >= 0 .and. nCarr <= 999
      aKoei[23,1] := nCarr
   endif

   //Laaste kalf
   aKoei[8,1] := aBere[5]

   //Gemiddelde voorspeenindeks
   if aBere[8] > 0
      nCarr := round(aBere[9]/aBere[8],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[9,1] := nCarr
      endif
   endif

   //Gemiddelde jaarindeks
   if aBere[10] > 0
      nCarr := round(aBere[11]/aBere[10],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[10,1] := nCarr
      endif
   endif

   //Gemiddelde 18 maande-indeks
   if aBere[12] > 0
      nCarr := round(aBere[13]/aBere[12],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[11,1] := nCarr
      endif
   endif

   //Gemiddelde gdo indeks
   if aBere[25] > 0
      nCarr := round(aBere[26]/aBere[25],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[25,1] := nCarr
      endif
   endif

   //Gemiddelde gdt indeks
   if aBere[27] > 0
      nCarr := round(aBere[28]/aBere[27],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[15,1] := nCarr
      endif
   endif

   //Gemiddelde vov indeks
   if aBere[38] > 0
      nCarr := round(aBere[39]/aBere[38],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[30,1] := nCarr
      endif
   endif

   //Speenpersentasie
   if aBere[3] > 0
      nCarr := round((aBere[6]/aBere[3])*100,0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[12,1] := nCarr
      endif
   endif

   //Retensiepersentasie
   if aBere[3] >= 0
      nCarr := round((aBere[14]/aBere[29])*100,0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[13,1] := nCarr
      endif
   endif

   //Simdeks
   if cGesl == "1"
      //Slegs vroulik
      //nCarr := ((aBere[3]-1)*365)+822
      if substr( cTotNaam(), 149, 3 ) == "217"
         nCarr := ((aBere[15]-1)*365)+1004       // Massmann 00-08-13 15:49
      else
         nCarr := ((aBere[15]-1)*365)+913        // Massmann 00-08-13 15:49
      endif
      if nCarr > 0
         if aBere[2] - dGebd > 0
            nCarr := ((aBere[2]-dGebd)/nCarr)*100
            nCarr := round(200-nCarr,0)
            if nCarr >= 0 .and. nCarr <= 999
               aKoei[14,1] := nCarr
            endif
         endif
      endif
   else
      aKoei[14,1] := 0
   endif

   //Mees waarskynlike produksievermoe
   if cGesl == "1"
      //Slegs vroulik
      nCarr := 1 + ((aBere[6]-1)*.4)
      if nCarr > 0
         nCarr := aBere[6]*.4 / nCarr
         nCarr := nCarr * (aKoei[6,1]-100)
         nCarr := 100 + nCarr
         if nCarr >= 0 .and. nCarr <= 999
            aKoei[16,1] := nCarr
         endif
      endif
   else
      aKoei[16,1] := 0
   endif

   //Produksie per produktiewe jaar
   if alltrim(cIdnr) == "07-0026J"
      altd()
   endif
   if cGesl == "1"
      // Slegs vroulik
      nCarr := round((aBere[2]-dGebd)/30.4375,0)-24
      if nCarr > 0
         nCalc := round((aBere[24]/nCarr)*12,0)
         if nCalc >= 0 .and. nCalc <= 999
            aKoei[17,1] := nCalc
         endif
      endif
   else
      aKoei[17,1] := 0
   endif

   //Gemiddelde doeltreffendheidindeks
   if aBere[16] > 0
      nCarr := round(aBere[17]/aBere[16],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[18,1] := nCarr
      endif
   endif

   // Gemiddelde kalf tot speen doeltreffendheidindeks
   if aBere[34] > 0
      nCarr := round(aBere[35]/aBere[34],0)
      if nCarr >= 0 .and. nCarr <= 9999
         aKoei[28,1] := nCarr
      endif
   endif

   // Gemiddelde speen tot speen doeltreffendheidindeks
   if aBere[36] > 0
      nCarr := round(aBere[37]/aBere[36],0)
      if nCarr >= 0 .and. nCarr <= 9999
         aKoei[29,1] := nCarr
      endif
   endif

   //Gemiddelde geboortemassaverhouding
   if aBere[18] > 0
      nCarr := round(aBere[19]/aBere[18],1)
      if nCarr >= 0 .and. nCarr <= 99.9
         aKoei[19,1] := nCarr
      endif
   endif

   //Gemiddelde speenmassaverhouding
   if aBere[30] > 0
      nCarr := round(aBere[31]/aBere[30],1)
      if nCarr >= 0 .and. nCarr <= 99.9
         aKoei[24,1] := nCarr
      endif
   endif

   //Goedkeurpersentasie
   if aBere[20] > 0
      nCarr := round((aBere[21]/aBere[20])*100,0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[20,1] := nCarr
      endif
   endif

   //Gemiddelde geboortemassa
   if aBere[22] > 0
      nCarr := round(aBere[23]/aBere[22],0)
      if nCarr >= 0 .and. nCarr <= 99
         aKoei[21,1] := nCarr
      endif
   endif

   //Kalwings
   if cGesl == "1"
      //Slegs vroulik
      if aBere[15] >= 0 .and. aBere[15] <= 99
         aKoei[22,1] := aBere[15]
      endif
   else
      aKoei[22,1] := 0
   endif

   //Dragtigheids periode
   if cGesl == "1" .and. aBere[32] > 0           //Slegs vroulik
      nCarr := round(aBere[33]/aBere[32],0)
      if nCarr >= 0 .and. nCarr <= 999
         aKoei[27,1] := nCarr
      endif
   endif

   // Reproduksie-indeks
   // Change over from months to days
   // From Peter Beith 03-02-13 16:20 (36->33 en 365->435)
   if cGesl == "1"
      if aBere[15] > 0 .and. aKoei[23,1] > 0
         nData := 1003 + ((aBere[15] - 1) * 435 )
         if nData > 0
            aKoei[31,1] := 200 - (((aKoei[23,1])*30.4167/nData)*100)
            if aKoei[31,1] > 0 .and. aKoei[31,1] <= 999
            else
               aKoei[31,1] := 0
            endif
         endif
      endif
   else
      aKoei[31,1] := 0
   endif

   // Reproduksie-indeks vervang met bg op 03-02-13 16:05
   //if cGesl == "1"
   //   if aBere[15] > 0 .and. aKoei[23,1] > 0
   //      nData := 36 + ((aBere[15] - 1) * 12 )
   //      if nData > 0
   //         aKoei[31,1] := 200 - ((aKoei[23,1]/nData)*100)
   //         if aKoei[31,1] > 0 .and. aKoei[31,1] <= 999
   //         else
   //            aKoei[31,1] := 0
   //         endif
   //      endif
   //   endif
   //else
   //   aKoei[31,1] := 0
   //endif


   //if cGesl == "1"
   //   //Slegs vroulik
   //   nCarr := ((aBere[15]-1)*365)+1096          // Hennie Snyman 02-06-19 11:25
   //   if nCarr > 0
   //      if aBere[2] - dGebd > 0
   //         nCarr := ((aBere[2]-dGebd)/nCarr)*100
   //         nCarr := round(200-nCarr,0)
   //         if nCarr >= 0 .and. nCarr <= 999
   //            aKoei[31,1] := nCarr
   //         endif
   //      endif
   //   endif
   //else
   //   aKoei[31,1] := 0
   //endif





   //Stoor dier se syfers
   set order to 1
   seek cIdnr
   if !eof()
      //Maak alle nageslag syfers skoon
      do while !rlock()
      enddo
      for i = 1 to len(aKoei)
         fieldput(aKoei[i,2],aKoei[i,1])
      next
   endif

   //Herstel
   //fTClose(cData)
   fTClose(cOdbf)
return NIL
