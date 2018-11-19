// Program to convert Anglo American Farms data
// 12-19-94 11:52am

// Needed to run
// The file amfkd.dbf must be in the current directory

// Declare
local aDbfs := {}
local cDate := ""

// Environment
set talk off
set date japan
clear screen

begin sequence

   // Create a text file of the amf213 file
   @ 1,5 say "AM Farms Data Matings"
   @ 2,5 say "---------------------"
   @ 4,5 say " 1) Create main text file."
   dbusearea(.t.,,"amfkd")
   copy to amfkd delimited
   dbcloseall()

   // Create a file with studmaster field names to read this text file
   @ 5,5 say " 2) Read the main text file."
   aadd(aDbfs,{"id"          ,"C",10, 0})
   aadd(aDbfs,{"d01"         ,"C", 9, 0})
   aadd(aDbfs,{"d02"         ,"C", 9, 0})
   aadd(aDbfs,{"d03"         ,"C", 1, 0})
   aadd(aDbfs,{"d04"         ,"C", 2, 0})
   aadd(aDbfs,{"d05"         ,"C",10, 0})
   aadd(aDbfs,{"d06"         ,"C",10, 0})
   aadd(aDbfs,{"d07"         ,"C", 6, 0})
   aadd(aDbfs,{"d08"         ,"N", 1, 0})
   aadd(aDbfs,{"d09"         ,"C", 1, 0})
   aadd(aDbfs,{"d10"         ,"C", 1, 0})
   aadd(aDbfs,{"vaarkode"    ,"C", 1, 0})
   aadd(aDbfs,{"d11"         ,"C", 2, 0})
   aadd(aDbfs,{"pa"          ,"C", 9, 0})
   aadd(aDbfs,{"dekin"       ,"C", 6, 0})
   aadd(aDbfs,{"dekuit"      ,"C", 6, 0})
   aadd(aDbfs,{"dragtig"     ,"C", 1, 0})
   aadd(aDbfs,{"gekalf"      ,"C", 1, 0})
   aadd(aDbfs,{"teelgroep"   ,"C", 6, 0})
   aadd(aDbfs,{"idmoer"      ,"C",12, 0})
   aadd(aDbfs,{"idvaar"      ,"C",12, 0})
   aadd(aDbfs,{"datumin"     ,"D", 8, 0})
   aadd(aDbfs,{"datumuit"    ,"D", 8, 0})
   dbcreate("sm3dekk",aDbfs)
   dbusearea(.t.,,"sm3dekk")
   append from amfkd delimited

   // Convert the data in a loop
   go top
   do while !eof()

      @ 6,5 say " 3) Data being converted. "+ltrim(str(recno()))+"/"+ltrim(str(lastrec()))

      // In no id number - delete
      if empty(SM3DEKK->id)
         delete
         skip
         loop
      endif

      // Id nommers
      SM3DEKK->idmoer := fIdnr(SM3DEKK->id)
      SM3DEKK->idvaar := fIdnr(SM3DEKK->pa)

      // Datumin
      if !empty(SM3DEKK->dekin)
         cDate := substr(SM3DEKK->dekin,1,2)
         cDate += "/"
         cDate += substr(SM3DEKK->dekin,3,2)
         cDate += "/"
         cDate += substr(SM3DEKK->dekin,5,2)
         SM3DEKK->datumin := ctod(cDate)
      endif

      // Datumuit
      if !empty(SM3DEKK->dekuit)
         cDate := substr(SM3DEKK->dekuit,1,2)
         cDate += "/"
         cDate += substr(SM3DEKK->dekuit,3,2)
         cDate += "/"
         cDate += substr(SM3DEKK->dekuit,5,2)
         SM3DEKK->datumuit := ctod(cDate)
      else
         SM3DEKK->datumuit := SM3DEKK->datumin
      endif

      // Vaarkode
      if !empty(SM3DEKK->vaarkode)
         if SM3DEKK->vaarkode == "N"
            SM3DEKK->vaarkode := "1"
         elseif SM3DEKK->vaarkode == "K"
            SM3DEKK->vaarkode := "3"
         else
            SM3DEKK->vaarkode := " "
         endif
      endif

      // Dragtig
      if !empty(SM3DEKK->dragtig)
         if SM3DEKK->dragtig == "+"
            SM3DEKK->dragtig := "*"
         else
            SM3DEKK->dragtig := " "
         endif
      endif

      // Gekalf
      if !empty(SM3DEKK->gekalf)
         if SM3DEKK->gekalf == "J"
            SM3DEKK->gekalf := "*"
         else
            SM3DEKK->gekalf := " "
         endif
      endif

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
