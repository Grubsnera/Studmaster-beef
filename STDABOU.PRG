//STDABOU.PRG
//Program om stelselinligting te vertoon
//Kopiereg (c) 1993 A van Rensburg
//07-02-93 04:53am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
PROCEDURE stdabou(cBood)

   //Verklaar
   local nBoxc := 0

   //Waardes
   cBood := if(cBood==NIL,cAppName(),cBood)

   //Skerm
    if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
    else
        fScrOpsk( , "Option "+cOption())
    endif

   if cLanType() == "A"
      nBoxc := fBoxCent(7,space(60),12,"Omtrent "+cBood)
      @ 8,nBoxc say "Weergawe.......... "+cAppName()
      @ 9,nBoxc say "Reeksnommer....... "+cReeNomm()
      @10,nBoxc say "Bedryfstelsel..... Windows Vista"
      @11,nBoxc say "Ontwikkelingstaal. CA-Clipper 5.2e"
      @12,nBoxc say "Ontwikkel deur.... Agricultural Data Control"
      @13,nBoxc say "Kontakadres....... Posbus 11094, Riverwalk, 2538."
      @14,nBoxc say "Telefoonnommer.... "+cOwnFone()
      @15,nBoxc say "Faksnommer........ "+cOwnFax()
      @16,nBoxc say "Epos.............. help@studmaster.com"
      @17,nBoxc say "Webtuiste......... http://www.stoetmeester.co.za"
   else
      nBoxc := fBoxCent(7,space(60),12,"About "+cBood)
      @ 8,nBoxc say "Version............... "+cAppName()
      @ 9,nBoxc say "Serial number......... "+cReeNomm()
      @10,nBoxc say "Operating system...... Windows Vista"
      @11,nBoxc say "Developement language. CA-Clipper 5.2e"
      @12,nBoxc say "Developed by.......... Agricultural Data Control"
      @13,nBoxc say "Address............... P.O. Box 11094, Riverwalk, 2538."
      @14,nBoxc say "Telephone number...... "+cOwnFone()
      @15,nBoxc say "Fax number............ "+cOwnFax()
      @16,nBoxc say "Email................. help@studmaster.com"
      @17,nBoxc say "Web................... http://www.studmaster.co.za"
   endif
   fScrWait(24)

   //Herstel

return
