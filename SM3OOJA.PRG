// Application: StudMaster for Beef Cattle
//   File Name: SM3OOJA.PRG
// Description: Program to transfer annual diary entries to diary
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-29-94      11:53:24am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3ooja

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local aCdbf := fATopen()
   local dDate := ctod("")
   local lExis := .f.
   begin sequence

      // Open the diary files
      aCdbf := fATopen(aCdbf,cDd(),"SM3KALE")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3JAAR")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // Loop to transfer the annual diary entries
      do while !eof()

         // Build the date
         if SM3JAAR->maandd = month(dAppDate())
            dDate := ctod(str(SM3JAAR->dagdag)+"/"+str(SM3JAAR->maandd)+"/"+left(dtos(dAppDate()),4))
         elseif SM3JAAR->maandd = month(dAppDate())+1
            dDate := ctod(str(SM3JAAR->dagdag)+"/"+str(SM3JAAR->maandd)+"/"+left(dtos(dAppDate()),4))
         elseif SM3JAAR->maandd = 1 .and. month(dAppDate())+1 = 13
            dDate := ctod(str(SM3JAAR->dagdag)+"/"+str(SM3JAAR->maandd)+"/"+str(val(left(dtos(dAppDate()),4))+1,4,0))
         else
            dDate := ctod("")
         endif

         // Add if date is not empty and entry does not exist
         if !empty(dDate)
            select SM3KALE
            seek dtos(dDate)
            if found()

               // Loop to see if entry does exist
               lExis := .f.
               do while !eof() .and. SM3KALE->datum == dDate
                  if upper(SM3KALE->handeling) == upper(SM3JAAR->handel)
                     lExis := .t.
                  endif
                  skip
               enddo

               // Add only if entry does not exist
               if !lExis
                  dbappend()
                  SM3KALE->datum := dDate
                  SM3KALE->handeling := SM3JAAR->handel
                  dbunlock()
               endif

            else

               // Add only if entry does not exist
               dbappend()
               SM3KALE->datum := dDate
               SM3KALE->handeling := SM3JAAR->handel
               dbunlock()

            endif

         endif

         // Next
         select SM3JAAR
         skip

      enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
