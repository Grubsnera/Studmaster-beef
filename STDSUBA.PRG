//STDSUBA.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//11:58 23 Aug,1991

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
FUNCTION StdSuba()

   local nch    := 1
   local aCscr  := {}
   local aVelde := {}
   local cDummy

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif


   do while TRUE
      //Sluit alle .dbf leers
      dbcloseall()

      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Hoofmenu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " keys and press " + D_ENTER + ". Press [Esc] for the Main menu." )
      endif

      // Kry opsienommer
      nCh := fNewMenu( nCh, "STDSUBA" )
      cOption(nCh)
      aCscr := fASaveScr()

      do case
         case nCh = 1
            //Bewaar inligting
            sm3edit()

         case nCh = 2
            //Bewaar dekkings
            sm3ssab()

         case nCh = 3
            //Deklyste
            sm3ssac()

         case nCh = 4
            //Nuwe geboortes
            sm3gebo()

         case nCh = 5
            //Verkorte deklys
            //Vra die teelgroep
            cDummy := sm3teeg()
            if len(alltrim(cDummy)) > 0
               //Bewaar syfers in dekleer
               if sm3deca(cDummy)
                  //Bereken totale en vertoon
                  if sm3opca(cDummy)
                     sm3opdi()
                  endif
               endif
            endif

         case nCh = 6
            //Volledige dekkings aksielys
            sm3deku()

         case nCh = 7
            //Druk geboortekennisgewings
            aSize(aVelde,0)
            aadd( aVelde, { "sm3tydi", "idnr" })
            aadd( aVelde, { "sm3data", "geslag" })
            aadd( aVelde, { "sm3data", "gebdatum" })
            aadd( aVelde, { "sm3data", "generasie" })
            aadd( aVelde, { "sm3data", "idvaar" })
            aadd( aVelde, { "sm3data", "idmoer" })
            aadd( aVelde, { "sm3data", "kalfbnr" })
            aadd( aVelde, { "sm3data", "gebstat" })
            aadd( aVelde, { "sm3data", "tweeling" })
            aadd( aVelde, { "sm3data", "niereg" })
            aadd( aVelde, { "sm3data", "vaarkode" })
            aadd( aVelde, { "sm3data", "ident" })
            aadd( aVelde, { "sm3data", "kalfstat" })
            aadd( aVelde, { "sm3data", "kalfgem" })
            aadd( aVelde, { "sm3data", "subafd" })
            aadd( aVelde, { "sm3data", "gebmassa" })
            aadd( aVelde, { "sm3data", "tipies" })
            aadd( aVelde, { "sm3data", "bloednr" })
            aadd( aVelde, { "sm3data", "mamoergeb" })
            aadd( aVelde, { "sm3data", "idnaam" })
            sm3gebk(3,2,20,aVelde)

         case nCh = 8
            //Begeleidingsbrief
            sm3bege()

         case nCh = 9
            // Import registration numbers
            sm3ireg()

         case nCh = 10
            //Kalfseisoene
            sm3tedi()

         case nCh = 11
            //Verkorte deklys
            //Vra die teelgroep
            cDummy := sm3teeg()
            if len(alltrim(cDummy)) > 0
               //Bewaar syfers in dekleer
               if sm3deca(cDummy)
                  //Bereken totale en vertoon
                  sm3opdv(cDummy)
               endif
            endif

         otherwise
            // Exit to hoofmenu
            cOption(-1)
            exit

      endcase

      //Herstel menu
      fARestScr(aCscr)
      cOption(-1)
   enddo

return NIL
