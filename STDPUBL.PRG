// Application: StudMaster for Beef Cattle
//   File Name: STDPUBL.PRG
// Description: Program to keep track of public variables
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-20-94      05:14:30am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION cAppName(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "StoetMeester V4.4b(25)"
   endif
return cRetu

/******************************************************************************/
FUNCTION cVersion(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "4.4b(25)"
   endif
return cRetu

/******************************************************************************/
FUNCTION cOwnFone(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "+27 (82) 8812310"
   endif
return cRetu

/******************************************************************************/
FUNCTION cOwnFax(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "+27 (86) 5549553"
   endif
return cRetu

/******************************************************************************/
FUNCTION cGebNaam(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "Agricultural Data Control"
   endif
return cRetu

/******************************************************************************/
FUNCTION cRegNaam(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "Agricultural Data Control"
   endif
return cRetu

/******************************************************************************/
FUNCTION cTotNaam(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := space(100)
   endif
return cRetu

/******************************************************************************/
FUNCTION cColBegi(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := setcolor()
   endif
return cRetu

/******************************************************************************/
FUNCTION cColNorm(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "W+/N,N/W,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColInve(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "N/W,W/N,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColMenu(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "N/W,W+/N,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColHead(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "N/W,N/W,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColBott(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "N/W,N/W,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColHelp(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "N/W,W+/N,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColTopl(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "W+/N,N/W,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cColAgte(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "W+/N,N/W,N"
   endif
return cRetu

/******************************************************************************/
FUNCTION cAgtChar(cData)
   static cRetu
   if cData == NIL
      if cRetu == NIL
         cRetu := " "
      endif
   else
      cRetu := cData
   endif
return cRetu

/******************************************************************************/
FUNCTION dAppDate(dData)
   static dRetu
   if !empty(dData)
      dRetu := dData
   endif
   if empty(dRetu)
      dRetu := date()
   endif
return dRetu

/******************************************************************************/
FUNCTION cDd(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := ""
   endif
return cRetu

/******************************************************************************/
//FUNCTION cPrnType(cData)
//   static cRetu
//   if !empty(cData)
//      cRetu := cData
//   endif
//   if empty(cRetu)
//      cRetu := "MATRIX"
//   endif
//return cRetu

/******************************************************************************/
FUNCTION nPrnCode(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 1
   endif
return nRetu

/******************************************************************************/
FUNCTION nPrnLptp(nData)
   static nRetu
   if nData != NIL .and. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 1
   endif
return nRetu

/******************************************************************************/
FUNCTION cPrnStar(cData)
   static cRetu
   if cData == NIL
   else
      cRetu := cData
   endif
return cRetu

/******************************************************************************/
FUNCTION cPrnInit(cData)
   static cRetu
   if cData == NIL
   else
      cRetu := cData
   endif
return cRetu

/******************************************************************************/
FUNCTION cPrnNorm(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "chr(18)"
   endif
return cRetu

/******************************************************************************/
FUNCTION nPrnLine(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 0
   endif
return nRetu

/******************************************************************************/
FUNCTION nPrnLeng(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 66
   endif
return nRetu

/******************************************************************************/
FUNCTION nPrnPrnl(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 60
   endif
return nRetu

/******************************************************************************/
FUNCTION nPrnWidt(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 79
   endif
return nRetu

/******************************************************************************/
FUNCTION cPrnCond(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "chr(15)"
   endif
return cRetu

/******************************************************************************/
FUNCTION nPrnCwid(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 129
   endif
return nRetu

/******************************************************************************/
//FUNCTION nPrnLine(nData)
//   static nRetu
//   if nData != NIL .AND. nData != nRetu
//      nRetu := nData
//   endif
//   if empty(nRetu)
//      nRetu := 1
//   endif
//return nRetu

/******************************************************************************/
FUNCTION nPrcLeng(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 88
   endif
return nRetu

/******************************************************************************/
FUNCTION nPrcPrnl(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 80
   endif
return nRetu

/******************************************************************************/
FUNCTION cPrn8lpi(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "chr(27)+[0]"
   endif
return cRetu

/******************************************************************************/
FUNCTION cPrn6lpi(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "chr(27)+[2]"
   endif
return cRetu

/******************************************************************************/
FUNCTION nPrnWait(nData)
   static nRetu
   if nData != NIL .AND. nData != nRetu
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 0
   endif
return nRetu

/******************************************************************************/
FUNCTION nScPort(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 1
   endif
return nRetu

/******************************************************************************/
FUNCTION nScBaud(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 9600
   endif
return nRetu

/******************************************************************************/
FUNCTION cScPari(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := "N"
   endif
return nRetu

/******************************************************************************/
FUNCTION nScBits(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 8
   endif
return nRetu

/******************************************************************************/
FUNCTION nScStop(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 1
   endif
return nRetu

/******************************************************************************/
FUNCTION nDayDiar(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 14
   endif
return nRetu

/******************************************************************************/
FUNCTION nDayActi(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 7
   endif
return nRetu

/******************************************************************************/
FUNCTION lTestDbf(lData)
   static lRetu
   if lData == .f. .or. lData == .t.
      lRetu := lData
   endif
   if empty(lRetu)
      lRetu := .f.
   endif
return lRetu

/******************************************************************************/
FUNCTION lNewFile(lData)
   static lRetu
   if lData == .f. .or. lData == .t.
      lRetu := lData
   endif
   if empty(lRetu)
      lRetu := .f.
   endif
return lRetu

/******************************************************************************/
FUNCTION cLanType(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "A"
   endif
return cRetu

/******************************************************************************/
FUNCTION nToetsNo(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 0
   endif
return nRetu

/******************************************************************************/
FUNCTION nToetsAn(nData)
   static nRetu
   if !empty(nData)
      nRetu := nData
   endif
   if empty(nRetu)
      nRetu := 0
   endif
return nRetu

/******************************************************************************/
FUNCTION cReeNomm(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "SMA0000"
   endif
return cRetu

/******************************************************************************/
FUNCTION cWaarisd(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "IK-IH-KK-CH"
   endif
return cRetu

/******************************************************************************/
FUNCTION cFileNam(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := space(12)
   endif
return cRetu

/******************************************************************************/
FUNCTION cIndeExt(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := ordbagext()
   endif
return cRetu

/******************************************************************************/
FUNCTION lTestDia(lData)
   static lRetu
   if lData == .f. .or. lData == .t.
      lRetu := lData
   endif
   if empty(lRetu)
      lRetu := .f.
   endif
return lRetu

/******************************************************************************/
FUNCTION cMailTar(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := cDd()
   endif
return cRetu

/******************************************************************************/
FUNCTION cMailAdd(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := ""
   endif
return cRetu

/******************************************************************************/
FUNCTION cWordPad(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "C:\Progra~1\Access~1\"
   endif
return cRetu

/******************************************************************************/
FUNCTION cPalmDir(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "C:\Mbdata\"
   endif
return cRetu

/******************************************************************************/
FUNCTION cIsoCoun(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "ZAF"
   endif
return cRetu

/******************************************************************************/
FUNCTION cIdForm(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "1"
   endif
return cRetu

/******************************************************************************/
FUNCTION cIdMask(cData)
   static cRetu
   if !empty(cData)
      cRetu := cData
   endif
   if empty(cRetu)
      cRetu := "KKKKJJ-VVVV"
   endif
return cRetu

/******************************************************************************/
FUNCTION cOption(nData)
   static cRetu

   if nData != NIL
      if nData = -9999
         cRetu := ""
      elseif nData < 0
         cRetu := SUBSTR(cRetu,1,(LEN(cRetu) - ABS(nData)))
      elseif nData > 0
         cRetu += CHR(64+nData)
      endif
   endif

return cRetu

