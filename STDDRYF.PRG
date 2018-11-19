// Application: StudMaster for Beef Cattle
//   File Name: STDDRYF.PRG
// Description: Program to display and choose data drives
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-22-94      05:32:27am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stddryf(cDryf)

   // Declare
   local cRetu := ""
   local lNewf := .f.
   local aDbfs := {}
   local aCdbf := fATopen()
   local nBoxc := 0
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local nKeyp := 0
   local lSeek := .t.

   begin sequence

      // Screen
      fScrOpsk()

      // Create file
      if !file("STDDRYF.DBF")
         copy file STDDRYF.tdb to STDDRYF.DBF
         lNewf := .t.
      endif

      // Dbf array
      aadd(aDbfs,{"datadr","C",30,0})
      aadd(aDbfs,{"toggle","C", 1,0})
      aadd(aDbfs,{"waarde","N",10,0})
      aadd(aDbfs,{"aantal","N", 3,0})

      // Test file structure
      if cLanType() == "A"
         if !stdconv("","STDDRYF","DBF",aDbfs,"Datadryf",.f.)
            break
         endif
      else
         if !stdconv("","STDDRYF","DBF",aDbfs,"Data drive",.f.)
            break
         endif
      endif

      // Open drives file
      aCdbf := fATopen(aCdbf,,"STDDRYF")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // If new file read DATADBF.TXT created by install program
      if lNewf .and. file("DATADBF.TXT")
         if flock()
            append from datadbf.txt deli
            go top
            dbunlock()
         endif
      endif

      // Remove marks to enable file integrity checks
      if file("NEWDRYF.tdb")
         if flock()
            repl all STDDRYF->toggle with "*"
            go top
            dbunlock()
            ferase("NEWDRYF.tdb")
         endif
      endif

      // Display available drives
      if cLanType() == "A"
         nBoxc := fBoxCent(9,space(30),5,"DATADRYF")
      else
         nBoxc := fBoxCent(9,space(30),5,"DATA DRIVE")
      endif
      setcolor(cColNorm())

      // Build the tBrowse
      bBrow := TBrowsedb(9,nBoxc,13,nBoxc+30)

      // Define columns
      aadd(aCols,TBColumnNew(,{|| STDDRYF->datadr }))

      // Put columns in tBrowse object
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Main loop
      do while nKeyp <> K_ESC

         // Display the available drives
         if cLanType() == "A"
            fScrBood( maxrow()-1, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER )
            fScrBood( maxrow(), "[Ins]=Open 'n nuwe datadryf.  [Del]=Skrap 'n bestaande datadryf." )
         else
            fScrBood( maxrow()-1, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER )
            fScrBood( maxrow(), "[Ins]=Open a new data drive.  [Del]=Delete an existing data drive." )
         endif

         // Find the last data drive
         if lSeek .and. !empty(cDryf)
            lSeek := .f.
            do while !bBrow:hitbottom .and. trim(STDDRYF->datadr) <> cDryf
               bBrow:down()
               FullStabilize(bBrow)
            enddo
         endif

         // Stabilize
         FullStabilize(bBrow)

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ENTER
            // Enter means leave and update drive variable
            if fEnter()
               cRetu := trim(STDDRYF->datadr)
               if right(cRetu,1) <> "\"
                  cRetu += "\"
               endif
               cDd(cRetu)
               if lTestDbf()
                  set cons off
                  set alternate to (cRetu+"FILEINTE.TXT")
                  set alternate on
                  ?? "Do file integrity checks!"+chr(13)+chr(10)
                  set alternate off
                  set alternate to
                  set cons on
               endif
               keyboard chr(K_ESC)
            endif

         elseif nKeyp == K_DEL
            // Delete a drive
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKeyp == K_INS
            // Create a new data drive
            if fInsert()
               bBrow:refreshall()
            endif

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

   // Reset
   fATclose( aCdbf )

return cRetu

/******************************************************************************/
STATIC FUNCTION fEnter

   // Function to enter on a new data drive

   // Declare
   local lRetu := .f.
   begin sequence

      // Set file integrity check
      lTestDbf(.f.)

      // Test if dir exist
      lRetu := o_direxist( trim( STDDRYF->datadr ) )

      if lRetu

         // Do not allow a root directory
         if len(trim(STDDRYF->datadr)) <= 3
            lRetu := .f.
            break
         endif

         // Set the test data file structure flag
         if STDDRYF->toggle == "*"
            if rlock()
               STDDRYF->toggle := " "
               lTestDbf(.t.)
            endif
            dbunlock()
         endif

         lRetu := .t.

      else

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Die DATADRYF bestaan nie!")
         else
            fScrBood(maxrow()-1,"The DATA DRIVE does not exist!")
         endif
         fScrWait(maxrow())

      endif

   end

   // Reset

return lRetu

/******************************************************************************/
STATIC FUNCTION fDelete

   // Funtion to delete the current data drive

   // Declare
   local lRetu := .f.
   local cMess := ""

   // Ask to delete
   if cLanType() == "A"
      cMess := "Skrap die verligte datadryf?"
   else
      cMess := "Delete the highlighted data drive?"
   endif

   if fJaNee(maxrow(),cMess)
      if rlock()
         lRetu := .t.
         delete
         skip
         if eof()
            go bottom
         endif
         dbunlock()
      endif
   endif

   // Reset

return lRetu

/******************************************************************************/
STATIC FUNCTION fInsert

   // Function to insert a new data drive route

   // Declare
   local getlist := {}
   local lRetu := .f.
   local aCscr := fASavescr()
   local nBoxc := 0
   local lLoop := .t.
   local cData := space(30)
   begin sequence

      // Display the box in which to ask the data drive
      if cLanType() == "A"
         nBoxc := fBoxCent(19,space(30),1,"NUWE DATADRYF")
      else
         nBoxc := fBoxCent(19,space(30),1,"NEW DATA DRIVE")
      endif

      // The loop to ask the new data drive
      lLoop := .t.
      do while lLoop

         // Fill keyboard with current drive specs
         if empty(cData)
            keyboard left(o_curpath(),3)
         endif

         // Screen message
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            fScrBood( maxrow(), "Tik 'n nuwe datadryf. Byvoorbeeld: C:\SM3 " )
         else
            fScrBood( maxrow(), "Type a new data drive. For example: C:\SM3 " )
         endif

         // The get
         @19,nBoxc get cData pict "@!"
         set cursor on
         read
         set cursor off

         // Escaped
         if lastkey() == K_ESC
            break
         endif

         // Empty
         if empty(cData)
            break
         endif

         // Drive letter
         if isalpha(left(cData,1)) .and. ;
               substr(cData,2,1) = ":" .and. ;
               substr(cData,3,1) = "\"
         else
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Die datadryf moet die begin met die dryfletter! (Byvoorbeeld C:\ of D:\ )")
            else
               fScrBood(maxrow()-1,"The data drive must start with the drive letter! (Example C:\ or D:\ )")
            endif
            fScrWait(maxrow())
            loop
         endif

         // Root directory
         if len(trim(cData)) >= 4
         else
            if trim(cData) == "A:\" .or. trim(cData) == "B:\"
            else
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"Die datadryf mag nie die hoofgids (root directory) van 'n hardeskyf wees nie!")
               else
                  fScrBood(maxrow()-1,"The data drive may not be the root directory of a hard disk!")
               endif
               fScrWait(maxrow())
               loop
            endif
         endif

         // No spaces allowed
         if at(" ",trim(cData)) > 0
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Geen spasies mag in die datadryf teenwoordig wees nie!")
            else
               fScrBood(maxrow()-1,"No spaces are allowed in the data drive!")
            endif
            fScrWait(maxrow())
            loop
         endif

         // Data drive may not end with a backslash
         if right(trim(cData),1) == "\" .and. len(trim(cData)) > 3
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Datadryf mag nie eindig met 'n '\' karakter nie!")
            else
               fScrBood(maxrow()-1,"Data drive may not end with a '\' character!")
            endif
            fScrWait(maxrow())
            loop
         endif

         // Length may not exceed eight characters
         if len(trim(cData)) > 2+numat("\",trim(cData))+(numat("\",trim(cData))*8)
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Subgidsname mag nie langer as agt (8) karakters wees nie!")
            else
               fScrBood(maxrow()-1,"Sub directory names may not exceed eight (8) characters!")
            endif
            fScrWait(maxrow())
            loop
         endif

         // Data drive already exists
         go top
         locate for STDDRYF->datadr = cData
         if !eof()
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Die datadryf bestaan reeds!")
            else
               fScrBood(maxrow()-1,"The Data drive already exists!")
            endif
            fScrWait(maxrow())
            loop
         endif

         // Make the directory
         lRetu := o_md(trim(cData))
         if !lRetu
            lRetu := o_direxist(trim(cData))
            if !lRetu
               //Indien roete reeds bestaan
               if cLanType() == "A"
                  fScrBood(maxrow()-1,"Die datadryf kan nie geskep word nie. Rede onbekend!" )
               else
                  fScrBood(maxrow()-1,"The data drive has not been created. Reason unknown!" )
               endif
               fScrWait(maxrow())
               loop
            endif
         endif

         // Save the entry
         lLoop := .f.
         dbappend()
         STDDRYF->datadr := cData
         STDDRYF->toggle := "*"
         dbunlock()

      enddo

   end
   // Reset
   fARestscr(aCscr)

return lRetu
