// Screen

begin sequence

   clear screen
   @ 1,5 say "Id number convert"
   @ 2,5 say "~~~~~~~~~~~~~~~~~"

   // Build new id numbers in the main file
   use sm3data shared
   index on michip to sm3data
   set index to sm3data

   // Loop the main file to create new id numbers
   do while !eof()

      // Screen
      @ 3, 5 say "Build new id numbers... "      //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      do while !rlock()
      enddo
      if empty(sm3data->kuddek) .or. empty(sm3data->jaarle)
         sm3data->idnr := sm3data->michip
      else
         sm3data->idnr := trim(sm3data->kuddek)
         sm3data->idnr := trim(sm3data->idnr) + trim(sm3data->jaarle)
         if val(sm3data->jaarle) > 0 .or. sm3data->jaarle == "00"
            sm3data->idnr := trim(sm3data->idnr) + "-"
            if val(sm3data->volgno) <= 999
               sm3data->idnr := trim(sm3data->idnr) + padl(trim(sm3data->volgno),3,"0")
            else
               sm3data->idnr := trim(sm3data->idnr) + trim(sm3data->volgno)
            endif
         else
            if val(sm3data->volgno) <= 999
               sm3data->idnr := trim(sm3data->idnr) + padl(trim(sm3data->volgno),3,"0")
            else
               sm3data->idnr := trim(sm3data->idnr) + trim(sm3data->volgno)
            endif
         endif

         // Add generation
         //if trim(SM3DATA->generasie) == "A"
         //   SM3DATA->idnr := trim(SM3DATA->idnr) + "A"
         //elseif trim(SM3DATA->generasie) == "B"
         //   SM3DATA->idnr := trim(SM3DATA->idnr) + "B"
         //elseif trim(SM3DATA->generasie) == "C"
         //   SM3DATA->idnr := trim(SM3DATA->idnr) + "C"
         //elseif trim(SM3DATA->generasie) == "D"
         //   SM3DATA->idnr := trim(SM3DATA->idnr) + "D"
         //endif

      endif

      // Next record
      select sm3data
      skip

   enddo

   // Convert the dam/sire id numbers
   select sm3data
   go top
   use sm3data alias tobe shared new
   do while !eof()

      // Screen
      @ 4, 5 say "Convert dams/sires in the main file... " //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idmoer
      if found()
         if sm3data->(rlock())
            if empty(sm3data->geslag)
               sm3data->geslag := "1"
            endif
         endif
         if tobe->(rlock())
            tobe->idmoer := sm3data->idnr
         endif
      endif
      seek tobe->idvaar
      if found()
         if sm3data->(rlock())
            if empty(sm3data->geslag)
               sm3data->geslag := "2"
            endif
         endif
         if tobe->(rlock())
            tobe->idvaar := sm3data->idnr
         endif
      endif
      seek tobe->bulid
      if found()
         if tobe->(rlock())
            tobe->bulid := sm3data->idnr
         endif
      endif
      seek tobe->skenker
      if found()
         if tobe->(rlock())
            tobe->skenker := sm3data->idnr
         endif
      endif
      seek tobe->draer
      if found()
         if tobe->(rlock())
            tobe->draer := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the purchases file
   select sm3data
   go top
   use sm3aank alias tobe shared new
   do while !eof()

      // Screen
      @ 5, 5 say "Convert purchases file... "    //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the actions file
   select sm3data
   go top
   use sm3acti alias tobe shared new
   do while !eof()

      // Screen
      @ 6, 5 say "Convert actions file... "      //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the matings file
   select sm3data
   go top
   use sm3dekk alias tobe shared new
   do while !eof()

      // Screen
      @ 7, 5 say "Convert matings file... "      //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif
      seek tobe->idmoer
      if found()
         if tobe->(rlock())
            tobe->idmoer := sm3data->idnr
         endif
      endif
      seek tobe->idvaar
      if found()
         if tobe->(rlock())
            tobe->idvaar := sm3data->idnr
         endif
      endif
      seek tobe->donor
      if found()
         if tobe->(rlock())
            tobe->donor := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the matings summary file
   select sm3data
   go top
   use sm3deko alias tobe shared new
   do while !eof()

      // Screen
      @ 8, 5 say "Convert summary matings file... " //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idvaar
      if found()
         if tobe->(rlock())
            tobe->idvaar := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the inspections file
   select sm3data
   go top
   use sm3insp alias tobe shared new
   do while !eof()

      // Screen
      @ 9, 5 say "Convert inspections file... "  //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the notes file
   select sm3data
   go top
   use sm3note alias tobe shared new
   do while !eof()

      // Screen
      @10, 5 say "Convert notes file... "        //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the transfers file
   select sm3data
   go top
   use sm3oord alias tobe shared new
   do while !eof()

      // Screen
      @11, 5 say "Convert transfers file... "    //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the picklist file
   select sm3data
   go top
   use sm3pick alias tobe shared new
   do while !eof()

      // Screen
      @12, 5 say "Convert picklist file... "     //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the veterinary file
   select sm3data
   go top
   use sm3veea alias tobe shared new
   do while !eof()

      // Screen
      @13, 5 say "Convert veterinary file... "   //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the veterinary report file
   select sm3data
   go top
   use sm3veev alias tobe shared new
   do while !eof()

      // Screen
      @14, 5 say "Convert veterinary report file... " //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the sales catalogue file
   select sm3data
   go top
   use sm3veil alias tobe shared new
   do while !eof()

      // Screen
      @15, 5 say "Convert sales catalogue file... " //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the sales file
   select sm3data
   go top
   use sm3verk alias tobe shared new
   do while !eof()

      // Screen
      @16, 5 say "Convert sales file... "        //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the deletions file
   select sm3data
   go top
   use sm3vore alias tobe shared new
   do while !eof()

      // Screen
      @17, 5 say "Convert deletions file... "    //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

   // Convert the weighings file
   select sm3data
   go top
   use sm3weeg alias tobe shared new
   do while !eof()

      // Screen
      @18, 5 say "Convert weighings file... "    //+ ltrim( str( sm3data->recno() ) ) //+ "/" + ltrim( str( sm3data->lastrec() ) )

      select sm3data
      seek tobe->idnr
      if found()
         if tobe->(rlock())
            tobe->idnr := sm3data->idnr
         endif
      endif

      // Next record
      select tobe
      skip

   enddo
   dbclosearea()

end

dbcloseall()

return NIL
