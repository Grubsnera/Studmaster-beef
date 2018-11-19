//SM3DECA.PRG
//Program om dragtigheidsyfers te bereken
//Kopiereg (c) 1992 A van Rensburg
//115:49 11 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3deca(cFind)

   //Veranderlikes
   local cCscr := savescreen(23,0,24,79)
   local lRetu := .f.
   local cDekk := ""
   local cHoof := ""
   local cData := ""

   //Verklaar - private standaardveranderlikes
   private nOudeer := 365
   private nRustyd := 30
   private nNordra := 274
   private nMindra := 266
   private nMakdra := 308
   private nSiklus := 21
   private nDaedra := 60
   private cKalfst := "01"
   private cKalfge := "09"
   private cIdenti := "16  "
   private cSubafd := "  "
   private cTipies := "  "
   private cBreekk := "-"

   //Dekwaardes word opgesoek
   fScrBood(23)
   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
      fScrWbood(24,"Standaardwaardes word gelees")
   else
      fScrOpsk(1,"Option "+cOption())
      fScrWbood(24,"Default values being read")
   endif

   cDekk := fTOpen(cDd(),"sm3rass",,,,.t.,.f.)
   if left(cDekk,1) == "f"
      return NIL
   endif
   locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
   if !eof()
      nOudeer := SM3RASS->oudeer
      nRustyd := SM3RASS->rustyd
      nNordra := SM3RASS->nordra
      nMindra := SM3RASS->mindra
      nMakdra := SM3RASS->makdra
      nSiklus := SM3RASS->siklus
      nDaedra := SM3RASS->daedra
      cKalfst := SM3RASS->kalfst
      cKalfge := SM3RASS->kalfge
      cIdenti := SM3RASS->identi
      cSubafd := SM3RASS->subafd
      cTipies := SM3RASS->tipies
      cBreekk := SM3RASS->breekk
   endif
   fTClose(cDekk)

   //Open dataleers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Opening data files")
   endif

   cHoof := fTOpen(cDd(),"sm3data")
   if left( cHoof, 1 ) == "f"
      return lRetu
   endif

   cDekk := fTOpen(cDd(),"sm3dekk")
   if left( cDekk, 1 ) == "f"
      fTClose(cHoof)
      return lRetu
   endif
   set order to 2

   //Skuif die databasis
   if cFind == NIL
      if cLanType() == "A"
         fScrBood(23,"Kalfseisoen onbekend!")
      else
         fScrBood(23,"Calving season unknown!")
      endif
      fScrWait(24)
      fTClose(cHoof)
      fTClose(cDekk)
      return lRetu
   else
      seek cFind
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Geen inligting vir die kalfseisoen kon gevind word nie!")
         else
            fScrBood(23,"No information could be found for the calving season!")
         endif
         fScrWait(24)
         fTClose(cHoof)
         fTClose(cDekk)
         return lRetu
      endif
   endif

   //Soek diere
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kalfseisoen se berekeninge word gedoen!")
   else
      fScrWbood(24,"Calving season calculations being done!")
   endif

   //Die loop
   select SM3DEKK
   do while SM3DEKK->teelgroep == cFind

      setcolor(cColBott())
      lRetu := .t.
      @23,35 say SM3DEKK->idmoer
      setcolor(cColNorm())

      //Toets datumin wel bestaan
      if SM3DEKK->datumin == ctod("")
         skip
         loop
      endif

      //Sluit die rekord
      do while !rlock()
      enddo

      //Maak alle nul
      SM3DEKK->idnr   := space(12)
      SM3DEKK->gebdat := ctod("")
      SM3DEKK->kalwer := 0
      SM3DEKK->speenn := 0
      SM3DEKK->waaris := 0
      if empty(SM3DEKK->datumuit)
         SM3DEKK->datumuit := SM3DEKK->datumin
      endif

      //Koei
      cData := SM3DEKK->idmoer

      //Kyk of koei nageslag het in hoofleer
      select SM3DATA
      set order to 4
      seek cData
      do while SM3DATA->idmoer == cData

         //Kyk na data en besluit of dit die kalf is
         if SM3DATA->idvaar   == SM3DEKK->idvaar            .and. ;
               SM3DATA->gebdatum >= SM3DEKK->datumin+nMindra   .and. ;
               SM3DATA->gebdatum <= SM3DEKK->datumuit+nMakdra
            SM3DEKK->idnr   := SM3DATA->idnr
            SM3DEKK->gebdat := SM3DATA->gebdatum
            SM3DEKK->gedra  := SM3DATA->gebdatum - SM3DEKK->datumin
            SM3DEKK->kalwer++
            if SM3DATA->ind205 > 0
               SM3DEKK->speenn++
            endif
            if SM3DATA->uitkrede $ cWaarisd()
               SM3DEKK->waaris++
            endif
            if SM3DEKK->datumin == SM3DEKK->datumuit // Save gestation period in case of AI, INOV or Hand service
               do while ! SM3DATA->(rlock())
               enddo
               SM3DATA->gestation := SM3DEKK->gedra
            endif

            // Kalf is gebore maar pa verskil
         elseif SM3DATA->gebdatum >= SM3DEKK->datumin+nMindra .and. ;
               SM3DATA->gebdatum <= SM3DEKK->datumuit+nMakdra
            if cLanType() == "A"
               SM3DEKK->remark := "Kalf '"+alltrim(SM3DATA->idnr)+"' se pa '"+alltrim(SM3DATA->idvaar)+"' verskil van die bul mee gedek"
            else
               SM3DEKK->remark := "Sire '"+alltrim(SM3DATA->idvaar)+"' of calf '"+alltrim(SM3DATA->idnr)+"' differ from service sire"
            endif
            // Kalf is gebore maar buite die maksimum tydperk
         elseif SM3DATA->gebdatum > SM3DEKK->datumin .and. ;
               SM3DATA->gebdatum <= SM3DEKK->datumin+365
            if cLanType() == "A"
               SM3DEKK->remark := "Kalf '"+alltrim(SM3DATA->idnr)+"' is "+str(SM3DATA->gebdatum-SM3DEKK->datumin)+" dae na die dekking gebore"
            else
               SM3DEKK->remark := "Calf '"+alltrim(SM3DATA->idnr)+"' is born "+str(SM3DATA->gebdatum-SM3DEKK->datumin)+" days after service"
            endif
         endif

         skip

      enddo
      set order to 1

      // Slegs een kalwing per koei per seisoen
      select SM3DEKK
      if SM3DEKK->kalwer > 0
         skip
         do while SM3DEKK->idmoer == cData
            skip
         enddo
      else
         skip
      endif

   enddo

   //Herstel
   fTClose(cHoof)
   fTClose(cDekk)
   restscreen(23,0,24,79)

return lRetu
