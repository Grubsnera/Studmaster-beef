// Application: StudMaster for Beef Cattle
//   File Name: SM3PARB.PRG
// Description: Function to read palmtop births
//   Copyright: (c) 2002 by Agricultural Data Control cc
//      Author: Albert van Rensburg
//  Created on: 02-08-20 11:35

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3parb

   // Declare
   local getlist := {}
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cPath := ""
   local nBoxc := 0
   local lBrea := .f.
   local cIcar := ""
   local aDbfs := {}
   local cData := ""
   local cResu := ""

   // Verklaar - private
   private cOudeer := 365
   private cRustyd := 30
   private cNordra := 274
   private cMindra := 266
   private cMakdra := 308
   private cSiklus := 21
   private cKalfst := "01"
   private cKalfge := "09"
   private cIdenti := "16  "
   private cSubafd := "  "
   private cTipies := "  "
   private cBreekk := "-"
   private cCompos := "N"
   private cNagebo := "   "
   private cAniTyp := " "
   private cEyepig := "  "

   begin sequence

      // Variables

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Funksie "+cOption())
      else
         fScrOpsk( ,"Function "+cOption())
      endif


      // Ask the location of the palmtop file
      cPath := padr(cPalmDir()+"\B"+cIcar+alltrim(substr(cTotNaam(),125,4))+".PTS",50)

      do while .t.

         if cLanType() = "A"
            fScrOpsk( ,"Funksie "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"LEES PALMTOP GEBOORTES")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik volledige lˆernaam bv. '"+cPath+"lˆernaam.ubr'")
         else
            fScrOpsk( ,"Function "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"IMPORT BIRTHS WEIGHTS")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow(),"Type full file name e.g. '"+cPath+"filename.ext'")
         endif

         @ 12,nboxc GET cPath
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // Escaped
         if lastkey() == K_ESC
            lBrea := .t.
            exit
         endif

         if !(file(alltrim(cPath)))
            // File does not exist
            if cLanType() = "A"
               fScrBood(maxrow()-1,"Die lˆer "+alltrim(cPath)+" bestaan nie ?")
               fScrWait(maxrow())
            else
               fScrBood(MAXROW()-1,"The file "+alltrim(cPath)+" does not exist ?")
               fScrWait(MAXROW())
            endif
         else
            // File exist
            exit
         endif

      enddo

      if lBrea
         lRetu := .f.
         break
      endif

      cPath := alltrim(cPath)

      // Dekwaardes word opgesoek
      aCdbf := fATopen(aCdbf,cDd(),"SM3RASS")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
      if !eof()
         cOudeer := SM3RASS->oudeer
         cRustyd := SM3RASS->rustyd
         cNordra := SM3RASS->nordra
         cMindra := SM3RASS->mindra
         cMakdra := SM3RASS->makdra
         cSiklus := SM3RASS->siklus
         cKalfst := SM3RASS->kalfst
         cKalfge := SM3RASS->kalfge
         cIdenti := SM3RASS->identi
         cSubafd := SM3RASS->subafd
         cTipies := SM3RASS->tipies
         cBreekk := SM3RASS->breekk
         cCompos := SM3RASS->askcom
         cNagebo := SM3RASS->nagebo
         cAniTyp := SM3RASS->type
         cEyepig := SM3RASS->eyepig
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DEKK")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3PALB",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif
      zap
      append from &(cPath) delimited

      // Rename and move source palm file
      if right(cPath,4) == ".PTS"

         // Rename existing files

         // Remove the extention
         cPath := left(cPath,len(cPath)-4)

         if file(cPath+".005")
            // Delete the file
            ferase(cPath+".005")
         endif
         if file(cPath+".004")
            // Rename the file
            frename(cPath+".004",cPath+".005")
         endif
         if file(cPath+".003")
            // Rename the file
            frename(cPath+".003",cPath+".004")
         endif
         if file(cPath+".002")
            // Rename the file
            frename(cPath+".002",cPath+".003")
         endif
         if file(cPath+".001")
            // Rename the file
            frename(cPath+".001",cPath+".002")
         endif
         frename(cPath+".PTS",cPath+".001")

      endif

      go top

      // Skakel data om
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow(),"Data word omgeskakel")
      else
         fScrWbood(maxrow(),"Data being converted")
      endif
      do while !eof()

         // Id number
         SM3PALB->jaarle := substr(SM3PALB->idnr,9,2)
         SM3PALB->volgno := alltrim(str(val(substr(SM3PALB->idnr,11,4))))

         // Sire
         cData := SM3PALB->idvaar
         if empty(alltrim(substr(cData,9,2))) .or. val(substr(cData,11,4)) <= 0
            SM3PALB->idvaar := ""
         else
            cResu := alltrim(substr(cData,5,4))
            cResu += alltrim(substr(cData,9,2))
            if isalpha(right(cResu,1))
            else
               cResu += "-"
            endif
            if val(substr(cData,11,4)) < 1000
               cResu += substr(cData,12,3)
            else
               cResu += substr(cData,11,4)
            endif
            SM3PALB->idvaar := cResu
         endif

         // Dam
         cData := SM3PALB->idmoer
         if empty(alltrim(substr(cData,9,2))) .or. val(substr(cData,11,4)) <= 0
            SM3PALB->idmoer := ""
         else
            cResu := alltrim(substr(cData,5,4))
            cResu += alltrim(substr(cData,9,2))
            if isalpha(right(cResu,1))
            else
               cResu += "-"
            endif
            if val(substr(cData,11,4)) < 1000
               cResu += substr(cData,12,3)
            else
               cResu += substr(cData,11,4)
            endif
            SM3PALB->idmoer := cResu
         endif

         // Sex
         if SM3PALB->geslag == "F"
            SM3PALB->geslag := "1"
         else
            SM3PALB->geslag := "2"
         endif

         // Next record
         select SM3PALB
         skip

      enddo
      go top

      // Display the data on the screen
      fDisplay(cPath)

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDisplay(cPath)

   // Declare variables
   local lRetu := .t.
   local aSend := {}
   local aRecv := {}
   local i     := 0
   local nScrl := 0
   local aCols := {}
   local nTopp := 3
   local nLeft := 2
   local nBott := maxrow()-4
   local nRigh := maxcol()-3
   local bBrow := NIL
   local nKeyp := 0
   local lMove := .f.
   local nCurr := 0
   local cCoun := ""
   local cHead := ""
   local cOpsk := ""
   local lAver := .f.
   local oCols := NIL
   local lFilt := .f.
   local lSort := .f.

   begin sequence

      // Turn cursor off
      setcursor(0)

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif

      // Screen - field descriptions
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrBood(maxrow(),"Skermuitleg word bepaal")
      else
         fScrBood(maxrow(),"Screen outlay being determined")
      endif
      if empty(aSend)
         //aadd(aSend,{"SM3PALB","idnr"     })
         aadd(aSend,{"SM3PALB","kuddek"   })
         aadd(aSend,{"SM3PALB","jaarle"   })
         aadd(aSend,{"SM3PALB","volgno"   })
         aadd(aSend,{"SM3PALB","geslag"   })
         aadd(aSend,{"SM3PALB","gebdatum" })
         aadd(aSend,{"SM3PALB","idvaar"   })
         aadd(aSend,{"SM3PALB","idmoer"   })
      endif
      aRecv := fGetField(aSend)

      // Calculate window width
      for i = 1 to len(aRecv)
         // Length
         nScrl := nScrl+aRecv[i,FLD_LENG]+3
         // Columns
         cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         aadd(aCols,TBColumnNew(cHead,fieldwblock(aRecv[i,FLD_NAME],select(strtran(aRecv[i,DBF_NAME],"->","")))))
      next

      // Calculate right hand column
      nRigh := if(nLeft+nScrl > maxcol()-3, maxcol()-3, nLeft+nScrl )

      // Screen
      fScrOpsk()
      if cLanType() == "A"
         cOpsk := iif(empty(cOpsk),"GEBOORTES VANAF PALMTOP",cOpsk)
      else
         cOpsk := iif(empty(cOpsk),"BIRTHS FROM PALMTOP",cOpsk)
      endif

      // Draw the box
      fBox(nTopp,nLeft,nBott,nRigh,cOpsk)
      setcolor( cColNorm() )

      // Build the browse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Build the browse columns
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      // Screen
      if cLanType() == "A"
         fScrBood(maxrow()-1,"[Esc ]=Menu            ")
         fScrBood(maxrow()  ,"[AltT]=Bewaar geboortes")
      else
         fScrBood(maxrow()-1,"[Esc ]=Menu           ")
         fScrBood(maxrow()  ,"[AltT]=Transfer births")
      endif

      // Freeze
      // bBrow:freeze := 1

      // Main loop
      do while nKeyp <> K_ESC

         // Stabilize
         FullStabilize(bBrow)
         if lMove
            do while recno() <> nCurr
               bBrow:up()
               FullStabilize(bBrow)
            enddo
            lMove := .f.
         endif

         // Display the record number
         cCoun := padl("["+ltrim(str(cmkeyno()))+"/"+ltrim(str(cmkeycount()))+"]",12,chr(205))
         @nBott,nRigh-(len(cCoun)+1) say cCoun

         // Wait for keypress
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ALT_T
            // Transfer data to main file
            fTransfer(cPath)
            //lRetu := .t.
            //nKeyp := K_ESC

         elseif nKeyp == K_F1
            // Help
            do help with "sm3parb",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end

return lRetu

/******************************************************************************/
STATIC FUNCTION fTransfer(cPath)

   // Declare variables
   local lRetu := .t.
   local aCscr := fASaveScr()
   local cData := ""
   local cFild := ""

   begin sequence

      // Screen message
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood(maxrow()-1,"Geboortes word oorgedra")
      else
         fScrWbood(maxrow()-1,"Births being transferred")
      endif

      // Palmtop file delete instruction file
      //cFild := alltrim(cPath)
      //cFild := left(cFild,len(cFild)-3)
      //cFild += "DEL"

      // Loop each animal to do the transfer
      select SM3PALB
      go top
      do while !eof()

         // Id number
         cData := alltrim(SM3PALB->kuddek)
         cData += alltrim(SM3PALB->jaarle)
         cData += "-"
         if val(SM3PALB->volgno) < 1000
            cData += padl(alltrim(SM3PALB->volgno),3,"0")
         else
            cData += padl(alltrim(SM3PALB->volgno),4,"0")
         endif

         // Look if animal does exist
         select SM3DATA
         go top
         seek cData
         if found()
            select SM3PALB
            skip
            loop
         else
            dbappend()
            SM3DATA->idnr := cData
         endif

         // Name of animal
         SM3DATA->idnaam := alltrim(SM3PALB->pref)+" "+alltrim(SM3PALB->idnaam)

         // Sex
         SM3DATA->geslag := SM3PALB->geslag
         SM3DATA->gebdatum := SM3PALB->gebdatum
         SM3DATA->gebmassa := SM3PALB->gebmassa
         SM3DATA->gebstat := SM3PALB->gebstat
         SM3DATA->tweeling := SM3PALB->tweeling
         SM3DATA->kalfstat := SM3PALB->kalfstat
         SM3DATA->ident := alltrim(SM3PALB->ident)+alltrim(SM3PALB->ident2)
         SM3DATA->tipies := SM3PALB->tipies
         SM3DATA->idvaar := SM3PALB->idvaar
         SM3DATA->idmoer := SM3PALB->idmoer
         SM3DATA->mamoergeb := SM3PALB->mamoergeb
         SM3DATA->kalfgem := SM3PALB->kalfgem
         SM3DATA->divers := SM3PALB->divers
         if SM3PALB->niereg == "Y"
            SM3DATA->niereg := "1"
         endif

         // Birth notification
         SM3DATA->toggle2 := "G"

         // Where is animal code
         if SM3DATA->kalfstat == "1 "
            SM3DATA->uitkrede := left(cWaarisd(),2)
         endif

         // Create the palmtop weight delete instruction
         // Open the text file
         //set alternate to (cFild) additive
         //set alternate on
         //set console off
         // Write the data
         //?? SM3PALB->idnr
         //?
         // Close the file
         //set console on
         //set alternate off
         //set alternate to

         // Next record
         select SM3PALB
         skip

      enddo
      go top

   end

   fARestScr(aCscr)

return lRetu

//****************************************************************************/
STATIC FUNCTION fDekkings(cMoer,dGebd)

   // Funksie om pa te soek in deklys

   // Verklaar
   local aVaar[5]
   local aCdbf := fATopen()
   local cDekk := ""
   local aBull := {}
   local aDekt := {}
   local nBoxc := 0
   local cCscr := ""
   local nCh   := 1

   // Waardes
   aVaar[1] := space(12)                         //Vaar id nommer
   aVaar[2] := "1"                               //Vaarkode
   aVaar[3] := ctod("")                          //Dekdatum
   aVaar[4] := space(6)                          //Kalfseisoen
   aVaar[5] := space(12)                         //Skenkerkoei

   begin sequence

      // Dataleer
      select SM3DEKK
      go top

      // Soek ma
      seek cMoer

      if eof()

         // Moeder nie in deklys

      else

         // Moeder wel in deklys

         // Kry dekkings
         do while SM3DEKK->idmoer == cMoer

            //Indien datum uit nul is, maak datum uit dieselfde as datum in

            if empty(SM3DEKK->datumuit)

               if dGebd >= SM3DEKK->datumin+cMindra .and. ;
                     dGebd <= SM3DEKK->datumin+cMakdra

                  // Dekking geldig
                  do case
                     case SM3DEKK->vaarkode == "3"
                        if cLanType() == "A"
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede kunsmatig ge‹nsemineer op "+dtoc(SM3DEKK->datumin),62))
                        else
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago artificially insiminated on "+dtoc(SM3DEKK->datumin),62))
                        endif
                     case SM3DEKK->vaarkode == "4"
                        if cLanType() == "A"
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede ge‹novuleer op "+dtoc(SM3DEKK->datumin),62))
                        else
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago inovulated on "+dtoc(SM3DEKK->datumin),62))
                        endif
                     otherwise
                        if cLanType() == "A"
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede natuurlike gedek op "+dtoc(SM3DEKK->datumin),62))
                        else
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago natural service on "+dtoc(SM3DEKK->datumin),62))
                        endif
                  endcase

                  aadd(aDekt,{SM3DEKK->vaarkode,SM3DEKK->datumin,SM3DEKK->teelgroep,SM3DEKK->donor})

               endif

            else

               if dGebd >= SM3DEKK->datumin+cMindra .and. ;
                     dGebd <= SM3DEKK->datumuit+cMakdra

                  //Dekking geldig
                  do case
                     case SM3DEKK->vaarkode == "3"
                        if cLanType() == "A"
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede kunsmatig ge‹nsemineer op "+dtoc(SM3DEKK->datumin),62))
                        else
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago artificially insiminated on "+dtoc(SM3DEKK->datumin),62))
                        endif
                     case SM3DEKK->vaarkode == "4"
                        if cLanType() == "A"
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede ge‹novuleer op "+dtoc(SM3DEKK->datumin),62))
                        else
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago inovulated on "+dtoc(SM3DEKK->datumin),62))
                        endif
                     otherwise
                        if cLanType() == "A"
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" dae gelede natuurlike gedek op "+dtoc(SM3DEKK->datumin),62))
                        else
                           aadd(aBull,padr(SM3DEKK->idvaar+" "+ltrim(str(dGebd-SM3DEKK->datumin,3,0))+" days ago natural service on "+dtoc(SM3DEKK->datumin),62))
                        endif
                  endcase

                  aadd(aDekt,{SM3DEKK->vaarkode,SM3DEKK->datumin,SM3DEKK->teelgroep,SM3DEKK->donor})

               endif

            endif

            skip

         enddo

         //Kry bulle
         if len(aBull) == 0

            // Geen vader in deklys

         elseif len(aBull) == 1

            // Slegs een vader

            aVaar[1] := left(aBull[1],12)
            aVaar[2] := aDekt[1][1]
            aVaar[3] := aDekt[1][2]
            aVaar[4] := aDekt[1][3]
            aVaar[5] := aDekt[1][4]

         else

            // Vertoon moontlike vaders en kies een
            cCscr := savescreen(0,0,24,79)
            if cLanType() == "A"
               fScrBood(23,"[Esc]=Nie een van die pa's nie")
               fScrBood(24,"Kies een van die pa's met die op- en afpyltjies en druk "+D_ENTER)
               nBoxc := fBoxCent(15,space(62),5,"MOONTLIKE PA'S")
            else
               fScrBood(23,"[Esc]=None of the sires")
               fScrBood(24,"Choose one of the sires with the up and down arrows and press "+D_ENTER)
               nBoxc := fBoxCent(15,space(62),5,"POSSIBLE SIRES")
            endif
            nCh := achoice(15,nBoxc,19,nBoxc+62,aBull)
            if nCh > 0
               aVaar[1] := left(aBull[nCh],12)
               aVaar[2] := aDekt[nCh][1]
               aVaar[3] := aDekt[nCh][2]
               aVaar[4] := aDekt[nCh][3]
               aVaar[5] := aDekt[nCh][4]
            endif
            restscreen(0,0,24,79,cCscr)

         endif

      endif

   end

   // Herstel

return aVaar
