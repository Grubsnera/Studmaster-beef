//SM3CREA.PRG
//Program om stoetmeester data om te skakel
//Kopiereg (C) 1992 A van Rensburg
//15:09 13 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3crea

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cFiln := ""
   local cIndn := ""
   local aFiel := {}
   local cData := ""
   local lCont := .t.
   local cVel1 := ""
   local cVel2 := ""
   local cVel3 := ""
   local cVeld := ""

   //Teelseisoene********************************/

   //Kyk of dekleer bestaan
   if file(cDd()+"sm3dekk.dbf") .and. !file(cDd()+"sm3teeg.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Teelseisoene word uitgesoek")
      else
         fScrWbood(24,"Breeding seasons being sorted")
      endif

      //Kyk of leer bestaan
      cFiln := cDd()+"sm3teeg.dbf"
      if !file(cFiln)
         //Skep teelseisoenleer
         asize(aFiel,0)
         aadd(aFiel,{"kode","C", 6,0})
         aadd(aFiel,{"besk","C",20,0})
         dbcreate(cFiln,aFiel)
      endif

      //Open .dbf
      ferase(cDd()+"sm3teeg"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3teeg")
      if neterr()
         dbcloseall()
      else

         //Indeks leer
         cIndn := cDd()+"sm3teeg"+ordbagext()
         index on sm3teeg->kode to (cIndn)

         //Open dekleer
         dbusearea(.t.,,cDd()+"sm3dekk")
         if neterr()
            dbcloseall()
         else
            //Loop deur hele leer
            do while !eof()
               cData := SM3DEKK->teelgroep
               if len(alltrim(cData)) > 0
                  select SM3TEEG
                  seek cData
                  if eof()
                     append blank
                     do while !rlock()
                     enddo
                     SM3TEEG->kode := cData
                  endif
                  select SM3DEKK
               endif
               skip
            enddo
            dbcloseall()

         endif

      endif

   endif

   //Herstel
   dbcloseall()

   //Seleksiegroepe - indeks ********************/

   //Kyk of selgroep bestaan
   if file(cDd()+"sm3seli.dbf")                  //.and. !file(cDd()+"sm3selg.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Seleksiegroepe word uitgesoek")
      else
         fScrWbood(24,"Selection groups being sorted")
      endif

      //Kyk of leer bestaan
      cFiln := cDd()+"sm3selg.dbf"
      if !file(cFiln)
         //Skep teelseisoenleer
         asize(aFiel,0)
         aadd(aFiel,{"kode" ,"C",  6,0})
         aadd(aFiel,{"besk" ,"C", 60,0})
         aadd(aFiel,{"veld1","C",800,0})
         aadd(aFiel,{"veld2","C",800,0})
         aadd(aFiel,{"veld3","C",800,0})
         dbcreate(cFiln,aFiel)
      endif

      //Open .dbf
      ferase(cDd()+"sm3selg"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3selg")
      if neterr()
         dbcloseall()
      else

         //Indeks leer
         cIndn := cDd()+"sm3selg"+ordbagext()
         index on sm3selg->kode to (cIndn)

         //Open dekleer
         dbusearea(.t.,,cDd()+"sm3seli")
         if neterr()
            dbcloseall()
         else
            //Loop deur hele leer
            do while !eof()

               cData := SM3SELI->snr


               if len(alltrim(cData)) > 0
                  select SM3SELG
                  seek cData
                  if eof()
                     append blank
                     do while !rlock()
                     enddo
                     SM3SELG->kode := cData
                     SM3SELG->besk := SM3SELI->sbesk
                  endif
                  select SM3SELI
               endif
               skip
            enddo
            dbcloseall()
            ferase(cDd()+"sm3seli.dbf")
         endif

      endif

   endif

   //Herstel
   dbcloseall()


   //Seleksiegroepe - vereistes *****************/

   //Kyk of selgroep bestaan
   if file(cDd()+"sm3sele.dbf") .and. ;
         file(cDd()+"sm3veld.dbf") .and. ;
         file(    "stdfiel.tdb") .and. ;
         file(cDd()+"sm3selg.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Seleksiegroepe word uitgesoek")
      else
         fScrWbood(24,"Selection groups being sorted")
      endif

      //Open .dbf
      ferase(cDd()+"sm3sele"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3sele")
      if neterr()
         dbcloseall()
         lCont := .f.
      else
         //Indeks leer
         cIndn := cDd()+"sm3sele"+ordbagext()
         index on sm3sele->snr to (cIndn)
         set index to (cIndn)
      endif

      if lCont
         //Open .dbf
         ferase(cDd()+"sm3selg"+cIndeExt())
         dbusearea(.t.,,cDd()+"sm3selg")
         if neterr()
            dbcloseall()
            lCont := .f.
         else
            //Indeks leer
            cIndn := cDd()+"sm3selg"+ordbagext()
            index on sm3selg->kode to (cIndn)
            set index to (cIndn)
         endif
      endif

      if lCont
         //Open .dbf
         ferase(cDd()+"stdfie1"+cIndeExt())
         dbusearea(.t.,,"stdfiel.tdb")
         if neterr()
            dbcloseall()
            lCont := .f.
         else
            //Indeks leer
            cIndn := "stdfie1"+ordbagext()
            index on stdfiel->dbfname+stdfiel->fldname to (cIndn)
            set index to (cIndn)
         endif
      endif

      if lCont
         //Open .dbf
         dbusearea(.t.,,cDd()+"sm3veld")
         if neterr()
            dbcloseall()
            lCont := .f.
         endif
      endif

      if lCont

         //Die loop
         cData := " "
         cVel1 := ""
         cVel2 := ""
         cVel3 := ""
         select SM3SELE
         go top
         do while !eof()

            //Volgende seleksiegroep
            if SM3SELE->snr <> cData

               if len(alltrim(cVel1)) > 0
                  //Bewaar die velde
                  select SM3SELG
                  seek cData
                  if found()
                     do while !rlock()
                     enddo
                     SM3SELG->veld1 := padr(cVel1,800)
                     SM3SELG->veld2 := padr(cVel2,800)
                     SM3SELG->veld3 := padr(cVel3,800)
                  endif
               endif
               cData := SM3SELE->snr
               cVel1 := ""
               cVel2 := ""
               cVel3 := ""
            endif

            //Bou veld 1 - Veldname
            if len(alltrim(SM3SELE->vnr)) == 3 .and. val(SM3SELE->vnr) >= 1 .and. val(SM3SELE->vnr) <= 111
               //Kry die veldnaam
               select SM3VELD
               goto val(SM3SELE->vnr)
               cVel1+= "SM3DATA   " + SM3VELD->veldnaam
               cVeld := "SM3DATA " + SM3VELD->veldnaam
            else
               select SM3SELE
               skip
               loop
            endif

            //Bou veld 2
            //Gaan na die regte veldbesonderhede
            select STDFIEL
            seek cVeld
            if eof()
               cVel1 := left(cVel1,len(cVel1)-20)
               select SM3SELE
               skip
               loop
            endif
            cVeld := ""
            //Operators
            if len(alltrim(SM3SELE->vro)) == 0
               cVel1 := left(cVel1,len(cVel1)-20)
               select SM3SELE
               skip
               loop
            else
               cVeld := SM3SELE->vro
            endif
            //Logics
            if SM3SELE->vlo == "O"
               cVeld+= ".or. "
            elseif SM3SELE->vlo $ "AEX"
               cVeld+= ".and."
            else
               cVel1 := left(cVel1,len(cVel1)-20)
               select SM3SELE
               skip
               loop
            endif
            //Veldbesonderhede
            cVeld+= STDFIEL->fldtype
            cVeld+= str(STDFIEL->fldleng,3,0)
            cVeld+= str(STDFIEL->flddeci,3,0)
            cVeld := padr(cVeld,20)
            cVel2+= cVeld

            //Bou veld 3 - Veranderlike
            if len(alltrim(SM3SELE->vve)) > 0
               cVel3+= upper(SM3SELE->vve)
            else
               cVel1 := left(cVel1,len(cVel1)-20)
               cVel2 := left(cVel2,len(cVel2)-20)
               select SM3SELE
               skip
               loop
            endif

            select SM3SELE
            skip

         enddo
         dbcloseall()
         ferase(cDd()+"sm3sele.dbf")
      endif

   endif

   //Herstel
   dbcloseall()

   //Indeksgroepe********************/

   //Kyk of dekleer bestaan
   if file(cDd()+"sm3data.dbf") .and. !file(cDd()+"sm3indg.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Indeksgroepe word uitgesoek")
      else
         fScrWbood(24,"Index groups being sorted")
      endif

      //Kyk of leer bestaan
      cFiln := cDd()+"sm3indg.dbf"
      if !file(cFiln)
         //Skep indeksgroepe
         asize(aFiel,0)
         aadd(aFiel,{"kode","C", 6,0})
         aadd(aFiel,{"besk","C",20,0})
         dbcreate(cFiln,aFiel)
      endif

      //Open .dbf
      ferase(cDd()+"sm3indg"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3indg")
      if neterr()
         dbcloseall()
      else

         //Indeks leer
         cIndn := cDd()+"sm3indg"+ordbagext()
         index on sm3indg->kode to (cIndn)

         //Open dekleer
         dbusearea(.t.,,cDd()+"sm3data")
         if neterr()
            dbcloseall()
         else
            //Loop deur hele leer
            do while !eof()
               cData := SM3DATA->indekskode
               if len(alltrim(cData)) > 0
                  select SM3INDG
                  seek cData
                  if eof()
                     append blank
                     do while !rlock()
                     enddo
                     SM3INDG->kode := cData
                  endif
                  select SM3DATA
               endif
               skip
            enddo
            dbcloseall()

         endif

      endif

   endif

   //Herstel
   dbcloseall()

   //Fasegroepe********************/

   //Kyk of dekleer bestaan
   if file(cDd()+"sm3data.dbf") .and. !file(cDd()+"sm3fasg.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Fasegroepe word uitgesoek")
      else
         fScrWbood(24,"Phase groups being sorted")
      endif

      //Kyk of leer bestaan
      cFiln := cDd()+"sm3fasg.dbf"
      if !file(cFiln)
         //Skep indeksgroepe
         asize(aFiel,0)
         aadd(aFiel,{"kode","C", 6,0})
         aadd(aFiel,{"besk","C",20,0})
         dbcreate(cFiln,aFiel)
      endif

      //Open .dbf
      ferase(cDd()+"sm3fasg"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3fasg")
      if neterr()
         dbcloseall()
      else

         //Indeks leer
         cIndn := cDd()+"sm3fasg"+ordbagext()
         index on sm3fasg->kode to (cIndn)

         //Open dekleer
         dbusearea(.t.,,cDd()+"sm3data")
         if neterr()
            dbcloseall()
         else
            //Loop deur hele leer
            do while !eof()
               cData := SM3DATA->fasekode
               if len(alltrim(cData)) > 0
                  select SM3FASG
                  seek cData
                  if eof()
                     append blank
                     do while !rlock()
                     enddo
                     SM3FASG->kode := cData
                  endif
                  select SM3DATA
               endif
               skip
            enddo
            dbcloseall()

         endif

      endif

   endif

   //Herstel
   dbcloseall()

   //Eie verslae - indeks ********************/

   //Kyk of selgroep bestaan
   if file(cDd()+"sm3veri.dbf")                  //.and. !file(cDd()+"sm3eiev.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Eie verslae word uitgesoek")
      else
         fScrWbood(24,"Own reports being sorted")
      endif

      //Kyk of leer bestaan
      cFiln := cDd()+"sm3eiev.dbf"
      if !file(cFiln)
         //Skep eie verslae leer
         asize(aFiel,0)
         aadd(aFiel,{"kode","C",  6,0})
         aadd(aFiel,{"besk","C", 60,0})
         aadd(aFiel,{"veld","C",800,0})
         dbcreate(cFiln,aFiel)
      endif

      //Open .dbf
      ferase(cDd()+"sm3eiev"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3eiev")
      if neterr()
         dbcloseall()
      else

         //Indeks leer
         cIndn := cDd()+"sm3eiev"+ordbagext()
         index on sm3eiev->kode to (cIndn)

         //Open leer
         dbusearea(.t.,,cDd()+"sm3veri")
         if neterr()
            dbcloseall()
         else
            //Loop deur hele leer
            do while !eof()
               cData := SM3VERI->vnr

               //Verwyder default nageslagopsommings en stambome
               if cData == "NAGESL" .or. ;
                     cData == "PROGEN" .or. ;
                     cData == "STAMBO" .or. ;
                     cData == "PEDIGR"
                  skip
                  loop
               endif

               if len(alltrim(cData)) > 0
                  select SM3EIEV
                  seek cData
                  if eof()
                     append blank
                     do while !rlock()
                     enddo
                     SM3EIEV->kode := cData
                     SM3EIEV->besk := SM3VERI->vbesk
                  endif
                  select SM3VERI
               endif
               skip
            enddo
            dbcloseall()
            ferase(cDd()+"sm3veri.dbf")
         endif

      endif

   endif

   //Herstel
   dbcloseall()


   //Eie verslae - vereistes *****************/

   //Kyk of selgroep bestaan
   if file(cDd()+"sm3vers.dbf") .and. ;
         file(cDd()+"sm3veld.dbf") .and. ;
         file(cDd()+"sm3eiev.dbf") .and. ;
         file(cDd()+"sm3eiev"+ordbagext())

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Eie verslae word uitgesoek")
      else
         fScrWbood(24,"Own reports being sorted")
      endif

      //Open .dbf
      ferase(cDd()+"sm3vers"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3vers")
      if neterr()
         dbcloseall()
         lCont := .f.
      else
         //Indeks leer
         cIndn := cDd()+"sm3vers"+ordbagext()
         index on sm3vers->vnr to (cIndn)
         set index to (cIndn)
      endif

      if lCont
         //Open .dbf
         dbusearea(.t.,,cDd()+"sm3eiev")
         if neterr()
            dbcloseall()
            lCont := .f.
         else
            //Indeks leer
            //cIndn := cDd()+"sm3eiev"+ordbagext()
            //set index to (cIndn)
         endif
      endif

      if lCont
         //Open .dbf
         dbusearea(.t.,,cDd()+"sm3veld")
         if neterr()
            dbcloseall()
            lCont := .f.
         endif
      endif

      if lCont

         //Die loop
         cData := " "
         cVel1 := ""
         select SM3VERS
         go top
         do while !eof()

            //Volgende seleksiegroep
            if SM3VERS->vnr <> cData

               if len(alltrim(cVel1)) > 0
                  //Bewaar die velde
                  select SM3EIEV
                  seek cData
                  if found()
                     do while !rlock()
                     enddo
                     SM3EIEV->veld := padr(cVel1,800)
                  endif
               endif
               cData := SM3VERS->vnr
               cVel1 := ""
            endif

            //Bou veld 1 - Veldname
            if len(alltrim(SM3VERS->vveld)) == 3 .and. val(SM3VERS->vveld) >= 1 .and. val(SM3VERS->vveld) <= 111
               //Kry die veldnaam
               select SM3VELD
               goto val(SM3VERS->vveld)
               cVel1+= "SM3DATA   " + SM3VELD->veldnaam
            else
               select SM3VERS
               skip
               loop
            endif

            select SM3VERS
            skip

         enddo
         dbcloseall()
         ferase(cDd()+"sm3vers.dbf")
      endif

   endif

   //Herstel
   dbcloseall()

   //Tydelike merke********************/

   //Kyk of tydelike merke leer bestaan
   if file(cDd()+"sm3data.dbf") .and. !file(cDd()+"sm3merk.dbf")

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Tydelike merke word uitgesoek")
      else
         fScrWbood(24,"Temporary marks being selected")
      endif

      //Kyk of leer bestaan
      cFiln := cDd()+"sm3merk.dbf"
      if !file(cFiln)
         //Skep indeksgroepe
         asize(aFiel,0)
         aadd(aFiel,{"kode","C", 2,0})
         aadd(aFiel,{"besk","C",60,0})
         aadd(aFiel,{"aant","N", 4,0})
         dbcreate(cFiln,aFiel)
      endif

      //Open .dbf
      ferase(cDd()+"sm3merk"+cIndeExt())
      dbusearea(.t.,,cDd()+"sm3merk")
      if neterr()
         dbcloseall()
      else

         //Indeks leer
         cIndn := cDd()+"sm3merk"+ordbagext()
         index on sm3merk->kode to (cIndn)

         //Open dataleer
         dbusearea(.t.,,cDd()+"sm3data")
         if neterr()
            dbcloseall()
         else
            //Loop deur hele leer
            do while !eof()
               cData := SM3DATA->toggle1
               if len(alltrim(cData)) > 0
                  select SM3MERK
                  seek cData
                  if eof()
                     append blank
                     do while !rlock()
                     enddo
                     SM3MERK->kode := cData
                     SM3MERK->aant++
                  else
                     do while !rlock()
                     enddo
                     SM3MERK->aant++
                  endif
                  select SM3DATA
               endif
               skip
            enddo
            dbcloseall()

         endif

      endif

   endif

   //Herstel
   dbcloseall()

return NIL

