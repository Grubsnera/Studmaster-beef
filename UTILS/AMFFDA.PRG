// Program to convert Anglo American Farms phase d data
// 12-19-94 10:57am

// Needed to run
// The file amffda.dbf must be in the current directory

// Declare
local aDbfs := {}
local cDate := ""

// Environment
set talk off
set date japan
clear screen

begin sequence

   // Create a text file of the amf213 file
   @ 1,5 say "AM Farms Phase D Data Conversion"
   @ 2,5 say "--------------------------------"
   @ 4,5 say " 1) Create main text file."
   dbusearea(.t.,,"amffda")
   copy to amffda delimited
   dbcloseall()

   // Create a file with studmaster field names to read this text file
   @ 5,5 say " 2) Read the main text file."
   aadd(aDbfs,{"id"          ,"C",10, 0})
   aadd(aDbfs,{"dum01"       ,"C", 3, 0})
   aadd(aDbfs,{"fasekode"    ,"C", 6, 0})
   aadd(aDbfs,{"dum02"       ,"C", 6, 0})
   aadd(aDbfs,{"dum03"       ,"C",10, 0})
   aadd(aDbfs,{"dum04"       ,"C",10, 0})
   aadd(aDbfs,{"dum05"       ,"C", 2, 0})
   aadd(aDbfs,{"dum06"       ,"N", 2, 0})
   aadd(aDbfs,{"dum07"       ,"N", 3, 0})
   aadd(aDbfs,{"begmassa"    ,"N", 3, 0})
   aadd(aDbfs,{"einmas"      ,"N", 3, 0})
   aadd(aDbfs,{"daeint"      ,"N", 3, 0})
   aadd(aDbfs,{"dum08"       ,"N", 3, 0})
   aadd(aDbfs,{"gdtgdt"      ,"N", 4, 0})
   aadd(aDbfs,{"voeromset"   ,"N", 8, 3})
   aadd(aDbfs,{"gdogdo"      ,"N", 4, 0})
   aadd(aDbfs,{"gdtind"      ,"N", 3, 0})
   aadd(aDbfs,{"voeromseti"  ,"N", 3, 0})
   aadd(aDbfs,{"gdoind"      ,"N", 3, 0})
   aadd(aDbfs,{"dum09"       ,"N", 3, 0})
   aadd(aDbfs,{"mateskouer"  ,"N", 4, 0})
   aadd(aDbfs,{"matelengte"  ,"N", 4, 0})
   aadd(aDbfs,{"veldikte"    ,"N", 4, 1})
   aadd(aDbfs,{"dum10"       ,"N", 3, 0})
   aadd(aDbfs,{"mateskrot"   ,"N", 3, 0})
   aadd(aDbfs,{"dum11"       ,"C", 3, 0})
   aadd(aDbfs,{"dum12"       ,"C", 1, 0})
   aadd(aDbfs,{"idnr"        ,"C",12, 0})
   dbcreate("oordata",aDbfs)
   dbusearea(.t.,,"oordata")
   append from amffda delimited

   // Convert the data in a loop
   go top
   do while !eof()

      @ 6,5 say " 3) Data being converted. "+ltrim(str(recno()))+"/"+ltrim(str(lastrec()))

      // In no id number - delete
      if empty(OORDATA->id)
         delete
         skip
         loop
      endif

      // Id nommers
      OORDATA->idnr   := fIdnr(OORDATA->id)

      // Next record
      skip

   enddo
   go top
   pack
   go top

   @ 7,5 say ""

end
// Close all files
dbcloseall()
quit

/****************************************************************************/
STATIC FUNCTION fIdnr(Id)

   // Function to convert id numbers

   // Declare
   local idnr := ""

   // Test if valid year letter number
   if    !empty(substr(id,1,4)) .and. ;
         empty(substr(id,5,1)) .and. ;
         isalpha(substr(id,6,1))

      idnr := alltrim(substr(id,1,4))
      idnr += substr(id,6,1)
      if val(substr(id,7,4)) <= 999
         idnr += padl(alltrim(str(val(substr(id,7,4)))),3,"0")
      else
         idnr += padl(alltrim(str(val(substr(id,7,4)))),4,"0")
      endif

   elseif !empty(substr(id,1,4)) .and. ;
         isdigit(substr(id,5,1)) .and. ;
         isdigit(substr(id,6,1))

      idnr := alltrim(substr(id,1,4))
      idnr += substr(id,5,2)
      idnr += "-"
      if val(substr(id,7,4)) <= 999
         idnr += padl(alltrim(str(val(substr(id,7,4)))),3,"0")
      else
         idnr += padl(alltrim(str(val(substr(id,7,4)))),4,"0")
      endif

   else

      idnr := alltrim(id)

   endif

return idnr
