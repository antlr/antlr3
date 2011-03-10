#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3/test/functional'

class XMLLexerTest < ANTLR3::Test::Functional
  inline_grammar( <<-'END' )
    lexer grammar XML;
    options { language = Ruby; }
    
    @members {
      include ANTLR3::Test::CaptureOutput
      include ANTLR3::Test::RaiseErrors
      
      def quote(text)
        text = text.gsub(/\"/, '\\"')
        \%("#{ text }")
      end
    }
    
    DOCUMENT
        :  XMLDECL? WS? DOCTYPE? WS? ELEMENT WS? 
        ;
    
    fragment DOCTYPE
        :
            '<!DOCTYPE' WS rootElementName=GENERIC_ID 
            {say("ROOTELEMENT: " + $rootElementName.text)}
            WS
            ( 
                ( 'SYSTEM' WS sys1=VALUE
            {say("SYSTEM: " + $sys1.text)}
                    
                | 'PUBLIC' WS pub=VALUE WS sys2=VALUE
                    {say("PUBLIC: " + $pub.text)}
                    {say("SYSTEM: " + $sys2.text)}   
                )
                ( WS )?
            )?
            ( dtd=INTERNAL_DTD
                {say("INTERNAL DTD: " + $dtd.text)}
            )?
        '>'
      ;
    
    fragment INTERNAL_DTD : '[' (options {greedy=false;} : .)* ']' ;
    
    fragment PI :
            '<?' target=GENERIC_ID WS? 
              {say("PI: " + $target.text)}
            ( ATTRIBUTE WS? )*  '?>'
      ;
    
    fragment XMLDECL :
            '<?' ('x'|'X') ('m'|'M') ('l'|'L') WS? 
              {say("XML declaration")}
            ( ATTRIBUTE WS? )*  '?>'
      ;
    
    
    fragment ELEMENT
        : ( START_TAG
                (ELEMENT
                | t=PCDATA
                    {say("PCDATA: " << quote($t.text))}
                | t=CDATA
                    {say("CDATA: " << quote($t.text))}
                | t=COMMENT
                    {say("Comment: " << quote($t.text))}
                | pi=PI
                )*
                END_TAG
            | EMPTY_ELEMENT
            )
        ;
    
    fragment START_TAG 
        : '<' WS? name=GENERIC_ID WS?
              {say("Start Tag: " + $name.text)}
            ( ATTRIBUTE WS? )* '>'
        ;
    
    fragment EMPTY_ELEMENT 
        : '<' WS? name=GENERIC_ID WS?
              {say("Empty Element: " + $name.text)}
            ( ATTRIBUTE WS? )* '/>'
        ;
    
    fragment ATTRIBUTE 
        : name=GENERIC_ID WS? '=' WS? value=VALUE
            {say("Attr: " + $name.text + " = "+ $value.text)}
        ;
    
    fragment END_TAG 
        : '</' WS? name=GENERIC_ID WS? '>'
            {say("End Tag: " + $name.text)}
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
  END
  
  it "should be valid" do
    lexer = XML::Lexer.new( <<-'END'.fixed_indent( 0 ) )
      <?xml version='1.0'?>
      <!DOCTYPE component [
      <!ELEMENT component (PCDATA|sub)*>
      <!ATTLIST component
                attr CDATA #IMPLIED
                attr2 CDATA #IMPLIED
      >
      <!ELMENT sub EMPTY>
      
      ]>
      <component attr="val'ue" attr2='val"ue'>
      <!-- This is a comment -->
      Text
      <![CDATA[huhu]]>
      öäüß
      &amp;
      &lt;
      <?xtal cursor='11'?>
      <sub/>
      <sub></sub>
      </component>
    END
    
    lexer.map { |tk| tk }
    
    lexer.output.should == <<-'END'.fixed_indent( 0 )
      XML declaration
      Attr: version = '1.0'
      ROOTELEMENT: component
      INTERNAL DTD: [
      <!ELEMENT component (PCDATA|sub)*>
      <!ATTLIST component
                attr CDATA #IMPLIED
                attr2 CDATA #IMPLIED
      >
      <!ELMENT sub EMPTY>
      
      ]
      Start Tag: component
      Attr: attr = "val'ue"
      Attr: attr2 = 'val"ue'
      PCDATA: "
      "
      Comment: "<!-- This is a comment -->"
      PCDATA: "
      Text
      "
      CDATA: "<![CDATA[huhu]]>"
      PCDATA: "
      öäüß
      &amp;
      &lt;
      "
      PI: xtal
      Attr: cursor = '11'
      PCDATA: "
      "
      Empty Element: sub
      PCDATA: "
      "
      Start Tag: sub
      End Tag: sub
      PCDATA: "
      "
      End Tag: component
    END
  end

end
