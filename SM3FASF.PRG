//SM3FASF.PRG
//Program om fase d leer voor te berei
//Kopiereg (C) 1992 A van Rensburg
//04-20-93 12:21pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3fasf

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local cData := ""
   local cFasf := cDd()+"fasd.dbf"
   local cFasg := ""
   local nCh   := 1
   local cMemo := cDd()+"sm3fasf.mem"
   private mFasg := ""

   //Skerm
   //Open dataleers
   if cLanType() == "A"
		fScrOpsk(,"Opsie "+cOption())
		fScrWbood( 24, "Datalˆers word geopen" )
   else
		fScrOpsk(,"Option "+cOption())
      fScrWbood( 24, "Data files being opened" )
   endif

   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      restscreen(0,0,24,79,cCscr)
      return cFasg
   endif

   //Vra die indeksgroep, groep of seleksiegroep
   nCh := fNewMenu(nCh,"SM3FASF")
	cOption(nCh)

   //Die keuses
   do case
      case nCh == 1
         //Fasegroep
         //Kry die fasegroep
         cFasg := sm3fasg(4)
         if len(trim(cFasg)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen fasegroep is gekies nie!")
            else
               fScrWait(24,"No phase group was selected!")
            endif
            cFasg := ""
            restscreen(0,0,24,79,cCscr)
            return cFasg
         endif
         //Kyk of daar wel diere is vir die indeksgroep
         select SM3DATA
         set order to 2
         seek cFasg
         copy to (cFasf) fields ;
            idnr,;                               //Id nommer
            gemspeeni,;                          //Moer gem speenindeks
            kalfbnr,;                            //Waarskuwings
            mas365,;                             //Toename
            gdo365,;                             //Dae verskil gdo ouderdom
            oud540,;                             //Gdo ouderdom
            gma540,;                             //Gdo gekorrigeerde massa
            ind540,;                             //Indeks vir sorteer
            oud205,;                             //Dae sedert vorige weging
            mas205,;                             //Massa toename afname sedert vorige weging
            kleiber;                             //gdt vanaf vorige weging
            while SM3DATA->fasekode == cFasg
            set order to 1

      case nCh == 2
         //Groep
         cFasg := sm3groe()
         if len(cFasg) > 0
            //Skep leer met name van diere om te weeg
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
            else
               fScrBood(24,"Calves qualifying with the group requirements being sorted.")
            endif
            copy to (cFasf) fields ;
               idnr,;                         //Id nommer
               gemspeeni,;                    //Moer gem speenindeks
               kalfbnr,;                      //Waarskuwings
               mas365,;                       //Toename
               gdo365,;                       //Dae verskil gdo ouderdom
               oud540,;                       //Gdo ouderdom
               gma540,;                       //Gdo gekorrigeerde massa
               ind540,;                       //Indeks vir sorteer
               oud205,;                       //Dae sedert vorige weging
               mas205,;                       //Massa toename afname sedert vorige weging
               kleiber;                       //gdt vanaf vorige weging
               for &cFasg
               cFasg := "GROEP"
            else
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No group selection requirements have been specified!")
               endif
               restscreen(0,0,24,79,cCscr)
               return cFasg
            endif

      case nCh == 3
         //Seleksiegroep
         cFasg := sm3selg()
         if len(cFasg) > 0
            //Skep leer met name van diere om te weeg
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
            else
               fScrBood(24,"Calves qualifying with the group requirements being sorted.")
            endif
            copy to (cfasf) fields ;
               idnr,;                      //Id nommer
               gemspeeni,;                 //Moer gem speenindeks
               kalfbnr,;                   //Waarskuwings
               mas365,;                    //Toename
               gdo365,;                    //Dae verskil gdo ouderdom
               oud540,;                    //Gdo ouderdom
               gma540,;                    //Gdo gekorrigeerde massa
               ind540,;                    //Indeks vir sorteer
               oud205,;                    //Dae sedert vorige weging
               mas205,;                    //Massa toename afname sedert vorige weging
               kleiber;                    //gdt vanaf vorige weging
               for &cFasg
               cFasg := "SELEKSIEGROEP"
            else
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No selection group requirements have been specified!")
               endif
               restscreen(0,0,24,79,cCscr)
               return cFasg
            endif
         otherwise
            if file(cMemo)
               restore from (cMemo) additive
            endif
            cFasg := mFasg
   endcase

   //Stoor memo
   mFasg := cFasg
   save all like m* to (cMemo)

   //Herstel
   fTClose(cData)
   restscreen(0,0,24,79,cCscr)

return cFasg
