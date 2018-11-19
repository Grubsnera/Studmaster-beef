// Application: StudMaster for Beef Cattle
//   File Name: STDREEK.PRG
// Description: Program to read the program serial number
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-22-94      06:06:43am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdreek

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aDbfs := {}
   local cData := ""
   local nData := 0
   local cFile := "STDREEK"
   local cCryp := "JNR"
   local lLoop := .t.
   local aMenu := {}
   local cReek := space(10)
   local nBoxc := 0
   cReeNomm("")
   begin sequence

      // Dbf array
      aadd(aDbfs,{"waard1","C",10,0})
      aadd(aDbfs,{"waard2","C",20,0})
      aadd(aDbfs,{"waard3","C", 8,0})
      aadd(aDbfs,{"waard4","C", 4,0})
      aadd(aDbfs,{"waard5","C", 2,0})

      // Test serial number file structure
      if cLanType() == "A"
         if !stdconv("",cFile,"tdb",aDbfs,"Reeksnommer",.f.)
            lRetu := .f.
            break
         endif
      else
         if !stdconv("",cFile,"tdb",aDbfs,"Serial number",.f.)
            lRetu := .f.
            break
         endif
      endif

      // Open file
      aCdbf := fATopen(aCdbf,,"STDREEK",,"tdb","STDREEK")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // Append if no records
      if lastrec() == 0
         dbappend()
      endif

      // Read and save the serial number from the text file
      if file("serial.txt")

         cData := filestr("serial.txt",10,,.t.)

         if len(trim(cData)) > 0 .and. rlock()
            STDREEK->waard1 := crypt(padr(trim(cData),10),cCryp)
            dbunlock()
         endif

         ferase("serial.txt")

      endif

      // Fill the static with serial number
      if !empty(STDREEK->waard1)
         cReeNomm(ALLTRIM(crypt(ALLTRIM(STDREEK->waard1),cCryp)))
      else
         if cLanType() == "A"
            fScrBood( maxrow()-1, "[Esc]=Terug" )
            fScrBood( maxrow()  , "Tik asseblief die program se reeksnommer soos voor in die handleiding." )
            nBoxc := fBoxCent(11, "Reeksnommer? xxxxxxxxxx", 3)
            setcolor(cColNorm())
            set curs on
            @12,nBoxc say "Reeksnommer?" get cReek pict "@!"
         else
            fScrBood( maxrow()-1, "[Esc]=Back" )
            fScrBood( maxrow()  , "Please type the program serial number as in the front of the manual." )
            nBoxc := fBoxCent(11, "Serial number? xxxxxxxxxx", 3)
            setcolor(cColNorm())
            set curs on
            @12,nBoxc say "Serial number?" get cReek pict "@!"
         endif
         read
         set curs off
         if lastkey() = K_ESC
            lRetu := .f.
            break
         endif
         // Default to demo program
         if left(cReek,3) == "SMA" .and. val(substr(cReek,4,4)) > 1 .and. val(substr(cReek,4,4)) <= 9999 .or. ;
               left(cReek,3) == "SME" .and. val(substr(cReek,4,4)) > 1 .and. val(substr(cReek,4,4)) <= 9999
         else
            if cLanType() == "A"
               cReek := padr("SMA0000",10)
            else
               cReek := padr("SME0000",10)
            endif
         endif
         if len(trim(cReek)) > 0 .and. rlock()
            STDREEK->waard1 := crypt(padr(trim(cReek),10),cCryp)
            dbunlock()
            cReeNomm(ALLTRIM(crypt(ALLTRIM(STDREEK->waard1),cCryp)))
         else
            lRetu := .f.
            break
         endif
      endif


   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

   // Change file date and time stamps
   setfdati(cFile+".tdb",filedate(exename()),filetime(exename()))

return lRetu
