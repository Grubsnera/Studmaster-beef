//ERRORSYS.PRG
//Program to display error messages
//A van Rensburg
//05-25-93 11:19am

#include "error.ch"
//Put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)
//Used below
#define ntrim(n)                (ltrim(str(n)))

/****************************************************************************/
PROCEDURE ErrorSys()
   // Note - automatically runs at startup
   errorblock({|e|deferror(e)})
   return

/****************************************************************************/
STATIC FUNCTION deferror(e)

   //Verklaar
   local i := 1
   local cMessage := ""
   local aOptions := {}
   local nChoice := 1
   local cCscr := ""

   //Printer disconnect
   set print off
   set device to screen
   set cons on

   //By default, division by zero yields zero
   if e:genCode == EG_ZERODIV
      return 0
   endif

   //By default, data width yields zero
   if e:genCode == EG_DATAWIDTH
      return .f.
   endif

   //For network open error, set NETERR() and subsystem default
   if e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault
      NetErr(.t.)
      return .f.                                 // NOTE
   endif

   //For lock error during APPEND BLANK, set NETERR() and subsystem default
   if e:genCode == EG_APPENDLOCK .and. e:canDefault
      NetErr(.t.)
      return .f.                                 // NOTE
   endif

   //Warn if printer error
   if e:genCode == EG_PRINT .and. e:canRetry
      cCscr := savescreen(0,0,24,79)
      if alert("Print Error",{"Retry","Quit"}) == 1
         restscreen(0,0,24,79,cCscr)
         set print on
         set device to print
         set cons off
         return .t.
      endif
   endif

   //Build error message
   if cLanType() == "A"
      cMessage := padr(" "+errormessage(e),50)
      cMessage += padr(";Indien hierdie fout herhaaldelik",50)
      cMessage += padr(";voorkom, volg ondergenoemde stappe asseblief!",50)
      cMessage += padr("; 1. Skakel drukker aan.",50)
      cMessage += padr("; 2. Kies Druk opsie.",50)
      cMessage += padr("; 3. Faks drukstuk aan "+cOwnFax()+".",50)
      aOptions := {"Menu","Druk","Tekslˆer","Quit"}
   else
      cMessage := padr(" "+errormessage(e),50)
      cMessage += padr(";If this error should occur repeatedly",50)
      cMessage += padr(";please follow the following steps!",50)
      cMessage += padr("; 1. Switch printer on.",50)
      cMessage += padr("; 2. Choose Print option.",50)
      cMessage += padr("; 3. Fax printout to "+cOwnFax()+".",50)
      aOptions := {"Menu","Print","Text file","Quit"}
   endif

   //Put up alert box
   nChoice := alert(cMessage,aOptions)

   //@24,0 say nChoice
   //inkey(0)

   do case
      case nChoice == 2
         //Druk
         fErrTxt(e,"Print")
         break(e)

      case nChoice == 3
         //File
         fErrTxt(e,"Text")
         if cLanType() == "A"
            alert("'n Lˆer met die naam ERROR.TXT is in die;"+dirname()+";subgids geskep wat gefaks kan word met 'n fakskaart!")
         else
            alert("A file with the name ERROR.TXT has been created in the;"+dirname()+";subdirectory and can be faxed with the fax card!")
         endif
         break(e)

      case nChoice == 4
         //Quit

         //Clear screen
         clear screen

         //Display message and traceback
         cMessage := errormessage(e)
         if !empty(e:osCode)
            cMessage += " (DOS Error " + ntrim(e:osCode) + ") "
         end

         ? cMessage
         i := 1
         while ( !empty(procname(i)) )
            if cLanType() == "A"
               ? "Prosedure "+trim(procname(i))+" ("+ntrim(procline(i))+")"
            else
               ? "Procedure "+trim(procname(i))+" ("+ntrim(procline(i))+")"
            endif
            i++
         end

         // wait for keypress
         ? " "
         ? "Druk enige sleutel . . . "
         ? "Press any key . . . "
         inkey(0)

         // stel terug na normaal
         break(e)

      otherwise
         //Break
         break(e)

   endcase

   //Herstel
   return NIL

/****************************************************************************/
STATIC FUNCTION ErrorMessage(e)

   //Verklaar
   local cMessage

   //Start error message
   if cLanType() == "A"
      cMessage := if(e:severity>ES_WARNING,"Fout! - ","Waarskuwing! - ")
   else
      cMessage := if(e:severity>ES_WARNING,"Error! - ","Warning! - " )
   endif

   //Add subsystem name if available
   if valtype(e:subsystem) == "C"
      cMessage += e:subsystem()
   else
      cMessage += "???"
   end

   //Add subsystem's error code if available
   if valtype(e:subCode) == "N"
      cMessage += ("/" + ntrim(e:subCode))
   else
      cMessage += "/???"
   end

   //Add error description if available
   if valtype(e:description) == "C"
      cMessage += ("  " + e:description)
   end


   // add either filename or operation
   if !Empty(e:filename)
      cMessage += (": " + e:filename)
   elseif !Empty(e:operation)
      cMessage += (": " + e:operation)
   end

   return (cMessage)

/****************************************************************************/
STATIC FUNCTION fErrTxt(e,cType)
   //Funksie om leer voor te berei met foutboodskappe

   //Verklaar
   local i := 1
   local cData := ""

   //Maak leer oop
   if upper(cType) == "TEXT"
      set console off
      set device to printer
      set printer to error.txt
   else
      if isprinter()
         set console off
         set device to printer
      endif
   endif

   //Opskrifte
   if cLanType() == "A"
      @prow()  , 0 say trim(cAppName())+" Faks Foutboodskap"
   else
      @prow()  , 0 say trim(cAppName())+" Fax Error Message"
   endif
   @prow()+1, 0 say trim(cGebNaam())+" ("+trim(cReeNomm())+")"
   @prow()+1, 0 say repl("-",80)
   @prow()+2, 0 say "Hardware / Hardeware"
   @prow()+1, 0 say "--------------------"
   if cputype() == 0
      @prow()+1, 0 say "CPU type............ "+"8088"
   elseif cputype() == 1
      @prow()+1, 0 say "CPU type............ "+"8086"
   elseif cputype() == 2
      @prow()+1, 0 say "CPU type............ "+"V20"
   elseif cputype() == 3
      @prow()+1, 0 say "CPU type............ "+"V30"
   elseif cputype() == 4
      @prow()+1, 0 say "CPU type............ "+"80188"
   elseif cputype() == 5
      @prow()+1, 0 say "CPU type............ "+"80186"
   elseif cputype() == 6
      @prow()+1, 0 say "CPU type............ "+"80286"
   elseif cputype() == 7
      @prow()+1, 0 say "CPU type............ "+"80386"
   elseif cputype() == 8
      @prow()+1, 0 say "CPU type............ "+"80486"
   else
      @prow()+1, 0 say "CPU type............ "+"Unknown"
   endif
   @prow()  ,39 say "DOS version......... "+osver()
   @prow()+1, 0 say "Conventional memory. "+ltrim(str(memsize(.f.)))
   @prow()  ,39 say "Available memory.... "+ltrim(str(memory(0)))
   @prow()+1, 0 say "Files command....... "+ltrim(str(numfiles()))
   @prow()  ,39 say "Buffers command..... "+ltrim(str(numbuffers()))
   @prow()+1, 0 say "Files maximum....... "+ltrim(str(filesmax()))
   @prow()  ,39 say "Files free.......... "+ltrim(str(filesfree()))
   @prow()+1, 0 say "Floppy drives....... "+ltrim(str(numdiskf()))
   @prow()  ,39 say "Hard drives......... "+ltrim(str(numdiskh()))
   @prow()+1, 0 say "Logical drives...... "+ltrim(str(numdiskl()))
   @prow()  ,39 say "Volume serial....... "+ltrim(str(volserial()))
   @prow()+1, 0 say "Total space......... "+ltrim(str(disktotal()))
   @prow()  ,39 say "Free space.......... "+ltrim(str(diskfree()))
   @prow()+1, 0 say "Clipper settings.... "+trim(getenv("CLIPPER"))
   @prow()+2, 0 say "Program"
   @prow()+1, 0 say "-------"
   @prow()+1, 0 say "Running exe......... "+exename()
   @prow()+1, 0 say "Data drive.......... "+cDd()
   @prow()+1, 0 say "Version............. "+left(filetime(exename()),5)
   @prow()  ,39 say "Date stamp.......... "+dtoc(filedate(exename()))
   @prow()+1, 0 say "Dos date............ "+dtoc(date())
   @prow()  ,39 say "Program date........ "+dtoc(dAppDate())
   @prow()+2, 0 say "Error / Fout"
   @prow()+1, 0 say "------------"
   @prow()+1, 0 say "Description......... "+e:descriptio
   @prow()+1, 0 say "Subsystem.(code).... "+e:subsystem+" ("+ntrim(e:subcode)+")"
   @prow()+1, 0 say "Filename.(doserr)... "+trim(e:filename)+"("+ntrim(e:oscode)+")"
   @prow()+1, 0 say "Operation........... "+e:operation
   @prow()+1, 0 say "Gencode............. "+ntrim(e:gencode)
   @prow()  ,39 say "Severity............ "+ntrim(e:severity)
   @prow()+1, 0 say "Candefault.......... "+if(e:candefault==.t.,"T","F")
   @prow()  ,39 say "Canretry............ "+if(e:canretry==.t.,"T","F")
   @prow()+1, 0 say "Cansubstitute....... "+if(e:cansubstit==.t.,"T","F")
   @prow()  ,39 say "Arguments........... "
   @prow()  ,39+21 say e:args
   @prow()+2, 0 say "Procedures / Prosedures"
   @prow()+1, 0 say "-----------------------"
   @prow()+1, 0 say ""
   for i = 1 to len(procname())
      cData := procname(i)+"("+ntrim(procline(i))+") "
      if pcol()+len(cData) < 80
         @prow(),pcol() say cData
      else
         @prow()+1, 0 say ""
         @prow(),pcol() say cData
      endif
   next
   @prow()+2, 0 say repl("-",80)
   if cLanType() == "A"
      @prow()+1, 0 say "Faks asseblief hierdie foutboodskap aan "+cOwnFax()
      @prow()+1, 0 say "Ons sal so spoedig moontlik die fout opspoor en terug rapporteer."
      @prow()+2, 0 say "My eie faksnommer vir die antwoord is:_______________________________________"
      @prow()+2, 0 say "  of my eie adres vir die antwoord is:_______________________________________"
      @prow()+2, 0 say "                                     :_______________________________________"
      @prow()+2, 0 say "                                     :_______________________________________"
   else
      @prow()+1, 0 say "Please fax this error message to "+cOwnFax()
      @prow()+1, 0 say "We will sort out the problem as soon as possible and report back."
      @prow()+2, 0 say "My own fax number for the  answer  is:_______________________________________"
      @prow()+2, 0 say " or my own address for the answer  is:_______________________________________"
      @prow()+2, 0 say "                                     :_______________________________________"
      @prow()+2, 0 say "                                     :_______________________________________"
   endif

   // Form Feed
   if upper(cType) == "PRINT"
      fPrnEjec()
   endif

   //Herstel
   set printer to
   set device to screen
   set console on
   return NIL

