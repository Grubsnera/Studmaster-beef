// Application: Stoetmeester
//   File Name: SM3PURC.PRG
// Description: Program to Maintain the Purchases
//   Copyright: (c) 1996 by Q Data Consulting (Pty) Ltd, Q Farm Division
//      Author: Sarel Cloete
//  Created on: 12-12-96 08:30am

// #include "mbz.ch"
#include "set.ch"
#include "inkey.ch"
#include "albert.ch"
#include "Common.ch"

#DEFINE F_IDNR   1
#DEFINE F_DATUM  2
#DEFINE F_ADRES  3
#DEFINE F_BEDRAG 4
#DEFINE F_GESLAG 5
#DEFINE F_GEBDAT 6
#DEFINE F_OUDERM 7
#DEFINE F_MASSA  8
#DEFINE F_WAARIS 9
#DEFINE F_REMARK 10

/******************************************************************************/
FUNCTION sm3purc(nTopp,nLeft,nBott,aVeld,cFind)

   // Declare
   LOCAL cRetu := ""
   LOCAL aCdbf := fATopen()
   LOCAL cCcur := setcursor(0)
   LOCAL aOpsk := {}
   LOCAL i     := 0
   LOCAL nScrl := 0
   LOCAL cHead := ""
   LOCAL aCols := {}
   LOCAL nRigh := 0
   LOCAL bBrow := NIL
   LOCAL nKeyp := 0
   LOCAL lMove := FALSE
   LOCAL nCurr := 1
   LOCAL cCoun := ""
   LOCAL oCols := NIL
   LOCAL lAver := FALSE
   LOCAL lFilt := FALSE

   BEGIN SEQUENCE
      // Parameters
      nTopp := IF(nTopp==NIL,         3,nTopp)
      nLeft := IF(nLeft==NIL,         2,nLeft)
      nBott := IF(nBott==NIL,MAXROW()-4,nBott)
      aVeld := IF(aVeld==NIL,        {},aVeld)
      cFind := IF(cFind==NIL,        "",cFind)

      // Screen - field descriptions
      IF cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
         fScrWbood(MAXROW(),"Skermuitleg word bepaal")
      ELSE
         fScrOpsk(1,"Option "+cOption())
         fScrWbood(MAXROW(),"Screen outlay being determined")
      ENDIF
      fScrBood(MAXROW()-1)

      ASIZE(aVeld,0)
      AADD(aVeld,{"SM3AANK","idnr"})
      AADD(aVeld,{"SM3AANK","datum"})
      AADD(aVeld,{"SM3AANK","adreskode"})
      AADD(aVeld,{"SM3AANK","bedrag"})
      AADD(aVeld,{"SM3AANK","anksex"})
      AADD(aVeld,{"SM3AANK","ankbrt"})
      AADD(aVeld,{"SM3AANK","massa"})
      AADD(aVeld,{"SM3AANK","ankwhr"})
      AADD(aVeld,{"SM3AANK","graad "})
      aOpsk := fGetField(aVeld)

      // Screen - data files
      fScrBood(MAXROW()-1)
      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Datalˆers word geopen")
      ELSE
         fScrWbood(MAXROW(),"Data files being opened")
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3WEEG")
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      aCdbf := fATopen(aCdbf,cDd(),"SM3AANK")
      IF ! aCdbf[LEN(aCdbf),1]
         BREAK
      ENDIF

      DBSETRELATION("SM3DATA",{|| SM3AANK->idnr },"SM3AANK->idnr")
      DBSETRELATION("SM3WEEG",{|| SM3AANK->idnr },"SM3AANK->idnr")

      // Move the record pointer
      IF ! EMPTY(cFind)
         set soft on
         seek cFind
         set soft off
         IF EOF()
            DBGOTOP()
         ENDIF
      ELSE
         DBGOTOP()
      ENDIF

      // Calculate window width
      FOR i = 1 TO LEN( aOpsk )
         // Length
         nScrl := nScrl + aOpsk[i,FLD_LENG] + 1
         // Columns
         cHead := aOpsk[i,FLD_HED1] + ";" + aOpsk[i,FLD_HED2] + ";" + aOpsk[i,FLD_HED3]
         IF "FUNCTION" $ aOpsk[i,DBF_NAME]
            AADD(aCols,TBColumnNew(cHead,&("{||"+aOpsk[i,FLD_NAME]+"}")))
         ELSE
            AADD(aCols,TBColumnNew(cHead,fieldwblock(aOpsk[i,FLD_NAME],SELECT(STRTRAN(aOpsk[i,DBF_NAME],"->","")))))
         ENDIF
      NEXT

      // Calculate right hand column
      nRigh := IF(nLeft+nScrl > MAXCOL()-3, MAXCOL()-3, nLeft+nScrl )

      // Clear screen
      IF cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      ELSE
         fScrOpsk( ,"Option "+cOption())
      ENDIF

      // Draw the box
      IF cLanType() == "A"
         fBox(nTopp, nLeft, nBott, nRigh, "AANKOPE" )
      ELSE
         fBox( nTopp, nLeft, nBott, nRigh, "PURCHASES" )
      ENDIF
      SETCOLOR( cColNorm() )

      // Build the browse
      bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      // Build the browse columns
      FOR i = 1 TO LEN( aCols )
         bBrow:addColumn( aCols[i] )
      NEXT

      // Screen
      IF cLanType() == "A"
         fScrBood(MAXROW()-1, "[Esc]=Menu  [Ins ]=Nuwe aankoop  [Del]=Skrap  [AltT]=Totale")
         fScrBood(MAXROW()  , "[F1 ]=Hulp  [AltE]=Verander  [A-Z]=Vind  [AltP]=Druk  [AltF]=Filter ")
      ELSE
         fScrBood(MAXROW()-1, "[Esc]=Menu  [Ins ]=New purchase  [Del]=Delete  [AltT]=Totals")
         fScrBood(MAXROW()  , "[F1 ]=Help  [AltE]=Edit  [A-Z]=Find  [AltP]=Print  [AltF]=Filter")
      ENDIF

      // Freeze
      bBrow:freeze := 1

      // Main loop
      DO WHILE nKeyp <> K_ESC

         // Stabilize
         FullStabilize(bBrow)
         IF lMove
            DO WHILE RECNO() <> nCurr
               bBrow:up()
               FullStabilize(bBrow)
            ENDDO
            lMove := FALSE
         ENDIF

         // Display the record number
         cCoun := PADL(LTRIM(STR(CMXKEYNO()))+"/"+LTRIM(STR(CMXKEYCOUNT())),15,CHR(205))
         @nBott,nRigh-(LEN(cCoun)+1) SAY cCoun

         // Wait for keypress
         IF bBrow:stable
            nKeyp := inkey(0)
         ENDIF

         IF nKeyp == K_ENTER
            // Enter means return Id number and exit
            cRetu := FIELDGET(1)
            nKeyp := K_ESC

         ELSEIF nKeyp == K_INS
            // Insert means add a record to the .dbf
            nCurr := RECNO()
            IF fAddAank()
               lMove := TRUE
               nCurr := RECNO()

               IF lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               ENDIF

               bBrow:refreshall()
            ELSE
               DBGOTO (nCurr)
            ENDIF

         ELSEIF nKeyp == K_ALT_E
            // Alt E means change a record
            nCurr := RECNO()
            IF fAddAank(RECNO())
               lMove := TRUE
               nCurr := RECNO()

               IF lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               ENDIF

               bBrow:refreshall()
            ELSE
               DBGOTO (nCurr)
            ENDIF

         ELSEIF nKeyp == K_ALT_T
            // Alt T means toggle totals and averages
            IF lAver
               lAver := FALSE
               // Remove all the column footings
               FOR i := 1 TO LEN(aOpsk)
                  oCols := bBrow:getcolumn(i)
                  oCols:footsep := ""
                  oCols:footing := ""
               NEXT
            ELSE
               lAver := TRUE
               // Do the actual calculation
               fAverage(aOpsk,bBrow)
            ENDIF
            bBrow:configure()

         ELSEIF nKeyp == K_ALT_F
            // Alt F means set a filter
            IF lFilt
               lFilt := FALSE
               cmclrfilter()
               DBGOTOP()

               IF lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               ENDIF

               bBrow:refreshall()
            ELSE
               IF fFilter()
                  lFilt := TRUE

                  IF lAver
                     fAverage(aOpsk,bBrow)
                     bBrow:configure()
                  ENDIF

                  bBrow:refreshall()
               ENDIF
            ENDIF

         ELSEIF nKeyp == K_DEL
            // Delete means Delete a record
            IF fDelete()
               IF lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               ENDIF

               bBrow:refreshall()
            ENDIF

         ELSEIF nKeyp == K_ALT_P
            // Alt P means print
            IF fPrint(aOpsk,lAver)
               bBrow:refreshall()
            ENDIF

         ELSEIF nKeyp == K_F1
            // Help
            DO help with "SM3PURC",1,"oorsig"

         ELSEIF UPPER(CHR(nKeyp)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            // Means locate a record
            IF fLocate(UPPER(CHR(nKeyp)))
               lMove := TRUE
               nCurr := RECNO()

               IF lAver
                  fAverage(aOpsk,bBrow)
                  bBrow:configure()
               ENDIF

               bBrow:refreshall()
            ENDIF

         ELSE

            // Apply the key to the browse
            ApplyKey(bBrow, nKeyp)

         ENDIF

      ENDDO

   END

   // Reset
   fATclose(aCdbf)
   setcursor(cCcur)

RETURN cRetu

/******************************************************************************/
STATIC FUNCTION fDelete ()

   // Function to Delete records

   // Declare
   LOCAL aCscr := fASaveScr(MAXROW()-1,0,MAXROW(),MAXCOL())
   LOCAL lRetu := FALSE
   LOCAL cBood := ""

   // Screen
   IF cLanType() == "A"
      cBood := "Moet bogenoemde dier uit aankope lˆer geskrap word ?"
      fScrBood(MAXROW()-1,SM3AANK->idnr+[ - ]+ALLTRIM(SM3AANK->adreskode))
   ELSE
      cBood := "Should the above-mentioned animal be removed from purchase file ?"
      fScrBood(MAXROW()-1,SM3AANK->idnr+[ - ]+ALLTRIM(SM3AANK->adreskode))
   ENDIF

   IF fJaNee(MAXROW(),cBood,,FALSE )
      IF RLOCK()
         DBDELETE()
         DBUNLOCK()
         DBSKIP()
         IF EOF()
            DBGOTOP()
         ENDIF
         lRetu := TRUE
      ENDIF
   ENDIF

   // Reset
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fLocate(cKeyp)

   // Function to locate any record

   // Declare
   LOCAL getlist := {}
   LOCAL lRetu := TRUE
   LOCAL aCscr := fASaveScr()
   LOCAL nBoxc := 0

   // Field length
   cKeyp += SPACE(11)
   KEYBOARD CHR(K_RIGHT)

   // Ask the data to locate
   fScrBood(MAXROW()-1)
   IF cLanType() == "A"
      fScrBood(MAXROW(),"Tik die ID NOMMER waarna gesoek word!")
      nBoxc := fBoxCent(MAXROW()/2,"Vind ? "+SPACE(LEN(cKeyp)),1)
      @MAXROW()/2, nBoxc SAY "Vind ?" GET cKeyp PICT "@K!"
   ELSE
      fScrBood(MAXROW(),"Type the ID NUMBER being searched for!")
      nBoxc := fBoxCent(MAXROW()/2,"Find ?"+SPACE(LEN(cKeyp)),1)
      @MAXROW()/2, nBoxc SAY "Find ?" GET cKeyp PICT "@K!"
   ENDIF

   // Read
   SET(_SET_CURSOR,1)
   READ
   SET(_SET_CURSOR,0)
   fARestScr(aCscr)
   cmclrfilter()

   // To do
   IF LASTKEY() == K_ESC
      lRetu := FALSE
   ELSE
      set soft on
      seek cKeyp
      set soft off
      IF EOF()
         DBGOTOP()
      ENDIF
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fAddAank(nReko,aOpsk)

   // Declare
   LOCAL getList := {}
   LOCAL lRetu := FALSE
   LOCAL aCscr := fASaveScr()
   LOCAL aCdbf := fATopen()
   LOCAL aVeld := {}
   LOCAL nLine := 0
   LOCAL nBoxc := 0
   LOCAL lLoop := TRUE
   LOCAL lClea := TRUE
   LOCAL lRepe := FALSE
   LOCAL i     := 0
   LOCAL nPrev := 1
   LOCAL cMess := ""

   BEGIN SEQUENCE
      // Values
      nReko := IIF(EMPTY(nReko),0,nReko)

      // Get the fields
      IF EMPTY(aOpsk)
         ASIZE(aVeld,0)
         AADD(aVeld,{"SM3AANK","idnr  "})
         AADD(aVeld,{"SM3AANK","datum "})
         AADD(aVeld,{"SM3AANK","adreskode"})
         AADD(aVeld,{"SM3AANK","bedrag"})
         AADD(aVeld,{"SM3AANK","anksex"})
         AADD(aVeld,{"SM3AANK","ankbrt"})
         AADD(aVeld,{"SM3AANK","ankage"})
         AADD(aVeld,{"SM3AANK","massa "})
         AADD(aVeld,{"SM3AANK","ankwhr"})
         AADD(aVeld,{"SM3AANK","graad"})
         aOpsk := fGetField(aVeld)
      ENDIF

      // Screen
      nLine := MAXROW()/2-int(LEN(aOpsk)/2)-1
      IF nReko == 0
         IF cLanType() == "A"
            nBoxc := fBoxCent(nLine,SPACE(60),LEN(aOpsk)+2,"BEWAAR AANKOPE" )
         ELSE
            nBoxc := fBoxCent(nLine,SPACE(60),LEN(aOpsk)+2,"ENTER PURCHASES" )
         ENDIF
      ELSE
         IF cLanType() == "A"
            nBoxc := fBoxCent(nLine,SPACE(60),LEN(aOpsk)+2,"VERANDER AANKOPE" )
         ELSE
            nBoxc := fBoxCent(nLine,SPACE(60),LEN(aOpsk)+2,"EDIT PURCHASES" )
         ENDIF
      ENDIF

      fAddMess()
      cmclrfilter()

      // The get
      lLoop := TRUE
      DO WHILE lLoop

         IF lClea
            // Get the current values
            IF nReko == 0
               // Insert a new record
               IF lRepe
                  lRepe := FALSE
                  aOpsk := fFillBlank(aOpsk)
               ELSE
                  aOpsk := fFillBlank(aOpsk)
               ENDIF
            ELSE
               // Edit a record by filling the array with current values
               FOR i := 1 TO LEN(aOpsk)
                  SELECT SELECT(STRTRAN(aOpsk[i,DBF_NAME],"->",""))
                  aOpsk[i,FLD_CARG] := FIELDGET(aOpsk[i,FLD_NUMB])
               NEXT
            ENDIF
         ELSE
            // Clear the get array
            lClea := TRUE
         ENDIF

         // Vertoon en get velde
         @nLine+ 1,nBoxc SAY aOpsk[F_IDNR,FLD_DESC] GET aOpsk[F_IDNR,FLD_CARG] PICT aOpsk[F_IDNR,FLD_PICT] ;
            WHEN(fWIdnomm(nReko)) ;
            VALID(fVIdnomm(getlist,aOpsk,nReko))
         @nLine+ 2,nBoxc SAY aOpsk[F_DATUM,FLD_DESC] GET aOpsk[F_DATUM,FLD_CARG] PICT aOpsk[F_DATUM,FLD_PICT] ;
            WHEN(fWDatum(nReko))
         @nLine+ 3,nBoxc SAY aOpsk[F_ADRES,FLD_DESC] GET aOpsk[F_ADRES,FLD_CARG] PICT aOpsk[F_ADRES,FLD_PICT] ;
            WHEN(fWAdres(nReko)) ;
            VALID(IIF(LASTKEY() == K_UP, TRUE,fVAdres(getlist,aOpsk,nReko)))
         @nLine+ 4,nBoxc SAY aOpsk[F_BEDRAG,FLD_DESC] GET aOpsk[F_BEDRAG,FLD_CARG] PICT aOpsk[F_BEDRAG,FLD_PICT] ;
            WHEN(fWPrice(nReko))
         @nLine+ 5,nBoxc SAY aOpsk[F_GESLAG,FLD_DESC] GET aOpsk[F_GESLAG,FLD_CARG] PICT aOpsk[F_GESLAG,FLD_PICT] ;
            WHEN(fWSex(nReko)) ;
            VALID(aOpsk[F_GESLAG,FLD_CARG] == "1" .OR. aOpsk[F_GESLAG,FLD_CARG] == "2" .OR. aOpsk[F_GESLAG,FLD_CARG] == "3")
         @nLine+ 6,nBoxc SAY aOpsk[F_GEBDAT,FLD_DESC] GET aOpsk[F_GEBDAT,FLD_CARG] PICT aOpsk[F_GEBDAT,FLD_PICT] ;
            WHEN(fWGebdat(nReko)) ;
            VALID(IIF(LASTKEY() == K_UP, TRUE,fVGebdat(getlist,aOpsk,nReko)))
         @nLine+ 7,nBoxc SAY aOpsk[F_OUDERM,FLD_DESC] GET aOpsk[F_OUDERM,FLD_CARG] PICT aOpsk[F_OUDERM,FLD_PICT] ;
            WHEN(fWOuder(nReko)) ;
            VALID(IIF(LASTKEY() == K_UP, TRUE,fVOuder(getlist,aOpsk,nReko)))
         @nLine+ 8,nBoxc SAY aOpsk[F_MASSA,FLD_DESC] GET aOpsk[F_MASSA,FLD_CARG] PICT aOpsk[F_MASSA,FLD_PICT] ;
            WHEN(fWMassa(nReko))
         @nLine+ 9,nBoxc SAY aOpsk[F_WAARIS,FLD_DESC] GET aOpsk[F_WAARIS,FLD_CARG] PICT aOpsk[F_WAARIS,FLD_PICT] ;
            WHEN(fWWaarisd(nReko)) ;
            VALID(IIF(LASTKEY() == K_UP, TRUE,fVWaarisd(getlist,aOpsk,nReko)))
         @nLine+10,nBoxc SAY aOpsk[F_REMARK,FLD_DESC] GET aOpsk[F_REMARK,FLD_CARG] PICT aOpsk[F_REMARK,FLD_PICT] ;
            WHEN(fWRemark(nReko))

         // The get
         SET(_SET_CURSOR,1)
         READ
         SET(_SET_CURSOR,0)

         // Reset the database
         fATclose(aCdbf)

         // The actions
         IF LASTKEY() == K_ENTER

            // Add or edit record
            IF nReko == 0
               // Add
               DBAPPEND()
            ELSE
               // Edit
               DO WHILE ! RLOCK()
               ENDDO
            ENDIF

            // Save the entry
            lRetu := TRUE

            FOR i := 1 TO LEN(aOpsk)
               FIELDPUT(aOpsk[i,FLD_NUMB],aOpsk[i,FLD_CARG])
            NEXT

            DBUNLOCK()
            DBCOMMIT()

            // Store the current record number
            nPrev := RECNO()

            IF nReko == 0
               // Save the animal in hoof lˆer
               DBSELECTAREA("SM3DATA")

               IF ! SM3DATA->(DBSEEK(aOpsk[F_IDNR,FLD_CARG]))
                  DBAPPEND()
                  SM3DATA->idnr := aOpsk[F_IDNR,FLD_CARG]
               ELSE
                  DO WHILE ! RLOCK()
                  ENDDO
               ENDIF

               if empty(SM3DATA->gebdatum)
                  SM3DATA->gebdatum := aOpsk[F_GEBDAT,FLD_CARG]
               endif
               if empty(SM3DATA->dataan)
                  SM3DATA->dataan   := aOpsk[F_DATUM,FLD_CARG]
               endif
               if empty(SM3DATA->geslag)
                  SM3DATA->geslag   := aOpsk[F_GESLAG,FLD_CARG]
               endif
               if empty(SM3DATA->uitkrede)
                  SM3DATA->uitkrede := aOpsk[F_WAARIS,FLD_CARG]
               endif
               DBCOMMIT()

               // Save the animal in weighings file
               IF ! EMPTY(aOpsk[F_MASSA,FLD_CARG])
                  DBSELECTAREA("SM3WEEG")

                  IF ! SM3WEEG->(DBSEEK(aOpsk[F_IDNR,FLD_CARG]))
                     DBAPPEND()
                     SM3WEEG->idnr := aOpsk[F_IDNR,FLD_CARG]
                  ELSE
                     DO WHILE ! RLOCK()
                     ENDDO
                  ENDIF

                  SM3WEEG->weegdatum := aOpsk[F_DATUM,FLD_CARG]
                  SM3WEEG->massa     := aOpsk[F_MASSA,FLD_CARG]
                  DBCOMMIT()
               ENDIF
            ENDIF

            // Next new record
            DBSELECTAREA("SM3AANK")
            IF nReko == 0
               // Repeat the previous data
               lRepe := TRUE
               LOOP
            ENDIF
         ELSE
            // Activate the correct previous record
            IF ! EMPTY(nPrev)
               DBGOTO (nPrev)
            ENDIF

            // Escaped
            IF UPDATED()
               // Warn that data will be lost
               IF cLanType() == "A"
                  cMess := "Kan veranderings verlore gaan?"
               ELSE
                  cMess := "Ok to lose changes?"
               ENDIF

               IF ! fJaNee(MAXROW(),cMess)
                  lClea := FALSE
                  LOOP
               ENDIF
            ENDIF
         ENDIF

         lLoop := FALSE
      ENDDO
   END

   // Reset
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fAddMess

   // Function to paint the get message

   // The print
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die besonderhede van die dier aangekoop !")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the particulars of the animal purchased !")
   ENDIF

RETURN TRUE

/******************************************************************************/
STATIC FUNCTION fWIdnomm(nReko)

   // Function to control entry of the id number field

   LOCAL lRetu := TRUE

   // If an edit
   IF nReko > 0
      lRetu := FALSE
   ELSE
      // Screen
      IF cLanType() == "A"
         fScrBood(MAXROW()-1,"[Esc]=Menu")
         fScrBood(MAXROW()  ,"Tik die ID NOMMER van die dier aangekoop.")
      ELSE
         fScrBood(MAXROW()-1,"[Esc]=Menu")
         fScrBood(MAXROW()  ,"Type the ID NUMBER of the animal purchased.")
      ENDIF
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWDatum(nReko)

   // Function to control entry of the datum field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die datum waarop die dier aangekoop is.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the date on which the animal purchased.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWMassa(nReko)

   // Function to control entry of the Mass field

   // Declare
   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die massa van die dier met aankoop.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the mass of the animal purchased.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWAdres(nReko)

   // Function to control entry of the Address code field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood( 23, "[Esc]=Menu.  "+D_DNARR+"==Adreskodes van verkopers.")
      fScrBood(MAXROW()  ,"Tik die adreskode van die verkoper.")
   ELSE
      fScrBood( 23, "[Esc]=Menu. "+D_DNARR+"==Address codes of sellers." )
      fScrBood(MAXROW()  ,"Type the address code of the seller.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWPrice(nReko)

   // Function to control entry of the Purchase Price field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die bedrag waarvoor die dier aankoop is.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the amount paid for the animal purchased.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWSex(nReko)

   // Function to control entry of the Remarks field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die geslag kode ([1]=vroulik, [2]=manlik, [3]=ander) van die dier.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the sex code ([1]=female, [2]=male, [3]=other) of the animal.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWGebdat(nReko)

   // Function to control entry of the Birth Date field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die geboorte datum van die dier (Gebruik Ouderdom indien onbekend).")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the birth date of the animal (Use age if unknown).")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWOuder(nReko)

   // Function to control entry of the Age field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik die ouderdom (maande) van die dier, indien geboorte datum onbekend is.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type the age (months) of the animal, only when birth date is unknown.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWWaarisd(nReko)

   // Function to control entry of the Where is animal code field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu   "+D_DNARR+"=Lys van waar-is-dier kodes")
      fScrBood(MAXROW()  ,"Tik die 'Waar is dier' kode.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu   "+D_DNARR+"=List of where-is-animal codes")
      fScrBood(MAXROW()  ,"Type the 'Where is animal' code.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fWRemark(nReko)

   // Function to control entry of the Remarks field

   LOCAL lRetu := TRUE

   // Screen
   IF cLanType() == "A"
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Tik enige opmerking aangaande die aankoop van bogenoemde dier.")
   ELSE
      fScrBood(MAXROW()-1,"[Esc]=Menu")
      fScrBood(MAXROW()  ,"Type any remark regarding the purchase of the animal.")
   ENDIF

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fVIdnomm(aGets,aOpsk,nReko)

   // Declare
   LOCAL lRetu := TRUE
   LOCAL aCscr := fASaveScr()
   LOCAL aCdbf := fATopen()
   LOCAL nFiel := fEnum(aOpsk,"idnr")

   BEGIN SEQUENCE
      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3AANK")
      IF ! aCdbf[LEN(aCdbf),1]
         lRetu := FALSE
         BREAK
      ENDIF

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      IF ! aCdbf[LEN(aCdbf),1]
         lRetu := FALSE
         BREAK
      ENDIF

      IF EMPTY(aGets[nFiel]:varget())
         // No number given - exit to browse
         KEYBOARD CHR(K_ESC)
         lRetu := FALSE
         BREAK
      ENDIF

      // Check if the Entered Code Exist Already
      IF SM3AANK->(DBSEEK(aGets[nFiel]:varget()))

         IF cLanType() == "A"
            fScrBood(MAXROW()-1,"Dier alreeds in aankope lˆer !")
         ELSE
            fScrBood(MAXROW()-1,"Animal already in purchase file !")
         ENDIF

         lRetu := FALSE
         fScrWait(MAXROW())
         BREAK
      ENDIF

      // Check if the Entered Code Exist Already
      // Removed for Pat Hobbs 03-04-98 12:31pm
      //IF SM3DATA->(DBSEEK(aGets[nFiel]:varget()))
      //
      //   IF cLanType() == "A"
      //      fScrBood(MAXROW()-1,"Dier bestaan alreeds op hooflˆer !")
      //   ELSE
      //      fScrBood(MAXROW()-1,"Animal exist already on main file !")
      //   ENDIF
      //
      //   lRetu := FALSE
      //   fScrWait(MAXROW())
      //   BREAK
      //ENDIF

   END

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fVAdres(aGets,aOpsk,nReko)

   // Declare
   LOCAL lRetu  := TRUE
   LOCAL aCscr  := fASaveScr()
   LOCAL aCdbf := fATopen()
   LOCAL aSend  := {}
   LOCAL nAdres := fEnum(aOpsk,"adreskode")

   BEGIN SEQUENCE
      // Check for down arrow
      IF LASTKEY() == K_DOWN
         AADD( aSend, { "sm3klie", "kode" })
         AADD( aSend, { "sm3klie", "naam" })
         aOpsk[F_ADRES,FLD_CARG] := sm3klie( 4, 4, 20, aSend, aOpsk[F_ADRES,FLD_CARG] )
         BREAK
      ENDIF

      IF EMPTY(aGets[nAdres]:varget())
         // No Address code given - exit
         BREAK
      ENDIF

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3KLIE")
      IF ! aCdbf[LEN(aCdbf),1]
         lRetu := FALSE
         BREAK
      ENDIF

      // Check if the Entered Code Exist Already
      DBSELECTAREA("SM3KLIE")

      IF ! SM3KLIE->(DBSEEK(aGets[nAdres]:varget()))
         AADD( aSend, { "sm3klie", "kode" })
         AADD( aSend, { "sm3klie", "naam" })
         aOpsk[F_ADRES,FLD_CARG] := sm3klie( 4, 4, 20, aSend, aOpsk[F_ADRES,FLD_CARG] )
         BREAK
      ENDIF
   END

   // Herstel
   fATclose(aCdbf)
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fVGebdat(aGets,aOpsk,nReko)

   // Declare
   LOCAL lRetu   := TRUE
   LOCAL aCscr   := fASaveScr()
   LOCAL nGebdat := fEnum(aOpsk,"ankbrt")
   LOCAL nDatum  := fEnum(aOpsk,"datum")
   LOCAL nAge    := fEnum(aOpsk,"ankage")

   BEGIN SEQUENCE
      IF EMPTY(aGets[nGebdat]:varget())
         // No Birth date given - exit
         BREAK
      ENDIF

      // Check if the Birth date is before purchase date
      IF aGets[nGebdat]:varget() > aGets[nDatum]:varget()
         IF cLanType() == "A"
            fScrBood(MAXROW()-1,"Geboorte datum na aankoop datum ?")
         ELSE
            fScrBood(MAXROW()-1,"Birth date after purchase date ?")
         ENDIF

         lRetu := FALSE
         fScrWait(MAXROW())
         BREAK
      ENDIF

      aGets[nAge]:varput(ROUND((aGets[nDatum]:varget() - aGets[nGebdat]:varget()) / 30.4375,0))
      aGets[nAge]:updatebuffer()
      BREAK
   END

   // Herstel
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fVOuder(aGets,aOpsk,nReko)

   // Declare
   LOCAL lRetu   := TRUE
   LOCAL aCscr   := fASaveScr()
   LOCAL nGebdat := fEnum(aOpsk,"ankbrt")
   LOCAL nDatum  := fEnum(aOpsk,"datum")
   LOCAL nAge    := fEnum(aOpsk,"ankage")

   BEGIN SEQUENCE
      IF EMPTY(aGets[nGebdat]:varget()) .AND. EMPTY(aGets[nAge]:varget())
         // No Birth date or age given - error
         IF cLanType() == "A"
            fScrBood(MAXROW()-1,"Geboorte datum of ouderdom moet voorsien word !")
         ELSE
            fScrBood(MAXROW()-1,"Birth date or Age must be entered !")
         ENDIF

         lRetu := FALSE
         fScrWait(MAXROW())
         BREAK
      ENDIF

      // Calculate birth date from age entered
      IF EMPTY(aGets[nGebdat]:varget())
         aGets[nGebdat]:varput(aGets[nDatum]:varget() - (aGets[nAge]:varget() * 30.4375))
         aGets[nGebdat]:updatebuffer()
         BREAK
      ENDIF
   END

   // Herstel
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fVWaarisd(aGets,aOpsk,nReko)

   // Declare
   LOCAL lRetu   := TRUE
   LOCAL cData   := ""
   LOCAL aCscr   := fASaveScr()
   LOCAL aCdbf   := fATopen()
   LOCAL nWaaris := fEnum(aOpsk,"ankwhr")

   BEGIN SEQUENCE
      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"SM3WAAR")
      IF !aCdbf[len(aCdbf),1]
         lRetu := FALSE
         BREAK
      ENDIF

      // The choices
      IF lastkey() == K_DOWN

         // Display list of animals
         cData := sm3waar(11,,,,aGets[nWaaris]:varget())
         IF !empty(cData)
            aGets[nWaaris]:varput(cData)
            aGets[nWaaris]:updatebuffer()
            IF lastkey() == K_ESC
               lRetu := FALSE
               BREAK
            ENDIF
         ELSE
            lRetu := FALSE
            BREAK
         ENDIF

      ELSEIF ! aGets[nWaaris]:varget() $ cWaarisd()

         // Display list of animals
         cData := sm3waar(11,,,,aGets[nWaaris]:varget())
         IF !empty(cData)
            aGets[nWaaris]:varput(cData)
            aGets[nWaaris]:updatebuffer()
            IF lastkey() == K_ESC
               lRetu := FALSE
               BREAK
            ELSE
               BREAK
            ENDIF
         ELSE
            // Not a vaild Where is animal code
            IF cLanType() == "A"
               fScrBood(MAXROW()-1,"Ongeldige Waar-is-dier kode !")
            ELSE
               fScrBood(MAXROW()-1,"Invalid Where-is-animal code !")
            ENDIF
         ENDIF

         lRetu := FALSE
         fScrWait(MAXROW())
         BREAK
      ENDIF
   END

   // Herstel
   fARestScr(aCscr)
   fATclose(aCdbf)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fAverage(aRecv,bBrow)

   // Function to calculate averages

   // Declare
   LOCAL lRetu := TRUE
   LOCAL aCscr := fASaveScr(MAXROW()-1,0,MAXROW(),MAXCOL())
   LOCAL nReko := RECNO()
   LOCAL i     := 0
   LOCAL oCols := NIL

   BEGIN SEQUENCE

      // Loop through all the columns to clear totals etc.
      FOR i := 1 TO LEN(aRecv)
         aRecv[i,FLD_COUN] := 0
         aRecv[i,FLD_TOTA] := 0
      NEXT

      // Set the data file
      DBGOTOP()

      // Screen
      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Totale en gemiddeldes word bereken")
      ELSE
         fScrWbood(MAXROW(),"Totals and averages being calculated")
      ENDIF

      // Loop through the file
      DO WHILE !EOF()

         // Screen
         IF cLanType() == "A"
            fScrbood(MAXROW()-1,fPercent(CMKEYNO(),CMKEYCOUNT())+"% Voltooi")
         ELSE
            fScrbood(MAXROW()-1,fPercent(CMKEYNO(),CMKEYCOUNT())+"% Completed")
         ENDIF

         // Loop through all the columns
         FOR i := 1 TO LEN(aRecv)
            IF aRecv[i,FLD_TYPE] == "N"
               SELECT SELECT(STRTRAN(aRecv[i,1],"->",""))
               IF fieldget(aRecv[i,FLD_NUMB]) > 0
                  aRecv[i,FLD_COUN]++
                  aRecv[i,FLD_TOTA] += fieldget(aRecv[i,FLD_NUMB])
               ENDIF
            ENDIF
         NEXT

         // Next record
         DBSELECTAREA("SM3AANK")
         DBSKIP()

      ENDDO

      DBGOTO (nReko)

      // Add all the column footings
      FOR i := 1 TO LEN(aRecv)
         oCols := bBrow:getcolumn(i)
         oCols:footsep := "Í"
         IF i == 1
            // First column to show headings
            IF cLanType() == "A"
               oCols:footing := PADL("Gemiddeld:",aRecv[i,FLD_LENG])+";"+;
                  PADL("Totaal:",aRecv[i,FLD_LENG])
            ELSE
               oCols:footing := PADL("Average:",aRecv[i,FLD_LENG])+";"+;
                  PADL("Total:",aRecv[i,FLD_LENG])
            ENDIF
         ELSEIF aRecv[i,FLD_TYPE] == "N"
            // Calc the average for all numeric cols
            oCols:footing := TRANSFORM(zer(aRecv[i,FLD_TOTA],aRecv[i,FLD_COUN]),aRecv[i,FLD_PICT])+";"+;
               TRANSFORM(aRecv[i,FLD_TOTA],aRecv[i,FLD_PICT])
         ELSE
            // Fill footings with spaces for all other cols
            oCols:footing := SPACE(aRecv[i,FLD_LENG])+";"+;
               SPACE(aRecv[i,FLD_LENG])
         ENDIF
      NEXT
   END

   // Reset
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fFilter

   // Function to display only selected records

   // Declare
   LOCAL lRetu := FALSE
   LOCAL aCscr := fASaveScr()
   LOCAL cTest := ""
   LOCAL nBoxc := 0
   LOCAL dFrom := CTOD("")
   LOCAL dToto := CTOD("")
   LOCAL cWhom := SM3AANK->adreskode
   LOCAL cSele := " "
   LOCAL getlist := {}

   BEGIN SEQUENCE

      // The screen
      IF cLanType() == "A"
         nBoxc := fBoxCent(10,"Verkope vanaf watter datum? xx/xx/xx",6,"Filter")
         @11,nBoxc SAY "Verkope vanaf watter datum?" get dFrom
         @12,nBoxc SAY "          Tot watter datum?" get dToto
         @13,nBoxc SAY "          Vir watter koper?" get cWhom pict "@K!"
         @14,nBoxc SAY "             Seleksiegroep?" get cSele pict "!"
      ELSE
         nBoxc := fBoxCent(10,"Sales from which date? xx/xx/xx",6,"Filter")
         @11,nBoxc SAY "Sales from which date?" get dFrom
         @12,nBoxc SAY "        To which date?" get dToto
         @13,nBoxc SAY "      For which buyer?" get cWhom pict "@K!"
         @14,nBoxc SAY "      Selection group?" get cSele pict "!"
      ENDIF

      // The read
      setcursor(1)
      read
      setcursor(0)

      // Escaped
      IF LASTKEY() == K_ESC
         BREAK
      ENDIF

      // Build the search array
      IF !EMPTY(dFrom)
         cTest += "SM3AANK->datum>=CTOD('"+DTOC(dFrom)+"').AND."
      ENDIF

      IF !EMPTY(dToto)
         cTest += "SM3AANK->datum<=CTOD('"+DTOC(dToto)+"').AND."
      ENDIF

      IF !EMPTY(cWhom)
         cTest += "SM3AANK->adreskode=='"+cWhom+"'.AND."
      ENDIF

      IF cSele $ "JY"
         cTest += sm3selg()
      ENDIF

      // If no search
      IF EMPTY(cTest)
         BREAK
      ENDIF

      // Remove the last and from the search string
      IF right(cTest,5) == ".AND."
         cTest := LEFT(cTest,LEN(cTest)-5)
      ENDIF

      // Screen
      fScrBood(MAXROW()-1)
      IF cLanType() == "A"
         fScrWbood(MAXROW(),"Diere word uitgesoek")
      ELSE
         fScrWbood(MAXROW(),"Animals being selected")
      ENDIF

      // Set the filter
      lRetu := TRUE
      cmfilter(cTest)
      DBGOTOP()

   END

   // Reset
   fARestScr(aCscr)

RETURN lRetu

/******************************************************************************/
STATIC FUNCTION fPrint(aOpsk,lAver)

   // Function to print

   // Declare
   LOCAL lRetu := TRUE
   LOCAL aCscr := fASaveScr()
   LOCAL nReko := RECNO()
   LOCAL aVeld := {}
   LOCAL cHdln := ""
   LOCAL i     := 0
   LOCAL nWidt := 0
   LOCAL nTopl := 0
   LOCAL nPrnl := 0
   LOCAL nCspa := 1
   LOCAL nMidc := 0
   LOCAL cPrnt := ""
   LOCAL cPrnl := ""
   LOCAL nBlad := 1
   LOCAL cData := ""
   LOCAL nCoun := 1
   LOCAL nDrag := 0
   LOCAL nOpen := 0
   LOCAL nChoi := 1

   BEGIN SEQUENCE
      // Test availability of printer
      IF fPrnReady(MAXROW()-1) == K_ESC
         BREAK
      ENDIF

      // Screen - fields to print
      fScrBood(MAXROW()-1)
      IF cLanType() == "A"
         fScrBood(MAXROW(),"Drukuitleg word bepaal")
      ELSE
         fScrBood(MAXROW(),"Print outlay being determined")
      ENDIF

      IF empty(aOpsk)
         AADD(aVeld,{"SM3AANK","idnr"     })
         AADD(aVeld,{"SM3AANK","datum"    })
         AADD(aVeld,{"SM3AANK","adreskode"})
         AADD(aVeld,{"SM3AANK","bedrag"   })
         AADD(aVeld,{"SM3AANK","anksex"   })
         AADD(aVeld,{"SM3AANK","ankbrt"   })
         AADD(aVeld,{"SM3AANK","massa"    })
         AADD(aVeld,{"SM3AANK","ankwhr"   })
         AADD(aVeld,{"SM3AANK","graad"    })
         aOpsk := fGetField(aVeld)
      ENDIF

      // Determine the print width
      FOR i := 1 TO LEN(aOpsk)
         nWidt += aOpsk[i,FLD_LENG] + nCspa
      NEXT

      IF nWidt > nPrnWidt()
         // Condensed
         nWidt := nPrnCwid()
         nTopl := nPrnLine()
         cPrnt := cPrnCond()

         IF lAver
            nPrnl := nPrcPrnl()-3
         ELSE
            nPrnl := nPrcPrnl()
         ENDIF

      ELSE
         // Normal
         nWidt := nPrnWidt()
         nTopl := nPrnLine()
         cPrnt := cPrnNorm()

         IF lAver
            nPrnl := nPrnPrnl()-3
         ELSE
            nPrnl := nPrnPrnl()
         ENDIF
      ENDIF

      nMidc := nWidt - 29

      // Select the dfata file
      DBGOTOP()

      // Screen
      IF cLanType() == "A"
         fScrbood(MAXROW(),"AANKOPE word gedruk!  [Esc]=Stop drukker.")
         cHdln := "Aankope"
      ELSE
         fScrbood(MAXROW(),"PURCHASES being printed!  [Esc]=Stop printer.")
         cHdln := "Purchases"
      ENDIF

      // Switch printer on
      fPrnOn()

      // The loop
      DO WHILE !EOF()

         // Headings
         IF PROW() = 0
            fPrnCod( cPrnt )

            IF cLanType() == "A"
               @PROW()+nTopl, 1 SAY upper( cGebNaam() )
               @PROW()  , nMidc SAY "             Verslag: " + cOption()
               @PROW()+1,     1 SAY substr(cTotNaam(),  1,40)
               @PROW()  , nMidc SAY "               Datum: " + dtoc( dAppDate() )
               @PROW()+1,     1 SAY substr(cTotNaam(), 41,40)
               @PROW()  , nMidc SAY "              Bladsy: " + ltrim( str( nBlad, 8 ) )
               @PROW()+1,     1 SAY substr(cTotNaam(), 81,40)
               @PROW()  , nMidc SAY "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
               @PROW()+1,     1 SAY substr(cTotNaam(),121, 4)
               @PROW()  ,nWidt-LEN(cHdln)+1 SAY cHdln
            ELSE
               @PROW()+nTopl, 1 SAY upper( cGebNaam() )
               @PROW()  , nMidc SAY "              Report: " + cOption()
               @PROW()+1,     1 SAY substr(cTotNaam(),  1,40)
               @PROW()  , nMidc SAY "                Date: " + dtoc( dAppDate() )
               @PROW()+1,     1 SAY substr(cTotNaam(), 41,40)
               @PROW()  , nMidc SAY "                Page: " + ltrim( str( nBlad, 8 ) )
               @PROW()+1,     1 SAY substr(cTotNaam(), 81,40)
               @PROW()  , nMidc SAY "    Herd Designation: " + substr(cTotNaam(),125,4)
               @PROW()+1,     1 SAY substr(cTotNaam(),121, 4)
               @PROW()  ,nWidt-LEN(cHdln)+1 SAY cHdln
            ENDIF

            @PROW()+1,  1 SAY REPLICATE( "=", nWidt )

            // 1st heading line
            cPrnl := ""
            FOR i = 1 TO LEN(aOpsk)
               cPrnl += PADR(TRIM(aOpsk[i,7]),aOpsk[i,4]) + SPACE(nCspa)
            NEXT
            @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

            // 2nd heading line
            cPrnl := ""
            FOR i = 1 TO LEN(aOpsk)
               cPrnl += PADR(TRIM(aOpsk[i,8]),aOpsk[i,4]) + SPACE(nCspa)
            NEXT
            @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

            // 3rd heading line
            cPrnl := ""
            FOR i = 1 TO LEN(aOpsk)
               cPrnl += PADR(TRIM(aOpsk[i,9]),aOpsk[i,4]) + SPACE(nCspa)
            NEXT
            @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

            // 4th heading line
            cPrnl := ""
            FOR i = 1 TO LEN(aOpsk)
               cPrnl += REPLICATE("-",aOpsk[i,4]) + SPACE(nCspa)
            NEXT
            @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

         ENDIF

         // Stop printer
         IF fPrnStop() = K_ESC
            lRetu := FALSE
            BREAK
         ENDIF

         // Data
         cPrnl := ""
         FOR i = 1 TO LEN(aOpsk)
            cData := aOpsk[i,1] + aOpsk[i,2]
            IF aOpsk[i,3] == "D"
               cPrnl += DTOC(&(cData)) + SPACE(nCspa)
            ELSEIF aOpsk[i,3] == "N"
               cPrnl += STR(&(cData),aOpsk[i,4],aOpsk[i,5]) + SPACE(nCspa)
            ELSE
               cPrnl += &(cData) + SPACE(nCspa)
            ENDIF
         NEXT
         @PROW()+1,1 SAY LEFT(cPrnl,nWidt)
         nCoun++

         // Screen
         // fPrnOff()
         // IF CMKEYCOUNT() > 0
         //    SETCOLOR( cColBott() )
         //    IF cLanType() == "A"
         //       fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+" % Voltooi")
         //    ELSE
         //       fScrBood(MAXROW()-1,STR((CMKEYNO()/CMKEYCOUNT())*100,4,0)+" % Completed")
         //    ENDIF
         //    SETCOLOR( cColNorm() )
         // ENDIF
         // fPrnOn()

         // Next record
         DBSELECTAREA("SM3AANK")
         DBSKIP()

         IF PROW() >= nPrnl .OR. EOF()
            // Averages and totals
            IF lAver .AND. EOF()
               // Bottom line
               cPrnl := ""
               FOR i = 1 TO LEN(aOpsk)
                  cPrnl += REPLICATE("-",aOpsk[i,4]) + SPACE(nCspa)
               NEXT
               @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

               // Averages
               cPrnl := ""
               FOR i := 1 TO LEN(aOpsk)
                  IF aOpsk[i,FLD_TYPE] == "N"
                     IF aOpsk[i,FLD_COUN] > 0
                        cPrnl += TRANSFORM((aOpsk[i,FLD_TOTA]/aOpsk[i,FLD_COUN]),aOpsk[i,FLD_PICT])
                     ELSE
                        cPrnl += SPACE(aOpsk[i,FLD_LENG])
                     ENDIF
                  ELSE
                     cPrnl += SPACE(aOpsk[i,FLD_LENG])
                  ENDIF
                  cPrnl += SPACE(nCspa)
               NEXT
               IF cLanType() == "A"
                  cPrnl := STRTRAN(cPrnl,SPACE(LEN("Gemiddeldes:")),"Gemiddeldes:",1,1)
               ELSE
                  cPrnl := STRTRAN(cPrnl,SPACE(LEN("Averages:")),"Averages:",1,1)
               ENDIF
               @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

               // Totals
               cPrnl := ""
               FOR i := 1 TO LEN(aOpsk)
                  IF aOpsk[i,FLD_TYPE] == "N"
                     IF aOpsk[i,FLD_TOTA] > 0
                        cPrnl += TRANSFORM(aOpsk[i,FLD_TOTA],aOpsk[i,FLD_PICT])
                     ELSE
                        cPrnl += SPACE(aOpsk[i,FLD_LENG])
                     ENDIF
                  ELSE
                     cPrnl += SPACE(aOpsk[i,FLD_LENG])
                  ENDIF
                  cPrnl += SPACE(nCspa)
               NEXT
               IF cLanType() == "A"
                  cPrnl := STRTRAN(cPrnl,SPACE(LEN("Totale:")),"Totale:",1,1)
               ELSE
                  cPrnl := STRTRAN(cPrnl,SPACE(LEN("Totals:")),"Totals:",1,1)
               ENDIF
               @PROW()+1,1 SAY LEFT(cPrnl,nWidt)

            ENDIF

            // Bottom line
            @PROW()+1, 1 SAY REPLICATE("=",nWidt)
            @PROW()+1, 1 SAY cAppName()
            fPrnEjec()
            //fPrnOff()
            nBlad++

         ENDIF

      ENDDO
      fPrnOff()
      fPrnOff()

      DBGOTO (nReko)

   END

   // Reset
   fARestScr(aCscr)

RETURN lRetu


