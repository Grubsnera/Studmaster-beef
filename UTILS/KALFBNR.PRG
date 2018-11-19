// Kalfbnr.prg
// Program om diere se kalfboeknommers toe te ken
// 01-04-24 16:29

// Hennie Snyman 01-04-24 16:29

local cLett := "  "
local nEers := 0
local nLaas := 0

set confirm on

begin sequence

   cls

   @ 5,5 say "Kalfboeknommertoekenning"
   @ 6,5 say "========================"

   @ 8,5 say "Lettergedeelte" get cLett pict "@!"
   @ 9,5 say "Eerste beskikbare nommer" get nEers pict "9999"
   @10,5 say "Laaste beskikbare nommer" get nLaas pict "9999"
   read

   if empty(cLett) .or. empty(nEers) .or. empty(nLaas)
      break
   endif

   use sm3data

   do while !(eof())

      if empty(sm3data->kalfbnr)
         if nEers <= nLaas
            sm3data->kalfbnr := trim(cLett)+padl(ltrim(str(nEers)),4,"0")
            @12,5 say sm3data->kalfbnr
            nEers++
         endif
      endif

      skip

   enddo

   use

end

quit
