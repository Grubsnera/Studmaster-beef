// Application: StudMaster for Beef Cattle
//   File Name: STDWAAR.PRG
// Description: Program to read the user standard values
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-22-94      01:10:47pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdwaar

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local aDbfs := {}
   local cFile := ""
   local lLoop := .t.
   local lNaam := .t.
   local aMenu := {}
   local nBoxc := 1
   local getlist := {}

   begin sequence

      // Get Origional Values
      cFile := cDd()+"STDDRUK.DBF"

      // Create STDDRUK.DBF if does not exist
      if !file(cDd()+"STDDRUK.DBF")
         // Create printer file if not exist
         copy file STDDRUK.tdb to (cDd()+"STDDRUK.DBF")
      endif

      // Dbf array
      ASIZE(aDbfs,0)
      aadd(aDbfs,{"PRTYPE","C",006,000})
      aadd(aDbfs,{"PRLPTP","N",001,000})
      aadd(aDbfs,{"PRINIT","C",080,000})
      aadd(aDbfs,{"PRNLIN","N",003,000})
      aadd(aDbfs,{"PRNPRL","N",003,000})
      aadd(aDbfs,{"PRNPAL","N",003,000})
      aadd(aDbfs,{"PRNWID","N",003,000})
      aadd(aDbfs,{"PRNCC" ,"C",080,000})
      aadd(aDbfs,{"PRCLIN","N",003,000})
      aadd(aDbfs,{"PRCPRL","N",003,000})
      aadd(aDbfs,{"PRCPAL","N",003,000})
      aadd(aDbfs,{"PRCWID","N",003,000})
      aadd(aDbfs,{"PRCCC" ,"C",080,000})
      aadd(aDbfs,{"PRNAME","C",030,000})
      aadd(aDbfs,{"PRNAAM","C",030,000})
      aadd(aDbfs,{"PR8LPI","C",080,000})
      aadd(aDbfs,{"PR6LPI","C",080,000})
      aadd(aDbfs,{"PRSTAR","C",080,000})
      aadd(aDbfs,{"PRWAIT","N",003,000})

      // Test file structure
      if cLanType() == "A"
         if !stdconv(cDd(),"STDDRUK","DBF",aDbfs,"Drukker kodes",.f.)
            alert("STDDRUK.DBF lˆerintegriteit het gefaal!")
            lRetu := .f.
            break
         endif
      else
         if !stdconv(cDd(),"STDDRUK","DBF",aDbfs,"Printer codes",.f.)
            alert("STDDRUK.DBF failed the file integrity check!")
            lRetu := .f.
            break
         endif
      endif

      // Values
      cFile := cDd()+"STDWAAR.DBF"

      // Create STDWAAR.DBF if does not exist
      if !file(cDd()+"STDWAAR.DBF")
         // Create data drive file if not exist
         copy file STDWAAR.tdb to (cDd()+"STDWAAR.DBF")
         lNewFile(.t.)
      endif

      // Dbf array
      ASIZE(aDbfs,0)
      aadd(aDbfs,{"GENAAM"  ,"C",040,000})
      aadd(aDbfs,{"ADRES1"  ,"C",040,000})
      aadd(aDbfs,{"ADRES2"  ,"C",040,000})
      aadd(aDbfs,{"ADRES3"  ,"C",040,000})
      aadd(aDbfs,{"POSKOD"  ,"C",004,000})
      aadd(aDbfs,{"DATUML"  ,"D",008,000})
      aadd(aDbfs,{"DATUMB"  ,"D",008,000})
      aadd(aDbfs,{"DATADR"  ,"C",030,000})
      aadd(aDbfs,{"NORLET"  ,"C",003,000})
      aadd(aDbfs,{"NORAGT"  ,"C",003,000})
      aadd(aDbfs,{"NORGLE"  ,"C",003,000})
      aadd(aDbfs,{"NORGAG"  ,"C",003,000})
      aadd(aDbfs,{"NORBOR"  ,"C",003,000})
      aadd(aDbfs,{"MENLET"  ,"C",003,000})
      aadd(aDbfs,{"MENAGT"  ,"C",003,000})
      aadd(aDbfs,{"MENBLE"  ,"C",003,000})
      aadd(aDbfs,{"MENBAG"  ,"C",003,000})
      aadd(aDbfs,{"MENSHA"  ,"C",003,000})
      aadd(aDbfs,{"HEDLET"  ,"C",003,000})
      aadd(aDbfs,{"HEDAGT"  ,"C",003,000})
      aadd(aDbfs,{"BOTLET"  ,"C",003,000})
      aadd(aDbfs,{"BOTAGT"  ,"C",003,000})
      aadd(aDbfs,{"HELLET"  ,"C",003,000})
      aadd(aDbfs,{"HELAGT"  ,"C",003,000})
      aadd(aDbfs,{"PRNORM"  ,"C",080,000})
      aadd(aDbfs,{"PRCOND"  ,"C",080,000})
      aadd(aDbfs,{"PRLENG"  ,"N",003,000})
      aadd(aDbfs,{"KUDVVO"  ,"C",020,000})
      aadd(aDbfs,{"KUDKKL"  ,"C",004,000})
      aadd(aDbfs,{"PRELID"  ,"C",010,000})
      aadd(aDbfs,{"STREEK"  ,"C",030,000})
      aadd(aDbfs,{"JAARLE"  ,"C",002,000})
      aadd(aDbfs,{"KALFBN"  ,"C",004,000})
      aadd(aDbfs,{"KALFBE"  ,"N",004,000})
      aadd(aDbfs,{"KALFBL"  ,"N",004,000})
      aadd(aDbfs,{"VELDED"  ,"C",059,000})
      aadd(aDbfs,{"OUDMAA"  ,"C",002,000})
      aadd(aDbfs,{"RASKOD"  ,"C",003,000})
      aadd(aDbfs,{"LANTYP"  ,"C",001,000})
      aadd(aDbfs,{"VOLGID"  ,"C",012,000})
      aadd(aDbfs,{"DRYFLE"  ,"C",002,000})
      aadd(aDbfs,{"AGTLET"  ,"C",003,000})
      aadd(aDbfs,{"AGTAGT"  ,"C",003,000})
      aadd(aDbfs,{"AGTCHR"  ,"C",001,000})
      aadd(aDbfs,{"PRCODE"  ,"N",003,000})
      aadd(aDbfs,{"PRPRNL"  ,"N",003,000})
      aadd(aDbfs,{"PRWIDT"  ,"N",003,000})
      aadd(aDbfs,{"PRLPTP"  ,"N",003,000})
      aadd(aDbfs,{"PRLINE"  ,"N",003,000})
      aadd(aDbfs,{"IDFORM"  ,"C",001,000})
      aadd(aDbfs,{"DAYDIA"  ,"N",003,000})
      aadd(aDbfs,{"DAYACT"  ,"N",003,000})
      aadd(aDbfs,{"ISOCOU"  ,"C",003,000})
      aadd(aDbfs,{"MAILTA"  ,"C",060,000})
      aadd(aDbfs,{"IDMASK"  ,"C",012,000})
      aadd(aDbfs,{"PRTYPE"  ,"C",006,000})
      aadd(aDbfs,{"PRCLIN"  ,"N",003,000})
      aadd(aDbfs,{"PRCPRL"  ,"N",003,000})
      aadd(aDbfs,{"PRCPAL"  ,"N",003,000})
      aadd(aDbfs,{"PRCWID"  ,"N",003,000})
      aadd(aDbfs,{"PRINIT"  ,"C",080,000})
      aadd(aDbfs,{"SCPORT"  ,"N",001,000})
      aadd(aDbfs,{"SCBAUD"  ,"N",005,000})
      aadd(aDbfs,{"SCPARI"  ,"C",001,000})
      aadd(aDbfs,{"SCBITS"  ,"N",001,000})
      aadd(aDbfs,{"SCSTOP"  ,"N",001,000})
      aadd(aDbfs,{"PR8LPI"  ,"C",080,000})
      aadd(aDbfs,{"PR6LPI"  ,"C",080,000})
      aadd(aDbfs,{"BATCHN"  ,"N",004,000})
      aadd(aDbfs,{"HERDNO"  ,"C",010,000})
      aadd(aDbfs,{"PRSTAR"  ,"C",080,000})
      aadd(aDbfs,{"WORDPD"  ,"C",080,000})
      aadd(aDbfs,{"PRWAIT"  ,"N",003,000})
      aadd(aDbfs,{"PALMDI"  ,"C",080,000})
      aadd(aDbfs,{"MAILAD"  ,"C",080,000})
      aadd(aDbfs,{"ELECSQ"  ,"N",003,000})

      // Test file structure
      if cLanType() == "A"
         if !stdconv(cDd(),"STDWAAR","DBF",aDbfs,"Standaardwaardes",.f.)
            alert("STDWAAR.DBF lˆerintegriteit het gefaal!")
            lRetu := .f.
            break
         endif
      else
         if !stdconv(cDd(),"STDWAAR","DBF",aDbfs,"Standard values",.f.)
            alert("STDWAAR.DBF failed the file integrity check!")
            lRetu := .f.
            break
         endif
      endif

      // Open drives file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR",,,,.f.)
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      //Taalvoorkeur
      cLanType(STDWAAR->lantyp)

      // If demo do not ask name
      if empty(cReeNomm()) .or. "0000" $ cReeNomm()
         lNaam := .f.
      endif

      if lNaam .and. lNewFile()

         // Ask the users name
         fScrOpsk()
         if cLanType() == "A"
            fScrBood( maxrow()-1, "[F1]=Hulp" )
            fScrBood( maxrow()  , "Tik u geregistreerde adres asook prestasietoetsskema besonderhede." )
         else
            fScrBood( maxrow()-1, "[F1]=Help" )
            fScrBood( maxrow()  , "Type your registered address as well as performance testing details." )
         endif
         nBoxc := fBoxCent( 6, "KuddeKenmerkletter 1234567890123456789012345678901234567890", 13, "GEREGISTREERDE ADRES" )
         setcolor(cColNorm())
         set curs on
         if cLanType() == "A"
            @  7, nBoxc say "              Naam" get STDWAAR->genaam
            @  8, nBoxc say "        Adreslyn 1" get STDWAAR->adres1
            @  9, nBoxc say "        Adreslyn 2" get STDWAAR->adres2
            @ 10, nBoxc say "        Adreslyn 3" get STDWAAR->adres3
            @ 11, nBoxc say "           Poskode" get STDWAAR->poskod pict "9999"
            @ 12, nBoxc say "      ISO Landkode" get STDWAAR->isocou pict "@!"
            @ 13, nBoxc say "KuddeKenmerkletter" get STDWAAR->kudkkl pict "@!"
            @ 14, nBoxc say "  KuddeVoorvoegsel" get STDWAAR->kudvvo pict "@!"
            @ 15, nBoxc say "         Lidnommer" get STDWAAR->prelid pict "@9"
            @ 16, nBoxc say " Breedplan raskode" get STDWAAR->herdno pict "@!"
            @ 17, nBoxc say "    StreeksKantoor" get STDWAAR->streek pict "@!"
         else
            @  7, nBoxc say "              Name" get STDWAAR->genaam
            @  8, nBoxc say "    Address line 1" get STDWAAR->adres1
            @  9, nBoxc say "    Address line 2" get STDWAAR->adres2
            @ 10, nBoxc say "    Address line 3" get STDWAAR->adres3
            @ 11, nBoxc say "       Postal code" get STDWAAR->poskod pict "9999"
            @ 12, nBoxc say "  ISO Country code" get STDWAAR->isocou pict "@!"
            @ 13, nBoxc say "  Herd Designation" get STDWAAR->kudkkl pict "@!"
            @ 14, nBoxc say "       Herd Prefix" get STDWAAR->kudvvo pict "@!"
            @ 15, nBoxc say "     Member Number" get STDWAAR->prelid pict "@9"
            @ 16, nBoxc say "BreedplanBreedCode" get STDWAAR->herdno pict "@!"
            @ 17, nBoxc say "   Regional Office" get STDWAAR->streek pict "@!"
         endif
         read
         set curs off

      endif


      // Function keys
      set function 8 to alltrim(STDWAAR->kudkkl)
      set function 7 to alltrim(STDWAAR->kudvvo) + " "

      // Kry gebruikersnaam
      cGebNaam(STDWAAR->genaam)
      cTotNaam(;
         STDWAAR->adres1 + ;                     //   1,40
         STDWAAR->adres2 + ;                     //  41,40
         STDWAAR->adres3 + ;                     //  81,40
         STDWAAR->poskod + ;                     // 121,4
         STDWAAR->kudkkl + ;                     // 125,4
         STDWAAR->kudvvo + ;                     // 129,20
         STDWAAR->raskod + ;                     // 149,3
         STDWAAR->prelid + ;                     // 152,10
         STDWAAR->streek + ;                     // 162,30
         STDWAAR->herdno + ;                     // 192,10
         STDWAAR->isocou)                        // 202,3

      // If colour screen
      if iscolor()

         if empty(STDWAAR->agtlet)
            STDWAAR->agtlet := "W  "
         endif
         if empty(STDWAAR->agtagt)
            STDWAAR->agtagt := "B  "
         endif

         // Screen background character
         cAgtChar(STDWAAR->agtchr)

         // Set the color
         fSetColor()

      endif

      // Set Printer control codes

      // Printer table code
      if empty(STDWAAR->prcode)
         STDWAAR->prcode := nPrnCode()
      else
         nPrnCode(STDWAAR->prcode)
      endif

      // Print port
      if empty(STDWAAR->prlptp)
         STDWAAR->prlptp := nPrnLptp()
      else
         nPrnLptp(STDWAAR->prlptp)
      endif

      // Print initialize
      cPrnStar(alltrim(STDWAAR->prstar))

      // Print page feed
      cPrnInit(alltrim(STDWAAR->prinit))

      // Normal print
      if empty(STDWAAR->prnorm)
         STDWAAR->prnorm := cPrnNorm()
      else
         cPrnNorm(alltrim(STDWAAR->prnorm))
      endif

      // Printer starting line
      if empty(STDWAAR->prline)
         STDWAAR->prline := nPrnLine()
      else
         nPrnLine(STDWAAR->prline)
      endif

      // Page length
      if empty(STDWAAR->prleng)
         STDWAAR->prleng := nPrnLeng()
      else
         nPrnLeng(STDWAAR->prleng)
      endif

      // Print length
      if empty(STDWAAR->prprnl)
         STDWAAR->prprnl := nPrnPrnl()
      else
         nPrnPrnl(STDWAAR->prprnl)
      endif

      // Print width
      if empty(STDWAAR->prwidt)
         STDWAAR->prwidt := nPrnWidt()
      else
         nPrnWidt(STDWAAR->prwidt)
      endif

      // Condensed print
      if empty(STDWAAR->prcond)
         STDWAAR->prcond := cPrnCond()
      else
         cPrnCond(alltrim(STDWAAR->prcond))
      endif

      // Print width
      if empty(STDWAAR->prcwid)
         STDWAAR->prcwid := nPrnCwid()
      else
         nPrnCwid(STDWAAR->prcwid)
      endif

      // Page length (8lpi)
      if empty(STDWAAR->prcpal)
         STDWAAR->prcpal := nPrcLeng()
      else
         nPrcLeng(STDWAAR->prcpal)
      endif

      // Print length (8lpi)
      if empty(STDWAAR->prcprl)
         STDWAAR->prcprl := nPrcPrnl()
      else
         nPrcPrnl(STDWAAR->prcprl)
      endif

      // Eight line per inch
      if empty(STDWAAR->pr8lpi)
         STDWAAR->pr8lpi := cPrn8lpi()
      else
         cPrn8lpi(alltrim(STDWAAR->pr8lpi))
      endif

      // Six line per inch
      if empty(STDWAAR->pr6lpi)
         STDWAAR->pr6lpi := cPrn6lpi()
      else
         cPrn6lpi(alltrim(STDWAAR->pr6lpi))
      endif

      // Printer wait after page feed
      if empty(STDWAAR->prwait)
         STDWAAR->prwait := nPrnWait()
      else
         nPrnWait(STDWAAR->prwait)
      endif

      // Serail Communication Port
      if empty(STDWAAR->scport)
         STDWAAR->scport := nScPort()
      endif
      nScPort(STDWAAR->scport)

      // Serail Communication Baud
      if empty(STDWAAR->scbaud)
         STDWAAR->scbaud := nScBaud()
      endif
      nScBaud(STDWAAR->scbaud)

      // Serail Communication Parity
      if empty(STDWAAR->scpari)
         STDWAAR->scpari := cScPari()
      endif
      cScPari(STDWAAR->scpari)

      // Serail Communication Bits
      if empty(STDWAAR->scbits)
         STDWAAR->scbits := nScBits()
      endif
      nScBits(STDWAAR->scbits)

      // Serail Communication Stop bits
      if empty(STDWAAR->scstop)
         STDWAAR->scstop := nScStop()
      endif
      nScStop(STDWAAR->scstop)

      // Number of days to warn if diary entry
      if empty(STDWAAR->daydia)
         STDWAAR->daydia := nDayDiar()
      endif
      nDayDiar(STDWAAR->daydia)

      // Number of days to warn if action entry
      if empty(STDWAAR->dayact)
         STDWAAR->dayact := nDayActi()
      endif
      nDayActi(STDWAAR->dayact)

      // Country
      cIsoCoun(STDWAAR->isocou)

      // Id number
      cIdForm(STDWAAR->idform)
      cIdMask(STDWAAR->idmask)

      // E-Mail target
      if empty(STDWAAR->mailta)
         STDWAAR->mailta := cMailTar()
      endif
      cMailTar(alltrim(STDWAAR->mailta))

      // E-Mail address
      if empty(STDWAAR->mailad)
         STDWAAR->mailad := cMailAdd()
      endif
      cMailAdd(alltrim(STDWAAR->mailad))

      // Wordpad
      if empty(STDWAAR->wordpd)
         STDWAAR->wordpd := cWordPad()
      endif
      cWordPad(alltrim(STDWAAR->wordpd))

      // Palmtop
      if empty(STDWAAR->palmdi)
         STDWAAR->palmdi := cPalmDir()
      endif
      cPalmDir(alltrim(STDWAAR->palmdi))

      // Ask the breed if new installation
      if lNewFile()
         fScrOpsk()
         STDWAAR->raskod := sm3rass( STDWAAR->raskod )
      endif

      // Kry gebruikersnaam
      cGebNaam(STDWAAR->genaam)
      cTotNaam(;
         STDWAAR->adres1 + ;                     //   1,40
         STDWAAR->adres2 + ;                     //  41,40
         STDWAAR->adres3 + ;                     //  81,40
         STDWAAR->poskod + ;                     // 121,4
         STDWAAR->kudkkl + ;                     // 125,4
         STDWAAR->kudvvo + ;                     // 129,20
         STDWAAR->raskod + ;                     // 149,3
         STDWAAR->prelid + ;                     // 152,10
         STDWAAR->streek + ;                     // 162,30
         STDWAAR->herdno + ;                     // 192,10
         STDWAAR->isocou)                        // 202,3


      // Living animals
      cWaarisd(strtran(left(STDWAAR->velded,29)," ","?"))

      // Id number format
      sm3idfo("Read")

      // Warn if backups are not made
      if !empty(STDWAAR->datumb) .and. !file(cDd()+"FILEINTE.TXT")
         if dAppDate() - STDWAAR->datumb > 31
            fScrOpsk()
            fScrBood(maxrow()-1)
            if cLanType() == "A"
               nBoxc := fBoxCent(9,space(50),8,"RUGSTEUN WAARSKUWING!!!")
               @10, nBoxc say "Inligting dui daarop dat u lanklaas  rugsteun  van"
               @11, nBoxc say "van u data geskep het.  Rugsteun  word  geskep  om"
               @12, nBoxc say "uself te beskerm teen dataverlies indien iets  met"
               @13, nBoxc say "die rekenaar of program verkeerd  sou  gaan.  Neem"
               @14, nBoxc say "dus asseblief  vir  u  eie  onthalwe  rugsteun  op"
               @15, nBoxc say "meer as een stel rugsteundiskette!                "
            else
               nBoxc := fBoxCent(9,space(50),8,"BACKUP WARNING!!!")
               @10, nBoxc say "Information shows that a backup of your  data  was"
               @11, nBoxc say "created long ago. Backup is created to prevent"
               @12, nBoxc say "loss of data should anything happen  to  your"
               @13, nBoxc say "computer or program. For  your  own  sake,  please"
               @14, nBoxc say "create a backup of your data  on  preferably  more"
               @15, nBoxc say "than one set of disks!                            "
            endif
            fScrWait(maxrow())
         endif
      endif

      // Warn to calculate month ages
      if STDWAAR->oudmaa <> substr(dtos(dAppDate()),5,2) .and. !file(cDd()+"FILEINTE.TXT")
         lTestDia(.t.)
         fScrOpsk()
         STDWAAR->oudmaa := substr(dtos(dAppDate()),5,2)
         fScrBood(maxrow()-1)
         if cLanType() == "A"
            nBoxc := fBoxCent(9,space(50),8,"MAANDOUDERDOMME!!!")
            @10, nBoxc say "Aangesien dit die eerste maal hierdie maand is wat"
            @11, nBoxc say "StoetMeester gebruik word, moet diere se maand-   "
            @12, nBoxc say "ouderdomme bereken word.                          "
            @13, nBoxc say "                                                  "
            @14, nBoxc say "Gebruik opsie HE om maandouderdomme te bereken.   "
            @15, nBoxc say "                                                  "
         else
            nBoxc := fBoxCent(9,space(50),8,"MONTH AGES!!!")
            @10, nBoxc say "Since this is the first time StudMaster is used   "
            @11, nBoxc say "this month, month ages of animals must be         "
            @12, nBoxc say "calculated.                                       "
            @13, nBoxc say "                                                  "
            @14, nBoxc say "Use option HE to calculate month ages.            "
            @15, nBoxc say "                                                  "
         endif
         fScrWait(maxrow())
         // INKEY(0)
      endif

   end

   // Reset
   fATclose(aCdbf)

   // Update the breed file with breedplan code






return lRetu

/******************************************************************************/
FUNCTION fSetColor()

   // Funksie om color variables te vul

   // Stel kleure
   cColNorm(;
      trim(STDWAAR->norlet) + "/" + ;
      trim(STDWAAR->noragt) + "," + ;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norbor))

   cColInve(;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norlet) + "/" + ;
      trim(STDWAAR->noragt) + "," + ;
      trim(STDWAAR->norbor))

   cColMenu(;
      trim(STDWAAR->menlet) + "/" + ;
      trim(STDWAAR->menagt) + "," + ;
      trim(STDWAAR->menble) + "/" + ;
      trim(STDWAAR->menbag) + "," + ;
      trim(STDWAAR->mensha))

   cColHead(;
      trim(STDWAAR->hedlet) + "/" + ;
      trim(STDWAAR->hedagt) + "," + ;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norbor))

   cColBott(;
      trim(STDWAAR->botlet) + "/" + ;
      trim(STDWAAR->botagt) + "," + ;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norbor))

   cColHelp(;
      trim(STDWAAR->hellet) + "/" + ;
      trim(STDWAAR->helagt) + "," + ;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norbor))

   cColTopl(;
      trim(STDWAAR->norlet) + "/" + ;
      trim(STDWAAR->norbor) + "," + ;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norbor))

   cColAgte(;
      trim(STDWAAR->agtlet) + "/" + ;
      trim(STDWAAR->agtagt) + "," + ;
      trim(STDWAAR->norgle) + "/" + ;
      trim(STDWAAR->norgag) + "," + ;
      trim(STDWAAR->norbor))

return NIL
