// SIMDATA.PRG
// Program om prestasiedata te onttrek
// 01-06-19 10:07

// Variable declaration
local cDryf := "C:\SM3"
local lLoop := .t.
local aMenu := {}
local nChoi := 1
local cNaam := ""
local cFile := ""
local nHand := 1
local nVoor := 0
local nSpee := 0
local nJaar := 0
local nAgtt := 0

// Environment
set date brit
clear screen
begin sequence

   @5,5 say "SIMMENTALER/SIMBRA PRESTASIEDATA-ONTTREKKING"
   @6,5 say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

   do while lLoop

      cDryf := left(trim(cDryf)+space(40),40)

      @8,5 say "StoetMeester Programlˆers?" get cDryf pict "@!"
      read

      // Escape
      if lastkey() == 27 .or. empty(cDryf)
         break
      endif

      // See if stddryf exist
      if !(file(trim(cDryf)+"\STDDRYF.DBF"))
         @10,5 say "StoetMeester programlˆers nie gevind!"
         @11,5 say "Druk enige sleutel..."
         inkey(0)
         loop
      endif

      lLoop := .f.

   enddo

   // Get the data drives
   dbusearea(.t.,,trim(cDryf)+"\STDDRYF.DBF")
   do while !eof()
      aadd(aMenu,STDDRYF->datadr)
      skip
   enddo
   dbcloseall()

   if len(aMenu) < 1
      @10,5 say "StoetMeester datalˆers nie gevind!"
      @11,5 say "Druk enige sleutel..."
      inkey(0)
      break
   elseif len(aMenu) == 1
      cDryf := trim(aMenu[1])
   else
      clear screen
      @5,5 say "SIMMENTALER/SIMBRA PRESTASIEDATA-ONTTREKKING"
      @6,5 say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      @8,5 say "Kies asseblief die datastel waarvan data voorberei moet word"
      @9,5 say "met die op- en afpyltjies en druk dan Enter."
      nChoi := achoice(11,5,15,40,aMenu)
      if nChoi < 1
         @17,5 say "StoetMeester datalˆers nie gekies!"
         @18,5 say "Druk enige sleutel..."
         inkey(0)
         break
      endif
      cDryf := trim(aMenu[nChoi])
   endif

   // Get the herd details
   dbusearea(.t.,,cDryf+"\STDWAAR.DBF")
   cNaam := upper(trim(STDWAAR->genaam))
   cFile := "P"+trim(STDWAAR->raskod)+trim(STDWAAR->kudkkl)+".txt"
   dbcloseall()

   // Screen
   clear screen
   @ 5,5 say "SIMMENTALER/SIMBRA PRESTASIEDATA-ONTTREKKING"
   @ 6,5 say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   @ 7,5 say cNaam
   @ 9,5 say " Voorspeendata: "+ltrim(str(nVoor))
   @10,5 say "     Speendata: "+ltrim(str(nSpee))
   @11,5 say "      Jaardata: "+ltrim(str(nJaar))
   @12,5 say "18 Maande data: "+ltrim(str(nAgtt))

   // Open the main data file
   dbusearea(.t.,,cDryf+"\SM3DATA.DBF")

   // Open the text file
   set alternate to (cFile)
   set alternate on
   set console off

   // Heading
   ?? "CompNo,"
   ?? "Phase,"
   ?? "Group,"
   ?? "Date,"
   ?? "Mass,"
   ?? "Code,"
   ?? "DamMassBirth,"
   ?? "DamMassWean"
   ?

   // Loop the file
   do while !eof()

      // Only look for animals with registration numbers
      if val(SM3DATA->reknr) > 0

         // Voorspeendata
         if !empty(SM3DATA->dat100) .and. !empty(SM3DATA->mas100)
            ?? ltrim(str(val(SM3DATA->reknr)))+","
            ?? "A1,"
            ?? trim(SM3DATA->indekskode)+","
            ?? dtos(SM3DATA->dat100)+","
            ?? ltrim(str(SM3DATA->mas100))+","
            ?? trim(SM3DATA->kod100)+","
            ?? ","
            ?
            nVoor++
         endif

         // Speendata
         if !empty(SM3DATA->dat205) .and. !empty(SM3DATA->mas205)
            ?? ltrim(str(val(SM3DATA->reknr)))+","
            ?? "A2,"
            ?? trim(SM3DATA->indekskode)+","
            ?? dtos(SM3DATA->dat205)+","
            ?? ltrim(str(SM3DATA->mas205))+","
            ?? trim(SM3DATA->kod205)+","
            if !empty(SM3DATA->mamoergeb)
               ?? ltrim(str(SM3DATA->mamoergeb))+","
            else
               ?? ","
            endif
            if !empty(SM3DATA->mamoerspe)
               ?? ltrim(str(SM3DATA->mamoerspe))
            endif
            ?
            nSpee++
         endif

         // Jaardata
         if !empty(SM3DATA->dat365) .and. !empty(SM3DATA->mas365)
            ?? ltrim(str(val(SM3DATA->reknr)))+","
            ?? "B1,"
            ?? trim(SM3DATA->indekskode)+","
            ?? dtos(SM3DATA->dat365)+","
            ?? ltrim(str(SM3DATA->mas365))+","
            ?? trim(SM3DATA->kod365)+","
            ?? ","
            ?
            nJaar++
         endif

         // 18 Maande data
         if !empty(SM3DATA->dat540) .and. !empty(SM3DATA->mas540)
            ?? ltrim(str(val(SM3DATA->reknr)))+","
            ?? "B2,"
            ?? trim(SM3DATA->indekskode)+","
            ?? dtos(SM3DATA->dat540)+","
            ?? ltrim(str(SM3DATA->mas540))+","
            ?? trim(SM3DATA->kod540)+","
            ?? ","
            ?
            nAgtt++
         endif

      endif

      // Display
      set alternate off
      set console on
      @ 9,5 say " Voorspeendata: "+ltrim(str(nVoor))
      @10,5 say "     Speendata: "+ltrim(str(nSpee))
      @11,5 say "      Jaardata: "+ltrim(str(nJaar))
      @12,5 say "18 Maande data: "+ltrim(str(nAgtt))
      set console off
      set alternate on

      // Next record
      skip

   enddo


   // Close the file
   set console on
   set alternate off
   set alternate to

   // Last screen message
   @14,5 say "Stuur asseblief hierdie disket terug aan die Genootskap."
   @15,5 say "Baie dankie vir u moeite."
   @16,5 say "Druk enige sleutel..."
   inkey(0)
   @17,5 say ""

end

// End the program
return NIL
