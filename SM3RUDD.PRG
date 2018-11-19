// Application: StudMaster for Beef Cattle
//   File Name: SM3RUDD.PRG
// Description: Program to run ruddweigh scales
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 04-02-96 01:07pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "directry.ch"

/******************************************************************************/
FUNCTION sm3rudd

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nBoxc := 1
   local nChoi := 1
   local i     := 0
   begin sequence

      fDownload()

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDownload

   // Function to download ruddweigh data

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCdbf := fATopen()
   local aCscr := fASaveScr()
   local aDire := {}
   local aFile := {}
   local cFile := ""
   local nChoi := 1
   local aDbfs := {}
   local dDate := ctod("")
   local i     := 0
   local nBoxc := 0
   Local cMass := ''
   Local cId   := ''
   Local lGetMass := .T.
   Local lGetId   := .F.
   local nPosi := 0
   local cMode := ""
   local cCopy := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      // Build the mode string
      cMode := "mode com"
      cMode += alltrim(str(nScPort(),1,0))+":"
      cMode += alltrim(str(nScBaud(),5,0))+","
      cMode += alltrim(cScPari())+","
      cMode += alltrim(str(nScBits(),1,0))+","
      cMode += alltrim(str(nScStop(),1,0))+",p"

      // Activate the scale
      //if swpruncmd("mode com1:9600,n,8,1,p")
      if swpruncmd(cMode)
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Mode fout: "+str(swperrmaj())+", "+str(swperrmin()))
         else
            fScrBood(maxrow()-1,"Mode error: "+str(swperrmaj())+", "+str(swperrmin()))
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      // Activate the scale
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Kies (Upload dataset F7) op die skaal!")
      else
         fScrBood(maxrow()-1,"Choose Upload dataset (F7) on the scale!")
      endif
      cCopy := "copy com"
      cCopy += alltrim(str(nScPort(),1,0))+":mass.txt"
      //if swpruncmd("copy com1:mass.txt",200)
      if swpruncmd(cCopy)
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Copy fout: "+str(swperrmaj())+", "+str(swperrmin()))
         else
            fScrBood(maxrow()-1,"Copy error: "+str(swperrmaj())+", "+str(swperrmin()))
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      //wait

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      // Array of files
      if file("mass.txt")
      else
         fScrBood(maxrow()-1,"Geen skaal massalˆers kon gevind word nie!")
         fScrWait(maxrow())
         lRetu := .f.
         break
      endif

      cFile := "mass.txt"

      // Create a temporary trutest file
      aDbfs := {}
      aadd(aDbfs,{"SKAALID","C",50,0})
      ferase("ruddweig.dbf")
      dbcreate("ruddweig.dbf",aDbfs)

      // Append the file
      aCdbf := fATopen(aCdbf,,"RUDDWEIG",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      append from &(cFile) delimited
      go top

      // Ask the weighing date
      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Tik die datum waarop die diere geweeg is!")
         nBoxc := fBoxCent(11,"Weegdatum? xx/xx/xx",3)
         @12,nBoxc say "Weegdatum?" get dDate
      else
         fScrOpsk( ,"Option "+cOption())
         fScrBood(maxrow()-1,"[Esc]=Menu")
         fScrBood(maxrow()  ,"Type the weighing date of the animals!")
         nBoxc := fBoxCent(11,"Weighing date? xx/xx/xx",3)
         @12,nBoxc say "Weighing date?" get dDate
      endif
      setcursor(1)
      read
      setcursor(0)

      // Break if no date
      if lastkey() == K_ESC .or. empty(dDate)
         lRetu := .f.
         break
      endif

      // Open the handheld mass file
      aCdbf := fATopen(aCdbf,cDd(),"SM3MASH",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      zap

      // Loop the original read file
      select RUDDWEIG
      go top
      do while !eof()

         // Skip if deleted
         if deleted()
            skip
            loop
         endif

         // Skip if nothing
         if empty(RUDDWEIG->skaalid)
            skip
            loop
         endif

         // Skip if no fullstop
         //if at(".",RUDDWEIG->skaalid) = 0
         //   skip
         //   loop
         //endif

         // Move the fullstop to the correct position
         nPosi := at(".",RUDDWEIG->skaalid)
         if nPosi > 5
            RUDDWEIG->skaalid := substr(RUDDWEIG->skaalid,nPosi-4,50)
         elseif nPosi> 0 .and. nPosi < 5
            RUDDWEIG->skaalid := space(5-nPosi) + RUDDWEIG->skaalid
         else
         endif

         // Skip if no mass
         if val(substr(RUDDWEIG->skaalid,1,4)) <= 0
            skip
            loop
         endif

         // Skip if no id number
         if empty(substr(RUDDWEIG->skaalid,9,5))
            skip
            loop
         endif

         // Save the data
         select SM3MASH
         dbappend()
         SM3MASH->skaalid := alltrim(substr(RUDDWEIG->skaalid,9,5))
         SM3MASH->mass    := val(alltrim(substr(RUDDWEIG->skaalid,1,4)))
         SM3MASH->mark    := alltrim(substr(RUDDWEIG->skaalid,14,2))
         SM3MASH->ownu    := alltrim(substr(RUDDWEIG->skaalid,17,7))
         SM3MASH->date    := dDate

         //Build the data
         // cMass := ""
         // cId := ""
         // lGetMass := .T.
         // lGetId := .F.
         //
         // for i := 1 to len(trim(RUDDWEIG->skaalid))
         //    if lGetMass
         //       if isdigit(substr(RUDDWEIG->skaalid,i,1))
         //          cMass += Substr(RuddWeig->SkaalId,i,1)
         //       Else
         //          If Len(cMass) > 0
         //             lGetMass := .F.
         //             lGetId := .T.
         //          Endif
         //       endif
         //    Endif
         //
         //    If lGetId
         //       If !Substr(RuddWeig->SkaalId,i,1) = ' '
         //          cId += Substr(RuddWeig->SkaalId,i,1)
         //       Endif
         //    Endif
         // next
         //
         // // Save the data
         // select SM3MASH
         // dbappend()
         // SM3MASH->skaalid := cId
         // SM3MASH->mass    := val(cMass)
         // SM3MASH->date    := dDate

         // Next record
         select RUDDWEIG
         skip

      enddo

      // Close the files
      select RUDDWEIG
      dbclosearea()
      ferase("ruddweig.dbf")
      select SM3MASH
      dbclosearea()
      aCdbf := asize(aCdbf,len(aCdbf)-2)

      // Do the actual transfer to the studmaster files
      if sm3mash()

         // Delete the ascii file
         ferase(cFile)

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCdbf)

return lRetu
