//STDFORM.PRG
//Program om diskette te formatteer
//Kopiereg (c) 1993 A van Rensburg
//04-30-93 03:54pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//***************************************************************************/
FUNCTION stdform

   //Verklaar
   local nBoxc := 0
   local lLoop := .t.
   local cDriv := "A:"
   local cText := ""
   local nErro := 0
   local getlist := {}

   priv nFlop := 0

   //Skerm
   fScrOpsk()
   if cLanType() == "A"
       fScrOpsk( 1, "Opsie "+cOption())
   else
       fScrOpsk( 1, "Option "+cOption())
   endif

   if cLanType() == "A"
      nBoxc := fBoxCent(11,"Disketaandrywer? xx",3,"FORMATTEER")
      cText := "Hierdie is 'n datadisket! Verwyder disket en druk enige sleutel..."
   else
      nBoxc := fBoxCent(11,"Disk drive? xx",3,"FORMAT")
      cText := "This is a data diskette! Remove diskette and press any key..."
   endif

   //Vra die data
   lLoop := .t.
   do while lLoop

      //Skerm
      fScrBood(23,"[Esc]=Menu")
      if cLanType() == "A"
         fScrBood(24,"Tik die dryfletter wat geformatteer moet word!")
      else
         fScrBood(24,"Type the drive letter where format should be done!")
      endif

      //Vraag
      if cLanType() == "A"
         @12,nBoxc say "Disketaandrywer?" get cDriv pict "!:"
      else
         @12,nBoxc say "Disk drive?" get cDriv pict "!:"
      endif
      set cursor on
      read
      set cursor off

      //Escaped
      if lastkey() == K_ESC
         exit
      endif

      //Nothing
      if cDriv $ " :  "
         if cLanType() == "A"
            fScrBood(23,"Dryfletter is verpligtend! (Moet wees A: of B:)")
         else
            fScrBood(23,"Drive letter is compulsory! (Should be A: or B: )")
         endif
         fScrWait(24)
         loop
      endif

      //Slegs A en B is geldig
      if cDriv $ "A:zB:"
      else
         if cLanType() == "A"
            fScrBood(23,"Slegs disketaandrywer A: of B: is geldig!")
         else
            fScrBood(23,"Only diskette drive A: or B: is valid!")
         endif
         fScrWait(24)
         loop
      endif

      lLoop := .f.

   enddo
   if lLoop
      return NIL
   endif

   //Toets die disket
   nFlop := floppytype(cDriv)
   //Forseer dos format nFlop := 0

   //Moet gewone dos of eie format gedoen word
   if nFlop == 0
      //Doen 'n dos format
      fDosFormat(cDriv)
   else
      lLoop := .t.
      do while lLoop

         //Skerm
         if cLanType() == "A"
            fScrBood(23,"Plaas die disket om te formatteer in die "+cDriv+" dryf!")
         else
            fScrBood(23,"Place the diskette to be formatted in the "+cDriv+" drive!")
         endif
         fScrWait(24)

         //Escaped
         if lastkey() == K_ESC
            lLoop := .f.
            loop
         endif

         //Skerm
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Disket word geformatteer")
         else
            fScrWbood(24,"Diskette being formatted")
         endif

         //Doen die format
         do case
            case nFlop == 1
               nErro := diskformat(cDriv,360,"fFormat",cText)
            case nFlop == 2
               if disktype(cDriv) == 253
                  nFlop := 1
                  nErro := diskformat(cDriv,360,"fFormat",cText)
               else
                  nErro := diskformat(cDriv,1200,"fFormat",cText)
               endif
            case nFlop == 3
               nErro := diskformat(cDriv,720,"fFormat",cText)
            case nFlop == 4
               if disktype(cDriv) == 249
                  nFlop := 3
                  nErro := diskformat(cDriv,720,"fFormat",cText)
               else
                  nErro := diskformat(cDriv,1440,"fFormat",cText)
               endif
            otherwise
               nErro := diskformat(cDriv,,"fFormat",cText)
         endcase

         //Toets die error
         if nErro <> 0
            if nErro == -4 .or. nErro == -2
               fDosFormat(cDriv)
               lLoop := .f.
               loop
            else
               if cLanType() == "A"
                  fScrBood(23,"Die disket is nie korrek geformatteer nie! ("+ltrim(str(nErro))+")")
               else
                  fScrBood(23,"The diskette has not been formatted correctly! ("+ltrim(str(nErro))+")")
               endif
               fScrWait(24)
            endif
         endif

         //Vra of nog een geformatteer moet word
         if cLanType() == "A"
            if fJaNee(24,"Formatteer nog 'n disket?",cColBott())
            else
               lLoop := .f.
            endif
         else
            if fJaNee(24,"Format another diskette?",cColBott())
            else
               lLoop := .f.
            endif
         endif

      enddo

   endif

return NIL

/**************************************************************************/
FUNCTION fFormat(nTrac,nHead)

   //Verklaar
   local nRetu := 0
   local nTotr := 1
   local getlist := {}

   //Waardes
   do case
      case nFlop == 1
         nTotr := 39
      case nFlop == 2
         nTotr := 79
      case nFlop == 3
         nTotr := 79
      case nFlop == 4
         nTotr := 79
   endcase

   //Skerm
   if cLanType() == "A"
      if nTrac == -1
         fScrBood(23,"Inisialiseer FAT en HOOFGIDS")
      else
         fScrBood(23,"Head "+str(nHead,2,0)+"  Track "+str(nTrac,3,0)+"  "+str(zer(nTotr-nTrac,nTotr)*100,3,0)+"% Completed")
      endif
   else
      if nTrac == -1
         fScrBood(23,"Initialise FAT and ROOT DIRECTORY")
      else
         fScrBood(23,"Head "+str(nHead,2,0)+"  Track "+str(nTrac,3,0)+"  "+str(zer(nTotr-nTrac,nTotr)*100,3,0)+"% Completed")
      endif
   endif

   //Sleutels
   if inkey() == K_ESC
      nRetu := 2
   else
      nRetu := 0
   endif

return(nRetu)

/****************************************************************************/
STATIC FUNCTION fDosFormat(cDriv)
   //Doen 'n normale dos format

   //Verklaar
   local cCscr := ""
   local nBoxc := 0
   local cPath := getenv("PATH")
   local getlist := {}
   priv cComm := ""

   //Waardes
   cDriv := if(cDriv==NIL,"A:",cDriv)

   //Dos path
   if len(trim(cPath)) == 0
      cPath := "\;\dos;\msdos;\pcdos"
   else
      if "dos" $ cPath
      else
         cPath := "\dos;"+cPath
      endif
   endif
   set path to (cPath)

   //Skerm
   fScrOpsk()

   //Kyk of format beskikbaar is
   if file("format.exe") .or. file("format.com")

      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(11,"Formatteer bevel? "+space(30),3,"Formatteer 'n disket")
         fScrBood(23,"[Esc]=Menu  [Enter]=Gaan voort met formattering")
         fSCrBood(24,"Verander die dos Format bevel indien nodig!")
      else
         nBoxc := fBoxCent(11,"Format command? "+space(30),3,"Format a diskette")
         fScrBood(23,"[Esc]=Menu  [Enter]=Proceed with format")
         fSCrBood(24,"Change the dos Format command if necessary!")
      endif
      keyboard chr(K_END)+" "

      //Vra die bevel
      cComm := padr("FORMAT "+cDriv,30)
      if cLanType() == "A"
         @12,nBoxc say "Formatteer bevel?" get cComm pict "@!"
      else
         @12,nBoxc say "Format command?" get cComm pict "@!"
      endif
      setcursor(1)
      read
      setcursor(0)

      if lastkey() == K_ESC .or. len(trim(cComm)) == 0
      else

         //Gaan voort
         cComm := trim(cComm)

         //Die bevel
         cCscr := savescreen(0,0,maxrow(),maxcol())
         setcolor(cColBegi())
         clear screen
         devpos(0,0)
         swpruncmd(cComm)
         fScrWait(24)
         restscreen(0,0,maxrow(),maxcol(),cCscr)

      endif

   else

      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(4,space(50),16,"Probleem!")
         @ 4,nBoxc say "Die dos FORMAT lˆer is nie beskikbaar nie.        "
         @ 6,nBoxc say "Gewoonlik is hierdie lˆer in die DOS  subgids  van"
         @ 7,nBoxc say "die hardeskyf.  Twee  moontlikhede  bestaan waarom"
         @ 8,nBoxc say "die lˆer nie beskikbaar is nie.                   "
         @10,nBoxc say "Eerstens bestaan die lˆer gladnie op die hardeskyf"
         @11,nBoxc say "nie en  dan  moet  dit  deur  u  rekenaarhandelaar"
         @12,nBoxc say "verskaf word."
         @14,nBoxc say "Tweedens bestaan die lˆer  wel  maar  is  dit  nie"
         @15,nBoxc say "in die dos PATH bevel nie. Om dit reg te stel moet"
         @16,nBoxc say "die PATH bevel in die  AUTOEXEC.BAT  lˆer  in  die"
         @17,nBoxc say "hoofgids   'root directory'   van   die  hardeskyf"
         @18,nBoxc say "verander word om die  DOS  subgids  in  te  sluit."
         @19,nBoxc say "U rekenaarhandelaar kan hiermee help.             "
      else
         nBoxc := fBoxCent(4,space(50),16,"Problem!")
         @ 4,nBoxc say "The dos FORMAT file is not available.             "
         @ 6,nBoxc say "This file is usually in the DOS  directory on     "
         @ 7,nBoxc say "the hard disk.  Two  possibilities exist as to    "
         @ 8,nBoxc say "why the file is not available.                    "
         @10,nBoxc say "Firstly the file is non-existant on the hard disk "
         @11,nBoxc say "and should be provided by a computer dealer.      "
         @12,nBoxc say "Secondly the file exists, but has not been        "
         @14,nBoxc say "included in the dos PATH command.                 "
         @15,nBoxc say "To correct this the PATH command in the           "
         @16,nBoxc say "AUTOEXEC.BAT  file in the root directory of the  "
         @17,nBoxc say "hard disk should be changed to include the DOS    "
         @18,nBoxc say "directory.                                        "
         @19,nBoxc say "Your computer dealer should assist you.           "
      endif
      fScrWait(24)

   endif

   //Herstel
   set path to
return NIL

