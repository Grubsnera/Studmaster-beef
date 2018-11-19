// Application: StudMaster for Beef Cattle
//   File Name: SM3MSPE.PRG
// Description: Program to mark any animals pedigree
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-26-95      12:50:31pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3mspe(cMark)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aSend := {}
   local aRecv := {}
   local nLine := 0
   local nBoxc := 0
   local nReko := 0
   local cIdnr := ""
   local nNumb := 0
   local nCoun := 0
   local getlist := {}

   begin sequence

      // Values
      if empty(cMark)
         break
      endif

      // Get the fields
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      asize(aSend,0)
      aadd(aSend,{"SM3MARK","idnr"})
      aadd(aSend,{"SM3MARK","number"})
      aRecv := fGetField(aSend)

      // Open the data file
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3MERK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3MARK",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Screen
      nLine := maxrow()/2-int(len(aRecv)/2)-1
      if cLanType() == "A"
		 fScrOpsk( ,"Opsie "+cOption())
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"MERK EEN DIER SE VOORGESLAG" )
      else
		 fScrOpsk( ,"Option "+cOption())
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"MARK ONE ANIMAL'S PEDIGREE" )
      endif

      // Blank data
      aRecv := fFillBlank(aRecv)
      aRecv[2,FLD_CARG] := 999

      // Vertoon en get velde
      @nLine+ 1,nBoxc say aRecv[ 1,FLD_DESC] get aRecv[ 1,FLD_CARG] ;
         pict aRecv[ 1,FLD_PICT] ;
         when(fWidnr()) ;
         valid(fVidnr(getlist,aRecv))
      @nLine+ 2,nBoxc say aRecv[ 2,FLD_DESC] get aRecv[ 2,FLD_CARG] ;
         pict aRecv[ 2,FLD_PICT] ;
         when(fWnumber())

      // The get
      set cursor on
      read
      set cursor off

      // Where to now?
      if lastkey() == K_ENTER

         // Start the process
         select SM3MARK
         dbappend()
         SM3MARK->idnr   := aRecv[1,FLD_CARG]
         SM3MARK->number := 0

      else

         // Quit
         break

      endif

      // Loop to do the actual search
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Voorgeslagte word uitgesoek")
      else
         fScrWbood(maxrow(),"Pedigree being selected")
      endif
      select SM3MARK
      go top
      do while !eof()

         // Get the current record number
         nReko := recno()
         cIdnr := SM3MARK->idnr
         nNumb := SM3MARK->number

         // Only up to the recommended generation
         if nNumb < aRecv[2,FLD_CARG]

            // Locate the animal in the main file
            select SM3DATA
            seek cIdnr
            if eof()
               select SM3MARK
               skip
            endif

            // Add the sire
            if !empty(SM3DATA->idvaar)
               select SM3MARK
               dbappend()
               SM3MARK->idnr := SM3DATA->idvaar
               SM3MARK->number := nNumb+1
            endif

            // Add the dam
            if !empty(SM3DATA->idmoer)
               select SM3MARK
               dbappend()
               SM3MARK->idnr := SM3DATA->idmoer
               SM3MARK->number := nNumb+1
            endif

         endif

         // Next record
         select SM3MARK
         goto nReko
         skip

      enddo

      // Mark the animals
      if cLanType() == "A"
         fScrWbood(maxrow(),"Voorgeslagte word gemerk")
      else
         fScrWbood(maxrow(),"Pedigree being marked")
      endif
      select SM3MARK
      go top
      do while !eof()

         // Screen
         if cmkeyno()%10 == 0
            if cLanType() == "A"
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Voltooi")
            else
               fScrWbood(maxrow()-1,fpercent(cmkeyno(),cmkeycount())+" % Completed")
            endif
         endif

         // Locate the animal in the main file
         select SM3DATA
         seek SM3MARK->idnr
         if found()
            if SM3DATA->toggle1 <> cMark
               nCoun++
            endif
            do while !rlock()
            enddo
            SM3DATA->toggle1 := cMark
         endif

         // Next record
         select SM3MARK
         skip

      enddo

      // Save the number of animals marked
      select SM3MERK
      seek cMark
      do while !rlock()
      enddo
      SM3MERK->aant := nCoun

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWidnr

   // Function to control entry to the id number field

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Lys van diere")
      fScrBood(maxrow()  ,"Tik die ID NOMMER van die dier om te merk!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=List of animals")
      fScrBood(maxrow()  ,"Type the ID NUMBER of the animal to be marked!")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVidnr(aGets,aRecv)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local i     := 1
   local aDisp := aclone(aRecv)
   local nFiel := fEnum(aRecv,"idnr")
   local cData := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // The choices
      if lastkey() == K_DOWN

         // Display list of animals
         if cLanType() == "A"
            cData := sm3idnu(3,,,"LYS VAN DIERE","SM3DATA",aGets[nFiel]:varget())
         else
            cData := sm3idnu(3,,,"LIST OF ANIMALS","SM3DATA",aGets[nFiel]:varget())
         endif
         if !empty(cData)
            aGets[nFiel]:varput(cData)
            aGets[nFiel]:updatebuffer()
         else
            lRetu := .f.
            break
         endif

      elseif empty(aGets[nFiel]:varget())

         // No number given - exit to browse
         keyboard chr(K_ESC)
         lRetu := .f.
         break

      endif

      // Locate data
      select SM3DATA
      seek aGets[nFiel]:varget()
      if eof()

         // Animal not in file -  do not allow
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Dier bestaan nie in die hooflˆer nie!")
         else
            fScrBood(maxrow()-1,"Animal does not exist in the main file!")
         endif
         fScrWait(maxrow())
         lRetu := .f.
         break

      endif

   end

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWnumber

   // Function to control entry to the number of generations

   // Declare
   local lRetu := .t.

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Tik die AANTAL GENERASIES wat gemerk moet word!")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu")
      fScrBood(maxrow()  ,"Type the NUMBER OF GENERATIONS to be marked!")
   endif

return lRetu
