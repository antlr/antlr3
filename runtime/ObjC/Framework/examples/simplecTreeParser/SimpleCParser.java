// $ANTLR 3.2 Aug 13, 2010 19:41:25 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g 2010-08-13 19:42:18

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class SimpleCParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "VAR_DEF", "ARG_DEF", "FUNC_HDR", "FUNC_DECL", "FUNC_DEF", "BLOCK", "ID", "EQ", "INT", "FOR", "INT_TYPE", "CHAR", "VOID", "EQEQ", "LT", "PLUS", "WS", "';'", "'('", "','", "')'", "'{'", "'}'"
    };
    public static final int LT=18;
    public static final int T__26=26;
    public static final int T__25=25;
    public static final int T__24=24;
    public static final int T__23=23;
    public static final int T__22=22;
    public static final int T__21=21;
    public static final int CHAR=15;
    public static final int FOR=13;
    public static final int FUNC_HDR=6;
    public static final int INT=12;
    public static final int FUNC_DEF=8;
    public static final int INT_TYPE=14;
    public static final int ID=10;
    public static final int EOF=-1;
    public static final int FUNC_DECL=7;
    public static final int ARG_DEF=5;
    public static final int WS=20;
    public static final int BLOCK=9;
    public static final int PLUS=19;
    public static final int VOID=16;
    public static final int EQ=11;
    public static final int VAR_DEF=4;
    public static final int EQEQ=17;

    // delegates
    // delegators


        public SimpleCParser(TokenStream input) {
            this(input, new RecognizerSharedState());
        }
        public SimpleCParser(TokenStream input, RecognizerSharedState state) {
            super(input, state);
             
        }
        
    protected TreeAdaptor adaptor = new CommonTreeAdaptor();

    public void setTreeAdaptor(TreeAdaptor adaptor) {
        this.adaptor = adaptor;
    }
    public TreeAdaptor getTreeAdaptor() {
        return adaptor;
    }

    public String[] getTokenNames() { return SimpleCParser.tokenNames; }
    public String getGrammarFileName() { return "/usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g"; }


    public static class program_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "program"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:16:1: program : ( declaration )+ ;
    public final SimpleCParser.program_return program() throws RecognitionException {
        SimpleCParser.program_return retval = new SimpleCParser.program_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        SimpleCParser.declaration_return declaration1 = null;



        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:17:5: ( ( declaration )+ )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:17:9: ( declaration )+
            {
            root_0 = (Object)adaptor.nil();

            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:17:9: ( declaration )+
            int cnt1=0;
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( (LA1_0==ID||(LA1_0>=INT_TYPE && LA1_0<=VOID)) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:17:9: declaration
            	    {
            	    pushFollow(FOLLOW_declaration_in_program85);
            	    declaration1=declaration();

            	    state._fsp--;

            	    adaptor.addChild(root_0, declaration1.getTree());

            	    }
            	    break;

            	default :
            	    if ( cnt1 >= 1 ) break loop1;
                        EarlyExitException eee =
                            new EarlyExitException(1, input);
                        throw eee;
                }
                cnt1++;
            } while (true);


            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "program"

    public static class declaration_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "declaration"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:20:1: declaration : ( variable | functionHeader ';' -> ^( FUNC_DECL functionHeader ) | functionHeader block -> ^( FUNC_DEF functionHeader block ) );
    public final SimpleCParser.declaration_return declaration() throws RecognitionException {
        SimpleCParser.declaration_return retval = new SimpleCParser.declaration_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token char_literal4=null;
        SimpleCParser.variable_return variable2 = null;

        SimpleCParser.functionHeader_return functionHeader3 = null;

        SimpleCParser.functionHeader_return functionHeader5 = null;

        SimpleCParser.block_return block6 = null;


        Object char_literal4_tree=null;
        RewriteRuleTokenStream stream_21=new RewriteRuleTokenStream(adaptor,"token 21");
        RewriteRuleSubtreeStream stream_functionHeader=new RewriteRuleSubtreeStream(adaptor,"rule functionHeader");
        RewriteRuleSubtreeStream stream_block=new RewriteRuleSubtreeStream(adaptor,"rule block");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:21:5: ( variable | functionHeader ';' -> ^( FUNC_DECL functionHeader ) | functionHeader block -> ^( FUNC_DEF functionHeader block ) )
            int alt2=3;
            alt2 = dfa2.predict(input);
            switch (alt2) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:21:9: variable
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_variable_in_declaration105);
                    variable2=variable();

                    state._fsp--;

                    adaptor.addChild(root_0, variable2.getTree());

                    }
                    break;
                case 2 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:22:9: functionHeader ';'
                    {
                    pushFollow(FOLLOW_functionHeader_in_declaration115);
                    functionHeader3=functionHeader();

                    state._fsp--;

                    stream_functionHeader.add(functionHeader3.getTree());
                    char_literal4=(Token)match(input,21,FOLLOW_21_in_declaration117);  
                    stream_21.add(char_literal4);



                    // AST REWRITE
                    // elements: functionHeader
                    // token labels: 
                    // rule labels: retval
                    // token list labels: 
                    // rule list labels: 
                    // wildcard labels: 
                    retval.tree = root_0;
                    RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

                    root_0 = (Object)adaptor.nil();
                    // 22:28: -> ^( FUNC_DECL functionHeader )
                    {
                        // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:22:31: ^( FUNC_DECL functionHeader )
                        {
                        Object root_1 = (Object)adaptor.nil();
                        root_1 = (Object)adaptor.becomeRoot((Object)adaptor.create(FUNC_DECL, "FUNC_DECL"), root_1);

                        adaptor.addChild(root_1, stream_functionHeader.nextTree());

                        adaptor.addChild(root_0, root_1);
                        }

                    }

                    retval.tree = root_0;
                    }
                    break;
                case 3 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:23:9: functionHeader block
                    {
                    pushFollow(FOLLOW_functionHeader_in_declaration135);
                    functionHeader5=functionHeader();

                    state._fsp--;

                    stream_functionHeader.add(functionHeader5.getTree());
                    pushFollow(FOLLOW_block_in_declaration137);
                    block6=block();

                    state._fsp--;

                    stream_block.add(block6.getTree());


                    // AST REWRITE
                    // elements: functionHeader, block
                    // token labels: 
                    // rule labels: retval
                    // token list labels: 
                    // rule list labels: 
                    // wildcard labels: 
                    retval.tree = root_0;
                    RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

                    root_0 = (Object)adaptor.nil();
                    // 23:30: -> ^( FUNC_DEF functionHeader block )
                    {
                        // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:23:33: ^( FUNC_DEF functionHeader block )
                        {
                        Object root_1 = (Object)adaptor.nil();
                        root_1 = (Object)adaptor.becomeRoot((Object)adaptor.create(FUNC_DEF, "FUNC_DEF"), root_1);

                        adaptor.addChild(root_1, stream_functionHeader.nextTree());
                        adaptor.addChild(root_1, stream_block.nextTree());

                        adaptor.addChild(root_0, root_1);
                        }

                    }

                    retval.tree = root_0;
                    }
                    break;

            }
            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "declaration"

    public static class variable_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "variable"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:26:1: variable : type declarator ';' -> ^( VAR_DEF type declarator ) ;
    public final SimpleCParser.variable_return variable() throws RecognitionException {
        SimpleCParser.variable_return retval = new SimpleCParser.variable_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token char_literal9=null;
        SimpleCParser.type_return type7 = null;

        SimpleCParser.declarator_return declarator8 = null;


        Object char_literal9_tree=null;
        RewriteRuleTokenStream stream_21=new RewriteRuleTokenStream(adaptor,"token 21");
        RewriteRuleSubtreeStream stream_declarator=new RewriteRuleSubtreeStream(adaptor,"rule declarator");
        RewriteRuleSubtreeStream stream_type=new RewriteRuleSubtreeStream(adaptor,"rule type");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:27:5: ( type declarator ';' -> ^( VAR_DEF type declarator ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:27:9: type declarator ';'
            {
            pushFollow(FOLLOW_type_in_variable166);
            type7=type();

            state._fsp--;

            stream_type.add(type7.getTree());
            pushFollow(FOLLOW_declarator_in_variable168);
            declarator8=declarator();

            state._fsp--;

            stream_declarator.add(declarator8.getTree());
            char_literal9=(Token)match(input,21,FOLLOW_21_in_variable170);  
            stream_21.add(char_literal9);



            // AST REWRITE
            // elements: type, declarator
            // token labels: 
            // rule labels: retval
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

            root_0 = (Object)adaptor.nil();
            // 27:29: -> ^( VAR_DEF type declarator )
            {
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:27:32: ^( VAR_DEF type declarator )
                {
                Object root_1 = (Object)adaptor.nil();
                root_1 = (Object)adaptor.becomeRoot((Object)adaptor.create(VAR_DEF, "VAR_DEF"), root_1);

                adaptor.addChild(root_1, stream_type.nextTree());
                adaptor.addChild(root_1, stream_declarator.nextTree());

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;
            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "variable"

    public static class declarator_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "declarator"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:30:1: declarator : ID ;
    public final SimpleCParser.declarator_return declarator() throws RecognitionException {
        SimpleCParser.declarator_return retval = new SimpleCParser.declarator_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ID10=null;

        Object ID10_tree=null;

        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:31:5: ( ID )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:31:9: ID
            {
            root_0 = (Object)adaptor.nil();

            ID10=(Token)match(input,ID,FOLLOW_ID_in_declarator199); 
            ID10_tree = (Object)adaptor.create(ID10);
            adaptor.addChild(root_0, ID10_tree);


            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "declarator"

    public static class functionHeader_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "functionHeader"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:34:1: functionHeader : type ID '(' ( formalParameter ( ',' formalParameter )* )? ')' -> ^( FUNC_HDR type ID ( formalParameter )+ ) ;
    public final SimpleCParser.functionHeader_return functionHeader() throws RecognitionException {
        SimpleCParser.functionHeader_return retval = new SimpleCParser.functionHeader_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ID12=null;
        Token char_literal13=null;
        Token char_literal15=null;
        Token char_literal17=null;
        SimpleCParser.type_return type11 = null;

        SimpleCParser.formalParameter_return formalParameter14 = null;

        SimpleCParser.formalParameter_return formalParameter16 = null;


        Object ID12_tree=null;
        Object char_literal13_tree=null;
        Object char_literal15_tree=null;
        Object char_literal17_tree=null;
        RewriteRuleTokenStream stream_ID=new RewriteRuleTokenStream(adaptor,"token ID");
        RewriteRuleTokenStream stream_22=new RewriteRuleTokenStream(adaptor,"token 22");
        RewriteRuleTokenStream stream_23=new RewriteRuleTokenStream(adaptor,"token 23");
        RewriteRuleTokenStream stream_24=new RewriteRuleTokenStream(adaptor,"token 24");
        RewriteRuleSubtreeStream stream_formalParameter=new RewriteRuleSubtreeStream(adaptor,"rule formalParameter");
        RewriteRuleSubtreeStream stream_type=new RewriteRuleSubtreeStream(adaptor,"rule type");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:35:5: ( type ID '(' ( formalParameter ( ',' formalParameter )* )? ')' -> ^( FUNC_HDR type ID ( formalParameter )+ ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:35:9: type ID '(' ( formalParameter ( ',' formalParameter )* )? ')'
            {
            pushFollow(FOLLOW_type_in_functionHeader219);
            type11=type();

            state._fsp--;

            stream_type.add(type11.getTree());
            ID12=(Token)match(input,ID,FOLLOW_ID_in_functionHeader221);  
            stream_ID.add(ID12);

            char_literal13=(Token)match(input,22,FOLLOW_22_in_functionHeader223);  
            stream_22.add(char_literal13);

            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:35:21: ( formalParameter ( ',' formalParameter )* )?
            int alt4=2;
            int LA4_0 = input.LA(1);

            if ( (LA4_0==ID||(LA4_0>=INT_TYPE && LA4_0<=VOID)) ) {
                alt4=1;
            }
            switch (alt4) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:35:23: formalParameter ( ',' formalParameter )*
                    {
                    pushFollow(FOLLOW_formalParameter_in_functionHeader227);
                    formalParameter14=formalParameter();

                    state._fsp--;

                    stream_formalParameter.add(formalParameter14.getTree());
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:35:39: ( ',' formalParameter )*
                    loop3:
                    do {
                        int alt3=2;
                        int LA3_0 = input.LA(1);

                        if ( (LA3_0==23) ) {
                            alt3=1;
                        }


                        switch (alt3) {
                    	case 1 :
                    	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:35:41: ',' formalParameter
                    	    {
                    	    char_literal15=(Token)match(input,23,FOLLOW_23_in_functionHeader231);  
                    	    stream_23.add(char_literal15);

                    	    pushFollow(FOLLOW_formalParameter_in_functionHeader233);
                    	    formalParameter16=formalParameter();

                    	    state._fsp--;

                    	    stream_formalParameter.add(formalParameter16.getTree());

                    	    }
                    	    break;

                    	default :
                    	    break loop3;
                        }
                    } while (true);


                    }
                    break;

            }

            char_literal17=(Token)match(input,24,FOLLOW_24_in_functionHeader241);  
            stream_24.add(char_literal17);



            // AST REWRITE
            // elements: formalParameter, ID, type
            // token labels: 
            // rule labels: retval
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

            root_0 = (Object)adaptor.nil();
            // 36:9: -> ^( FUNC_HDR type ID ( formalParameter )+ )
            {
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:36:12: ^( FUNC_HDR type ID ( formalParameter )+ )
                {
                Object root_1 = (Object)adaptor.nil();
                root_1 = (Object)adaptor.becomeRoot((Object)adaptor.create(FUNC_HDR, "FUNC_HDR"), root_1);

                adaptor.addChild(root_1, stream_type.nextTree());
                adaptor.addChild(root_1, stream_ID.nextNode());
                if ( !(stream_formalParameter.hasNext()) ) {
                    throw new RewriteEarlyExitException();
                }
                while ( stream_formalParameter.hasNext() ) {
                    adaptor.addChild(root_1, stream_formalParameter.nextTree());

                }
                stream_formalParameter.reset();

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;
            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "functionHeader"

    public static class formalParameter_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "formalParameter"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:39:1: formalParameter : type declarator -> ^( ARG_DEF type declarator ) ;
    public final SimpleCParser.formalParameter_return formalParameter() throws RecognitionException {
        SimpleCParser.formalParameter_return retval = new SimpleCParser.formalParameter_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        SimpleCParser.type_return type18 = null;

        SimpleCParser.declarator_return declarator19 = null;


        RewriteRuleSubtreeStream stream_declarator=new RewriteRuleSubtreeStream(adaptor,"rule declarator");
        RewriteRuleSubtreeStream stream_type=new RewriteRuleSubtreeStream(adaptor,"rule type");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:40:5: ( type declarator -> ^( ARG_DEF type declarator ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:40:9: type declarator
            {
            pushFollow(FOLLOW_type_in_formalParameter281);
            type18=type();

            state._fsp--;

            stream_type.add(type18.getTree());
            pushFollow(FOLLOW_declarator_in_formalParameter283);
            declarator19=declarator();

            state._fsp--;

            stream_declarator.add(declarator19.getTree());


            // AST REWRITE
            // elements: declarator, type
            // token labels: 
            // rule labels: retval
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

            root_0 = (Object)adaptor.nil();
            // 40:25: -> ^( ARG_DEF type declarator )
            {
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:40:28: ^( ARG_DEF type declarator )
                {
                Object root_1 = (Object)adaptor.nil();
                root_1 = (Object)adaptor.becomeRoot((Object)adaptor.create(ARG_DEF, "ARG_DEF"), root_1);

                adaptor.addChild(root_1, stream_type.nextTree());
                adaptor.addChild(root_1, stream_declarator.nextTree());

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;
            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "formalParameter"

    public static class type_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "type"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:43:1: type : ( 'int' | 'char' | 'void' | ID );
    public final SimpleCParser.type_return type() throws RecognitionException {
        SimpleCParser.type_return retval = new SimpleCParser.type_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token set20=null;

        Object set20_tree=null;

        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:44:5: ( 'int' | 'char' | 'void' | ID )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:
            {
            root_0 = (Object)adaptor.nil();

            set20=(Token)input.LT(1);
            if ( input.LA(1)==ID||(input.LA(1)>=INT_TYPE && input.LA(1)<=VOID) ) {
                input.consume();
                adaptor.addChild(root_0, (Object)adaptor.create(set20));
                state.errorRecovery=false;
            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }


            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "type"

    public static class block_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "block"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:50:1: block : lc= '{' ( variable )* ( stat )* '}' -> ^( BLOCK[$lc,@\"BLOCK\"] ( variable )* ( stat )* ) ;
    public final SimpleCParser.block_return block() throws RecognitionException {
        SimpleCParser.block_return retval = new SimpleCParser.block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token lc=null;
        Token char_literal23=null;
        SimpleCParser.variable_return variable21 = null;

        SimpleCParser.stat_return stat22 = null;


        Object lc_tree=null;
        Object char_literal23_tree=null;
        RewriteRuleTokenStream stream_25=new RewriteRuleTokenStream(adaptor,"token 25");
        RewriteRuleTokenStream stream_26=new RewriteRuleTokenStream(adaptor,"token 26");
        RewriteRuleSubtreeStream stream_variable=new RewriteRuleSubtreeStream(adaptor,"rule variable");
        RewriteRuleSubtreeStream stream_stat=new RewriteRuleSubtreeStream(adaptor,"rule stat");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:51:5: (lc= '{' ( variable )* ( stat )* '}' -> ^( BLOCK[$lc,@\"BLOCK\"] ( variable )* ( stat )* ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:51:9: lc= '{' ( variable )* ( stat )* '}'
            {
            lc=(Token)match(input,25,FOLLOW_25_in_block376);  
            stream_25.add(lc);

            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:52:13: ( variable )*
            loop5:
            do {
                int alt5=2;
                int LA5_0 = input.LA(1);

                if ( (LA5_0==ID) ) {
                    int LA5_2 = input.LA(2);

                    if ( (LA5_2==ID) ) {
                        alt5=1;
                    }


                }
                else if ( ((LA5_0>=INT_TYPE && LA5_0<=VOID)) ) {
                    alt5=1;
                }


                switch (alt5) {
            	case 1 :
            	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:52:13: variable
            	    {
            	    pushFollow(FOLLOW_variable_in_block390);
            	    variable21=variable();

            	    state._fsp--;

            	    stream_variable.add(variable21.getTree());

            	    }
            	    break;

            	default :
            	    break loop5;
                }
            } while (true);

            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:53:13: ( stat )*
            loop6:
            do {
                int alt6=2;
                int LA6_0 = input.LA(1);

                if ( (LA6_0==ID||(LA6_0>=INT && LA6_0<=FOR)||(LA6_0>=21 && LA6_0<=22)||LA6_0==25) ) {
                    alt6=1;
                }


                switch (alt6) {
            	case 1 :
            	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:53:13: stat
            	    {
            	    pushFollow(FOLLOW_stat_in_block405);
            	    stat22=stat();

            	    state._fsp--;

            	    stream_stat.add(stat22.getTree());

            	    }
            	    break;

            	default :
            	    break loop6;
                }
            } while (true);

            char_literal23=(Token)match(input,26,FOLLOW_26_in_block416);  
            stream_26.add(char_literal23);



            // AST REWRITE
            // elements: variable, stat
            // token labels: 
            // rule labels: retval
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

            root_0 = (Object)adaptor.nil();
            // 55:9: -> ^( BLOCK[$lc,@\"BLOCK\"] ( variable )* ( stat )* )
            {
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:55:12: ^( BLOCK[$lc,@\"BLOCK\"] ( variable )* ( stat )* )
                {
                Object root_1 = (Object)adaptor.nil();
                root_1 = (Object)adaptor.becomeRoot((Object)adaptor.create(BLOCK, lc, @"BLOCK"), root_1);

                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:55:34: ( variable )*
                while ( stream_variable.hasNext() ) {
                    adaptor.addChild(root_1, stream_variable.nextTree());

                }
                stream_variable.reset();
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:55:44: ( stat )*
                while ( stream_stat.hasNext() ) {
                    adaptor.addChild(root_1, stream_stat.nextTree());

                }
                stream_stat.reset();

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;
            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "block"

    public static class stat_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "stat"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:58:1: stat : ( forStat | expr ';' | block | assignStat ';' | ';' );
    public final SimpleCParser.stat_return stat() throws RecognitionException {
        SimpleCParser.stat_return retval = new SimpleCParser.stat_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token char_literal26=null;
        Token char_literal29=null;
        Token char_literal30=null;
        SimpleCParser.forStat_return forStat24 = null;

        SimpleCParser.expr_return expr25 = null;

        SimpleCParser.block_return block27 = null;

        SimpleCParser.assignStat_return assignStat28 = null;


        Object char_literal26_tree=null;
        Object char_literal29_tree=null;
        Object char_literal30_tree=null;

        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:58:5: ( forStat | expr ';' | block | assignStat ';' | ';' )
            int alt7=5;
            switch ( input.LA(1) ) {
            case FOR:
                {
                alt7=1;
                }
                break;
            case ID:
                {
                int LA7_2 = input.LA(2);

                if ( (LA7_2==EQ) ) {
                    alt7=4;
                }
                else if ( ((LA7_2>=EQEQ && LA7_2<=PLUS)||LA7_2==21) ) {
                    alt7=2;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("", 7, 2, input);

                    throw nvae;
                }
                }
                break;
            case INT:
            case 22:
                {
                alt7=2;
                }
                break;
            case 25:
                {
                alt7=3;
                }
                break;
            case 21:
                {
                alt7=5;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 7, 0, input);

                throw nvae;
            }

            switch (alt7) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:58:7: forStat
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_forStat_in_stat449);
                    forStat24=forStat();

                    state._fsp--;

                    adaptor.addChild(root_0, forStat24.getTree());

                    }
                    break;
                case 2 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:59:7: expr ';'
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_expr_in_stat457);
                    expr25=expr();

                    state._fsp--;

                    adaptor.addChild(root_0, expr25.getTree());
                    char_literal26=(Token)match(input,21,FOLLOW_21_in_stat459); 

                    }
                    break;
                case 3 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:60:7: block
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_block_in_stat468);
                    block27=block();

                    state._fsp--;

                    adaptor.addChild(root_0, block27.getTree());

                    }
                    break;
                case 4 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:61:7: assignStat ';'
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_assignStat_in_stat476);
                    assignStat28=assignStat();

                    state._fsp--;

                    adaptor.addChild(root_0, assignStat28.getTree());
                    char_literal29=(Token)match(input,21,FOLLOW_21_in_stat478); 

                    }
                    break;
                case 5 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:62:7: ';'
                    {
                    root_0 = (Object)adaptor.nil();

                    char_literal30=(Token)match(input,21,FOLLOW_21_in_stat487); 

                    }
                    break;

            }
            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "stat"

    public static class forStat_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "forStat"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:65:1: forStat : 'for' '(' start= assignStat ';' expr ';' next= assignStat ')' block -> ^( 'for' $start expr $next block ) ;
    public final SimpleCParser.forStat_return forStat() throws RecognitionException {
        SimpleCParser.forStat_return retval = new SimpleCParser.forStat_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token string_literal31=null;
        Token char_literal32=null;
        Token char_literal33=null;
        Token char_literal35=null;
        Token char_literal36=null;
        SimpleCParser.assignStat_return start = null;

        SimpleCParser.assignStat_return next = null;

        SimpleCParser.expr_return expr34 = null;

        SimpleCParser.block_return block37 = null;


        Object string_literal31_tree=null;
        Object char_literal32_tree=null;
        Object char_literal33_tree=null;
        Object char_literal35_tree=null;
        Object char_literal36_tree=null;
        RewriteRuleTokenStream stream_21=new RewriteRuleTokenStream(adaptor,"token 21");
        RewriteRuleTokenStream stream_FOR=new RewriteRuleTokenStream(adaptor,"token FOR");
        RewriteRuleTokenStream stream_22=new RewriteRuleTokenStream(adaptor,"token 22");
        RewriteRuleTokenStream stream_24=new RewriteRuleTokenStream(adaptor,"token 24");
        RewriteRuleSubtreeStream stream_assignStat=new RewriteRuleSubtreeStream(adaptor,"rule assignStat");
        RewriteRuleSubtreeStream stream_block=new RewriteRuleSubtreeStream(adaptor,"rule block");
        RewriteRuleSubtreeStream stream_expr=new RewriteRuleSubtreeStream(adaptor,"rule expr");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:66:5: ( 'for' '(' start= assignStat ';' expr ';' next= assignStat ')' block -> ^( 'for' $start expr $next block ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:66:9: 'for' '(' start= assignStat ';' expr ';' next= assignStat ')' block
            {
            string_literal31=(Token)match(input,FOR,FOLLOW_FOR_in_forStat507);  
            stream_FOR.add(string_literal31);

            char_literal32=(Token)match(input,22,FOLLOW_22_in_forStat509);  
            stream_22.add(char_literal32);

            pushFollow(FOLLOW_assignStat_in_forStat513);
            start=assignStat();

            state._fsp--;

            stream_assignStat.add(start.getTree());
            char_literal33=(Token)match(input,21,FOLLOW_21_in_forStat515);  
            stream_21.add(char_literal33);

            pushFollow(FOLLOW_expr_in_forStat517);
            expr34=expr();

            state._fsp--;

            stream_expr.add(expr34.getTree());
            char_literal35=(Token)match(input,21,FOLLOW_21_in_forStat519);  
            stream_21.add(char_literal35);

            pushFollow(FOLLOW_assignStat_in_forStat523);
            next=assignStat();

            state._fsp--;

            stream_assignStat.add(next.getTree());
            char_literal36=(Token)match(input,24,FOLLOW_24_in_forStat525);  
            stream_24.add(char_literal36);

            pushFollow(FOLLOW_block_in_forStat527);
            block37=block();

            state._fsp--;

            stream_block.add(block37.getTree());


            // AST REWRITE
            // elements: block, expr, FOR, start, next
            // token labels: 
            // rule labels: retval, start, next
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);
            RewriteRuleSubtreeStream stream_start=new RewriteRuleSubtreeStream(adaptor,"rule start",start!=null?start.tree:null);
            RewriteRuleSubtreeStream stream_next=new RewriteRuleSubtreeStream(adaptor,"rule next",next!=null?next.tree:null);

            root_0 = (Object)adaptor.nil();
            // 67:9: -> ^( 'for' $start expr $next block )
            {
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:67:12: ^( 'for' $start expr $next block )
                {
                Object root_1 = (Object)adaptor.nil();
                root_1 = (Object)adaptor.becomeRoot(stream_FOR.nextNode(), root_1);

                adaptor.addChild(root_1, stream_start.nextTree());
                adaptor.addChild(root_1, stream_expr.nextTree());
                adaptor.addChild(root_1, stream_next.nextTree());
                adaptor.addChild(root_1, stream_block.nextTree());

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;
            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "forStat"

    public static class assignStat_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "assignStat"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:70:1: assignStat : ID EQ expr -> ^( EQ ID expr ) ;
    public final SimpleCParser.assignStat_return assignStat() throws RecognitionException {
        SimpleCParser.assignStat_return retval = new SimpleCParser.assignStat_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ID38=null;
        Token EQ39=null;
        SimpleCParser.expr_return expr40 = null;


        Object ID38_tree=null;
        Object EQ39_tree=null;
        RewriteRuleTokenStream stream_EQ=new RewriteRuleTokenStream(adaptor,"token EQ");
        RewriteRuleTokenStream stream_ID=new RewriteRuleTokenStream(adaptor,"token ID");
        RewriteRuleSubtreeStream stream_expr=new RewriteRuleSubtreeStream(adaptor,"rule expr");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:71:5: ( ID EQ expr -> ^( EQ ID expr ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:71:9: ID EQ expr
            {
            ID38=(Token)match(input,ID,FOLLOW_ID_in_assignStat570);  
            stream_ID.add(ID38);

            EQ39=(Token)match(input,EQ,FOLLOW_EQ_in_assignStat572);  
            stream_EQ.add(EQ39);

            pushFollow(FOLLOW_expr_in_assignStat574);
            expr40=expr();

            state._fsp--;

            stream_expr.add(expr40.getTree());


            // AST REWRITE
            // elements: EQ, expr, ID
            // token labels: 
            // rule labels: retval
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

            root_0 = (Object)adaptor.nil();
            // 71:20: -> ^( EQ ID expr )
            {
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:71:23: ^( EQ ID expr )
                {
                Object root_1 = (Object)adaptor.nil();
                root_1 = (Object)adaptor.becomeRoot(stream_EQ.nextNode(), root_1);

                adaptor.addChild(root_1, stream_ID.nextNode());
                adaptor.addChild(root_1, stream_expr.nextTree());

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;
            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "assignStat"

    public static class expr_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "expr"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:74:1: expr : condExpr ;
    public final SimpleCParser.expr_return expr() throws RecognitionException {
        SimpleCParser.expr_return retval = new SimpleCParser.expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        SimpleCParser.condExpr_return condExpr41 = null;



        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:74:5: ( condExpr )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:74:9: condExpr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_condExpr_in_expr598);
            condExpr41=condExpr();

            state._fsp--;

            adaptor.addChild(root_0, condExpr41.getTree());

            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "expr"

    public static class condExpr_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "condExpr"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:77:1: condExpr : aexpr ( ( '==' | '<' ) aexpr )? ;
    public final SimpleCParser.condExpr_return condExpr() throws RecognitionException {
        SimpleCParser.condExpr_return retval = new SimpleCParser.condExpr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token string_literal43=null;
        Token char_literal44=null;
        SimpleCParser.aexpr_return aexpr42 = null;

        SimpleCParser.aexpr_return aexpr45 = null;


        Object string_literal43_tree=null;
        Object char_literal44_tree=null;

        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:5: ( aexpr ( ( '==' | '<' ) aexpr )? )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:9: aexpr ( ( '==' | '<' ) aexpr )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_aexpr_in_condExpr617);
            aexpr42=aexpr();

            state._fsp--;

            adaptor.addChild(root_0, aexpr42.getTree());
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:15: ( ( '==' | '<' ) aexpr )?
            int alt9=2;
            int LA9_0 = input.LA(1);

            if ( ((LA9_0>=EQEQ && LA9_0<=LT)) ) {
                alt9=1;
            }
            switch (alt9) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:17: ( '==' | '<' ) aexpr
                    {
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:17: ( '==' | '<' )
                    int alt8=2;
                    int LA8_0 = input.LA(1);

                    if ( (LA8_0==EQEQ) ) {
                        alt8=1;
                    }
                    else if ( (LA8_0==LT) ) {
                        alt8=2;
                    }
                    else {
                        NoViableAltException nvae =
                            new NoViableAltException("", 8, 0, input);

                        throw nvae;
                    }
                    switch (alt8) {
                        case 1 :
                            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:18: '=='
                            {
                            string_literal43=(Token)match(input,EQEQ,FOLLOW_EQEQ_in_condExpr622); 
                            string_literal43_tree = (Object)adaptor.create(string_literal43);
                            root_0 = (Object)adaptor.becomeRoot(string_literal43_tree, root_0);


                            }
                            break;
                        case 2 :
                            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:78:26: '<'
                            {
                            char_literal44=(Token)match(input,LT,FOLLOW_LT_in_condExpr627); 
                            char_literal44_tree = (Object)adaptor.create(char_literal44);
                            root_0 = (Object)adaptor.becomeRoot(char_literal44_tree, root_0);


                            }
                            break;

                    }

                    pushFollow(FOLLOW_aexpr_in_condExpr631);
                    aexpr45=aexpr();

                    state._fsp--;

                    adaptor.addChild(root_0, aexpr45.getTree());

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "condExpr"

    public static class aexpr_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "aexpr"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:81:1: aexpr : atom ( '+' atom )* ;
    public final SimpleCParser.aexpr_return aexpr() throws RecognitionException {
        SimpleCParser.aexpr_return retval = new SimpleCParser.aexpr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token char_literal47=null;
        SimpleCParser.atom_return atom46 = null;

        SimpleCParser.atom_return atom48 = null;


        Object char_literal47_tree=null;

        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:82:5: ( atom ( '+' atom )* )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:82:9: atom ( '+' atom )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_atom_in_aexpr653);
            atom46=atom();

            state._fsp--;

            adaptor.addChild(root_0, atom46.getTree());
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:82:14: ( '+' atom )*
            loop10:
            do {
                int alt10=2;
                int LA10_0 = input.LA(1);

                if ( (LA10_0==PLUS) ) {
                    alt10=1;
                }


                switch (alt10) {
            	case 1 :
            	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:82:16: '+' atom
            	    {
            	    char_literal47=(Token)match(input,PLUS,FOLLOW_PLUS_in_aexpr657); 
            	    char_literal47_tree = (Object)adaptor.create(char_literal47);
            	    root_0 = (Object)adaptor.becomeRoot(char_literal47_tree, root_0);

            	    pushFollow(FOLLOW_atom_in_aexpr660);
            	    atom48=atom();

            	    state._fsp--;

            	    adaptor.addChild(root_0, atom48.getTree());

            	    }
            	    break;

            	default :
            	    break loop10;
                }
            } while (true);


            }

            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "aexpr"

    public static class atom_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "atom"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:85:1: atom : ( ID | INT | '(' expr ')' -> expr );
    public final SimpleCParser.atom_return atom() throws RecognitionException {
        SimpleCParser.atom_return retval = new SimpleCParser.atom_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ID49=null;
        Token INT50=null;
        Token char_literal51=null;
        Token char_literal53=null;
        SimpleCParser.expr_return expr52 = null;


        Object ID49_tree=null;
        Object INT50_tree=null;
        Object char_literal51_tree=null;
        Object char_literal53_tree=null;
        RewriteRuleTokenStream stream_22=new RewriteRuleTokenStream(adaptor,"token 22");
        RewriteRuleTokenStream stream_24=new RewriteRuleTokenStream(adaptor,"token 24");
        RewriteRuleSubtreeStream stream_expr=new RewriteRuleSubtreeStream(adaptor,"rule expr");
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:86:5: ( ID | INT | '(' expr ')' -> expr )
            int alt11=3;
            switch ( input.LA(1) ) {
            case ID:
                {
                alt11=1;
                }
                break;
            case INT:
                {
                alt11=2;
                }
                break;
            case 22:
                {
                alt11=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 11, 0, input);

                throw nvae;
            }

            switch (alt11) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:86:7: ID
                    {
                    root_0 = (Object)adaptor.nil();

                    ID49=(Token)match(input,ID,FOLLOW_ID_in_atom680); 
                    ID49_tree = (Object)adaptor.create(ID49);
                    adaptor.addChild(root_0, ID49_tree);


                    }
                    break;
                case 2 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:87:7: INT
                    {
                    root_0 = (Object)adaptor.nil();

                    INT50=(Token)match(input,INT,FOLLOW_INT_in_atom694); 
                    INT50_tree = (Object)adaptor.create(INT50);
                    adaptor.addChild(root_0, INT50_tree);


                    }
                    break;
                case 3 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleC.g:88:7: '(' expr ')'
                    {
                    char_literal51=(Token)match(input,22,FOLLOW_22_in_atom708);  
                    stream_22.add(char_literal51);

                    pushFollow(FOLLOW_expr_in_atom710);
                    expr52=expr();

                    state._fsp--;

                    stream_expr.add(expr52.getTree());
                    char_literal53=(Token)match(input,24,FOLLOW_24_in_atom712);  
                    stream_24.add(char_literal53);



                    // AST REWRITE
                    // elements: expr
                    // token labels: 
                    // rule labels: retval
                    // token list labels: 
                    // rule list labels: 
                    // wildcard labels: 
                    retval.tree = root_0;
                    RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

                    root_0 = (Object)adaptor.nil();
                    // 88:20: -> expr
                    {
                        adaptor.addChild(root_0, stream_expr.nextTree());

                    }

                    retval.tree = root_0;
                    }
                    break;

            }
            retval.stop = input.LT(-1);

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "atom"

    // Delegated rules


    protected DFA2 dfa2 = new DFA2(this);
    static final String DFA2_eotS =
        "\15\uffff";
    static final String DFA2_eofS =
        "\15\uffff";
    static final String DFA2_minS =
        "\2\12\1\25\1\12\1\uffff\1\12\1\25\1\27\2\uffff\2\12\1\27";
    static final String DFA2_maxS =
        "\1\20\1\12\1\26\1\30\1\uffff\1\12\1\31\1\30\2\uffff\1\20\1\12\1"+
        "\30";
    static final String DFA2_acceptS =
        "\4\uffff\1\1\3\uffff\1\3\1\2\3\uffff";
    static final String DFA2_specialS =
        "\15\uffff}>";
    static final String[] DFA2_transitionS = {
            "\1\1\3\uffff\3\1",
            "\1\2",
            "\1\4\1\3",
            "\1\5\3\uffff\3\5\7\uffff\1\6",
            "",
            "\1\7",
            "\1\11\3\uffff\1\10",
            "\1\12\1\6",
            "",
            "",
            "\1\13\3\uffff\3\13",
            "\1\14",
            "\1\12\1\6"
    };

    static final short[] DFA2_eot = DFA.unpackEncodedString(DFA2_eotS);
    static final short[] DFA2_eof = DFA.unpackEncodedString(DFA2_eofS);
    static final char[] DFA2_min = DFA.unpackEncodedStringToUnsignedChars(DFA2_minS);
    static final char[] DFA2_max = DFA.unpackEncodedStringToUnsignedChars(DFA2_maxS);
    static final short[] DFA2_accept = DFA.unpackEncodedString(DFA2_acceptS);
    static final short[] DFA2_special = DFA.unpackEncodedString(DFA2_specialS);
    static final short[][] DFA2_transition;

    static {
        int numStates = DFA2_transitionS.length;
        DFA2_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA2_transition[i] = DFA.unpackEncodedString(DFA2_transitionS[i]);
        }
    }

    class DFA2 extends DFA {

        public DFA2(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 2;
            this.eot = DFA2_eot;
            this.eof = DFA2_eof;
            this.min = DFA2_min;
            this.max = DFA2_max;
            this.accept = DFA2_accept;
            this.special = DFA2_special;
            this.transition = DFA2_transition;
        }
        public String getDescription() {
            return "20:1: declaration : ( variable | functionHeader ';' -> ^( FUNC_DECL functionHeader ) | functionHeader block -> ^( FUNC_DEF functionHeader block ) );";
        }
    }
 

    public static final BitSet FOLLOW_declaration_in_program85 = new BitSet(new long[]{0x000000000001C402L});
    public static final BitSet FOLLOW_variable_in_declaration105 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_functionHeader_in_declaration115 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_21_in_declaration117 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_functionHeader_in_declaration135 = new BitSet(new long[]{0x0000000002000000L});
    public static final BitSet FOLLOW_block_in_declaration137 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_type_in_variable166 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_declarator_in_variable168 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_21_in_variable170 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_ID_in_declarator199 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_type_in_functionHeader219 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_ID_in_functionHeader221 = new BitSet(new long[]{0x0000000000400000L});
    public static final BitSet FOLLOW_22_in_functionHeader223 = new BitSet(new long[]{0x000000000101C400L});
    public static final BitSet FOLLOW_formalParameter_in_functionHeader227 = new BitSet(new long[]{0x0000000001800000L});
    public static final BitSet FOLLOW_23_in_functionHeader231 = new BitSet(new long[]{0x000000000001C400L});
    public static final BitSet FOLLOW_formalParameter_in_functionHeader233 = new BitSet(new long[]{0x0000000001800000L});
    public static final BitSet FOLLOW_24_in_functionHeader241 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_type_in_formalParameter281 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_declarator_in_formalParameter283 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_type0 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_25_in_block376 = new BitSet(new long[]{0x000000000661F400L});
    public static final BitSet FOLLOW_variable_in_block390 = new BitSet(new long[]{0x000000000661F400L});
    public static final BitSet FOLLOW_stat_in_block405 = new BitSet(new long[]{0x0000000006603400L});
    public static final BitSet FOLLOW_26_in_block416 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_forStat_in_stat449 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expr_in_stat457 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_21_in_stat459 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_block_in_stat468 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_assignStat_in_stat476 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_21_in_stat478 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_21_in_stat487 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FOR_in_forStat507 = new BitSet(new long[]{0x0000000000400000L});
    public static final BitSet FOLLOW_22_in_forStat509 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_assignStat_in_forStat513 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_21_in_forStat515 = new BitSet(new long[]{0x0000000000401400L});
    public static final BitSet FOLLOW_expr_in_forStat517 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_21_in_forStat519 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_assignStat_in_forStat523 = new BitSet(new long[]{0x0000000001000000L});
    public static final BitSet FOLLOW_24_in_forStat525 = new BitSet(new long[]{0x0000000002000000L});
    public static final BitSet FOLLOW_block_in_forStat527 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_ID_in_assignStat570 = new BitSet(new long[]{0x0000000000000800L});
    public static final BitSet FOLLOW_EQ_in_assignStat572 = new BitSet(new long[]{0x0000000000401400L});
    public static final BitSet FOLLOW_expr_in_assignStat574 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_condExpr_in_expr598 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_aexpr_in_condExpr617 = new BitSet(new long[]{0x0000000000060002L});
    public static final BitSet FOLLOW_EQEQ_in_condExpr622 = new BitSet(new long[]{0x0000000000401400L});
    public static final BitSet FOLLOW_LT_in_condExpr627 = new BitSet(new long[]{0x0000000000401400L});
    public static final BitSet FOLLOW_aexpr_in_condExpr631 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_atom_in_aexpr653 = new BitSet(new long[]{0x0000000000080002L});
    public static final BitSet FOLLOW_PLUS_in_aexpr657 = new BitSet(new long[]{0x0000000000401400L});
    public static final BitSet FOLLOW_atom_in_aexpr660 = new BitSet(new long[]{0x0000000000080002L});
    public static final BitSet FOLLOW_ID_in_atom680 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_INT_in_atom694 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_22_in_atom708 = new BitSet(new long[]{0x0000000000401400L});
    public static final BitSet FOLLOW_expr_in_atom710 = new BitSet(new long[]{0x0000000001000000L});
    public static final BitSet FOLLOW_24_in_atom712 = new BitSet(new long[]{0x0000000000000002L});

}