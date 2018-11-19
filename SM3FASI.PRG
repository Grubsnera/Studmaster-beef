// Application: StudMaster for Beef Cattle
//   File Name: SM3FASI.PRG
// Description: Program to enter bulls into phase D test
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 03-29-95      10:39:20am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3fasi

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nCh   := 1
   local cIndg := ""
   local nBoxc := 0
   local cCode := space(6)
   local cDesc := space(20)
   local lAdde := .f.
   local cMess := ""
   local getlist := {}

   begin sequence

      // Ask which animals must be included
      if cLanType() == "A"
		 fScrOpsk(1,"Opsie "+cOption())
         fScrBood( maxrow()-1, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
      else
		 fScrOpsk(1,"Option "+cOption())
         fScrBood( maxrow()-1, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
      endif

      nCh := fNewMenu(nCh,"SM3FASI")
		cOption(nCh)

      // Data files being opened
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen
      if cLanType() == "A"
			fScrOpsk(,"Opsie "+cOption())
      else
			fScrOpsk(,"Option "+cOption())
      endif

      // The choices
      if nCh == 1
         // Index group
         // Get the index group
         cIndg := sm3indg(4)
         if empty(cIndg)
            if cLanType() == "A"
               fScrWait(24,"Geen indeksgroep is gekies nie!")
            else
               fScrWait(24,"No index group was selected!")
            endif
            break
         endif

         // Create file with animals
         select SM3DATA
         ordsetfocus(3)
         seek cIndg
         if eof()
            if cLanType() == "A"
               fScrWait(24,"Geen diere kon gevind word vir die indeksgroep nie!")
            else
               fScrWait(24,"No animals could be found for the index group!")
            endif
            break
         endif
         copy to (cDd()+"mass") fields idnr while SM3DATA->indekskode == cIndg
         ordsetfocus(1)

      elseif nCh == 2
         // Group
         // Get the group
         cIndg := sm3groe()
         if empty(cIndg)
            if cLanType() == "A"
               fScrWait(24,"Geen groep is gekies nie!")
            else
               fScrWait(24,"No group was selected!")
            endif
            break
         endif

         // Look for the animals
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            fScrBood(maxrow(),"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
         else
            fScrBood(maxrow(),"Calves qualifying for the group requirements being selected.")
         endif
         copy to (cDd()+"mass") fields idnr for &(cIndg)

      elseif nCh == 3
         // Selection group
         // Get the group
         cIndg := sm3selg()
         if empty(cIndg)
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep is gekies nie!")
            else
               fScrWait(24,"No selection group was selected!")
            endif
            break
         endif

         // Look for the animals
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            fScrBood(maxrow(),"Kalwers wat voldoen aan die seleksiegroepvereistes word uitgesoek.")
         else
            fScrBood(maxrow(),"Calves qualifying for the selection group requirements being selected.")
         endif
         copy to (cDd()+"mass") fields idnr for &(cIndg)

      else
         // Exit
         break

      endif

      // Open the mass file
      ferase(cDd()+"MASS"+ordbagext())
      aCdbf := fATopen(aCdbf,cDd(),"MASS",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      set relation to MASS->idnr into SM3DATA
      go top

      // Remove female and not living animals
      do while !eof()

         // Keep only males in herd
         if SM3DATA->geslag $ "2MO" .and. SM3DATA->uitkrede $ cWaarisd()
         else
            delete
         endif

         // Next
         select MASS
         skip

      enddo
      pack
      set relation to
      go top

      // See if animals exist
      if lastrec() <= 0
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Geen Kalwers wat voldoen aan die seleksiegroepvereistes word uitgesoek.")
         else
            fScrBood(maxrow()-1,"Calves qualifying for the selection group requirements being selected.")
         endif
         fScrWait(maxrow())
         break
      endif

      // Ask the Phase Group particulars
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp  "+D_DNARR+"=Fasegroepe")
         fScrBood(maxrow()  ,"Tik die FASEGROEP waaraan die bulle gaan behoort!")
         nBoxc := fBoxCent(11,space(41),4,"Fasegroep")
         @12,nBoxc say "           Fasegroep" get cCode pict "@!" valid(fVcode(getlist))
         @13,nBoxc say "          Beskrywing" get cDesc
      else
         fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help  "+D_DNARR+"=Phase groups")
         fScrBood(maxrow()  ,"Type the PHASE GROUP to which the bulls will belong!")
         nBoxc := fBoxCent(11,space(41),4,"Phase group")
         @12,nBoxc say "         Phase group" get cCode pict "@!" valid(fVcode(getlist))
         @13,nBoxc say "         Description" get cDesc
      endif
      setcursor(1)
      read
      setcursor(0)

      // If escaped
      if lastkey() == K_ESC
         break
      endif

      // If empty
      if empty(cCode)
         break
      endif

      // Display found bulls one after the other
      if cLanType() == "A"
		 fScrOpsk(,"Opsie "+cOption())
         nBoxc := fBoxCent(11,space(17),4,"BUL")
         @12,nBoxc say " Bul"
         @13,nBoxc say "Rek#"
      else
		 fScrOpsk(,"Option "+cOption())
         nBoxc := fBoxCent(11,space(17),4,"BULL")
         @12,nBoxc say "Bull"
         @13,nBoxc say "Rec#"
      endif
      do while !eof()

         // Display the bull
         setcolor(cColInve())
         @12,nBoxc+5 say MASS->idnr
         @13,nBoxc+5 say ltrim(str(recno()))+"/"+ltrim(str(lastrec()))
         setcolor(cColNorm())

         // Ask if bull to go to phase d test
         if cLanType() == "A"
            cMess := "Gaan bogenoemde bul deelneem aan die "+trim(cCode)+" Fase D toets?"
         else
            cMess := "Will above-mentioned bull participate in the "+trim(cCode)+" Phase D test?"
         endif
         if fJaNee(maxrow(),cMess,,.f.,.f.)
            select SM3DATA
            seek MASS->idnr
            do while !rlock()
            enddo
            SM3DATA->fasekode := cCode
            dbunlock()
            select MASS
            lAdde := .t.
         endif

         // If escaped
         if lastkey() == K_ESC
            select MASS
            go bottom
            skip
         endif

         // Next
         select MASS
         skip

      enddo

      // Add group and description to group file
      if lAdde
         aCdbf := fATopen(aCdbf,cDd(),"SM3FASG")
         if !aCdbf[len(aCdbf),1]
            break
         endif
         seek cCode
         if eof()
            dbappend()
            SM3FASG->kode := cCode
            SM3FASG->besk := cDesc
            dbunlock()
         endif
      endif

   end

   // Reset
	cOption(-1)
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu


/******************************************************************************/
STATIC FUNCTION fVcode(aGets)

   // Function to display a pick list

   // Declare
   local aCscr := fASaveScr()
   local lRetu := .t.
   local cCode := ""
   local nElem := 0
   local i     := 0

   begin sequence

      // Get the active get element
      for i := 1 to len(aGets)
         if aGets[i]:hasfocus
            nElem := i
            exit
         endif
      next

      // Display the pick list
      if lastkey() == K_DOWN
         cCode := SM3FASG(4)
         if !empty(cCode)
            aGets[nElem]:varput(cCode)
            aGets[nElem]:display()
         else
            lRetu := .f.
         endif
      endif

   end

   // Reset
   fARestScr(aCscr)

return lRetu
