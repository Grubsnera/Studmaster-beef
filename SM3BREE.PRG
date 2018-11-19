// Application: StudMaster for Beef Cattle
//   File Name: SM3BREE.PRG
// Description: Program to import Breedplan breeding values
//   Copyright: (c) 2002 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-03-22 13:31

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3bree

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local lBrea := .f.
   local cVers := ""
   local dDate := ctod("")
   local nFoun := 0
   local nUnkn := 0
   local nBoxc := 0
   local cBood := ""

   begin sequence

      cPath := padr("A:\"+"E"+ltrim(str(val(substr(cTotNaam(),152,10))))+".DAT",50)

      do while .t.

         if cLanType() = "A"
            fScrOpsk( ,"Opsie "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"LEES BLUP TEELWAARDES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik volledige lˆer naam bv. '"+cPath+"lˆernaam.ubr'")
         else
            fScrOpsk( ,"Option "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"IMPORT EBV BREEDING VALUES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow(),"Type full file name e.g. '"+cPath+"filename.ext'")
         endif

         @ 12,nboxc GET cPath
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // Escaped
         if lastkey() == K_ESC
            lBrea := .t.
            exit
         endif

         if !(file(alltrim(cPath)))
            // File does not exist
            if cLanType() = "A"
               fScrBood(maxrow()-1,"Die lˆer "+alltrim(cPath)+" bestaan nie ?")
               fScrWait(maxrow())
            else
               fScrBood(MAXROW()-1,"The file "+alltrim(cPath)+" does not exist ?")
               fScrWait(MAXROW())
            endif
         else
            // File exist
            exit
         endif

      enddo

      if lBrea
         lRetu := .f.
         break
      endif

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3IMPO",,,,.f.)
      if ! aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      IF !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      set order to 14
      go top

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow(),"Die lˆer "+alltrim(cPath)+" word gelees...")
         fScrBood(maxrow()-1)
      else
         fScrBood(maxrow(),"The file "+alltrim(cPath)+" being imported...")
         fScrBood(maxrow()-1)
      endif

      // The actual import
      dbselectarea("SM3IMPO")
      zap
      append from (alltrim(cPath)) sdf
      go top

      // See if there are records
      if lastrec() < 1
         if cLanType() = "A"
            fScrBood(maxrow()-1,"Geen data kon gelees word vanaf die lˆer nie!")
         else
            fScrBood(maxrow()-1,"No data could be read from the file!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Read each record in import file and store in main file
      // First record is a header
      select SM3IMPO
      go top

      // Read header record
      cVers := substr(SM3IMPO->text,2,5)

      //dDate := convdate(substr(SM3IMPO->text,22,8))
      //Breedplan 04:20 not in yyyymmdd format
      dDate := ctod(substr(SM3IMPO->text,22,8))

      skip

      do while !eof()

         // Find the animal
         select SM3DATA
         set order to 14
         go top
         seek padl(alltrim(substr(SM3IMPO->text,26,19)),10,"0")
         if eof()

            // Then seek the calf book number
            select SM3DATA
            set order to 6
            go top
            seek padl(alltrim(substr(SM3IMPO->text,26,19)),10,"0")

            if eof()

               // Make note that animal does not exist
               nUnkn++
               select SM3IMPO
               SM3IMPO->mark := "*"
               skip
               loop

            endif

         else

            nFoun++

            // Clean out current values
            SM3DATA->analdate := ctod("")
            SM3DATA->tkpdir := 0
            SM3DATA->tkpacc := 0
            SM3DATA->oekdir := 0
            SM3DATA->oekacc := 0
            SM3DATA->eocdir := 0
            SM3DATA->eocacc := 0
            SM3DATA->eocmat := 0
            SM3DATA->eocmac := 0
            SM3DATA->birdir := 0
            SM3DATA->biracc := 0
            SM3DATA->birmat := 0
            SM3DATA->birmac := 0
            SM3DATA->weadir := 0
            SM3DATA->weaacc := 0
            SM3DATA->weamat := 0
            SM3DATA->weamac := 0
            SM3DATA->weacom := 0
            SM3DATA->weacac := 0
            SM3DATA->yeadir := 0
            SM3DATA->yeaacc := 0
            SM3DATA->m18dir := 0
            SM3DATA->m18acc := 0
            SM3DATA->adgdir := 0
            SM3DATA->adgacc := 0
            SM3DATA->pcfcrd := 0
            SM3DATA->pcfcra := 0
            SM3DATA->kledir := 0
            SM3DATA->kleacc := 0
            SM3DATA->scrdir := 0
            SM3DATA->scracc := 0
            SM3DATA->hgtdir := 0
            SM3DATA->hgtacc := 0
            SM3DATA->lgtdir := 0
            SM3DATA->lgtacc := 0
            SM3DATA->findir := 0
            SM3DATA->finacc := 0
            SM3DATA->mcwdir := 0
            SM3DATA->mcwacc := 0
            SM3DATA->cardir := 0
            SM3DATA->caracc := 0
            SM3DATA->ribdir := 0
            SM3DATA->ribacc := 0

         endif

         // Save the data

         // Analysis date
         SM3DATA->analdate := dDate
         SM3DATA->phddat := dDate

         // Birth direct
         SM3DATA->birdir := val(substr(SM3IMPO->text, 47,5))
         SM3DATA->biracc := val(substr(SM3IMPO->text,131,2))

         // 200 day
         SM3DATA->weadir := val(substr(SM3IMPO->text, 56,4))
         SM3DATA->weaacc := val(substr(SM3IMPO->text,135,2))
         SM3DATA->weamat := val(substr(SM3IMPO->text, 72,4))
         SM3DATA->weamac := val(substr(SM3IMPO->text,143,2))
         SM3DATA->weacom := val(substr(SM3IMPO->text, 52,4))
         SM3DATA->weacac := val(substr(SM3IMPO->text,133,2))

         // 400 day
         SM3DATA->yeadir := val(substr(SM3IMPO->text, 60,4))
         SM3DATA->yeaacc := val(substr(SM3IMPO->text,137,2))

         // 600 day
         SM3DATA->m18dir := val(substr(SM3IMPO->text, 64,4))
         SM3DATA->m18acc := val(substr(SM3IMPO->text,139,2))

         // 900 day
         SM3DATA->adgdir := val(substr(SM3IMPO->text, 68,4))
         SM3DATA->adgacc := val(substr(SM3IMPO->text,141,2))

         // Gestation length
         SM3DATA->tkpdir := val(substr(SM3IMPO->text, 81,5))
         SM3DATA->tkpacc := val(substr(SM3IMPO->text,147,2))

         // Scrotum size
         SM3DATA->scrdir := val(substr(SM3IMPO->text, 86,5))
         SM3DATA->scracc := val(substr(SM3IMPO->text,149,2))

         // Days to calving
         SM3DATA->oekdir := val(substr(SM3IMPO->text, 91,5))
         SM3DATA->oekacc := val(substr(SM3IMPO->text,151,2))

         // Ease of calving
         SM3DATA->eocdir := val(substr(SM3IMPO->text,121,5))
         SM3DATA->eocacc := val(substr(SM3IMPO->text,163,2))
         SM3DATA->eocmat := val(substr(SM3IMPO->text,126,5))
         SM3DATA->eocmac := val(substr(SM3IMPO->text,165,2))

         // Mature cow weight
         SM3DATA->mcwdir := val(substr(SM3IMPO->text,171,4))
         SM3DATA->mcwacc := val(substr(SM3IMPO->text,214,2))

         // Carcass weight
         SM3DATA->cardir := val(substr(SM3IMPO->text,175,4))
         SM3DATA->caracc := val(substr(SM3IMPO->text,216,2))

         // Rib fat
         SM3DATA->ribdir := val(substr(SM3IMPO->text,179,5))
         SM3DATA->ribacc := val(substr(SM3IMPO->text,218,2))

         // Retail beef yield
         SM3DATA->findir := val(substr(SM3IMPO->text,194,5))
         SM3DATA->finacc := val(substr(SM3IMPO->text,224,2))

         // Net feed efficiency
         SM3DATA->kledir := val(substr(SM3IMPO->text,209,5))
         SM3DATA->kleacc := val(substr(SM3IMPO->text,230,2))

         // Net feed intake
         SM3DATA->pcfcrd := val(substr(SM3IMPO->text,235,5))
         SM3DATA->pcfcra := val(substr(SM3IMPO->text,258,2))

         // Docility
         SM3DATA->lgtdir := val(substr(SM3IMPO->text,247,4))
         SM3DATA->lgtacc := val(substr(SM3IMPO->text,251,2))




         // 02-03-27 11:39
         // Still short fields in SM3DATA for Carcass rump fat ebv
         //                                   Eye muscle area abv
         //                                   Intramuscular fat ebv
         //                                   Tenderness ebv



         // Next record
         select SM3IMPO
         skip

      enddo

      // Notice if not all animals were found
      if nUnkn == 0
         if cLanType() = "A"
            fScrBood(maxrow()-1,"Teelwaardes van "+ALLTRIM(STR(nFoun))+" diere is ingelees!")
            fScrWait(maxrow())
         else
            fScrBood(maxrow()-1,"Breeding values for "+ALLTRIM(STR(nFoun))+" animals was processed!")
            fScrWait(maxrow())
         endif
      else
         if cLanType() = "A"
            fScrBood(maxrow()-1,"Teelwaardes van "+ALLTRIM(STR(nUnkn))+" uit "+ALLTRIM(STR(nFoun+nUnkn))+" diere kon nie gelees word nie!")
            cBood := "Druk inligting van die diere wat nie gevind kon word!"
         else
            fScrBood(maxrow()-1,"Breeding values for "+ALLTRIM(STR(nUnkn))+" out of "+ALLTRIM(STR(nFoun+nUnkn))+" animals could not be read!")
            cBood := "Print information of the unknown animals"
         endif
         if fJaNee(maxrow(),cBood,,.f. )
            fPrint()
         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION convdate(cDate)

   local dRetu := ctod("")
   local cRetu := ""

   begin sequence

      cRetu := left(cDate,4)
      if val(cRetu) > 1930
         // Date valid
         cRetu := right(cDate,2) + "/"
         cRetu += substr(cDate,5,2) + "/"
         cRetu += left(cDate,4)
         set cent on
         dRetu := ctod(cRetu)
         set cent off
      else
         // Date not valid - skip
         break
      endif

   end

return dRetu

/*************************************************************************/
STATIC FUNCTION fPrint

   // Declare
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   // Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return NIL
   endif

   // Skerm
   fScrBood(maxrow()-1)
   fScrBood(maxrow())

   // Skuif die databasis
   select SM3IMPO
   go top

   // Tel aantal velde
   nTota := lastrec()

   // Bepaal die drukgrootte
   nWidt := 0

   if nWidt <= nPrnWidt()
      // Normal
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      // Condense
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl()
         nPagl := nPrnLeng()
      else
         nPrnl := nPrcPrnl()
         nPagl := nPrcLeng()
      endif
   endif

   nMidc := nWidt - 29

   // Skerm
   if cLanType() == "A"
      fScrbood(maxrow()-1,"Diere nie gevind word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("Diere met teelwaardes wat nie gevind kon word nie")
   else
      fScrbood(24,"Unknown animals being printed!  [Esc]=Stop printer.")
      cHdln := upper("Animals with breeding values that could not be found")
   endif

   // Skakel die drukker aan
   fPrnOn()

   // Doen die loop
   lLoop := .t.
   do while lLoop

      //Opskrifte
      if prow() = 0

         fPrnCod( cPcod )
         if cLanType() == "A"
            @prow()+nTopl, 1 say upper( cGebNaam() )
            @prow()  , nMidc say "             Verslag: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            @prow()+1,     1 say cHdln
         else
            @prow()+nTopl, 1 say upper( cGebNaam() )
            @prow()  , nMidc say "              Report: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "    Herd Designation: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            @prow()+1,     1 say cHdln
         endif
         @prow()+1,  1 say repl( "=",  nWidt )

         // Opskrif
         if cLanType() == "A"
            @prow()+1,  1 say "                            Dier       Registrasie  In   "
            @prow()+1,  1 say "Identifikasie       Geslag  status     status       kudde"
            @prow()+1,  1 say "------------------- ------- ---------- ------------ -----"
            //                 1                   21      29         40           53
         else
            @prow()+1,  1 say "                            Animal     Registration In   "
            @prow()+1,  1 say "Identification      Sex     status     status       herd "
            @prow()+1,  1 say "------------------- ------- ---------- ------------ -----"
         endif


      endif

      // Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      // Data
      if !empty(SM3IMPO->mark)

         // Identifikasie
         @prow()+1, 1 say substr(SM3IMPO->text,1,19)

         // Sex
         if cLanType() == "A"
            if substr(SM3IMPO->text,22,1) == "M"
               @prow()  ,21 say "Manlik"
            elseif substr(SM3IMPO->text,22,1) == "F"
               @prow()  ,21 say "Vroulik"
            elseif substr(SM3IMPO->text,22,1) == "S"
               @prow()  ,21 say "Os"
            else
               @prow()  ,21 say "Onbekend"
            endif
         else
            if substr(SM3IMPO->text,22,1) == "M"
               @prow()  ,21 say "Male"
            elseif substr(SM3IMPO->text,22,1) == "F"
               @prow()  ,21 say "Female"
            elseif substr(SM3IMPO->text,22,1) == "S"
               @prow()  ,21 say "Ox"
            else
               @prow()  ,21 say "Unknown"
            endif
         endif

         // Animal status
         if cLanType() == "A"
            if substr(SM3IMPO->text,23,1) == "A"
               @prow()  ,29 say "Aktief"
            elseif substr(SM3IMPO->text,23,1) == "I"
               @prow()  ,29 say "Onaktief"
            elseif substr(SM3IMPO->text,23,1) == "D"
               @prow()  ,29 say "Dood"
            elseif substr(SM3IMPO->text,23,1) == "X"
               @prow()  ,29 say "Oorsee"
            elseif substr(SM3IMPO->text,23,1) == "E"
               @prow()  ,29 say "Uitgevoer"
            elseif substr(SM3IMPO->text,23,1) == "C"
               @prow()  ,29 say "Geskrap"
            else
               @prow()  ,29 say "Onbekend"
            endif
         else
            if substr(SM3IMPO->text,23,1) == "A"
               @prow()  ,29 say "Active"
            elseif substr(SM3IMPO->text,23,1) == "I"
               @prow()  ,29 say "Inactive"
            elseif substr(SM3IMPO->text,23,1) == "D"
               @prow()  ,29 say "Dead"
            elseif substr(SM3IMPO->text,23,1) == "X"
               @prow()  ,29 say "Overseas"
            elseif substr(SM3IMPO->text,23,1) == "E"
               @prow()  ,29 say "Exported"
            elseif substr(SM3IMPO->text,23,1) == "C"
               @prow()  ,29 say "Culled"
            else
               @prow()  ,29 say "Unknown"
            endif
         endif

         // Registration status
         if cLanType() == "A"
            if substr(SM3IMPO->text,24,1) == "R"
               @prow()  ,40 say "Geregistreer"
            elseif substr(SM3IMPO->text,24,1) == "C"
               @prow()  ,40 say "Aangeteken"
            elseif substr(SM3IMPO->text,24,1) == "M"
               @prow()  ,40 say "Kommersieel"
            elseif substr(SM3IMPO->text,24,1) == " "
               @prow()  ,40 say "Voorgeslag"
            else
               @prow()  ,40 say "Onbekend"
            endif
         else
            if substr(SM3IMPO->text,24,1) == "R"
               @prow()  ,40 say "Registered"
            elseif substr(SM3IMPO->text,24,1) == "C"
               @prow()  ,40 say "Recorded"
            elseif substr(SM3IMPO->text,24,1) == "M"
               @prow()  ,40 say "Commercial"
            elseif substr(SM3IMPO->text,24,1) == " "
               @prow()  ,40 say "Ancestral"
            else
               @prow()  ,40 say "Unknown"
            endif
         endif

         // In herd
         if cLanType() == "A"
            if substr(SM3IMPO->text,25,1) == "Y"
               @prow()  ,53 say "Ja"
            else
               @prow()  ,53 say "Nee"
            endif
         else
            if substr(SM3IMPO->text,25,1) == "Y"
               @prow()  ,53 say "Yes"
            else
               @prow()  ,53 say "No"
            endif
         endif

      endif

      // Volgende rekord
      select SM3IMPO
      skip

      // Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         // Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         nBlad++

         // Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   // Herstel
   select SM3IMPO
   go top

return NIL
