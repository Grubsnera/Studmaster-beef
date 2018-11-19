//SM3BEGE.PRG
//Program om begeleidingsbrief te druk
//Kopiereg (c) 1992 A van Rensburg
//14:08 29 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//****************************************************************************/
FUNCTION sm3bege

   //Veranderlikes
   local getlist := {}
   local cCscr := savescreen(0,0,24,79)
   local aDoku := {}
   local aNota := {}
   local dVore := ctod("")
   local i     := 0
   local nBoxc := 0
   local nCopy := 1
   local cRasn := ""
   local cOpsk := ""

	// Skerm
    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   //Waardes
   for i = 1 to 8
      aadd(aDoku,space(10))
   next
   for i = 1 to 12
      aadd(aNota,space(60))
   next

   //Toets of drukker reg is
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Kry die rasnaam
   cOpsk := fRasNaam(substr(cTotNaam(),149,3),"HEADCL")
   if empty(cOpsk)
      cRasn := fRasNaam(substr(cTotNaam(),149,3))
      if cLanType() == "A"
         cOpsk := "Die "+cRasn+" Beestelersgenootskap van S.A."
      else
         cOpsk := "The "+cRasn+" Cattle Breeders Society of S.A."
      endif
   endif

   //Aantal afskrifte
   nCopy := 1 //fCopies() 07-05-28 12:15
   if nCopy < 1
      return NIL
   endif

	// Skerm
    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   //Box
   if cLanType() == "A"
      nBoxc := fBoxCent(8,space(42),9,"Geboortekennisgewings")
      fScrBood(23,"[Esc]=Menu")
      fScrBood(24,"Tik die geboortekennisgewing reeks om te versend!")
      @ 9,nBoxc    say "1. Nommer " get aDoku[1] pict "@!"
      @ 9,nBoxc+22 say "   tot    " get aDoku[2] pict "@!"
      @11,nBoxc    say "2. Nommer " get aDoku[3] pict "@!"
      @11,nBoxc+22 say "   tot    " get aDoku[4] pict "@!"
      @13,nBoxc    say "3. Nommer " get aDoku[5] pict "@!"
      @13,nBoxc+22 say "   tot    " get aDoku[6] pict "@!"
      @15,nBoxc    say "4. Nommer " get aDoku[7] pict "@!"
      @15,nBoxc+22 say "   tot    " get aDoku[8] pict "@!"
   else
      nBoxc := fBoxCent(8,space(42),9,"Birth Notifications")
      fScrBood(23,"[Esc]=Menu")
      fScrBood(24,"Type the birth notification series to be posted!")
      @ 9,nBoxc    say "1. Number " get aDoku[1] pict "@!"
      @ 9,nBoxc+22 say "   to     " get aDoku[2] pict "@!"
      @11,nBoxc    say "2. Number " get aDoku[3] pict "@!"
      @11,nBoxc+22 say "   to     " get aDoku[4] pict "@!"
      @13,nBoxc    say "3. Number " get aDoku[5] pict "@!"
      @13,nBoxc+22 say "   to     " get aDoku[6] pict "@!"
      @15,nBoxc    say "4. Number " get aDoku[7] pict "@!"
      @15,nBoxc+22 say "   to     " get aDoku[8] pict "@!"
   endif
   set cursor on
   read
   set cursor off

   //If escaped
   if lastkey() == K_ESC
      return NIL
   endif

	// Skerm
    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   //Box
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(40),3,"Vorm E (Skrappingslys)")
      fScrBood(23,"[Esc]=Menu")
      fScrBood(24,"Tik die Vorm E (Skrappingslys) wat versend word se datum!")
      @12,nBoxc    say "Vorm E (Skrappingslys) gedateer" get dVore
   else
      nBoxc := fBoxCent(11,space(40),3,"Form E (Culling list)")
      fScrBood(23,"[Esc]=Menu")
      fScrBood(24,"Type the Form E (Culling list) date to be posted!")
      @12,nBoxc    say "Form E (Culling list) dated" get dVore
   endif
   set cursor on
   read
   set cursor off

   //If escaped
   if lastkey() == K_ESC
      return NIL
   endif

	// Skerm
    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   //Box
   if cLanType() == "A"
      nBoxc := fBoxCent(6,space(60),14,"NOTA AAN GENOOTSKAP")
      fScrBood(23,"[Esc]=Menu")
      fScrBood(24,"Tik enige nota aan die Genootskap indien verlang!")
   else
      nBoxc := fBoxCent(6,space(60),14,"NOTE TO SOCIETY")
      fScrBood(23,"[Esc]=Menu")
      fScrBood(24,"Type a note to the Society, if required!")
   endif
   @ 7,nBoxc get aNota[ 1]
   @ 8,nBoxc get aNota[ 2]
   @ 9,nBoxc get aNota[ 3]
   @10,nBoxc get aNota[ 4]
   @11,nBoxc get aNota[ 5]
   @12,nBoxc get aNota[ 6]
   @13,nBoxc get aNota[ 7]
   @14,nBoxc get aNota[ 8]
   @15,nBoxc get aNota[ 9]
   @16,nBoxc get aNota[10]
   @17,nBoxc get aNota[11]
   @18,nBoxc get aNota[12]
   set cursor on
   read
   set cursor off

   //If escaped
   if lastkey() == K_ESC
      return NIL
   endif

   //Oorspronklike skerm
   restscreen(0,0,24,79,cCscr)
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Begeleidingsbrief word gedruk")
   else
      fScrWbood(24,"Covering letter being printed")
   endif

   //Verander data
   for i = 1 to len(aDoku)
      aDoku[i] := padr(aDoku[i],30)
      if aDoku[i] == space(30)
         aDoku[i] := repl("_",30)
      endif
   next

   for i = 1 to nCopy

      //1e blad

      //Skakel die drukker aan
      fPrnOn()
      fPrnCod( cPrnNorm() )

      if cLanType() == "A"
         @prow()+nPrnLine(), 21 say upper(cOpsk)
         @prow()+1, 31 say "BEGELEIDINGSBRIEF"
         @prow()+1,  1 say repl("=",79)

         @prow()+2,  1 say cGebNaam()

         @prow()  , 50 say "               Datum: " + dtoc( dAppDate() )

         @prow()+1,  1 say substr(cTotNaam(),  1,40)
         @prow()+1,  1 say substr(cTotNaam(), 41,40)
         @prow()+1,  1 say substr(cTotNaam(), 81,40)
         @prow()+1,  1 say substr(cTotNaam(),121, 4)
         @prow()+2,  1 say repl("=",79)

         @prow()+2,  1 say "Hiermee ingesluit vind asseblief Geboortekennisgewing vorms:-"

         @prow()+2,  1 say "Nommer " + aDoku[1] + " tot " + aDoku[2]
         @prow()+2,  1 say "Nommer " + aDoku[3] + " tot " + aDoku[4]
         @prow()+2,  1 say "Nommer " + aDoku[5] + " tot " + aDoku[6]
         @prow()+2,  1 say "Nommer " + aDoku[7] + " tot " + aDoku[8]

         @prow()+2,  1 say "Hiermee ingesluit vind asseblief Vorm E (Skrappingslys) gedateer:-"

         @prow()+2,  1 say dVore

         @prow()+2,  1 say "Nota:-"

         @prow()+2,  1 say aNota[ 1]
         @prow()+2,  1 say aNota[ 2]
         @prow()+2,  1 say aNota[ 3]
         @prow()+2,  1 say aNota[ 4]
         @prow()+2,  1 say aNota[ 5]
         @prow()+2,  1 say aNota[ 6]
         @prow()+2,  1 say aNota[ 7]
         @prow()+2,  1 say aNota[ 8]
         @prow()+2,  1 say aNota[ 9]
         @prow()+2,  1 say aNota[10]
         @prow()+2,  1 say aNota[11]
         @prow()+2,  1 say aNota[12]

         @prow()+4,  1 say "_______________________________"
         @prow()+1,  1 say "Handtekening"

         @prow()+2,  1 say cAppName()

      else
         @prow()+nPrnLine(), 21 say upper(cOpsk)
         @prow()+1, 31 say "COVERING LETTER"
         @prow()+1,  1 say repl("=",79)

         @prow()+2,  1 say cGebNaam()

         @prow()  , 50 say "               Date: " + dtoc( dAppDate() )

         @prow()+1,  1 say substr(cTotNaam(),  1,40)
         @prow()+1,  1 say substr(cTotNaam(), 41,40)
         @prow()+1,  1 say substr(cTotNaam(), 81,40)
         @prow()+1,  1 say substr(cTotNaam(),121, 4)
         @prow()+2,  1 say repl("=",79)

         @prow()+2,  1 say "Enclosed herewith find Birth Notification forms:-"

         @prow()+2,  1 say "Number " + aDoku[1] + " to  " + aDoku[2]
         @prow()+2,  1 say "Number " + aDoku[3] + " to  " + aDoku[4]
         @prow()+2,  1 say "Number " + aDoku[5] + " to  " + aDoku[6]
         @prow()+2,  1 say "Number " + aDoku[7] + " to  " + aDoku[8]

         @prow()+2,  1 say "Enclosed herewith find Form E (Culling list) dated:-"

         @prow()+2,  1 say dVore

         @prow()+2,  1 say "Note:-"

         @prow()+2,  1 say aNota[ 1]
         @prow()+2,  1 say aNota[ 2]
         @prow()+2,  1 say aNota[ 3]
         @prow()+2,  1 say aNota[ 4]
         @prow()+2,  1 say aNota[ 5]
         @prow()+2,  1 say aNota[ 6]
         @prow()+2,  1 say aNota[ 7]
         @prow()+2,  1 say aNota[ 8]
         @prow()+2,  1 say aNota[ 9]
         @prow()+2,  1 say aNota[10]
         @prow()+2,  1 say aNota[11]
         @prow()+2,  1 say aNota[12]

         @prow()+4,  1 say "_______________________________"
         @prow()+1,  1 say "Signature"

         @prow()+2,  1 say cAppName()

      endif

      fPrnEjec()
      fPrnOff()

      //2e blad

      //Skakel die drukker aan
      if i == 1
         fPrnOn()
         fPrnCod( cPrnNorm() )

         if cLanType() == "A"
            @prow()+nPrnLine(), 21 say upper(cOpsk)
            @prow()+1, 31 say "BEGELEIDINGSBRIEF ANTWOORD"
            @prow()+1,  1 say repl("=",79)

            @prow()+2,  1 say cGebNaam()
            @prow()  , 50 say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,  1 say substr(cTotNaam(),  1,40)
            @prow()+1,  1 say substr(cTotNaam(), 41,40)
            @prow()+1,  1 say substr(cTotNaam(), 81,40)
            @prow()+1,  1 say substr(cTotNaam(),121, 4)
            @prow()  , 50 say "Datum ontvang ________" + "________"
            @prow()+2,  1 say repl("=",79)

            @prow()+2,  1 say "Ons erken ontvangs van Geboortekennisgewing vorms soos volg:-"

            @prow()+2,  1 say "Nommer " + repl("_",30) + " tot " + repl("_",30)
            @prow()+2,  1 say "Nommer " + repl("_",30) + " tot " + repl("_",30)
            @prow()+2,  1 say "Nommer " + repl("_",30) + " tot " + repl("_",30)
            @prow()+2,  1 say "Nommer " + repl("_",30) + " tot " + repl("_",30)

            @prow()+2,  1 say "Ons erken ontvangs van Vorm E (Skrappingslys) gedateer:-"

            @prow()+2,  1 say repl("_",30)

            @prow()+3,  1 say "Die volgende word teruggestuur vir korreksie:-"

            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)

            @prow()+5,  1 say "_______________________________            ____________________"
            @prow()+1,  1 say "Handtekening                               Datum"

            @prow()+2,  1 say cAppName()

         else
            @prow()+nPrnLine(), 21 say upper(cOpsk)
            @prow()+1, 31 say "COVERING LETTER ACKNOWLEDGEMENT"
            @prow()+1,  1 say repl("=",79)

            @prow()+2,  1 say cGebNaam()
            @prow()  , 50 say "               Date: " + dtoc( dAppDate() )
            @prow()+1,  1 say substr(cTotNaam(),  1,40)
            @prow()+1,  1 say substr(cTotNaam(), 41,40)
            @prow()+1,  1 say substr(cTotNaam(), 81,40)
            @prow()+1,  1 say substr(cTotNaam(),121, 4)
            @prow()  , 50 say "Date received ________" + "________"
            @prow()+2,  1 say repl("=",79)

            @prow()+2,  1 say "We acknowledge receipt of Birth notification forms as follows:-"

            @prow()+2,  1 say "Number " + repl("_",30) + " to  " + repl("_",30)
            @prow()+2,  1 say "Number " + repl("_",30) + " to  " + repl("_",30)
            @prow()+2,  1 say "Number " + repl("_",30) + " to  " + repl("_",30)
            @prow()+2,  1 say "Number " + repl("_",30) + " to  " + repl("_",30)

            @prow()+2,  1 say "We acknowledge receipt of Form E (Culling list) dated:-"

            @prow()+2,  1 say repl("_",30)

            @prow()+3,  1 say "The following are being returned for correction:-"

            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)
            @prow()+2,  1 say repl("_",79)

            @prow()+5,  1 say "_______________________________            ____________________"
            @prow()+1,  1 say "Signature                                  Date"

            @prow()+2,  1 say cAppName()

         endif

         fPrnEjec()
         fPrnOff()
      endif

   next

   //Herstel
return NIL

