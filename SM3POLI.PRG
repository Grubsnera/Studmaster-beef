// Application: StudMaster for Beef Cattle
//   File Name: SM3POLI.PRG
// Description: Program to store breeding policy
//   Copyright: (c) 1925 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-03-25 14:53

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3poli

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aBscr := {}
   local aSend := {}
   local aRecv := {}
   local lLoop := .t.
   local nScrn := 1
   local nBoxc := 0
   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif
      aBscr := fASaveScr()

      // Loopup field names
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "tkpdir" })      // 1
      aadd( aSend, { "sm3data", "oekdir" })      // 2
      aadd( aSend, { "sm3data", "eocdir" })      // 3
      aadd( aSend, { "sm3data", "eocmat" })      // 4
      aadd( aSend, { "sm3data", "birdir" })      // 5
      aadd( aSend, { "sm3data", "birmat" })      // 6
      aadd( aSend, { "sm3data", "weadir" })      // 7
      aadd( aSend, { "sm3data", "weamat" })      // 8
      aadd( aSend, { "sm3data", "weacom" })      // 9
      aadd( aSend, { "sm3data", "yeadir" })      // 10
      aadd( aSend, { "sm3data", "m18dir" })      // 11
      aadd( aSend, { "sm3data", "adgdir" })      // 12
      aadd( aSend, { "sm3data", "kledir" })      // 13
      aadd( aSend, { "sm3data", "pcfcrd" })      // 14
      aadd( aSend, { "sm3data", "scrdir" })      // 15
      aadd( aSend, { "sm3data", "hgtdir" })      // 16
      aadd( aSend, { "sm3data", "lgtdir" })      // 17
      aRecv := fGetField( aSend )

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3POLI",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Create records if empty
      if empty(lastrec())
         dbappend()
         SM3POLI->descri := "Female"
         dbappend()
         SM3POLI->descri := "Male"
         dbappend()
         SM3POLI->descri := "Herd"
         dbappend()
         SM3POLI->descri := "National"
      endif


      // Loop to display different screens
      do while lLoop

         // Restore the blank screen
         fARestScr(aBscr)

         do case

            case nScrn == 0

               // Return to menu

               lLoop := .f.
               loop

            case nScrn == 1

               // Cow selection parameters

               // Select correct record
               select SM3POLI
               goto nScrn

               // Screen
               if cLanType() == "A"
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Vroulik" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Velde  [PgDn]=Manlik")
               else
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Female" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Fields  [PgDn]=Male")
               endif

            case nScrn == 2

               // Bull selection parameters

               // Select correct record
               select SM3POLI
               goto nScrn

               // Screen
               if cLanType() == "A"
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Manlik" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Velde  [PgUp]=Vroulik  [PgDn]=Kudde")
               else
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Male" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Fields  [PgUp]=Female  [PgDn]=Herd")
               endif

            case nScrn == 3

               // Herd selection parameters

               // Select correct record
               select SM3POLI
               goto nScrn

               // Screen
               if cLanType() == "A"
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Kudde" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Velde  [PgUp]=Manlik  [PgDn]=Nasionaal")
               else
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Herd" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Fields  [PgUp]=Male  [PgDn]=National")
               endif

            case nScrn == 4

               // National selection parameters

               // Select correct record
               select SM3POLI
               goto nScrn

               // Screen
               if cLanType() == "A"
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "Nasionaal" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Velde  [PgUp]=Kudde")
               else
                  nBoxc := fBoxCent( 4, space(20)+"  X  XXXXXXXX  XXXXXXXX  XXX", 17, "National" )
                  fScrBood(maxrow(),"[Esc]=Menu  "+D_DNARR+D_UPARR+"=Fields  [PgUp]=Herd")
               endif

         endcase

         // Screen
         @ 4, nBoxc say aRecv[ 1,6]
         @ 5, nBoxc say aRecv[ 2,6]
         @ 6, nBoxc say aRecv[ 3,6]
         @ 7, nBoxc say aRecv[ 4,6]
         @ 8, nBoxc say aRecv[ 5,6]
         @ 9, nBoxc say aRecv[ 6,6]
         @10, nBoxc say aRecv[ 7,6]
         @11, nBoxc say aRecv[ 8,6]
         @12, nBoxc say aRecv[ 9,6]
         @13, nBoxc say aRecv[10,6]
         @14, nBoxc say aRecv[11,6]
         @15, nBoxc say aRecv[12,6]
         @16, nBoxc say aRecv[13,6]
         @17, nBoxc say aRecv[14,6]
         @18, nBoxc say aRecv[15,6]
         @19, nBoxc say aRecv[16,6]
         @20, nBoxc say aRecv[17,6]

         // Read

         // Tkpdir
         @ 4, nBoxc+22 get SM3POLI->tkpdirs pict "!" when fWsel(aRecv[1,6])
         @ 4, nBoxc+25 get SM3POLI->tkpdirm when fWmin(aRecv[1,6])
         @ 4, nBoxc+35 get SM3POLI->tkpdirx when fWmax(aRecv[1,6]) valid fVmax(getlist, 1, 2, 3,aRecv[1,6])
         @ 4, nBoxc+45 get SM3POLI->tkpdira when fWacc(aRecv[1,6])

         // Oekdir
         @ 5, nBoxc+22 get SM3POLI->oekdirs pict "!" when fWsel(aRecv[2,6])
         @ 5, nBoxc+25 get SM3POLI->oekdirm when fWmin(aRecv[2,6])
         @ 5, nBoxc+35 get SM3POLI->oekdirx when fWmax(aRecv[2,6]) valid fVmax(getlist, 5, 6, 7,aRecv[2,6])
         @ 5, nBoxc+45 get SM3POLI->oekdira when fWacc(aRecv[2,6])

         // Eocdir
         @ 6, nBoxc+22 get SM3POLI->eocdirs pict "!" when fWsel(aRecv[3,6])
         @ 6, nBoxc+25 get SM3POLI->eocdirm when fWmin(aRecv[3,6])
         @ 6, nBoxc+35 get SM3POLI->eocdirx when fWmax(aRecv[3,6]) valid fVmax(getlist, 9,10,11,aRecv[3,6])
         @ 6, nBoxc+45 get SM3POLI->eocdira when fWacc(aRecv[3,6])

         // Eocmat
         @ 7, nBoxc+22 get SM3POLI->eocmats pict "!" when fWsel(aRecv[4,6])
         @ 7, nBoxc+25 get SM3POLI->eocmatm when fWmin(aRecv[4,6])
         @ 7, nBoxc+35 get SM3POLI->eocmatx when fWmax(aRecv[4,6]) valid fVmax(getlist,13,14,15,aRecv[4,6])
         @ 7, nBoxc+45 get SM3POLI->eocmata when fWacc(aRecv[4,6])

         // Birdir
         @ 8, nBoxc+22 get SM3POLI->birdirs pict "!" when fWsel(aRecv[5,6])
         @ 8, nBoxc+25 get SM3POLI->birdirm when fWmin(aRecv[5,6])
         @ 8, nBoxc+35 get SM3POLI->birdirx when fWmax(aRecv[5,6]) valid fVmax(getlist,17,18,19,aRecv[5,6])
         @ 8, nBoxc+45 get SM3POLI->birdira when fWacc(aRecv[5,6])

         // Birmat
         @ 9, nBoxc+22 get SM3POLI->birmats pict "!" when fWsel(aRecv[6,6])
         @ 9, nBoxc+25 get SM3POLI->birmatm when fWmin(aRecv[6,6])
         @ 9, nBoxc+35 get SM3POLI->birmatx when fWmax(aRecv[6,6]) valid fVmax(getlist,21,22,23,aRecv[6,6])
         @ 9, nBoxc+45 get SM3POLI->birmata when fWacc(aRecv[6,6])

         // Weadir
         @10, nBoxc+22 get SM3POLI->weadirs pict "!" when fWsel(aRecv[7,6])
         @10, nBoxc+25 get SM3POLI->weadirm when fWmin(aRecv[7,6])
         @10, nBoxc+35 get SM3POLI->weadirx when fWmax(aRecv[7,6]) valid fVmax(getlist,25,26,27,aRecv[7,6])
         @10, nBoxc+45 get SM3POLI->weadira when fWacc(aRecv[7,6])

         // Weamat
         @11, nBoxc+22 get SM3POLI->weamats pict "!" when fWsel(aRecv[8,6])
         @11, nBoxc+25 get SM3POLI->weamatm when fWmin(aRecv[8,6])
         @11, nBoxc+35 get SM3POLI->weamatx when fWmax(aRecv[8,6]) valid fVmax(getlist,29,30,31,aRecv[8,6])
         @11, nBoxc+45 get SM3POLI->weamata when fWacc(aRecv[8,6])

         // Weacom
         @12, nBoxc+22 get SM3POLI->weacoms pict "!" when fWsel(aRecv[9,6])
         @12, nBoxc+25 get SM3POLI->weacomm when fWmin(aRecv[9,6])
         @12, nBoxc+35 get SM3POLI->weacomx when fWmax(aRecv[9,6]) valid fVmax(getlist,33,34,35,aRecv[9,6])
         @12, nBoxc+45 get SM3POLI->weacoma when fWacc(aRecv[9,6])

         // Yeadir
         @13, nBoxc+22 get SM3POLI->yeadirs pict "!" when fWsel(aRecv[10,6])
         @13, nBoxc+25 get SM3POLI->yeadirm when fWmin(aRecv[10,6])
         @13, nBoxc+35 get SM3POLI->yeadirx when fWmax(aRecv[10,6]) valid fVmax(getlist,37,38,39,aRecv[10,6])
         @13, nBoxc+45 get SM3POLI->yeadira when fWacc(aRecv[10,6])

         // M18dir
         @14, nBoxc+22 get SM3POLI->m18dirs pict "!" when fWsel(aRecv[11,6])
         @14, nBoxc+25 get SM3POLI->m18dirm when fWmin(aRecv[11,6])
         @14, nBoxc+35 get SM3POLI->m18dirx when fWmax(aRecv[11,6]) valid fVmax(getlist,41,42,43,aRecv[11,6])
         @14, nBoxc+45 get SM3POLI->m18dira when fWacc(aRecv[11,6])

         // Adgdir
         @15, nBoxc+22 get SM3POLI->adgdirs pict "!" when fWsel(aRecv[12,6])
         @15, nBoxc+25 get SM3POLI->adgdirm when fWmin(aRecv[12,6])
         @15, nBoxc+35 get SM3POLI->adgdirx when fWmax(aRecv[12,6]) valid fVmax(getlist,45,46,47,aRecv[12,6])
         @15, nBoxc+45 get SM3POLI->adgdira when fWacc(aRecv[12,6])

         // Pcfcrd
         @16, nBoxc+22 get SM3POLI->pcfcrds pict "!" when fWsel(aRecv[13,6])
         @16, nBoxc+25 get SM3POLI->pcfcrdm when fWmin(aRecv[13,6])
         @16, nBoxc+35 get SM3POLI->pcfcrdx when fWmax(aRecv[13,6]) valid fVmax(getlist,49,50,51,aRecv[13,6])
         @16, nBoxc+45 get SM3POLI->pcfcrda when fWacc(aRecv[13,6])

         // Kledir
         @17, nBoxc+22 get SM3POLI->kledirs pict "!" when fWsel(aRecv[14,6])
         @17, nBoxc+25 get SM3POLI->kledirm when fWmin(aRecv[14,6])
         @17, nBoxc+35 get SM3POLI->kledirx when fWmax(aRecv[14,6]) valid fVmax(getlist,53,54,55,aRecv[14,6])
         @17, nBoxc+45 get SM3POLI->kledira when fWacc(aRecv[14,6])

         // Scrdir
         @18, nBoxc+22 get SM3POLI->scrdirs pict "!" when fWsel(aRecv[15,6])
         @18, nBoxc+25 get SM3POLI->scrdirm when fWmin(aRecv[15,6])
         @18, nBoxc+35 get SM3POLI->scrdirx when fWmax(aRecv[15,6]) valid fVmax(getlist,57,58,59,aRecv[15,6])
         @18, nBoxc+45 get SM3POLI->scrdira when fWacc(aRecv[15,6])

         // Hgtdir
         @19, nBoxc+22 get SM3POLI->hgtdirs pict "!" when fWsel(aRecv[16,6])
         @19, nBoxc+25 get SM3POLI->hgtdirm when fWmin(aRecv[16,6])
         @19, nBoxc+35 get SM3POLI->hgtdirx when fWmax(aRecv[16,6]) valid fVmax(getlist,61,62,63,aRecv[16,6])
         @19, nBoxc+45 get SM3POLI->hgtdira when fWacc(aRecv[16,6])

         // Lgtdir
         @20, nBoxc+22 get SM3POLI->lgtdirs pict "!" when fWsel(aRecv[17,6])
         @20, nBoxc+25 get SM3POLI->lgtdirm when fWmin(aRecv[17,6])
         @20, nBoxc+35 get SM3POLI->lgtdirx when fWmax(aRecv[17,6]) valid fVmax(getlist,65,66,67,aRecv[17,6])
         @20, nBoxc+45 get SM3POLI->lgtdira when fWacc(aRecv[17,6])

         set cursor on
         read
         set cursor off

         // Where to
         do case
            case lastkey() == K_ESC
               // Menu
               nScrn := 0
            case lastkey() == K_ENTER
               // Next screen
               nScrn++
               if nScrn > 4
                  nScrn := 0
               endif
            case lastkey() == K_PGUP
               // Previous screen
               nScrn--
               if nScrn < 1
                  nScrn := 1
               endif
            case lastkey() == K_PGDN
               // Next screen
               nScrn++
               if nScrn > 4
                  nScrn := 4
               endif
         endcase

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fVmax(aGetl,nSele,nMin,nMax,cBood)

   // Function to test if correct

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()

   // See if selected
   if lastkey() == K_UP
   else
      if aGetl[nSele]:varget() == "X"
         if aGetl[nMax]:varget() > aGetl[nMin]:varget()
         elseif aGetl[nMin]:varget() == 0 .and. aGetl[nMax]:varget() <> 0
         elseif aGetl[nMax]:varget() == 0 .and. aGetl[nMin]:varget() <> 0
         else
            if cLanType() == "A"
               fScrBood(maxrow()-1,alltrim(upper(cBood)) + " maksimum is kleiner/gelyk aan minimum!")
            else
               fScrBood(maxrow()-1,alltrim(upper(cBood)) + " maximum is smaller/same as minimum!")
            endif
            fScrWait(maxrow())
            lRetu := .f.
         endif
      endif
   endif

   // Reset
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWsel(cBood)

   // Function to display message

   // Declare
   local lRetu := .t.

   // Message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"Tik  X  indien "+alltrim(upper(cBood))+" in seleksie gebruik moet word!")
   else
      fScrBood(maxrow()-1,"Type  X  if "+alltrim(upper(cBood))+" must be used in selection!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWmin(cBood)

   // Function to display message

   // Declare
   local lRetu := .t.

   // Message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"Tik die minimum waarde vir die " + alltrim(upper(cBood)) + " eienskap!")
   else
      fScrBood(maxrow()-1,"Type the minimum value for the " + alltrim(upper(cBood)) + " trait!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWmax(cBood)

   // Function to display message

   // Declare
   local lRetu := .t.

   // Message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"Tik die maksimum waarde vir die " + alltrim(upper(cBood)) + " eienskap!")
   else
      fScrBood(maxrow()-1,"Type the maximum value for the " + alltrim(upper(cBood)) + " trait!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWacc(cBood)

   // Function to display message

   // Declare
   local lRetu := .t.

   // Message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"Tik die minimum akkuraatheidswaarde vir die " + alltrim(upper(cBood)) + " eienskap!")
   else
      fScrBood(maxrow()-1,"Type the minimum accuracy value for the " + alltrim(upper(cBood)) + " trait!")
   endif

return lRetu
