// SM3SEKG.PRG
// Program om diere se inligting te vra - net sekere inligting
// Kopiereg (C) 1992 A van Rensburg
// 10:20 25 Mar,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3sekg(aVeld,cTest)

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := {}
   local aCdbf := fATopen()
   local aRecv := {}
   local cIndf := cDd()+"TEMP"+ordbagext()
   local cIdnr := ""
   local lLoop := .t.
   local i     := 1
   local nBoxc := 1

   begin sequence
      // Screen
      if cLanType() == "A"
	      fScrOpsk(,"Opsie "+cOption())
      else
          fScrOpsk(,"Option "+cOption())
      endif

      aCscr := fASaveScr()

      // Delete the temporary index file
      if file(cIndf)
         ferase(cIndf)
      endif

      // The get structure
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrWbood(maxrow(),"Screen outlay being determined")
      endif
      aRecv := fGetField(aVeld)

      // Open the file
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Datalˆers word geopen")
      else
         fScrWbood(maxrow(),"Data files being opened")
      endif

      // Where is animal codes
      aCdbf := fATopen(aCdbf,cDd(),"SM3WAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Remarks
      aCdbf := fATopen(aCdbf,cDd(),"SM3OPMK")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Reasons
      aCdbf := fATopen(aCdbf,cDd(),"SM3REDE")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Hoofleer
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // Build a new index only if group or selection group
      if !empty(cTest)

         // Close the index
         set index to

         // Build a new index
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            fScrWbood(maxrow(),"Diere word uitgesoek")
         else
         endif
         index on SM3DATA->idnr to (cIndf) for &(cTest)
         set index to (cIndf)

      endif

      // The database
      select SM3DATA
      go top

      // The loop to display the animals
      lLoop := .t.
      do while lLoop

         // Ask the Id number if single
         if empty(cTest)
            // Fill empty Id number
            cIdnr := space(12)

            nBoxc := fBoxCent(12,space(33),1)
            select SM3DATA
            cIdnr := sm3idnr(cIdnr,12,nBoxc,,,,.t.)

            do case

               case left(cIdnr,9) == "CANCELLED"
                  lLoop := .f.
                  loop

               case left(cIdnr,3) == "NOT"
                  lLoop := .f.
                  loop

            endcase

            seek cIdnr
            if eof()
               dbappend()
               SM3DATA->idnr := cIdnr
            endif

         else

            cIdnr := SM3DATA->idnr

         endif

         // Fill with data
         for i = 1 to len(aRecv)
            aRecv[i,FLD_CARG] := fieldget(aRecv[i,FLD_NUMB])
         next

         // Display the data
         if cLanType() == "A"
            fBox(3,1,maxrow()-3,maxcol()-2,"SEKERE INLIGTING   - "+TRIM(cIdnr),cColNorm())
         else
            fBox(3,1,maxrow()-3,maxcol()-2,"CERTAIN INFORMATION     - "+TRIM(cIdnr),cColNorm())
         endif

         // The get
         for i := 1 to 16
            if i <= len( aRecv )
               if aRecv[i,FLD_NAME] == "UITKREDE"
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fWuitkrede()) ;
                     valid(fVuitkrede(getlist,aRecv))
               elseif aRecv[i,FLD_NAME] == "OPMERKING1"
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fWopmerk1()) ;
                     valid(fVopmerk1(getlist,aRecv))
               elseif aRecv[i,FLD_NAME] == "OPMERKING2"
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fWopmerk2()) ;
                     valid(fVopmerk2(getlist,aRecv))
               elseif aRecv[i,FLD_NAME] == "REDEUI"
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fWredeui()) ;
                     valid(fVredeui(getlist,aRecv))
               elseif aRecv[i,FLD_NAME] == "INDEKSKODE"
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fWindekskode()) ;
                     valid(fVindekskode(getlist,aRecv))
               elseif aRecv[i,FLD_NAME] == "FASEKODE"
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fWfasekode()) ;
                     valid(fVfasekode(getlist,aRecv))
               else
                  @4+i,4 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                     pict aRecv[i,FLD_PICT] ;
                     when(fMessage())
               endif
            endif
         next

         if len(aRecv) >= 17
            for i := 17 to 32
               if i <= len( aRecv )
                  if aRecv[i,FLD_NAME] == "UITKREDE"
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fWuitkrede()) ;
                        valid(fVuitkrede(getlist,aRecv))
                  elseif aRecv[i,FLD_NAME] == "OPMERKING1"
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fWopmerk1()) ;
                        valid(fVopmerk1(getlist,aRecv))
                  elseif aRecv[i,FLD_NAME] == "OPMERKING2"
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fWopmerk2()) ;
                        valid(fVopmerk2(getlist,aRecv))
                  elseif aRecv[i,FLD_NAME] == "REDEUI"
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fWredeui()) ;
                        valid(fVredeui(getlist,aRecv))
                  elseif aRecv[i,FLD_NAME] == "INDEKSKODE"
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fWindekskode()) ;
                        valid(fVindekskode(getlist,aRecv))
                  elseif aRecv[i,FLD_NAME] == "FASEKODE"
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fWfasekode()) ;
                        valid(fVfasekode(getlist,aRecv))
                  else
                     @i-12,41 say aRecv[i,FLD_DESC] get aRecv[i,FLD_CARG] ;
                        pict aRecv[i,FLD_PICT] ;
                        when(fMessage())
                  endif
               endif
            next
         endif

         // The read
         setcursor(1)
         read
         setcursor(0)

         // Save the data
         if updated()

            do while !rlock()
            enddo

            for i := 1 to len(aRecv)
               fieldput(aRecv[i,FLD_NUMB],aRecv[i,FLD_CARG])
            next

            commit

         endif

         // Key handling
         if !empty(cTest)

            // Groups
            do case

               case lastkey() == K_ESC
                  // Menu
                  lRetu := .f.
                  break

               case lastkey() == K_PGUP
                  // Previous animal
                  skip -1
                  if bof()
                     go top
                  endif
                  cIdnr := SM3DATA->idnr

               otherwise
                  // Next animal
                  skip
                  if eof()
                     go bottom
                  endif
                  cIdnr := SM3DATA->idnr

            endcase

         else

            // Single animals
            do case

               case lastkey() == K_ESC
                  //Menu
                  lRetu := .f.
                  break

            endcase

         endif

      enddo

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fMessage

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"            [PgUp]=Vorige dier  ")
      fScrBood(maxrow()  ,"[Esc]=Menu  [PgDn]=Volgende dier")
   else
      fScrBood(maxrow()-1,"            [PgUp]=Previous animal")
      fScrBood(maxrow()  ,"[Esc]=Menu  [PgDn]=Next animal    ")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWuitkrede

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Vorige dier                          ")
      fScrBood(maxrow()  ,"            [PgDn]=Volgende dier  "+D_DNARR+"=Waar-is-dier kodes")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Previous animal                           ")
      fScrBood(maxrow()  ,"            [PgDn]=Next animal      "+D_DNARR+"=Where-is-animal codes")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitkrede(aGetl,aFiel)

   // Function to test the where is animal code existance

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nWaar := fEnum(aFiel,"uitkrede")
   local cWaar := ""
   local aVeld := {}

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         asize( aVeld, 0 )
         aadd( aVeld, { "sm3waar", "kode" })
         aadd( aVeld, { "sm3waar", "besk" })
         if empty(aGetl[nWaar]:varget())
            cWaar := sm3waar(6,8,maxrow()-3,aVeld)
         else
            cWaar := sm3waar(6,8,maxrow()-3,aVeld,aGetl[nWaar]:varget())
         endif

         // Update get
         if !empty(cWaar)
            aGetl[nWaar]:varput(cWaar)
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu


/******************************************************************************/
STATIC FUNCTION fWopmerk1

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Vorige dier                       ")
      fScrBood(maxrow()  ,"            [PgDn]=Volgende dier  "+D_DNARR+"=Opmerkingskodes")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Previous animal                  ")
      fScrBood(maxrow()  ,"            [PgDn]=Next animal      "+D_DNARR+"=Remark codes")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVopmerk1(aGetl,aFiel)

   // Function to test the remarks 1 field

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nOpmk := fEnum(aFiel,"opmerking1")
   local cOpmk := ""
   local aVeld := {}

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         asize( aVeld, 0 )
         aadd( aVeld, { "sm3opmk", "kode" })
         aadd( aVeld, { "sm3opmk", "besk" })
         if empty(left(aGetl[nOpmk]:varget(),2))
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld)
         else
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld,left(aGetl[nOpmk]:varget(),2))
         endif

         // Update get
         if !empty(cOpmk)
            if cOpmk $ aGetl[nOpmk]:varget()
            else
               aGetl[nOpmk]:varput(strtran(aGetl[nOpmk]:varget(),"  ",cOpmk,1,1))
            endif
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWopmerk2

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Vorige dier                       ")
      fScrBood(maxrow()  ,"            [PgDn]=Volgende dier  "+D_DNARR+"=Opmerkingskodes")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Previous animal                  ")
      fScrBood(maxrow()  ,"            [PgDn]=Next animal      "+D_DNARR+"=Remark codes")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVopmerk2(aGetl,aFiel)

   // Function to test the remarks 2 field

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nOpmk := fEnum(aFiel,"opmerking2")
   local cOpmk := ""
   local aVeld := {}

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         asize( aVeld, 0 )
         aadd( aVeld, { "sm3opmk", "kode" })
         aadd( aVeld, { "sm3opmk", "besk" })
         if empty(left(aGetl[nOpmk]:varget(),2))
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld)
         else
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld,left(aGetl[nOpmk]:varget(),2))
         endif

         // Update get
         if !empty(cOpmk)
            if cOpmk $ aGetl[nOpmk]:varget()
            else
               aGetl[nOpmk]:varput(strtran(aGetl[nOpmk]:varget(),"  ",cOpmk,1,1))
            endif
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWredeui

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Vorige dier                   ")
      fScrBood(maxrow()  ,"            [PgDn]=Volgende dier  "+D_DNARR+"=Afkeurredes")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Previous animal                     ")
      fScrBood(maxrow()  ,"            [PgDn]=Next animal      "+D_DNARR+"=Rejection codes")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVredeui(aGetl,aFiel)

   // Function to test the rejection reason existance

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRede := fEnum(aFiel,"redeui")
   local cRede := ""

   // Call the reasons window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         cRede := sm3rede(6,8,,,left(aGetl[nRede]:varget(),2))

         // Update get
         if !empty(cRede)
            if cRede $ aGetl[nRede]:varget()
            else
               aGetl[nRede]:varput(strtran(aGetl[nRede]:varget(),"  ",cRede,1,1))
            endif
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWindekskode

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Vorige dier                  ")
      fScrBood(maxrow()  ,"            [PgDn]=Volgende dier  "+D_DNARR+"=Indekskode")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Previous animal                ")
      fScrBood(maxrow()  ,"            [PgDn]=Next animal      "+D_DNARR+"=Index code")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVindekskode(aGetl,aFiel)

   // Function to test index group existance

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nInde := fEnum(aFiel,"indekskode")
   local cInde := ""

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         if empty(aGetl[nInde]:varget())
            cInde := sm3indg(6,8,maxrow()-3)
         else
            cInde := sm3indg(6,8,maxrow()-3,,aGetl[nInde]:varget())
         endif

         // Update get
         if !empty(cInde)
            aGetl[nInde]:varput(cInde)
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWfasekode

   // Declare
   local lRetu := .t.

   // The message
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Vorige dier                ")
      fScrBood(maxrow()  ,"            [PgDn]=Volgende dier  "+D_DNARR+"=Fasekode")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  [PgUp]=Previous animal                 ")
      fScrBood(maxrow()  ,"            [PgDn]=Next animal      "+D_DNARR+"=Phase group")
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fVfasekode(aGetl,aFiel)

   // Function to test phase group existance

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nFase := fEnum(aFiel,"fasekode")
   local cFase := ""

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         if empty(aGetl[nFase]:varget())
            cFase := sm3fasg(6,8,maxrow()-3)
         else
            cFase := sm3fasg(6,8,maxrow()-3,,aGetl[nFase]:varget())
         endif

         // Update get
         if !empty(cFase)
            aGetl[nFase]:varput(cFase)
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
