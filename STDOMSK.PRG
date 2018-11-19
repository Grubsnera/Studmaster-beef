// Application: StudMaster for Beef Cattle
//   File Name: STDCONV.PRG
// Description: Program to convert any .dbf file to the correct structure
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-23-94      02:52:48pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "dbstruct.ch"

/******************************************************************************/
FUNCTION stdconv(cPath,cFile,cExte,aStru,cMess,lScrn)

   // Declare
   local lRetu := .f.
   local cTxtf := ""
   local aCdbf := fATopen()
   local aFile := {}
   local lConv := .f.
   local i     := 0
   local aPoin := {}
   local cSeek := ""
   local j     := 0
   local cData := ""
   local nReko := 0
   local cCarr := ""
   local cDeli := chr(232)
   local aCarg := {}
   local nLowe := 0
   local nUppe := 0
   local nData := 0

   begin sequence

      // Values
      cPath := if(cPath==NIL,"",cPath)
      cExte := if(cExte==NIL,"DBF",cExte)
      cMess := if(cMess==NIL,cFile,cMess)
      lScrn := if(lScrn==NIL,.t.,lScrn)
      cTxtf := cPath+"CONV.TXT"

      // Test the file
      if !file(cPath+cFile+"."+cExte)

         //File does not exist - create

         // Screen message
         if lScrn
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWbood(maxrow(),cMess+" lˆer word geskep")
            else
               fScrBood(maxrow()-1)
               fScrWbood(maxrow(),cMess+" file being created")
            endif
         endif

         // Create the file
         dbcreate(cPath+cFile+"."+cExte,aStru)
         if file(cPath+cFile+"."+cExte)
            lRetu := .t.
         endif

      else

         // File does exist

         // Do not open index automatically
         cmxAutoOpen(.f.)

         // Open the file
         aCdbf := fATopen(aCdbf,cPath,cFile,,cExte,"OLD",.f.)

         // Open index automatically
         cmxAutoOpen(.t.)

         // If problem opening file
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif

         // Get the file structure
         aFile := dbstruct()

         // Convert if field length is not the same
         if len(aStru) <> len(aFile)
            lConv := .t.
         endif

         // Test structure if field lenths is the same
         if !lConv
            for i := 1 to len(aStru)
               // Fieldname
               if upper(aStru[i,DBS_NAME]) <> upper(aFile[i,DBS_NAME])
                  lConv := .t.
                  exit
               endif
               // Field type
               if upper(aStru[i,DBS_TYPE]) <> upper(aFile[i,DBS_TYPE])
                  lConv := .t.
                  exit
               endif
               // Field lenth
               if aStru[i,DBS_LEN] <> aFile[i,DBS_LEN]
                  lConv := .t.
                  exit
               endif
               // Field decimal
               if aStru[i,DBS_DEC] <> aFile[i,DBS_DEC]
                  lConv := .t.
                  exit
               endif
            next
         endif

         // If to be converted
         if lConv

            // Create new file if no records
            if lastrec() == 0
               fATclose(aCdbf)
               asize(aCdbf,len(aCdbf)-1)
               ferase(cPath+cFile+"."+cExte)
               if lScrn
                  if cLanType() == "A"
                     fScrBood(maxrow()-1)
                     fScrWbood(maxrow(),cMess+" lˆer word geskep")
                  else
                     fScrBood(maxrow()-1)
                     fScrWbood(maxrow(),cMess+" file being created")
                  endif
               endif
               dbcreate(cPath+cFile+"."+cExte,aStru)
               if file(cPath+cFile+"."+cExte)
                  lRetu := .t.
                  break
               endif
            endif

            // Screen
            if lScrn
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWbood(maxrow(),cMess+" lˆer word omgeskakel")
               else
                  fScrBood(maxrow()-1)
                  fScrWbood(maxrow(),cMess+" file being converted")
               endif
            endif

            // Build a second array same as new file with field pointer to old file
            for i = 1 to len(aStru)
               aadd(aPoin,0)
               cSeek := upper(aStru[i,DBS_NAME])
               // Seek field name in old file
               for j = 1 to len(aFile)
                  if cSeek == upper(aFile[j,DBS_NAME])
                     aPoin[i] := j
                     exit
                  endif
               next
            next

            // Create temp file
            dbcreate(cPath+"CONV.DBF",aStru)

            // Open temp file
            aCdbf := fATopen(aCdbf,cPath,"CONV",,"DBF","NEW",.f.)
            if !aCdbf[len(aCdbf),1]
               lRetu := .f.
               break
            endif

            // Loop the old file
            select OLD
            go top
            do while !eof()

               // Cancel deleted files
               if deleted()
                  select OLD
                  skip
                  loop
               endif

               nReko++

               // Screen
               setcolor(cColBott())
               if cLanType() == "A"
                  @maxrow()-1,35 say fPercent(recno(),lastrec())+"% Voltooi"
               else
                  @maxrow()-1,35 say fPercent(recno(),lastrec())+"% Completed"
               endif
               setcolor(cColNorm())

               // Empty the cargo array
               aCarg := {}

               for i := 1 to len(aStru)

                  // See if field exist
                  if aPoin[i] > 0

                     // Pointer exist so get data

                     // Convert all data to character
                     do case
                        case aFile[aPoin[i],DBS_TYPE] == "N"
                           // Numeric
                           if empty(fieldget(aPoin[i]))
                              aadd(aCarg,"")
                           else
                              aadd(aCarg,ltrim(str(fieldget(aPoin[i]),aFile[aPoin[i],DBS_LEN],aFile[aPoin[i],DBS_DEC])))
                           endif
                        case aFile[aPoin[i],DBS_TYPE] == "D"
                           // Date
                           if empty(fieldget(aPoin[i]))
                              aadd(aCarg,"")
                           else
                              aadd(aCarg,dtos(fieldget(aPoin[i])))
                           endif
                        otherwise
                           // Character
                           if empty(fieldget(aPoin[i]))
                              aadd(aCarg,"")
                           else
                              aadd(aCarg,fieldget(aPoin[i]))
                           endif
                     endcase

                  else

                     // Pointer does not exist - create new
                     aadd(aCarg,"")

                  endif

               next

               // Store the data in new file
               select NEW
               dbappend()
               for i := 1 to len(aStru)

                  if !empty(aCarg[i])
                     do case

                        case aStru[i,DBS_TYPE] == "N"
                           // Numeric
                           nData := val(aCarg[i])
                           cData := repl("9",aStru[i,DBS_LEN])
                           if aStru[i,DBS_DEC] > 0
                              cData := strtran(cData,"9",".",aStru[i,DBS_LEN]-aStru[i,DBS_DEC],1)
                           endif
                           nUppe := val(cData)
                           cData := strtran(cData,"9","-",1,1)
                           nLowe := val(cData)
                           if nData >= nLowe .and. nData <= nUppe
                              fieldput(i,nData)
                           endif

                        case aStru[i,DBS_TYPE] == "D"
                           // Date
                           fieldput(i,stod(aCarg[i]))

                        otherwise
                           // Character
                           fieldput(i,aCarg[i])

                     endcase


                  endif

               next

               // Next record
               select OLD
               skip

            enddo

            // Was correct number of records read
            select NEW
            if lastrec() <> nReko
               if cLanType() == "A"
                  fScrBood(maxrow()-1,cMess+" aantal rekords nie korrek gelees!")
               else
                  fScrBood(maxrow()-1,cMess+" number of records read incorrectly!")
               endif
               fScrWait(maxrow())
               break
            endif

            // Delete old file
            fATclose(aCdbf)

            // Rename the file
            ferase(cPath+"TEMP.DBF")
            frename(cPath+cFile+"."+cExte,cPath+"TEMP.DBF")
            ferase(cPath+cFile+"."+cExte)
            if frename(cPath+"CONV.DBF",cPath+cFile+"."+cExte) == -1
               cPath+cFile+"."+cExte
               frename(cPath+"TEMP.DBF",cPath+cFile+"."+cExte)
               if cLanType() == "A"
                  fScrBood(maxrow()-1,cMess+" nie geskep nie!")
               else
                  fScrBood(maxrow()-1,cMess+" not created!")
               endif
               fScrWait(maxrow())
               break
            endif

            lRetu := .t.

         else

            // Pack file
            if lScrn
               fScrBood(maxrow()-1)
               if cLanType() == "A"
                  fScrWbood(maxrow(),cMess+" lˆer word gekompakteer")
               else
                  fScrWbood(maxrow(),cMess+" file being packed")
               endif
            endif

            // Pack the file
            pack

            lRetu := .t.

         endif

      endif

   end

   // Reset

return lRetu
