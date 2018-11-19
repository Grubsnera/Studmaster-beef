//SM3VOLL.PRG
//Program om enige dier se volle besonderhede te vertoon
//Kopiereg (c) 1993 A van Rensburg
//22:15 19 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//****************************************************************************/
FUNCTION sm3voll(cIdnr)

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local nMenu := 1
   local cTest := ""
   local cData := ""
   local aRecv := {}
   local nReko := 0
   local nMin  := 0

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   //Vertoon menu indien nommer nie gegee is nie
   if cIdnr == NIL
      cIdnr := space(12)
      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      endif
      // Kry opsienommer
      nMenu := fNewMenu(nMenu,"SM3VOLL")
      fScrBood(23)
      fScrBood(24)
      if nMenu == 0
         return NIL
      endif

      nMin++

      IF cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nMenu))
      ELSE
         fScrOpsk(1,"Option "+cOption(nMenu))
      ENDIF

   endif

   //Kry die groep of seleksiegroep
   if nMenu == 2
      //Groep
      cTest := sm3groe()
      if len(trim(cTest)) == 0
         if cLanType() == "A"
            fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
         else
            fScrWait(24,"No group selection requirements have been specified!")
         endif

         cOption(-nMin)
         return NIL
      endif
   elseif nMenu == 3
      //Seleksiegroep
      cTest := sm3selg()
      if len(trim(cTest)) == 0
         if cLanType() == "A"
            fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
         else
            fScrWait(24,"No selection group requirements have been specified!")
         endif

         cOption(-nMin)
         return NIL
      endif
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetDbf("sm3data")

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif

   //Wat nou
   if nMenu == 1
      //Een dier
      fDisplay(aRecv,cIdnr)
   else
      //Groep of seleksiegroep
      select SM3DATA
      go top
      do while !eof()

         nReko := recno()

         if &cTest

            if !fPrint(aRecv)
               select SM3DATA
               go bottom
               skip
               loop
            endif

         endif

         //Volgende dier
         select SM3DATA
         goto nReko
         skip
      enddo

   endif

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cData)
   fTClose(cCdbf)
   cOption(-nMin)

return NIL

//**************************************************************************/
STATIC FUNCTION fDisplay(aRecv,cIdnr)

   //Funksie om die nageslag opsomming te vertoon

   //Verklaar
   local nMore := 1
   local nKeyp := 0
   local nBoxc := 1
   local cOldi := ""

   //Skuif databasis
   select SM3DATA
   if cIdnr == space(12)
      go bottom
      skip
   else
      seek cIdnr
      if eof()
         cIdnr := space(12)
      endif
   endif

   //Skerm
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   //Vertoon die skerms
   do while nMore > 0

      do case

         case nMore == 1

            //Skerm
            if cLanType() == "A"
               fBox( 3, 2,21,77,"ALGEMENE INLIGTING      - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu                                         ")
               fSCrBood(24,"[A - Z]=Nuwe dier  [PgDn]=Volgende blad  [Alt P]=Druk")
            else
               fBox( 3, 2,21,77,"GENERAL INFORMATION     - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu                                         ")
               fSCrBood(24,"[A - Z]=New animal  [PgDn]=Next page  [Alt P]=Print")
            endif

            //Hoofde
            @ 4, 4 say aRecv[  4, 6]
            @ 5, 4 say aRecv[  2, 6]
            @ 6, 4 say aRecv[  3, 6]
            @ 7, 4 say aRecv[  5, 6]
            @ 8, 4 say aRecv[  6, 6]
            @ 9, 4 say aRecv[  7, 6]
            @10, 4 say aRecv[  8, 6]
            @11, 4 say aRecv[  9, 6]
            @12, 4 say aRecv[ 10, 6]
            @13, 4 say aRecv[ 11, 6]
            @14, 4 say aRecv[ 14, 6]
            @15, 4 say aRecv[ 15, 6]
            @16, 4 say aRecv[ 16, 6]
            @17, 4 say aRecv[ 17, 6]
            @18, 4 say aRecv[ 18, 6]
            @19, 4 say aRecv[ 19, 6]
            @20, 4 say aRecv[ 36, 6]

            @ 5,39 say aRecv[177, 6]
            @ 6,39 say aRecv[ 37, 6]
            @ 7,39 say aRecv[ 38, 6]
            @ 8,39 say aRecv[ 39, 6]
            @ 9,39 say aRecv[ 40, 6]
            @10,39 say aRecv[ 41, 6]
            @11,39 say aRecv[ 80, 6]
            @12,39 say aRecv[ 78, 6]
            @13,39 say aRecv[ 23, 6]
            @14,39 say aRecv[ 24, 6]
            @15,39 say aRecv[ 93, 6]
            @16,39 say aRecv[ 95, 6]
            @17,39 say aRecv[ 94, 6]
            @18,39 say aRecv[ 96, 6]
            @19,39 say aRecv[ 12, 6]
            @20,39 say aRecv[117, 6]

            //Data
            setcolor(cColInve())
            @ 4,25 say fieldget(aRecv[  4,13])
            @ 5,25 say fieldget(aRecv[  2,13])
            @ 6,25 say fieldget(aRecv[  3,13])
            @ 7,25 say fieldget(aRecv[  5,13])
            @ 8,25 say fieldget(aRecv[  6,13])
            @ 9,25 say fieldget(aRecv[  7,13])
            @10,25 say fieldget(aRecv[  8,13])
            @11,25 say fieldget(aRecv[  9,13])
            @12,25 say fieldget(aRecv[ 10,13])
            @13,25 say fieldget(aRecv[ 11,13])
            @14,25 say fieldget(aRecv[ 14,13])
            @15,25 say fieldget(aRecv[ 15,13])
            @16,25 say fieldget(aRecv[ 16,13])
            @17,25 say fieldget(aRecv[ 17,13])
            @18,25 say fieldget(aRecv[ 18,13])
            @19,25 say fieldget(aRecv[ 19,13])
            @20,25 say fieldget(aRecv[ 36,13])

            @ 5,60 say fieldget(aRecv[177,13])
            @ 6,60 say fieldget(aRecv[ 37,13])
            @ 7,60 say fieldget(aRecv[ 38,13])
            @ 8,60 say fieldget(aRecv[ 39,13])
            @ 9,60 say fieldget(aRecv[ 40,13])
            @10,60 say fieldget(aRecv[ 41,13])
            @11,60 say fieldget(aRecv[ 80,13])
            @12,60 say fieldget(aRecv[ 78,13])
            @13,60 say fieldget(aRecv[ 23,13])
            @14,60 say fieldget(aRecv[ 24,13])
            @15,60 say fieldget(aRecv[ 93,13])
            @16,60 say fieldget(aRecv[ 95,13])
            @17,60 say fieldget(aRecv[ 94,13])
            @18,60 say fieldget(aRecv[ 96,13])
            @19,60 say fieldget(aRecv[ 12,13])
            @20,60 say fieldget(aRecv[117,13])
            setcolor(cColNorm())

            if cIdnr == space(12)
               keyboard chr(K_CTRL_N)
            endif

            //Wag vir sleutel
            inkey(0)

            //Doen iets met elke sleutel
            do case
               case lastkey() == K_ESC
                  nMore := 0
               case lastkey() == K_ALT_N
                  //Vra die id nommer
                  cIdnr := space(12)
               case lastkey() == K_CTRL_N
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := space(12)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                     nMore := 0
                     loop
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                     nMore := 0
                     loop
                  endif
               case chr(lastkey()) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
                  //Nuwe nommer
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := chr(lastkey())+space(11)
                  keyboard chr(K_RIGHT)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                  endif
               case lastkey() == K_PGDN
                  nMore := 2
               case lastkey() == K_ALT_P
                  fPrint(aRecv)
            endcase

         case nMore == 2

            //Skerm
            if cLanType() == "A"
               fBox( 4, 3,21,77,"INDEKS INLIGTING        - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu       [PgUp]=Vorige blad    [Alt N]=Nuwe dier")
               fSCrBood(24,"[A - Z]=Nuwe dier  [PgDn]=Volgende blad  [Alt P]=Druk     ")
            else
               fBox( 4, 3,21,77,"INDEX INFORMATION       - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu        [PgUp]=Previous page   [Alt N]=New animal")
               fSCrBood(24,"[A - Z]=New animal  [PgDn]=Next page       [Alt P]=Print      ")
            endif

            //Hoofde
            @ 5, 5 say aRecv[ 41, 6]
            @ 6, 5 say aRecv[ 43, 6]
            @ 7, 5 say aRecv[ 44, 6]
            @ 8, 5 say aRecv[ 48, 6]
            @ 9, 5 say aRecv[ 47, 6]
            @10, 5 say aRecv[ 45, 6]
            @11, 5 say aRecv[ 49, 6]
            @12, 5 say aRecv[ 50, 6]

            @14, 5 say aRecv[ 52, 6]
            @15, 5 say aRecv[ 53, 6]
            @16, 5 say aRecv[ 57, 6]
            @17, 5 say aRecv[ 56, 6]
            @18, 5 say aRecv[ 54, 6]
            @19, 5 say aRecv[ 58, 6]
            @20, 5 say aRecv[ 59, 6]

            //if SM3DATA->fasekode == "      "
            @ 6,40 say aRecv[ 61, 6]
            @ 7,40 say aRecv[ 62, 6]
            @ 8,40 say aRecv[ 66, 6]
            @ 9,40 say aRecv[ 65, 6]
            @10,40 say aRecv[ 63, 6]
            @11,40 say aRecv[ 67, 6]
            @12,40 say aRecv[ 68, 6]

            @14,40 say aRecv[ 70, 6]
            @15,40 say aRecv[ 71, 6]
            @16,40 say aRecv[ 75, 6]
            @17,40 say aRecv[ 74, 6]
            @18,40 say aRecv[ 72, 6]
            @19,40 say aRecv[ 76, 6]
            @20,40 say aRecv[ 77, 6]
            //endif

            //Data
            setcolor(cColInve())
            @ 5,26 say fieldget(aRecv[ 41,13])
            @ 6,26 say fieldget(aRecv[ 43,13])
            @ 7,26 say fieldget(aRecv[ 44,13])
            @ 8,26 say fieldget(aRecv[ 48,13])
            @ 9,26 say fieldget(aRecv[ 47,13])
            @10,26 say fieldget(aRecv[ 45,13])
            @11,26 say fieldget(aRecv[ 49,13])
            @12,26 say fieldget(aRecv[ 50,13])

            @14,26 say fieldget(aRecv[ 52,13])
            @15,26 say fieldget(aRecv[ 53,13])
            @16,26 say fieldget(aRecv[ 57,13])
            @17,26 say fieldget(aRecv[ 56,13])
            @18,26 say fieldget(aRecv[ 54,13])
            @19,26 say fieldget(aRecv[ 58,13])
            @20,26 say fieldget(aRecv[ 59,13])

            //if SM3DATA->fasekode == "      "
            @ 6,61 say fieldget(aRecv[ 61,13])
            @ 7,61 say fieldget(aRecv[ 62,13])
            @ 8,61 say fieldget(aRecv[ 66,13])
            @ 9,61 say fieldget(aRecv[ 65,13])
            @10,61 say fieldget(aRecv[ 63,13])
            @11,61 say fieldget(aRecv[ 67,13])
            @12,61 say fieldget(aRecv[ 68,13])

            @14,61 say fieldget(aRecv[ 70,13])
            @15,61 say fieldget(aRecv[ 71,13])
            @16,61 say fieldget(aRecv[ 75,13])
            @17,61 say fieldget(aRecv[ 74,13])
            @18,61 say fieldget(aRecv[ 72,13])
            @19,61 say fieldget(aRecv[ 76,13])
            @20,61 say fieldget(aRecv[ 77,13])
            //endif
            setcolor(cColNorm())

            //Wag vir sleutel
            inkey(0)

            //Doen iets met elke sleutel
            do case
               case lastkey() == K_ESC
                  nMore := 0
               case lastkey() == K_ALT_N
                  //Vra die id nommer
                  cIdnr := space(12)
                  nMore := 1
               case chr(lastkey()) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
                  //Nuwe nommer
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := chr(lastkey())+space(11)
                  keyboard chr(K_RIGHT)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                  endif
               case lastkey() == K_PGUP
                  nMore := 1
               case lastkey() == K_PGDN
                  nMore := 3
               case lastkey() == K_ALT_P
                  fPrint(aRecv)
            endcase

         case nMore == 3

            //Skerm
            if cLanType() == "A"
               fBox( 5, 4,21,77,"FASE C & D INLIGTING    - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu       [PgUp]=Vorige blad    [Alt N]=Nuwe dier")
               fSCrBood(24,"[A - Z]=Nuwe dier  [PgDn]=Volgende blad  [Alt P]=Druk     ")
            else
               fBox( 5, 4,21,77,"PHASE C & D INFORMATION - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu        [PgUp]=Previous page  [Alt N]=New animal")
               fSCrBood(24,"[A - Z]=New animal  [PgDn]=Next page      [Alt P]=Print     ")
            endif

            if SM3DATA->fasekode == "      "
               if lastkey() == K_PGUP
                  nMore := 2
                  loop
               elseif lastkey() == K_PGDN
                  nMore := 4
                  loop
               endif
            endif

            // Hoofde
            @ 7, 6 say aRecv[fEnum(aRecv,"fasekode"  ),6]
            @ 8, 6 say aRecv[fEnum(aRecv,"begdatum"  ),6]
            @ 9, 6 say aRecv[fEnum(aRecv,"begmassa"  ),6]
            @10, 6 say aRecv[fEnum(aRecv,"eindat"    ),6]
            @11, 6 say aRecv[fEnum(aRecv,"einmas"    ),6]
            @12, 6 say aRecv[fEnum(aRecv,"daeint"    ),6]
            @13, 6 say aRecv[fEnum(aRecv,"tydgen"    ),6]
            @14, 6 say aRecv[fEnum(aRecv,"rangor"    ),6]
            @15, 6 say aRecv[fEnum(aRecv,"gdtgdt"    ),6]
            @16, 6 say aRecv[fEnum(aRecv,"gdtind"    ),6]
            @17, 6 say aRecv[fEnum(aRecv,"gdogdo"    ),6]
            @18, 6 say aRecv[fEnum(aRecv,"gdoind"    ),6]

            @ 7,41 say aRecv[fEnum(aRecv,"voeromset" ),6]
            @ 8,41 say aRecv[fEnum(aRecv,"voeromseti"),6]
            @ 9,41 say aRecv[fEnum(aRecv,"kleiber"   ),6]
            @10,41 say aRecv[fEnum(aRecv,"kleiberi"  ),6]
            @11,41 say aRecv[fEnum(aRecv,"mateskouer"),6]
            @12,41 say aRecv[fEnum(aRecv,"gekhoo"    ),6]
            @13,41 say aRecv[fEnum(aRecv,"matelengte"),6]
            @14,41 say aRecv[fEnum(aRecv,"geklen"    ),6]
            @15,41 say aRecv[fEnum(aRecv,"hoolen"    ),6]
            @16,41 say aRecv[fEnum(aRecv,"mateskrot" ),6]
            @17,41 say aRecv[fEnum(aRecv,"gekskr"    ),6]
            @18,41 say aRecv[fEnum(aRecv,"veldikte"  ),6]
            @19,41 say aRecv[fEnum(aRecv,"gekvel"    ),6]

            //Data
            setcolor(cColInve())

            @ 7,27 say fieldget(aRecv[fEnum(aRecv,"fasekode"  ),13])
            @ 8,27 say fieldget(aRecv[fEnum(aRecv,"begdatum"  ),13])
            @ 9,27 say fieldget(aRecv[fEnum(aRecv,"begmassa"  ),13])
            @10,27 say fieldget(aRecv[fEnum(aRecv,"eindat"    ),13])
            @11,27 say fieldget(aRecv[fEnum(aRecv,"einmas"    ),13])
            @12,27 say fieldget(aRecv[fEnum(aRecv,"daeint"    ),13])
            @13,27 say fieldget(aRecv[fEnum(aRecv,"tydgen"    ),13])
            @14,27 say fieldget(aRecv[fEnum(aRecv,"rangor"    ),13])
            @15,27 say fieldget(aRecv[fEnum(aRecv,"gdtgdt"    ),13])
            @16,27 say fieldget(aRecv[fEnum(aRecv,"gdtind"    ),13])
            @17,27 say fieldget(aRecv[fEnum(aRecv,"gdogdo"    ),13])
            @18,27 say fieldget(aRecv[fEnum(aRecv,"gdoind"    ),13])

            @ 7,62 say fieldget(aRecv[fEnum(aRecv,"voeromset" ),13])
            @ 8,62 say fieldget(aRecv[fEnum(aRecv,"voeromseti"),13])
            @ 9,62 say fieldget(aRecv[fEnum(aRecv,"kleiber"   ),13])
            @10,62 say fieldget(aRecv[fEnum(aRecv,"kleiberi"  ),13])
            @11,62 say fieldget(aRecv[fEnum(aRecv,"mateskouer"),13])
            @12,62 say fieldget(aRecv[fEnum(aRecv,"gekhoo"    ),13])
            @13,62 say fieldget(aRecv[fEnum(aRecv,"matelengte"),13])
            @14,62 say fieldget(aRecv[fEnum(aRecv,"geklen"    ),13])
            @15,62 say fieldget(aRecv[fEnum(aRecv,"hoolen"    ),13])
            @16,62 say fieldget(aRecv[fEnum(aRecv,"mateskrot" ),13])
            @17,62 say fieldget(aRecv[fEnum(aRecv,"gekskr"    ),13])
            @18,62 say fieldget(aRecv[fEnum(aRecv,"veldikte"  ),13])
            @19,62 say fieldget(aRecv[fEnum(aRecv,"gekvel"    ),13])

            setcolor(cColNorm())

            //Wag vir sleutel
            inkey(0)

            //Doen iets met elke sleutel
            do case
               case lastkey() == K_ESC
                  nMore := 0
               case lastkey() == K_ALT_N
                  //Vra die id nommer
                  cIdnr := space(12)
                  nMore := 1
               case chr(lastkey()) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
                  //Nuwe nommer
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := chr(lastkey())+space(11)
                  keyboard chr(K_RIGHT)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                  endif
               case lastkey() == K_PGUP
                  nMore := 2
               case lastkey() == K_PGDN
                  nMore := 4
               case lastkey() == K_ALT_P
                  fPrint(aRecv)

            endcase

         case nMore == 4

            //Skerm
            if cLanType() == "A"
               fBox( 6, 5,21,77,"NAGESLAG INLIGTING      - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu       [PgUp]=Vorige blad    [Alt N]=Nuwe dier")
               fSCrBood(24,"[A - Z]=Nuwe dier  [PgDn]=Volgende blad  [Alt P]=Druk     ")
            else
               fBox( 6, 5,21,77,"PROGENY INFORMATION     - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu        [PgUp]=Previous page  [Alt N]=New animal")
               fSCrBood(24,"[A - Z]=New animal  [PgDn]=Next page      [Alt P]=Print     ")
            endif

            //Hoofde
            @ 7, 7 say aRecv[ 29, 6]
            @ 8, 7 say aRecv[ 22, 6]
            @ 9, 7 say aRecv[ 26, 6]
            @10, 7 say aRecv[ 30, 6]
            @11, 7 say aRecv[ 31, 6]
            @12, 7 say aRecv[123, 6]
            @13, 7 say aRecv[ 33, 6]
            @14, 7 say aRecv[ 34, 6]
            @15, 7 say aRecv[124, 6]
            @16, 7 say aRecv[ 27, 6]
            @17, 7 say aRecv[107, 6]
            @18, 7 say aRecv[ 28, 6]
            @19, 7 say aRecv[108, 6]
            @20, 7 say aRecv[109, 6]

            @ 7,42 say aRecv[111, 6]
            @ 8,42 say aRecv[110, 6]
            @ 9,42 say aRecv[ 35, 6]
            @10,42 say aRecv[116, 6]
            @11,42 say aRecv[112, 6]
            @12,42 say aRecv[113, 6]
            @13,42 say aRecv[119, 6]
            @14,42 say aRecv[118, 6]
            @15,42 say aRecv[114, 6]
            @16,42 say aRecv[115, 6]
            @17,42 say aRecv[ 21, 6]
            @18,42 say aRecv[106, 6]
            @19,42 say aRecv[144, 6]
            @20,42 say aRecv[146, 6]

            //Data
            setcolor(cColInve())
            @ 7,28 say fieldget(aRecv[ 29,13])
            @ 8,28 say fieldget(aRecv[ 22,13])
            @ 9,28 say fieldget(aRecv[ 26,13])
            @10,28 say fieldget(aRecv[ 30,13])
            @11,28 say fieldget(aRecv[ 31,13])
            @12,28 say fieldget(aRecv[123,13])
            @13,28 say fieldget(aRecv[ 33,13])
            @14,28 say fieldget(aRecv[ 34,13])
            @15,28 say fieldget(aRecv[124,13])
            @16,28 say fieldget(aRecv[ 27,13])
            @17,28 say fieldget(aRecv[107,13])
            @18,28 say fieldget(aRecv[ 28,13])
            @19,28 say fieldget(aRecv[108,13])
            @20,28 say fieldget(aRecv[109,13])

            @ 7,63 say fieldget(aRecv[111,13])
            @ 8,63 say fieldget(aRecv[110,13])
            @ 9,63 say fieldget(aRecv[ 35,13])
            @10,63 say fieldget(aRecv[116,13])
            @11,63 say fieldget(aRecv[112,13])
            @12,63 say fieldget(aRecv[113,13])
            @13,63 say fieldget(aRecv[119,13])
            @14,63 say fieldget(aRecv[118,13])
            @15,63 say fieldget(aRecv[114,13])
            @16,63 say fieldget(aRecv[115,13])
            @17,63 say fieldget(aRecv[ 21,13])
            @18,63 say fieldget(aRecv[106,13])
            @19,63 say fieldget(aRecv[144,13])
            @20,63 say fieldget(aRecv[146,13])
            setcolor(cColNorm())

            //Wag vir sleutel
            inkey(0)

            //Doen iets met elke sleutel
            do case
               case lastkey() == K_ESC
                  nMore := 0
               case lastkey() == K_ALT_N
                  //Vra die id nommer
                  cIdnr := space(12)
                  nMore := 1
               case chr(lastkey()) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
                  //Nuwe nommer
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := chr(lastkey())+space(11)
                  keyboard chr(K_RIGHT)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                  endif
               case lastkey() == K_PGUP
                  nMore := 3
               case lastkey() == K_PGDN
                  nMore := 5
               case lastkey() == K_ALT_P
                  fPrint(aRecv)

            endcase

         case nMore == 5

            //Skerm
            if cLanType() == "A"
               fBox( 7, 6,21,77,"LIGGAAMSMATES           - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu       [PgUp]=Vorige blad    [Alt N]=Nuwe dier")
               fSCrBood(24,"[A - Z]=Nuwe dier                        [Alt P]=Druk     ")
            else
               fBox( 7, 6,21,77,"BODY MEASUREMENTS       - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu        [PgUp]=Previous page  [Alt N]=New animal")
               fSCrBood(24,"[A - Z]=New animal                        [Alt P]=Print     ")
            endif

            //Hoofde
            @ 8, 8 say aRecv[ 97, 6]
            @ 9, 8 say aRecv[ 98, 6]
            @10, 8 say aRecv[ 99, 6]
            @11, 8 say aRecv[100, 6]
            @12, 8 say aRecv[101, 6]
            @13, 8 say aRecv[102, 6]
            @14, 8 say aRecv[103, 6]
            @15, 8 say aRecv[104, 6]
            @16, 8 say aRecv[105, 6]

            //Data
            setcolor(cColInve())
            @ 8,29 say fieldget(aRecv[ 97,13])
            @ 9,29 say fieldget(aRecv[ 98,13])
            @10,29 say fieldget(aRecv[ 99,13])
            @11,29 say fieldget(aRecv[100,13])
            @12,29 say fieldget(aRecv[101,13])
            @13,29 say fieldget(aRecv[102,13])
            @14,29 say fieldget(aRecv[103,13])
            @15,29 say fieldget(aRecv[104,13])
            @16,29 say fieldget(aRecv[105,13])
            setcolor(cColNorm())

            //Wag vir sleutel
            inkey(0)

            //Doen iets met elke sleutel
            do case
               case lastkey() == K_ESC
                  nMore := 0
               case lastkey() == K_ALT_N
                  //Vra die id nommer
                  cIdnr := space(12)
                  nMore := 1
               case chr(lastkey()) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
                  //Nuwe nommer
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := chr(lastkey())+space(11)
                  keyboard chr(K_RIGHT)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                  endif
               case lastkey() == K_PGUP
                  nMore := 4
               case lastkey() == K_PGDN
                  nMore := 6
               case lastkey() == K_ALT_P
                  fPrint(aRecv)

            endcase

         case nMore == 6

            //Skerm
            if cLanType() == "A"
               fBox( 8, 7,21,77,"TEELWAARDES             - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu       [PgUp]=Vorige blad    [Alt N]=Nuwe dier")
               fSCrBood(24,"[A - Z]=Nuwe dier                        [Alt P]=Druk     ")
            else
               fBox( 8, 7,21,77,"BREEDING VALUES         - "+cIdnr )
               fScrBood(23,"[ Esc ]=Menu        [PgUp]=Previous page  [Alt N]=New animal")
               fSCrBood(24,"[A - Z]=New animal                        [Alt P]=Print     ")
            endif

            // Hoofde
            @ 9, 9 say aRecv[fEnum(aRecv,"analdate"  ),6]
            @10, 9 say aRecv[fEnum(aRecv,"tkpdir"  ),6]
            @11, 9 say aRecv[fEnum(aRecv,"oekdir"  ),6]
            @12, 9 say aRecv[fEnum(aRecv,"eocdir"  ),6]
            @13, 9 say aRecv[fEnum(aRecv,"eocmat"  ),6]
            @14, 9 say aRecv[fEnum(aRecv,"birdir"  ),6]
            @15, 9 say aRecv[fEnum(aRecv,"birmat"  ),6]
            @16, 9 say aRecv[fEnum(aRecv,"weadir"  ),6]
            @17, 9 say aRecv[fEnum(aRecv,"weamat"  ),6]
            @18, 9 say aRecv[fEnum(aRecv,"weacom"  ),6]
            @19, 9 say aRecv[fEnum(aRecv,"yeadir"  ),6]
            @20, 9 say aRecv[fEnum(aRecv,"m18dir"  ),6]

            @10,42 say aRecv[fEnum(aRecv,"adgdir"  ),6]
            @11,42 say aRecv[fEnum(aRecv,"pcfcrd"  ),6]
            @12,42 say aRecv[fEnum(aRecv,"kledir"  ),6]
            @13,42 say aRecv[fEnum(aRecv,"scrdir"  ),6]
            @14,42 say aRecv[fEnum(aRecv,"hgtdir"  ),6]
            @15,42 say aRecv[fEnum(aRecv,"lgtdir"  ),6]
            @16,42 say aRecv[fEnum(aRecv,"findir"  ),6]
            @17,42 say aRecv[fEnum(aRecv,"mcwdir"  ),6]
            @18,42 say aRecv[fEnum(aRecv,"cardir"  ),6]
            @19,42 say aRecv[fEnum(aRecv,"ribdir"  ),6]

            // Data
            setcolor(cColInve())
            @ 9,30 say fieldget(aRecv[fEnum(aRecv,"analdate"  ),13])
            @10,30 say fieldget(aRecv[fEnum(aRecv,"tkpdir"  ),13])
            @11,30 say fieldget(aRecv[fEnum(aRecv,"oekdir"  ),13])
            @12,30 say fieldget(aRecv[fEnum(aRecv,"eocdir"  ),13])
            @13,30 say fieldget(aRecv[fEnum(aRecv,"eocmat"  ),13])
            @14,30 say fieldget(aRecv[fEnum(aRecv,"birdir"  ),13])
            @15,30 say fieldget(aRecv[fEnum(aRecv,"birmat"  ),13])
            @16,30 say fieldget(aRecv[fEnum(aRecv,"weadir"  ),13])
            @17,30 say fieldget(aRecv[fEnum(aRecv,"weamat"  ),13])
            @18,30 say fieldget(aRecv[fEnum(aRecv,"weacom"  ),13])
            @19,30 say fieldget(aRecv[fEnum(aRecv,"yeadir"  ),13])
            @20,30 say fieldget(aRecv[fEnum(aRecv,"m18dir"  ),13])

            @10,39 say fieldget(aRecv[fEnum(aRecv,"tkpacc"  ),13])
            @11,39 say fieldget(aRecv[fEnum(aRecv,"oekacc"  ),13])
            @12,39 say fieldget(aRecv[fEnum(aRecv,"eocacc"  ),13])
            @13,39 say fieldget(aRecv[fEnum(aRecv,"eocmac"  ),13])
            @14,39 say fieldget(aRecv[fEnum(aRecv,"biracc"  ),13])
            @15,39 say fieldget(aRecv[fEnum(aRecv,"birmac"  ),13])
            @16,39 say fieldget(aRecv[fEnum(aRecv,"weaacc"  ),13])
            @17,39 say fieldget(aRecv[fEnum(aRecv,"weamac"  ),13])
            @18,39 say fieldget(aRecv[fEnum(aRecv,"weacac"  ),13])
            @19,39 say fieldget(aRecv[fEnum(aRecv,"yeaacc"  ),13])
            @20,39 say fieldget(aRecv[fEnum(aRecv,"m18acc"  ),13])

            @10,63 say fieldget(aRecv[fEnum(aRecv,"adgdir"  ),13])
            @11,63 say fieldget(aRecv[fEnum(aRecv,"pcfcrd"  ),13])
            @12,63 say fieldget(aRecv[fEnum(aRecv,"kledir"  ),13])
            @13,63 say fieldget(aRecv[fEnum(aRecv,"scrdir"  ),13])
            @14,63 say fieldget(aRecv[fEnum(aRecv,"hgtdir"  ),13])
            @15,63 say fieldget(aRecv[fEnum(aRecv,"lgtdir"  ),13])
            @16,63 say fieldget(aRecv[fEnum(aRecv,"findir"  ),13])
            @17,63 say fieldget(aRecv[fEnum(aRecv,"mcwdir"  ),13])
            @18,63 say fieldget(aRecv[fEnum(aRecv,"cardir"  ),13])
            @19,63 say fieldget(aRecv[fEnum(aRecv,"ribdir"  ),13])

            @10,72 say fieldget(aRecv[fEnum(aRecv,"adgacc"  ),13])
            @11,72 say fieldget(aRecv[fEnum(aRecv,"pcfcra"  ),13])
            @12,72 say fieldget(aRecv[fEnum(aRecv,"kleacc"  ),13])
            @13,72 say fieldget(aRecv[fEnum(aRecv,"scracc"  ),13])
            @14,72 say fieldget(aRecv[fEnum(aRecv,"hgtacc"  ),13])
            @15,72 say fieldget(aRecv[fEnum(aRecv,"lgtacc"  ),13])
            @16,72 say fieldget(aRecv[fEnum(aRecv,"finacc"  ),13])
            @17,72 say fieldget(aRecv[fEnum(aRecv,"mcwacc"  ),13])
            @18,72 say fieldget(aRecv[fEnum(aRecv,"caracc"  ),13])
            @19,72 say fieldget(aRecv[fEnum(aRecv,"ribacc"  ),13])

            setcolor(cColNorm())

            //Wag vir sleutel
            inkey(0)

            //Doen iets met elke sleutel
            do case
               case lastkey() == K_ESC
                  nMore := 0
               case lastkey() == K_ALT_N
                  //Vra die id nommer
                  cIdnr := space(12)
                  nMore := 1
               case chr(lastkey()) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
                  //Nuwe nommer
                  //Vra die id nommer
                  nBoxc := fBoxCent( 12, space(33), 1 )
                  cIdnr := chr(lastkey())+space(11)
                  keyboard chr(K_RIGHT)
                  cIdnr := sm3idnr(cIdnr,12,nBoxc)
                  if left(cIdnr,3) == "NOT"
                     cIdnr := SM3DATA->idnr
                  elseif left(cIdnr,9) == "CANCELLED"
                     cIdnr := SM3DATA->idnr
                  endif
               case lastkey() == K_PGUP
                  nMore := 5
               case lastkey() == K_ALT_P
                  fPrint(aRecv)

            endcase

      endcase

   enddo

   //Herstel
return NIL

//**************************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Funksie om algehele opsomming te druk

   //Verklaar
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local lRetu := .t.

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return .f.
   endif

   //Skerm
   fScrBood(23)

   //Bepaal die drukgrootte
   // Condense Printing
   nWidt := nPrnCwid()
   nTopl := nPrnLine()
   if nPrnLptp() < 8
      cPcod := cPrnCond()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      cPcod := cPrn8lpi()
      nPrnl := nPrcPrnl()
      nPagl := nPrcLeng()
   endif
   nMidc := nWidt - 29

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrbood(24,alltrim(SM3DATA->idnr)+" algehele opsomming word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,alltrim(SM3DATA->idnr)+" general summary being printed!  [Esc]=Stop printer.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Toets of drukker moet stop
   if fPrnStop() = K_ESC
      lRetu := .f.
      return lRetu
   endif

   //Druk opskrifte
   fPrnCod( cPcod )
   // fPrnCod(cPrn8lpi())
   if cLanType() == "A"
      @prow()+nTopl,1 say upper( cGebNaam() )
      @prow()  , nMidc say "             Verslag: " + cOption()
      @prow()+1,     1 say substr(cTotNaam(),  1,40)
      @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
      @prow()+1,     1 say substr(cTotNaam(), 41,40)
      @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
      @prow()+1,     1 say substr(cTotNaam(), 81,40)
      @prow()  , nMidc say "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
      @prow()+1,     1 say substr(cTotNaam(),121, 4)
      cHdln := "Algehele opsomming van "+trim(SM3DATA->idnr)
      @prow()  ,nWidt-len(cHdln)+1 say cHdln
   else
      @prow()+nTopl,1 say upper( cGebNaam() )
      @prow()  , nMidc say "              Report: " + cOption()
      @prow()+1,     1 say substr(cTotNaam(),  1,40)
      @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
      @prow()+1,     1 say substr(cTotNaam(), 41,40)
      @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
      @prow()+1,     1 say substr(cTotNaam(), 81,40)
      @prow()  , nMidc say "    Herd Designation: " + substr(cTotNaam(),125,4)
      @prow()+1,     1 say substr(cTotNaam(),121, 4)
      cHdln := "General summary for "+trim(SM3DATA->idnr)
      @prow()  ,nWidt-len(cHdln)+1 say cHdln
   endif

   //Algemene inligting
   if cLanType() == "A"
      @prow()+2,  1 say padr("=== Algemene inligting =",nWidt,"=")
   else
      @prow()+2,  1 say padr("=== General summary =",nWidt,"=")
   endif
   @prow()+1,  1 say fConv(aRecv[  4,6]) + fieldget(aRecv[  4,13])
   @prow()+1,  1 say fConv(aRecv[  2,6]) + transform(fieldget(aRecv[  2,13]),aRecv[  2,10])
   @prow()  , 40 say fConv(aRecv[ 16,6]) + transform(fieldget(aRecv[ 16,13]),aRecv[ 16,10])
   @prow()  , 80 say fConv(aRecv[ 78,6]) + transform(fieldget(aRecv[ 78,13]),aRecv[ 78,10])
   @prow()+1,  1 say fConv(aRecv[  3,6]) + transform(fieldget(aRecv[  3,13]),aRecv[  3,10])
   @prow()  , 40 say fConv(aRecv[ 17,6]) + transform(fieldget(aRecv[ 17,13]),aRecv[ 17,10])
   @prow()  , 80 say fConv(aRecv[ 23,6]) + transform(fieldget(aRecv[ 23,13]),aRecv[ 23,10])
   @prow()+1,  1 say fConv(aRecv[  5,6]) + transform(fieldget(aRecv[  5,13]),aRecv[  4,10])
   @prow()  , 40 say fConv(aRecv[ 18,6]) + transform(fieldget(aRecv[ 18,13]),aRecv[ 18,10])
   @prow()  , 80 say fConv(aRecv[ 24,6]) + transform(fieldget(aRecv[ 24,13]),aRecv[ 24,10])
   @prow()+1,  1 say fConv(aRecv[  6,6]) + transform(fieldget(aRecv[  6,13]),aRecv[  5,10])
   @prow()  , 40 say fConv(aRecv[ 19,6]) + transform(fieldget(aRecv[ 19,13]),aRecv[ 19,10])
   @prow()  , 80 say fConv(aRecv[ 93,6]) + transform(fieldget(aRecv[ 93,13]),aRecv[ 93,10])
   @prow()+1,  1 say fConv(aRecv[  7,6]) + transform(fieldget(aRecv[  7,13]),aRecv[  6,10])
   @prow()  , 40 say fConv(aRecv[ 36,6]) + transform(fieldget(aRecv[ 36,13]),aRecv[ 36,10])
   @prow()  , 80 say fConv(aRecv[ 95,6]) + transform(fieldget(aRecv[ 95,13]),aRecv[ 95,10])
   @prow()+1,  1 say fConv(aRecv[  8,6]) + transform(fieldget(aRecv[  8,13]),aRecv[  7,10])
   @prow()  , 40 say fConv(aRecv[ 37,6]) + transform(fieldget(aRecv[ 37,13]),aRecv[ 37,10])
   @prow()  , 80 say fConv(aRecv[ 94,6]) + transform(fieldget(aRecv[ 94,13]),aRecv[ 94,10])
   @prow()+1,  1 say fConv(aRecv[  9,6]) + transform(fieldget(aRecv[  9,13]),aRecv[  9,10])
   @prow()  , 40 say fConv(aRecv[ 38,6]) + transform(fieldget(aRecv[ 38,13]),aRecv[ 38,10])
   @prow()  , 80 say fConv(aRecv[ 96,6]) + transform(fieldget(aRecv[ 96,13]),aRecv[ 96,10])
   @prow()+1,  1 say fConv(aRecv[ 10,6]) + transform(fieldget(aRecv[ 10,13]),aRecv[ 10,10])
   @prow()  , 40 say fConv(aRecv[ 39,6]) + transform(fieldget(aRecv[ 39,13]),aRecv[ 39,10])
   @prow()  , 80 say fConv(aRecv[ 12,6]) + transform(fieldget(aRecv[ 12,13]),aRecv[ 12,10])
   @prow()+1,  1 say fConv(aRecv[ 11,6]) + transform(fieldget(aRecv[ 11,13]),aRecv[ 11,10])
   @prow()  , 40 say fConv(aRecv[ 40,6]) + transform(fieldget(aRecv[ 40,13]),aRecv[ 40,10])
   @prow()  , 80 say fConv(aRecv[117,6]) + transform(fieldget(aRecv[117,13]),aRecv[117,10])
   @prow()+1,  1 say fConv(aRecv[ 14,6]) + transform(fieldget(aRecv[ 14,13]),aRecv[ 14,10])
   @prow()  , 40 say fConv(aRecv[ 41,6]) + transform(fieldget(aRecv[ 41,13]),aRecv[ 41,10])
   @prow()  , 80 say fConv(aRecv[149,6]) + transform(fieldget(aRecv[149,13]),aRecv[149,10])
   @prow()+1,  1 say fConv(aRecv[ 15,6]) + transform(fieldget(aRecv[ 15,13]),aRecv[ 15,10])
   @prow()  , 40 say fConv(aRecv[ 80,6]) + transform(fieldget(aRecv[ 80,13]),aRecv[ 80,10])
   @prow()  , 80 say fConv(aRecv[150,6]) + transform(fieldget(aRecv[150,13]),aRecv[150,10])
   @prow()+1,  1 say fConv(aRecv[151,6]) + transform(fieldget(aRecv[151,13]),aRecv[151,10])
   @prow()  , 40 say fConv(aRecv[155,6]) + transform(fieldget(aRecv[155,13]),aRecv[155,10])
   @prow()  , 80 say fConv(aRecv[ 13,6]) + transform(fieldget(aRecv[ 13,13]),aRecv[ 13,10])
   @prow()+1,  1 say fConv(aRecv[152,6]) + transform(fieldget(aRecv[152,13]),aRecv[152,10])
   @prow()  , 40 say fConv(aRecv[138,6]) + transform(fieldget(aRecv[138,13]),aRecv[138,10])
   @prow()  , 80 say fConv(aRecv[ 32,6]) + transform(fieldget(aRecv[ 32,13]),aRecv[ 32,10])
   @prow()+1,  1 say fConv(aRecv[ 25,6]) + transform(fieldget(aRecv[ 25,13]),aRecv[ 25,10])
   @prow()  , 40 say fConv(aRecv[176,6]) + transform(fieldget(aRecv[176,13]),aRecv[176,10])
   @prow()  , 80 say fConv(aRecv[177,6]) + transform(fieldget(aRecv[177,13]),aRecv[177,10])

   //Indeks inligting
   if cLanType() == "A"
      @prow()+1,  1 say padr("=== Indeks inligting =",nWidt,"=")
   else
      @prow()+1,  1 say padr("=== Index information =",nWidt,"=")
   endif
   @prow()+1,  1 say fConv(aRecv[ 41,6]) + fieldget(aRecv[ 41,13])
   @prow()+1,  1 say fConv(aRecv[ 43,6]) + transform(fieldget(aRecv[ 43,13]),aRecv[ 43,10])
   @prow()  , 33 say fConv(aRecv[ 52,6]) + transform(fieldget(aRecv[ 52,13]),aRecv[ 52,10])
   @prow()  , 66 say fConv(aRecv[ 61,6]) + transform(fieldget(aRecv[ 61,13]),aRecv[ 61,10])
   @prow()  , 99 say fConv(aRecv[ 70,6]) + transform(fieldget(aRecv[ 70,13]),aRecv[ 70,10])
   @prow()+1,  1 say fConv(aRecv[ 44,6]) + transform(fieldget(aRecv[ 44,13]),aRecv[ 44,10])
   @prow()  , 33 say fConv(aRecv[ 53,6]) + transform(fieldget(aRecv[ 53,13]),aRecv[ 53,10])
   @prow()  , 66 say fConv(aRecv[ 62,6]) + transform(fieldget(aRecv[ 62,13]),aRecv[ 62,10])
   @prow()  , 99 say fConv(aRecv[ 71,6]) + transform(fieldget(aRecv[ 71,13]),aRecv[ 71,10])
   @prow()+1,  1 say fConv(aRecv[ 48,6]) + transform(fieldget(aRecv[ 48,13]),aRecv[ 48,10])
   @prow()  , 33 say fConv(aRecv[ 57,6]) + transform(fieldget(aRecv[ 57,13]),aRecv[ 57,10])
   @prow()  , 66 say fConv(aRecv[ 66,6]) + transform(fieldget(aRecv[ 66,13]),aRecv[ 66,10])
   @prow()  , 99 say fConv(aRecv[ 75,6]) + transform(fieldget(aRecv[ 75,13]),aRecv[ 75,10])
   @prow()+1,  1 say fConv(aRecv[ 47,6]) + transform(fieldget(aRecv[ 47,13]),aRecv[ 47,10])
   @prow()  , 33 say fConv(aRecv[ 56,6]) + transform(fieldget(aRecv[ 56,13]),aRecv[ 56,10])
   @prow()  , 66 say fConv(aRecv[ 65,6]) + transform(fieldget(aRecv[ 65,13]),aRecv[ 65,10])
   @prow()  , 99 say fConv(aRecv[ 74,6]) + transform(fieldget(aRecv[ 74,13]),aRecv[ 74,10])
   @prow()+1,  1 say fConv(aRecv[ 45,6]) + transform(fieldget(aRecv[ 45,13]),aRecv[ 45,10])
   @prow()  , 33 say fConv(aRecv[ 54,6]) + transform(fieldget(aRecv[ 54,13]),aRecv[ 54,10])
   @prow()  , 66 say fConv(aRecv[ 63,6]) + transform(fieldget(aRecv[ 63,13]),aRecv[ 63,10])
   @prow()  , 99 say fConv(aRecv[ 72,6]) + transform(fieldget(aRecv[ 72,13]),aRecv[ 72,10])
   @prow()+1,  1 say fConv(aRecv[ 49,6]) + transform(fieldget(aRecv[ 49,13]),aRecv[ 49,10])
   @prow()  , 33 say fConv(aRecv[ 58,6]) + transform(fieldget(aRecv[ 58,13]),aRecv[ 58,10])
   @prow()  , 66 say fConv(aRecv[ 67,6]) + transform(fieldget(aRecv[ 67,13]),aRecv[ 67,10])
   @prow()  , 99 say fConv(aRecv[ 76,6]) + transform(fieldget(aRecv[ 76,13]),aRecv[ 76,10])
   @prow()+1,  1 say fConv(aRecv[ 50,6]) + transform(fieldget(aRecv[ 50,13]),aRecv[ 50,10])
   @prow()  , 33 say fConv(aRecv[ 59,6]) + transform(fieldget(aRecv[ 59,13]),aRecv[ 59,10])
   @prow()  , 66 say fConv(aRecv[ 68,6]) + transform(fieldget(aRecv[ 68,13]),aRecv[ 68,10])
   @prow()  , 99 say fConv(aRecv[ 77,6]) + transform(fieldget(aRecv[ 77,13]),aRecv[ 77,10])

   //Algemene inligting

   if !empty(SM3DATA->fasekode)
      if cLanType() == "A"
         @prow()+1,  1 say padr("=== Fase C & D inligting =",nWidt,"=")
      else
         @prow()+1,  1 say padr("=== Phase C & D information =",nWidt,"=")
      endif

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"fasekode"),6]) + ;
         fieldget(aRecv[fEnum(aRecv,"fasekode"),13])

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"begdatum"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"begdatum"),13])
      @prow()  , 33 say fConv(aRecv[fEnum(aRecv,"gdtgdt"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gdtgdt"),13])
      @prow()  , 66 say fConv(aRecv[fEnum(aRecv,"voeromset"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"voeromset"),13])
      @prow()  , 99 say fConv(aRecv[fEnum(aRecv,"gekhoo"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gekhoo"),13])

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"begmassa"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"begmassa"),13])
      @prow()  , 33 say fConv(aRecv[fEnum(aRecv,"gdtind"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gdtind"),13])
      @prow()  , 66 say fConv(aRecv[fEnum(aRecv,"voeromseti"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"voeromseti"),13])
      @prow()  , 99 say fConv(aRecv[fEnum(aRecv,"geklen"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"geklen"),13])

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"eindat"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"eindat"),13])
      @prow()  , 33 say fConv(aRecv[fEnum(aRecv,"gdogdo"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gdogdo"),13])
      @prow()  , 66 say fConv(aRecv[fEnum(aRecv,"kleiber"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"kleiber"),13])
      @prow()  , 99 say fConv(aRecv[fEnum(aRecv,"hoolen"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"hoolen"),13])

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"einmas"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"einmas"),13])
      @prow()  , 33 say fConv(aRecv[fEnum(aRecv,"gdoind"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gdoind"),13])
      @prow()  , 66 say fConv(aRecv[fEnum(aRecv,"kleiberi"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"kleiberi"),13])
      @prow()  , 99 say fConv(aRecv[fEnum(aRecv,"gekskr"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gekskr"),13])

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"daeint"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"daeint"),13])
      @prow()  , 33 say fConv(aRecv[fEnum(aRecv,"tydgen"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"tydgen"),13])
      @prow()  , 66 say fConv(aRecv[fEnum(aRecv,"rangor"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"rangor"),13])
      @prow()  , 99 say fConv(aRecv[fEnum(aRecv,"gekvel"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"gekvel"),13])

      @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"mateskouer"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"mateskouer"),13])
      @prow()  , 33 say fConv(aRecv[fEnum(aRecv,"matelengte"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"matelengte"),13])
      @prow()  , 66 say fConv(aRecv[fEnum(aRecv,"mateskrot"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"mateskrot"),13])
      @prow()  , 99 say fConv(aRecv[fEnum(aRecv,"veldikte"),6])
      @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"veldikte"),13])

   endif

   //Nageslag inligting
   if cLanType() == "A"
      @prow()+1,  1 say padr("=== Nageslag inligting =",nWidt,"=")
   else
      @prow()+1,  1 say padr("=== Progeny information =",nWidt,"=")
   endif
   @prow()+1,  1 say fConv(aRecv[ 29,6]) + transform(fieldget(aRecv[ 29,13]),aRecv[ 29,10])
   @prow()  , 33 say fConv(aRecv[ 34,6]) + transform(fieldget(aRecv[ 34,13]),aRecv[ 34,10])
   @prow()  , 66 say fConv(aRecv[111,6]) + transform(fieldget(aRecv[111,13]),aRecv[111,10])
   @prow()  , 99 say fConv(aRecv[118,6]) + transform(fieldget(aRecv[118,13]),aRecv[118,10])
   @prow()+1,  1 say fConv(aRecv[ 22,6]) + transform(fieldget(aRecv[ 22,13]),aRecv[ 22,10])
   @prow()  , 33 say fConv(aRecv[124,6]) + transform(fieldget(aRecv[124,13]),aRecv[124,10])
   @prow()  , 66 say fConv(aRecv[110,6]) + transform(fieldget(aRecv[110,13]),aRecv[110,10])
   @prow()  , 99 say fConv(aRecv[114,6]) + transform(fieldget(aRecv[114,13]),aRecv[114,10])
   @prow()+1,  1 say fConv(aRecv[ 26,6]) + transform(fieldget(aRecv[ 26,13]),aRecv[ 26,10])
   @prow()  , 33 say fConv(aRecv[ 27,6]) + transform(fieldget(aRecv[ 27,13]),aRecv[ 27,10])
   @prow()  , 66 say fConv(aRecv[ 35,6]) + transform(fieldget(aRecv[ 35,13]),aRecv[ 35,10])
   @prow()  , 99 say fConv(aRecv[115,6]) + transform(fieldget(aRecv[115,13]),aRecv[115,10])
   @prow()+1,  1 say fConv(aRecv[ 30,6]) + transform(fieldget(aRecv[ 30,13]),aRecv[ 30,10])
   @prow()  , 33 say fConv(aRecv[107,6]) + transform(fieldget(aRecv[107,13]),aRecv[107,10])
   @prow()  , 66 say fConv(aRecv[116,6]) + transform(fieldget(aRecv[116,13]),aRecv[116,10])
   @prow()  , 99 say fConv(aRecv[ 21,6]) + transform(fieldget(aRecv[ 21,13]),aRecv[ 21,10])
   @prow()+1,  1 say fConv(aRecv[ 31,6]) + transform(fieldget(aRecv[ 31,13]),aRecv[ 31,10])
   @prow()  , 33 say fConv(aRecv[ 28,6]) + transform(fieldget(aRecv[ 28,13]),aRecv[ 28,10])
   @prow()  , 66 say fConv(aRecv[112,6]) + transform(fieldget(aRecv[112,13]),aRecv[112,10])
   @prow()  , 99 say fConv(aRecv[106,6]) + transform(fieldget(aRecv[106,13]),aRecv[106,10])
   @prow()+1,  1 say fConv(aRecv[123,6]) + transform(fieldget(aRecv[123,13]),aRecv[123,10])
   @prow()  , 33 say fConv(aRecv[108,6]) + transform(fieldget(aRecv[108,13]),aRecv[108,10])
   @prow()  , 66 say fConv(aRecv[113,6]) + transform(fieldget(aRecv[113,13]),aRecv[113,10])
   @prow()  , 99 say fConv(aRecv[144,6]) + transform(fieldget(aRecv[144,13]),aRecv[144,10])
   @prow()+1,  1 say fConv(aRecv[ 33,6]) + transform(fieldget(aRecv[ 33,13]),aRecv[ 33,10])
   @prow()  , 33 say fConv(aRecv[109,6]) + transform(fieldget(aRecv[109,13]),aRecv[109,10])
   @prow()  , 66 say fConv(aRecv[119,6]) + transform(fieldget(aRecv[119,13]),aRecv[119,10])
   @prow()  , 99 say fConv(aRecv[146,6]) + transform(fieldget(aRecv[146,13]),aRecv[146,10])
   @prow()+1,  1 say fConv(aRecv[145,6]) + transform(fieldget(aRecv[145,13]),aRecv[145,10])
   @prow()  , 33 say fConv(aRecv[183,6]) + transform(fieldget(aRecv[183,13]),aRecv[183,10])

   //Liggaamsmates
   if cLanType() == "A"
      @prow()+1,  1 say padr("=== Liggaamsmates =",nWidt,"=")
   else
      @prow()+1,  1 say padr("=== Body measurements =",nWidt,"=")
   endif
   @prow()+1,  1 say fConv(aRecv[ 97,6]) + transform(fieldget(aRecv[ 97,13]),aRecv[ 97,10])
   @prow()  , 40 say fConv(aRecv[ 98,6]) + transform(fieldget(aRecv[ 98,13]),aRecv[ 98,10])
   @prow()  , 80 say fConv(aRecv[101,6]) + transform(fieldget(aRecv[101,13]),aRecv[101,10])
   @prow()+1,  1 say fConv(aRecv[104,6]) + transform(fieldget(aRecv[104,13]),aRecv[104,10])
   @prow()  , 40 say fConv(aRecv[ 99,6]) + transform(fieldget(aRecv[ 99,13]),aRecv[ 99,10])
   @prow()  , 80 say fConv(aRecv[102,6]) + transform(fieldget(aRecv[102,13]),aRecv[102,10])
   @prow()+1,  1 say fConv(aRecv[105,6]) + transform(fieldget(aRecv[105,13]),aRecv[105,10])
   @prow()  , 40 say fConv(aRecv[100,6]) + transform(fieldget(aRecv[100,13]),aRecv[100,10])
   @prow()  , 80 say fConv(aRecv[103,6]) + transform(fieldget(aRecv[103,13]),aRecv[103,10])
   @prow()+1,  1 say fConv(aRecv[147,6]) + transform(fieldget(aRecv[147,13]),aRecv[147,10])
   @prow()  , 40 say fConv(aRecv[148,6]) + transform(fieldget(aRecv[148,13]),aRecv[148,10])

   //Teelwaardes
   if cLanType() == "A"
      @prow()+1,  1 say padr("=== Teelwaardes =",nWidt,"=")
   else
      @prow()+1,  1 say padr("=== Breeding Values =",nWidt,"=")
   endif
   @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"analdate"),6])
   @prow()  ,pcol() say fieldget(aRecv[fEnum(aRecv,"analdate"),13])

   @prow()+1,     1 say fConv(aRecv[fEnum(aRecv,"tkpdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"tkpdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"tkpacc"),13]),"@B"))+")"
   @prow()  ,    40 say fConv(aRecv[fEnum(aRecv,"weadir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"weadir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"weaacc"),13]),"@B"))+")"
   @prow()  ,    80 say fConv(aRecv[fEnum(aRecv,"adgdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"adgdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"adgacc"),13]),"@B"))+")"

   @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"oekdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"oekdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"oekacc"),13]),"@B"))+")"
   @prow()  ,    40 say fConv(aRecv[fEnum(aRecv,"weamat"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"weamat"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"weamac"),13]),"@B"))+")"
   @prow()  ,    80 say fConv(aRecv[fEnum(aRecv,"pcfcrd"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"pcfcrd"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"pcfcra"),13]),"@B"))+")"

   @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"eocdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"eocdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"eocacc"),13]),"@B"))+")"
   @prow()  ,    40 say fConv(aRecv[fEnum(aRecv,"weacom"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"weacom"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"weacac"),13]),"@B"))+")"
   @prow()  ,    80 say fConv(aRecv[fEnum(aRecv,"kledir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"kledir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"kleacc"),13]),"@B"))+")"

   @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"eocmat"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"eocmat"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"eocmac"),13]),"@B"))+")"
   @prow()  ,    40 say fConv(aRecv[fEnum(aRecv,"yeadir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"yeadir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"yeaacc"),13]),"@B"))+")"
   @prow()  ,    80 say fConv(aRecv[fEnum(aRecv,"scrdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"scrdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"scracc"),13]),"@B"))+")"

   @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"birdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"birdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"biracc"),13]),"@B"))+")"
   @prow()  ,    40 say fConv(aRecv[fEnum(aRecv,"m18dir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"m18dir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"m18acc"),13]),"@B"))+")"
   @prow()  ,    80 say fConv(aRecv[fEnum(aRecv,"hgtdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"hgtdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"hgtacc"),13]),"@B"))+")"

   @prow()+1,  1 say fConv(aRecv[fEnum(aRecv,"birmat"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"birmat"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"birmac"),13]),"@B"))+")"
   @prow()  ,    40 say fConv(aRecv[fEnum(aRecv,"mcwdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"mcwdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"mcwacc"),13]),"@B"))+")"
   @prow()  ,    80 say fConv(aRecv[fEnum(aRecv,"lgtdir"),6])
   @prow()  ,pcol() say alltrim(transform(fieldget(aRecv[fEnum(aRecv,"lgtdir"),13]),"@B"))
   @prow()  ,pcol() say " ("+alltrim(transform(fieldget(aRecv[fEnum(aRecv,"lgtacc"),13]),"@B"))+")"

   //Print onderste lyn
   @prow()+1,  1 say repl( "=",  nWidt )
   @prow()+1,  1 say cAppName()
   //fPrnCod(cPrn6lpi())
   //@prow()+(nPagl-3-prow()),nWidt-len(trim(SM3DATA->idnr)) say trim(SM3DATA->idnr)
   //@nPagl-3,nWidt-len(trim(SM3DATA->idnr)) say trim(SM3DATA->idnr)
   fPrnEjec()
   fPrnOff()

   //Herstel

return lRetu

//*************************************************************************/
STATIC FUNCTION fConv(cData)
   //Funksie om databeskrywing om te skakel
return padr(alltrim(cData),20,".")+" "

