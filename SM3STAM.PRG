//SM3STAM.PRG
//Program om diere se stambome te vra
//Kopiereg (C) 1992 A van Rensburg
//14:24 18 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3stam

   //Verklaar
   local getlist := {}
   local lLoop := .t.
   local cFile := ""
   local aStam := {}
   local i     := 0

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   //Waardes
   for i = 1 to 15
      aadd(aStam,{space(12),space(35),space(10)," "})
   next

   //Open dataleer
   if cLanType() == "A"
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrWbood( 24, "Data files being opened" )
   endif
   cFile := fTOpen( cDd(), "sm3data", , "dbf", , .t. )
   if left(cFile,1) == "f"
      return NIL
   endif

   //Demonstrasieprogram
   if "0000" $ cReeNomm() .and. lastrec() > 200 .or. ;
         len(trim(cReeNomm())) <= 0 .and. lastrec() > 200
      if cLanType() == "A"
         fScrBood(23,"Nuwe diere kan nie met die demonstrasieprogram bygevoeg word nie!")
         fScrWait(24)
      else
         fScrBood(23,"New animals cannot be added with the demonstration program!")
         fScrWait(24)
      endif
      //Herstel
      fTClose(cFile)
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      fBox(3,2,20,76,"STAMBOOM")
   else
      fBox(3,2,20,76,"PEDIGREE")
   endif
   //setcolor(cColNorm())

   lLoop := .t.
   do while lLoop

      //Skerm
      if cLanType() == "A"
         fBox(3,2,20,77,"STAMBOOM")
      else
         fBox(3,2,20,77,"PEDIGREE")
      endif

      //Waardes
      aStam[1][1] := space(12)

      //Vra die dier se nommer
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  [F1]=Hulp")
         fScrBood(24,"Tik die id nommer van die dier wie se stamboom bewaar moet word.")
      else
         fScrBood(23,"[Esc]=Menu  [F1]=Help")
         fScrBood(24,"Type the id number of the animal for which a pedigree is to be entered.")
      endif
      @11, 4 get aStam[1][1] pict "@!"
      set cursor on
      read
      set cursor off
      //Nou?
      if lastkey() == K_ESC .or. aStam[1][1] == space(12)
         lLoop := .f.
         loop
      endif

      //Dier se stamboom
      aStam := fStamboom(aStam[1][1])

      //Vra die res van die data
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  [F1]=Hulp")
         fScrBood(24,"Tik die diere se ID NOMMERS, REKENAARNOMMERS en NAME.")
      else
         fScrBood(23,"[Esc]=Menu  [F1]=Help")
         fScrBood(24,"Type the animals' ID NUMBERS, COMPUTER NUMBERS and NAMES.")
      endif

      //Dier self
      @12, 4 get aStam[ 1][3] pict "@!"
      @13, 4 get aStam[ 1][2] pict "@!@S12"

      //Pa
      @ 7,24 get aStam[ 2][1] pict "@!" valid fFill(getlist,3)
      @ 8,24 get aStam[ 2][3] pict "@!"
      @ 9,24 get aStam[ 2][2] pict "@!@S12"

      //Ma
      @15,24 get aStam[ 3][1] pict "@!" valid fFill(getlist,6)
      @16,24 get aStam[ 3][3] pict "@!"
      @17,24 get aStam[ 3][2] pict "@!@S12"

      //PaPa
      @ 5,44 get aStam[ 4][1] pict "@!" valid fFill(getlist,9)
      @ 6,44 get aStam[ 4][3] pict "@!"
      @ 7,44 get aStam[ 4][2] pict "@!@S12"

      //PaMa
      @ 9,44 get aStam[ 5][1] pict "@!" valid fFill(getlist,12)
      @10,44 get aStam[ 5][3] pict "@!"
      @11,44 get aStam[ 5][2] pict "@!@S12"

      //MaPa
      @13,44 get aStam[ 6][1] pict "@!" valid fFill(getlist,15)
      @14,44 get aStam[ 6][3] pict "@!"
      @15,44 get aStam[ 6][2] pict "@!@S12"

      //MaMa
      @17,44 get aStam[ 7][1] pict "@!" valid fFill(getlist,18)
      @18,44 get aStam[ 7][3] pict "@!"
      @19,44 get aStam[ 7][2] pict "@!@S12"

      //PaPaPa
      @ 5,64 get aStam[ 8][1] pict "@!"

      //PaPaMa
      @ 7,64 get aStam[ 9][1] pict "@!"

      //PaMaPa
      @ 9,64 get aStam[10][1] pict "@!"

      //PaMaMa
      @11,64 get aStam[11][1] pict "@!"

      //MaPaPa
      @13,64 get aStam[12][1] pict "@!"

      //MaPaMa
      @15,64 get aStam[13][1] pict "@!"

      //MaMaPa
      @17,64 get aStam[14][1] pict "@!"

      //MaMaMa
      @19,64 get aStam[15][1] pict "@!"

      //Read
      setcolor(cColNorm())
      set cursor on
      read
      set cursor off

      //Bewaar
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Stamboombesonderhede word bewaar")
      else
         fScrWbood(24,"Pedigree details being saved")
      endif
      for i = 1 to 15
         if empty(aStam[i][1])
         else
            seek aStam[i][1]
            if eof()
               append blank
               SM3DATA->idnr     := aStam[i][1]
               SM3DATA->uitkrede := "ST"
            endif
            do while !rlock()
            enddo
            //Bewaar ander data
            if !empty(aStam[i,2])
               SM3DATA->idnaam := aStam[i][2]
            endif
            if !empty(aStam[i,3])
               SM3DATA->reknr  := aStam[i][3]
            endif
            do case
               case i==1
                  if !empty(aStam[i+1,1])
                     SM3DATA->idvaar := aStam[i+1][1]
                  endif
                  if !empty(aStam[i+2,1])
                     SM3DATA->idmoer := aStam[i+2][1]
                  endif
               case i==2
                  if !empty(aStam[i+2,1])
                     SM3DATA->idvaar := aStam[i+2][1]
                  endif
                  if !empty(aStam[i+3,1])
                     SM3DATA->idmoer := aStam[i+3][1]
                  endif
                  SM3DATA->geslag := "2"
               case i==3
                  if !empty(aStam[i+3,1])
                     SM3DATA->idvaar := aStam[i+3][1]
                  endif
                  if !empty(aStam[i+4,1])
                     SM3DATA->idmoer := aStam[i+4][1]
                  endif
                  SM3DATA->geslag := "1"
               case i==4
                  if !empty(aStam[i+4,1])
                     SM3DATA->idvaar := aStam[i+4][1]
                  endif
                  if !empty(aStam[i+5,1])
                     SM3DATA->idmoer := aStam[i+5][1]
                  endif
                  SM3DATA->geslag := "2"
               case i==5
                  if !empty(aStam[i+5,1])
                     SM3DATA->idvaar := aStam[i+5][1]
                  endif
                  if !empty(aStam[i+6,1])
                     SM3DATA->idmoer := aStam[i+6][1]
                  endif
                  SM3DATA->geslag := "1"
               case i==6
                  if !empty(aStam[i+6,1])
                     SM3DATA->idvaar := aStam[i+6][1]
                  endif
                  if !empty(aStam[i+7,1])
                     SM3DATA->idmoer := aStam[i+7][1]
                  endif
                  SM3DATA->geslag := "2"
               case i==7
                  if !empty(aStam[i+7,1])
                     SM3DATA->idvaar := aStam[i+7][1]
                  endif
                  if !empty(aStam[i+8,1])
                     SM3DATA->idmoer := aStam[i+8][1]
                  endif
                  SM3DATA->geslag := "1"
               case i==8 .or. i==10 .or. i==12 .or. i==14
                  SM3DATA->geslag := "2"
               case i==9 .or. i==11 .or. i==13 .or. i==15
                  SM3DATA->geslag := "1"
            endcase
         endif
      next

      //if lastkey() == K_ESC
      //   lLoop := .f.
      //endif

   enddo

   //Herstel
   fTClose(cFile)

return NIL

/******************************************************************************/
STATIC FUNCTION fStamboom(cId)

   //Funksie om basiese stamboombesonderhede na te slaan
   //SM3DATA lˆer moet reeds oop wees en id nommer moet
   //die bestaande indeks wees

   //Verklaar
   //local cSker := savescreen(23,0,24,79)
   local cCurd := fTOpen()
   local aStam := {}
   local i     := 0

   //Waardes
   for i = 1 to 15
      aadd(aStam,{space(12),space(35),space(10)," "})
   next

   //Skerm
   //fScrBood(23)
   if cLanType() == "A"
      //fScrWbood(24,"Voorgeslagte word opgesoek")
   else
      //fScrWbood(24,"Ancestors being sorted")
   endif

   //Soek die dier
   select SM3DATA
   set order to 1

   //Dier self
   aStam[1][1] := cId

   for i = 1 to 15
      if empty(aStam[i][1])                      // == space(12)
         //Moenie soek
      else
         seek aStam[i][1]
         if found()
            aStam[i][2] := SM3DATA->idnaam
            aStam[i][3] := SM3DATA->reknr
            do case
               case i==1
                  aStam[i+1][1] := SM3DATA->idvaar
                  aStam[i+2][1] := SM3DATA->idmoer
                  aStam[i+1][4] := "2"
                  aStam[i+2][4] := "1"
               case i==2
                  aStam[i+2][1] := SM3DATA->idvaar
                  aStam[i+3][1] := SM3DATA->idmoer
                  aStam[i+2][4] := "2"
                  aStam[i+3][4] := "1"
               case i==3
                  aStam[i+3][1] := SM3DATA->idvaar
                  aStam[i+4][1] := SM3DATA->idmoer
                  aStam[i+3][4] := "2"
                  aStam[i+4][4] := "1"
               case i==4
                  aStam[i+4][1] := SM3DATA->idvaar
                  aStam[i+5][1] := SM3DATA->idmoer
                  aStam[i+4][4] := "2"
                  aStam[i+5][4] := "1"
               case i==5
                  aStam[i+5][1] := SM3DATA->idvaar
                  aStam[i+6][1] := SM3DATA->idmoer
                  aStam[i+5][4] := "2"
                  aStam[i+6][4] := "1"
               case i==6
                  aStam[i+6][1] := SM3DATA->idvaar
                  aStam[i+7][1] := SM3DATA->idmoer
                  aStam[i+6][4] := "2"
                  aStam[i+7][4] := "1"
               case i==7
                  aStam[i+7][1] := SM3DATA->idvaar
                  aStam[i+8][1] := SM3DATA->idmoer
                  aStam[i+7][4] := "2"
                  aStam[i+8][4] := "1"
            endcase
         else
            //Dier onbekend
         endif
      endi
   next

   //Herstel
   select SM3DATA
   set order to 1
   fTClose(cCurd)
   //restscreen(23,0,24,79,cSker)

return aStam

/******************************************************************************/
STATIC FUNCTION fFill(aGetl,nPosi)

   // Function to complete the fathers pedigree

   // Declare
   local lRetu := .t.
   local aPedi := {}

   begin sequence

      // Do nothing if empty
      if empty(aGetl[nPosi]:varget())
         break
      endif

      // Get the pedigree
      aPedi := fStamboom(aGetl[nPosi]:varget())

      // Voltooi die pa se stamboom
      if nPosi == 3

         // Pa self
         aGetl[4]:varput(aPedi[1,3])
         aGetl[4]:display()
         aGetl[5]:varput(aPedi[1,2])
         aGetl[5]:display()
         //PaPa
         aGetl[9]:varput(aPedi[2,1])
         aGetl[9]:display()
         aGetl[10]:varput(aPedi[2,3])
         aGetl[10]:display()
         aGetl[11]:varput(aPedi[2,2])
         aGetl[11]:display()
         // PaMa
         aGetl[12]:varput(aPedi[3,1])
         aGetl[12]:display()
         aGetl[13]:varput(aPedi[3,3])
         aGetl[13]:display()
         aGetl[14]:varput(aPedi[3,2])
         aGetl[14]:display()
         //PaPaPa
         aGetl[21]:varput(aPedi[4,1])
         aGetl[21]:display()
         //PaPaMa
         aGetl[22]:varput(aPedi[5,1])
         aGetl[22]:display()
         // PaMaPa
         aGetl[23]:varput(aPedi[6,1])
         aGetl[23]:display()
         // PaMaMa
         aGetl[24]:varput(aPedi[7,1])
         aGetl[24]:display()

         // Voltooi die ma se stamboom
      elseif nPosi == 6

         // Ma self
         aGetl[7]:varput(aPedi[1,3])
         aGetl[7]:display()
         aGetl[8]:varput(aPedi[1,2])
         aGetl[8]:display()
         //MaPa
         aGetl[15]:varput(aPedi[2,1])
         aGetl[15]:display()
         aGetl[16]:varput(aPedi[2,3])
         aGetl[16]:display()
         aGetl[17]:varput(aPedi[2,2])
         aGetl[17]:display()
         // MaMa
         aGetl[18]:varput(aPedi[3,1])
         aGetl[18]:display()
         aGetl[19]:varput(aPedi[3,3])
         aGetl[19]:display()
         aGetl[20]:varput(aPedi[3,2])
         aGetl[20]:display()
         //PaPaPa
         aGetl[25]:varput(aPedi[4,1])
         aGetl[25]:display()
         //PaPaMa
         aGetl[26]:varput(aPedi[5,1])
         aGetl[26]:display()
         // PaMaPa
         aGetl[27]:varput(aPedi[6,1])
         aGetl[27]:display()
         // PaMaMa
         aGetl[28]:varput(aPedi[7,1])
         aGetl[28]:display()

         // Voltooi die papa se stamboom
      elseif nPosi == 9

         // PaPa self
         aGetl[10]:varput(aPedi[1,3])
         aGetl[10]:display()
         aGetl[11]:varput(aPedi[1,2])
         aGetl[11]:display()
         // PaPaPa
         aGetl[21]:varput(aPedi[2,1])
         aGetl[21]:display()
         //PaPaMa
         aGetl[22]:varput(aPedi[3,1])
         aGetl[22]:display()

         // Voltooi die pama se stamboom
      elseif nPosi == 12

         // PaMa self
         aGetl[13]:varput(aPedi[1,3])
         aGetl[13]:display()
         aGetl[14]:varput(aPedi[1,2])
         aGetl[14]:display()
         // PaMaPa
         aGetl[23]:varput(aPedi[2,1])
         aGetl[23]:display()
         //PaMaMa
         aGetl[24]:varput(aPedi[3,1])
         aGetl[24]:display()

         // Voltooi die mapa se stamboom
      elseif nPosi == 15

         // MaPa self
         aGetl[16]:varput(aPedi[1,3])
         aGetl[16]:display()
         aGetl[17]:varput(aPedi[1,2])
         aGetl[17]:display()
         // MaPaPa
         aGetl[25]:varput(aPedi[2,1])
         aGetl[25]:display()
         //PaMaMa
         aGetl[26]:varput(aPedi[3,1])
         aGetl[26]:display()

         // Voltooi die mama se stamboom
      elseif nPosi == 18

         // MaMa self
         aGetl[19]:varput(aPedi[1,3])
         aGetl[19]:display()
         aGetl[20]:varput(aPedi[1,2])
         aGetl[20]:display()
         // MaMaPa
         aGetl[27]:varput(aPedi[2,1])
         aGetl[27]:display()
         //MaMaMa
         aGetl[28]:varput(aPedi[3,1])
         aGetl[28]:display()

      endif

   end

return lRetu


