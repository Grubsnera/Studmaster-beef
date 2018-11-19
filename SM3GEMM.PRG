//SM3GEMM.PRG
//Program om submenu te vertoon
//Kopiereg (c) 1991 A van Rensburg
//15:55 02 Oct,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/****************************************************************************/
FUNCTION sm3gemm

   	LOCAL nCh    := 1
	local aCscr  := {}

    if cLanType() == "A"
        fScrOpsk( 1, "Opsie "+cOption())
    else
        fScrOpsk( 1, "Option "+cOption())
    endif

   	do while TRUE
      	//Sluit alle .dbf leers
      	dbcloseall()

      	// Vertoon hulpskerm
      	if cLanType() == "A"
         	fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die menu." )
      	else
         	fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the menu." )
      	endif

      	// Kry opsienommer
      	nCh := fNewMenu( nCh, "SM3GEMM" )
	  	cOption(nCh)
      	aCscr := fASaveScr()

        do case
            case nCh = 1
               	//Een dier
               	fEen()

            case nCh = 2
               	//Groep
               	fGroep()

            case nCh = 3
               	//Seleksiegroep
               	fSelGroep()

            case nCh = 4
               	//Almal
               	fAlmal()

            otherwise
               	// Exit to hoofmenu
	        	cOption(-1)
            	exit

        endcase

      	//Herstel menu
      	fARestScr(aCscr)
	  	cOption(-1)
   	enddo

return NIL

/****************************************************************************/
STATIC FUNCTION fEen

   //Funksie om een dier se gemiddeldes te bereken

   //Verklaar
   local cData := ""
   local lLoop := .t.
   local nBoxc := 0
   local cIdnr := space(12)

   //Skerm
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   //Open lˆer
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   if left(cData,1) == "f"
      return NIL
   endif

   lLoop := .t.
   do while lLoop

      //Vra die dier se nommer
      nBoxc := fBoxCent(11,space(33),3)
      cIdnr := sm3idnr(,12,nBoxc)
      do case
         case left(cIdnr,9) == "CANCELLED"
            lLoop := .f.
         case left(cIdnr,3) == "NOT"
            lLoop := .f.
      endcase

      //Bereken
      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Nageslag gemiddeldes word bereken")
      else
         fScrWbood(24,"Progeny averages being calculated")
      endif
      sm3koei(cIdnr)

   enddo

   //Herstel
   fTClose(cData)
return NIL

/****************************************************************************/
STATIC FUNCTION fGroep

   //Funksie om 'n groep se gemiddeldes te bereken

   //Verklaar
   local   cData := ""
   local   nTell := 1
   local   nReko := 1
   private cTest := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   cTest := sm3groe()
   if len(trim(cTest)) == 0
      if cLanType() == "A"
         fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
      else
         fScrWait(24,"No group selection requirements have been specified!")
      endif
      return NIL
   endif

   //Open lˆer
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   if left(cData,1) == "f"
      return NIL
   endif
   nReko := lastrec()

   //Skerm
   fScrBood(23)

   do while !eof()

      //Skerm
      if cLanType() == "A"
         fScrBood(24,"Nageslag gemiddeldes word bereken. ("+fPercent(nTell,nReko)+"% Voltooi)")
      else
         fScrBood(24,"Progeny averages being calculated. ("+fPercent(nTell,nReko)+"% Completed)")
      endif

      //Bereken
      if &cTest
         sm3koei(SM3DATA->idnr)
      endif

      //Escape
      if inkey() == K_ESC
         go bottom
         skip
      endif

      //Volgende dier
      nTell++
      skip

   enddo

   //Herstel
   fTClose(cData)
return NIL

/****************************************************************************/
STATIC FUNCTION fSelgroep

   //Funksie om 'n seleksiegroep se gemiddeldes te bereken

   //Verklaar
   local   cData := ""
   local   nTell := 1
   local   nReko := 1
   private cTest := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   cTest := sm3selg()
   if len(trim(cTest)) == 0
      if cLanType() == "A"
         fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
      else
         fScrWait(24,"No selection group requirements have been specified!")
      endif
      return NIL
   endif

   //Open lˆer
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   if left(cData,1) == "f"
      return NIL
   endif
   nReko := lastrec()

   //Skerm
   fScrBood(23)

   do while !eof()

      //Skerm
      if cLanType() == "A"
         fScrBood(24,"Nageslag gemiddeldes word bereken. ("+fPercent(nTell,nReko)+"% Voltooi)")
      else
         fScrBood(24,"Progeny averages being calculated. ("+fPercent(nTell,nReko)+"% Completed)")
      endif

      //Bereken
      if &cTest
         sm3koei(SM3DATA->idnr)
      endif

      //Escape
      if inkey() == K_ESC
         go bottom
         skip
      endif

      //Volgende dier
      nTell++
      skip

   enddo

   //Herstel
   fTClose(cData)
return NIL

/****************************************************************************/
STATIC FUNCTION fAlmal

   //Funksie om alle diere se gemiddeldes te bereken

   //Verklaar
   local cData := ""
   local nTell := 1
   local nReko := 1

   //Skerm
   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption())
   else
      fScrOpsk( ,"Option "+cOption())
   endif

   //Open lˆer
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cData := fTOpen(cDd(),"sm3data",,,,.t.,.f.)
   if left(cData,1) == "f"
      return NIL
   endif
   nReko := lastrec()

   //Skerm
   fScrBood(23)

   do while !eof()

      //Skerm
      if cLanType() == "A"
         fScrBood(24,"Nageslag gemiddeldes word bereken. ("+fPercent(nTell,nReko)+"% Voltooi)")
      else
         fScrBood(24,"Progeny averages being calculated. ("+fPercent(nTell,nReko)+"% Completed)")
      endif

      //Bereken
      sm3koei(SM3DATA->idnr)

      //Escape
      if inkey() == K_ESC
         go bottom
         skip
      endif

      //Volgende dier
      nTell++
      skip

   enddo

   //Herstel
   fTClose(cData)

return NIL

