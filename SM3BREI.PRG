// Application: StudMaster for Beef Cattle
//   File Name: SM3BREI.PRG
// Description: Program to import Breedplan data
//   Copyright: (c) 2002 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-01-24      12:57:49

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3brei

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local nHand := 0
   local cMemb := ""
   local cData := ""
   local cAlph := ""
   local cNume := ""
   local cIdno := ""
   local cYear := ""
   local i     := 0
   local nReco := 0
   local nCoun := 1
   begin sequence

      // Member number
      cMemb := ltrim(str(val(substr(cTotNaam(),152,10))))

      // Ask the path to the import file
      cPath := cDd()+"H"+cMemb+".DAT"

      // Open the text import file
      aCdbf := fATopen(aCdbf,cDd(),"SM3IMPO",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap

      // Open the main data file
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      //set order to 14
      set order to 6

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
         break
      endif

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow(),"Registrasiedata word gelees...")
         fScrBood(maxrow()-1)
      else
         fScrBood(maxrow(),"Registration data being imported...")
         fScrBood(maxrow()-1)
      endif

      // Read the data until no more records
      // First record is a header
      dbselectarea("SM3IMPO")
      do while !(eof())


         // See if animal has valid registration number
         cData := SM3IMPO->text

         // Screen
         fScrBood(maxrow()-1,substr(cData,16,19))

         // See if animal already exist
         dbselectarea("SM3DATA")
         //seek padl(alltrim(substr(cData,129,10)),10,"0")
         seek padl(alltrim(substr(cData,35,9)),10,"0")
         if eof()
            // Create new record for animal
            dbappend()
         else
            // Do not save anything - skip animal
            // Next record

            //cData := freadstr(nHand,278)
            //loop

         endif

         // Save the data

         // Registration number
         SM3DATA->reknr := alltrim(substr(cData,129,10))

         // Id number
         SM3DATA->idsoc := alltrim(substr(cData,16,19))

         if cIdform() == "2"

            cIdno := alltrim(substr(cData,16,19))

         else

            cIdno := ""
            cAlph := ""
            cNume := ""
            altd()
            cIdno := alltrim(substr(cData,16,19))
            if substr(cTotNaam(),149,3) == "217"
               // Simbra
               if right(cIdno,1) $ "ABCD"
                  cIdno := left(cIdno,len(cIdno)-1)
               endif
               if right(cIdno,2) $ "F1zF2zF3zF4"
                  cIdno := left(cIdno,len(cIdno)-2)
               endif
            endif

            // First split alpha and numeric characters
            for i := 1 to len(cIdno)
               if isalpha(substr(cIdno,i,1))
                  cAlph += substr(cIdno,i,1)
               endif
               if isdigit(substr(cIdno,i,1))
                  cNume += substr(cIdno,i,1)
               endif
            next

            cYear := substr(cData,253,2)
            // Remove year from numerics
            if left(cNume,2) == cYear
               cNume := right(cNume,len(cNume)-2)
               cIdno := cAlph
               cIdno += cYear
               cIdno += "-"
               if val(cNume) <= 999
                  cIdno += padl(cNume,3,"0")
               else
                  cIdno += cNume
               endif
            else
               cYear := ""
               cIdno := cAlph
               if val(cNume) <= 999
                  cIdno += padl(cNume,3,"0")
               else
                  cIdno += cNume
               endif
            endif

            if alltrim(cIdno) == "00-000"
               cIdno := padl(ltrim(str(nCoun)),3,"0")
               nCoun++
            endif

         endif

         // See if id number already exist
         //nReco := recno()
         //set order to 1
         //go top
         //seek cIdno
         //if found()
         //   // Animal exist
         //   nCoun := 0
         //   do while cIdno == left(SM3DATA->idnr,len(cIdno))
         //      nCoun++
         //      skip
         //   enddo
         //   cIdno := cIdno + "/" + ltrim(str(nCoun))
         //   set order to 14
         //   goto nReco
         //else
         //   // Animal does not exist - carry on
         //   set order to 14
         //   goto nReco
         //endif

         SM3DATA->idnr  := cIdno
         SM3DATA->kuddek := cAlph
         SM3DATA->jaarle := alltrim(cYear)
         SM3DATA->volgno := alltrim(str(val(cNume)))

         // Name of animal
         cIdno := alltrim(substr(cData,62,20)) + " " + alltrim(substr(cData,82,20))
         cIdno := strtran(cIdno,"'")
         SM3DATA->idnaam := cIdno

         // Abri unique key
         SM3DATA->kalfbnr := ltrim(str(val(substr(cData,35,9))))

         // Sex
         cIdno := substr(cData,102,1)
         if cIdno == "M"
            SM3DATA->geslag := "2"
         elseif cIdno == "F"
            SM3DATA->geslag := "1"
         else
            SM3DATA->geslag := "3"
         endif

         // Approved
         cIdno := substr(cData,103,1)
         if cIdno $ "RY"
            if cLanType() == "A"
               SM3DATA->gekeur := "J"
            else
               SM3DATA->gekeur := "Y"
            endif
         elseif cIdno $ "CUN"
            SM3DATA->gekeur := "N"
         endif

         // How mated
         if substr(cData,106,1) == "Y"
            SM3DATA->vaarkode := "4"
         else
            if substr(cData,104,1) $ "YA"
               SM3DATA->vaarkode := "3"
            else
               SM3DATA->vaarkode := "1"
            endif
         endif

         // Blood lab number
         SM3DATA->bloednr := alltrim(substr(cData,108,8))

         // Animal type
         SM3DATA->type := left(alltrim(substr(cData,124,2)),1)

         // Twin with
         cIdno := left(alltrim(substr(cData,126,2)),1)
         if cIdno == "M"
            SM3DATA->tweeling := "2"
         elseif cIdno == "F"
            SM3DATA->tweeling := "1"
         endif

         // Generation
         SM3DATA->generasie := alltrim(substr(cData,128,1))
         if SM3DATA->generasie == "C "
            SM3DATA->generasie := "K "
         elseif SM3DATA->generasie == "1 "
            SM3DATA->generasie := "A "
         elseif SM3DATA->generasie == "2 "
            SM3DATA->generasie := "B "
         elseif SM3DATA->generasie == "3 "
            SM3DATA->generasie := "C "
         elseif SM3DATA->generasie == "4 "
            SM3DATA->generasie := "D "
         endif

         // After birth remark
         SM3DATA->nagebo := left(alltrim(substr(cData,142,4)),3)
         if SM3DATA->nagebo == "-1"
            SM3DATA->nagebo := ""
         endif

         // Sire
         SM3DATA->idvaar := ltrim(str(val(substr(cData,150,9))))

         // Dam
         SM3DATA->idmoer := ltrim(str(val(substr(cData,159,9))))

         // Recipient - carrier
         SM3DATA->skenker := ltrim(str(val(substr(cData,168,9))))

         // Foster Dam
         SM3DATA->draer := ltrim(str(val(substr(cData,177,9))))

         // Where is animal code
         cIdno := substr(cData,186,1)
         if empty(cIdno)
            if cLanType() == "A"
               SM3DATA->uitkrede := "IK"
            else
               SM3DATA->uitkrede := "IH"
            endif
         else
            SM3DATA->uitkrede := cIdno + cIdno
         endif

         // Date left herd
         SM3DATA->uitkdatum := convdate(substr(cData,187,8))
         if !(empty(SM3DATA->uitkdatum))
            if SM3DATA->uitkrede $ "IKzIH"
               SM3DATA->uitkrede := "DL"
            endif
         endif

         // Registration date
         SM3DATA->keurda := convdate(substr(cData,203,8))

         // Mating date
         SM3DATA->idatum := convdate(substr(cData,211,8))

         // Date of birth
         SM3DATA->gebdatum := convdate(substr(cData,251,8))

         // Date recorded
         SM3DATA->dataan := convdate(substr(cData,195,8))

         // Next record
         dbselectarea("SM3IMPO")
         skip

      enddo

      /*************************************************************************/
      // Parent's id numbers

      // Screen
      if cLanType() = "A"
         fScrBood(maxrow(),"Ouers se registrasiedata word gelees...")
         fScrBood(maxrow()-1)
      else
         fScrBood(maxrow(),"Parents registration data being imported...")
         fScrBood(maxrow()-1)
      endif

      // Calculate the parent id numbers
      select SM3DATA
      set order to 6
      go top
      do while !(eof())

         // Screen
         fScrBood(maxrow()-1,"SM3DATA->idnr")

         // Store the current record number
         nReco := recno()

         // Sire
         cData := padleft(alltrim(SM3DATA->idvaar),10,"0")
         if val(cData) > 0
            go top
            seek cData
            if found()
               cIdno := SM3DATA->idnr
            else
               //cIdno := ""
            endif
         else
            cIdno := ""
         endif
         goto nReco
         SM3DATA->idvaar := cIdno

         // Dam
         cData := padleft(alltrim(SM3DATA->idmoer),10,"0")
         if val(cData) > 0
            go top
            seek cData
            if found()
               cIdno := SM3DATA->idnr
            else
               cIdno := ""
            endif
         endif
         goto nReco
         SM3DATA->idmoer := cIdno

         // Next animals
         select SM3DATA
         skip

      enddo

      /************************************************************************/

      select SM3DATA
      set order to 14
      go top

      // Ask the path to the import file
      cPath := cDd()+"W"+cMemb+".DAT"

      if file(cPath)

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
               fScrBood(maxrow()-1,"Geen data kon gelees word vanaf die massaslˆer nie!")
            else
               fScrBood(maxrow()-1,"No data could be read from the weights file!")
            endif
            fScrWait(maxrow())
            break
         endif

         // Screen
         if cLanType() = "A"
            fScrBood(maxrow(),"Prestasiedata word gelees...")
            fScrBood(maxrow()-1)
         else
            fScrBood(maxrow(),"Performance data being imported...")
            fScrBood(maxrow()-1)
         endif

         // Read the data until no more records
         // First record is a header
         dbselectarea("SM3IMPO")
         do while !(eof())

            // See if animal has valid registration number
            cData := SM3IMPO->text

            // Screen
            fScrBood(maxrow()-1,substr(cData,1,19))

            // See if animal already exist
            dbselectarea("SM3DATA")
            seek padl(alltrim(substr(cData,20,19)),10,"0")
            if eof()
               // Next record
               dbselectarea("SM3IMPO")
               skip
               loop
            endif

            // Save the data

            if alltrim(substr(cData,56,3)) == "W2"

               // Wean

               // Date weighed
               SM3DATA->dat205 := convdate(substr(cData,42,8))

               // Mass
               SM3DATA->mas205 := val(substr(cData,50,6))

               // Management group
               SM3DATA->indekskode := alltrim(substr(cData,39,2))+alltrim(substr(cData,59,3))

            elseif alltrim(substr(cData,56,3)) == "W4"

               // Year

               // Date weighed
               SM3DATA->dat365 := convdate(substr(cData,42,8))

               // Mass
               SM3DATA->mas365 := val(substr(cData,50,6))

               // Management group
               SM3DATA->indekskode := alltrim(substr(cData,39,2))+alltrim(substr(cData,59,3))

            elseif alltrim(substr(cData,56,3)) == "W6"

               // 18 Months

               // Date weighed
               SM3DATA->dat540 := convdate(substr(cData,42,8))

               // Mass
               SM3DATA->mas540 := val(substr(cData,50,6))

               // Management group
               SM3DATA->indekskode := alltrim(substr(cData,39,2))+alltrim(substr(cData,59,3))

            endif

            // Next record
            dbselectarea("SM3IMPO")
            skip

         enddo



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
