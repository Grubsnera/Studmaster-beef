// Application: StudMaster for Beef Cattle
//   File Name: SM3PRES.PRG
// Description: Program to enter single pregnancies
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-12-95      01:29:59pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3pres

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 0
   local lLoop := .t.
   local nIdnr := 0
   local nDate := 0
   local nPreg := 0
   local nWeek := 0
   local dDate := ctod("")
   local cBull := ""
   local cType := ""
   local dMate := ctod("")
   local aSend := {}
   local aRecv := {}
   local cTeeg := ""


   local getlist := {}
   local cOudeer := 365
   local cRustyd := 30
   local cNordra := 274
   local cMindra := 266
   local cMakdra := 308
   local cSiklus := 21
   begin sequence

      // Read the standard mating values
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dekkings standaardwaardes word gelees")
      else
         fScrWbood(maxrow(),"Mating standard values being read")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS")
      if !aCdbf[len(aCdbf),1]
      else
         locate for SM3RASS->raskod == substr(cTotNaam(),149,3)
         if !eof()
            cOudeer := SM3RASS->oudeer
            cRustyd := SM3RASS->rustyd
            cNordra := SM3RASS->nordra
            cMindra := SM3RASS->mindra
            cMakdra := SM3RASS->makdra
            cSiklus := SM3RASS->siklus
         endif
      endif
      fATclose(aCdbf)
      asize(aCdbf,len(aCdbf)-1)

      // Field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Dekkings veldbeskrywings word opgesoek")
      else
         fScrWbood(maxrow(),"Mating field descriptions being looked up")
      endif
      if empty(cDratip())
         aadd(aSend,{"SM3DATA","idnr"})
         aadd(aSend,{"SM3DATA","dragda"})
         aadd(aSend,{"SM3DATA","dragti"})
         aRecv := fGetField(aSend)
      else
         aadd(aSend,{"SM3DATA","idnr"})
         aadd(aSend,{"SM3DATA","dragda"})
         aadd(aSend,{"SM3DATA","dragwe"})
         aRecv := fGetField(aSend)
      endif
      aRecv := fFillBlank(aRecv)
      nIdnr := fEnum(aRecv,"idnr")
      nDate := fEnum(aRecv,"dragda")
      nPreg := fEnum(aRecv,"dragti")
      nWeek := fEnum(aRecv,"dragwe")

      // Screen
      fScrOpsk()

      // Get the mating season
      cTeeg := sm3teeg()
      if empty(cTeeg)
         break
      endif

      // Open the data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif

      aCdbf := fATopen(aCdbf,cDd(),"SM3TEMP",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      // Set order to females
      ordsetfocus("SM3ZVRO")

      aCdbf := fATopen(aCdbf,cDd(),"SM3DEKK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      // Set order to season+cowid
      ordsetfocus(2)

      // See if mating season exist
      seek cTeeg
      if eof()
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Vind geen kalfseisoen "+trim(cTeeg)+" koeie nie!")
         else
            fScrBood(maxrow()-1,"Found no "+trim(cTeeg)+" calving season cows")
         endif
         fScrWait(maxrow())
         break
      endif

      // Screen
      if cLanType() == "A"
         nBoxc := fBoxCent(10,space(33),5,"Dragtigheidsondersoeke - Enkel")
      else
         nBoxc := fBoxCent(10,space(33),5,"Pregnancy diagnosis - Single")
      endif

      // The loop to get the data
      do while lLoop

         // Display the fields
         @11,nBoxc say aRecv[nIdnr,6] ;
            get aRecv[nIdnr,14] ;
            pict aRecv[nIdnr,10] ;
            when fWidnr() ;
            valid fVidnr(getlist,aRecv)
         @12,nBoxc say aRecv[nDate,6] ;
            get aRecv[nDate,14] ;
            pict aRecv[nDate,10] ;
            when fWdragda(getlist,aRecv)
         if empty(cDratip())
            @13,nBoxc say aRecv[nPreg,6] ;
               get aRecv[nPreg,14] ;
               pict aRecv[nPreg,10] ;
               when fWdragti(getlist,aRecv) ;
               valid fVdragti(getlist,aRecv)
         else
            @13,nBoxc say aRecv[nWeek,6] ;
               get aRecv[nWeek,14] ;
               pict aRecv[nWeek,10] ;
               when fWdragwe(getlist,aRecv) ;
               valid fVdragwe(getlist,aRecv)
         endif

         // The get
         setcursor(1)
         read
         setcursor(0)

         // The keys
         if lastkey() == K_ESC
            lLoop := .f.
         else

            // Store the date
            dDate := aRecv[nDate,14]
            if !empty(cDratip())
               dMate := dDate - int(aRecv[nWeek,14]*7)
               cBull := ""
               cType := ""
            endif

            // Mating file
            select SM3DEKK
            seek cTeeg+aRecv[nIdnr,14]
            do while SM3DEKK->teelgroep+SM3DEKK->idmoer == cTeeg+aRecv[nIdnr,14]
               do while !rlock()
               enddo
               if empty(cDratip())
                  SM3DEKK->dragtig := aRecv[nPreg,14]
                  SM3DEKK->dragwe  := 0
               else
                  if aRecv[nWeek,14] > 0
                     if empty(cBull) .and. dMate >= SM3DEKK->datumin-10 .and. dMate <= SM3DEKK->datumuit+10
                        cBull := SM3DEKK->idvaar
                        cType := SM3DEKK->vaarkode
                        if cLanType() == "A"
                           SM3DEKK->dragtig := "J"
                        else
                           SM3DEKK->dragtig := "Y"
                        endif
                        SM3DEKK->dragwe  := aRecv[nWeek,14]
                     else
                        if empty(aRecv[nDate,14])
                           SM3DEKK->dragtig := " "
                           SM3DEKK->dragwe := 0
                        else
                           SM3DEKK->dragtig := "N"
                           SM3DEKK->dragwe := 0
                        endif
                     endif
                  else
                     if empty(aRecv[nDate,14])
                        SM3DEKK->dragtig := " "
                        SM3DEKK->dragwe := 0
                     else
                        SM3DEKK->dragtig := "N"
                        SM3DEKK->dragwe := 0
                     endif
                  endif

               endif
               dbunlock()
               skip
            enddo

            // Main file
            select SM3DATA
            seek aRecv[nIdnr,14]
            if found()
               do while !rlock()
               enddo
               SM3DATA->dragda := aRecv[nDate,14]
               if empty(cDratip())
                  SM3DATA->dragti := aRecv[nPreg,14]
                  SM3DATA->dragwe := 0
               else
                  SM3DATA->dragwe := aRecv[nWeek,14]
                  if SM3DATA->dragwe > 0
                     if cLanType() == "A"
                        SM3DATA->dragti := "J"
                     else
                        SM3DATA->dragti := "Y"
                     endif
                  else
                     if empty(aRecv[nDate,14])
                        SM3DATA->dragti := " "
                     else
                        SM3DATA->dragti := "N"
                     endif
                  endif
                  if !empty(cBull)
                     SM3DATA->bulid     := cBull
                     SM3DATA->teelgroep := cTeeg
                     SM3DATA->tipede    := cType
                     SM3DATA->dekdat    := dMate
                  endif
               endif

            endif

            // Clean out variables
            aRecv := fFillBlank(aRecv)

         endif

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWidnr

   // Function to control read access

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp  [PgUp]=Vorige dier  [PgDn]=Volgende dier")
      fScrBood(maxrow(),"Tik die Id nommer van die vers/koei wat dragtig ondersoek is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help  [PgUp]=Previous animal  [PgDn]=Next animal")
      fScrBood(maxrow(),"Type the Id number of the heifer/cow which was pd tested!")
   endif

   // Reset

return lRetu

/******************************************************************************/
STATIC FUNCTION fVidnr(aGets,aRecv)

   // Program to validate id numbers

   // Declare
   local lRetu := .t.
   local nIdnr := fEnum(aRecv,"idnr")
   local nDrad := fEnum(aRecv,"dragda")
   local nDrat := fEnum(aRecv,"dragti")
   local nDraw := fEnum(aRecv,"dragwe")
   begin sequence

      // Page up
      if lastkey() == K_PGUP
         lRetu := .f.
         select SM3DATA
         skip -1
         if bof()
            go top
         endif
         aGets[nIdnr]:varput(SM3DATA->idnr)
         aGets[nIdnr]:display()
      endif

      // Page down
      if lastkey() == K_PGDN
         lRetu := .f.
         select SM3DATA
         skip
         if eof()
            go bottom
         endif
         aGets[nIdnr]:varput(SM3DATA->idnr)
         aGets[nIdnr]:display()
      endif

      // Escape if no id number
      if empty(aGets[nIdnr]:varget())
         keyboard chr(K_ESC)
         break
      endif

      // See if cow exist
      select SM3DATA
      seek aGets[nIdnr]:varget()
      if eof()
         aGets[nIdnr]:varput(sm3idnu(3,,,"VROULIK IN KUDDE","SM3ZVRO",aGets[nIdnr]:varget()))
         if empty(aGets[nIdnr]:varget())
            aGets[nIdnr]:varput(space(12))
            lRetu := .f.
         else
            select SM3DATA
            seek aGets[nIdnr]:varget()
            if empty(cDratip())
               aGets[nDrad]:varput(SM3DATA->dragda)
               aGets[nDrad]:display()
               aGets[nDrat]:varput(SM3DATA->dragti)
               aGets[nDrat]:display()
            else
               aGets[nDrad]:varput(SM3DATA->dragda)
               aGets[nDrad]:display()
               aGets[nDraw]:varput(SM3DATA->dragwe)
               aGets[nDraw]:display()
            endif
         endif
      else
         if empty(cDratip())
            aGets[nDrad]:varput(SM3DATA->dragda)
            aGets[nDrad]:display()
            aGets[nDrat]:varput(SM3DATA->dragti)
            aGets[nDrat]:display()
         else
            aGets[nDrad]:varput(SM3DATA->dragda)
            aGets[nDrad]:display()
            aGets[nDraw]:varput(SM3DATA->dragwe)
            aGets[nDraw]:display()
         endif
      endif

   end
   // Reset

return lRetu

/******************************************************************************/
STATIC FUNCTION fWdragda

   // Function to control read access

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
      fScrBood(maxrow(),"Tik die datum waarop die dragtigheidsondersoek gedoen is!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
      fScrBood(maxrow(),"Type the date on which the pd test was performed!")
   endif

   // Reset
return lRetu

/******************************************************************************/
STATIC FUNCTION fWdragti

   // Function to control read access

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
      fScrBood(maxrow(),"Tik [JY123456] vir dragtig en [N0] vir nie dragtig!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
      fScrBood(maxrow(),"Type [YJ0123456] if pregnant or [N0] if not pregnant!")
   endif

   // Reset
return lRetu

/******************************************************************************/
STATIC FUNCTION fVdragti(aGets,aRecv)

   // Function to validate pregnancy status

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nDrat := fEnum(aRecv,"dragti")

   // Test
   if aGets[nDrat]:varget() $ " JYN0123456"
   else
      lRetu := .f.
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Slegs kodes JYN0123456 is aanvaarbaar!")
         fScrWait(maxrow())
      else
         fScrBood(maxrow()-1,"Only codes YJN0123456 is acceptable!")
         fScrWait(maxrow())
      endif
   endif

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWdragwe

   // Function to control read access

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
      fScrBood(maxrow(),"Tik AANTAL WEKE dragtig of NUL indien nie dragtig!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
      fScrBood(maxrow(),"Type NUMBER OF WEEKS preganant or ZERO if not pregnant!")
   endif

   // Reset
return lRetu

/******************************************************************************/
STATIC FUNCTION fVdragwe(aGets,aRecv)

   // Function to validate pregnancy status

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local nDraw := fEnum(aRecv,"dragwe")

   // Test
   if aGets[nDraw]:varget() >= 0
   else
      lRetu := .f.
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Aantal weke moet groter as NUL wees!")
         fScrWait(maxrow())
      else
         fScrBood(maxrow()-1,"Number of weeks must be greater than ZERO!")
         fScrWait(maxrow())
      endif
   endif

   // Reset
   fARestScr(aCscr)

return lRetu
