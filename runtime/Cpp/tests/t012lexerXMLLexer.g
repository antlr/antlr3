lexer grammar t012lexerXMLLexer;
options {
  language =Cpp;
}

@lexer::includes
{
#include "UserTestTraits.hpp"
#include <iostream>
}
@lexer::namespace
{ Antlr3Test }

@lexer::context {
ImplTraits::StringStreamType outbuf;

void output(const char* line)
{
    outbuf << line << "\r\n";
}

void output(const char* line1, const char *line2)
{
    outbuf << line1 << line2 << "\r\n";
}

void output(const char* line1, ImplTraits::StringType const& line2)
{
    outbuf << line1 << line2 << "\r\n";
}

void appendArribute(const char* prefix, ImplTraits::StringType const& name, ImplTraits::StringType const& value)
{
    outbuf << prefix << name << '=' << value << "\r\n";
}

void appendString(const char* name, ImplTraits::StringType const& value)
{
    outbuf << name << '"' << value << '"' << "\r\n";
}

}
DOCUMENT
    :  XMLDECL? WS? DOCTYPE? WS? ELEMENT WS? 
    ;

fragment DOCTYPE
    :
        '<!DOCTYPE' WS rootElementName=GENERIC_ID 
        { output("ROOTELEMENT: ", $rootElementName.text);}
        WS
        ( 
            ( 'SYSTEM' WS sys1=VALUE
                {output("SYSTEM: ", $sys1.text);}
                
            | 'PUBLIC' WS pub=VALUE WS sys2=VALUE
                {output("PUBLIC: ", $pub.text);}
                {output("SYSTEM: ", $sys2.text);}   
            )
            ( WS )?
        )?
        ( dtd=INTERNAL_DTD
            {output("INTERNAL DTD: ", $dtd.text);}
        )?
		'>'
	;

fragment INTERNAL_DTD : '[' (options {greedy=false;} : .)* ']' ;

fragment PI :
        '<?' target=GENERIC_ID WS? 
          {output("PI: ", $target.text);}
        ( ATTRIBUTE WS? )*  '?>'
	;

fragment XMLDECL :
        '<?' ('x'|'X') ('m'|'M') ('l'|'L') WS? 
          {output("XML declaration");}
        ( ATTRIBUTE WS? )*  '?>'
	;


fragment ELEMENT
    : ( START_TAG
            (ELEMENT
            | t=PCDATA
                {appendString("PCDATA: ", $t.text);}
            | t=CDATA
                {appendString("CDATA: ", $t.text);}
            | t=COMMENT
                {appendString("Comment: ", $t.text);}
            | pi=PI
            )*
            END_TAG
        | EMPTY_ELEMENT
        )
    ;

fragment START_TAG 
    : '<' WS? name=GENERIC_ID WS?
          {output("Start Tag: ", $name.text);}
        ( ATTRIBUTE WS? )* '>'
    ;

fragment EMPTY_ELEMENT 
    : '<' WS? name=GENERIC_ID WS?
          {output("Empty Element: ", $name.text);}
        ( ATTRIBUTE WS? )* '/>'
    ;

fragment ATTRIBUTE 
    : name=GENERIC_ID WS? '=' WS? value=VALUE
        {appendArribute("Attr: ", $name.text, $value.text);}
    ;

fragment END_TAG 
    : '</' WS? name=GENERIC_ID WS? '>'
        {output("End Tag: ", $name.text);}
    ;

fragment COMMENT
	:	'<!--' (options {greedy=false;} : .)* '-->'
	;

fragment CDATA
	:	'<![CDATA[' (options {greedy=false;} : .)* ']]>'
	;

fragment PCDATA : (~'<')+ ; 

fragment VALUE : 
        ( '\"' (~'\"')* '\"'
        | '\'' (~'\'')* '\''
        )
	;

fragment GENERIC_ID 
    : ( LETTER | '_' | ':') 
        ( options {greedy=true;} : LETTER | '0'..'9' | '.' | '-' | '_' | ':' )*
	;

fragment LETTER
	: 'a'..'z' 
	| 'A'..'Z'
	;

fragment WS  :
        (   ' '
        |   '\t'
        |  ( '\n'
            |	'\r\n'
            |	'\r'
            )
        )+
    ;    

