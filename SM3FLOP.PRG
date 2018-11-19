//SM3FLOP.PRG
//Program om diere op disket oor te plaas
//Kopiereg (c) 1993 A van Rensburg
//08-13-93 04:59am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"
#include "fileio.ch"

//****************************************************************************/
FUNCTION sm3flop

   /*
   Ek het besluit om die skep van diskette by dieselfde opsie te doen
   as waar oordragte gedoen word. Vertoon boodskap as sulks aan
   gebruikers.
   */

   // Declare
   local nChoice := 0
   local aMess   := {}

   if cLanType() == "A"
      fScrOpsk(1, "Opsie "+cOption())
   else
      fScrOpsk(1, "Option "+cOption())
   endif

   begin sequence

      // Ask what type of data must be created
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". [Esc]=Menu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". [Esc]=Menu." )
      endif
      nChoice := fNewMenu(nChoice,"SM3FLOP1")
      cOption(nChoice)

      do case
         case nChoice == 1
            // Give message about transfers
            if cLanType() == "A"
               fScrOpsk(,"Opsie "+cOption())
               aadd(aMess,"Diskette met data van verkoopte diere wat aan die koper")
               aadd(aMess,"oorhandig kan word, word geskep deur Alt F by OORDRAGTE")
               aadd(aMess,"te druk. Hierdie disket kan slegs deur  telers  met  'n")
               aadd(aMess,"StoetMeesterprogram gebruik word. (Opsie EI)")
               stdnotc("Verkoopte diere",aMess)
            else
               fScrOpsk(,"Opstion "+cOption())
               aadd(aMess,"Diskettes for handing to the buyer, containing data of the")
               aadd(aMess,"animals purchased, are created by pressing Alt F at ")
               aadd(aMess,"TRANSFERS. These diskettes can only be used by breeders")
               aadd(aMess,"with a StudMaster program. (Option EI)")
               stdnotc("Sold animals",aMess)
            endif
            fScrBood(23)
            fScrWait(24)

         case nChoice == 2
            // Give message about spread sheets
            fScrOpsk()
            if cLanType() == "A"
               fScrOpsk(,"Opsie "+cOption())
               aadd(aMess,"Diskette met data van enige ander diere vir byvoorbeeld")
               aadd(aMess,"spreitabelle word voorberei deur Alt F te druk wanneer")
               aadd(aMess,"EIE VERSLAE op die skerm vertoon word. (Opsie EB)")
               stdnotc("Spreitabel",aMess)
            else
               fScrOpsk(,"Opstion "+cOption())
               aadd(aMess,"Diskettes with any other animal data for spread sheets")
               aadd(aMess,"for example, are prepared by pressing Alt F when the")
               aadd(aMess,"OWN REPORT screen is displayed. (Option EB)")
               stdnotc("Spreadsheet",aMess)
            endif
            fScrBood(23)
            fScrWait(24)

         case nChoice == 3
            // Move data from one set to another
            sm3move()

         case nChoice == 4
            // Prepare registration data for MultiBreed
            fRegister()

         case nChoice == 5
            // Prepare performance data for MultiBreed
            fPrepare()

         case nChoice == 6
            // Prepare owner data for MultiBreed
            fOwner()

         case nChoice == 7
            // Prepare breedplan data
            fHerdmaster()

         otherwise
            break

      endcase

   end

   // Reset
   cOption(-1)

return NIL

/******************************************************************************/
STATIC FUNCTION fRegister

   // Function to prepare diskettes with registration data for MultiBreed

   // Declare
   local aCdbf      := fATopen()
   local nWhich     := 0
   local nBoxc      := 0
   local cToRegi    := padr(o_curpath(),30)      // REGI"+trim(substr(cTotNaam(),125,4))+".DBF"
   local cToLigg    := ""
   local lLoop      := .t.
   local cSaym      := ""
   local nHandle    := 0
   local aStruct1   := {}
   local aStruct2   := {}
   local nCreated   := 0
   local cData      := ""
   local getlist    := {}
   private cTest    := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      // Ask the file name where to write to
      if cLanType() == "A"
         cSaym := "Dryfroete?"
         nBoxc := fBoxCent(6,cSaym+space(31),3,"MultiBreed registrasiedata")
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Tik die dryfroete van die datalˆer!")
      else
         cSaym := "Data drive path?"
         nBoxc := fBoxCent(6,cSaym+space(31),3,"MultiBreed registration data")
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Type the data drive path for the data file!")
      endif
      lLoop := .t.
      do while lLoop

         // Ask
         @ 7,nBoxc say cSaym get cToRegi pict "@!"
         set cursor on
         read
         set cursor off

         // Escaped
         if lastkey() == K_ESC
            break
         endif

         // Empty
         if empty(cToRegi)
            break
         endif

         // Complete path variable
         if right(trim(cToRegi),1) <> "\"
            cToRegi := padr(trim(cToRegi)+"\",30)
         endif

         // If floppies
         if left(cToRegi,2) $ "A:zB:"
            fScrBood(23,"[Esc]=Menu")
            if cLanType() == "A"
               fScrBood(24,"Sit 'n geformatteerde disket in die "+left(cToRegi,2)+" dryf en druk enige sleutel.")
            else
               fScrBood(24,"Insert a formatted diskette into the "+left(cToRegi,2)+" drive and press any key.")
            endif
            inkey(0)
            if lastkey() == K_ESC
               break
            endif
         endif

         // See if file does exist
         // If floppies
         if left(cToRegi,2) $ "A:zB:"
            if file(trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),125,4))+".DBF")
               lLoop := .f.
               loop
            endif
         else
            if file(trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),149,3))+".DBF")
               lLoop := .f.
               loop
            endif
         endif

         // Try to create the file
         if left(cToRegi,2) $ "A:zB:"
            nHandle := fcreate(trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),125,4))+".DBF")
            if nHandle == -1
               // Error creating file - display message
               fScrBood(23,fFileError())
               fScrWait(24)
               loop
            endif
            fclose(nHandle)
            ferase(trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),125,4))+".DBF")
         else
            nHandle := fcreate(trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),149,3))+".DBF")
            if nHandle == -1
               // Error creating file - display message
               fScrBood(23,fFileError())
               fScrWait(24)
               loop
            endif
            fclose(nHandle)
            ferase(trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),149,3))+".DBF")
         endif

         lLoop := .f.

      enddo
      cToLigg := cToRegi
      if left(cToRegi,2) $ "A:zB:"
         cToRegi := trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),125,4))
      else
         cToRegi := trim(cToRegi)+"REGI"+trim(substr(cTotNaam(),149,3))
      endif

      // Display menu to ask group etc.
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
      endif
      nWhich := fNewMenu(nWhich,"SM3FLOP2")
      fScrBood(23)
      fScrBood(24)
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nWhich))
      else
         fScrOpsk(1,"Option "+cOption(nWhich))
      endif

      // The choices
      do case

         case nWhich == 1
            // Index group
            cTest := sm3indg(4)
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen indeksgroep is gekies nie!")
               else
                  fScrWait(24,"No index group was selected!")
               endif
               break
            endif
            cTest := "SM3DATA->indekskode=='"+cTest+"'"

         case nWhich == 2
            // Phase group
            cTest := sm3fasg(4)
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen fasegroep is gekies nie!")
               else
                  fScrWait(24,"No phase group was selected!")
               endif
               break
            endif
            cTest := "SM3DATA->fasekode=='"+cTest+"'"

         case nWhich == 3
            // Group
            cTest := sm3groe()
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen groep is gespesifiseer nie!")
               else
                  fScrWait(24,"No group have been specified!")
               endif
               break
            endif

         case nWhich == 4
            // Selection group
            cTest := sm3selg()
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No selection group requirements have been specified!")
               endif
               break
            endif

         otherwise
            break

      endcase

      if left(cToRegi,2) $ "A:zB:" .or. ;
            !file(cToRegi+".dbf")

         // Create performance data files
         aadd(aStruct1,{"IDNOMM","C",012,000})
         aadd(aStruct1,{"GESLAG","C",001,000})
         aadd(aStruct1,{"GEBDAT","D",008,000})
         aadd(aStruct1,{"STATUS","C",001,000})
         aadd(aStruct1,{"IDVAAR","C",012,000})
         aadd(aStruct1,{"IDMOER","C",012,000})
         aadd(aStruct1,{"KEURDA","D",008,000})
         aadd(aStruct1,{"GEKEUR","C",001,000})
         aadd(aStruct1,{"DATUMU","D",008,000})
         aadd(aStruct1,{"WAARID","C",002,000})
         aadd(aStruct1,{"DEKKOD","C",001,000})
         aadd(aStruct1,{"GEBOPM","C",002,000})
         aadd(aStruct1,{"REKNOM","C",012,000})
         aadd(aStruct1,{"BLOEDT","C",010,000})
         aadd(aStruct1,{"NAAMVD","C",046,000})
         aadd(aStruct1,{"GEBMAS","N",004,001})
         aadd(aStruct1,{"TWEMET","C",001,000})
         aadd(aStruct1,{"SUBAFD","C",002,000})
         aadd(aStruct1,{"KLEURK","C",004,000})
         aadd(aStruct1,{"GEBWAA","C",002,000})
         aadd(aStruct1,{"NAGEBO","C",002,000})
         aadd(aStruct1,{"GENERA","C",002,000})
         aadd(aStruct1,{"IDENTI","C",004,000})
         aadd(aStruct1,{"INSEMD","D",008,000})
         aadd(aStruct1,{"NIEREG","C",001,000})
         aadd(aStruct1,{"MASMGE","N",003,000})
         aadd(aStruct1,{"VEELVA","C",001,000})
         aadd(aStruct1,{"LKALFD","D",008,000})
         aadd(aStruct1,{"REDGEN","C",001,000})
         aadd(aStruct1,{"TKPTKP","N",004,000})
         aadd(aStruct1,{"KALFAA","N",003,000})
         aadd(aStruct1,{"KEURDE","C",006,000})
         aadd(aStruct1,{"KALFBN","C",008,000})
         dbcreate(cToRegi+".dbf",aStruct1)

      endif

      // Open dataleers
      aCdbf := fATopen(aCdbf,,cToRegi,,,"REGI")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // The loop to create the file
      select SM3DATA
      do while !eof()

         // Skerm
         if cLanType() == "A"
            fScrBood(23,ltrim(str(nCreated))+" Diere. ("+fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi)")
            fScrWbood(24,"Registrasielˆer word geskep")
         else
            fScrBood(23,ltrim(str(nCreated))+" Animals. ("+fPercent(cmxkeyno(),cmxkeycount())+"% Completed)")
            fScrWbood(24,"Registration file being created")
         endif

         if &cTest

            nCreated++

            // Voorspeen
            select REGI
            append blank
            do while !rlock()
            enddo

            // Id number
            if sm3idfo() == "2"
               REGI->idnomm := SM3DATA->idnr
            else
               cData := fId(SM3DATA->idnr,.t.)
               REGI->idnomm := padr( ;
                  padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                  padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                  alltrim(left(cData,4)) ,12)    // Kuddekenmerk
            endif
            REGI->geslag := SM3DATA->geslag
            REGI->gebdat := SM3DATA->gebdatum
            REGI->status := SM3DATA->gebstat
            if sm3idfo() == "2"
               REGI->idvaar := SM3DATA->idvaar
            else
               cData := fId(SM3DATA->idvaar,.t.)
               REGI->idvaar := padr( ;
                  padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                  padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                  alltrim(left(cData,4)) ,12)    // Kuddekenmerk
            endif
            if sm3idfo() == "2"
               REGI->idmoer := SM3DATA->idmoer
            else
               cData := fId(SM3DATA->idmoer,.t.)
               REGI->idmoer := padr( ;
                  padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                  padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                  alltrim(left(cData,4)) ,12)    // Kuddekenmerk
            endif
            REGI->keurda := SM3DATA->keurda
            REGI->gekeur := SM3DATA->gekeur
            REGI->datumu := SM3DATA->uitkdatum
            if SM3DATA->uitkrede $ cWaarisd()
            else
               REGI->waarid := SM3DATA->uitkrede
            endif
            REGI->dekkod := SM3DATA->vaarkode
            REGI->gebopm := SM3DATA->kalfgem
            REGI->reknom := SM3DATA->reknr
            REGI->bloedt := SM3DATA->bloednr
            REGI->naamvd := SM3DATA->idnaam
            REGI->gebmas := SM3DATA->gebmassa
            REGI->twemet := SM3DATA->tweeling
            REGI->subafd := SM3DATA->subafd
            REGI->kleurk := SM3DATA->tipies
            REGI->gebwaa := SM3DATA->kalfstat
            REGI->nagebo := SM3DATA->nagebo
            REGI->genera := SM3DATA->generasie
            REGI->identi := SM3DATA->ident
            REGI->insemd := SM3DATA->idatum
            REGI->niereg := SM3DATA->niereg
            REGI->masmge := SM3DATA->mamoergeb
            if "MSIRE" $ SM3DATA->idvaar .or. "VVAAR" $ SM3DATA->idvaar
               REGI->veelva := "1"
            endif
            REGI->kalfbn := SM3DATA->kalfbnr

         endif

         // Next animal
         select SM3DATA
         skip

      enddo

      // Skerm
      fScrWait(24)

   end

   // Reset
   cOption(-1)
   fATclose(aCdbf)

return NIL

/****************************************************************************/
STATIC FUNCTION fPrepare

   // Function to prepare diskettes with performance data for MultiBreed

   // Declare
   local aCdbf      := fATopen()
   local nWhich     := 0
   local nBoxc      := 0
   local cToPres    := padr(o_curpath(),30)      // PRES"+trim(substr(cTotNaam(),125,4))+".DBF"
   local cToLigg    := ""
   local lLoop      := .t.
   local cSaym      := ""
   local nHandle    := 0
   local aStruct1   := {}
   local aStruct2   := {}
   local nCreated   := 0
   local cData      := ""
   local getlist    := {}
   private cTest    := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      // Ask the file name where to write to
      if cLanType() == "A"
         cSaym := "Dryfroete?"
         nBoxc := fBoxCent(6,cSaym+space(31),3,"MultiBreed prestasiedata")
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Tik die dryfroete van die datalˆer!")
      else
         cSaym := "Data drive path?"
         nBoxc := fBoxCent(6,cSaym+space(31),3,"MultiBreed performance data")
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Type the data drive path for the data file!")
      endif
      lLoop := .t.
      do while lLoop

         // Ask
         @ 7,nBoxc say cSaym get cToPres pict "@!@K"
         set cursor on
         read
         set cursor off

         // Escaped
         if lastkey() == K_ESC
            break
         endif

         // Empty
         if empty(cToPres)
            break
         endif

         // Complete path variable
         if right(trim(cToPres),1) <> "\"
            cToPres := padr(trim(cToPres)+"\",30)
         endif

         // If floppies
         if left(cToPres,2) $ "A:zB:"
            fScrBood(23,"[Esc]=Menu")
            if cLanType() == "A"
               fScrBood(24,"Sit 'n geformatteerde disket in die "+left(cToPres,2)+" dryf en druk enige sleutel.")
            else
               fScrBood(24,"Insert a formatted diskette into the "+left(cToPres,2)+" drive and press any key.")
            endif
            inkey(0)
            if lastkey() == K_ESC
               break
            endif
         endif

         // See if file does exist
         // If floppies
         if left(cToPres,2) $ "A:zB:"
            if file(trim(cToPres)+"PRES"+trim(substr(cTotNaam(),125,4))+".DBF")
               lLoop := .f.
               loop
            endif
         else
            if file(trim(cToPres)+"PRES"+trim(substr(cTotNaam(),149,3))+".DBF")
               lLoop := .f.
               loop
            endif
         endif

         // Try to create the file
         if left(cToPres,2) $ "A:zB:"
            nHandle := fcreate(trim(cToPres)+"PRES"+trim(substr(cTotNaam(),125,4))+".DBF")
            if nHandle == -1
               // Error creating file - display message
               fScrBood(23,fFileError())
               fScrWait(24)
               loop
            endif
            fclose(nHandle)
            ferase(trim(cToPres)+"PRES"+trim(substr(cTotNaam(),125,4))+".DBF")
         else
            nHandle := fcreate(trim(cToPres)+"PRES"+trim(substr(cTotNaam(),149,3))+".DBF")
            if nHandle == -1
               // Error creating file - display message
               fScrBood(23,fFileError())
               fScrWait(24)
               loop
            endif
            fclose(nHandle)
            ferase(trim(cToPres)+"PRES"+trim(substr(cTotNaam(),149,3))+".DBF")
         endif

         lLoop := .f.

      enddo
      cToLigg := cToPres
      if left(cToPres,2) $ "A:zB:"
         cToPres := trim(cToPres)+"PRES"+trim(substr(cTotNaam(),125,4))
         cToLigg := trim(cToLigg)+"LIGG"+trim(substr(cTotNaam(),125,4))
      else
         cToPres := trim(cToPres)+"PRES"+trim(substr(cTotNaam(),149,3))
         cToLigg := trim(cToLigg)+"LIGG"+trim(substr(cTotNaam(),149,3))
      endif

      // Display menu to ask group etc.
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
      endif
      nWhich := fNewMenu(nWhich,"SM3FLOP2")
      fScrBood(23)
      fScrBood(24)
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nWhich))
      else
         fScrOpsk(1,"Option "+cOption(nWhich))
      endif

      // The choices
      do case

         case nWhich == 1
            // Index group
            cTest := sm3indg(4)
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen indeksgroep is gekies nie!")
               else
                  fScrWait(24,"No index group was selected!")
               endif
               break
            endif
            cTest := "SM3DATA->indekskode=='"+cTest+"'"

         case nWhich == 2
            // Phase group
            cTest := sm3fasg(4)
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen fasegroep is gekies nie!")
               else
                  fScrWait(24,"No phase group was selected!")
               endif
               break
            endif
            cTest := "SM3DATA->fasekode=='"+cTest+"'"

         case nWhich == 3
            // Group
            cTest := sm3groe()
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen groep is gespesifiseer nie!")
               else
                  fScrWait(24,"No group have been specified!")
               endif
               break
            endif

         case nWhich == 4
            // Selection group
            cTest := sm3selg()
            if empty(cTest)
               if cLanType() == "A"
                  fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No selection group requirements have been specified!")
               endif
               break
            endif

         otherwise
            break

      endcase

      if left(cToPres,2) $ "A:zB:" .or. ;
            !file(cToPres+".dbf")

         // Create performance data files
         aadd(aStruct1,{"IDNOMM","C",012,000})
         aadd(aStruct1,{"INTIPE","C",003,000})
         aadd(aStruct1,{"INFASE","C",002,000})
         aadd(aStruct1,{"INMASS","N",004,000})
         aadd(aStruct1,{"INDATU","D",008,000})
         aadd(aStruct1,{"INBYVO","C",001,000})
         aadd(aStruct1,{"INKODE","C",002,000})
         aadd(aStruct1,{"INRANG","N",004,000})
         aadd(aStruct1,{"INGGRO","N",004,000})
         aadd(aStruct1,{"INGMAS","N",004,000})
         aadd(aStruct1,{"INGDOO","N",004,000})
         aadd(aStruct1,{"ININDE","N",003,000})
         aadd(aStruct1,{"INKMAG","N",004,000})
         aadd(aStruct1,{"INKMAI","N",004,000})
         aadd(aStruct1,{"INKBYV","C",001,000})
         aadd(aStruct1,{"INKKLI","N",003,000})
         aadd(aStruct1,{"INGDTT","N",004,000})
         aadd(aStruct1,{"INGDTI","N",003,000})
         aadd(aStruct1,{"INAAND","D",008,000})
         aadd(aStruct1,{"INAANM","N",004,000})
         aadd(aStruct1,{"INBEGD","D",008,000})
         aadd(aStruct1,{"INBEGM","N",004,000})
         aadd(aStruct1,{"INFCRA","N",008,003})
         aadd(aStruct1,{"INFCIN","N",003,000})
         dbcreate(cToPres+".dbf",aStruct1)

      endif

      if left(cToPres,2) $ "A:zB:" .or. ;
            !file(cToLigg+".dbf")

         // Create body measurements file
         aadd(aStruct2,{"IDNOMM","C",012,000})
         aadd(aStruct2,{"LITIPE","C",003,000})
         aadd(aStruct2,{"LIDATU","D",008,000})
         aadd(aStruct2,{"LIHOOB","N",004,000})
         aadd(aStruct2,{"LIHOOE","N",004,000})
         aadd(aStruct2,{"LIHOOG","N",004,000})
         aadd(aStruct2,{"LIHOOT","C",001,000})
         aadd(aStruct2,{"LILENB","N",004,000})
         aadd(aStruct2,{"LILENE","N",004,000})
         aadd(aStruct2,{"LILENG","N",004,000})
         aadd(aStruct2,{"LILENT","C",001,000})
         aadd(aStruct2,{"LISKRB","N",004,000})
         aadd(aStruct2,{"LISKRE","N",004,000})
         aadd(aStruct2,{"LISKRG","N",004,000})
         aadd(aStruct2,{"LIVELD","N",002,000})
         aadd(aStruct2,{"LIBOSL","N",004,000})
         aadd(aStruct2,{"LIBOSI","N",003,000})
         dbcreate(cToLigg+".dbf",aStruct2)

      endif

      // Open dataleers
      aCdbf := fATopen(aCdbf,,cToLigg,,,"LIGG")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,,cToPres,,,"PRES")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // The loop to create the file
      select SM3DATA
      do while !eof()

         // Skerm
         if cLanType() == "A"
            fScrBood(23,ltrim(str(nCreated))+" Diere. ("+fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi)")
            fScrWbood(24,"Prestasierekords word geskep")
         else
            fScrBood(23,ltrim(str(nCreated))+" Animals. ("+fPercent(cmxkeyno(),cmxkeycount())+"% Completed)")
            fScrWbood(24,"Performance record being created")
         endif

         if &cTest

            nCreated++

            // Voorspeen
            if !empty(SM3DATA->dat100) .and. !empty(SM3DATA->mas100)
               select PRES
               append blank
               do while !rlock()
               enddo

               // Id number
               if sm3idfo() == "1"
                  cData := fId(SM3DATA->idnr,.t.)
                  PRES->idnomm := padr( ;
                     padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                     padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                     alltrim(left(cData,4)) ,12) // Kuddekenmerk
               else
                  PRES->idnomm := SM3DATA->idnr
               endif
               PRES->intipe := "A1 "
               PRES->infase := "A1"
               PRES->inmass := SM3DATA->mas100
               PRES->indatu := SM3DATA->dat100
               PRES->inkode := SM3DATA->kod100
               PRES->inrang := SM3DATA->ple100
               PRES->inggro := SM3DATA->aan100
               PRES->ingmas := SM3DATA->gma100
               PRES->ingdoo := SM3DATA->gdo100
               PRES->ininde := SM3DATA->ind100
            endif

            // Speen
            if !empty(SM3DATA->dat205) .and. !empty(SM3DATA->mas205)
               select PRES
               append blank
               do while !rlock()
               enddo
               if sm3idfo() == "1"
                  cData := fId(SM3DATA->idnr,.t.)
                  PRES->idnomm := padr( ;
                     padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                     padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                     alltrim(left(cData,4)) ,12) // Kuddekenmerk
               else
                  PRES->idnomm := SM3DATA->idnr
               endif
               PRES->intipe := "A2 "
               PRES->infase := "A2"
               PRES->inmass := SM3DATA->mas205
               PRES->indatu := SM3DATA->dat205
               PRES->inkode := SM3DATA->kod205
               PRES->inrang := SM3DATA->ple205
               PRES->inggro := SM3DATA->aan205
               PRES->ingmas := SM3DATA->gma205
               PRES->ingdoo := SM3DATA->gdo205
               PRES->ininde := SM3DATA->ind205
               PRES->inkmag := SM3DATA->mamoergeb
               PRES->inkmai := SM3DATA->mamoerspe
               PRES->inkkli := SM3DATA->mpresind
            endif

            // Jaar
            if !empty(SM3DATA->dat365) .and. !empty(SM3DATA->mas365)
               select PRES
               append blank
               do while !rlock()
               enddo
               if sm3idfo() == "1"
                  cData := fId(SM3DATA->idnr,.t.)
                  PRES->idnomm := padr( ;
                     padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                     padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                     alltrim(left(cData,4)) ,12) // Kuddekenmerk
               else
                  PRES->idnomm := SM3DATA->idnr
               endif
               PRES->intipe := "B1 "
               PRES->infase := "B1"
               PRES->inmass := SM3DATA->mas365
               PRES->indatu := SM3DATA->dat365
               PRES->inkode := SM3DATA->kod365
               PRES->inrang := SM3DATA->ple365
               PRES->inggro := SM3DATA->aan365
               PRES->ingmas := SM3DATA->gma365
               PRES->ingdoo := SM3DATA->gdo365
               PRES->ininde := SM3DATA->ind365
            endif

            // 18 maande
            if !empty(SM3DATA->dat540) .and. !empty(SM3DATA->mas540)
               select PRES
               append blank
               do while !rlock()
               enddo
               if sm3idfo() == "1"
                  cData := fId(SM3DATA->idnr,.t.)
                  PRES->idnomm := padr( ;
                     padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                     padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                     alltrim(left(cData,4)) ,12) // Kuddekenmerk
               else
                  PRES->idnomm := SM3DATA->idnr
               endif
               PRES->intipe := "B2 "
               PRES->infase := "B2"
               PRES->inmass := SM3DATA->mas540
               PRES->indatu := SM3DATA->dat540
               PRES->inkode := SM3DATA->kod540
               PRES->inrang := SM3DATA->ple540
               PRES->inggro := SM3DATA->aan540
               PRES->ingmas := SM3DATA->gma540
               PRES->ingdoo := SM3DATA->gdo540
               PRES->ininde := SM3DATA->ind540
            endif

            // Fase C & D
            if !empty(SM3DATA->fasekode) .and. ;
                  !empty(SM3DATA->einmas) .and. !empty(SM3DATA->eindat) .and. ;
                  !empty(SM3DATA->begmassa) .and. !empty(SM3DATA->begdatum)

               select PRES
               append blank
               do while !rlock()
               enddo
               if sm3idfo() == "1"
                  cData := fId(SM3DATA->idnr,.t.)
                  PRES->idnomm := padr( ;
                     padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                     padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                     alltrim(left(cData,4)) ,12) // Kuddekenmerk
               else
                  PRES->idnomm := SM3DATA->idnr
               endif
               if "C" $ SM3DATA->fasekode
                  PRES->intipe := "CD "
                  if substr(SM3DATA->fasekode,2,1) $ "123456"
                     PRES->infase := "C"+substr(SM3DATA->fasekode,2,1)
                  else
                     PRES->infase := "C "
                  endif
               else
                  PRES->intipe := "CD "
                  if substr(SM3DATA->fasekode,2,1) $ "123456"
                     PRES->infase := "D"+substr(SM3DATA->fasekode,2,1)
                  else
                     PRES->infase := "D "
                  endif
               endif
               PRES->inmass := SM3DATA->einmas
               PRES->indatu := SM3DATA->eindat
               PRES->inrang := SM3DATA->rangor
               PRES->inggro := SM3DATA->tydgen
               PRES->ingmas := SM3DATA->einmas
               PRES->ingdoo := SM3DATA->gdogdo
               PRES->ininde := SM3DATA->gdoind
               PRES->ingdtt := SM3DATA->gdtgdt
               PRES->ingdti := SM3DATA->gdtind
               PRES->inaand := SM3DATA->aandat
               PRES->inaanm := SM3DATA->aanmas
               PRES->inbegd := SM3DATA->begdatum
               PRES->inbegm := SM3DATA->begmassa

               if "D" $ PRES->infase
                  PRES->infcra := SM3DATA->kleiber
                  PRES->infcin := SM3DATA->kleiberi
               else
                  PRES->infcra := SM3DATA->voeromset
                  PRES->infcin := SM3DATA->voeromseti
               endif

               // Liggaamsmates
               select LIGG
               append blank
               do while !rlock()
               enddo
               if sm3idfo() == "1"
                  cData := fId(SM3DATA->idnr,.t.)
                  LIGG->idnomm := padr( ;
                     padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                     padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                     alltrim(left(cData,4)) ,12) // Kuddekenmerk
               else
                  LIGG->idnomm := SM3DATA->idnr
               endif
               if "C" $ SM3DATA->fasekode
                  if substr(SM3DATA->fasekode,2,1) $ "123456"
                     LIGG->litipe := "C"+substr(SM3DATA->fasekode,2,1)+" "
                  else
                     LIGG->litipe := "C  "
                  endif
               else
                  if substr(SM3DATA->fasekode,2,1) $ "123456"
                     LIGG->litipe := "D"+substr(SM3DATA->fasekode,2,1)+" "
                  else
                     LIGG->litipe := "D  "
                  endif
               endif
               LIGG->lidatu := SM3DATA->eindat
               LIGG->lihoob := SM3DATA->mateskouer
               LIGG->lihooe := SM3DATA->mateskouer
               LIGG->lihoog := SM3DATA->gekhoo
               LIGG->lihoot := ""                // Tipe
               LIGG->lilenb := SM3DATA->matelengte
               LIGG->lilene := SM3DATA->matelengte
               LIGG->lileng := SM3DATA->geklen
               LIGG->lilent := ""                // Tipe
               LIGG->liskrb := SM3DATA->mateskrot
               LIGG->liskre := SM3DATA->mateskrot
               LIGG->liskrg := SM3DATA->gekskr
               LIGG->liveld := SM3DATA->veldikte
               LIGG->libosl := 0
               LIGG->libosi := 0

            endif

         endif

         // Next animal
         select SM3DATA
         skip

      enddo

      // Skerm
      fScrWait(24)

   end

   // Reset
   cOption(-1)
   fATclose(aCdbf)

return NIL

/******************************************************************************/
STATIC FUNCTION fOwner

   // Function to prepare diskettes with owner data for MultiBreed

   // Declare
   local aCdbf      := fATopen()
   local nWhich     := 0
   local nBoxc      := 0
   local cToRegi    := padr(o_curpath(),30)      // OWNE"+trim(substr(cTotNaam(),125,4))+".DBF"
   local cToLigg    := ""
   local lLoop      := .t.
   local cSaym      := ""
   local nHandle    := 0
   local aStruct1   := {}
   local aStruct2   := {}
   local nCreated   := 0
   local cData      := ""
   local getlist    := {}
   local cToOwne := space(6)
   local cSayo := ""
   local cWaar := ""
   private cTest    := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      // Ask the file name where to write to
      if cLanType() == "A"
         cSaym := "Dryfroete?"
         cSayo := "MultiBreed lidnommer?"
         nBoxc := fBoxCent(6,cSayo+space(31),4,"MultiBreed eienaardata")
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Tik die dryfroete van die datalˆer!")
      else
         cSaym := "Data drive path?"
         cSayo := "MultiBreed member number?"
         nBoxc := fBoxCent(6,cSayo+space(31),4,"MultiBreed owner data")
         fScrBood(23,"[Esc]=Menu")
         fScrBood(24,"Type the data drive path for the data file!")
      endif
      lLoop := .t.
      do while lLoop

         // Ask
         @ 7,nBoxc say cSaym get cToRegi pict "@!@K"
         @ 8,nBoxc say cSayo get cToOwne pict "@!@K"
         set cursor on
         read
         set cursor off

         // Escaped
         if lastkey() == K_ESC
            break
         endif

         // Empty
         if empty(cToRegi)
            break
         endif

         // Complete path variable
         if right(trim(cToRegi),1) <> "\"
            cToRegi := padr(trim(cToRegi)+"\",30)
         endif

         // If floppies
         if left(cToRegi,2) $ "A:zB:"
            fScrBood(23,"[Esc]=Menu")
            if cLanType() == "A"
               fScrBood(24,"Sit 'n geformatteerde disket in die "+left(cToRegi,2)+" dryf en druk enige sleutel.")
            else
               fScrBood(24,"Insert a formatted diskette into the "+left(cToRegi,2)+" drive and press any key.")
            endif
            inkey(0)
            if lastkey() == K_ESC
               break
            endif
         endif

         // See if file does exist
         // If floppies
         if left(cToRegi,2) $ "A:zB:"
            if file(trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),125,4))+".DBF")
               lLoop := .f.
               loop
            endif
         else
            if file(trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),149,3))+".DBF")
               lLoop := .f.
               loop
            endif
         endif

         // Try to create the file
         if left(cToRegi,2) $ "A:zB:"
            nHandle := fcreate(trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),125,4))+".DBF")
            if nHandle == -1
               // Error creating file - display message
               fScrBood(23,fFileError())
               fScrWait(24)
               loop
            endif
            fclose(nHandle)
            ferase(trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),125,4))+".DBF")
         else
            nHandle := fcreate(trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),149,3))+".DBF")
            if nHandle == -1
               // Error creating file - display message
               fScrBood(23,fFileError())
               fScrWait(24)
               loop
            endif
            fclose(nHandle)
            ferase(trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),149,3))+".DBF")
         endif

         lLoop := .f.

      enddo
      cToLigg := cToRegi
      if left(cToRegi,2) $ "A:zB:"
         cToRegi := trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),125,4))
      else
         cToRegi := trim(cToRegi)+"OWNE"+trim(substr(cTotNaam(),149,3))
      endif

      if left(cToRegi,2) $ "A:zB:" .or. ;
            !file(cToRegi+".dbf")

         // Create performance data files
         aadd(aStruct1,{"LEKODE","C",006,000})
         aadd(aStruct1,{"IDNOMM","C",012,000})
         dbcreate(cToRegi+".dbf",aStruct1)

      endif

      // Open dataleers
      aCdbf := fATopen(aCdbf,,cToRegi,,,"OWNE")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      cWaar := STDWAAR->velded
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      cTest := "SM3DATA->uitkrede & '" + cWaar + "'"

      // The loop to create the file
      select SM3DATA
      do while !eof()

         // Skerm
         if cLanType() == "A"
            fScrBood(23,ltrim(str(nCreated))+" Diere. ("+fPercent(cmxkeyno(),cmxkeycount())+"% Voltooi)")
            fScrWbood(24,"Eienaarlˆer word geskep")
         else
            fScrBood(23,ltrim(str(nCreated))+" Animals. ("+fPercent(cmxkeyno(),cmxkeycount())+"% Completed)")
            fScrWbood(24,"Owner file being created")
         endif

         if SM3DATA->uitkrede $ cWaar

            nCreated++

            // Owner
            select OWNE
            append blank
            do while !rlock()
            enddo

            // Id number
            if sm3idfo() == "2"
               OWNE->idnomm := SM3DATA->idnr
            else
               cData := fId(SM3DATA->idnr,.t.)
               OWNE->idnomm := padr( ;
                  padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
                  padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
                  alltrim(left(cData,4)) ,12)    // Kuddekenmerk
            endif
            OWNE->lekode := cToOwne

         endif

         // Next animal
         select SM3DATA
         skip

      enddo

      // Skerm
      fScrWait(24)

   end

   // Reset
   cOption(-1)
   fATclose(aCdbf)

return NIL

/******************************************************************************/
STATIC FUNCTION fHerdmaster

   // Program to create file for herdmaster
   // 11-12-02 08:08am

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local nRout := 1
   local cDriv := ""
   local cFile := ""
   local nHdel := 0
   local cStra := ""
   local cStrb := ""
   local cData := ""
   local i     := 0
   local nLen  := 0
   local cIcar := ""
   local cBrec := ""
   local cDreg := ""
   local nBoxc := 0
   local cPref := ""
   local cName := ""
   local lSkip := .f.
   local cWaar := ""

   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")
      cBrec := alltrim(fRasNaam(substr(cTotNaam(),149,3),"BREEDS"))

      cFile := cMailTar()+"saltbush.csv"

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic transfer file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Herdmaster lˆer word voorberei")
      else
         fScrWbood(maxrow(),"Herdmaster file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Herdmaster lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create Herdmaster file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Herdmaster lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create the Herdmaster file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Open the main file
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      cWaar := STDWAAR->velded
      aCdbf := fATopen(aCdbf,cDd(),"SM3DEKK")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Start writing the animal data to the file

      // Write the data
      select SM3DATA
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Always Animal 1
         cStra := "Animal,"

         // Link Number 2
         cStra += ","

         // Guid 3
         cStra += ","

         // Open 4
         cStra += ","

         // Open 5
         cStra += ","

         // Animal tag 6
         cStra += alltrim(SM3DATA->idnr)+","

         // Sex 7
         if SM3DATA->geslag $ "1FVKHC"
            cStra += "F,"
         elseif SM3DATA->geslag == "3"
            cStra += "C,"
         else
            cStra += "M,"
         endif

         // Electronic ID 8
         cStra += alltrim(SM3DATA->michip)+","

         // Society ID 9
         cStra += alltrim(SM3DATA->idsoc)+","

         // National ID 10
         cStra += ","

         // Alternative ID 11
         cStra += ","

         // Birthdate 12
         cStra += dtod(SM3DATA->gebdatum)+","

         // Tail tag 13
         cStra += ","

         // Active date 14
         cStra += ","

         // AI permit 15
         cStra += ","

         // Birth date estimate 16
         cStra += ","

         // Birth weight 17
         cStra += alltrim(str(SM3DATA->gebmassa))+","

         // Birth year 18
         cStra += left(dtos(SM3DATA->gebdatum),4)+","

         // Origin 19
         cStra += ","

         // Breed code 20
         cStra += ","

         // Breeding 21
         cStra += ","

         // Fate 22
         // "  "=Alive
         // Use normal reason left herd
         if SM3DATA->uitkrede $ cWaar
            cStra += ","
         elseif empty(SM3DATA->uitkrede)
            cStra += "EM,"
         else
            cStra += alltrim(SM3DATA->uitkrede)+","
         endif

         // Fate date 23
         if SM3DATA->uitkrede $ cWaar
            cStra += ","
         else
            cStra += dtod(SM3DATA->uitkdatum)+","
         endif

         // Colour code 24
         cStra += alltrim(SM3DATA->tipies)+","

         // Date puchased 25
         cStra += ","

         // Purchased by 26
         cStra += ","

         // Breed society registration status 27
         cStra += alltrim(SM3DATA->gekeur)+","

         // Breed society registration status date 28
         cStra += dtod(SM3DATA->keurda)+","

         // Conceived by AI 29
         if SM3DATA->vaarkode == "3"
            cStra += "Y,"
         else
            cStra += ","
         endif

         // Conceived by ET 30
         if SM3DATA->vaarkode == "4"
            cStra += "Y,"
         else
            cStra += ","
         endif

         // De-sex date 31
         cStra += ","

         // Classification 32
         cStra += ","

         // Dam 33
         cStra += alltrim(SM3DATA->idmoer)+","

         // Sire 34
         cStra += alltrim(SM3DATA->idvaar)+","

         // Default Breedplan Performance group 35
         cStra += ","

         // Foster dam tag 36
         cStra += ","

         // Grade 37
         cStra += ","

         // Group code 1 38
         cStra += ","

         // Group code 2 39
         cStra += ","

         // Horn status 40
         cStra += ","

         // Current location 41
         if SM3DATA->uitkrede $ cWaar
            cStra += alltrim(SM3DATA->uitkrede)+","
         else
            cStra += ","
         endif

         // Weaning date 42
         cStra += dtod(SM3DATA->dat205)+","

         // Weaning weight 43
         cStra += alltrim(str(SM3DATA->mas205))+","

         // BRD % 44
         cStra += ","

         // Prefix and name 45 46
         if empty(alltrim(SM3DATA->idnaam))

            // Prefix and name is empty - blanks please

            // Prefix 45
            if empty(substr(cTotNaam(),129,20))
               cStra += ","
            else
               cStra +=  alltrim(substr(cTotNaam(),129,20))+","
            endif

            // Name 46
            cStra += ","

         else

            // Name not empty
            if at(alltrim(substr(cTotNaam(),129,20)),alltrim(SM3DATA->idnaam)) > 0

               // Prefix is in name

               // Prefix 45
               cStra +=  alltrim(substr(cTotNaam(),129,20))+","

               // Name 46
               cStra += alltrim(strtran(SM3DATA->idnaam,alltrim(substr(cTotNaam(),129,20))))+","

            else

               // Prefix not the same and not in name

               // Loop the name and build variables
               cPref := ""
               cName := ""
               lSkip := .f.
               for i := 1 to len(SM3DATA->idnaam)
                  cData := substr(SM3DATA->idnaam,i,1)
                  if cData == " "
                     lSkip := .t.
                  endif
                  if lSkip == .f.
                     // Prefix
                     cPref += cData
                  else
                     // Name
                     cName += cData
                  endif
               next
               cPref := alltrim(cPref)
               cName := alltrim(cName)

               // Prefix 45
               cStra +=  cPref+","

               // Name 46
               cStra +=  cName+","

            endif

         endif

         // Herd code 47
         cStra += ","

         // User definable 1 48
         cStra += alltrim(SM3DATA->divers)+","

         // User definable 2 49
         cStra += alltrim(SM3DATA->divert)+","

         // User definable 3 50
         cStra += ","

         // User definable 4 51
         cStra += ","

         // User definable 5 52
         cStra += ","

         // User definable 6 53
         cStra += ","

         // User definable 7 54
         cStra += ","

         // User definable 8 55
         cStra += ","

         // User definable 9 56
         cStra += ","

         // Sale declaration number 57
         cStra += ","

         // First lacation recorded 58
         cStra += ","

         // Number of animals 59
         cStra += ","

         // Default ID 60
         cStra += ","

         // Property ID 61
         cStra += ","

         // Breed options 62
         cStra += ","

         // Prewean performance group 63
         cStra += ","

         // Note 64
         cStra += ","

         // Purchase agent 65
         cStra += ","

         // Purchase price 66
         cStra += ","

         // Vendor dec supplied 67
         cStra += ","

         // Date sold 68
         cStra += ","

         // Sold to 69
         cStra += ","

         // Sales agent 70
         cStra += ","

         // Sales price 71
         cStra += ","

         // Transporter 72
         cStra += ","

         // Vehicle registration number 73
         cStra += ","

         // Quarantine date 74
         cStra += ","

         // Old id 75
         cStra += ","

         // Extra id 76
         cStra += ","

         // Tagged HGP free 77
         cStra += ","

         // Generation 78
         cStra += alltrim(SM3DATA->generasie)+","

         // Bloodtyping number 79
         cStra += alltrim(SM3DATA->bloednr)+","

         // Empty 80
         cStra += ","

         // Temporary mark 81
         cStra += alltrim(SM3DATA->toggle1)+","

         // Empty 82
         cStra += ","

         // Empty 83
         cStra += ","

         // Empty 84
         cStra += ","

         // Empty 85
         cStra += ","

         // Empty 86
         cStra += ","

         // Empty 87
         cStra += ","

         // Empty 88
         cStra += ","

         // Empty 89
         cStra += ","

         // Empty 90
         cStra += ","

         // Empty 91
         cStra += ","

         // Recipient id number 92
         cStra += alltrim(SM3DATA->draer)+","

         // Number in birth 93
         cStra += alltrim(SM3DATA->gebstat)+","

         // AI date 94
         cStra += dtod(SM3DATA->idatum)+","

         // Empty 95
         cStra += ","

         // Calving ease 96
         cStra += alltrim(SM3DATA->kalfgem)+","

         // Empty 97
         cStra += ","

         // Dam weight at calving 98
         cStra += alltrim(str(SM3DATA->mamoergeb))+","

         // Dam weight at weaning 99
         cStra += alltrim(str(SM3DATA->mamoerspe))+","

         // Identification method 100
         cStra += alltrim(SM3DATA->ident)+","

         // Subdivision of herd book 101
         cStra += alltrim(SM3DATA->subafd)+","

         // Empty 102
         cStra += ","

         // After birth remark 103
         cStra += alltrim(SM3DATA->nagebo)+","

         // Not for registration 104
         cStra += alltrim(SM3DATA->niereg)+","

         // Eye pigmentation left 105
         cStra += left(SM3DATA->eyepig,1)+","

         // Remarks 1 106
         cStra += alltrim(SM3DATA->opmerking1)+","

         // Remarks 2 107
         cStra += alltrim(SM3DATA->opmerking2)+","

         // Empty 108
         cStra += ","

         // Rejection reasons 109
         cStra += SM3DATA->redeui+","

         // Empty 110
         cStra += ","

         // Empty 111
         cStra += ","

         // Empty 112
         cStra += ","

         // Empty 113
         cStra += ","

         // Empty 114
         cStra += ","

         // Empty 115
         cStra += ","

         // Twin with 116
         if SM3DATA->tweeling $ "1FVKHC"
            cStra += "F,"
         elseif SM3DATA->tweeling $ "23MOS"
            cStra += "M,"
         else
            cStra += ","
         endif

         // Not for registration 117
         cStra += alltrim(SM3DATA->type)+","

         // Service code 118
         cStra += alltrim(SM3DATA->vaarkode)+","

         // Empty 119
         cStra += ","

         // Empty 120
         cStra += ","

         // Empty 121
         cStra += ","

         // Breeders identifier 122
         cStra += ","

         // Tattoo 123
         cStra += ","

         // Join/Emb# 124
         cStra += ","

         // Owner 125
         cStra += ","

         // Reared on dam 126
         cStra += ","

         // Calving season 127
         cStra += ","

         // Eye pigmentation right 128
         cStra += right(SM3DATA->eyepig,1)+","

         // Nurse code 129
         cStra += ","

         // Other breed codes 130
         cStra += ","

         // Left ear tattoo 131
         cStra += ","

         // Right ear tattoo 132
         cStra += ","

         // Breed percentage 133
         cStra += ","

         // Red carrier 134
         cStra += ","

         // Foreign registration number 135
         cStra += alltrim(SM3DATA->reknr)+","

         // ASA Breeder Id 136
         cStra += ","

         // Quarantine date 137
         cStra += ","

         // Farm code 138
         cStra += ","

         // Comment 139
         cStra += ","

         // Vendor tag 140
         cStra += ","

         // Calving status 141
         cStra += alltrim(SM3DATA->kalfstat)

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3DATA
         skip

      enddo

      // Start writing the weight data to the file

      // Write the data
      select SM3DATA
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Completed"      )
         endif

         // The actual write of birth weight
         if SM3DATA->gebmassa > 0 .and. !(empty(SM3DATA->gebdatum))
            // Always Animal 1
            cStra := "AnimalPerformance,"
            // Five blanks
            cStra += ",,,,"
            // Animal tag 6
            cStra += alltrim(SM3DATA->idnr)+","
            // Trait code 7
            cStra += "Liveweight,"
            // Observation code 8
            cStra += "B,"
            // Date 9
            cStra += dtod(SM3DATA->gebdatum)+","
            // Value 10
            cStra += alltrim(str(SM3DATA->gebmassa))+","
            // Performance group 11
            cStra += ","
            // Blanks 12-14
            cStra += ",,"
            cStra += chr(13) + chr(10)
            nLen := fwrite(nHdel,cStra)
            if nLen != len(cStra)
               fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
               break
            endif
         endif

         // The actual write of 100 day weight
         if SM3DATA->mas100 > 0 .and. !(empty(SM3DATA->dat100))
            // Always Animal 1
            cStra := "AnimalPerformance,"
            // Five blanks
            cStra += ",,,,"
            // Animal tag 6
            cStra += alltrim(SM3DATA->idnr)+","
            // Trait code 7
            cStra += "Liveweight,"
            // Observation code 8
            cStra += "W1,"
            // Date 9
            cStra += dtod(SM3DATA->dat100)+","
            // Value 10
            cStra += alltrim(str(SM3DATA->mas100))+","
            // Performance group 11
            cStra += alltrim(SM3DATA->indekskode)+alltrim(SM3DATA->kod100)+","
            // Blanks 12-14
            cStra += ",,"
            cStra += chr(13) + chr(10)
            nLen := fwrite(nHdel,cStra)
            if nLen != len(cStra)
               fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
               break
            endif
         endif

         // The actual write of 205 day weight
         if SM3DATA->mas205 > 0 .and. !(empty(SM3DATA->dat205))
            // Always Animal 1
            cStra := "AnimalPerformance,"
            // Five blanks
            cStra += ",,,,"
            // Animal tag 6
            cStra += alltrim(SM3DATA->idnr)+","
            // Trait code 7
            cStra += "Liveweight,"
            // Observation code 8
            cStra += "W2,"
            // Date 9
            cStra += dtod(SM3DATA->dat205)+","
            // Value 10
            cStra += alltrim(str(SM3DATA->mas205))+","
            // Performance group 11
            cStra += alltrim(SM3DATA->indekskode)+alltrim(SM3DATA->kod205)+","
            // Blanks 12-14
            cStra += ",,"
            cStra += chr(13) + chr(10)
            nLen := fwrite(nHdel,cStra)
            if nLen != len(cStra)
               fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
               break
            endif
         endif

         // The actual write of 365 day weight
         if SM3DATA->mas365 > 0 .and. !(empty(SM3DATA->dat365))
            // Always Animal 1
            cStra := "AnimalPerformance,"
            // Five blanks
            cStra += ",,,,"
            // Animal tag 6
            cStra += alltrim(SM3DATA->idnr)+","
            // Trait code 7
            cStra += "Liveweight,"
            // Observation code 8
            cStra += "W4,"
            // Date 9
            cStra += dtod(SM3DATA->dat365)+","
            // Value 10
            cStra += alltrim(str(SM3DATA->mas365))+","
            // Performance group 11
            cStra += alltrim(SM3DATA->indekskode)+alltrim(SM3DATA->kod365)+","
            // Blanks 12-14
            cStra += ",,"
            cStra += chr(13) + chr(10)
            nLen := fwrite(nHdel,cStra)
            if nLen != len(cStra)
               fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
               break
            endif
         endif

         // The actual write of 540 day weight
         if SM3DATA->mas540 > 0 .and. !(empty(SM3DATA->dat540))
            // Always Animal 1
            cStra := "AnimalPerformance,"
            // Five blanks
            cStra += ",,,,"
            // Animal tag 6
            cStra += alltrim(SM3DATA->idnr)+","
            // Trait code 7
            cStra += "Liveweight,"
            // Observation code 8
            cStra += "W6,"
            // Date 9
            cStra += dtod(SM3DATA->dat540)+","
            // Value 10
            cStra += alltrim(str(SM3DATA->mas540))+","
            // Performance group 11
            cStra += alltrim(SM3DATA->indekskode)+alltrim(SM3DATA->kod540)+","
            // Blanks 12-14
            cStra += ",,"
            cStra += chr(13) + chr(10)
            nLen := fwrite(nHdel,cStra)
            if nLen != len(cStra)
               fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
               break
            endif
         endif

         // Export feedlot data
         if !(empty(SM3DATA->fasekode))

            // The actual write of arrival weight
            if SM3DATA->aanmas > 0 .and. !(empty(SM3DATA->aandat))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "Liveweight,"
               // Observation code 8
               cStra += "FLARR,"
               // Date 9
               cStra += dtod(SM3DATA->aandat)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->aanmas))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

            // The actual write of starting weight
            if SM3DATA->begmassa > 0 .and. !(empty(SM3DATA->begdatum))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "Liveweight,"
               // Observation code 8
               cStra += "FLSTR,"
               // Date 9
               cStra += dtod(SM3DATA->begdatum)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->begmassa))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

            // The actual write of departure weight
            if SM3DATA->einmas > 0 .and. !(empty(SM3DATA->eindat))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "Liveweight,"
               // Observation code 8
               cStra += "FLDEP,"
               // Date 9
               cStra += dtod(SM3DATA->eindat)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->einmas))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

            // The actual write of length
            if SM3DATA->matelengte > 0 .and. !(empty(SM3DATA->eindat))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "LNG,"
               // Observation code 8
               cStra += "FLDEP,"
               // Date 9
               cStra += dtod(SM3DATA->eindat)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->matelengte))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

            // The actual write of height
            if SM3DATA->mateskouer > 0 .and. !(empty(SM3DATA->eindat))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "HH,"
               // Observation code 8
               cStra += "FLDEP,"
               // Date 9
               cStra += dtod(SM3DATA->eindat)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->mateskouer))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

            // The actual write of scrotum circumference
            if SM3DATA->mateskrot > 0 .and. !(empty(SM3DATA->eindat))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "SS,"
               // Observation code 8
               cStra += "FLDEP,"
               // Date 9
               cStra += dtod(SM3DATA->eindat)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->mateskrot))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

            // The actual write of skin thickness
            if SM3DATA->veldikte > 0 .and. !(empty(SM3DATA->eindat))
               // Always Animal 1
               cStra := "AnimalPerformance,"
               // Five blanks
               cStra += ",,,,"
               // Animal tag 6
               cStra += alltrim(SM3DATA->idnr)+","
               // Trait code 7
               cStra += "SKTHK,"
               // Observation code 8
               cStra += "FLDEP,"
               // Date 9
               cStra += dtod(SM3DATA->eindat)+","
               // Value 10
               cStra += alltrim(str(SM3DATA->veldikte))+","
               // Performance group 11
               cStra += alltrim(SM3DATA->fasekode)+","
               // Blanks 12-14
               cStra += ",,"
               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)
               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif
            endif

         endif

         // Next record
         select SM3DATA
         skip

      enddo

      // Start writing the mating data to the file

      // Write the data
      select SM3DEKK
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Always Animal 1
         cStra := "Mating,"

         // Link Number 2
         cStra += ",,,,,,"

         // Dam 8
         cStra += alltrim(SM3DEKK->idmoer)+","

         // Sire 9
         cStra += alltrim(SM3DEKK->idvaar)+","

         // Date in 10
         cStra += dtod(SM3DEKK->datumin)+","

         // Mating status 11
         if SM3DATA->vaarkode == "3"
            cStra += "A,"
         elseif SM3DATA->vaarkode == "4"
            cStra += "R,"
         else
            cStra += "N,"
         endif

         // Unique farrowing number 12
         cStra += ","

         // Birth date 13
         cStra += ","

         // Number born 14
         cStra += alltrim(str(SM3DEKK->kalwer))+","

         // Number still born 15
         cStra += ","

         // Number mummified 16
         cStra += ","

         // Assigned litter number 17
         cStra += ","

         // Calf number 18
         cStra += alltrim(SM3DEKK->idnr)+","

         // Litter birthweight 19
         cStra += ","

         // Number fostered on 20
         cStra += ","

         // Foster reason 21
         cStra += ","

         // Unique weaning key 22
         cStra += ","

         // Weaning date 23
         cStra += ","

         // Number weaned 24
         cStra += alltrim(str(SM3DEKK->speenn))+","

         // Weaning weight 25
         cStra += ","

         // Mating date out 26
         cStra += dtod(SM3DEKK->datumuit)+","

         // Donor dam 27
         cStra += alltrim(SM3DEKK->donor)+","

         // Sire certificate 28
         cStra += ","

         // Performance group 29
         cStra += ","

         // Mating outcome code 30
         cStra += ","

         // Calving ease 31
         cStra += ","

         // Birth comment 32
         cStra += ","

         // Ai program code 33
         cStra += ","

         // Drugs 34
         cStra += ","

         // Vet exam 35
         cStra += ","

         // Correction code 36
         cStra += ","

         // Mating season code 37
         cStra += alltrim(SM3DEKK->teelgroep)+","

         // Pregnancy status 38
         if SM3DEKK->dragtig $ "JY*123456789"
            cStra += "Y,"
         elseif SM3DEKK->dragtig $ "N0"
            cStra += "N,"
         else
            cStra += ","
         endif

         // Inseminator 39
         cStra += alltrim(SM3DEKK->insem)+","

         // Remark at mating 40
         cStra += alltrim(SM3DEKK->opmerk)+","

         // Weeks pregnant 41
         cStra += alltrim(str(SM3DEKK->dragwe))+","

         // Weeks pregnant 42
         cStra += dtod(SM3DEKK->dragda)+","

         // Post mating remark 43
         cStra += alltrim(SM3DEKK->remark)

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3DEKK
         skip

      enddo

      // Close all files
      fATclose(aCdbf)

      // Rebuild aCdbf variable
      aCdbf := fATopen()

      // Purchases
      aCdbf := fATopen(aCdbf,cDd(),"SM3AANK")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Write the data
      select SM3AANK
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Always Animal 1
         cStra := "AnimalPurchase,"

         // Link Number 2 - 5
         cStra += ",,,,"

         // Id number 6
         cStra += alltrim(SM3AANK->idnr)+","

         // Date purchased 7
         cStra += dtod(SM3AANK->datum)+","

         // Purchased from 8
         cStra += alltrim(SM3AANK->adreskode)+","

         // Amount paid 9
         cStra += alltrim(str(SM3AANK->bedrag))+","

         // Sex 10
         cStra += ","

         // Age in months 11
         cStra += ","

         // Birth date 12
         cStra += ","

         // Weight at purchase 13
         cStra += alltrim(str(SM3AANK->massa))+","

         // Comment 14
         cStra += alltrim(SM3AANK->graad)+","

         // Filler to end of file
         cStra += ",,,,,,,,"

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3AANK
         skip

      enddo


      // Close all files
      fATclose(aCdbf)

      // Rebuild aCdbf variable
      aCdbf := fATopen()

      // Purchases
      aCdbf := fATopen(aCdbf,cDd(),"SM3VERK")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Write the data
      select SM3VERK
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Always Animal 1
         cStra := "AnimalSale,"

         // Link Number 2 - 5
         cStra += ",,,,"

         // Id number 6
         cStra += alltrim(SM3VERK->idnr)+","

         // Date purchased 7
         cStra += dtod(SM3VERK->datum)+","

         // Weight at purchase 8
         cStra += alltrim(str(SM3VERK->massa))+","

         // Purchased from 9
         cStra += alltrim(SM3VERK->adreskode)+","

         // Amount paid 10
         cStra += alltrim(str(SM3VERK->bedrag))+","

         // Comment 11
         cStra += alltrim(SM3VERK->graad)+","

         // Blank 12
         cStra += ","

         // Blank 13
         cStra += ","

         // Amount paid 14
         cStra += alltrim(str(SM3VERK->kouema))+","

         // Blank 15
         cStra += ","

         // Blank 16
         cStra += ","

         // Transfer 17
         cStra += alltrim(SM3VERK->oordra)+","

         // Transfer 18
         cStra += alltrim(SM3VERK->skrapp)+","

         // Filler to end of file
         cStra += ",,,,,,,,"

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3VERK
         skip

      enddo

      // Close all files
      fATclose(aCdbf)

      // Rebuild aCdbf variable
      aCdbf := fATopen()

      // Addresses
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Write the data
      select SM3KLIE
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(cmxkeyno(),lastrec())+"% Completed"      )
         endif

         // The actual write

         // Always Animal 1
         cStra := "Client,"

         // Link Number 2 - 5
         cStra += ",,,,"

         // Client Code 6
         cStra += alltrim(SM3KLIE->kode)+","

         // Client name 7
         cStra += alltrim(SM3KLIE->kontak)+","

         // Trading name 8
         cStra += alltrim(SM3KLIE->naam)+","

         // Address line 2 9
         cStra += alltrim(SM3KLIE->adr2)+","

         // Town 10
         cStra += alltrim(SM3KLIE->adr3)+","

         // State 11
         cStra += ","

         // Postcode 12
         cStra += alltrim(SM3KLIE->posk)+","

         // Address line 1 13
         cStra += alltrim(SM3KLIE->adr1)+","

         // Phone home 14
         cStra += alltrim(SM3KLIE->htel)+","

         // Phone work 15
         cStra += alltrim(SM3KLIE->wtel)+","

         // Fax 16
         cStra += ","

         // Mobile 17
         cStra += ","

         // Salutation 18
         cStra += ","

         // Client type code 1 19
         cStra += alltrim(SM3KLIE->tipe)+","

         // Client code type 2 20
         cStra += ","

         // Current agent 21
         cStra += ","

         // Society membership number 22
         cStra += ","

         // Other info 23
         cStra += alltrim(SM3KLIE->opmerk)+","

         // Open fields 24 - 30
         cStra += ",,,,,,,"

         // Herd prefix 31
         cStra += alltrim(SM3KLIE->kudvv)+","

         // Herd designation 32
         cStra += alltrim(SM3KLIE->kudkl)+","

         // Entry date 33
         cStra += dtod(SM3KLIE->adat)+","

         // User date 34
         cStra += dtod(SM3KLIE->datum2)+","

         // Empty fields 35 -
         cStra += ",,,,,,,,,,,,,,,,,,,,,,,,,,,,"

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error: "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         // Next record
         select SM3KLIE
         skip

      enddo

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Herdmaster lˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Herdmaster file was not created!")
         endif
      else

         // Display note on the screen
         if cLanType() == "A"
            nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
            // File
            //             "         0         0         0         0         0"
            @11, nBoxc say "'n Lˆer met die naam Saltbush.csv is in die"
            @12, nBoxc say cMailTar()+" subgids op die"
            @13, nBoxc say "hardeskyf geskryf!"
            @14, nBoxc say "Heg asseblief hierdie lˆer aan 'n epos boodskap"
            @15, nBoxc say "gerig aan die betrokke Registrerende Owerheid."
            fScrBood(maxrow()-1,"Herdmaster lˆer is suksesvol geskep!")
         else
            nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
            // File
            //             "         0         0         0         0         0"
            @11, nBoxc say "A file with the name Saltbush.csv was created in the"
            @12, nBoxc say cMailTar()+" subdirectory of the"
            @13, nBoxc say "hard disk!"
            @14, nBoxc say "Attach this file to an email message addressed"
            @15, nBoxc say "to the relative Registering Authority."
            fScrBood(maxrow()-1,"File containing births was succesfully created!")
         endif

      endif

      fScrWait(maxrow())

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu



