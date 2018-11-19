/***
*	Errorsys.prg
*	Standard Clipper 5.0 error handler
*	Copyright (c) 1990 Nantucket Corp.  All rights reserved.
* adapted by Ian on 5/5/93 using a lot of Clipper Tools 3 + OverLay()
*	Compile:  /m/n/w
*
* PRIVATE VARIABLES to be DECLARED on SYSTEMS
*  cAppName() = User Name
*  dAppDate()     = Program System Date
*/
****************************************************************************
#include "ERROR.CH"
#include "INKEY.CH"
#include "SET.CH"
****************************************************************************

// put messages to STDERR
#command ? <list,...>	=>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>	=>  OutErr(<list>)
#command RETRY =>  RETURN (.F.)                  // Retry the Operation
#command RESUME =>  RETURN (.F.)                 // Rather go to a menu
#command GIVE(0) => RETURN (0)
***************************************************************************

// used below
#define NTRIM(n)		( LTrim(Str(n)) )

***************************************************************************

/***
*	ErrorSys()
*
*	Note:  automatically executes at startup
*/

proc ErrorSys()

	ErrorBlock( {|e| DefError(e)} )

RETURN

***************************************************************************
/***
*	DefError()
*/
STATIC FUNC DEFERROR(e)

	LOCAL eI, eL, cMessage, aOptions, nChoice, zMessage, cRet, mLCount := 1
	LOCAL cDosPath, cDosPLineLen, nTokenCounter, cVar, nLCounter

	Set Prin Off
	Set Cons On
	Set Devi To Scree
	// by default, division by zero yields zero
	If ( e:genCode == EG_ZERODIV )
		GIVE(0)
	End

	// for network open error, set NETERR() and subsystem default
	if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
		NetErr(.t.)
		RESUME
	end

	// for lock error during APPEND BLANK, set NETERR() and subsystem default
	if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
		NetErr(.t.)
		RESUME
	end

	// build error message
	cMessage := ErrorMessage(e)

	// build options array
	aOptions := { " Print Error on Printer ", " < Enter key > return " }

	// Display all the calling routines
	zMessage:="[ ERROR WARNING ! ]"

	@ 1,0 clear to 9,79
	@ 1,0 to 9,79
	@ 1,2 say zMessage
	eI := 2
	eL := 5
   @ 2,1 say PADC(iif(cLanType()="A","Indien u hierdie fout aan ons wil raporteer ;","Should you wish to report this error to us ;"),78)
   @ 3,1 say PADC(iif(cLanType()="A","Skakel u drukker aan,","Please bring your printer on line, then"),78)
   @ 4,1 say PADC(iif(cLanType()="A","Neem asb. die Print Error opsie","Select the Print Error option"),78)
   @ 5,1 say PADC(iif(cLanType()="A","en FAKS die VERSLAG deur na ons","and FAX the REPORT to us"),78)
   @ 6,1 say PADC(iif(cLanType()="A"," OF "," OR "),78)
   @ 7,1 say PADC(iif(cLanType()="A","Druk die 'Enter' sleutel om aan te gaan ...","Strike the 'Enter' key to continue ..."),78)

	// put up alert box
	nChoice := 0
	while ( nChoice == 0 )

		if ( Empty(e:osCode) )
			nChoice := Alert( cMessage, aOptions )
		else
			nChoice := Alert( cMessage + ;
			";(DOS Error " + NTRIM(e:osCode) + ")", ;
			aOptions )
		end

		if ( nChoice == NIL ) .or. (nChoice == 2 )
			exit
		else

			Set Devi To Prin
			mLCount = 2
			@ mLCount,1 say "PLEASE FAX to either"
			mLCount := mLCount + 2
         @ mLCount,10 say "JOHANNESBURG (011) 266-5705"
			mLCount = mLCount + 2
         @ mLCount,1 say "FROM .....: " + cAppName()
			mLCount++
         @ mLCount,1 say "as at " + DTOC(dAppDate()) + " --- System date " + DTOC(DATE())
			mLCount++
			TOKENINIT(@cMessage,";",1)
			do while !TOKENEND()
				mLCount++
				cVar := TOKENNEXT(cMessage)
				@ mLCount,1 say cVar
			enddo
			@ mLCount,1 say Repl("_",78)
			mLCount++
			If !( Empty(e:OsCode) )
				@ mLCount,1 say "DOS Error " + NTRIM(e:osCode)
			Endif
			while ( !Empty(ProcName(eI)) )
				mLCount++
				@ mLCount,1 say "Called from "+Trim(ProcName(eI))+"  Line "+;
				"(" + NTRIM(ProcLine(eI)) + ")"
				eI++
			end
			@ mLCount,1 say Repl("_",78)

			mLCount := mLCount + 2
			@ mLCount,1 say "Running EXE ...........: " + EXENAME()
			mLCount++
			@ mLCount,1 say "Date and Time Stamp ...: " + DTOC(FILEDATE(EXENAME())) + " -- " + FILETIME(EXENAME())
			mLCount++

			cDosPath := GETENV("PATH")
			@ mLCount,1 say "DOS Path settings .....: "
			cDosPLineLen := Len(cDosPath)
			nTokenCounter := CEILING(cDosPLineLen/70)
			cVar := ARRAY(nTokenCounter)
			nLCounter := 1
			For q := 1 To nTokenCounter
				cVar[q] = Subs(cDosPath,nLCounter,70)
				nLCounter := nLCounter + 70
			Next
			mLCount++
			For q := 1 To nTokenCounter
				@ mLCount,5 say cVar[q]
				mLCount++
			Next
			mLCount++

			@ mLCount,1 say "Any Clipper Settings ..: " + GETENV("CLIPPER")
			mLCount++
			@ mLCount,1 say "Total Disk Space ......: " + LTrim(Str(DISKTOTAL(),13,0)) + " Bytes"
			mLCount++
			@ mLCount,1 say "Disk Space Free .......: " + LTrim(Str(DISKFREE(),13,0)) + " Bytes"
			mLCount++
			@ mLCount,1 say "Drive Type ............: " + LTrim(Str(DRIVETYPE()))
			mLCount++
			@ mLCount,1 say "Disk Type .............: " + LTrim(Str(DISKTYPE()))
			mLCount++
			@ mLCount,1 say "Disk Serial No ........: " + LTrim(Str(VOLSERIAL()))
			mLCount++
			@ mLCount,1 say "Total Conventional Mem : " + LTrim(Str(MEMSIZE(.F.))) + "KB"
			mLCount++
			@ mLCount,1 say "Available Memory ......: " + LTRim(Str(MEMORY(0),6,0)) + "KB"
			mLCount++
			@ mLCount,1 say "File Handles Available : " + LTrim(Str(FILESFREE()))
			mLCount++
			@ mLCount,1 say "Max File Handels Set ..: " + LTrim(Str(FILESMAX()))
			mLCount++
			@ mLCount,1 say "Operating System Vers .: " + OSVER()
			mLCount++
			@ mLCount,1 say "PC Type ...............: " + LTrim(Str(PCTYPE()))
			mLCount++
			@ mLCount,1 say "CPU Type ..............: " + LTrim(Str(CPUTYPE()))
			mLCount++
			@ mLCount,1 say "Current Active Dir ....: " + O_CurPath()
			mLCount++
			@ mLCount,1 say "Error Block Specs .....: Args -> "
			@ mLCount,pCol() + 1 say e:args
			mLCount++
			@ mLCount,1 say "                   canDefault -> "
			@ mLCount,pCol() + 1 say e:canDefault
			mLCount++
			@ mLCount,1 say "                     canRetry -> "
			@ mLCount,pCol() + 1 say e:canRetry
			mLCount++
			@ mLCount,1 say "                canSubstitute -> "
			@ mLCount,pCol() + 1 say e:canSubstitute
			mLCount++
			@ mLCount,1 say "                        Cargo -> "
			@ mLCount,pCol() + 1 say e:Cargo
			mLCount++
			@ mLCount,1 say "                  Description -> "
			@ mLCount,pCol() + 1 say e:description
			mLCount++
			@ mLCount,1 say "                     FileName -> "
			@ mLCount,pCol() + 1 say e:fileName
			mLCount++
			@ mLCount,1 say "                      genCode -> "
			@ mLCount,pCol() + 1 say e:genCode
			mLCount++
			@ mLCount,1 say "                    operation -> "
			@ mLCount,pCol() + 1 say e:operation
			mLCount++
			@ mLCount,1 say "                       osCode -> "
			@ mLCount,pCol() + 1 say e:osCode
			mLCount++
			@ mLCount,1 say "                     Severity -> "
			@ mLCount,pCol() + 1 say e:Severity
			mLCount++
			@ mLCount,1 say "                      subCode -> "
			@ mLCount,pCol() + 1 say e:subCode
			mLCount++
			@ mLCount,1 say "                    subSystem -> "
			@ mLCount,pCol() + 1 say e:subSystem
			mLCount++
			@ mLCount,1 say "                        Tries -> "
			@ mLCount,pCol() + 1 say e:Tries

			@ mLCount,1 say Repl("_",78)
			mLCount := mLCount + 2
         @ mLCount,1 say iif(cLanType()="A","U terug FAKS Nr. asb. ..:" ,"Your return FAX No. please .: " ) + Repl("_",30)
			mLCount := mLCount + 2
         @ mLCount,1 say iif(cLanType()="A","Versender se naam asb. .:" ,"Senders name please ........: " ) + Repl("_",30)
			mLCount := mLCount + 2
         @ mLCount,1 say iif(cLanType()="A","                Adres ..:" ,"            Address ........: " ) + Repl("_",30)
			mLCount := mLCount + 2
         @ mLCount,1 say iif(cLanType()="A","                Adres ..:" ,"            Address ........: " ) + Repl("_",30)

         fPrnEjec()
			Set Devi to Scree

		endif
	enddo

	break

RETURN (.F.)

****************************************************************************
/*************************
*	ErrorMessage()
**************************/
STATIC FUNC ERRORMESSAGE(e)

	LOCAL cMessage


	// start error message
	cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )


	// add subsystem name if available
	if ( ValType(e:subsystem) == "C" )
		do case
		case e:subsystem()="BASE"
			cMessage+="VARIABLE-BASE"
		case e:subsystem()="DBFNTX"
			cMessage+="DATA-DBFNTX"
		case e:subsystem()="TERM"
			cMessage+="PRINTER-TERM"
		endcase

	else
		cMessage += "???"
	end

	// add subsystem's error code if available
	if ( ValType(e:subCode) == "N" )
		cMessage += ("(" + NTRIM(e:subCode))+")"
	else
		cMessage += "(???)"
	end

	// add error description if available
	if ( ValType(e:description) == "C" )
		cMessage += ("  " + e:description)
	end

	// add either filename or operation
	if ( !Empty(e:filename) )
		cMessage += (": " + e:filename)

	elseif ( !Empty(e:operation) )
		cMessage += (": " + e:operation)

	end
	do case
	case e:subsystem()="TERM"
		cMessage+=";Please make sure the printer is switched on"
	case !empty(e:osCode) .and. e:osCode=4
		cMessage+=";Edit the CONFIG.SYS please"
	case !empty(e:osCode) .and. e:osCode=2
		cMessage+=";This data file is NOT available"
	case !empty(e:osCode) .and. e:osCode=5
		cMessage+=";Access denied"
	case !empty(e:osCode) .and. e:osCode=8
		cMessage+=";Insufficient memory"
	case !empty(e:osCode) .and. e:osCode=11
		cMessage+=";Invalid format"
	case !empty(e:osCode) .and. e:osCode=19
		cMessage+=";Cannot write on WRITE PROTECTED Disk"
	case !empty(e:osCode) .and. e:osCode=21
		cMessage+=";Drive not ready"
	case !empty(e:osCode) .and. e:osCode=23
		cMessage+=";Data Error (CRC)"
	case !empty(e:osCode) .and. e:osCode=28
		cMessage+=";Printer out of Paper, Chaps!"
	endcase

RETURN (cMessage)
****************************************************************************
