// IDSPLIT.PRG
// Program to split the id number into three parts
// 03-15-99 08:30am

// Declare
local i := 0
local cChar := ""
local cNume := ""

// Environment
set date brit
set conf off
clear screen

@ 1, 0 say "Id nommer split"
@ 2, 0 say "==============="

// Open dbf
use sm3data

//Loop
do while !eof()

   // Variables
   cChar := ""
   cNume := ""

   // Screen
   @ 4, 2 say "Rekord # " + ltrim(str(recno()))

   // Save id number in the michip field
   if empty(sm3data->michip)
      sm3data->michip := sm3data->idnr
   endif

   // Remove all characters
   for i := 1 to len(trim(sm3data->idnr))

      if isalpha(substr(sm3data->idnr,i,1))
         // Remove the characters
         cChar += substr(sm3data->idnr,i,1)
      elseif isdigit(substr(sm3data->idnr,i,1))
         // Remove the numerics
         cNume += substr(sm3data->idnr,i,1)
      endif

   next

   // See if number correspond with the date of birth
   if left(cNume,2) == substr(dtos(sm3data->gebdatum),3,2)
      // If same, normal id number
      sm3data->kuddek := cChar
      sm3data->jaarle := left(cNume,2)
      sm3data->volgno := ltrim(str(val(substr(cNume,3,len(cNume)-2))))
   else
      // Not the same, year letter
      sm3data->kuddek := left(cChar,len(cChar)-1)
      sm3data->jaarle := right(cChar,1)
      sm3data->volgno := ltrim(str(val(cNume)))
   endif

   // Next record
   skip

enddo

dbcloseall()

return NIL
