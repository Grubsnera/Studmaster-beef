local nReko := 0
local cIdnr := ""

clear screen
@ 5,5 say "Mark progeny program"
@ 6,5 say "~~~~~~~~~~~~~~~~~~~~"

use c:\herds\sm3\sm3data.dbf
index on idmoer to dam
set index to dam
do while !eof()

   @ 8,5 say "Animal " + ltrim(str(recno())) + " of " + ltrim(str(lastrec()))

   // Only marked records
   if SM3DATA->toggle1 == "WA"
      nReko := recno()
      cIdnr := SM3DATA->idnr
      seek cIdnr
      if found()
         do while SM3DATA->idmoer == cIdnr
            if SM3DATA->toggle1 <> "WA"
               SM3DATA->toggle1 := "WP"
            endif
            skip
         enddo
      endif
      goto nReko
   endif

   // Next record
   select sm3data
   skip

enddo

close all

@ 10,5 say "There you are Sue!"
@ 11,5 say "All the progeny of the WA marked animals were"
@ 12,5 say "marked with WP in the temporary mark field."

quit
