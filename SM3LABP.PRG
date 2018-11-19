//SM3LABP.PRG
//Program om adresetikette te druk
//Kopiereg (c) 1992 A van Rensburg
//18:27 10 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3labp( nReko )

   //Die leer kliexxxx.dbf moet reeds bestaan met die adreskodes van die persone
   //om te druk

   //Verklaar
   local GetList := {}
   local cTemp   := ""
   local cLede   := ""
   local cLabe   := ""
   local i       := 0
   local j       := 0
   local nTest   := 1
   local aLine[10]
   local nCh     := 1
   local nLeng   := 80

   private cData := ""
   private cCarr := ""

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Open data
   cLabe := fTOpen( cDd(), "sm3labe", , "dbf", , .t., .f. )
   if left( cLabe, 1 ) == "f"
      return NIL
   endif
   goto nReko
   cLede := fTOpen( cDd(), "sm3klie", , "dbf", , .t., .f. )
   if left( cLede, 1 ) == "f"
      fTClose( cLabe )
      return NIL
   endif
   cTemp := fTOpen( cDd(), "sm3temp",, "dbf","sm3temp" , .f., .f. )
   if left( cTemp, 1 ) == "f"
      fTClose( cLabe )
      fTClose( cLede )
      return NIL
   endif

   //Stel relation
   set relation to SM3TEMP->KODE into SM3KLIE

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Adresplakkers word gedruk")
   else
      fScrWbood(24,"Address labels being printed")
   endif

   fPrnOn()
   if SM3LABE->latype == "C"
      fPrnCod( cPrnCond() )
      nLeng := 130
   elseif SM3LABE->latype == "W"
      fPrnCod( cPrnNorm() )
      nLeng := 40
   else
      fPrnCod( cPrnNorm() )
      nLeng := 80
   endif
   fPrnOff()

   //Die loop
   do while !eof()

      setcolor( cColBott() )
      if cLanType() == "A"
         @23,35 say str((recno()/lastrec())*100,3,0)+"% voltooi"
      else
         @23,35 say str((recno()/lastrec())*100,3,0)+"% completed"
      endif
      setcolor( cColNorm() )

      for i = 1 to SM3LABE->laaccr

         //Maak skoon
         if i == 1
            aLine := afill(aLine, space(SM3LABE->lastar) )
         endif

         //Indien einde van leer
         if eof()
            exit
         endif

         //Bou die lyne
         for j = 1 to SM3LABE->laheig
            cCarr := padl(ltrim(str(j,2,0)),2,"0")
            if len(trim(SM3LABE->lali&cCarr)) > 0
               cData := trim(SM3LABE->lali&cCarr)
               aLine[j] += padr( &cData, SM3LABE->lawidt ) + space(SM3LABE->lacolb)
            endif
         next

         //Volgende rekord
         select SM3TEMP
         skip
      next
      set print on
      set cons off
      for j = 1 to SM3LABE->laheig
         if SM3LABE->latype == "W"
            // &cPrnWide + aLine[j]
            ? &(cPrnNorm()) + aLine[j]
         else
            ? padl(aLine[j],nLeng)
         endif
      next
      for j = 1 to SM3LABE->labetw
         ? ""
      next
      set cons on
      set print off

      //Breek indien nodig
      if inkey() == K_ESC
         select SM3TEMP
         go bottom
      endif

      //Toets of reg
      if nTest == 1
         nCh := fNewMenu( nCh, "SM3LABP" )
         if cLanType() == "A"
            do case
               case nCh == 1
                  nTest++
               case nCh == 2
                  select SM3TEMP
                  go top
                  fScrBood(23,"Stel die plakkers reg asseblief!")
                  fScrWait(24)
               otherwise
                  select SM3TEMP
                  go bottom
                  skip
            endcase
         else
            do case
               case nCh == 1
                  nTest++
               case nCh == 2
                  select SM3TEMP
                  go top
                  fScrBood(23,"Please set the labels correctly!")
                  fScrWait(24)
               otherwise
                  select SM3TEMP
                  go bottom
                  skip
            endcase
         endif

         //Skerm
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Adresplakkers word gedruk")
         else
            fScrWbood(24,"Address labels being printed")
         endif

      endif

   enddo

   fPrnOn()
   fPrnCod( cPrnNorm() )
   fPrnOff()

   //Herstel
   fTClose( cLabe )
   fTClose( cTemp )
   fTClose( cLede )
return NIL

