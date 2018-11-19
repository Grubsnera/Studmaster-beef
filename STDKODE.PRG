// Application: StudMaster for Beef Cattle
//   File Name: STDKODE.PRG
// Description: Program to ask user codes
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-26-94      07:04:14am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdkode(cSyst,nData)

   // Declare
   local getlist := {}
   local lRetu := .f.
   local aCdbf := fATopen()
   local cReek := ""
   local cCryp := "JNR"
   local nDryf := 0
   local nBoxc := 0
   local i     := 0
   local cData := ""
   local nReek := 0
   local nVolu := 0
   local dDatu := ctod("")
   local nGeek := 0
   local nOntk := 0
   local nTest := 0

   begin sequence

      // Values
      nData := if(nData==NIL,0,nData)
      cSyst := diskname()+":\"+cSyst+".sys"

      // Do not ask codes if

      // Albert or Sarel code
      if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
         lRetu := .t.
         break
      endif

      // Agricultural Data Control
      if upper(left(cGebNaam(), 25)) == "AGRICULTURAL DATA CONTROL"
         lRetu := .t.
         break
      endif

      // Tarragon Computing
      //if upper(left(cGebNaam(), 18)) == "TARRAGON COMPUTING"
      //   lRetu := .t.
      //   break
      //endif

      // Q Farm
      //if upper(left(cGebNaam(), 6)) == "Q FARM"
      //   lRetu := .t.
      //   break
      //endif

      // Q Data Consulting (Pty) Ltd
      //if upper(left(cGebNaam(), 27)) == "Q DATA CONSULTING (PTY) LTD"
      //   lRetu := .t.
      //   break
      //endif

      // Software Farm (Pty) Ltd
      //if upper(left(cGebNaam(), 23)) == "SOFTWARE FARM (PTY) LTD"
      //   lRetu := .t.
      //   break
      //endif

      // Software Farm (Edms) Bpk
      //if upper(left(cGebNaam(), 24)) == "SOFTWARE FARM (EDMS) BPK"
      //   lRetu := .t.
      //   break
      //endif

      // 1 December to 9 January
      if right(dtos(dAppDate()),4) >= "1201" .and. ;
            right(dtos(dAppDate()),4) <= "1231" .or.  ;
            right(dtos(dAppDate()),4) >= "0101" .and. ;
            right(dtos(dAppDate()),4) <= "0109"
         lRetu := .t.
         break
      endif

      // Serial numbers for Corrective Services
      if !empty(cReeNomm())
         if val(right(trim(cReeNomm()),4)) >= 390 .and. ;
               val(right(trim(cReeNomm()),4)) <= 399
            lRetu := .t.
            break
         endif
         // Taurus program in Ghana
         if val(right(trim(cReeNomm()),4)) == 460
            lRetu := .t.
            break
         endif
      endif

      // Do not ask codes in the Zambia and Uganda
      if substr(cTotNaam(),202,3) == "ZMB"
         lRetu := .t.
         break
      endif

      // Return code values
      // 1 == Nuwe installasie
      // 2 == Disk volume serial not the same as stored value in waard2
      // 3 == Value of system file not the same as value in waard2
      // 4 == System file does not exist
      // 5 == Appl time expired or > waard3 + waard4

      // Get the number of data drives
      aCdbf := fATopen(aCdbf,,"STDDRYF",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      pack
      nDryf := lastrec()
      fATclose(aCdbf)
      asize(aCdbf,len(aCdbf)-1)

      // Ask serial number if not exist
      do while empty(cReeNomm())

         // Screen
         fScrOpsk()
         fScrBood(maxrow()-1,"[Esc]=Dos")

         cReek := space(10)

         if cLanType() == "A"
            fScrBood(maxrow(),"Tik asseblief die reeksnommer soos voor in die handleiding!")
            nBoxc := fBoxCent(12,"Reeksnommer? 1234567890",3)
            @13,nBoxc say "Reeksnommer?" get cReek pict "@!"
         else
            fScrBood(maxrow(),"Please type the serial number found in the front of the manual!")
            nBoxc := fBoxCent(12,"Serial number? 1234567890",3)
            @13,nBoxc say "Serial number?" get cReek pict "@!"
         endif
         set cursor on
         read
         set cursor off
         if lastkey() == K_ESC
            break
         endif
         cReeNomm(cReek)
      enddo

      // Return if empty serial number
      if empty(cReeNomm())
         break
      endif

      // Get the numeric part of the serial number
      for i := 1 to len(cReeNomm())
         if isdigit(substr(cReeNomm(),i,1))
            cData += substr(cReeNomm(),i,1)
         endif
      next
      nReek := val(cData)
      if nReek <= 0
         nReek := 60
      endif

      // Open the serial number file
      aCdbf := fATopen(aCdbf,,"STDREEK",,"tdb",,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Save the serial number
      if crypt(STDREEK->waard1,cCryp) <> cReeNomm()
         STDREEK->waard1 := crypt(cReeNomm(),cCryp)
      endif

      // New installation if STDREEK.tdb is empty
      if empty(STDREEK->waard2) .or. ;
            empty(STDREEK->waard3) .or. ;
            empty(STDREEK->waard4)
         nData := 1
      endif

      // See if disk volume and WAARD2 is the same
      if nData == 0
         if file("stdkode.def")
            nVolu := 0
         else
            nVolu := volserial()
         endif
         if nVolu > 0
            // Disk volume exist and must be the same as WAARD2
            if val(crypt(STDREEK->waard2,cCryp)) <> nVolu
               nData := 2
            endif
         else
            // Disk volume does not exist - look at system file in root
            if len(trim(fileseek(cSyst,7,.t.))) > 0
               nVolu := val(filestr(cSyst,20,,.t.))
               if val(crypt(STDREEK->waard2,cCryp)) <> nVolu
                  nData := 3
               endif
            else
               nVolu := diskfree()
               nData := 4
            endif
         endif
      endif

      // If system date > WAARD3 (Date) + WAARD4 (Days)
      if nData == 0
         if len(trim(crypt(STDREEK->waard3,cCryp))) == 8 .and. len(trim(crypt(STDREEK->waard4,cCryp))) > 0
            set century on
            dDatu := ctod( right(crypt(STDREEK->waard3,cCryp),2) + "/" + substr(crypt(STDREEK->waard3,cCryp),5,2) + "/" + left(crypt(STDREEK->waard3,cCryp),4) )
            set century off
            if dAppDate() > dDatu + val(crypt(STDREEK->waard4,cCryp))*30
               nData := 5
            endif
         endif
      endif

      // If disk volume does not exist
      if nVolu <= 0
         // Get the volume
         if file("stdkode.def")
            nVolu := 0
         else
            nVolu := volserial()
         endif
         if nVolu <= 0
            nVolu := diskfree()
         endif
      endif

      // If code must be asked
      if nData > 0

         // Screen
         fScrOpsk()

         if cLanType() == "A"
            if val(crypt(STDREEK->waard5,cCryp)) <= 8
               nBoxc := fBoxCent(4,space(60),5,"NOTA")
               @ 4,nBoxc say "Skakel asseblief vir 'n nuwe gebruikerskode terwyl hierdie"
               @ 5,nBoxc say "skerm vertoon word. Indien dit buite normale kantoorure is"
               @ 6,nBoxc say "druk dan net [Enter] aangesien program nog  sal  loop  vir"
               @ 7,nBoxc say ltrim(str(9-val(crypt(STDREEK->waard5,cCryp))))+" maal sonder 'n gebruikerskode."
               @ 8,nBoxc say "Ons telefoonnommer is "+cOwnFone()
            else
               nBoxc := fBoxCent(4,space(60),3,"NOTA")
               @ 4,nBoxc say "Skakel asseblief vir 'n nuwe gebruikerskode terwyl hierdie"
               @ 5,nBoxc say "skerm vertoon word."
               @ 6,nBoxc say "Ons telefoonnommer is "+cOwnFone()
            endif
         else
            if val(crypt(STDREEK->waard5,cCryp)) <= 8
               nBoxc := fBoxCent(4,space(60),5,"NOTE")
               @ 4,nBoxc say "Please phone for a new usercode while this screen"
               @ 5,nBoxc say "is displayed. If it is outside normal office hours"
               @ 6,nBoxc say "then press [Enter] as the program will still work "
               @ 7,nBoxc say ltrim(str(9-val(crypt(STDREEK->waard5,cCryp))))+" times without a usercode."
               @ 8,nBoxc say "Our telephone number is "+cOwnFone()
            else
               nBoxc := fBoxCent(4,space(60),3,"NOTE")
               @ 4,nBoxc say "Please phone for a new usercode while "
               @ 5,nBoxc say "this screen is displayed."
               @ 6,nBoxc say "Our telephone number is "+cOwnFone()
            endif
         endif

         if crypt(STDREEK->waard5,cCryp) == "99"
         else
            STDREEK->waard5 := crypt(str(val(crypt(STDREEK->waard5,cCryp))+1,2,0),cCryp)
         endif

         if cLanType() == "A"
            nBoxc := fBoxCent(13,space(50),7,"Gebruikerskode")
            fScrBood(maxrow(),"Jammer vir die ongerief hierdeur veroorsaak.")
            fScrBood(maxrow()-1,"Tik die nuwe gebruikerskode asseblief.")
            @14,nBoxc say "         Reeksnommer"
            @16,nBoxc say "         Programkode"
            @18,nBoxc say "      Gebruikerskode"
         else
            nBoxc := fBoxCent(13,space(50),7,"Usercode")
            fScrBood(maxrow(),"We apologise for the inconvenience caused.")
            fScrBood(maxrow()-1,"Please type the new usercode.")
            @14,nBoxc say "       Serial number"
            @16,nBoxc say "        Program code"
            @18,nBoxc say "            Usercode"
         endif

         setcolor(cColInve())
         nGeek := int( nVolu / int(seconds()) ) + random()
         cData := ltrim(str(nData)) + padl(ltrim(str(nDryf)),2,"0") + ltrim(str(nGeek))
         @14,nBoxc+21 say cReeNomm()
         @16,nBoxc+21 say cData
         setcolor(cColNorm())
         nGeek := val(left(charmirr(cData),4))
         nGeek := int((nGeek*nReek)/val( left(cData,1)+substr(cData,3,1) ))

         // Ask the code
         @18,nBoxc+21 get nOntk pict "9999999999"
         set cursor on
         read
         set cursor off

         cData := ltrim(str(nOntk))
         if val(left(cData,len(cData)-2)) == nGeek

            // Code the same - save
            STDREEK->waard2 := crypt(padr(ltrim(str(nVolu)),20),cCryp)
            STDREEK->waard3 := crypt(dtos(dAppDate()),cCryp)
            STDREEK->waard4 := crypt(right(ltrim(str(nOntk)),2),cCryp)
            STDREEK->waard5 := crypt("0 ",cCryp)

            // Write the hidden system file in root
            if file("stdkode.def")
               nTest := 0
            else
               nTest := volserial()
            endif
            if nTest > 0
            else
               if len(trim(fileseek(cSyst,7,.t.))) <= 0
                  set console off
                  set device to printer
                  set printer to (cSyst)
                  @prow(),0 say ltrim(str(nVolu))
                  set printer to
                  set device to screen
                  set console on
               else
                  // Remove attributes
                  setfattr(cSyst,0)
                  set console off
                  set device to printer
                  set printer to (cSyst)
                  @prow(),0 say ltrim(str(nVolu))
                  set printer to
                  set device to screen
                  set console on
               endif

               // Change file date and times
               setfdati(cSyst,biosdate(),"12:00:00")

               // Add attributes
               setfattr(cSyst,7)

            endif

            lRetu := .t.

         else

            // Accept if less than 9 uses
            if nOntk == 0 .and. val(crypt(STDREEK->waard5,cCryp)) < 10
               lRetu := .t.
            endif

         endif

      else

         lRetu := .t.

      endif

   end

   // Reset
   fATclose(aCdbf)

   // Change file date and time stamps
   setfdati("STDREEK.tdb",filedate(exename()),filetime(exename()))

return lRetu
