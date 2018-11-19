//SM3PROG.PRG
//Program om nageslag opsommings te vertoon
//Kopiereg (c) 1993 A van Rensburg
//10:24 02 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3prog(cIdnr)

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local nMenu := 1
   local cSeek := ""
   local cProg := ""
   local cFile := ""
   local cWeeg := ""
   local lItis := .t.
   local i     := 1
   local nTel  := 1
   local aSend := {}
   local aRecv := {}
   local aSen2 := {}
   local aRec2 := {}
   local aSens := {}
   local aRecs := {}
   local cTest := ""
   local nReko := 0
   local cData := ""
   local nMin  := 0
   local cAank := ""
   local cVerk := ""

   if cLanType() == "A"
      fScrOpsk(1, "Opsie "+cOption())
   else
      fScrOpsk(1, "Option "+cOption())
   endif

   //Open progeny file
   cProg := fTOpen(cDd(),"sm3prog",,,,.f.)
   if left(cProg,1) == "f"
      fTClose(cCdbf)
      return NIL
   endif
   zap

   //Vertoon menu indien nommer nie gegee is nie
   if cIdnr == NIL
      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      endif
      // Kry opsienommer
      nMenu := fNewMenu(nMenu,"SM3PROG")
      fScrBood(23)
      fScrBood(24)
      if nMenu == 0
         return NIL
      endif

      nMin++
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nMenu))
      else
         fScrOpsk(1,"Option "+cOption(nMenu))
      endif

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

   // Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif

   // Open the own reports file
   cFile := fTOpen(cDd(),"sm3eiev")
   if left(cFile,1) == "f"
   else

      // Animals own data
      if cLanType() == "A"
         cSeek := "NAGES0"
      else
         cSeek := "PROGE0"
      endif
      seek cSeek
      if eof()
      else
         nTel := 1
         for i = 1 to 40
            if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
               aadd(aSens,{trim(substr(SM3EIEV->veld,nTel,10)),trim(substr(SM3EIEV->veld,nTel+10,10))})
            endif
            nTel := nTel + 20
         next
      endif

      // First part of progeny sumary
      if cLanType() == "A"
         cSeek := "NAGES1"
      else
         cSeek := "PROGE1"
      endif
      seek cSeek
      if eof()
      else
         aadd(aSend,{"sm3prog","idnr"      })
         aadd(aSend,{"sm3data","geslag"    })
         aadd(aSend,{"sm3data","generasie" })
         aadd(aSend,{"sm3data","gebdatum"  })
         aadd(aSend,{"sm3data","kalfinterv"})
         aadd(aSend,{"sm3data","idmoer"    })
         nTel := 1
         for i = 1 to 40
            if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
               aadd(aSend,{trim(substr(SM3EIEV->veld,nTel,10)),trim(substr(SM3EIEV->veld,nTel+10,10))})
            endif
            nTel := nTel + 20
         next
      endif

      // Latter part of progeny sumary
      if cLanType() == "A"
         cSeek := "NAGES2"
      else
         cSeek := "PROGE2"
      endif
      seek cSeek
      if eof()
      else
         aadd(aSen2,{"sm3prog","idnr"      })
         nTel := 1
         for i = 1 to 40
            if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
               aadd(aSen2,{trim(substr(SM3EIEV->veld,nTel,10)),trim(substr(SM3EIEV->veld,nTel+10,10))})
            endif
            nTel := nTel + 20
         next
      endif

      // Close the file
      fTClose(cFile)

   endif

   // Get the fields

   // Own data
   if empty(aSens)
      aadd( aSens, { "sm3data", "reknr"      })
      aadd( aSens, { "sm3data", "kalfbnr"    })
      aadd( aSens, { "sm3data", "idvaar"     })
      aadd( aSens, { "sm3data", "idmoer"     })
      aadd( aSens, { "sm3data", "oudekalf"   })
      aadd( aSens, { "sm3data", "kalfaantal" })
      aadd( aSens, { "sm3data", "gemkalfin"  })
      aadd( aSens, { "sm3data", "mwprod"     })
      aadd( aSens, { "sm3data", "prodpj"     })
      aadd( aSens, { "sm3data", "simdeks"    })
      aadd( aSens, { "sm3data", "gemdind"    })
      aadd( aSens, { "sm3data", "gemgmv"     })
      aadd( aSens, { "sm3data", "gemgebmas"  })
      aadd( aSens, { "sm3data", "gemspeena"  })
      aadd( aSens, { "sm3data", "gem100"     })
      aadd( aSens, { "sm3data", "gemspeeni"  })
      aadd( aSens, { "sm3data", "gem365"     })
      aadd( aSens, { "sm3data", "gem540"     })
      aadd( aSens, { "sm3data", "gegdti"     })
      aadd( aSens, { "sm3data", "speper"     })
      aadd( aSens, { "sm3data", "gemret"     })
      aadd( aSens, { "sm3data", "retens"     })
      aadd( aSens, { "sm3data", "dekdat"     })
      aadd( aSens, { "sm3data", "tipede"     })
      aadd( aSens, { "sm3data", "bulid"      })
      aadd( aSens, { "sm3data", "teelgroep"  })
      aadd( aSens, { "sm3data", "dragda"     })
      aadd( aSens, { "sm3data", "dragti"     })
      aadd( aSens, { "sm3data", "lkalfdatum" })
      aadd( aSens, { "sm3data", "lkalfn"     })
      aadd( aSens, { "sm3data", "idnaam"     })
   endif
   aRecs := fGetField( aSens )

   // First part
   if empty(aSend)
      aadd(aSend,{"sm3prog","idnr"      })
      aadd(aSend,{"sm3data","geslag"    })
      aadd(aSend,{"sm3data","generasie" })
      aadd(aSend,{"sm3data","gebdatum"  })
      aadd(aSend,{"sm3data","kalfinterv"})
      aadd(aSend,{"sm3data","idmoer"    })
      aadd(aSend,{"sm3data","gekeur"    })
      aadd(aSend,{"sm3data","uitkrede"  })
      aadd(aSend,{"sm3data","gebmassa"  })
      aadd(aSend,{"sm3data","gma205"    })
      aadd(aSend,{"sm3data","ind205"    })
      aadd(aSend,{"sm3data","gma365"    })
      aadd(aSend,{"sm3data","ind365"    })
      aadd(aSend,{"sm3data","gma540"    })
      aadd(aSend,{"sm3data","ind540"    })
      aadd(aSend,{"sm3data","gdoind"    })
      aadd(aSend,{"sm3data","gdtind"    })
      aadd(aSend,{"sm3data","mpresind"  })
      aadd(aSend,{"sm3data","gebmasv"   })
   endif
   aRecv := fGetField( aSend )

   // Latter part
   if !empty(aSen2)
      aRec2 := fGetField( aSen2 )
   endif

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif

   cVerk := fTOpen(cDd(),"sm3verk")
   if left(cAank,1) == "f"
      fTClose(cProg)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif

   cAank := fTOpen(cDd(),"sm3aank")
   if left(cAank,1) == "f"
      fTClose(cVerk)
      fTClose(cProg)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif

   cWeeg := fTOpen(cDd(),"sm3weeg")
   if left(cWeeg,1) == "f"
      fTClose(cVerk)
      fTClose(cAank)
      fTClose(cProg)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif
   ordsetfocus(2)

   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      fTClose(cVerk)
      fTClose(cAank)
      fTClose(cWeeg)
      fTClose(cProg)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif

   dbsetrelation("SM3AANK",{|| SM3DATA->idnr },"SM3DATA->idnr")
   dbsetrelation("SM3VERK",{|| SM3DATA->idnr },"SM3DATA->idnr")
   dbsetrelation("SM3WEEG",{|| SM3DATA->idnr },"SM3DATA->idnr")

   go bottom
   skip
   select SM3PROG

   //Wat nou
   if nMenu == 1
      //Een dier
      fDisplay(,,,aRecv,aRec2,cIdnr,aRecs)
   else
      //Groep of seleksiegroep
      select SM3DATA
      go top
      do while !eof()

         nReko := recno()

         if &cTest

            fVul(SM3DATA->idnr,aRecv,aRec2)
            fAverage(aRecv,aRec2)
            if !fPrint(aRecv,aRec2,aRecs)
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
   fTClose(cWeeg)
   fTClose(cProg)
   fTClose(cData)
   fTClose(cCdbf)
   cOption(-nMin)

return NIL

/****************************************************************************/
STATIC FUNCTION fDisplay( nTop, nLeft, nBott, aRecv, aRec2, cIdnr, aRecs )

   //Funksie om die nageslag opsomming te vertoon

   //Verklaar
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local lNumb := .t.
   local oCols := NIL

   private cData := ""
   private cHead := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,21, nBott )

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next
   for i = 1 to len(aRec2)
      //Lengte
      nScrl := nScrl + aRec2[i,4] + 1
      //Kolomme
      cData := aRec2[i,1] + aRec2[i,2]
      cHead := aRec2[i,7] + ";" + aRec2[i,8] + ";" + aRec2[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "NAGESLAG OPSOMMING" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "PROGENY SUMMARY" )
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

   //Moet idnr gevra word
   if cIdnr == NIL
      lNumb := .t.
   else
      if len(alltrim(cIdnr)) > 0
         lNumb := .f.
         fVul(cIdnr,aRecv,aRec2,bBrow)
         fAverage(aRecv,aRec2,bBrow)
      else
         lNumb := .t.
      endif
   endif

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm

      if cLanType() == "A"
         if recno() == 1
            setcolor(cColHead())
            @nTop,nLeft+2 say " NAGESLAG OPSOMMING VAN " + SM3PROG->idnr
            setcolor(cColNorm())
         endif
         if lastrec() >= 2 .and. recno() == 1
            setcolor(cColBott())
            @nBott,nLeft+2 say str(lastrec()-2,4,0)+" Nageslag "
            setcolor(cColNorm())
         endif
         fScrBood( 23, "[ Esc ]=Menu     [Alt P]=Druk     " )
         fScrBood( 24, "[Enter]=Vertoon  [A - Z]=Nuwe dier" )
      else
         if recno() == 1
            setcolor(cColHead())
            @nTop,nLeft+2 say " PROGENY SUMMARY FOR " + SM3PROG->idnr
            setcolor(cColNorm())
         endif
         if lastrec() >= 2 .and. recno() == 1
            setcolor(cColBott())
            @nBott,nLeft+2 say str(lastrec()-2,4,0)+" Progeny "
            setcolor(cColNorm())
         endif
         fScrBood( 23, "[ Esc ]=Menu     [Alt P]=Print     " )
         fScrBood( 24, "[Enter]=Display  [A - Z]=New animal" )
      endif

      //Vries
      bBrow:freeze := 1

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         if lNumb
            keyboard chr(K_CTRL_BS)
            lNumb := .f.
         endif
         oCols := bBrow:getcolumn(2)
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ENTER
         //Enter means display figures
         fFigure(nTop,nLeft,nBott,aRecs)
         bBrow:refreshall()

      elseif nKeyp == K_ALT_N .or. nKeyp == K_CTRL_BS
         //Nuwe nommer
         if fIdnr(,bBrow,aRecv,aRec2)
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Nuwe nommer
         if fIdnr(chr(nKeyp),bBrow,aRecv,aRec2)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_G
         //Alt G means calculate averages
         if fAverage(aRecv,aRec2,bBrow)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecv,aRec2,aRecs)
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
return NIL

/****************************************************************************/
STATIC FUNCTION fVul(cIdnr,aRecv,aRec2,bBrow)

   //Funksie om leer te vul met die korrekte data

   //Verklaar
   local oCols := NIL

   //Maak leer skoon
   select SM3PROG
   zap

   //Kry die dier self
   select SM3DATA
   seek cIdnr
   select SM3PROG
   append blank
   SM3PROG->idnr := SM3DATA->idnr
   append blank
   SM3PROG->idnr := "------------"
   select SM3DATA
   if SM3DATA->geslag == "1"
      if bBrow == NIL
      else
         //Maak kolomme reg
         oCols := bBrow:getcolumn(6)
         oCols:block   := {|| sm3data->idvaar }
         if cLanType() == "A"
            oCols:heading := padr("",aRecv[6][4]) + ";" + padr("Vader",aRecv[6][4]) + ";" + padr("id nommer",aRecv[6][4])
         else
            oCols:heading := padr("",aRecv[6][4]) + ";" + padr("Sire",aRecv[6][4]) + ";" + padr("id number",aRecv[6][4])
         endif
         bBrow:setcolumn(6,oCols)
      endif
      //Maak array reg
      aRecv[6][2] := "IDVAAR"
      if cLanType() == "A"
         aRecv[6][7] := padr("",aRecv[6][4])
         aRecv[6][8] := padr("Vader",aRecv[6][4])
         aRecv[6][9] := padr("id nommer",aRecv[6][4])
      else
         aRecv[6][7] := padr("",aRecv[6][4])
         aRecv[6][8] := padr("Sire",aRecv[6][4])
         aRecv[6][9] := padr("id number",aRecv[6][4])
      endif
      aRecv[6][13] := 5
      //Kry nageslag
      set order to 4
      seek cIdnr
      do while SM3DATA->idmoer == cIdnr
         select SM3PROG
         append blank
         SM3PROG->idnr := SM3DATA->idnr
         select SM3DATA
         skip
      enddo
   else
      if bBrow == NIL
      else
         //Maak kolomme reg
         oCols := bBrow:getcolumn(6)
         oCols:block   := {|| sm3data->idmoer }
         if cLanType() == "A"
            oCols:heading := padr("",aRecv[6][4]) + ";" + padr("Moeder",aRecv[6][4]) + ";" + padr("id nommer",aRecv[6][4])

         else
            oCols:heading := padr("",aRecv[6][4]) + ";" + padr("Dam",aRecv[6][4]) + ";" + padr("id number",aRecv[6][4])

         endif
         bBrow:setcolumn(6,oCols)
      endif
      //Maak array reg
      aRecv[6][2] := "IDMOER"
      if cLanType() == "A"
         aRecv[6][7] := padr("",aRecv[6][4])
         aRecv[6][8] := padr("Moeder",aRecv[6][4])
         aRecv[6][9] := padr("id nommer",aRecv[6][4])
      else
         aRecv[6][7] := padr("",aRecv[6][4])
         aRecv[6][8] := padr("Dam",aRecv[6][4])
         aRecv[6][9] := padr("id number",aRecv[6][4])
      endif
      aRecv[6][13] := 6
      //Kry nageslag
      set order to 5
      seek cIdnr
      do while SM3DATA->idvaar == cIdnr
         select SM3PROG
         append blank
         SM3PROG->idnr := SM3DATA->idnr
         select SM3DATA
         skip
      enddo
   endif
   set order to 1

   //Stel relation
   select SM3PROG
   set relation to SM3PROG->IDNR into SM3DATA
   go top
return NIL

/****************************************************************************/
STATIC FUNCTION fIdnr(cKeyp,bBrow,aRecv,aRec2)

   //Funksie om id nommer te vra

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local nBoxc := 0
   local cData := space(12)
   local oCols := NIL

   //Waardes
   if cKeyp == NIL
      cKeyp := space(12)
   else
      ckeyp := padr(cKeyp,12)
      keyboard chr(K_RIGHT)
   endif

   //Kry die huidige nageslag se dier
   go top
   cData := SM3PROG->idnr

   //Ander databasis
   select SM3DATA
   seek cData
   if eof()
      go top
   endif

   //Vra die nommer
   nBoxc := fBoxCent( 12, space(33), 1 )
   cData := sm3idnr(cKeyp,12,nBoxc)
   do case
      case left(cData,9) == "CANCELLED"
         select SM3PROG
         set relation to SM3PROG->IDNR into SM3DATA
      case left(cData, 3 ) == "NOT"
         select SM3PROG
         set relation to SM3PROG->IDNR into SM3DATA
      otherwise
         fVul(cData,aRecv,aRec2,bBrow)
         fAverage(aRecv,aRec2,bBrow)
   endcase
   restscreen(0,0,24,79,cCscr)
return .t.

/****************************************************************************/
STATIC FUNCTION fAverage(aRecv,aRec2,bBrow)

   //Verklaar
   local i     := 0
   local lAver := .f.
   local cText := ""
   local nData := 0
   local oCols := NIL
   local nReko := 1
   local cEbvf := ""
   local cEbvp := ""
   local cEbvc := ""

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
      if aRecv[i][3] == "N"
         lAver := .t.
      endif
   next
   if !lAver
      for i = 1 to len(aRec2)
         if aRec2[i][3] == "N"
            lAver := .t.
         endif
      next
      if !lAver
         return .f.
      endif
   endif

   //Maak alle gemiddeldes nul
   for i = 1 to len(aRecv)
      aRecv[i][11] := 0
      aRecv[i][12] := 0
      if bBrow == NIL
      else
         oCols := bBrow:getcolumn(i)
         oCols:footsep := "Í"
         oCols:footing := ""
         bBrow:setcolumn(i,oCols)
      endif
   next

   //Maak alle gemiddeldes nul
   for i = 1 to len(aRec2)
      aRec2[i][11] := 0
      aRec2[i][12] := 0
      if bBrow == NIL
      else
         oCols := bBrow:getcolumn(i+len(aRecv))
         oCols:footsep := "Í"
         oCols:footing := ""
         bBrow:setcolumn(i+len(aRecv),oCols)
      endif
   next

   //Bereken die gemiddeldes
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Gemiddeldes word bereken")
   else
      fScrWbood(24,"Averages being calculated")
   endif
   goto 3
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
         if aRecv[i][3] == "N"
            //Kies die regte leer
            cText := aRecv[i][1]
            cText := strtran(cText,"->")
            cText := alltrim(cText)
            select select(cText)
            nData := fieldget(aRecv[i][13])

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

            select SM3PROG

         endif
      next
      for i = 1 to len(aRec2)
         if aRec2[i][3] == "N"
            //Kies die regte leer
            cText := aRec2[i][1]
            cText := strtran(cText,"->")
            cText := alltrim(cText)
            select select(cText)
            nData := fieldget(aRec2[i][13])
            if cText == "SM3DATA" .and. aRec2[i][2] $ cEbvf
               if !empty(SM3DATA->analdate)
                  aRec2[i][11]++
                  aRec2[i][12]+= nData
               endif
            elseif nData <> 0
               aRec2[i][11]++
               aRec2[i][12]+= nData
            else
            endif

            //if nData <> 0
            //   aRec2[i][11]++
            //   aRec2[i][12]+= nData
            //endif
            select SM3PROG
         endif
      next
      select SM3PROG
      skip
   enddo
   go top

   //Kyk of daar enige gemiddeldes is
   lAver := .f.
   for i = 1 to len(aRecv)
      if aRecv[i][11] > 0
         lAver := .t.
         exit
      endif
   next
   if !lAver
      for i = 1 to len(aRec2)
         if aRec2[i][11] > 0
            lAver := .t.
            exit
         endif
      next
      if !lAver
         return .t.
      endif
   endif

   //Bou veranderlikes
   if bBrow == NIL
   else
      for i = 1 to len(aRecv)
         oCols := bBrow:getcolumn(i)
         if aRecv[i][11] > 0
            oCols:footing := str(  aRecv[i][12]/aRecv[i][11] ,aRecv[i][4], aRecv[i][5] )
            oCols:footsep := "Í"
         else
            oCols:footsep := "Í"
            oCols:footing := ""
            if i == 1
               if cLanType() == "A"
                  oCols:footing := left("Gemiddeldes:",aRecv[i][4])
               else
                  oCols:footing := left("Averages:",aRecv[i][4])
               endif
            endif
         endif
         bBrow:setcolumn(i,oCols)
      next
      for i = 1 to len(aRec2)
         oCols := bBrow:getcolumn(i+len(aRecv))
         if aRec2[i][11] > 0
            oCols:footing := str(  aRec2[i][12]/aRec2[i][11] ,aRec2[i][4], aRec2[i][5] )
            oCols:footsep := "Í"
         else
            oCols:footsep := "Í"
            oCols:footing := ""
         endif
         bBrow:setcolumn(i+len(aRecv),oCols)
      next
   endif

return .t.

/****************************************************************************/
STATIC FUNCTION fFigure(nTop,nLeft,nBott,aRecs)

   //Funksie om die basiese inligting van 'n koei te wys

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local i     := 0
   LOCAL cData := ""

   //Skuif databasis
   select SM3PROG
   go top

   //Skerm
   if cLanType() == "A"
      fBox(nTop+1,nLeft+1,nBott,77," NAGESLAG GEMIDDELDES VAN " + SM3PROG->idnr )
   else
      fBox(nTop+1,nLeft+1,nBott,77," PROGENY AVERAGES FOR " + SM3PROG->idnr )
   endif

   // Select the data file
   select SM3DATA

   // Display the data - first part
   for i := 1 to len(aRecs)
      cData := aRecs[i,1] + aRecs[i,2]
      if i <= 16
         @nTop+1+i,nLeft+3 say aRecs[i,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[i,FLD_PICT]))
      elseif i >= 17 .and. i <= 31
         @nTop-14+i,nLeft+40 say aRecs[i,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[i,FLD_PICT]))
      endif
   next

   select SM3PROG

   // Wag vir sleutel
   fScrBood(23)
   fScrWait(24)

   // Herstel
   restscreen(0,0,24,79,cCscr)

return NIL

/****************************************************************************/
STATIC FUNCTION fPrint(aRecv,aRec2,aRecs)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local lRetu := .t.
   local lHead := .t.
   local cIdnr := space(12)
   local cText := ""
   local aStam := {}
   local aClon := {}
   local lFirs := .t.
   local lPrnh := .t.
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return .f.
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   select SM3PROG
   go top
   cIdnr := SM3PROG->idnr

   //Kry stamboom
   select SM3DATA
   aStam := fStamboom(cIdnr)
   select SM3PROG
   set relation to SM3PROG->IDNR into SM3DATA

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3prog","idnr"      })
      aadd(aSend,{"sm3data","geslag"    })
      aadd(aSend,{"sm3data","generasie" })
      aadd(aSend,{"sm3data","gebdatum"  })
      aadd(aSend,{"sm3data","kalfinterv"})
      aadd(aSend,{"sm3data","idmoer"    })
      aadd(aSend,{"sm3data","gekeur"    })
      aadd(aSend,{"sm3data","uitkrede"  })
      aadd(aSend,{"sm3data","gebmassa"  })
      aadd(aSend,{"sm3data","gma205"    })
      aadd(aSend,{"sm3data","ind205"    })
      aadd(aSend,{"sm3data","gma365"    })
      aadd(aSend,{"sm3data","ind365"    })
      aadd(aSend,{"sm3data","gma540"    })
      aadd(aSend,{"sm3data","ind540"    })
      aadd(aSend,{"sm3data","gdoind"    })
      aadd(aSend,{"sm3data","gdtind"    })
      aadd(aSend,{"sm3data","mpresind"  })
      aadd(aSend,{"sm3data","gebmasv"   })
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Waardes
   aClon := aclone(aRecv)
   lFirs := .t.

   //Bepaal die drukgrootte
   // Condense
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
   if cLanType() == "A"
      fScrbood(24,alltrim(cIdnr)+" nageslag opsomming word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,alltrim(cIdnr)+" progeny report being printed!  [Esc]=Stop printer.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   fPrnCod( cPcod )

   //Doen die loop
   lLoop := .t.
   do while lLoop

      // Opskrifte
      if prow() = 0
         lHead := .t.
         if cLanType() == "A"
            @prow()+nTopl,     1 say upper( cGebNaam() )
            @prow()  , nMidc say "             Verslag: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            cHdln := "Nageslag opsomming van "+trim(cIdnr)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
         else
            @prow()+nTopl,     1 say upper( cGebNaam() )
            @prow()  , nMidc say "              Report: " + cOption()
            @prow()+1,     1 say substr(cTotNaam(),  1,40)
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,     1 say substr(cTotNaam(), 41,40)
            @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say substr(cTotNaam(), 81,40)
            @prow()  , nMidc say "    Herd Designation: " + substr(cTotNaam(),125,4)
            @prow()+1,     1 say substr(cTotNaam(),121, 4)
            cHdln := "Progeny summary for "+trim(cIdnr)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
         endif
         @prow()+1,  1 say repl( "=",  nWidt )
      endif

      // Ander besonderhede
      if lPrnh
         lPrnh := .f.
         select SM3DATA
         if len(aRecs) >= 1
            cData := aRecs[1,1] + aRecs[1,2]
            @prow()+1,  1 say aRecs[1,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[1,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         @prow()  , 80 say "|"
         if cLanType() == "A"
            @prow()  , 86 say "(Vader)"
         else
            @prow()  , 86 say "( Sire)"
         endif
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[ 8][1]

         if len(aRecs) >= 2
            cData := aRecs[2,1] + aRecs[2,2]
            @prow()+1,1 say aRecs[2,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[2,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 16
            cData := aRecs[16,1] + aRecs[16,2]
            @prow(),40 say aRecs[16,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[16,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,102 say aStam[ 4][1]
         @prow()  ,115 say "| "

         if len(aRecs) >= 3
            cData := aRecs[3,1] + aRecs[3,2]
            @prow()+1,1 say aRecs[3,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[3,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 17
            cData := aRecs[17,1] + aRecs[17,2]
            @prow(),40 say aRecs[17,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[17,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,118 say aStam[ 9][1]
         @prow()  ,115 say "| "

         if len(aRecs) >= 4
            cData := aRecs[4,1] + aRecs[4,2]
            @prow()+1,1 say aRecs[4,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[4,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 18
            cData := aRecs[18,1] + aRecs[18,2]
            @prow(),40 say aRecs[18,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[18,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 86 say aStam[ 2][1]
         @prow()  , 99 say "| "

         if len(aRecs) >= 5
            cData := aRecs[5,1] + aRecs[5,2]
            @prow()+1,1 say aRecs[5,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[5,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 19
            cData := aRecs[19,1] + aRecs[19,2]
            @prow(),40 say aRecs[19,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[19,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[10][1]

         if len(aRecs) >= 6
            cData := aRecs[6,1] + aRecs[6,2]
            @prow()+1,1 say aRecs[6,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[6,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 20
            cData := aRecs[20,1] + aRecs[20,2]
            @prow(),40 say aRecs[20,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[20,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,102 say aStam[ 5][1]
         @prow()  ,115 say "| "

         if len(aRecs) >= 7
            cData := aRecs[7,1] + aRecs[7,2]
            @prow()+1,1 say aRecs[7,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[7,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 21
            cData := aRecs[21,1] + aRecs[21,2]
            @prow(),40 say aRecs[21,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[21,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[11][1]

         if len(aRecs) >= 8
            cData := aRecs[8,1] + aRecs[8,2]
            @prow()+1,1 say aRecs[8,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[8,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 22
            cData := aRecs[22,1] + aRecs[22,2]
            @prow(),40 say aRecs[22,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[22,FLD_PICT]))
         endif
         @prow()  , 80 say "|"

         if len(aRecs) >= 9
            cData := aRecs[9,1] + aRecs[9,2]
            @prow()+1,1 say aRecs[9,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[9,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 23
            cData := aRecs[23,1] + aRecs[23,2]
            @prow(),40 say aRecs[23,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[23,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[12][1]

         if len(aRecs) >= 10
            cData := aRecs[10,1] + aRecs[10,2]
            @prow()+1,1 say aRecs[10,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[10,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 24
            cData := aRecs[24,1] + aRecs[24,2]
            @prow(),40 say aRecs[24,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[24,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,102 say aStam[ 6][1]
         @prow()  ,115 say "| "

         if len(aRecs) >= 11
            cData := aRecs[11,1] + aRecs[11,2]
            @prow()+1,1 say aRecs[11,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[11,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 25
            cData := aRecs[25,1] + aRecs[25,2]
            @prow(),40 say aRecs[25,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[25,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[13][1]

         if len(aRecs) >= 12
            cData := aRecs[12,1] + aRecs[12,2]
            @prow()+1,1 say aRecs[12,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[12,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 26
            cData := aRecs[26,1] + aRecs[26,2]
            @prow(),40 say aRecs[26,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[26,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 86 say aStam[ 3][1]
         @prow()  , 99 say "| "

         if len(aRecs) >= 13
            cData := aRecs[13,1] + aRecs[13,2]
            @prow()+1,1 say aRecs[13,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[13,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 27
            cData := aRecs[27,1] + aRecs[27,2]
            @prow(),40 say aRecs[27,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[27,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[14][1]

         if len(aRecs) >= 14
            cData := aRecs[14,1] + aRecs[14,2]
            @prow()+1,1 say aRecs[14,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[14,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 28
            cData := aRecs[28,1] + aRecs[28,2]
            @prow(),40 say aRecs[28,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[28,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         @prow()  , 99 say "| "
         @prow()  ,102 say aStam[ 7][1]
         @prow()  ,115 say "| "

         if len(aRecs) >= 15
            cData := aRecs[15,1] + aRecs[15,2]
            @prow()+1,1 say aRecs[15,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[15,FLD_PICT]))
         else
            @prow()+1,1 say ""
         endif
         if len(aRecs) >= 29
            cData := aRecs[29,1] + aRecs[29,2]
            @prow(),40 say aRecs[29,FLD_DESC]+" "+alltrim(transform(&(cData),aRecs[29,FLD_PICT]))
         endif
         @prow()  , 80 say "|"
         if cLanType() == "A"
            @prow()  , 86 say "(Moeder)"
         else
            @prow()  , 86 say "(Mother)"
         endif
         @prow()  ,115 say "| "
         @prow()  ,118 say aStam[15][1]

         select SM3PROG
         @prow()+1,  1 say repl( "=",  nWidt )

      endif

      if lHead

         lHead := .f.

         //1e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aClon )
            cData := cData + padr( trim( aClon[nI,7] ), aClon[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //2e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aClon )
            cData := cData + padr( trim( aClon[nI,8] ), aClon[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //3e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aClon )
            cData := cData + padr( trim( aClon[nI,9] ), aClon[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //4e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aClon )
            cData := cData + repl("-",aClon[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         lRetu := .f.
         exit
      endif

      //Data
      cData := ""
      for nI = 1 to len( aClon )
         //Kies die regte leer
         cText := aClon[nI][1]
         cText := strtran(cText,"->")
         cText := alltrim(cText)
         select select(cText)
         do case
            case aClon[nI][3] == "C"
               //Character
               cData+= fieldget(aClon[nI,13]) + " "
            case aClon[nI][3] == "N"
               //Numeric
               if empty(fieldget(aClon[nI,13]))
                  cData += space(aClon[nI][4]) + " "
               else
                  cData+= str(  fieldget(aClon[nI,13])  ,aClon[nI][4],aClon[nI][5]) + " "
               endif
            case aClon[nI][3] == "D"
               //Date
               if empty(fieldget(aClon[nI,13]))
                  cData+= space(8) + " "
               else
                  cData+= dtoc(  fieldget(aClon[nI,13])  ) + " "
               endif
            otherwise
               //Nie een van bogenoemde
               cData+= space(aClon[nI][4])+" "
         endcase
         select SM3PROG
      next
      @prow()+1,1 say padr(cData, nWidt)

      //Skerm
      // fPrnOff()
      // if nTota > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
      //    else
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
      //    endif
      //    setcolor( cColNorm() )
      //    nReko++
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         //Druk gemiddeldes indien eof
         if eof() .and. lastrec() > 2
            //Bou gemiddeldes lyn
            cData := ""
            for nI = 1 to len(aClon)
               if aClon[nI][11] > 0
                  cData+= str(aClon[nI][12]/aClon[nI][11],aClon[nI][4],aClon[nI][5]) + " "
               else
                  cData+= space(aClon[nI][4]) + " "
               endif
            next
            if cLanType() == "A"
               cData := strtran(cData,space(13),padr(ltrim(str(lastrec()-2,4,0)) + " Nageslag",13),1,1)
            else
               cData := strtran(cData,space(10),padr(ltrim(str(lastrec()-2,4,0)) + "  Progeny",10),1,1)
            endif
            @prow()+2,1 say padr(cData, nWidt)
            //if cLanType() == "A"
            //   @prow()+1,1 say ltrim(str(lastrec()-2,4,0)) + " Nageslag"
            //else
            //   @prow()+1,1 say ltrim(str(lastrec()-2,4,0)) + "  Progeny"
            //endif
         endif

         //Kyk of 'n tweede deel gedruk moet word
         if eof() .and. len(aRec2) > 0 .and. lFirs
            @prow()+1,  1 say repl( "=",  nWidt )
            if prow()+8 > nPrnl
               //Form feed first
               @prow()+1,  1 say cAppName()
               @prow()+(nPagl-3-prow()),nWidt-len(trim(cIdnr)) say trim(cIdnr)
               fPrnEjec()
               //fPrnOff()
               nBlad++
            endif
            lFirs := .f.
            lHead := .t.
            aClon := aclone(aRec2)
            go top
         else
            //Print onderste lyn
            @prow()+1,  1 say repl( "=",  nWidt )
            @prow()+1,  1 say cAppName()
            @prow()+(nPagl-3-prow()),nWidt-len(trim(cIdnr)) say trim(cIdnr)
            fPrnEjec()
            //fPrnOff()
            nBlad++
         endif

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   go top

return lRetu

