// STDCODE.PRG
// Program om gebruikerskode te hanteer//
// Kopiereg (C) 2001 A van Rensburg
// 01-06-19 16:54

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION stdcode

   // Variables
   local getlist := {}
   local lRetu := .f.
   local nReas := 0
   local cUser := ""
   local nUcon := ""
   local nSum1 := 0
   local nSum2 := 0
   local nSum3 := 0
   local nUser := 0
   local nBack := 0
   local nGive := 0
   local cDriv := ""
   local cProg := ""
   local cRpro := ""
   local nRpro := 0
   local nSeri := 0
   local nDivi := 0
   local lLoop := .t.
   local cCoun := ""
   local i     := 0
   local nBoxc := 0
   local cBack := ""
   local nMfil := 0
   local cStr := ""

   begin sequence

      // Do not ask if a demo program
      if val(substr(cReeNomm(),4,6)) < 1 .or. cReeNomm() == "SMA0000" .or. cReeNomm() == "SME0000"
         lRetu := .t.
         break
      endif

      // Do not ask if in the December period
      // Do not ask if in the April period
      // Do not ask if in the July period
      // Do not ask if in the October period
      if substr(dtos(dAppDate()),5,4) >= "1201" .and. substr(dtos(dAppDate()),5,4) <= "1231" .or. ;
            substr(dtos(dAppDate()),5,4) >= "0101" .and. substr(dtos(dAppDate()),5,4) <= "0115" .or. ;
            substr(dtos(dAppDate()),5,4) >= "0315" .and. substr(dtos(dAppDate()),5,4) <= "0420" .or. ;
            substr(dtos(dAppDate()),5,4) >= "0615" .and. substr(dtos(dAppDate()),5,4) <= "0720" .or. ;
            substr(dtos(dAppDate()),5,4) >= "0915" .and. substr(dtos(dAppDate()),5,4) <= "1020"
         lRetu := .t.
         break
      endif

      // Get the seconds after midnight
      cDriv := right(padl(alltrim(str(int(seconds()))),8,"0"),3)

      // Open the serial number file
      dbusearea(.t.,,"SM3SERI.TDB","SM3SERI")

      // New installation
      if empty(SM3SERI->usecon) .and. nReas == 0
         nReas := 1
      endif

      // Registered name differs
      cUser := crypt(alltrim(SM3SERI->userna),"userna")
      for i = 1 to len(cUser)
         // Calculate the numeric version
         if i = 1
            nSum3 := int(asc(substr(upper(cUser),i,1))/7)
         elseif i = 2 .or. i = 5 .or. i = 7 .or. i = 10
            nSum2 += asc(substr(upper(cUser),i,1))
         elseif i = 3 .or. i = 4 .or. i = 9 .or. i = 13 .or. i = 17
            nSum1 += asc(substr(upper(cUser),i,1))
         endif
      next
      nUser := int((nSum1 * nSum2) / nSum3)
      nUcon := val(crypt(alltrim(SM3SERI->usecon),"usecon"))
      if nUser <> nUcon .and. nReas == 0
         nReas := 2
      endif

      // Ask for code if new version
      if left(cVersion(),3) <> crypt(alltrim(SM3SERI->versio),"versio") .and. nReas == 0
         nReas := 3
      endif

      // Time expired
      if !(empty(SM3SERI->datexp))
         if dAppDate() > stod(crypt(alltrim(SM3SERI->datexp),"datexp")) .and. nReas == 0
            nReas := 4
         endif
      endif

      // Ask for the user code
      if nReas > 0

         // Calculate the invisible user code // (Version 4.4a) 05-08-16 12:51
         cProg := alltrim(str(nReas))+cDriv+alltrim(str(nUser))
         //@24,0 say cProg
         //inkey(0)
         for i := 1 to len(cProg)
            cRpro := substr(cProg,i,1) + cRpro
         next
         nRpro := val(left(cRpro,5))
         //@24,10 say nRpro
         //inkey(0)
         nSeri := val(substr(cReeNomm(),4,4))
         //@24,20 say nSeri
         //inkey(0)
         nDivi := val(left(cProg,3))
         //@24,30 say nDivi
         //inkey(0)
         nGive :=  int((nRpro * nSeri) / nDivi)
         //@24,40 say nGive
         //inkey(0)

         // Calculate the invisible user code // (Version 4.3a en 4.3b)
         //cProg := alltrim(str(nReas))+cDriv+alltrim(str(nUser))
         //for i := 1 to len(cProg)
         //   cRpro := substr(cProg,i,1) + cRpro
         //next
         //nRpro := val(left(cRpro,4))
         //nSeri := val(substr(cReeNomm(),4,4))
         //nDivi := val(left(cProg,2))
         //nGive :=  int((nRpro * nSeri) / nDivi)

         // Save the program code if empty
         if empty(SM3SERI->datcod)
            SM3SERI->datcod := crypt(dtos(dAppDate()+15),"datcod")
            SM3SERI->dattod := crypt(dtos(dAppDate()),"dattod")
            SM3SERI->codeee := crypt(cProg,"codeee")
         endif

         // Keep the old user code if within date
         if dAppDate() <= stod(crypt(alltrim(SM3SERI->datcod),"datcod"))
            if empty(SM3SERI->codeee)
            else
               cProg := crypt(alltrim(SM3SERI->codeee),"codeee")
               for i := 1 to len(cProg)
                  cRpro := substr(cProg,i,1) + cRpro
               next
               nRpro := val(left(cRpro,5))
               nSeri := val(substr(cReeNomm(),4,4))
               nDivi := val(left(cProg,3))
               nGive :=  int((nRpro * nSeri) / nDivi)
            endif
         endif

         do while lLoop

            if cLanType() == "A"
               fScrOpsk(,"Programregistrasie")
               nBoxc := fBoxCent(4,"neer en neem dit saam telefoon toe. U kan voortgaan om die program",7,"Nota")
               if dAppDate() <= stod(crypt(SM3SERI->datcod,"datcod")) .and. ;
                     dAppDate() >= stod(crypt(SM3SERI->dattod,"dattod"))
                  // Registreer voor vervaldatum
                  set century on
                  @5,nBoxc say "Registreer asseblief die program voor "+dtoc(stod(crypt(SM3SERI->datcod,"datcod")))+" deur"
                  @6,nBoxc say cOwnFone() + " te skakel. Indien die rekenaar nie naby die"
                  @7,nBoxc say "telefoon is nie, skryf asseblief die onderstaande besonderhede"
                  @8,nBoxc say "neer en neem dit saam telefoon toe. U kan voortgaan om die program"
                  @9,nBoxc say "te gebruik tot en met die vervaldatum deur net [Enter] te druk."
                  @10,nBoxc say "Tik 9 om gebruikerskode versoek te epos."
                  set century off
               else
                  // Moes reeds geregistreer het
                  @5,nBoxc say "Registreer asseblief die program deur die volgende nommer"
                  @6,nBoxc say cOwnFone() + " te skakel. Indien die rekenaar nie naby die"
                  @7,nBoxc say "telefoon is nie, skryf asseblief die onderstaande besonderhede"
                  @8,nBoxc say "neer en neem dit saam telefoon toe."
                  @9,nBoxc say ""
                  @10,nBoxc say "Tik 9 om gebruikerskode versoek te epos."

               endif
               nBoxc := fBoxCent(14,"Gebruikerskode?"+space(42),7,"Gebruikerskode")
               @15,nBoxc say "   Reeksnommer:"
               @16,nBoxc say "      Weergawe:"
               @17,nBoxc say "   Gereg. Naam:"
               @18,nBoxc say "   Programkode:"
               @19,nBoxc say "Gebruikerskode?"
               @15,nBoxc+len("Gebruikerskode? ") say padr(cReeNomm(),10)
               @16,nBoxc+len("Gebruikerskode? ") say padr(cVersion(),4)
               @17,nBoxc+len("Gebruikerskode? ") say padr(cUser,40)
               @18,nBoxc+len("Gebruikerskode? ") say padr(cProg,10)
               fScrBood(maxrow()-1,"Tik asseblief die program se gebruikerskode.")
               fScrBood(maxrow(),"[Esc]=Terug  [Enter]=GaanVoort  [9]=EposGebruikerskode")
               @19,nBoxc+len("Gebruikerskode? ") get nBack pict "9999999999"
            else
               fScrOpsk(,"Program Registration")
               nBoxc := fBoxCent(4,"neer en neem dit saam telefoon toe. U kan voortgaan om die program",7,"Note")
               if dAppDate() <= stod(crypt(SM3SERI->datcod,"datcod")) .and. ;
                     dAppDate() >= stod(crypt(SM3SERI->dattod,"dattod"))
                  // Registreer voor vervaldatum
                  set century on
                  @5,nBoxc-1 say "Please register the program before "+dtoc(stod(crypt(SM3SERI->datcod,"datcod")))+" by phoning"
                  @6,nBoxc-1 say cOwnFone() + ". If the computer is not near to the telephone,"
                  @7,nBoxc-1 say "please write down the undermentioned details, and take it with you to"
                  @8,nBoxc-1 say "the telephone. You can carry on using the program until the expiry"
                  @9,nBoxc-1 say "date mentioned above by pressing [Enter]."
                  @10,nBoxc-1 say "Type 9 to email user code request."

                  set century off
               else
                  // Moes reeds geregistreer het
                  @5,nBoxc-1 say "Please register the program by phoning "+cOwnFone()
                  @6,nBoxc-1 say "If the computer is not near to the telephone, please write down the"
                  @7,nBoxc-1 say "undermentioned details, and take it with you to the telephone."
                  @8,nBoxc-1 say ""
                  @9,nBoxc-1 say ""
                  @10,nBoxc-1 say "Type 9 to email user code request."

               endif
               nBoxc := fBoxCent(14,"Serial Number?"+space(42),7,"User Code")
               @15,nBoxc say "Serial number:"
               @16,nBoxc say "      Version:"
               @17,nBoxc say "    Reg. Name:"
               @18,nBoxc say " Program code:"
               @19,nBoxc say "    User code?"
               @15,nBoxc+len("Serial number: ") say padr(cReeNomm(),10)
               @16,nBoxc+len("Serial number: ") say padr(cVersion(),4)
               @17,nBoxc+len("Serial number: ") say padr(cUser,40)
               @18,nBoxc+len("Serial number: ") say padr(cProg,10)
               fScrBood(maxrow()-1,"Please type the program's user code.")
               fScrBood(maxrow(),"[Esc]=Exit  [Enter]=Save  [9]=EmailUserCode")
               @19,nBoxc+len("Serial number: ") get nBack pict "9999999999"
            endif
            read

            // Escaped
            if lastkey() == K_ESC
               break
            endif

            // If no code
            if nBack == 0
               if dAppDate() <= stod(crypt(SM3SERI->datcod,"datcod")) .and. ;
                     dAppDate() >= stod(crypt(SM3SERI->dattod,"dattod"))
                  SM3SERI->dattod := crypt(dtos(dAppDate()),"dattod")
                  lRetu := .t.
                  break
               elseif dAppDate() > stod(crypt(SM3SERI->datcod,"datcod"))
                  SM3SERI->dattod := crypt(dtos(dAppDate()),"dattod")
                  SM3SERI->codeee := ""
                  break
               else
                  SM3SERI->codeee := ""
                  break
               endif
            endif

            // If code = 9 send email asking for user code
            if nBack == 9

               // Create email message file

               nMfil := fcreate("MailFile.txt")
               if nMfil < 0
                  if cLanType() == "A"
                     fScrBood(maxrow()-1)
                     fScrWBood(maxrow(),"Gebruikerskode epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
                  else
                     fScrBood(maxrow()-1)
                     fScrWBood(maxrow(),"User code email file not created! Reason: "+alltrim(str(ferror(),5,0)))
                  endif
                  loop
               endif

               // Build file contents

               if cLanType() == "A"

                  cStr := "StoetMeester Gebruikerskode" + chr(13) + chr(10) // Window frame name
                  fwrite(nMfil,cStr)
                  cStr := "home@studmaster.com" + chr(13) + chr(10) // To
                  fwrite(nMfil,cStr)
                  cStr := "StoetMeester Bees Gebruikerskode" + chr(13) + chr(10) // Subject
                  fwrite(nMfil,cStr)
                  cStr := "" + chr(13) + Chr(10) // Filename
                  fwrite(nMfil,cStr)
                  cStr := "Voorsien asseblief gebruikerskode vir:" + chr(13) + chr(10) // Body
                  fwrite(nMfil,cStr)
                  cStr := padr(cReeNomm(),10) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cVersion(),4) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cUser,40) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cProg,10) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := dtoc(stod(crypt(SM3SERI->datcod,"datcod")))+chr(13)+chr(10)
                  fwrite(nMfil,cStr)
                  cStr := fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(cGebNaam()) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),1,40)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),41,40)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),81,40)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),121,4)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := cAppName() + chr(13) + chr(10)
                  fwrite(nMfil,cStr)

               else

                  cStr := "StudMaster User Code" + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := "home@studmaster.com" + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := "StudMaster Beef User Code" + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := "" + chr(13) + Chr(10)
                  fwrite(nMfil,cStr)
                  cStr := "Please sypply user code for:" + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cReeNomm(),10) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cVersion(),4) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cUser,40) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := padr(cProg,10) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := dtoc(stod(crypt(SM3SERI->datcod,"datcod")))+chr(13)+chr(10)
                  fwrite(nMfil,cStr)
                  cStr := fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(cGebNaam()) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),1,40)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),41,40)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),81,40)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := alltrim(substr(cTotNaam(),121,4)) + chr(13) + chr(10)
                  fwrite(nMfil,cStr)
                  cStr := cAppName() + chr(13) + chr(10)
                  fwrite(nMfil,cStr)

               endif

               fclose(nMfil)
               swpruncmd("mailfile.exe mailfile.txt",300)

               nBack := 0
               loop

            endif

            // Code correct
            cBack := alltrim(str(nBack))
            if val(left(cBack,len(cBack)-2)) == nGive

               // Save the name and control field
               SM3SERI->usecon := crypt(alltrim(str(nUser)),"usecon")

               // Save the serial number
               SM3SERI->versio := crypt(left(alltrim(cVersion()),3),"versio")

               // Save the expiry date if needed
               if right(cBack,2) <> "00"
                  SM3SERI->datexp := crypt(dtos(dAppDate()+(val(right(cBack,2))*30)),"datexp")
               else
                  SM3SERI->datexp := ""
               endif

               // Remove any counters, program codes and code dates
               SM3SERI->datcod := ""
               SM3SERI->codeee := ""
               SM3SERI->dattod := ""

               lLoop := .f.
               lRetu := .t.

            endif

         enddo

      else

         // No code neccesary
         lRetu := .t.

      endif

   end

   // Close the file
   if select("SM3SERI") > 0
      dbclosearea()
      // Set the file date back to .exe date & time
      setfdati("sm3seri.tdb",filedate(exename()),filetime(exename()))
   endif

return lRetu
