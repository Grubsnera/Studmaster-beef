// Application: StudMaster for Beef Cattle
//   File Name: SM3OWNR.PRG
// Description: Program to display own reports
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 10-19-95      11:49:21am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3ownr

   //Veranderlikes
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local aSend := {}
   local aRecv := {}
   local nWatt := 1
   local nGesl := 3
   local nLeer := 1
   local cFile := cDd()+"sm3ownr.dbf"
   local cMemf := ""
   local cData := ""
   local cOwnr := ""
   local nMin  := 0
   private cTest := ""
   private cXvko := ""
   private cXvbe := ""
   private cXsko := ""
   private cXsbe := ""

   begin sequence

      //Skerm
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      //Kry mem waardes
      cMemf := cDd()+"sm3ownr.mem"
      if file(cMemf)
         restore from (cMemf) additive
      endif

      //Vra die verslag verlang
      aSend := sm3eiev()
      if len(aSend) == 0
         lRetu := .f.
         break
      endif

      //Kry verslag waardes vanuit die mem leer
      cMemf := cDd()+"sm3eiev.mem"
      restore from (cMemf) additive
      cXvko := cMkod
      cXvbe := cMbes
      cMemf := cDd()+"sm3ownr.mem"
      save all like cX* to (cMemf)

      //Vertoon menu om te vra groep ensovoorts
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
      endif
      nWatt := fNewMenu(nWatt,"OWNRWATT")
      fScrBood(23)
      nMin++

      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nWatt))
      else
         fScrOpsk(1,"Option "+cOption(nWatt))
      endif

      aCscr := fASaveScr()

      do case

         case nWatt == 1
            //Indeksgroep
            //Kry die indeksgroep
            cTest := sm3indg(4)
            if len(trim(cTest)) == 0
               if cLanType() == "A"
                  fScrWait(24,"Geen indeksgroep is gekies nie!")
               else
                  fScrWait(24,"No index group was selected!")
               endif
               lRetu := .f.
               break
            endif
            //Mem veranderlikes
            if cLanType() == "A"
               cXsko := "Indeksgroep"
               cXsbe := trim(cTest) + " Indeksgroep"
            else
               cXsko := "Index group"
               cXsbe := trim(cTest) + " Index group"
            endif
            cMemf := cDd()+"sm3ownr.mem"
            save all like cX* to (cMemf)
         case nWatt == 2
            //Fasegroep
            //Kry die fasegroep
            cTest := sm3fasg(4)
            if len(trim(cTest)) == 0
               if cLanType() == "A"
                  fScrWait(24,"Geen fasegroep is gekies nie!")
               else
                  fScrWait(24,"No phase group was selected!")
               endif
               lRetu := .f.
               break
            endif
            //Mem veranderlikes
            if cLanType() == "A"
               cXsko := "Fasegroep"
               cXsbe := trim(cTest) + " Fasegroep"
            else
               cXsko := "Phase group"
               cXsbe := trim(cTest) + " Phase group"
            endif
            cMemf := cDd()+"sm3ownr.mem"
            save all like cX* to (cMemf)
         case nWatt == 3
            //Groep
            cTest := sm3groe()
            if len(trim(cTest)) == 0
               if cLanType() == "A"
                  fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No group selection requirements have been specified!")
               endif
               lRetu := .f.
               break
            endif
            //Mem veranderlikes
            if cLanType() == "A"
               cXsko := "Groep"
               cXsbe := "Groep diere"
            else
               cXsko := "Group"
               cXsbe := "Group animals"
            endif
            cMemf := cDd()+"sm3ownr.mem"
            save all like cX* to (cMemf)
         case nWatt == 4
            //Seleksiegroep
            cTest := sm3selg()
            if len(trim(cTest)) == 0
               if cLanType() == "A"
                  fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No selection group requirements have been specified!")
               endif
               lRetu := .f.
               break
            endif
            //Kry mem besonderhede
            cMemf := cDd()+"sm3selg.mem"
            restore from (cMemf) additive
            //Mem veranderlikes
            cXsko := cMkod
            cXsbe := cMbes
            cMemf := cDd()+"sm3ownr.mem"
            save all like cX* to (cMemf)
         case nWatt == 5
            //Vorige groep
            //Kyk of leer bestaan
            if !file(cDd()+"sm3ownr.dbf")
               if cLanType() == "A"
                  fScrWait(24,"Geen vorige geselekteerde groep diere bestaan nie!")
               else
                  fScrWait(24,"No previously selected group of animals exists!")
               endif
               lRetu := .f.
               break
            endif
            //Kry mem waardes
            cMemf := cDd()+"sm3ownr.mem"
            restore from (cMemf) additive
         otherwise
            lRetu := .f.
            break
      endcase

      fARestScr(aCscr)

      //Net in geval van indeksgroep
      if nWatt == 1
         //Vertoon menu om te vra watter geslag
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
         endif
         nGesl := fNewMenu(nGesl,"OWNRGESL")
         fScrBood(23)
         nMin++

         if cLanType() == "A"
            fScrOpsk(1,"Opsie "+cOption(nGesl))
         else
            fScrOpsk(1,"Option "+cOption(nGesl))
         endif

         do case
            case nGesl == 1
               //Vroulik
            case nGesl == 2
               //Manlik
            case nGesl == 3
               //Albei
            otherwise
               lRetu := .f.
               break
         endcase

      elseif nWatt == 2
         //Fasegroep - doen niks
      elseif nWatt == 5
         //Vorige groep - doen niks
      else
         //Vertoon menu om te vra watter leer
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
         endif
         nLeer := fNewMenu(nLeer,"OWNRLEER")
         fScrBood(23)
         nMin++

         if cLanType() == "A"
            fScrOpsk(1,"Opsie "+cOption(nLeer))
         else
            fScrOpsk(1,"Option "+cOption(nLeer))
         endif

         do case
            case nLeer == 1
               //In kudde diere
            case nLeer == 2
               //Alle diere
            otherwise
               lRetu := .f.
               break
         endcase
      endif

      //Skerm
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Diere word uitgesoek")
      else
         fScrWbood(24,"Animals being sorted")
      endif

      //Open dataleers
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif

      //Net in geval van indeksgroep
      if nWatt == 1
         //Kies die regte indeks
         set order to 3
         //Soek die indeksgroep
         seek cTest
         //Skep die tydelike leer
         copy to (cFile) fields idnr,idnaam while SM3DATA->indekskode == cTest
         //Herstel indeks
         select SM3DATA
         set order to 1
      elseif nWatt == 2
         //Kies die regte indeks
         set order to 2
         //Soek die fasegroep
         seek cTest
         //Skep die tydelike leer
         copy to (cFile) fields idnr,idnaam while SM3DATA->fasekode == cTest
         //Herstel indeks
         select SM3DATA
         set order to 1
      elseif nWatt == 5
         //Vorige groep - doen niks
      else
         if nLeer == 2
            //Hele leer
            //Skep die tydelike leer
            copy to (cFile) fields idnr,idnaam for &cTest
         else
            //Slegs in kudde diere
            //Skep die tydelike leer
            set order to 7
            copy to (cFile) fields idnr,idnaam for &cTest
            select SM3DATA
            set order to 1
         endif
      endif

      // Delete the temp file index before opening
      ferase(cDd()+"sm3ownr"+cIndeExt())

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"SM3VAAR")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"SM3MOER")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA",,,"SM3KALF")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif

      // Set realtions into the main file
      select SM3DATA
      dbsetrelation("SM3VAAR",{|| SM3DATA->idvaar },"SM3DATA->idvaar")
      dbsetrelation("SM3MOER",{|| SM3DATA->idmoer },"SM3DATA->idmoer")
      dbsetrelation("SM3KALF",{|| SM3DATA->lkalfn },"SM3DATA->lkalfn")

      //Open die tydelike leer
      aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif
      DBSELECTAREA("SM3WEEG")
      ORDSETFOCUS(2)                             // to get latest weigh date

      //aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
      //if !aCdbf[len(aCdbf),DBF_NAME]
      //   break
      //endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3AANK")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3OWNR")
      if !aCdbf[len(aCdbf),DBF_NAME]
         break
      endif

      //Kyk of daar diere bestaan
      if lastrec() == 0
         if cLanType() == "A"
            fScrBood(23,"Geen diere is gevind om te vertoon/druk!")
         else
            fScrBood(23,"No animals were found to display/print!")
         endif
         fScrWait(24)
         lRetu := .f.
         break
      endif

      //Stel relation
      dbsetrelation("SM3DATA",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
      dbsetrelation("SM3WEEG",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
      dbsetrelation("SM3AANK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
      dbsetrelation("SM3VERK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
      go top

      //Net in geval van indeksgroep
      if nWatt == 1
         //Verwyder ongewenste diere
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Ongewenste diere word geskrap")
         else
            fScrWbood(24,"Animals not required being deleted")
         endif
         do while !eof()
            do while !rlock()
            enddo
            if nGesl == 1 .and. SM3DATA->geslag $ "23"
               delete
               skip
               loop
            endif
            if nGesl == 2 .and. SM3DATA->geslag == "1"
               delete
               skip
               loop
            endif
            skip
         enddo
         go top
      endif

      //Vertoon die diere
      fDisplay(,,,aSend)

   end

   //Herstel
   if nMin != 0
      cOption(-nMin)
   endif

   fARestScr(aCdbf)
   fATclose(aCdbf)

return NIL

/******************************************************************************/
STATIC FUNCTION fDisplay( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local aAksi := {}
   local cAksi := ""
   local cAksk := ""
   local nAksi := 0
   local cCoun := ""
   local nMenu := 0

   private cData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif
   else
      if cLanType() == "A"
         fScrOpsk(1, "Opsie "+cOption())
      else
         fScrOpsk(1, "Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 4, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,21, nBott )
   if aSend == NIL
      return NIL
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField(aSend)

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,FLD_LENG] + 1
      //Kolomme
      cData := aRecv[i,DBF_NAME] + aRecv[i,FLD_NAME]
      cHead := aRecv[i,FLD_HED1] + ";" + aRecv[i,FLD_HED2] + ";" + aRecv[i,FLD_HED3]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop-1, nLeft, nTop , nRigh, "Verslag : "+padr(cXvbe,60) )
      fBox( nTop  , nLeft, nBott, nRigh, "Seleksie: "+padr(cXsbe,60) )
      //setcolor(cColBott())
      //@nBott,nLeft+2 say ltrim(str(lastrec()))+ " diere geselekteer"
      //setcolor(cColNorm())
   else
      fBox( nTop-1, nLeft, nTop , nRigh, "Report   : "+padr(cXvbe,60) )
      fBox( nTop  , nLeft, nBott, nRigh, "Selection: "+padr(cXsbe,60) )
      //setcolor(cColBott())
      //@nBott,nLeft+2 say ltrim(str(lastrec()))+ " animals selected"
      //setcolor(cColNorm())
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   //Vries
   bBrow:freeze := 1

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[Esc]=Menu  [Alt S]=Sorteer  [Alt P]=Druk         [A-Z ]=Vind    ")
         fScrBood( 24, "[F1 ]=Hulp  [Alt A]=Aksies   [Alt G]=Gemiddeldes  [AltF]=SkepLˆer")
      else
         fScrBood( 23, "[Esc]=Menu  [Alt S]=Sort     [Alt P]=Print     [A-Z ]=Find      ")
         fScrBood( 24, "[F1 ]=Help  [Alt A]=Actions  [Alt G]=Averages  [AltF]=ExportData")
      endif

      // Stabilize
      FullStabilize(bBrow)

      // Display the record number
      cCoun := padl(ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount())),10,chr(205))
      @nBott,nRigh-(len(cCoun)+1) say cCoun

      // Wait for keypress
      if bBrow:stable
         nKeyp := inkey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecv)
         bBrow:refreshall()

      elseif nKeyp == K_ALT_G .or. nKeyp == K_ALT_B .or. nKeyp == K_ALT_W
         //Alt G means calculate averages
         if fAverage(aRecv,bBrow)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_S
         //Alt S means sort
         if fSort(aRecv,bBrow:colpos)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_A
         //Vertoon menu met verdere aksies
         if "IDNAAM" $ aRecv[bBrow:colpos,FLD_NAME]
            cAksi := trim(SM3DATA->idnaam)
         elseif "IDMOER" $ aRecv[bBrow:colpos,FLD_NAME]
            cAksi := trim(SM3DATA->idmoer)
         elseif "IDVAAR" $ aRecv[bBrow:colpos,FLD_NAME]
            cAksi := trim(SM3DATA->idvaar)
         else
            cAksi := trim(SM3DATA->idnr)
         endif
         //Bou array
         asize(aAksi,0)
         if cLanType() == "A"
            aadd(aAksi,padr(cAksi+" se nageslag opsomming (Alt N)",45))
            aadd(aAksi,padr(cAksi+" se uitgebreide stamboom (Alt U)",45))
            aadd(aAksi,padr(cAksi+" se algehele opsomming (Alt O)",45))
         else
            aadd(aAksi,padr(cAksi+" progeny report (Alt N)",45))
            aadd(aAksi,padr(cAksi+" extended pedigree (Alt U)",45))
            aadd(aAksi,padr(cAksi+" general summary (Alt O)",45))
         endif
         //Vertoon array
         cAksk := savescreen(0,0,24,79)
         if cLanType() == "A"
            nAksi := fBoxCent(11,space(45),3,"Aksies",cColMenu())
         else
            nAksi := fBoxCent(11,space(45),3,"Actions",cColMenu())
         endif
         nAksi := achoice(11,nAksi,13,nAksi+45,aAksi)
         do case
            case nAksi == 1
               keyboard chr(K_CTRL_N)
            case nAksi == 2
               keyboard chr(K_CTRL_U)
            case nAksi == 3
               keyboard chr(K_CTRL_O)
         endcase
         restscreen(0,0,24,79,cAksk)

      elseif nKeyp == K_ALT_N .or. nKeyp == K_CTRL_N
         //Alt N means display progeny summary
         if "IDNAAM" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3prog(SM3DATA->idnaam)
         elseif "IDMOER" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3prog(SM3DATA->idmoer)
         elseif "IDVAAR" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3prog(SM3DATA->idvaar)
         else
            sm3prog(SM3DATA->idnr)
         endif
         select SM3OWNR
         dbsetrelation("SM3DATA",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3WEEG",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3AANK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3VERK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")

      elseif nKeyp == K_ALT_U .or. nKeyp == K_CTRL_U
         //Alt U means display stamboom
         if "IDNAAM" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3pedi(SM3DATA->idnaam)
         elseif "IDMOER" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3pedi(SM3DATA->idmoer)
         elseif "IDVAAR" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3pedi(SM3DATA->idvaar)
         else
            sm3pedi(SM3DATA->idnr)
         endif
         select SM3OWNR
         dbsetrelation("SM3DATA",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3WEEG",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3AANK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3VERK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")

      elseif nKeyp == K_ALT_O .or. nKeyp == K_CTRL_O
         //Alt O means display stamboom
         if "IDNAAM" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3voll(SM3DATA->idnaam)
         elseif "IDMOER" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3voll(SM3DATA->idmoer)
         elseif "IDVAAR" $ aRecv[bBrow:colpos,FLD_NAME]
            sm3voll(SM3DATA->idvaar)
         else
            sm3voll(SM3DATA->idnr)
         endif
         select SM3OWNR
         dbsetrelation("SM3DATA",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3WEEG",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3AANK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")
         dbsetrelation("SM3VERK",{|| SM3OWNR->idnr },"SM3OWNR->idnr")

      elseif nKeyp == K_ALT_F

         // Alt F means create file

         // Display menu
         cAksk := savescreen(0,0,24,79)
         if cLanType() == "A"
            fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Hoofmenu." )
         else
            fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Main menu." )
         endif
         fScrBood(maxrow())
         // Kry opsienommer
         nMenu := fNewMenu( nMenu, "SM3OWNREX" )
         restscreen(0,0,24,79,cAksk)
         // The choices
         do case
            case nMenu = 1

               // Export to normal text file
               if fDiskette(aRecv)
                  bBrow:refreshall()
               endif

            case nMenu = 2

               // Export to palmtop file
               if fPalmtop(aRecv)
                  bBrow:refreshall()
               endif
               if fPalmtopPedigree(aRecv)
                  bBrow:refreshall()
               endif

            otherwise

               // Return
               bBrow:refreshall()

         endcase

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_F1
         // Help
         do help with "SM3OWNR",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
return NIL

/******************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local cData := ""
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cData := upper(chr(nKeyp)) + space(11)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+12),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+12),3,"FIND")
   endif

   //Vra die veld
   if cLanType() == "A"
      @12,nBoxc say "            Id nommer" get cData pict "@!"
   else
      @12,nBoxc say "            Id number" get cData pict "@!"
   endif
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cData == space(12)
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   go top
   locate for trim(cData) $ SM3OWNR->idnr
   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Verklaar
   local aCscr := fASaveScr()
   local lLoop := .t.
   local nI    := 1
   local cData := ""
   local aSend := {}
   local cText := ""
   local lDoub := .f.
   local lNumb := .f.
   local nChoi := 1
   local cHdl1 := ""
   local cHdl2 := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local lAver := .f.
   local nFiel := 0
   local cFiel := ""
   local dFiel := ctod("")

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return NIL
   endif

   // Ask for double spacing or not
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Lys van diere")
   else
      fScrBood(maxrow()-1,"[Esc]=List of animals")
   endif
   nChoi := fNewMenu(1,"OWNRDOUB")

   if nChoi == 1
      // No spacing
   elseif nChoi == 2
      // With spacing
      lDoub := .t.
   else
      // Exit
      return NIL
   endif

   // Ask for line numbers or not
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Lys van diere")
   else
      fScrBood(maxrow()-1,"[Esc]=List of animals")
   endif
   nChoi := fNewMenu(1,"OWNRNUMB")

   if nChoi == 1
      // No numbers
   elseif nChoi == 2
      // With numbers
      lNumb := .t.
   else
      // Exit
      return NIL
   endif

   // Screen
   fARestScr(aCscr)

   //Kyk of daar gemiddeldes is
   for nI = 1 to len(aRecv)
      if aRecv[nI,FLD_COUN] > 0
         lAver := .t.
         exit
      endif
   next

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   go top

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      return NIL
   endif

   //Bepaal die drukwydte
   if lNumb
      nWidt := 5
   else
      nWidt := 0
   endif
   for nI = 1 to len(aRecv)
      nWidt+= aRecv[nI,FLD_LENG]+1
   next

   if nWidt <= nPrnWidt()
      // Normal
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      // Condense
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         // nPrnl := nPrnPrnl() 11-06-30 08:22
         nPrnl := nPrcPrnl()
         // nPagl := nPrnLeng() 11-06-30 08:22
         nPagl := nPrcLeng()
      else
         nPrnl := nPrcPrnl()
         nPagl := nPrcLeng()
      endif
   endif

   nMidc := nWidt - 29

   if lAver
      nPrnl -= 2
   endif

   if lDoub
      nPrnl -= 1
   endif

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Eie verslag word gedruk!  [Esc]=Stop drukker.")
      cHdl1 := "EIE VERSLAG: "+ALLTRIM(cXvbe)
      cHdl2 := "SELEKSIE: "+ALLTRIM(cXsbe)
   else
      fScrbood(24,"Own report being printed!  [Esc]=Stop printer.")
      cHdl1 := "OWN REPORT: "+ALLTRIM(cXvbe)
      cHdl2 := "SELECTION: "+ALLTRIM(cXsbe)
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := .t.
   do while lLoop


      //Opskrifte
      if prow() = 0

         fPrnCod( cPcod )
         if cLanType() == "A"
            @prow()+nTopl, 1 say upper( cGebNaam() )
            @prow()  , nMidc say "             Verslag: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
            @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
         else
            @prow()+nTopl, 1 say upper( cGebNaam() )
            @prow()  , nMidc say "              Report: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "    Herd Designation: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
            @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
         endif

         @prow()+1,  1 say repl( "=",  nWidt )

         //1e Lyn van opskrif
         if lNumb
            cData := "    " + " "
         else
            cData := ""
         endif
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,FLD_HED1] ), aRecv[nI,FLD_LENG] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //2e Lyn van opskrif
         if lNumb
            cData := "    " + " "
         else
            cData := ""
         endif
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,FLD_HED2] ), aRecv[nI,FLD_LENG] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //3e Lyn van opskrif
         if lNumb
            cData := "####" + " "
         else
            cData := ""
         endif
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,FLD_HED3] ), aRecv[nI,FLD_LENG] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //4e Lyn van opskrif
         if lNumb
            cData := "----" + " "
         else
            cData := ""
         endif
         for nI = 1 to len( aRecv )
            cData := cData + repl("-",aRecv[nI,FLD_LENG]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Data
      if lNumb
         cData := padl(alltrim(str(cmkeyno())),4) + " "
      else
         cData := ""
      endif
      for nI = 1 to len( aRecv )
         //Kies die regte leer
         cText := aRecv[nI,DBF_NAME]
         cText := strtran(cText,"->")
         cText := alltrim(cText)
         select select(cText)
         do case
            case aRecv[nI,FLD_TYPE] == "C"
               //Character
               cData+= fieldget(fieldpos(aRecv[nI,FLD_NAME])) + " "
            case aRecv[nI,FLD_TYPE] == "N"
               //Numeric
               cData+= str(  fieldget(fieldpos(aRecv[nI,FLD_NAME]))  ,aRecv[nI,FLD_LENG],aRecv[nI,FLD_DECI]) + " "
            case aRecv[nI,FLD_TYPE] == "D"
               //Date
               cData+= dtoc(  fieldget(fieldpos(aRecv[nI,FLD_NAME]))  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI,FLD_LENG])+" "
         endcase
         select SM3OWNR
      next
      @prow()+1,1 say padr(cData, nWidt)
      if lDoub
         @prow()+1,  1 say repl( "-",  nWidt )
      endif

      //Skerm
      // fPrnOff()
      // if cLanType() == "A"
      //    fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
      // else
      //    fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         //Print onderste lyn
         if eof()
            if lAver
               if lNumb
                  cData := "    " + " "
               else
                  cData := ""
               endif
               for nI = 1 to len(aRecv)
                  if aRecv[nI,FLD_COUN] > 0
                     cData+= str(  aRecv[nI,FLD_TOTA]/aRecv[nI,FLD_COUN] ,aRecv[nI,FLD_LENG], aRecv[nI,FLD_DECI] ) + " "
                  else
                     cData+= space(aRecv[nI,FLD_LENG]) + " "
                  endif
               next
               if cLanType() == "A"
                  if left(cData,12) == space(12)
                     cData := "Gemiddeldes:" + right(cData,len(cData)-12)
                  endif
                  @prow()+1,  1 say ltrim(str(lastrec())) + " diere in verslag."
               else
                  if left(cData, 9) == space( 9)
                     cData := "Averages:" + right(cData,len(cData)- 9)
                  endif
                  @prow()+1,  1 say ltrim(str(lastrec())) + " animals in report."
               endif
               @prow()+1,  1 say left(cData,nWidt)
            else
               if cLanType() == "A"
                  @prow()+1,  1 say ltrim(str(lastrec())) + " diere in verslag."
               else
                  @prow()+1,  1 say ltrim(str(lastrec())) + " animals in report."
               endif
            endif
         endif

         if lDoub
            if eof()
               @prow()+1,  1 say repl( "=",  nWidt )
            endif
         else
            @prow()+1,  1 say repl( "=",  nWidt )
         endif

         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   go top
return NIL

/******************************************************************************/
STATIC FUNCTION fAverage(aRecv,bBrow)

   //Verklaar
   local i     := 0
   local lAver := .f.
   local cText := ""
   local nData := 0
   local oCols := NIL
   local nReko := 1
   local cEbvf := ""

   // Build the ebv fields variable
   cEbvf := "BIRDIR"
   cEbvf += ",BIRMAT"
   cEbvf += ",WEADIR"
   cEbvf += ",WEAMAT"
   cEbvf += ",WEACOM"
   cEbvf += ",YEADIR"
   cEbvf += ",M18DIR"
   cEbvf += ",OEKDIR"
   cEbvf += ",TKPDIR"
   //cEbvf += ",EOCDIR"
   //cEbvf += ",EOCMAT"
   cEbvf += ",ADGDIR"
   cEbvf += ",PCFCRD"
   cEbvf += ",KLEDIR"
   cEbvf += ",SCRDIR"
   cEbvf += ",HGTDIR"
   cEbvf += ",LGTDIR"
   cEbvf += ",FINDIR"
   cEbvf += ",MCWDIR"
   cEbvf += ",CARDIR"
   cEbvf += ",RIBDIR"

   //Kyk of daar enige numeriese waardes is
   for i = 1 to len(aRecv)
      if aRecv[i,FLD_TYPE] == "N"
         lAver := .t.
         exit
      endif
   next
   if !lAver
      return .f.
   endif

   //@10,0 say "Tot hier"
   //inkey(0)

   //Bereken die gemiddeldes
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Gemiddeldes word bereken")
   else
      fScrWbood(24,"Averages being calculated")
   endif
   go top
   do while !eof()
      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say fPercent(nReko/lastrec())+"% Voltooi"
      else
         @23,35 say fPercent(nReko/lastrec())+"% Completed"
      endif
      setcolor(cColNorm())
      nReko++
      for i = 1 to len(aRecv)
         if aRecv[i,FLD_TYPE] == "N"
            //Kies die regte leer
            cText := aRecv[i,DBF_NAME]
            cText := strtran(cText,"->")
            cText := alltrim(cText)
            select select(cText)
            nData := fieldget(aRecv[i,FLD_NUMB])

            //if nData <> 0
            //   aRecv[i,FLD_COUN]++
            //   aRecv[i,FLD_TOTA]+= nData
            //endif

            if cText == "SM3DATA" .and. aRecv[i][2] $ cEbvf
               if !empty(SM3DATA->analdate)
                  aRecv[i][11]++
                  aRecv[i][12]+= nData
               endif
            elseif nData <> 0
               aRecv[i][11]++
               aRecv[i][12]+= nData
            else
            endif

            select SM3OWNR
         endif
      next
      select SM3OWNR
      skip
   enddo
   go top

   //Kyk of daar enige gemiddeldes is
   lAver := .f.
   for i = 1 to len(aRecv)
      if aRecv[i,FLD_COUN] > 0
         lAver := .t.
         exit
      endif
   next
   if !lAver
      return .t.
   endif

   //Bou veranderlikes
   for i = 1 to len(aRecv)
      oCols := bBrow:getcolumn(i)
      if aRecv[i,FLD_COUN] > 0
         oCols:footing := str(  aRecv[i,FLD_TOTA]/aRecv[i,FLD_COUN] ,aRecv[i,FLD_LENG], aRecv[i,FLD_DECI] )
         oCols:footsep := "Í"
      else
         oCols:footsep := "Í"
         if i == 1
            if cLanType() == "A"
               oCols:footing := left("Gemiddeldes:",aRecv[i,FLD_LENG])
            else
               oCols:footing := left("Averages:",aRecv[i,FLD_LENG])
            endif
         endif
      endif
      bBrow:setcolumn(i,oCols)
   next

return .t.

/******************************************************************************/
STATIC FUNCTION fSort(aRecv,nMenu)

   //Funksie om leer te sorteer

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local i     := 1
   local nBoxc := 1
   local aMenu := {}
   local cText := ""
   local cNeg  := ""
   local cdata := ""
   local cIndf := cDd()+"sm3ownr"+ordbagext()
   local nReko := 1
   local cMenuCol := IIF( cMenuCol==NIL, cColMenu(), cMenuCol )
   local aKeys := {;
      {K_ALT_F10,{|a,n,o,i| IIF(a[n,1] == " ", a[n,1]:=CHR(++i), NIL), o:RefreshCurrent() }},;
      {K_CTRL_F10,{|a,n,o,i| IIF(a[n,1] == " ", a[n,1]:=CHR(++i), NIL), o:RefreshCurrent() }},;
      {K_ALT_F8,{|a,n,o,i| IIF(a[n,1] == " ", a[n,1]:=CHR(++i), NIL), o:RefreshCurrent() }},;
      {K_ALT_F9, {|a,n,o,i| IIF(a[n,1] != " ", fReset(a,ASC(a[n,1])), NIL), IIF(a[n,1] != " ", IIF(i > 48, i--, i := 48), NIL), a[n,1]:=" ", o:RefreshAll() }};
      }

   //Waardes
   nMenu := if(nMenu==NIL,1,nMenu)

   //Bou die menu om te vertoon
   for i = 1 to len(aRecv)
      aadd(aMenu,{" ",padr(ltrim(aRecv[i,FLD_DESC]),20),i})
   next

   //Vertoon die menu
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Los net so")
      fScrBood(24,"[Alt-F10]=Merk   [Alt-F9]=Verwyder Merk")
   else
      fScrBood(23,"[Esc]=Leave as is")
      fScrBood(24,"[Alt-F10]=Mark   [Alt-F9]=Remove Mark")
   endif

   if cLanType() == "A"
      nMenu := LPICKLIST(aMenu,06,15,22,65,{1,2},"Merk veld(e) waarop gesorteer moet word...",aKeys,,,cMenuCol)
   else
      nMenu := LPICKLIST(aMenu,06,15,22,65,{1,2},"Mark field(s) on which to sort...",aKeys,,,cMenuCol)
   endif

   if nMenu = nil .or. nMenu = 0
      restscreen(0,0,24,79,cCscr)
      return .f.
   endif

   ASORT(aMenu,,, { |x,y| x[1] < y[1] })

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Data word gesorteer")
   else
      fScrWbood(24,"Data being sorted")
   endif

   altd()

   //Databasis
   select SM3OWNR
   dbclearindex()
   go top

   //Vul databasis met sorteerveld
   do while !eof()

      setcolor(cColBott())
      if cLanType() == "A"
         @23,35 say fPercent(nReko,lastrec())+"% Voltooi"
      else
         @23,35 say fPercent(nReko,lastrec())+"% Completed"
      endif
      setcolor(cColNorm())
      nReko++
      do while !rlock()
      enddo
      SM3OWNR->idnaam := ""
      cData := ""
      //Kies die regte databasis

      FOR i := 1 TO LEN(aMenu)
         IF aMenu[i,1] != " "
            cText := aRecv[aMenu[i,3],DBF_NAME]
            cText := strtran(cText,"->")
            cText := alltrim(cText)
            select select(cText)

            do case
               case aRecv[aMenu[i,3],FLD_TYPE] == "C" //Character
                  cData += padr(fieldget(aRecv[aMenu[i,3],FLD_NUMB]),aRecv[aMenu[i,3],FLD_LENG])

               case aRecv[aMenu[i,3],FLD_TYPE] == "N" //Numeric
                  // The following code is especially written to force negative numbers
                  // to be sorted above positive numbers after they were converted to
                  // ASCII characters. Positive numbers are left padded with '.' to force
                  // them after the '-' and the negative numbers is subtractacted from the
                  // most negetive number (-999.99 in case of N 7,2) to get the smallest
                  // number at the top.

                  if fieldget(aRecv[aMenu[i,3],FLD_NUMB]) >= 0
                     cData += padl(alltrim(str(fieldget(aRecv[aMenu[i,3],FLD_NUMB]),aRecv[aMenu[i,3],FLD_LENG],aRecv[aMenu[i,3],FLD_DECI])),aRecv[aMenu[i,3],FLD_LENG],".")
                  else
                     cNeg := PADR("-",aRecv[aMenu[i,3],FLD_LENG],"9")
                     if aRecv[aMenu[i,3],FLD_DECI] > 0
                        cNeg := SUBSTR(cNeg,1,(aRecv[aMenu[i,3],FLD_LENG] - aRecv[aMenu[i,3],FLD_DECI] - 1)) + "."
                        cNeg := PADR(cNeg,aRecv[aMenu[i,3],FLD_LENG],"9")
                     endif
                     cData += str((VAL(cNeg)-fieldget(aRecv[aMenu[i,3],FLD_NUMB])),aRecv[aMenu[i,3],FLD_LENG],aRecv[aMenu[i,3],FLD_DECI])
                  endif

               case aRecv[aMenu[i,3],FLD_TYPE] == "D" //Date
                  cData += padr(dtos(fieldget(aRecv[aMenu[i,3],FLD_NUMB])),8)

               otherwise                         //Nie een van bogenoemde
                  cData += SM3OWNR->idnr
            endcase
         ENDIF
      NEXT

      select SM3OWNR
      SM3OWNR->idnaam := cData
      skip

   enddo
   go top

   //Bou indeks
   index on SM3OWNR->idnaam to (cIndf)
   set index to (cIndf)
   go top
   restscreen(0,0,24,79,cCscr)

return .t.

/******************************************************************************/
STATIC FUNCTION fDiskette(aRecv)

   // Program to create a file

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local cFile := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local i     := 0
   begin sequence

      // Get the drive
      cDriv := stdfile()
      if empty(cDriv)
         break
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Lˆer word voorberei")
      else
         fScrWbood(maxrow(),"File being prepared")
      endif

      // Create the file
      cFile := cDriv
      set alternate to (cFile)
      set alternate on
      set console off

      // Write the data
      select SM3OWNR
      go top
      do while !eof()

         // The actual write
         for i := 1 to len(aRecv)
            select select(strtran(aRecv[i,DBF_NAME],"->",""))
            if i == 1
               if aRecv[i,FLD_TYPE] == "D"
                  ?? alltrim(dtos(fieldget(aRecv[i,FLD_NUMB])))
               elseif aRecv[i,FLD_TYPE] == "N"
                  ?? alltrim(str(fieldget(aRecv[i,FLD_NUMB])))
               else
                  ?? alltrim(fieldget(aRecv[i,FLD_NUMB]))
               endif
            else
               if aRecv[i,FLD_TYPE] == "D"
                  ?? ","+alltrim(dtos(fieldget(aRecv[i,FLD_NUMB])))
               elseif aRecv[i,FLD_TYPE] == "N"
                  ?? ","+alltrim(str(fieldget(aRecv[i,FLD_NUMB])))
               else
                  ?? ","+alltrim(fieldget(aRecv[i,FLD_NUMB]))
               endif
            endif
         next
         ?

         // Screen
         select SM3OWNR
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
         else
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
         endif
         set cons off
         set alternate on

         // Next
         select SM3OWNR
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Lˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"File was not created!")
         endif
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Lˆer is suksesvol geskep!")
         else
            fScrBood(maxrow()-1,"File was created succesfully!")
         endif
      endif
      fScrWait(maxrow())

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPalmtop(aRecv)

   // Program to create a file

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local cFile := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local i     := 0
   begin sequence

      // Get the file name

      // Rename existing files
      if file(cPalmDir()+"\Report5.stp")
         // Delete the file
         ferase(cPalmDir()+"\Report5.stp")
      endif
      if file(cPalmDir()+"\Report4.stp")
         // Rename the file
         frename(cPalmDir()+"\Report4.stp",cPalmDir()+"\Report5.stp")
      endif
      if file(cPalmDir()+"\Report3.stp")
         // Rename the file
         frename(cPalmDir()+"\Report3.stp",cPalmDir()+"\Report4.stp")
      endif
      if file(cPalmDir()+"\Report2.stp")
         // Rename the file
         frename(cPalmDir()+"\Report2.stp",cPalmDir()+"\Report3.stp")
      endif
      if file(cPalmDir()+"\Report1.stp")
         // Rename the file
         frename(cPalmDir()+"\Report1.stp",cPalmDir()+"\Report2.stp")
      endif
      // Ask the location of the palmtop file
      cPath := cPalmDir()+"\Report1.stp"

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Lˆer word voorberei")
      else
         fScrWbood(maxrow(),"File being prepared")
      endif

      // Create the file
      //cFile := cPath
      set alternate to (cPath)
      set alternate on
      set console off

      // Write the headers

      // Report name
      ?? left(trim(cXvbe),30)
      ?

      // Language
      if cLanType() == "A"
         ?? "A"
      else
         ?? "E"
      endif
      ?

      // Field descriptions
      if cLanType() == "A"
         ?? "Id Nommerl,"
         ?? "Id Nommer"
      else
         ?? "Id Numberl,"
         ?? "Id Number"
      endif
      for i := 1 to len(aRecv)
         if aRecv[i,2] == "IDNR"
         else
            ?? ","+alltrim(aRecv[i,FLD_DESC])
         endif
      next
      ?

      // Field types
      ?? "C,"
      ?? "C"
      for i := 1 to len(aRecv)
         if aRecv[i,2] == "IDNR"
         else
            ?? ","+alltrim(aRecv[i,FLD_TYPE])
         endif
      next
      ?

      // Field length
      ?? "10,"
      ?? "12"
      for i := 1 to len(aRecv)
         if aRecv[i,2] == "IDNR"
         else
            if aRecv[i,FLD_DECI] > 0
               ?? ","+ltrim(str(aRecv[i,FLD_LENG]))+"."+ltrim(str(aRecv[i,FLD_DECI]))
            else
               ?? ","+ltrim(str(aRecv[i,FLD_LENG]))
            endif
         endif
      next
      ?

      // Write the data
      select SM3OWNR
      go top
      do while !eof()

         // Write the id number
         ?? fid(SM3DATA->idnr,.t.)+","
         ?? alltrim(SM3DATA->idnr)

         // The actual write
         for i := 1 to len(aRecv)
            if aRecv[i,2] == "IDNR"
            else
               select select(strtran(aRecv[i,DBF_NAME],"->",""))
               if aRecv[i,FLD_TYPE] == "D"
                  ?? ","+alltrim(dtos(fieldget(aRecv[i,FLD_NUMB])))
               elseif aRecv[i,FLD_TYPE] == "N"
                  ?? ","+alltrim(str(fieldget(aRecv[i,FLD_NUMB])))
               else
                  ?? ","+alltrim(fieldget(aRecv[i,FLD_NUMB]))
               endif
            endif
         next
         ?

         // Screen
         select SM3OWNR
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
         else
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
         endif
         set cons off
         set alternate on

         // Next
         select SM3OWNR
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cPath)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"REPORT1 Lˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"REPORT1 File was not created!")
         endif
         fScrWait(maxrow())
      endif

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fPalmtopPedigree(aRecv)

   // Program to create a file

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local cFile := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local i     := 0
   begin sequence

      // Get the file name

      // Delete existing file
      if file(cPalmDir()+"\General.stp")
         // Delete the file
         ferase(cPalmDir()+"\General.stp")
      endif

      // Ask the location of the palmtop file
      cPath := cPalmDir()+"\General.stp"

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Lˆer word voorberei")
      else
         fScrWbood(maxrow(),"File being prepared")
      endif

      // Create the file
      set alternate to (cPath)
      set alternate on
      set console off

      // Report name
      if cLanType() == "A"
         ?? "Stamboom"
      else
         ?? "Pedigree"
      endif
      ?

      // Language
      if cLanType() == "A"
         ?? "A"
      else
         ?? "E"
      endif
      ?

      // Field descriptions
      if cLanType() == "A"
         ?? "Id Nommerl,"
         ?? "Id Nommer,"
         ?? "Id Vaar,"
         ?? "Id Moer"
      else
         ?? "Id Numberl,"
         ?? "Id Number,"
         ?? "Id Sire,"
         ?? "Id Dam"
      endif
      //for i := 1 to len(aRecv)
      //   if aRecv[i,2] == "IDNR"
      //   else
      //      ?? ","+alltrim(aRecv[i,FLD_DESC])
      //   endif
      //next
      ?

      // Field types
      ?? "C,"
      ?? "C,"
      ?? "C,"
      ?? "C"
      //for i := 1 to len(aRecv)
      //   if aRecv[i,2] == "IDNR"
      //   else
      //      ?? ","+alltrim(aRecv[i,FLD_TYPE])
      //   endif
      //next
      ?

      // Field length
      ?? "10,"
      ?? "12,"
      ?? "12,"
      ?? "12"
      //for i := 1 to len(aRecv)
      //   if aRecv[i,2] == "IDNR"
      //   else
      //      if aRecv[i,FLD_DECI] > 0
      //         ?? ","+ltrim(str(aRecv[i,FLD_LENG]))+"."+ltrim(str(aRecv[i,FLD_DECI]))
      //      else
      //         ?? ","+ltrim(str(aRecv[i,FLD_LENG]))
      //      endif
      //   endif
      //next
      ?

      // Write the data
      select SM3DATA
      set order to 1
      go top
      do while !eof()

         // The actual write
         ?? fid(SM3DATA->idnr,.t.)+","+alltrim(idnr)+","+alltrim(idvaar)+","+alltrim(idmoer)
         ?

         // Screen
         select SM3DATA
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
         else
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
         endif
         set cons off
         set alternate on

         // Next
         select SM3DATA
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cPath)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"GENERAL Lˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"GENERAL File was not created!")
         endif
      endif
      fScrWait(maxrow())

      // Display message
      if cLanType() == "A"
         fScrBood(maxrow()-1,"Druk asseblief nou HOTSYNC op die PALM!")
      else
         fScrBood(maxrow()-1,"Please press HOTSYNC now on the PALM!")
      endif
      fScrWait(maxrow())

   end

   // Reset
   fARestScr(aCscr)
   fATclose(aCdbf)

return lRetu
