//SM3RASK.PRG
//Program om rasse te vertoon en te kies
//Kopiereg (c) 1991 A van Rensburg
//14:07 10 Jan,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3rask( cRass )

   // Veranderlikes
   LOCAL cCurDbf := fTOpen()                     //Bewaar huidige dbf waardes
   LOCAL cCurScr := fCurScreen()                 //Huidige skerm besonderhede
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )
   LOCAL nBoxCoo := 0                            //Waarde van venster
   LOCAL cBrowse
   LOCAL aColumn := {}
   LOCAL i       := 1
   LOCAL lMore   := .t.
   LOCAL nKey    := 1

   // Waardes
   cRass := if( cRass==NIL,"   ",cRass)

   // Open dryfleer
   do while lMore
      // dbUseArea(.t.,,"sm3rass.tdb","sm3rass",.t.,.f.)
      dbUseArea(.t.,,cDd()+"sm3rass.dbf","sm3rass",.t.,.f.)
      if neterr()
         if cLanType() == "A"
            fScrBood(23,"Netwerkfout! - Rasse. (Nuwe skep)")
            fScrBood(24,"[Esc]=Dos  [Enter]=Probeer weer")
         else
            fScrBood(23,"Network error! - Breeds. (Create new)")
            fScrBood(24,"[Esc]=Dos  [Enter]=Retry")
         endif
         inkey(0)
         if lastkey() == K_ESC
            setcolor( cColBegi() )
            clear screen
            set curs on
            quit
         endif
      else
         exit
      endif
   enddo

   // Vind die laaste roete
   if cRass <> "   "
      locate for SM3RASS->raskod = cRass
      if eof()
         go top
      endif
   else
      go top
      cRass := SM3RASS->raskod
   endif

   // Vertoon die beskikbare drywe
   if cLanType() == "A"
      fScrBood( 23, "[PgDn]=Nog Rasse  [PgUp]=Nog Rasse" )
      fScrBood( 24, "Kies ras met " + D_DNARR + D_UPARR + " sleutels en druk " + D_ENTER )
      nBoxCoo := fBoxCent( 4, space(24), 16, "KIES 'n RAS" )
   else
      fScrBood( 23, "[PgDn]=More Breeds  [PgUp]=More Breeds")
      fScrBood( 24, "Choose breed with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER )
      nBoxCoo :=fBoxCent( 4, space(24), 16, "CHOOSE A BREED" )
   endif
   setcolor(cColNorm())

   // Bou die tBrowse
   cBrowse := TBrowseDB( 4, nBoxCoo, 19, nBoxCoo+24 )

   // Definieer kolomme
   aadd( aColumn, TBColumnNew( , {|| SM3RASS->rasnaa } ) )
   aadd( aColumn, TBColumnNew( , {|| SM3RASS->raskod } ) )

   // Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   // Main loop
   lMore := .T.
   do while lMore

      // Stabilize the display until it's stable or a key is pressed
      nKey := 0
      do while nKey == 0 .and. .not. cBrowse:stable
         cBrowse:stabilize()
         nKey := InKey()
      enddo

      if cBrowse:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         cBrowse:refreshCurrent()
         ForceStable(cBrowse)
         // Everything's done -- just wait for a key
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         // Esc means leave
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means leave and update drive variable
         cRass := SM3RASS->raskod
         lMore := .f.
         // Change field name entries
         if empty(SM3RASS->breedp)
            FielName(.f.,"")
         else
            FielName(.t.,SM3RASS->breeds)
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   // Herstel
   dbCloseArea()
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )

return cRass

/******************************************************************************/
STATIC FUNCTION FielName(lBrep,cBcod)

   // Declare
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lGene := .f.
   local lPedi := .f.
   local lCalf := .f.
   local lOthe := .f.
   local lProg := .f.
   local lInde := .f.
   local lGrow := .f.
   local lBody := .f.
   local lSale := .f.
   local lBree := .f.
   local lPurc := .f.

   begin sequence

      // First create program index files
      stdinde(.f.)

      // Open the fields file
      aCdbf := fATopen(aCdbf,,"STDFIEL",,"tdb",,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Soek vir sekere velde

      // Wean
      seek "SM3DATA KOD205    "
      if lBrep
         STDFIEL->fldbesk := "200d voedingstatus"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "voe"
         STDFIEL->fldops3 := "sta"
         STDFIEL->flddesc := "200d feeding status"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "fee"
         STDFIEL->fldhed3 := "sta"
      else
         STDFIEL->fldbesk := "205d voedingstatus"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "voe"
         STDFIEL->fldops3 := "sta"
         STDFIEL->flddesc := "205d feeding status"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "fee"
         STDFIEL->fldhed3 := "sta"
      endif
      seek "SM3DATA UNR205    "
      if lBrep
         STDFIEL->fldbesk := "200d onbetroubaar"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "onb"
         STDFIEL->flddesc := "200d unreliable"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "unr"
      else
         STDFIEL->fldbesk := "205d onbetroubaar"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "onb"
         STDFIEL->flddesc := "205d unreliable"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "unr"
      endif
      seek "SM3DATA DAT205    "
      if lBrep
         STDFIEL->fldbesk := "200d weegdatum"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "datum"
         STDFIEL->flddesc := "200d weigh date"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "date"
      else
         STDFIEL->fldbesk := "205d weegdatum"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "datum"
         STDFIEL->flddesc := "205d weigh date"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "date"
      endif
      seek "SM3DATA MAS205    "
      if lBrep
         STDFIEL->fldbesk := "200d massa"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "mass"
         STDFIEL->flddesc := "200d mass"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "mass"
      else
         STDFIEL->fldbesk := "205d massa"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "mass"
         STDFIEL->flddesc := "205d mass"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "mass"
      endif
      seek "SM3DATA AAN205    "
      if lBrep
         STDFIEL->fldbesk := "200d tydgenote"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "tydg"
         STDFIEL->flddesc := "200d contemporaries"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cont"
      else
         STDFIEL->fldbesk := "205d tydgenote"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "tydg"
         STDFIEL->flddesc := "205d contemporaries"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cont"
      endif
      seek "SM3DATA PLE205    "
      if lBrep
         STDFIEL->fldbesk := "200d rangorde"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "rang"
         STDFIEL->flddesc := "200d order"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "order"
      else
         STDFIEL->fldbesk := "205d rangorde"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "rang"
         STDFIEL->flddesc := "205d order"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "order"
      endif
      seek "SM3DATA OUD205    "
      if lBrep
         STDFIEL->fldbesk := "200d ouderdom"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "oud"
         STDFIEL->flddesc := "200d age"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "age"
      else
         STDFIEL->fldbesk := "205d ouderdom"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "oud"
         STDFIEL->flddesc := "205d age"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "age"
      endif
      seek "SM3DATA GMA205    "
      if lBrep
         STDFIEL->fldbesk := "200d gek.massa"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gmas"
         STDFIEL->flddesc := "200d corr.mass"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cmas"
      else
         STDFIEL->fldbesk := "205d gek.massa"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gmas"
         STDFIEL->flddesc := "205d corr.mass"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cmas"
      endif
      seek "SM3DATA GDO205    "
      if lBrep
         STDFIEL->fldbesk := "200d gdo"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gdo"
         STDFIEL->flddesc := "200d ada"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ada"
      else
         STDFIEL->fldbesk := "205d gdo"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gdo"
         STDFIEL->flddesc := "205d ada"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ada"
      endif
      seek "SM3DATA IND205    "
      if lBrep
         STDFIEL->fldbesk := "200d indeks"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "200d index"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ind"
      else
         STDFIEL->fldbesk := "205d indeks"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "205d index"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ind"
      endif

      // Year
      seek "SM3DATA KOD365    "
      if lBrep
         STDFIEL->fldbesk := "400d voedingstatus"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "voe"
         STDFIEL->fldops3 := "sta"
         STDFIEL->flddesc := "400d feeding status"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "fee"
         STDFIEL->fldhed3 := "sta"
      else
         STDFIEL->fldbesk := "365d voedingstatus"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "voe"
         STDFIEL->fldops3 := "sta"
         STDFIEL->flddesc := "365d feeding status"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "fee"
         STDFIEL->fldhed3 := "sta"
      endif
      seek "SM3DATA UNR365    "
      if lBrep
         STDFIEL->fldbesk := "400d onbetroubaar"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "onb"
         STDFIEL->flddesc := "400d unreliable"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "unr"
      else
         STDFIEL->fldbesk := "365d onbetroubaar"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "onb"
         STDFIEL->flddesc := "365d unreliable"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "unr"
      endif
      seek "SM3DATA DAT365    "
      if lBrep
         STDFIEL->fldbesk := "400d weegdatum"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "datum"
         STDFIEL->flddesc := "400d weigh date"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "date"
      else
         STDFIEL->fldbesk := "365d weegdatum"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "datum"
         STDFIEL->flddesc := "365d weigh date"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "date"
      endif
      seek "SM3DATA MAS365    "
      if lBrep
         STDFIEL->fldbesk := "400d massa"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "mass"
         STDFIEL->flddesc := "400d mass"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "mass"
      else
         STDFIEL->fldbesk := "365d massa"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "mass"
         STDFIEL->flddesc := "365d mass"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "mass"
      endif
      seek "SM3DATA AAN365    "
      if lBrep
         STDFIEL->fldbesk := "400d tydgenote"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "tydg"
         STDFIEL->flddesc := "400d contemporaries"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cont"
      else
         STDFIEL->fldbesk := "365d tydgenote"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "tydg"
         STDFIEL->flddesc := "365d contemporaries"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cont"
      endif
      seek "SM3DATA PLE365    "
      if lBrep
         STDFIEL->fldbesk := "400d rangorde"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "rang"
         STDFIEL->flddesc := "400d order"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "order"
      else
         STDFIEL->fldbesk := "365d rangorde"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "rang"
         STDFIEL->flddesc := "365d order"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "order"
      endif
      seek "SM3DATA OUD365    "
      if lBrep
         STDFIEL->fldbesk := "400d ouderdom"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "oud"
         STDFIEL->flddesc := "400d age"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "age"
      else
         STDFIEL->fldbesk := "365d ouderdom"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "oud"
         STDFIEL->flddesc := "365d age"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "age"
      endif
      seek "SM3DATA GMA365    "
      if lBrep
         STDFIEL->fldbesk := "400d gek.massa"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gmas"
         STDFIEL->flddesc := "400d corr.mass"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cmas"
      else
         STDFIEL->fldbesk := "365d gek.massa"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gmas"
         STDFIEL->flddesc := "365d corr.mass"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cmas"
      endif
      seek "SM3DATA GDO365    "
      if lBrep
         STDFIEL->fldbesk := "400d gdo"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gdo"
         STDFIEL->flddesc := "400d ada"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ada"
      else
         STDFIEL->fldbesk := "365d gdo"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gdo"
         STDFIEL->flddesc := "365d ada"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ada"
      endif
      seek "SM3DATA IND365    "
      if lBrep
         STDFIEL->fldbesk := "400d indeks"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "400d index"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ind"
      else
         STDFIEL->fldbesk := "365d indeks"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "365d index"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ind"
      endif

      // 18 Months
      seek "SM3DATA KOD540    "
      if lBrep
         STDFIEL->fldbesk := "600d voedingstatus"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "voe"
         STDFIEL->fldops3 := "sta"
         STDFIEL->flddesc := "600d feeding status"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "fee"
         STDFIEL->fldhed3 := "sta"
      else
         STDFIEL->fldbesk := "540d voedingstatus"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "voe"
         STDFIEL->fldops3 := "sta"
         STDFIEL->flddesc := "540d feeding status"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "fee"
         STDFIEL->fldhed3 := "sta"
      endif
      seek "SM3DATA UNR540    "
      if lBrep
         STDFIEL->fldbesk := "600d onbetroubaar"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "onb"
         STDFIEL->flddesc := "600d unreliable"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "unr"
      else
         STDFIEL->fldbesk := "540d onbetroubaar"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "onb"
         STDFIEL->flddesc := "540d unreliable"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "unr"
      endif
      seek "SM3DATA DAT540    "
      if lBrep
         STDFIEL->fldbesk := "600d weegdatum"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "datum"
         STDFIEL->flddesc := "600d weigh date"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "date"
      else
         STDFIEL->fldbesk := "540d weegdatum"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "datum"
         STDFIEL->flddesc := "540d weigh date"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "date"
      endif
      seek "SM3DATA MAS540    "
      if lBrep
         STDFIEL->fldbesk := "600d massa"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "mass"
         STDFIEL->flddesc := "600d mass"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "mass"
      else
         STDFIEL->fldbesk := "540d massa"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "mass"
         STDFIEL->flddesc := "540d mass"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "mass"
      endif
      seek "SM3DATA AAN540    "
      if lBrep
         STDFIEL->fldbesk := "600d tydgenote"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "tydg"
         STDFIEL->flddesc := "600d contemporaries"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cont"
      else
         STDFIEL->fldbesk := "540d tydgenote"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "tydg"
         STDFIEL->flddesc := "540d contemporaries"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cont"
      endif
      seek "SM3DATA PLE540    "
      if lBrep
         STDFIEL->fldbesk := "600d rangorde"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "rang"
         STDFIEL->flddesc := "600d order"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "order"
      else
         STDFIEL->fldbesk := "540d rangorde"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "rang"
         STDFIEL->flddesc := "540d order"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "order"
      endif
      seek "SM3DATA OUD540    "
      if lBrep
         STDFIEL->fldbesk := "600d ouderdom"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "oud"
         STDFIEL->flddesc := "600d age"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "age"
      else
         STDFIEL->fldbesk := "540d ouderdom"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "oud"
         STDFIEL->flddesc := "540d age"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "age"
      endif
      seek "SM3DATA GMA540    "
      if lBrep
         STDFIEL->fldbesk := "600d gek.massa"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gmas"
         STDFIEL->flddesc := "600d corr.mass"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cmas"
      else
         STDFIEL->fldbesk := "540d gek.massa"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gmas"
         STDFIEL->flddesc := "540d corr.mass"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "cmas"
      endif
      seek "SM3DATA GDO540    "
      if lBrep
         STDFIEL->fldbesk := "600d gdo"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gdo"
         STDFIEL->flddesc := "600d ada"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ada"
      else
         STDFIEL->fldbesk := "540d gdo"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "gdo"
         STDFIEL->flddesc := "540d ada"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ada"
      endif
      seek "SM3DATA IND540    "
      if lBrep
         STDFIEL->fldbesk := "600d indeks"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "600d index"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ind"
      else
         STDFIEL->fldbesk := "540d indeks"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "540d index"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ind"
      endif

      // Average wean index
      seek "SM3DATA GEMSPEENI "
      if lBrep
         STDFIEL->fldbesk := "Gem. 200d indeks"
         STDFIEL->fldops1 := "Gem"
         STDFIEL->fldops2 := "200"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "Ave. 200d index"
         STDFIEL->fldhed1 := "Avg"
         STDFIEL->fldhed2 := "200"
         STDFIEL->fldhed3 := "ind"
      else
         STDFIEL->fldbesk := "Gem. 205d indeks"
         STDFIEL->fldops1 := "Gem"
         STDFIEL->fldops2 := "205"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "Ave. 205d index"
         STDFIEL->fldhed1 := "Avg"
         STDFIEL->fldhed2 := "205"
         STDFIEL->fldhed3 := "ind"
      endif

      // Average year index
      seek "SM3DATA GEM365    "
      if lBrep
         STDFIEL->fldbesk := "Gem. 400d indeks"
         STDFIEL->fldops1 := "Gem"
         STDFIEL->fldops2 := "400"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "Ave. 400d index"
         STDFIEL->fldhed1 := "Avg"
         STDFIEL->fldhed2 := "400"
         STDFIEL->fldhed3 := "ind"
      else
         STDFIEL->fldbesk := "Gem. 365d indeks"
         STDFIEL->fldops1 := "Gem"
         STDFIEL->fldops2 := "365"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "Ave. 365d index"
         STDFIEL->fldhed1 := "Avg"
         STDFIEL->fldhed2 := "365"
         STDFIEL->fldhed3 := "ind"
      endif
      // Average 18 month index
      seek "SM3DATA GEM540    "
      if lBrep
         STDFIEL->fldbesk := "Gem. 600d indeks"
         STDFIEL->fldops1 := "Gem"
         STDFIEL->fldops2 := "600"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "Ave. 600d index"
         STDFIEL->fldhed1 := "Avg"
         STDFIEL->fldhed2 := "600"
         STDFIEL->fldhed3 := "ind"
      else
         STDFIEL->fldbesk := "Gem. 540d indeks"
         STDFIEL->fldops1 := "Gem"
         STDFIEL->fldops2 := "540"
         STDFIEL->fldops3 := "ind"
         STDFIEL->flddesc := "Ave. 540d index"
         STDFIEL->fldhed1 := "Avg"
         STDFIEL->fldhed2 := "540"
         STDFIEL->fldhed3 := "ind"
      endif

      // Wean frame
      seek "SM3DATA FRA205    "
      if lBrep
         STDFIEL->fldbesk := "200d raam"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "raa"
         STDFIEL->flddesc := "200d frame"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "fra"
      else
         STDFIEL->fldbesk := "205d raam"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "raa"
         STDFIEL->flddesc := "205d frame"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "fra"
      endif
      // Year frame
      seek "SM3DATA FRA365    "
      if lBrep
         STDFIEL->fldbesk := "400d raam"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "raa"
         STDFIEL->flddesc := "400d frame"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "fra"
      else
         STDFIEL->fldbesk := "365d raam"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "raa"
         STDFIEL->flddesc := "365d frame"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "fra"
      endif
      // 18 month frame
      seek "SM3DATA FRA540    "
      if lBrep
         STDFIEL->fldbesk := "600d raam"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "raa"
         STDFIEL->flddesc := "600d frame"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "fra"
      else
         STDFIEL->fldbesk := "540d raam"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "raa"
         STDFIEL->flddesc := "540d frame"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "fra"
      endif

      // Wean length
      seek "SM3DATA LEN205    "
      if lBrep
         STDFIEL->fldbesk := "200d lengte"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "len"
         STDFIEL->flddesc := "200d length"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "len"
      else
         STDFIEL->fldbesk := "205d lengte"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "len"
         STDFIEL->flddesc := "205d length"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "len"
      endif
      // Year length
      seek "SM3DATA LEN365    "
      if lBrep
         STDFIEL->fldbesk := "400d lengte"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "len"
         STDFIEL->flddesc := "400d length"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "len"
      else
         STDFIEL->fldbesk := "365d lengte"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "len"
         STDFIEL->flddesc := "365d length"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "len"
      endif
      // 18 month length
      seek "SM3DATA LEN540    "
      if lBrep
         STDFIEL->fldbesk := "600d lengte"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "len"
         STDFIEL->flddesc := "600d length"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "len"
      else
         STDFIEL->fldbesk := "540d lengte"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "len"
         STDFIEL->flddesc := "540d length"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "len"
      endif
      // Year scrotum
      seek "SM3DATA SKR365    "
      if lBrep
         STDFIEL->fldbesk := "400d skrotum"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "skr"
         STDFIEL->flddesc := "400d scrotum"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "scr"
      else
         STDFIEL->fldbesk := "365d skrotum"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "skr"
         STDFIEL->flddesc := "365d scrotum"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "scr"
      endif
      // 18 month scrotum
      seek "SM3DATA SKR540    "
      if lBrep
         STDFIEL->fldbesk := "600d skrotum"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "skr"
         STDFIEL->flddesc := "600d scrotum"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "scr"
      else
         STDFIEL->fldbesk := "540d skrotum"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dae"
         STDFIEL->fldops3 := "skr"
         STDFIEL->flddesc := "540d scrotum"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "scr"
      endif

      // Oekdir
      seek "SM3DATA OEKDIR    "
      if lBrep
         STDFIEL->fldbesk := "Dae te kalf ebv"
         STDFIEL->fldops1 := "Dae"
         STDFIEL->fldops2 := "kal"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Days to calf ebv"
         STDFIEL->fldhed1 := "Day"
         STDFIEL->fldhed2 := "cal"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Oud 1e kalf ebv"
         STDFIEL->fldops1 := "Oud"
         STDFIEL->fldops2 := "1ek"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Age 1st calf ebv"
         STDFIEL->fldhed1 := "Age"
         STDFIEL->fldhed2 := "1st"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Oekacc
      seek "SM3DATA OEKACC    "
      if lBrep
         STDFIEL->fldbesk := "Dae te kalf akk"
         STDFIEL->fldops1 := "Dae"
         STDFIEL->fldops2 := "kal"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Days to calf acc"
         STDFIEL->fldhed1 := "Day"
         STDFIEL->fldhed2 := "cal"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Oud 1e kalf akk"
         STDFIEL->fldops1 := "Oud"
         STDFIEL->fldops2 := "1ek"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Age 1st calf acc"
         STDFIEL->fldhed1 := "Age"
         STDFIEL->fldhed2 := "1st"
         STDFIEL->fldhed3 := "acc"
      endif

      // Tkpdir
      seek "SM3DATA TKPDIR    "
      if lBrep
         STDFIEL->fldbesk := "Dragtiglengte ebv"
         STDFIEL->fldops1 := "Dra"
         STDFIEL->fldops2 := "len"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Gestation len ebv"
         STDFIEL->fldhed1 := "Ges"
         STDFIEL->fldhed2 := "len"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Tkp ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Tkp"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Icp ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Icp"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Tkpacc
      seek "SM3DATA TKPACC    "
      if lBrep
         STDFIEL->fldbesk := "Dragtiglengte akk"
         STDFIEL->fldops1 := "Dra"
         STDFIEL->fldops2 := "len"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Gestation len acc"
         STDFIEL->fldhed1 := "Ges"
         STDFIEL->fldhed2 := "len"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Tkp akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Tkp"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Icp acc"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Icp"
         STDFIEL->fldhed3 := "acc"
      endif

      // Eocdir
      seek "SM3DATA EOCDIR    "
      if lBrep
         STDFIEL->fldbesk := "Kalfgemak ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Gvk"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Calving ease ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Eoc"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Kalftempo ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Kte"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Calf rate ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Cra"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Eocacc
      seek "SM3DATA EOCACC    "
      if lBrep
         STDFIEL->fldbesk := "Kalfgemak akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Gvk"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Calving ease acc"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Eoc"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Kalftempo akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Kte"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Calf rate acc"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Cra"
         STDFIEL->fldhed3 := "acc"
      endif

      // Eocmat
      seek "SM3DATA EOCMAT    "
      if lBrep
         STDFIEL->fldbesk := "Kalfgemak mat ebv"
         STDFIEL->fldops1 := "Gvk"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Calving ease mat ebv"
         STDFIEL->fldhed1 := "Eoc"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Kalfgemak ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Gvk"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Calving ease ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Eoc"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Eocacc
      seek "SM3DATA EOCMAC    "
      if lBrep
         STDFIEL->fldbesk := "Kalfgemak mat akk"
         STDFIEL->fldops1 := "Gvk"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Calving ease mat acc"
         STDFIEL->fldhed1 := "Eoc"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Kalfgemak akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Gvk"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Calving ease acc"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Eoc"
         STDFIEL->fldhed3 := "acc"
      endif

      // Gebdir
      seek "SM3DATA BIRDIR    "
      if lBrep
         STDFIEL->fldbesk := "GebMassa ebv"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "massa"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "BirMass ebv"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mass"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "GebMassa ebv"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "massa"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "BirMass ebv"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mass"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Gebacc
      seek "SM3DATA BIRACC    "
      if lBrep
         STDFIEL->fldbesk := "GebMassa akk"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "mas"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "BirMass acc"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mas"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "GebMassa akk"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "mas"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "BirMass acc"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mas"
         STDFIEL->fldhed3 := "acc"
      endif

      // Gebmat
      seek "SM3DATA BIRMAT    "
      if lBrep
         STDFIEL->fldbesk := "GebMassa mat ebv"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "BirMass mat ebv"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "GebMassa mat ebv"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "BirMass mat ebv"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Gebmac
      seek "SM3DATA BIRMAC    "
      if lBrep
         STDFIEL->fldbesk := "GebMassa mat akk"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "BirMass mat acc"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "GebMassa mat akk"
         STDFIEL->fldops1 := "Geb"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "BirMass mat acc"
         STDFIEL->fldhed1 := "Bir"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "acc"
      endif

      // Weadir
      seek "SM3DATA WEADIR    "
      if lBrep
         STDFIEL->fldbesk := "200dag ebv"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "200day ebv"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "205dag ebv"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "205day ebv"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Weaacc
      seek "SM3DATA WEAACC    "
      if lBrep
         STDFIEL->fldbesk := "200dag akk"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "200day acc"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "205dag akk"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "205day acc"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      endif

      // Weamat
      seek "SM3DATA WEAMAT    "
      if lBrep
         STDFIEL->fldbesk := "Maternale waarde ebv"
         STDFIEL->fldops1 := "Mat"
         STDFIEL->fldops2 := "waa"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Maternal value ebv"
         STDFIEL->fldhed1 := "Mat"
         STDFIEL->fldhed2 := "val"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "205dag mat ebv"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "205day mat ebv"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Weamac
      seek "SM3DATA WEAMAC    "
      if lBrep
         STDFIEL->fldbesk := "Maternale waarde akk"
         STDFIEL->fldops1 := "Mat"
         STDFIEL->fldops2 := "waa"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Maternal value acc"
         STDFIEL->fldhed1 := "Mat"
         STDFIEL->fldhed2 := "val"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "205dag mat akk"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "mat"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "205day mat acc"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "mat"
         STDFIEL->fldhed3 := "acc"
      endif

      // Weacom
      seek "SM3DATA WEACOM    "
      if lBrep
         STDFIEL->fldbesk := "200dag melk ebv"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "melk"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "200day milk ebv"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "milk"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "205dag komb ebv"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "komb"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "205day comb ebv"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "comb"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Weacac
      seek "SM3DATA WEACAC    "
      if lBrep
         STDFIEL->fldbesk := "200dag melk akk"
         STDFIEL->fldops1 := "200"
         STDFIEL->fldops2 := "mel"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "200day milk acc"
         STDFIEL->fldhed1 := "200"
         STDFIEL->fldhed2 := "mil"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "205dag komb akk"
         STDFIEL->fldops1 := "205"
         STDFIEL->fldops2 := "komb"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "205day comb acc"
         STDFIEL->fldhed1 := "205"
         STDFIEL->fldhed2 := "com"
         STDFIEL->fldhed3 := "acc"
      endif

      // Yeadir
      seek "SM3DATA YEADIR    "
      if lBrep
         STDFIEL->fldbesk := "400dag ebv"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "400day ebv"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "365dag ebv"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "365day ebv"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Yeaacc
      seek "SM3DATA YEAACC    "
      if lBrep
         STDFIEL->fldbesk := "400dag akk"
         STDFIEL->fldops1 := "400"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "400day acc"
         STDFIEL->fldhed1 := "400"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "365dag akk"
         STDFIEL->fldops1 := "365"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "365day acc"
         STDFIEL->fldhed1 := "365"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      endif

      // M18dir
      seek "SM3DATA M18DIR    "
      if lBrep
         STDFIEL->fldbesk := "600dag ebv"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "600day ebv"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "540dag ebv"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "540day ebv"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      endif

      // M18acc
      seek "SM3DATA M18ACC    "
      if lBrep
         STDFIEL->fldbesk := "600dag akk"
         STDFIEL->fldops1 := "600"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "600day acc"
         STDFIEL->fldhed1 := "600"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "540dag akk"
         STDFIEL->fldops1 := "540"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "540day acc"
         STDFIEL->fldhed1 := "540"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      endif

      // Adgdir
      seek "SM3DATA ADGDIR    "
      if lBrep
         STDFIEL->fldbesk := "900dag ebv"
         STDFIEL->fldops1 := "900"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "900day ebv"
         STDFIEL->fldhed1 := "900"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Gdt ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Gdt"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Adg ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Adg"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Adgacc
      seek "SM3DATA ADGACC    "
      if lBrep
         STDFIEL->fldbesk := "900dag akk"
         STDFIEL->fldops1 := "900"
         STDFIEL->fldops2 := "dag"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "900day acc"
         STDFIEL->fldhed1 := "900"
         STDFIEL->fldhed2 := "day"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Gdt akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Gdt"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Adg acc"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Adg"
         STDFIEL->fldhed3 := "acc"
      endif

      // Kledir
      seek "SM3DATA KLEDIR    "
      if lBrep
         STDFIEL->fldbesk := "Netto voer eff ebv"
         STDFIEL->fldops1 := "Voe"
         STDFIEL->fldops2 := "eff"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Net feed eff ebv"
         STDFIEL->fldhed1 := "Fee"
         STDFIEL->fldhed2 := "eff"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Voerinname ebv"
         STDFIEL->fldops1 := "Voe"
         STDFIEL->fldops2 := "inn"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Feed intake ebv"
         STDFIEL->fldhed1 := "Fee"
         STDFIEL->fldhed2 := "int"
         STDFIEL->fldhed3 := "ebv"
         //STDFIEL->fldbesk := "Kleiber ebv" //Replaced 05-10-18
         //STDFIEL->fldops1 := ""
         //STDFIEL->fldops2 := "Klb"
         //STDFIEL->fldops3 := "ebv"
         //STDFIEL->flddesc := "Kleiber ebv"
         //STDFIEL->fldhed1 := ""
         //STDFIEL->fldhed2 := "Klb"
         //STDFIEL->fldhed3 := "ebv"
      endif

      // Kleacc
      seek "SM3DATA KLEACC    "
      if lBrep
         STDFIEL->fldbesk := "Netto voer eff akk"
         STDFIEL->fldops1 := "Voe"
         STDFIEL->fldops2 := "eff"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Net feed eff ebv"
         STDFIEL->fldhed1 := "Fee"
         STDFIEL->fldhed2 := "eff"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Voerinname akk"
         STDFIEL->fldops1 := "Voe"
         STDFIEL->fldops2 := "inn"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Feed intake acc"
         STDFIEL->fldhed1 := "Fee"
         STDFIEL->fldhed2 := "int"
         STDFIEL->fldhed3 := "acc"
         //STDFIEL->fldbesk := "Kleiber akk" //Repaced 05-10-18
         //STDFIEL->fldops1 := ""
         //STDFIEL->fldops2 := "Klb"
         //STDFIEL->fldops3 := "akk"
         //STDFIEL->flddesc := "Kleiber acc"
         //STDFIEL->fldhed1 := ""
         //STDFIEL->fldhed2 := "Klb"
         //STDFIEL->fldhed3 := "acc"
      endif

      // Pcfcrd
      seek "SM3DATA PCFCRD    "
      if lBrep
         STDFIEL->fldbesk := "Netto voer inn ebv"
         STDFIEL->fldops1 := "Voe"
         STDFIEL->fldops2 := "inn"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Net feed int ebv"
         STDFIEL->fldhed1 := "Fee"
         STDFIEL->fldhed2 := "int"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Voeromset ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Vov"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Feed conv ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Fcr"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Pcfcra
      seek "SM3DATA PCFCRA    "
      if lBrep
         STDFIEL->fldbesk := "Netto voer inn akk"
         STDFIEL->fldops1 := "Voe"
         STDFIEL->fldops2 := "inn"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Net feed int ebv"
         STDFIEL->fldhed1 := "Fee"
         STDFIEL->fldhed2 := "int"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Voeromset akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Vov"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Feed conv acc"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Fcr"
         STDFIEL->fldhed3 := "acc"
      endif

      // Scrdir
      seek "SM3DATA SCRDIR    "
      if lBrep
         STDFIEL->fldbesk := "Skrotum ebv"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "tum"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Scrotum ebv"
         STDFIEL->fldhed1 := "Scr"
         STDFIEL->fldhed2 := "tum"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Skrotum ebv"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "tum"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Scrotum ebv"
         STDFIEL->fldhed1 := "Scr"
         STDFIEL->fldhed2 := "tum"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Scracc
      seek "SM3DATA SCRACC    "
      if lBrep
         STDFIEL->fldbesk := "Skrotum akk"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "tum"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Scrotum acc"
         STDFIEL->fldhed1 := "Scr"
         STDFIEL->fldhed2 := "tum"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Skrotum akk"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "tum"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Scrotum acc"
         STDFIEL->fldhed1 := "Scr"
         STDFIEL->fldhed2 := "tum"
         STDFIEL->fldhed3 := "acc"
      endif

      // Hgtdir
      seek "SM3DATA HGTDIR    "
      if lBrep
         STDFIEL->fldbesk := "Skouerhoogte ebv"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "hoo"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Shoulder height ebv"
         STDFIEL->fldhed1 := "Shr"
         STDFIEL->fldhed2 := "hgt"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Skouerhoogte ebv"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "hoo"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Shoulder height ebv"
         STDFIEL->fldhed1 := "Shr"
         STDFIEL->fldhed2 := "hgt"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Hgtacc
      seek "SM3DATA HGTACC    "
      if lBrep
         STDFIEL->fldbesk := "Skouerhoogte akk"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "hoo"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Shoulder height acc"
         STDFIEL->fldhed1 := "Shr"
         STDFIEL->fldhed2 := "hgt"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Skouerhoogte akk"
         STDFIEL->fldops1 := "Skr"
         STDFIEL->fldops2 := "hoo"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Shoulder height acc"
         STDFIEL->fldhed1 := "Shr"
         STDFIEL->fldhed2 := "hgt"
         STDFIEL->fldhed3 := "acc"
      endif

      // Lgtdir
      seek "SM3DATA LGTDIR    "
      if lBrep
         STDFIEL->fldbesk := "Temperament ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Tem"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Docility ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Doc"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Lengte ebv"
         STDFIEL->fldops1 := "Lig"
         STDFIEL->fldops2 := "len"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Length ebv"
         STDFIEL->fldhed1 := "Bod"
         STDFIEL->fldhed2 := "len"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Lgtacc
      seek "SM3DATA LGTACC    "
      if lBrep
         STDFIEL->fldbesk := "Temperament akk"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Tem"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Docility akk"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Doc"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Lengte akk"
         STDFIEL->fldops1 := "Lig"
         STDFIEL->fldops2 := "len"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Length akk"
         STDFIEL->fldhed1 := "Bod"
         STDFIEL->fldhed2 := "len"
         STDFIEL->fldhed3 := "acc"
      endif

      // Findir
      seek "SM3DATA FINDIR    "
      if lBrep
         STDFIEL->fldbesk := "Vleisopbrengs ebv"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Kvo"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "RetailBeefYield ebv"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Rby"
         STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Voerwinsindeks ebv"
         STDFIEL->fldops1 := "Voer"
         STDFIEL->fldops2 := "wins"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Feed profit index ebv"
         STDFIEL->fldhed1 := "Feed"
         STDFIEL->fldhed2 := "prof"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Finacc
      seek "SM3DATA FINACC    "
      if lBrep
         STDFIEL->fldbesk := "Vleisopbrengs acc"
         STDFIEL->fldops1 := ""
         STDFIEL->fldops2 := "Kvo"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "RetailBeefYield akk"
         STDFIEL->fldhed1 := ""
         STDFIEL->fldhed2 := "Rby"
         STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Voerwinsindeks akk"
         STDFIEL->fldops1 := "Voer"
         STDFIEL->fldops2 := "wins"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Feed profit index acc"
         STDFIEL->fldhed1 := "Feed"
         STDFIEL->fldhed2 := "prof"
         STDFIEL->fldhed3 := "acc"
      endif

      // Mcwdir
      seek "SM3DATA MCWDIR    "
      if lBrep
         //STDFIEL->fldbesk := "Vleisopbrengs ebv"
         //STDFIEL->fldops1 := ""
         //STDFIEL->fldops2 := "Kvo"
         //STDFIEL->fldops3 := "ebv"
         //STDFIEL->flddesc := "RetailBeefYield ebv"
         //STDFIEL->fldhed1 := ""
         //STDFIEL->fldhed2 := "Rby"
         //STDFIEL->fldhed3 := "ebv"
      else
         STDFIEL->fldbesk := "Volwasse massa ebv"
         STDFIEL->fldops1 := "Volw"
         STDFIEL->fldops2 := "mass"
         STDFIEL->fldops3 := "ebv"
         STDFIEL->flddesc := "Mature weight ebv"
         STDFIEL->fldhed1 := "Matu"
         STDFIEL->fldhed2 := "weig"
         STDFIEL->fldhed3 := "ebv"
      endif

      // Finacc
      seek "SM3DATA MCWACC    "
      if lBrep
         //STDFIEL->fldbesk := "Vleisopbrengs acc"
         //STDFIEL->fldops1 := ""
         //STDFIEL->fldops2 := "Kvo"
         //STDFIEL->fldops3 := "akk"
         //STDFIEL->flddesc := "RetailBeefYield akk"
         //STDFIEL->fldhed1 := ""
         //STDFIEL->fldhed2 := "Rby"
         //STDFIEL->fldhed3 := "acc"
      else
         STDFIEL->fldbesk := "Volwasse massa akk"
         STDFIEL->fldops1 := "Volw"
         STDFIEL->fldops2 := "mass"
         STDFIEL->fldops3 := "akk"
         STDFIEL->flddesc := "Mature weight acc"
         STDFIEL->fldhed1 := "Matu"
         STDFIEL->fldhed2 := "weig"
         STDFIEL->fldhed3 := "acc"
      endif

      // Build the own report fields

      // Open the list file
      aCdbf := fATopen(aCdbf,,"STDLIST",,"tdb",,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap

      select STDFIEL
      ordsetfocus("FLDLIST")
      go top

      // Loop to add the fields
      select STDFIEL
      do while !eof()

         // Skip empty numbers
         if STDFIEL->fldlist <= 0
            skip
            loop
         endif

         // Add general heading
         if STDFIEL->fldlist > 998 .and. lGene == .f.
            lGene := .t.
            select STDLIST
            dbappend()
            STDLIST->fldbesk := "Algemene inligting"
            STDLIST->flddesc := "General information"
            STDLIST->fldlist := 998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  999
         endif

         // Add pedigree heading
         if STDFIEL->fldlist > 1497 .and. lPedi == .f.
            lPedi := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 1497
            dbappend()
            STDLIST->fldbesk := "Stamboom inligting"
            STDLIST->flddesc := "Pedigree information"
            STDLIST->fldlist := 1498
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  1499
         endif

         // Add last calf heading
         if STDFIEL->fldlist > 1697 .and. lCalf == .f.
            lCalf := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 1697
            dbappend()
            STDLIST->fldbesk := "Laaste kalf inligting"
            STDLIST->flddesc := "Last calf information"
            STDLIST->fldlist := 1698
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  1699
         endif

         // Add other information heading
         if STDFIEL->fldlist > 1997 .and. lOthe == .f.
            lOthe := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 1997
            dbappend()
            STDLIST->fldbesk := "Ander inligting"
            STDLIST->flddesc := "Other information"
            STDLIST->fldlist := 1998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  1999
         endif

         // Add progeny information heading
         if STDFIEL->fldlist > 2997 .and. lProg == .f.
            lProg := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 2997
            dbappend()
            STDLIST->fldbesk := "Nageslag inligting"
            STDLIST->flddesc := "Progeny information"
            STDLIST->fldlist := 2998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  2999
         endif

         // Add index information heading
         if STDFIEL->fldlist > 3997 .and. lInde == .f.
            lInde := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 3997
            dbappend()
            STDLIST->fldbesk := "Indeks inligting"
            STDLIST->flddesc := "Index information"
            STDLIST->fldlist := 3998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  3999
         endif

         // Add feedlot information heading
         if STDFIEL->fldlist > 4997 .and. lGrow == .f.
            lGrow := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 4997
            dbappend()
            STDLIST->fldbesk := "Voerkraal inligting"
            STDLIST->flddesc := "Feedlot information"
            STDLIST->fldlist := 4998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  4999
         endif

         // Add body information heading
         if STDFIEL->fldlist > 5997 .and. lBody == .f.
            lBody := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 5997
            dbappend()
            STDLIST->fldbesk := "Liggaamsmates"
            STDLIST->flddesc := "Body measurements"
            STDLIST->fldlist := 5998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  5999
         endif

         // Add sales information heading
         if STDFIEL->fldlist > 6997 .and. lSale == .f.
            lSale := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 6997
            dbappend()
            STDLIST->fldbesk := "Verkope"
            STDLIST->flddesc := "Sales"
            STDLIST->fldlist := 6998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  6999
         endif

         // Add breeding values heading
         if STDFIEL->fldlist > 7997 .and. lBree == .f.
            lBree := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 7997
            dbappend()
            STDLIST->fldbesk := "Teelwaardes"
            STDLIST->flddesc := "Breeding values"
            STDLIST->fldlist := 7998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  7999
         endif

         // Add purchases heading
         if STDFIEL->fldlist > 8997 .and. lPurc == .f.
            lPurc := .t.
            select STDLIST
            dbappend()
            STDLIST->fldlist := 8997
            dbappend()
            STDLIST->fldbesk := "Aankope"
            STDLIST->flddesc := "Purchases"
            STDLIST->fldlist := 8998
            dbappend()
            STDLIST->fldbesk :=  "--------------------"
            STDLIST->flddesc :=  "--------------------"
            STDLIST->fldlist :=  8999
         endif

         // Add entry
         select STDLIST
         dbappend()
         STDLIST->dbfname := STDFIEL->dbfname
         STDLIST->fldbesk := STDFIEL->fldbesk
         STDLIST->flddesc := STDFIEL->flddesc
         STDLIST->fldname := STDFIEL->fldname
         STDLIST->fldtype := STDFIEL->fldtype
         STDLIST->fldleng := STDFIEL->fldleng
         STDLIST->flddeci := STDFIEL->flddeci
         STDLIST->fldlist := STDFIEL->fldlist

         // Next record
         select STDFIEL
         skip

      enddo

      // Build the selection group fields

      // Make variables false
      lGene := .f.
      lOthe := .f.
      lProg := .f.
      lInde := .f.
      lGrow := .f.
      lBody := .f.
      lBree := .f.

      // Open the list file
      aCdbf := fATopen(aCdbf,,"STDVELD",,"tdb",,.f.)
      if !aCdbf[len(aCdbf),1]
         break
      endif
      zap

      select STDFIEL
      ordsetfocus("FLDSORT")
      go top

      // Loop to add the fields
      select STDFIEL
      do while !eof()

         // Skip empty numbers
         if STDFIEL->fldsort <= 0
            skip
            loop
         endif

         // Add general heading
         if STDFIEL->fldsort > 998 .and. lGene == .f.
            lGene := .t.
            select STDVELD
            dbappend()
            STDVELD->fldbesk := "Algemene inligting"
            STDVELD->flddesc := "General information"
            STDVELD->fldsort := 998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  999
         endif

         // Add other information heading
         if STDFIEL->fldsort > 1997 .and. lOthe == .f.
            lOthe := .t.
            select STDVELD
            dbappend()
            STDVELD->fldsort := 1997
            dbappend()
            STDVELD->fldbesk := "Ander inligting"
            STDVELD->flddesc := "Other information"
            STDVELD->fldsort := 1998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  1999
         endif

         // Add progeny information heading
         if STDFIEL->fldsort > 2997 .and. lProg == .f.
            lProg := .t.
            select STDVELD
            dbappend()
            STDVELD->fldsort := 2997
            dbappend()
            STDVELD->fldbesk := "Nageslag inligting"
            STDVELD->flddesc := "Progeny information"
            STDVELD->fldsort := 2998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  2999
         endif

         // Add index information heading
         if STDFIEL->fldsort > 3997 .and. lInde == .f.
            lInde := .t.
            select STDVELD
            dbappend()
            STDVELD->fldsort := 3997
            dbappend()
            STDVELD->fldbesk := "Indeks inligting"
            STDVELD->flddesc := "Index information"
            STDVELD->fldsort := 3998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  3999
         endif

         // Add feedlot information heading
         if STDFIEL->fldsort > 4997 .and. lGrow == .f.
            lGrow := .t.
            select STDVELD
            dbappend()
            STDVELD->fldsort := 4997
            dbappend()
            STDVELD->fldbesk := "Voerkraal inligting"
            STDVELD->flddesc := "Feedlot information"
            STDVELD->fldsort := 4998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  4999
         endif

         // Add body information heading
         if STDFIEL->fldsort > 5997 .and. lBody == .f.
            lBody := .t.
            select STDVELD
            dbappend()
            STDVELD->fldsort := 5997
            dbappend()
            STDVELD->fldbesk := "Liggaamsmates"
            STDVELD->flddesc := "Body measurements"
            STDVELD->fldsort := 5998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  5999
         endif

         // Add breeding values heading
         if STDFIEL->fldsort > 7997 .and. lBree == .f.
            lBree := .t.
            select STDVELD
            dbappend()
            STDVELD->fldsort := 7997
            dbappend()
            STDVELD->fldbesk := "Teelwaardes"
            STDVELD->flddesc := "Breeding values"
            STDVELD->fldsort := 7998
            dbappend()
            STDVELD->fldbesk :=  "--------------------"
            STDVELD->flddesc :=  "--------------------"
            STDVELD->fldsort :=  7999
         endif

         // Add entry
         select STDVELD
         dbappend()
         STDVELD->dbfname := STDFIEL->dbfname
         STDVELD->fldbesk := STDFIEL->fldbesk
         STDVELD->flddesc := STDFIEL->flddesc
         STDVELD->fldname := STDFIEL->fldname
         STDVELD->fldtype := STDFIEL->fldtype
         STDVELD->fldleng := STDFIEL->fldleng
         STDVELD->flddeci := STDFIEL->flddeci
         STDVELD->fldsort := STDFIEL->fldsort

         // Next record
         select STDFIEL
         skip

      enddo

      // Open drives file
      //aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      //altd()
      //if !aCdbf[len(aCdbf),1]
      //   break
      //endif
      //do while !rlock()
      //   STDWAAR->herdno := cBcod
      //enddo

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return NIL
