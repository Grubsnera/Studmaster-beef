//SM3PEDI.PRG
//Program om voorgeslagte te vertoon
//Kopiereg (c) 1993 A van Rensburg
//16:02 13 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/******************************************************************************/
/* 'n Leer met die naam BEEFM.SET moet in die program directory bestaan om    */
/* Beefmaster sertifikate uit te druk.                                        */
/******************************************************************************/

FUNCTION sm3pedi(cIdnr)

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local nMenu := 1
   local cSeek := ""
   local cStam := ""
   local cWeeg := ""
   local cFile := ""
   local lItis := TRUE
   local i     := 1
   local nTel  := 1
   local aSend := {}
   local aRecv := {}
   local aSens := {}
   local aRecs := {}
   local cTest := ""
   local nReko := 0
   local cData := ""
   local nMin  := 0
   local cVaar := ""
   local cMoer := ""
   local cKalf := ""

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   //Kyk of leer bestaan
   //if !file(cDd()+"sm3stam.dbf") 12-17-97 10:31am removed
   copy file sm3stam.tdb to (cDd()+"sm3stam.dbf")
   //endif

   //Open progeny file
   cStam := fTOpen(cDd(),"sm3stam",,,,FALSE)
   if left(cStam,1) == "f"
      fTClose(cCdbf)
      return NIL
   endif
   replace all gener1 with space(12),;
      gener2 with space(12),;
      gener3 with space(12),;
      gener4 with space(12),;
      gener5 with space(8 ),;
      gener6 with space(10)

   //Vertoon menu indien nommer nie gegee is nie
   if cIdnr == NIL
      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      endif
      // Kry opsienommer
      nMenu := fNewMenu(nMenu,"SM3PEDI")
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

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
      cSeek := "STAMBO"
   else
      fScrWbood(24,"Field descriptions being sorted")
      cSeek := "PEDIGR"
   endif

   //Skerm
   aadd(aSend,{"sm3stam","gener1"    })
   aadd(aSend,{"sm3stam","lines1"    })
   aadd(aSend,{"sm3stam","gener2"    })
   aadd(aSend,{"sm3stam","lines2"    })
   aadd(aSend,{"sm3stam","gener3"    })
   aadd(aSend,{"sm3stam","lines3"    })
   aadd(aSend,{"sm3stam","gener4"    })
   aadd(aSend,{"sm3stam","lines4"    })
   aadd(aSend,{"sm3stam","gener5"    })
   aadd(aSend,{"sm3stam","lines5"    })
   aadd(aSend,{"sm3stam","gener6"    })
   aRecv := fGetfield(aSend)

   cFile := fTOpen(cDd(),"sm3eiev")
   if left(cFile,1) == "f"
      lItis := FALSE
   else
      seek cSeek
      if eof()
         lItis := FALSE
      else
         //Bou die send array
         for i = 1 to 40
            if !empty(substr(SM3EIEV->veld,nTel,10)) .and. !empty(substr(SM3EIEV->veld,nTel+10,10))
               aadd(aSens,{trim(substr(SM3EIEV->veld,nTel,10)),trim(substr(SM3EIEV->veld,nTel+10,10))})
            endif
            nTel := nTel + 20
         next
      endif
      //Sluit leer
      fTClose(cFile)
   endif

   if !lItis
      //Bou waardes
      if file("BEEFM.SET")
         aadd(aSens,{"sm3data","idnr"      })
         aadd(aSens,{"sm3data","geslag"    })
         aadd(aSens,{"sm3data","generasie" })
         aadd(aSens,{"sm3data","gebdatum"  })
         aadd(aSens,{"sm3data","gebmassa"  })
         //aadd(aSens,{"sm3data","gekeur"    })
         aadd(aSens,{"sm3data","ind205"    })
         aadd(aSens,{"sm3data","ind365"    })
         aadd(aSens,{"sm3data","gdtind"    })
         aadd(aSens,{"sm3data","mateskrot" })
         aadd(aSens,{"sm3data","einmas"    })

         aadd(aSens,{"sm3data","gemspeeni" })
         aadd(aSens,{"sm3data","gemdind"   })
         aadd(aSens,{"sm3data","oudlkalf"  })
         aadd(aSens,{"sm3data","kalfaantal"})
      else
         aadd(aSens,{"sm3data","idnr"      })
         aadd(aSens,{"sm3data","reknr"     })
         aadd(aSens,{"sm3data","kalfbnr"   })
         aadd(aSens,{"sm3data","generasie" })
         aadd(aSens,{"sm3data","gebdatum"  })
         aadd(aSens,{"sm3data","gebmassa"  })
         aadd(aSens,{"sm3data","gekeur"    })
         aadd(aSens,{"sm3data","uitkrede"  })
         aadd(aSens,{"sm3data","ind205"    })
         aadd(aSens,{"sm3data","kalfaantal"})
         aadd(aSens,{"sm3data","gemkalfin" })
      endif
   endif

   aRecs := fGetField(aSens)

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cWeeg := fTOpen(cDd(),"sm3weeg")
   if left(cData,1) == "f"
      fTClose(cStam)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif
   ordsetfocus(2)
   cVaar := fTOpen(cDd(),"sm3data",,,"sm3vaar")
   if left(cData,1) == "f"
      fTClose(cWeeg)
      fTClose(cStam)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif
   cMoer := fTOpen(cDd(),"sm3data",,,"sm3moer")
   if left(cData,1) == "f"
      fTClose(cVaar)
      fTClose(cWeeg)
      fTClose(cStam)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif
   cKalf := fTOpen(cDd(),"sm3data",,,"sm3kalf")
   if left(cData,1) == "f"
      fTClose(cMoer)
      fTClose(cVaar)
      fTClose(cWeeg)
      fTClose(cStam)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif

   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      fTClose(cKalf)
      fTClose(cMoer)
      fTClose(cVaar)
      fTClose(cWeeg)
      fTClose(cStam)
      fTClose(cCdbf)
      cOption(-nMin)
      return NIL
   endif
   dbsetrelation("SM3WEEG",{|| SM3DATA->idnr },"SM3DATA->idnr")
   dbsetrelation("SM3VAAR",{|| SM3DATA->idvaar },"SM3DATA->idvaar")
   dbsetrelation("SM3MOER",{|| SM3DATA->idmoer },"SM3DATA->idmoer")
   dbsetrelation("SM3KALF",{|| SM3DATA->lkalfn },"SM3DATA->lkalfn")
   go bottom
   skip
   select SM3STAM

   //Wat nou
   if nMenu == 1
      //Een dier
      fDisplay(,,,aRecv,cIdnr,aRecs)
   else
      //Groep of seleksiegroep
      select SM3DATA
      go top
      do while !eof()

         nReko := recno()

         if &cTest

            fVul(SM3DATA->idnr)
            if file("BEEFM.SET")
               if !fBeefm()
                  select SM3DATA
                  go bottom
                  skip
                  loop
               endif
            else
               if !fPrint(aRecs)
                  select SM3DATA
                  go bottom
                  skip
                  loop
               endif
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
   fTClose(cKalf)
   fTClose(cMoer)
   fTClose(cVaar)
   fTClose(cWeeg)
   fTClose(cStam)
   fTClose(cData)
   fTClose(cCdbf)
   cOption(-nMin)

return NIL

/****************************************************************************/
STATIC FUNCTION fDisplay( nTop, nLeft, nBott, aRecv, cIdnr, aRecs )

   //Funksie om die stamboom te vertoon

   //Verklaar
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := TRUE
   local nKeyp := 0
   local lNumb := TRUE
   local oCols := NIL

   private cData := ""
   private cHead := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,19, nBott )

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( , {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "STAMBOOM" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "PEDIGREE" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   //Moet idnr gevra word
   if cIdnr == NIL
      lNumb := TRUE
      cIdnr := space(12)
   else
      if len(alltrim(cIdnr)) > 0
         lNumb := FALSE
         fVul(cIdnr)
         bBrow:rowpos := 8
      else
         lNumb := TRUE
         cIdnr := space(12)
      endif
   endif

   // Main loop
   lMore := TRUE
   do while lMore

      //Skerm

      if cLanType() == "A"
         setcolor(cColHead())
         @nTop,nLeft+2 say " STAMBOOM VAN " + cIdnr
         setcolor(cColNorm())
         fScrBood( 23, "[ Esc ]=Menu     [Alt P]=Druk     " )
         fScrBood( 24, "[Enter]=Vertoon  [A - Z]=Nuwe dier" )
      else
         setcolor(cColHead())
         @nTop,nLeft+2 say " PEDIGREE FOR " + cIdnr
         setcolor(cColNorm())
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
            lNumb := FALSE
         endif
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := FALSE

      elseif nKeyp == K_ENTER
         //Enter means display figures
         fFigure(nTop,nLeft,nBott,aRecs,fieldget(bBrow:colpos))
         bBrow:refreshall()

      elseif nKeyp == K_ALT_N .or. nKeyp == K_CTRL_BS
         //Nuwe nommer
         if fIdnr()
            cIdnr := SM3DATA->idnr
            bBrow:refreshall()
            bBrow:rowpos := 8
            bBrow:colpos := 1
            cIdnr := SM3DATA->idnr
         else
            lMore := FALSE
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Nuwe nommer
         if fIdnr(chr(nKeyp))
            bBrow:rowpos := 8
            bBrow:colpos := 1
            bBrow:refreshall()
            cIdnr := SM3DATA->idnr
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         if file("BEEFM.SET")
            fBeefm(aRecs)
         else
            fPrint(aRecs)
         endif
         bBrow:rowpos := 8
         bBrow:colpos := 1
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
return NIL

/****************************************************************************/
STATIC FUNCTION fVul(cIdnr)

   //Funksie om leer te vul met die korrekte data

   //Verklaar
   local aStam := {}

   //Kry die dier self
   select SM3DATA
   aStam := fStamboom(cIdnr)
   seek cIdnr

   //Vul die stamboomleer
   select SM3STAM
   go top
   do while !eof()

      do case
         case recno() == 1
            SM3STAM->gener3 := aStam[ 4][2]
            SM3STAM->gener4 := aStam[ 8][1]
            SM3STAM->gener5 := aStam[ 8][2]
            SM3STAM->gener6 := aStam[ 8][3]
         case recno() == 2
            SM3STAM->gener3 := aStam[ 4][1]
         case recno() == 3
            SM3STAM->gener2 := aStam[ 2][2]
            SM3STAM->gener3 := aStam[ 4][3]
            SM3STAM->gener4 := aStam[ 9][1]
            SM3STAM->gener5 := aStam[ 9][2]
            SM3STAM->gener6 := aStam[ 9][3]
         case recno() == 4
            SM3STAM->gener2 := aStam[ 2][1]
         case recno() == 5
            SM3STAM->gener2 := aStam[ 2][3]
            SM3STAM->gener3 := aStam[ 5][2]
            SM3STAM->gener4 := aStam[10][1]
            SM3STAM->gener5 := aStam[10][2]
            SM3STAM->gener6 := aStam[10][3]
         case recno() == 6
            SM3STAM->gener3 := aStam[ 5][1]
         case recno() == 7
            SM3STAM->gener1 := aStam[ 1][2]
            SM3STAM->gener4 := aStam[11][1]
            SM3STAM->gener5 := aStam[11][2]
            SM3STAM->gener6 := aStam[11][3]
         case recno() == 8
            SM3STAM->gener1 := aStam[ 1][1]
         case recno() == 9
            SM3STAM->gener1 := aStam[ 1][3]
            SM3STAM->gener3 := aStam[ 6][2]
            SM3STAM->gener4 := aStam[12][1]
            SM3STAM->gener5 := aStam[12][2]
            SM3STAM->gener6 := aStam[12][3]
         case recno() == 10
            SM3STAM->gener3 := aStam[ 6][1]
         case recno() == 11
            SM3STAM->gener2 := aStam[ 3][2]
            SM3STAM->gener3 := aStam[ 6][3]
            SM3STAM->gener4 := aStam[13][1]
            SM3STAM->gener5 := aStam[13][2]
            SM3STAM->gener6 := aStam[13][3]
         case recno() == 12
            SM3STAM->gener2 := aStam[ 3][1]
         case recno() == 13
            SM3STAM->gener2 := aStam[ 3][3]
            SM3STAM->gener3 := aStam[ 7][2]
            SM3STAM->gener4 := aStam[14][1]
            SM3STAM->gener5 := aStam[14][2]
            SM3STAM->gener6 := aStam[14][3]
         case recno() == 14
            SM3STAM->gener3 := aStam[ 7][1]
         case recno() == 15
            SM3STAM->gener3 := aStam[ 7][3]
            SM3STAM->gener4 := aStam[15][1]
            SM3STAM->gener5 := aStam[15][2]
            SM3STAM->gener6 := aStam[15][3]
      endcase
      skip
   enddo
   go top
return NIL

/****************************************************************************/
STATIC FUNCTION fIdnr(cKeyp)

   //Funksie om id nommer te vra

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local nBoxc := 0
   local cData := space(12)
   local lRetu := TRUE

   //Waardes
   if cKeyp == NIL
      cKeyp := space(12)
   else
      cKeyp := padr(cKeyp,12)
      keyboard chr(K_RIGHT)
   endif

   //Vorige nommer
   select SM3DATA

   //Vra die nommer
   nBoxc := fBoxCent( 12, space(33), 1 )
   cData := sm3idnr(cKeyp,12,nBoxc)
   select SM3STAM
   do case
      case left(cData,9) == "CANCELLED"
         lRetu := FALSE
      case left(cData, 3 ) == "NOT"
         lRetu := FALSE
      otherwise
         fVul(cData)
   endcase
   restscreen(0,0,24,79,cCscr)
return lRetu

/****************************************************************************/
STATIC FUNCTION fFigure(nTop,nLeft,nBott,aRecs,cIdnr)

   //Funksie om die basiese inligting van 'n koei te wys

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local i     := 1
   local nRow  := 1
   local nCol  := 1
   LOCAL cData := ""

   //Kyk of nommer iets in het
   if cIdnr == NIL
      return NIL
   endif

   //Kyk of nommer iets in het
   if len(alltrim(cIdnr)) == 0
      return NIL
   endif

   //Databasis
   select SM3DATA
   seek cIdnr
   if eof()
      select SM3STAM
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      fBox(nTop+1,nLeft+1,maxrow()-3,77," STAMBOOM INLIGTING VAN " + cIdnr )
   else
      fBox(nTop+1,nLeft+1,maxrow()-3,77," PEDIGREE INFORMATION FOR " + cIdnr )
   endif

   //Waardes
   nRow := nTop+3
   nCol := nLeft+3

   //Veldname
   for i = 1 to len(aRecs)

      if i > ((maxrow()-4)-nTop+3)*2
      else
         if nRow >= maxrow()-4
            nRow := nTop+3
            nCol := nLeft + 40
         endif
         @nRow,nCol say aRecs[i][6]
         setcolor(cColInve())
         cData := aRecs[i,1] + aRecs[i,2]
         @nRow,nCol+21 SAY transform(&(cData),aRecs[i,10])
         setcolor(cColNorm())
         nRow++
      endif

   next

   //Wag vir sleutel
   fScrBood(23)
   fScrWait(24)

   //Herstel
   select SM3STAM
   restscreen(0,0,24,79,cCscr)
return NIL

/****************************************************************************/
STATIC FUNCTION fPrint(aRecs)

   //Verklaar
   local nTota := 0
   local lLoop := TRUE
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSens := {}
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1
   local lRetu := TRUE
   local cIdnr := space(12)
   local cText := ""
   local cSeek := ""
   local cLine := ""

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return FALSE
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   select SM3STAM
   goto 8
   cIdnr := SM3STAM->gener1
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecs == NIL
      asize(aSens,0)
      aadd(aSens,{"sm3stam","idnr"      })
      aadd(aSens,{"sm3data","reknr"     })
      aadd(aSens,{"sm3data","kalfbnr"   })
      aadd(aSens,{"sm3data","generasie" })
      aadd(aSens,{"sm3data","gebdatum"  })
      aadd(aSens,{"sm3data","gebmassa"  })
      aadd(aSens,{"sm3data","gekeur"    })
      aadd(aSens,{"sm3data","uitkrede"  })
      aadd(aSens,{"sm3data","uitkdatum" })
      aadd(aSens,{"sm3data","ind205"    })
      aadd(aSens,{"sm3data","ind365"    })
      aadd(aSens,{"sm3data","ind540"    })
      aadd(aSens,{"sm3data","gdogdo"    })
      aadd(aSens,{"sm3data","gdtgdt"    })
      aadd(aSens,{"sm3data","gemkalfin" })
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecs := fGetField(aSens)
   endif

   //Bepaal die drukgrootte
   nWidt := 60                                   // Pedigree tree width

   for nI = 1 to len(aRecs)
      nWidt += aRecs[nI][4]+1
   next

   if nWidt <= nPrnWidt()
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl()
         nPagl := nPrnLeng()
      else
         nPrnl := nPrcPrnl()
         nPagl := nPrcLeng()
      endif
   endif

   nMidc := nWidt - 29

   //Skerm
   if cLanType() == "A"
      fScrbood(24,alltrim(cIdnr)+" stamboom word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,alltrim(cIdnr)+" pedigree being printed!  [Esc]=Stop printer.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := TRUE
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
            cHdln := "Uitgebreide stamboom van "+trim(cIdnr)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
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
            cHdln := "Extended pedigree for "+trim(cIdnr)
            @prow()  ,nWidt-len(cHdln)+1 say cHdln
         endif
         @prow()+1,  1 say repl( "=",  nWidt )

         //1e Lyn van opskrif
         cData := space(60)
         for nI = 1 to len( aRecs )
            cData+= padr( trim( aRecs[nI,7] ), aRecs[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //2e Lyn van opskrif
         cData := space(60)
         for nI = 1 to len( aRecs )
            cData := cData + padr( trim( aRecs[nI,8] ), aRecs[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //3e Lyn van opskrif
         if cLanType() == "A"
            cData := left("Stamboom"+space(60),60)
         else
            cData := left("Pedigree"+space(60),60)
         endif
         for nI = 1 to len( aRecs )
            cData := cData + padr( trim( aRecs[nI,9] ), aRecs[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //4e Lyn van opskrif
         cData := repl("-",57) + space(3)
         for nI = 1 to len( aRecs )
            cData := cData + repl("-",aRecs[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)
         @prow()+1,  1 say " "

      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := FALSE
         lRetu := FALSE
         exit
      endif

      //Data
      cData := ""
      cLine := ""
      do case

         case SM3STAM->(recno()) == 1
            cData := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 2
            cData := space(12)       + "   " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + "   "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 3
            cData := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 4
            cData := space(12)       + " | " + SM3STAM->gener2 + "-| " + space(12)       + "   " + space(12)       + "   "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener2
         case SM3STAM->(recno()) == 5
            cData := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 6
            cData := space(12)       + " | " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + "   "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 7
            cData := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 8
            cData := SM3STAM->gener1 + "-| " + space(12)       + "   " + space(12)       + "   " + space(12)       + "   "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener1
         case SM3STAM->(recno()) == 9
            cData := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 10
            cData := space(12)       + " | " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + "   "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 11
            cData := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 12
            cData := space(12)       + " | " + SM3STAM->gener2 + "-| " + space(12)       + "   " + space(12)       + "   "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener2
         case SM3STAM->(recno()) == 13
            cData := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 14
            cData := space(12)       + "   " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + "   "
            cLine := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + space(12)       + "   "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 15
            cData := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + "   "
            cLine := space(12)       + "   " + space(12)       + "   " + space(12)       + "   " + space(12)       + "   "
            cSeek := SM3STAM->gener4
      endcase

      //Data
      if !empty(cSeek)
         select SM3DATA
         seek cSeek
         if found()
            for nI = 1 to len( aRecs )
               //Kies die regte leer
               cText := aRecs[nI][1]
               cText := strtran(cText,"->")
               cText := alltrim(cText)
               select select(cText)
               do case
                  case aRecs[nI][3] == "C"
                     //Character
                     cData+= fieldget(aRecs[nI,13]) + " "
                  case aRecs[nI][3] == "N"
                     //Numeric
                     cData+= str(  fieldget(aRecs[nI,13])  ,aRecs[nI][4],aRecs[nI][5]) + " "
                  case aRecs[nI][3] == "D"
                     //Date
                     cData+= dtoc(  fieldget(aRecs[nI,13])  ) + " "
                  otherwise
                     //Nie een van bogenoemde
                     cData+= space(aRecs[nI][4])+" "
               endcase
               select SM3STAM
            next
         endif
      endif
      select SM3STAM
      @prow()+1,1 say padr(cData, nWidt)
      @prow()+1,1 say padr(cLine, nWidt)

      //Skerm
      //fPrnOff()
      //if nTota > 0
      //   setcolor( cColBott() )
      //   if cLanType() == "A"
      //      @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
      //   else
      //      @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
      //   endif
      //   setcolor( cColNorm() )
      //   nReko++
      //endif
      //fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         //Print onderste lyn
         @prow()+2,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         //@prow()+(nPagl-3-prow()),nWidt-len(trim(cIdnr)) say trim(cIdnr)
         @nPagl-3,nWidt-len(trim(cIdnr)) say trim(cIdnr)
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof()
            lLoop := FALSE
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   go top
return lRetu

/****************************************************************************/
STATIC FUNCTION fBeefm()

   //Verklaar
   local nTota := 0
   local lLoop := TRUE
   local nI    := 1
   local nBlad := 1
   local nReko := 1
   local cData := ""
   local aSens := {}
   local aPhaa := {}
   local aPhad := {}
   local aRecv := {}
   local nWidt := 0
   local nTopl := 0
   local nPagl := 0
   local nPrnl := 0
   local cNorm := ""
   local cCond := ""
   local lRetu := TRUE
   local nAver := 0
   local cIdnr := space(12)
   local cText := ""
   local cSeek := ""
   local cLine := ""

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return FALSE
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   select SM3STAM
   goto 8
   cIdnr := SM3STAM->gener1
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if cLanType() == "A"
      fScrwbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrwbood(24,"Field descriptions being sorted")
   endif
   aSens := {}
   aadd(aSens,{"sm3data","idnr"      })
   aadd(aSens,{"sm3data","geslag"    })
   aadd(aSens,{"sm3data","generasie" })
   aadd(aSens,{"sm3data","gebdatum"  })
   aadd(aSens,{"sm3data","gebmassa"  })
   aadd(aSens,{"sm3data","ind205"    })
   aadd(aSens,{"sm3data","ind365"    })
   aadd(aSens,{"sm3data","ind540"    })
   aadd(aSens,{"sm3data","gdo540"    })
   aadd(aSens,{"sm3data","gma540"    })
   aadd(aSens,{"sm3data","gemspeeni" })
   aadd(aSens,{"sm3data","gemdind"   })
   aadd(aSens,{"sm3data","oudlkalf"  })
   aadd(aSens,{"sm3data","kalfaantal"})
   aadd(aSens,{"sm3data","gemkalfin" })
   aPhaa := fGetField(aSens)

   aSens := {}
   aadd(aSens,{"sm3data","idnr"      })
   aadd(aSens,{"sm3data","geslag"    })
   aadd(aSens,{"sm3data","generasie" })
   aadd(aSens,{"sm3data","gebdatum"  })
   aadd(aSens,{"sm3data","gebmassa"  })
   aadd(aSens,{"sm3data","ind205"    })
   aadd(aSens,{"sm3data","gdtind"    })
   aadd(aSens,{"sm3data","gdoind"    })
   aadd(aSens,{"sm3data","mateskrot" })
   aadd(aSens,{"sm3data","einmas"    })
   aadd(aSens,{"sm3data","gemspeeni" })
   aadd(aSens,{"sm3data","gemdind"   })
   aadd(aSens,{"sm3data","oudlkalf"  })
   aadd(aSens,{"sm3data","kalfaantal"})
   aadd(aSens,{"sm3data","gemkalfin" })
   aPhad := fGetField(aSens)


   //Bepaal die drukgrootte
   nWidt := nPrnWidt()
   nTopl := nPrnLine()
   nPrnl := nPrnPrnl()
   nPagl := nPrnLeng()
   cNorm := cPrnNorm()
   cCond := cPrnCond()

   //Skerm
   if cLanType() == "A"
      fScrbood(24,alltrim(cIdnr)+" stamboom word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,alltrim(cIdnr)+" pedigree being printed!  [Esc]=Stop printer.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := TRUE
   do while lLoop


      //Opskrifte
      if prow() = 0

         select SM3DATA
         seek cIdnr

         // Which report
         if empty(SM3DATA->fasekode)
            aRecv := aPhaa
         else
            aRecv := aPhad
         endif

         // Get the field number for average 205 day index
         nAver := fEnum(aRecv,"gemspeeni")

         fPrnCod( cNorm )
         if cLanType() == "A"

            cData := "DIE BEEFMASTER BEESTELERSGENOOTSKAP VAN SUID-AFRIKA"
            @prow()+nTopl,(79/2)-(len(cData)/2) say cData
            cData := "BASISKUDDE AANTEKENINGSBEWYS"
            @prow()+1,(79/2)-(len(cData)/2) say cData
            fPrnCod( cCond )
            @prow()+1,  1 say repl( "=",  129 )
            @prow()+2, 1 say "Hiermee word gesertifiseer dat"
            fPrnCod( cNorm )
            if empty(SM3DATA->idnaam)
               @prow()  ,20 say SM3DATA->idnr
            else
               @prow()  ,20 say SM3DATA->idnaam
            endif
            fPrnCod( cCond )
            @prow()+2, 1 say "aanvaar is vir aantekening in die BASISKUDDE as"
            fPrnCod( cNorm )
            @prow()  ,30 say SM3DATA->generasie
            fPrnCod( cCond )
            @prow()+2, 1 say "      Id nommer:                                                                            Geslag:"
            fPrnCod( cNorm )
            @prow()  ,12 say SM3DATA->idnr
            @prow()  ,61 say SM3DATA->geslag
            fPrnCod( cCond )
            @prow()+2, 1 say "    Teler (KKM):                                                                    Inspeksiedatum:"
            fPrnCod( cNorm )
            if trim(left(fId(SM3DATA->idnr,.t.),4)) == trim(substr(cTotNaam(),125,4))
               @prow()  ,12 say trim(cGebNaam()) + " (" + trim(substr(cTotNaam(),125,4)) + ")"
            else
               @prow()  ,12 say "("+ trim(left(fId(SM3DATA->idnr,.t.),4)) +")"
            endif
            @prow()  ,61 say SM3DATA->keurda
            fPrnCod( cCond )
            @prow()+2, 1 say "Huidige eienaar:                                                                   Datum uitgereik:"
            fPrnCod( cNorm )
            @prow()  ,12 say trim(cGebNaam()) + " (" + trim(substr(cTotNaam(),125,4)) + ")"
            @prow()  ,61 say dAppDate()
            @prow()+1,12 say substr(cTotNaam(),  1,40)
            @prow()+1,12 say substr(cTotNaam(), 41,40)
            @prow()+1,12 say substr(cTotNaam(), 81,40)
            @prow()+1,12 say substr(cTotNaam(),121, 4)

         else

            cData := "THE BEEFMASTER CATTLE BREEDERS SOCIETY OF SOUTHERN AFRICA"
            @prow()+nTopl,(79/2)-(len(cData)/2) say cData
            cData := "BASE HERD PROOF OF RECORDING"
            @prow()+1,(79/2)-(len(cData)/2) say cData
            fPrnCod( cCond )
            @prow()+1,  1 say repl( "=",  129 )
            @prow()+2, 1 say "This is to certify that"
            fPrnCod( cNorm )
            if empty(SM3DATA->idnaam)
               @prow()  ,20 say SM3DATA->idnr
            else
               @prow()  ,20 say SM3DATA->idnaam
            endif
            fPrnCod( cCond )
            @prow()+2, 1 say "has been accepted for recording in the BASE HERD as"
            fPrnCod( cNorm )
            @prow()  ,33 say SM3DATA->generasie
            fPrnCod( cCond )
            @prow()+2, 1 say "      Id number:                                                                               Sex:"
            fPrnCod( cNorm )
            @prow()  ,12 say SM3DATA->idnr
            @prow()  ,61 say SM3DATA->geslag
            fPrnCod( cCond )
            @prow()+2, 1 say "  Breeder (HDM):                                                                   Inspection date:"
            fPrnCod( cNorm )
            if trim(left(fId(SM3DATA->idnr,.t.),4)) == trim(substr(cTotNaam(),125,4))
               @prow()  ,12 say trim(cGebNaam()) + " (" + trim(substr(cTotNaam(),125,4)) + ")"
            else
               @prow()  ,12 say "("+ trim(left(fId(SM3DATA->idnr,.t.),4)) +")"
            endif
            @prow()  ,61 say SM3DATA->keurda
            fPrnCod( cCond )
            @prow()+2, 1 say "  Present owner:                                                                       Date issued:"
            fPrnCod( cNorm )
            @prow()  ,12 say trim(cGebNaam()) + " (" + trim(substr(cTotNaam(),125,4)) + ")"
            @prow()  ,61 say dAppDate()
            @prow()+1,12 say substr(cTotNaam(),  1,40)
            @prow()+1,12 say substr(cTotNaam(), 41,40)
            @prow()+1,12 say substr(cTotNaam(), 81,40)
            @prow()+1,12 say substr(cTotNaam(),121, 4)

         endif

         select SM3STAM

         fPrnCod( cCond )
         @prow()+2,  1 say repl( "=",  nWidt )

         //1e Lyn van opskrif
         cData := space(58)
         for nI = 1 to len( aRecv )
            //          if nI == nAver
            //             cData += " | "
            //          endif
            cData+= padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         // 2e Lyn van opskrif
         cData := space(58)
         for nI = 1 to len( aRecv )
            //          if nI == nAver
            //             cData += " | "
            //          endif
            cData := cData + padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         // 3e Lyn van opskrif
         if cLanType() == "A"
            cData := left("Stamboom en prestasiedata"+space(58),58)
         else
            cData := left("Pedigree and performance data"+space(58),58)
         endif
         for nI = 1 to len( aRecv )
            //          if nI == nAver
            //             cData += " | "
            //          endif
            cData := cData + padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         // 4e Lyn van opskrif
         cData := repl("-",57) + space(1)
         for nI = 1 to len( aRecv )
            //          if nI == nAver
            //             cData += " | "
            //          endif
            cData := cData + repl("-",aRecv[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)
         @prow()+1,  1 say " "

      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := FALSE
         lRetu := FALSE
         exit
      endif

      //Data
      cData := ""
      cLine := ""
      do case

         case SM3STAM->(recno()) == 1
            cData := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 2
            cData := space(12)       + "   " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + " "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 3
            cData := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 4
            cData := space(12)       + " | " + SM3STAM->gener2 + "-| " + space(12)       + "   " + space(12)       + " "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener2
         case SM3STAM->(recno()) == 5
            cData := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 6
            cData := space(12)       + " | " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + " "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 7
            cData := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 8
            cData := SM3STAM->gener1 + "-| " + space(12)       + "   " + space(12)       + "   " + space(12)       + " "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener1
         case SM3STAM->(recno()) == 9
            cData := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + " | " + space(12)       + "   " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 10
            cData := space(12)       + " | " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + " "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 11
            cData := space(12)       + " | " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + " | " + space(12)       + " | " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 12
            cData := space(12)       + " | " + SM3STAM->gener2 + "-| " + space(12)       + "   " + space(12)       + " "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener2
         case SM3STAM->(recno()) == 13
            cData := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + "   " + space(12)       + " | " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener4
         case SM3STAM->(recno()) == 14
            cData := space(12)       + "   " + space(12)       + " | " + SM3STAM->gener3 + "-| " + space(12)       + " "
            cLine := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + space(12)       + " "
            cSeek := SM3STAM->gener3
         case SM3STAM->(recno()) == 15
            cData := space(12)       + "   " + space(12)       + "   " + space(12)       + " | " + SM3STAM->gener4 + " "
            cLine := space(12)       + "   " + space(12)       + "   " + space(12)       + "   " + space(12)       + " "
            cSeek := SM3STAM->gener4
      endcase

      //Data
      if !empty(cSeek)
         select SM3DATA
         seek cSeek
         if found()
            for nI = 1 to len( aRecv )
               //Kies die regte leer
               cText := aRecv[nI][1]
               cText := strtran(cText,"->")
               cText := alltrim(cText)
               select select(cText)
               do case
                  case aRecv[nI][3] == "C"
                     //Character
                     //                   if nI == nAver
                     //                      cData += " | "
                     //                   endif
                     cData+= fieldget(aRecv[nI,13]) + " "
                  case aRecv[nI][3] == "N"
                     //Numeric
                     //                   if nI == nAver
                     //                      cData += " | "
                     //                   endif
                     cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
                  case aRecv[nI][3] == "D"
                     //Date
                     //                   if nI == nAver
                     //                      cData += " | "
                     //                   endif
                     cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
                  otherwise
                     //Nie een van bogenoemde
                     //                   if nI == nAver
                     //                      cData += " | "
                     //                   endif
                     cData+= space(aRecv[nI][4])+" "
               endcase
               select SM3STAM
            next
         endif
      endif
      select SM3STAM
      @prow()+1,1 say padr(cData, nWidt)
      @prow()+1,1 say padr(cLine, nWidt)

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

         // Print onderste lyn
         @prow()+2,  1 say repl( "=",  nWidt )
         if cLanType() == "A"
            @prow()+4,  1 say "Korrek gesertifiseer:"
         else
            @prow()+4,  1 say "Certified correct:"
         endif
         @prow()+1,  1 say repl( "=",  nWidt )
         // 09-18-98 11:16am
         // @prow()+(nPagl-8-prow()),nWidt-len(trim(cIdnr)) say trim(cIdnr)
         fPrnEjec()
         //fPrnOff()
         nBlad++

         // Indien eof()
         if eof()
            lLoop := FALSE
         endif

      endif

   enddo

   fPrnOff()

   // Herstel
   go top

return lRetu
