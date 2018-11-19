// Program to convert Anglo American Farms data
// 12-19-94 04:33am

// Needed to run
// The file amf213.dbf must be in the current directory

// Declare
local aDbfs := {}
local cDate := ""

// Environment
set talk off
set date japan
clear screen

begin sequence

   // Create a text file of the amf213 file
   @ 1,5 say "AM Farms Data Conversion"
   @ 2,5 say "------------------------"
   @ 4,5 say " 1) Create main text file."
   dbusearea(.t.,,"amf213")
   copy to amf213 delimited
   dbcloseall()

   // Create a file with studmaster field names to read this text file
   @ 5,5 say " 2) Read the main text file."
   aadd(aDbfs,{"id"          ,"C",12, 0})
   aadd(aDbfs,{"reknr"       ,"C",12, 0})
   aadd(aDbfs,{"kalfbnr"     ,"C", 8, 0})
   aadd(aDbfs,{"bloedlyn"    ,"C", 2, 0})
   aadd(aDbfs,{"generasie"   ,"C", 2, 0})
   aadd(aDbfs,{"pa"          ,"C",12, 0})
   aadd(aDbfs,{"ma"          ,"C",12, 0})
   aadd(aDbfs,{"gebdatumc"   ,"C", 6, 0})
   aadd(aDbfs,{"icp"         ,"N", 4, 0})
   aadd(aDbfs,{"geslag"      ,"C", 1, 0})
   aadd(aDbfs,{"gebmassa"    ,"N", 2, 0})
   aadd(aDbfs,{"mamoergeb"   ,"N", 3, 0})
   aadd(aDbfs,{"gma100"      ,"N", 3, 0})
   aadd(aDbfs,{"ind100"      ,"N", 3, 0})
   aadd(aDbfs,{"gma205"      ,"N", 3, 0})
   aadd(aDbfs,{"ind205"      ,"N", 3, 0})
   aadd(aDbfs,{"mamoerspe"   ,"N", 3, 0})
   aadd(aDbfs,{"fasekode"    ,"C", 6, 0})
   aadd(aDbfs,{"evalgrp"     ,"C", 4, 0})
   aadd(aDbfs,{"gma365"      ,"N", 3, 0})
   aadd(aDbfs,{"ind365"      ,"N", 3, 0})
   aadd(aDbfs,{"gma540"      ,"N", 3, 0})
   aadd(aDbfs,{"ind540"      ,"N", 3, 0})
   aadd(aDbfs,{"voeromset"   ,"N", 8, 3})
   aadd(aDbfs,{"voeromseti"  ,"N", 3, 0})
   aadd(aDbfs,{"gekeur"      ,"C", 1, 0})
   aadd(aDbfs,{"uitkrede"    ,"C", 2, 0})
   aadd(aDbfs,{"uitkdatumc"  ,"C", 6, 0})
   aadd(aDbfs,{"idnaam"      ,"C",35, 0})
   aadd(aDbfs,{"idnr"        ,"C",12, 0})
   aadd(aDbfs,{"idvaar"      ,"C",12, 0})
   aadd(aDbfs,{"idmoer"      ,"C",12, 0})
   aadd(aDbfs,{"gebdatum"    ,"D", 8, 0})
   aadd(aDbfs,{"uitkdatum"   ,"D", 8, 0})
   aadd(aDbfs,{"gdtind"      ,"N", 3, 0})
   aadd(aDbfs,{"gdoind"      ,"N", 3, 0})
   dbcreate("sm3data",aDbfs)
   dbusearea(.t.,,"sm3data")
   append from amf213 delimited

   // Convert the data in a loop
   go top
   do while !eof()

      @ 6,5 say " 3) Data being converted. "+ltrim(str(recno()))+"/"+ltrim(str(lastrec()))

      // In no id number - delete
      if empty(SM3DATA->id)
         delete
         skip
         loop
      endif

      // Id nommers
      SM3DATA->idnr   := fIdnr(SM3DATA->id)
      SM3DATA->idvaar := fIdnr(SM3DATA->pa)
      SM3DATA->idmoer := fIdnr(SM3DATA->ma)

      // Geboortedatum
      if !empty(SM3DATA->gebdatumc)
         cDate := substr(SM3DATA->gebdatumc,1,2)
         cDate += "/"
         cDate += substr(SM3DATA->gebdatumc,3,2)
         cDate += "/"
         cDate += substr(SM3DATA->gebdatumc,5,2)
         SM3DATA->gebdatum := ctod(cDate)
      endif

      // Uit kudde datum
      if !empty(SM3DATA->uitkdatumc)
         cDate := substr(SM3DATA->uitkdatumc,1,2)
         cDate += "/"
         cDate += substr(SM3DATA->uitkdatumc,3,2)
         cDate += "/"
         cDate += substr(SM3DATA->uitkdatumc,5,2)
         SM3DATA->uitkdatum := ctod(cDate)
      endif

      // Gekeur
      if !empty(SM3DATA->gekeur)
         if SM3DATA->gekeur == "G"
            SM3DATA->gekeur := "J"
         elseif SM3DATA->gekeur == "A"
            SM3DATA->gekeur := "N"
         else
            SM3DATA->gekeur := " "
         endif
      endif

      // Waar is dier kode
      if !empty(SM3DATA->uitkrede)
         if "I" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "IK"
         elseif "V" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "VE"
         elseif "K" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "KI"
         elseif "D" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "DO"
         elseif "S" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "SL"
         elseif "U" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "UI"
         elseif "A" $ SM3DATA->uitkrede
            SM3DATA->uitkrede := "AB"
         else
            SM3DATA->uitkrede := "  "
         endif
      endif

      // Fasekode
      if "C" $ SM3DATA->fasekode .or. ;
            "D" $ SM3DATA->fasekode
         SM3DATA->gdtind := SM3DATA->ind365
         SM3DATA->gdoind := SM3DATA->ind540
         SM3DATA->gma365 := 0
         SM3DATA->ind365 := 0
         SM3DATA->gma540 := 0
         SM3DATA->ind540 := 0
      else
         SM3DATA->fasekode := "      "
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
