// Application: StudMaster for Beef Cattle
//   File Name: SM3PARW.PRG
// Description: Function to read palmtop weights
//   Copyright: (c) 1920 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-08-20      09:20:50

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3parw

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local nBoxc := 0
   local lBrea := .f.
   local cIcar := ""
   local aDbfs := {}
   local cData := ""
   local nCh   := 1
   local aSscr := {}
   local cType := ""
   local cFild := ""

   begin sequence

      // Variables

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Funksie "+cOption())
      else
         fScrOpsk( ,"Function "+cOption())
      endif

      // Ask the location of the palmtop file
      cPath := padr(cPalmDir()+"\W"+cIcar+alltrim(substr(cTotNaam(),125,4))+".PTS",50)

      do while .t.

         if cLanType() = "A"
            fScrOpsk( ,"Funksie "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"LEES PALMTOP MASSAS")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik volledige lˆernaam bv. '"+cPath+"lˆernaam.ubr'")
         else
            fScrOpsk( ,"Function "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"IMPORT PALMTOP WEIGHTS")
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

      // Ask which weight to be input
      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Funksie "+cOption())
      else
         fScrOpsk( ,"Function "+cOption())
      endif
      aSscr := fASaveScr()
      nCh := fNewMenu(nCh,"SM3PWTY")
      fARestScr(aSscr)
      do case

         case nCh >= 1 .and. nCh <= 99
            // Push menu number into variable
            cType := alltrim(str(nCh-1))

         otherwise

            // Exit
            lRetu := .f.
            break

      endcase

      cPath := alltrim(cPath)

      // Create a temporary palmtop weights file
      // New format 02-12-06 12:11
      aDbfs := {}
      aadd(aDbfs,{"IDNR","C",14,0})
      aadd(aDbfs,{"DATE","D", 8,0})
      aadd(aDbfs,{"MASS","N", 4,0})
      aadd(aDbfs,{"TYPE","C", 2,0})
      aadd(aDbfs,{"DAMM","N", 4,0})
      aadd(aDbfs,{"REMA","C",20,0})
      ferase("palmweig.dbf")
      dbcreate("palmweig.dbf",aDbfs)

      // Append the file
      aCdbf := fATopen(aCdbf,,"PALMWEIG",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      append from &(cPath) delimited

      // Rename and move source palm file
      if right(cPath,4) == ".PTS"

         // Rename existing files

         // Remove the extention
         cPath := left(cPath,len(cPath)-4)

         if file(cPath+".005")
            // Delete the file
            ferase(cPath+".005")
         endif
         if file(cPath+".004")
            // Rename the file
            frename(cPath+".004",cPath+".005")
         endif
         if file(cPath+".003")
            // Rename the file
            frename(cPath+".003",cPath+".004")
         endif
         if file(cPath+".002")
            // Rename the file
            frename(cPath+".002",cPath+".003")
         endif
         if file(cPath+".001")
            // Rename the file
            frename(cPath+".001",cPath+".002")
         endif
         frename(cPath+".PTS",cPath+".001")

      endif

      go top

      // Open the handheld mass file
      aCdbf := fATopen(aCdbf,cDd(),"SM3MASH",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      zap

      // Loop the original read file
      select PALMWEIG
      go top
      do while !eof()

         // Skip if deleted
         if deleted()
            skip
            loop
         endif

         // Skip if no mass
         if empty(PALMWEIG->mass)
            skip
            loop
         endif

         // Skip if no date
         if empty(PALMWEIG->date)
            skip
            loop
         endif

         // Skip if not the correct type
         if cType == "0"
         else
            if alltrim(PALMWEIG->type) == cType
            else
               skip
               loop
            endif
         endif

         // Save the data
         select SM3MASH
         dbappend()
         cData := alltrim(substr(PALMWEIG->idnr,5,4))
         cData += substr(PALMWEIG->idnr,9,2)+"-"
         cData += padl(ltrim(str(val(substr(PALMWEIG->idnr,11,4)))),3,"0")
         SM3MASH->skaalid := cData
         SM3MASH->mass    := PALMWEIG->mass
         SM3MASH->date    := PALMWEIG->date
         SM3MASH->type    := PALMWEIG->type

         // Create the palmtop weight delete instruction
         // Open the text file
         //set alternate to (cFild) additive
         //set alternate on
         //set console off
         // Write the data
         //?? PALMWEIG->idnr
         //?
         // Close the file
         //set console on
         //set alternate off
         //set alternate to

         // Next record
         select PALMWEIG
         skip

      enddo

      // Close the files
      select PALMWEIG
      dbclosearea()
      ferase("palmweig.dbf")
      select SM3MASH
      dbclosearea()
      aCdbf := asize(aCdbf,len(aCdbf)-2)

      // Do the actual transfer to the studmaster files
      if sm3mash()

         // Delete the ascii file
         //ferase(cFile)

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
/******************************************************************************/
