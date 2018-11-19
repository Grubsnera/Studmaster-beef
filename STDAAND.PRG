//STDAAND.PRG
//Program om aantal rekords te vertoon
//Kopiereg (c) 1993 A van Rensburg
//08-23-93 05:23am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION stdaand(nTop,nLeft,nBott,aSend)

   //Verklaar
   local cDbfs := ""
   local aRecv := {}
   local cDbfn := ""
   local nReko := 0
   local i     := 0
   local nScrl := 0
   local aCols := {}
   local nRigh := 0
   local bBrow := NIL
   local lMore := .t.
   local nKeyp := 0

   priv  cData := ""
   priv  cHead := ""

   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   begin sequence

      //Parameters
      nTop    := if( nTop  == NIL, 3, nTop  )
      nLeft   := if( nLeft == NIL, 2, nLeft )
      nBott   := if( nBott == NIL,20, nBott )
      if aSend == NIL
         //Kolomme
         aSend := {}
         if cLanType() == "A"
            aadd(aSend,{"stddbfs","dbfbesk"})
            aadd(aSend,{"stddbfs","dbfaant"})
         else
            aadd(aSend,{"stddbfs","dbfdesc"})
            aadd(aSend,{"stddbfs","dbfaant"})
         endif
      endif

      //Lees die skermopskrifte
      //Veldbeskrywings
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrWbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)

      //Open dbfs file
      cDbfs := fTOpen(,"stddbfs",,"tdb")
      if left(cDbfs,1) == "f"
         break
      endif

      //Open elke leer en tel die aantal rekords
      fScrWBood(24,"Aantal rekords word getel")
      do while !eof()

         //Maak aantal rekords nul
         //Skerm
         if cLanType() == "A"
            fScrBood(23,STDDBFS->dbfbesk)
         else
            fScrBood(23,STDDBFS->dbfdesc)
         endif
         //Sluit die rekord
         do while !rlock()
         enddo
         //Maak nul
         STDDBFS->dbfaant := 0

         //Open die dbfleer
         cDbfn := cDd()+trim(STDDBFS->dbfname)
         dbusearea(.t.,,cDbfn)

         //Kry aantal rekords
         nReko := lastrec()

         //Sluit die leer
         dbclosearea()

         //Bewaar aantal rekords
         select STDDBFS
         if nReko <= 99999
            STDDBFS->dbfaant := nReko
         endif
         skip

      enddo
      go top

      //Maak browse gereed
      //Kry die breedte van venster
      for i = 1 to len(aRecv)
         //Lengte
         nScrl := nScrl + aRecv[i,4] + 1
         //Kolomme
         cData := aRecv[i,1] + aRecv[i,2]
         cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
      next

      //Bepaal regterkantste lyn
      nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

      //Teken die box
      if cLanType() == "A"
         fBox( nTop, nLeft, nBott, nRigh, "AANTAL REKORDS" )
      else
         fBox( nTop, nLeft, nBott, nRigh, "NUMBER OF RECORDS" )
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

      //Skerm
      if cLanType() == "A"
         fScrBood(23)
         fScrBood(24,"[Esc]=Menu")
      else
         fScrBood(23)
         fScrBood(24,"[Esc]=Menu")
      endif

      //Vertoon die aantal rekords
      // Main loop
      lMore := .t.
      do while lMore

         // Stabilize the display until it's stable or a key is pressed
         do while (nKeyp := inkey()) == 0 .and. !(bBrow:stabilize)
         enddo
         if bBrow:stable
            nKeyp := inkey(0)
         endif

         if nKeyp == K_ESC
            //Esc means leave
            lMore := .f.

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         endif

      enddo

   end
   //Herstel
   fTClose(cDbfs)
return NIL

