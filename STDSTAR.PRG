// Application: StudMaster for Beef Cattle
//   File Name: STDSTAR.PRG
// Description: Program to read the standard program values from stdwaar.tdb
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-20-94      11:19:34am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdstar

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()

   begin sequence

      // Open file
      aCdbf := fATopen(aCdbf,,"STDWAAR",,"tdb","STDWAAR")
      if !aCdbf[len(aCdbf),1]
         lRetu := .f.
         break
      endif

      // Temporary heading
      cGebNaam(trim(STDWAAR->genaam))

      // Language
      cLanType(STDWAAR->lantyp)
      if cLanType() == "A"
         cAppName("StoetMeester V4.4b(25)")
      else
         cAppName("StudMaster V4.4b(25)")
      endif

      // Versions
      // 4.4b(4) Nuwe blup formaat inlees
      // 4.4b(5) Inspeksielys veranderinge
      // 4.4b(6) Korrigeer nuwe blup formaat fout
      // 4.4b(7) Remove -> char at end of perf test electronic file
      // 4.4b(8) Add the where is animal code to the form e cancellation form
      // 4.4b(9) Import iris historic data. Haal dier uit kudde as dit uit kudde datum het, al het dit huidige eienaar lidnommer
      // 4.4b(10) Export matings data for Iris 13-04-25 12:25
      // 4.4b(11) Export cancellation data 13-07-16 06:40
      // 4.4b(12) Korrigeer fout waar fase d skrotum gedruk word op inspeksielys ipv 540 d skrotum
      // 4.4b(13) Change the batch header for electronic data files
      // 4.4b(14) Change the batch header for electronic births, matings and masses
      // 4.4b(15) Add ave calving interval in own reports under pedigree information section
      // 4.4b(15) Add the generation to the extended mating reports
      // 4.4b(15) Calculate wean mass ratio on corrected mass rather than actual wean mass
      // 4.4b(16) 14-11-24 11:35 Add numeric character search at edit mating table
      // 4.4b(17) 15-04-02 11:43 Add excel format to electronic mating list
      // 4.4b(18) 15-04-24 10:01 Add sire id number to excel format in (17)
      // 4.4b(19) 15-04-24 13:04 Remove
      // 4.4b(20) 15-09-16 15:40 Change registration status on birth notifications
      // 4.4b(21) 11/11/15 01:05pm for breed 229 (Santa Gertrudis) from R to Q
      // 4.4b(22) 13/01/17 Import studbook reg numbers as full numbers (10char) and not only number
      // 4.4b(23) 17-11-08 14:17 Add generation calculation at Angus birth entry
      // 4.4b(23) 17-11-08 14:18 Add HHYYVVVV name format at Wagyu birth entry
      // 4.4b(24) 18-01-23 15:04 Electronic matings to studbook. One character too many in case of msire fathers
      //                         15 spaces reduced to 14 characters
      // 4.4b(25) 18-08-02 05:43 Include indekskode in IRIS electronic birth notification

      // Colors
      if iscolor()
         // If colour screen
         fSetColor()
      else
         // Monochroom
         cColNorm("W+/N,N/W,N")
         cColInve("N/W,W/N,N")
         cColMenu("N/W,W+/N,N")
         cColHead("N/W,N/W,N")
         cColBott("N/W,N/W,N")
         cColHelp("N/W,W+/N,N")
         cColTopl("W+/N,N/W,N")
         cColAgte("W+/N,N/W,N")
         cAgtChar("±")
      endif

      // Printer control codes //cPrnType(alltrim(STDWAAR->prtype))
      cPrnStar(alltrim(STDWAAR->prstar))
      nPrnCode(STDWAAR->prcode)
      cPrnInit(alltrim(STDWAAR->prinit))
      nPrnLptp(STDWAAR->prlptp)

      cPrnNorm(alltrim(STDWAAR->prnorm))
      nPrnLine(STDWAAR->prline)
      nPrnLeng(STDWAAR->prleng)
      nPrnPrnl(STDWAAR->prprnl)
      nPrnWidt(STDWAAR->prwidt)

      cPrnCond(alltrim(STDWAAR->prcond))
      nPrnCwid(STDWAAR->prcwid)
      nPrcLeng(STDWAAR->prcpal)
      nPrcPrnl(STDWAAR->prcprl)

      cPrn8lpi(alltrim(STDWAAR->pr8lpi))
      cPrn6lpi(alltrim(STDWAAR->pr6lpi))

      // Number of days to warn if diary entry
      nDayDiar(STDWAAR->daydia)

      // Number of days to warn if action entry
      nDayActi(STDWAAR->dayact)

      // Living animal where is animal codes
      cWaarisd(strtran(left(STDWAAR->velded,29)," ","?"))

      // Country
      cIsoCoun("ZAF")

      // Id number
      cIdForm("1")
      cIdMask("KKKKJJ-VVVV")

      // Data drive
      if empty(stddryf(trim(STDWAAR->datadr)))
         lRetu := .f.
         break
      else
         if rlock()
            STDWAAR->datadr := left(cDd(),len(cDd())-1)
            dbunlock()
         endif
      endif

      // Todays date
      if empty(stddatu(iif(date()>STDWAAR->datuml,date(),STDWAAR->datuml)))
         lRetu := .f.
         break
      else
         if rlock()
            STDWAAR->datuml := dAppDate()
            dbunlock()
         endif
      endif

	  // Initialize menu option string
	  fScrOpsk()
	  cOption(-9999)

   end

   // Reset
   fATclose(aCdbf)

return lRetu
