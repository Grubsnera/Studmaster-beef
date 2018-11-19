// Application: StudMaster for Beef Cattle
//   File Name: STDSERN.PRG
// Description: Program to ask for the serial number
//   Copyright: (c) 1920 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 01-06-20 11:18

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
Function stdsern

   // Declare
   local lRetu := .t.
   local aDbfc := {}
   local lLoop := .t.
   local nPosi := 0
   local cSeri := ""
   local cRnam := ""
   local nBoxc := 0

   begin sequence

      // Create the serial number file if it does not exist
      if !file("sm3seri.tdb")
         aSize(aDbfc,0)
         aadd(aDbfc,{"SERNUM","C",10,0})
         aadd(aDbfc,{"VERSIO","C",10,0})
         aadd(aDbfc,{"USERNA","C",40,0})
         aadd(aDbfc,{"USECON","C",10,0})
         aadd(aDbfc,{"DATCOD","C", 8,0})
         aadd(aDbfc,{"DATEXP","C", 8,0})
         aadd(aDbfc,{"CODEEE","C",10,0})
         aadd(aDbfc,{"DATTOD","C", 8,0})
         dbcreate("sm3seri.tdb",aDbfc)
      endif

      // Open the serial number file
      dbusearea(.t.,,"SM3SERI.TDB","SM3SERI")
      if lastrec() <= 0
         dbappend()
      endif

      // Store the version number if nothing
      if empty(SM3SERI->versio)
         SM3SERI->versio := crypt(left(alltrim(cVersion()),3),"versio")
      endif

      // Get the serial number
      if empty(SM3SERI->sernum)

         cSeri := space(10)

         do while lLoop

            // Ask for the serial number
            if cLanType() == "A"
               fScrOpsk(,"Reeksnommer")
               fScrBood(maxrow()-1,"[Esc]=Menu")
               fScrBood(maxrow(), "Tik die reeksnommer van die program.")
               nBoxc := fBoxCent(11,"Reeksnommer? xxxxxxxxxx",3,"Reeksnommer")
            else
               fScrOpsk(,"Serial Number")
               fScrBood(maxrow()-1,"[Esc]=Menu")
               fScrBood(maxrow(), "Type the serial number of the program.")
               nBoxc := fBoxCent(11,"Serial number? xxxxxxxxxx",3,"Serial number")
            endif

            // Vra die reeksnommer
            setcolor(cColNorm())
            if cLanType() == "A"
               @ 12, nBoxc say "Reeksnommer?" get cSeri pict "@!"
            else
               @ 12, nBoxc say "Serial number?" get cSeri pict "@!"
            endif
            set cursor on
            read
            set curs off

            // Escaped
            if lastkey() == K_ESC
               lRetu := .f.
               break
            endif

            // If nothing filled in
            if empty(cSeri)
               if cLanType() == "A"
                  cSeri := "SMA0000   "
               else
                  cSeri := "SME0000   "
               endif
            endif

            // First three characters must be spa or spe
            if left(cSeri,3) $ "SMAzSME"
            else
               if cLanType() == "A"
                  fScrWait(maxrow(),"Reeksnommer moet met 'SMA' begin")
               else
                  fScrWait(maxrow(),"Serial number must start with 'SME'")
               endif
               loop
            endif

            // Numeric part must be greater than 2 and smaller than 99999
            if val(substr(cSeri,4,5)) >= 0 .and. val(substr(cSeri,4,5)) <= 9999
            else
               if cLanType() == "A"
                  fScrWait(maxrow(),"Reeksnommer moet eindig met 'n waarde tussen 0000 en 9999")
               else
                  fScrWait(maxrow(),"Serial number must end with a value between 0000 and 9999")
               endif
               loop
            endif

            // Save the value
            SM3SERI->sernum := crypt(alltrim(cSeri),"sernum")
            cSeri := alltrim(cSeri)
            cReeNomm(cSeri)

            lLoop := .f.

         enddo

      else

         // Read the current serial number
         cSeri := crypt(alltrim(SM3SERI->sernum),"sernum")
         cReeNomm(cSeri)

      endif

      // Get the user name
      if empty(SM3SERI->userna)

         if cSeri == "SMA0000" .or. cSeri == "SME0000"
            // Do not ask
            break
         endif

         cRnam := space(40)
         lLoop := .t.
         do while lLoop

            // Ask for the registered name
            if cLanType() == "A"
               fScrOpsk(,"Geregistreerde Naam")
               fScrBood(maxrow()-1,"[Esc]=Menu")
               fScrBood(maxrow(), "Tik die Persoon of Besigheid in wie se naam die program geregistreer moet word.")
               nBoxc := fBoxCent(11,"Geregistreerde Naam?"+space(42),3,"Geregistreerde Naam")
            else
               fScrOpsk(,"Registered Name")
               fScrBood(maxrow()-1,"[Esc]=Menu")
               fScrBood(maxrow(), "Type the Person or Company in whose name the program must be registered.")
               nBoxc := fBoxCent(11,"Registered Name?"+space(42),3,"Registered Name")
            endif

            // Vra die reeksnommer
            setcolor(cColNorm())
            if cLanType() == "A"
               @ 12, nBoxc say "Geregistreerde Naam?" get cRnam
            else
               @ 12, nBoxc say "Registered Name?" get cRnam
            endif
            set cursor on
            read
            set curs off

            // Escaped
            if lastkey() == K_ESC
               lRetu := .f.
               break
            endif

            // If nothing filled in
            if empty(cRnam)
               if cLanType() == "A"
                  fScrWait(maxrow(),"Die geregistreerde naam is ongelukkig verpligtend")
               else
                  fScrWait(maxrow(),"The registered name is unfortunately compulsory")
               endif
               loop
            endif

            // Save the value
            SM3SERI->userna := crypt(alltrim(cRnam),"userna")
            cRnam := crypt(alltrim(SM3SERI->userna),"userna")
            cRegNaam(cRnam)

            lLoop := .f.

         enddo

      else

         // Read the current registered user
         cRnam := crypt(alltrim(SM3SERI->userna),"userna")
         cRegNaam(cRnam)

      endif

   end

   // Close the file
   dbclosearea()

   // Set the file date back to .exe date & time
   setfdati("sm3seri.tdb",filedate(exename()),filetime(exename()))

return lRetu
