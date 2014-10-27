/*
MiniC.l : Toy C/C++ scanner, converting to Unicode
Copyright (c) December 2007, Mihai Nita
*/

%{

#include <string.h>
#include <io.h>
#include "FixAPI.h"

#ifdef __cplusplus
	#define my_yy_input yyinput
#else
	#define my_yy_input input
#endif

const char *szFileIn = "<stdin>";
const char *szTextGen = "_T(%s)";

%}

ID       [_A-Za-z][_A-Za-z0-9]*
SPACE    [ \t\n\r\v\f]
XNUMBER   0x[0-9A-Fa-f]+
NUMBER   [0-9]+
STRING   "\""(\\.|\\\n|\\\r|[^\\"])*"\""
CHAR     "'"(\\.|\\\n|\\\r|[^\\'])"'"
GTEXT	{STRING}|{CHAR}

%x CMTSTATE

%%

"#"{SPACE}*"include"{SPACE}+"<".*">"	|
"#"{SPACE}*"include"{SPACE}+{STRING}	|
"extern"{SPACE}+"\"C\""		            ECHO;

{GTEXT}	{
	if( isSuspectExpliciteAPI( yytext ) )
		fprintf( stderr, "%s(%d) : warning ToUnicode: check if explicite A/W API call: %s\n", szFileIn, yylineno, yytext );
	fprintf( yyout, szTextGen, yytext );
}

L({GTEXT})                                        |
(_T|TEXT){SPACE}*\({SPACE}*{GTEXT}{SPACE}*\)	  ECHO;

{ID}	{
	int toCheck;
	fprintf( yyout, "%s", fixBadApi( yytext, &toCheck ) );
	if( toCheck )
		fprintf( stderr, "%s(%d) : warning ToUnicode: check API usage : %s\n", szFileIn, yylineno, yytext );
}

{NUMBER} ECHO;
{XNUMBER} ECHO;

{SPACE} ECHO;

"/*" {
	ECHO;
	BEGIN CMTSTATE;
}
<CMTSTATE>.    |
<CMTSTATE>\n   ECHO;

<CMTSTATE>"*/" {
	ECHO;
	BEGIN INITIAL;
}

"//".*"\n"	ECHO; /* line comment */

.	        ECHO;

%%

int yywrap( void ) {
	return 1;
}

int main( int argc, char *argv[] ) {
	++argv, --argc;  /* skip over program name */

	if( !argc ) {
		fprintf( stderr, "Usage: MiniC [-<option>] [<inputfile>] [<outputFile>]\n" );
		fprintf( stderr, "      option:  -T or -TEXT" );
		return 1;
	}

	if( !strcmp( argv[0], "-TEXT" ) ) {
		++argv, --argc;
		szTextGen = "TEXT(%s)";
	}
	if( !strcmp( argv[0], "-T" ) ) {
		++argv, --argc;
		szTextGen = "_T(%s)";
	}

	initApiTables();

	if( argc > 0 ) {
		szFileIn = argv[0];
		yyin = fopen( szFileIn, "r" );
	}
	else
		yyin = stdin;

	if( argc > 1 )
		yyout = fopen( argv[1], "w" );
	else
		yyout = stdout;

	yylex();

	fclose( yyout );
	fclose( yyin );
}
