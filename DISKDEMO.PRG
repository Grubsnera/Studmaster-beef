STATIC FUNCTION fDiskette

   // Program to create diskettes with birth notification data

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local nRout := 1
   local cNumb := ""
   begin sequence

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".CSV"
         //cFile := cDriv+"P"+alltrim(substr(cTotNaam(),152,7))+".CSV"
      else
         cFile := cMailTar()+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".CSV"
         //cFile := cMailTar()+"P"+alltrim(substr(cTotNaam(),152,7))+".CSV"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Prestasielˆer word voorberei")
      else
         fScrWbood(maxrow(),"Performance file being prepared")
      endif

      // Open the file
      if file(cFile)
         set alternate to (cFile) additive
         set alternate on
         set console off
      else
         set alternate to (cFile)
         set alternate on
         set console off
         // Write the header
         ?? "2200,"                              // Document code
         ?? "1,"                                 // Transaction code
         ?? dtos(dAppDate())+","                 // Date prepared
         ?? upper(trim(substr(cTotNaam(),162,30)))+"," //Regional Office
         ?? alltrim(cGebNaam())+","              // Member
         ?

         // Headings
         ?? "Document,"                          // Document code
         ?? "Code,"                              // Transaction code
         ?? "Member,"                            // Participant number
         ?? "Breed,"                             // Breed code
         ?? "Phase,"                             // Phase
         ?? "IdNo,"                              // Herd designation
         ?? "CompNo,"                            // Computer number
         ?? "Sex,"                               // Sex
         ?? "Mass,"
         ?? "DamBirth,"
         ?? "DamWean,"
         ?? "Date,"                              // Weighing date
         ?? "CalfSupl,"                          // Calf supplement
         ?? "CowSupl,"                           // Dam supplement
         ?? "IxCode,"
         ?

      endif

      // Write the data
      select MASS
      go top
      do while !eof()

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif
         set cons off
         set alternate on

         // Bewaar indekskode
         select SM3DATA
         if kod&cOude $ " 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ,10,12,13,14,15,01,02,03,04,05,06,07,08,09"
         elseif empty(cByvg)
         else
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := cByvg
         endif
         if empty(SM3DATA->kod&cOude)
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := "00"
         endif
         select MASS

         // Convert main id number
         if sm3idfo() == "1"
            cData := fId(SM3DATA->idnr)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         else
            cData := alltrim(SM3DATA->idnr)
         endif

         // The actual write
         ?? "2708,"                              // Document code
         ?? "1,"                                 // Transaction code
         ?? trim(substr(cTotNaam(),152,10))+","  // Participant number
         ?? substr(cTotNaam(),149,3)+","         // Breed code
         ?? cFase+","                            // Phase
         //?? alltrim(substr(cData,8,4))+","       // Herd designation
         // Animals year
         if isalpha(left(cData,1)) .and. substr(cData,2,1) == "0"
            // Old type number with year letter
            ?? alltrim(substr(cData,8,4))+alltrim(left(cData,1))+ltrim(str(val(substr(cData,4,4))))+"," // Year letter
         else
            ?? alltrim(substr(cData,8,4))+alltrim(left(cData,2))+ltrim(str(val(substr(cData,4,4))))+"," // Year letter
         endif
         // Animals sequence number
         //cNumb := substr(cData,4,4)
         //do while left(cNumb,1) == "0"
         //   cNumb := right(cNumb,len(cNumb)-1)
         //enddo
         //?? cNumb+","                            // Sequence number
         ?? alltrim(SM3DATA->reknr)+","          // Computer number
         ?? alltrim(SM3DATA->geslag)+","         // Sex
         ?? alltrim(str(SM3DATA->mas&cOude))+","
         ?? alltrim(str(SM3DATA->mamoergeb))+","
         ?? alltrim(str(SM3DATA->mamoerspe))+","
         ?? dtos(SM3DATA->dat&cOude)+","         // Weighing date
         ?? cByvk+","                            // Calf supplement
         ?? cByvm+","                            // Dam supplement
         ?? "_"+alltrim(SM3DATA->kod&cOude)+","
         ?

         // Next
         select MASS
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Prestasielˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Performance file was not created!")
         endif
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Prestasielˆer is suksesvol geskep!")
         else
            fScrBood(maxrow()-1,"Performance file was created succesfully!")
         endif
      endif
      fScrWait(maxrow())

   end
   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
