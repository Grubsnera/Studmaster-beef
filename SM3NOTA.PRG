//SM3NOTA.PRG
//Program om enkel dier nota te bewaar
//Kopiereg (c) 1993 A van Rensburg
//22:28 18 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//****************************************************************************
FUNCTION sm3nota( nTop, nLeft, nBott, aSend, cFind )

//Veranderlikes
local cCscr := savescreen(0,0,24,79)
local cCdbf := fTOpen()
local cNota := ""
local cData := ""
local aRecv := {}
local nScrl := 0
local nRigh := 77
local bBrow := NIL
local aCols := {}
local i     := 0
local lMore := .t.
local nKeyp := 0
local cRetu := space(12)

private cData := ""
private cHead := ""

//Skerm
if nTop == NIL
   fScrOpsk()
endif

//Parameters
nTop    := if( nTop  == NIL, 4, nTop  )
nLeft   := if( nLeft == NIL,45, nLeft )
nBott   := if( nBott == NIL,20, nBott )
if aSend == NIL
   aSend := {}
   aadd(aSend,{"sm3nota","idnr"    })
   aadd(aSend,{"sm3data","geslag"  })
   aadd(aSend,{"sm3data","gebdatum"})
   aadd(aSend,{"sm3data","idvaar"  })
   aadd(aSend,{"sm3data","idmoer"  })
endif

//Veldbeskrywings
fScrBood(23)
if cLanType() == "A"
   fScrWbood(24,"Veldbeskrywings word opgesoek")
else
   fScrWbood(24,"Field descriptions being sorted")
endif
aRecv := fGetField( aSend )

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
   return cRetu
endif
cNota := fTOpen(cDd(),"sm3nota")
if left(cNota,1) == "f"
   fTClose(cData)
   fTClose(cCdbf)
   return cRetu
endif

//Skuif die databasis
if cFind == NIL
else
   cRetu := cFind
   set soft on
   seek cFind
   set soft off
   if eof()
      go top
   endif
endif

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
   fBox( nTop, nLeft, nBott, nRigh, "ENKEL DIER NOTAS" )
else
   fBox( nTop, nLeft, nBott, nRigh, "SINGLE ANIMAL NOTES" )
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

// Main loop
lMore := .t.
do while lMore

   //Skerm
   if cLanType() == "A"
      fScrBood( 23, "[ Esc ]=Menu          [Ins]=Nuwe   [A - Z]=Vind                        " )
      fScrBood( 24, "[Enter]=Vertoon nota  [Del]=Skrap  [Alt E]=Verander  [Alt P]=Druk notas" )
   else
      fScrBood( 23, "[ Esc ]=Menu          [Ins]=New     [A - Z]=Find                     " )
      fScrBood( 24, "[Enter]=Display note  [Del]=Delete  [Alt E]=Edit  [Alt P]=Print notes" )
   endif

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
      nKeyp := InKey(0)
   endif

   if nKeyp == K_ESC
      //Esc means leave
      lMore := .f.

   elseif nKeyp == K_ENTER
          //Enter means display note

   elseif nKeyp == K_INS
          //Insert means add a record to the .dbf
          go bottom
          skip
          if fAddChg()
             bBrow:refreshall()
          endif

   elseif nKeyp == K_ALT_E
          //Alt E means change a record
          if fAddChg()
             bBrow:refreshall()
          endif

   elseif nKeyp == K_DEL
          //Delete means delete a record
          if fDelete(aRecv)
             bBrow:refreshall()
          endif

   elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
          //Means locate a record
          if fLocate(aRecv,nKeyp)
             bBrow:refreshall()
          endif

   elseif nKeyp == K_ALT_P
          //Alt P means print
          fPrint()
          bBrow:refreshall()

   else
      // Apply the key to the browse
      ApplyKey(bBrow, nKeyp)

   endif

enddo

//Herstel
restscreen(0,0,24,79,cCscr)
fTClose(cNota)
fTClose(cData)
fTClose(cCdbf)
return cRetu

/*************************************************************************/
STATIC FUNCTION fACNota(aRecv)

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxc    := 0
   local aSend    := {}
   local lLoop    := .t.
   local lReturn  := .f.
   local i        := 0
   local nLoop    := 0
   local nRekord  := 0
   local aDbfs    := {}
   local cSearch  := ""
   local nLine    := 0

   private aData
   private cData

   //Kry die velde benodig
   if aRecv == NIL
      aadd(aSend,{"sm3teeg","kode"})
      aadd(aSend,{"sm3teeg","besk"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE KALFSEISOEN")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW CALVING SEASON")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER KALFSEISOEN")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT CALVING SEASON")
      endif
   endif

   //Vul met data en vertoon
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i][13] )
   next

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Vra die velde
            //Skerm
            //Read
            @nLine+ 1,nBoxc say aRecv[ 1][6] get aRecv[ 1][14] pict aRecv[ 1][10] valid(fVkode(1,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 2,nBoxc say aRecv[ 2][6] get aRecv[ 2][14] pict aRecv[ 2][10]
            set cursor on
            read
            set cursor off
            lReturn := .t.
            //Wat nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         otherwise
            //Bewaar rekord
            //Gaan na rekord
            if nRekord > 0
               goto nRekord
            else
               dbAppend()
            endif
            //Lock
            do while !rlock()
            enddo
            //Bewaar
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i][13], aRecv[i][14] )
            next
            commit
            if nRekord == 0
               nRekord := recno()
               //Maak rekord skoon
               go bottom
               skip
               for i = 1 to len( aRecv )
                  aRecv[i][14] := fieldget( aRecv[i][13] )
               next
               goto nRekord
               nRekord := 0
               nLoop := 1
            else
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen(0,0,24,79,cCurSke)
return lReturn

//*************************************************************************
STATIC FUNCTION fDelete(aRecv)

//Funksie om enige rekord te skrap

//Verklaar
local lReturn := .f.
local cBood   := ""

//Skerm
fScrBood(23,trim(fieldget(1))+" - "+trim(fieldget(2)))
if cLanType() == "A"
   cBood := "Moet bogenoemde "+alltrim(aRecv[1][6])+" geskrap word?"
else
   cBood := "Should above-mentioned "+alltrim(aRecv[1][6])+" be deleted?"
endif

//Vra
if fJaNee( 24, cBood,,.f. )
   do while !rlock()
   enddo
   delete
   skip
   if eof()
      go top
   endif
   lReturn := .t.
endif

return lReturn

//*************************************************************************
STATIC FUNCTION fLocate(aRecv,nKeyp)

//Funksie om vinnig 'n rekord op te soek

//Verklaar
local cCscr := savescreen(0,0,24,79)
local lRetu := .f.
local cData := ""
local nBoxc := 0

//Waardes
if aRecv == NIL
   return lRetu
endif
cData := upper(chr(nKeyp)) + space(aRecv[1][4]-1)

//Move cursor one right
keyboard chr(K_RIGHT)

//Teken die skerm
if cLanType() == "A"
   nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
else
   nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
endif

//Vra die veld
@12,nBoxc say aRecv[1][6] get cData pict aRecv[1][10]
set cursor on
read
set cursor off

//Escaped
if lastkey() == K_ESC .or. cData == space(aRecv[1][4])
   restscreen(0,0,24,79,cCscr)
   return lRetu
endif

//Soek
set softseek on
seek cData
set softseek off
if eof()
   go top
endif
lRetu := .t.

//Herstel
restscreen(0,0,24,79,cCscr)
return lRetu

//******************************************************************************
STATIC FUNCTION fVkode(nItem,aRecv,nRekord,nLine,nBoxc)

//Verklaar
local lRetu   := .t.
local cCscr   := savescreen(0,0,24,79)
local aDisp   := aclone(aRecv)
local cSeek   := ""
local i       := 1

do case
   case len(alltrim(aRecv[nItem][14])) == 0
        if cLanType() == "A"
           fScrBood(23,alltrim(aRecv[nItem][6])+" is verpligtend!")
        else
           fScrBood(23,alltrim(aRecv[nItem][6])+" is compulsory!")
        endif
        fScrWait(24)
        lRetu := .f.
   otherwise
        //Kyk of rekord reeds bestaan
        seek aDisp[nItem][14]
        if eof()
           //Bestaan nie - gaan voort
           if nRekord > 0
              goto nRekord
           endif
        else
           //Bestaan
           if nRekord > 0 .and. nRekord == recno()
              //Dieselfde rekord - gaan voort
           else
              //Bestaan reeds - vertoon bestaande
              //Vul data
              for i = 1 to len(aDisp)
                  aDisp[i][14] := fieldget(aRecv[i][13])
                  setcolor(cColInve())
                  @nLine+i,nBoxc+21 say transform(aDisp[i][14],aDisp[i][10])
                  setcolor(cColNorm())
              next
              //Wag
              fScrBood(23)
              if cLanType() == "A"
                 fScrWait(24,alltrim(aDisp[nItem][6])+" bestaan reeds!" )
              else
                 fScrWait(24,alltrim(aDisp[nItem][6])+" already exists!" )
              endif
              if nRekord > 0
                 goto nRekord
              else
                 go bottom
                 skip
              endif
              //Vertoon oorspronklike
              setcolor(cColInve())
              for i = 1 to len(aRecv)
                  @nLine+i,nBoxc+21 say transform(aRecv[i][14],aRecv[i][10])
              next
              setcolor(cColNorm())
              lRetu := .f.
           endif
        endif
endcase

//Herstel
restscreen(0,0,24,79,cCscr)
return lRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nBlad := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local nMidc := 50
   local nLeng := 79
   local nTotl := 0
   private cPcod := cPrnNorm()

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3teeg","kode"})
      aadd(aSend,{"sm3teeg","besk"})
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Bepaal die drukgrootte
   nTotl := 0
   for nI = 1 to len(aRecv)
      nTotl+= aRecv[nI][4]+1
   next
   if nTotl > 79
      nMidc := 100
      nLeng := 129
      cPcod := cPrnCond()
   endif

   //Skerm
   if cLanType() == "A"
      fScrbood(24,alltrim(aRecv[1][6])+" word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,alltrim(aRecv[1][6])+" being printed!  [Esc]=Stop printer.")
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
            @prow()+1,     1 say upper( cGebNaam() )
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,     1 say upper(alltrim(aRecv[1][6])+"e.")
            @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
         else
            @prow()+1,     1 say upper( cGebNaam() )
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,     1 say upper(alltrim(aRecv[1][6])+"s.")
            @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
         endif
         @prow()+1,  1 say repl( "=",  nLeng )

         //1e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nLeng)

         //2e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nLeng)

         //3e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nLeng)

         //4e Lyn van opskrif
         cData := ""
         for nI = 1 to len( aRecv )
            cData := cData + repl("-",aRecv[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nLeng)
         @prow()+1,  1 say repl( "=",  nLeng )

      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Data
      cData := ""
      for nI = 1 to len( aRecv )
         do case
            case aRecv[nI][3] == "C"
               //Character
               cData+= fieldget(aRecv[nI,13]) + " "
            case aRecv[nI][3] == "N"
               //Numeric
               cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
            case aRecv[nI][3] == "D"
               //Date
               cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI][4])+" "
         endcase
      next
      @prow()+1,1 say padr(cData, nLeng)

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
      if prow() >= nPrnPrnl() .or. eof()

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nLeng )
         @prow()+1,  1 say cAppName()
         fPrnCod( cPrnNorm() )

         // Form feed
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
