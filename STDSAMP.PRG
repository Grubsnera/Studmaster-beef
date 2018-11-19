// Application: StudMaster for Beef Cattle
//   File Name: STDSAMP.PRG
// Description: Program to create sample files
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-23-94      06:20:03am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdsamp

   // Declare
   local lRetu := .t.
   begin sequence

      if file(cDd()+"FILEINTE.TXT")

         copy file SM3RASS.tdb to (cDd()+"SM3RASS.DBF") //Rasse
         copy file SM3DEKU.tdb to (cDd()+"SM3DEKU.DBF") //Kudde dekaktiwiteite

         if !file(cDd()+"SM3SEKE.DBF")
            copy file SM3SEKE.tdb to (cDd()+"SM3SEKE.DBF") //Sekere inligting
         endif

         if !file(cDd()+"SM3TABE.DBF")
            copy file SM3TABE.tdb to (cDd()+"SM3TABE.DBF") //Veegetal tabelle
         endif

         if !file(cDd()+"SM3SELG.DBF")
            copy file SM3SELG.tdb to (cDd()+"SM3SELG.DBF") //Seleksiegroepe
         endif

         if !file(cDd()+"SM3EIEV.DBF")
            copy file SM3EIEV.tdb to (cDd()+"SM3EIEV.DBF") //Eie verslae
         endif

         if !file(cDd()+"SM3WAAR.DBF")
            copy file SM3WAAR.tdb to (cDd()+"SM3WAAR.DBF") //Waar-is-dier kodes
         endif

         if !file(cDd()+"SM3OPMK.DBF")
            copy file SM3OPMK.tdb to (cDd()+"SM3OPMK.DBF") //Opmerkings
         endif

         if !file(cDd()+"SM3REDE.DBF")
            copy file SM3REDE.tdb to (cDd()+"SM3REDE.DBF") //Afkeurredes
         endif

      endif

   end

   // Reset

return lRetu
