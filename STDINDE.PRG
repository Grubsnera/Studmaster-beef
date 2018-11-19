// Application: StudMaster for Beef Cattle
//   File Name: STDINDE.PRG
// Description: Program to create std file indexes
//   Copyright: (c) 1994 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 12-20-94      06:43:08pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION stdinde(lDone)

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr(maxrow()-1,0,maxrow(),maxcol())
   local aCdbf := fATopen()
   local lThis := .f.
   local lLoop := .t.
   local cFile := ""
   cmxAutoOpen(.f.)

    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   begin sequence

      // Screen
      fScrBood(maxrow()-1)

      // Index file index
      lThis := .f.
      if !(file("STDNTXS"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Indekslˆer indeks word geskep")
         else
            fScrWbood(maxrow(),"Index file index being created")
         endif
         ferase("STDNTXS"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDNTXS",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDNTXS->dbfname+STDNTXS->ntxname tag DBFNAME
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

      // Menu file index
      lThis := .f.
      if !(file("STDMENU"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Menulˆer indeks word geskep")
         else
            fScrWbood(maxrow(),"Menu file index being created")
         endif
         ferase("STDMENU"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDMENU",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDMENU->mennaam+left(STDMENU->menopsi,1) tag MENNAAM
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

      // Data file index
      lThis := .f.
      if !(file("STDDBFS"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Datalˆer indeks word geskep")
         else
            fScrWbood(maxrow(),"Data file index being created")
         endif
         ferase("STDDBFS"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDDBFS",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDDBFS->DBFNAME tag DBFNAME
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

      // Fields file index
      lThis := .f.
      if !(file("STDFIEL"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Veldelˆer indeks word geskep")
         else
            fScrWbood(maxrow(),"Fields file index being created")
         endif
         ferase("STDFIEL"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDFIEL",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDFIEL->DBFNAME+STDFIEL->FLDNAME tag FLDNAME
         index on STDFIEL->DBFNAME+STDFIEL->FLDORDE tag FLDORDE
         index on STDFIEL->FLDLIST tag FLDLIST
         index on STDFIEL->FLDSORT tag FLDSORT
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

      // Help file index
      lThis := .f.
      if !(file("STDHELP"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Hulplˆer indeks word geskep")
         else
            fScrWbood(maxrow(),"Help file index being created")
         endif
         ferase("STDHELP"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDHELP",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDHELP->PROG+STDHELP->VARI tag PROG
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

      // Handleiding file index
      lThis := .f.
      if !(file("STDDEXA"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Handleidinglˆer indeks word geskep")
         else
            fScrWbood(maxrow(),"Handleidinglˆer indeks word geskep")
         endif
         ferase("STDDEXA"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDDEXA",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDDEXA->KODE tag KODE
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

      // Manual file index
      lThis := .f.
      if !(file("STDDEXE"+ordbagext()))
         lThis := .t.
      endif
      if lDone .or. lThis
         if cLanType() == "A"
            fScrWbood(maxrow(),"Manual file being created")
         else
            fScrWbood(maxrow(),"Manual file being created")
         endif
         ferase("STDDEXE"+ordBagExt())
         aCdbf := fATopen(aCdbf,,"STDDEXE",,"tdb",,.f.)
         if !aCdbf[len(aCdbf),1]
            lRetu := .f.
            break
         endif
         index on STDDEXE->KODE tag KODE
         fATclose(aCdbf)
         aSize(aCdbf,len(aCdbf)-1)
      endif

   end

   // Reset
   cmxAutoOpen(.t.)
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
