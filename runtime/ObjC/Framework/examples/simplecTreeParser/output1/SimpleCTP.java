// $ANTLR 3.2 Aug 13, 2010 19:41:25 /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g 2010-08-13 19:42:13

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class SimpleCTP extends TreeParser {
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


        public SimpleCTP(TreeNodeStream input) {
            this(input, new RecognizerSharedState());
        }
        public SimpleCTP(TreeNodeStream input, RecognizerSharedState state) {
            super(input, state);
             
        }
        

    public String[] getTokenNames() { return SimpleCTP.tokenNames; }
    public String getGrammarFileName() { return "/usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g"; }



    // $ANTLR start "program"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:8:1: program : ( declaration )+ ;
    public final void program() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:9:5: ( ( declaration )+ )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:9:9: ( declaration )+
            {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:9:9: ( declaration )+
            int cnt1=0;
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( (LA1_0==VAR_DEF||(LA1_0>=FUNC_DECL && LA1_0<=FUNC_DEF)) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:9:9: declaration
            	    {
            	    pushFollow(FOLLOW_declaration_in_program43);
            	    declaration();

            	    state._fsp--;


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

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "program"


    // $ANTLR start "declaration"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:12:1: declaration : ( variable | ^( FUNC_DECL functionHeader ) | ^( FUNC_DEF functionHeader block ) );
    public final void declaration() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:13:5: ( variable | ^( FUNC_DECL functionHeader ) | ^( FUNC_DEF functionHeader block ) )
            int alt2=3;
            switch ( input.LA(1) ) {
            case VAR_DEF:
                {
                alt2=1;
                }
                break;
            case FUNC_DECL:
                {
                alt2=2;
                }
                break;
            case FUNC_DEF:
                {
                alt2=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 2, 0, input);

                throw nvae;
            }

            switch (alt2) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:13:9: variable
                    {
                    pushFollow(FOLLOW_variable_in_declaration63);
                    variable();

                    state._fsp--;


                    }
                    break;
                case 2 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:14:9: ^( FUNC_DECL functionHeader )
                    {
                    match(input,FUNC_DECL,FOLLOW_FUNC_DECL_in_declaration74); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_functionHeader_in_declaration76);
                    functionHeader();

                    state._fsp--;


                    match(input, Token.UP, null); 

                    }
                    break;
                case 3 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:15:9: ^( FUNC_DEF functionHeader block )
                    {
                    match(input,FUNC_DEF,FOLLOW_FUNC_DEF_in_declaration88); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_functionHeader_in_declaration90);
                    functionHeader();

                    state._fsp--;

                    pushFollow(FOLLOW_block_in_declaration92);
                    block();

                    state._fsp--;


                    match(input, Token.UP, null); 

                    }
                    break;

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "declaration"


    // $ANTLR start "variable"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:18:1: variable : ^( VAR_DEF type declarator ) ;
    public final void variable() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:19:5: ( ^( VAR_DEF type declarator ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:19:9: ^( VAR_DEF type declarator )
            {
            match(input,VAR_DEF,FOLLOW_VAR_DEF_in_variable113); 

            match(input, Token.DOWN, null); 
            pushFollow(FOLLOW_type_in_variable115);
            type();

            state._fsp--;

            pushFollow(FOLLOW_declarator_in_variable117);
            declarator();

            state._fsp--;


            match(input, Token.UP, null); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "variable"


    // $ANTLR start "declarator"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:22:1: declarator : ID ;
    public final void declarator() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:23:5: ( ID )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:23:9: ID
            {
            match(input,ID,FOLLOW_ID_in_declarator137); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "declarator"


    // $ANTLR start "functionHeader"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:26:1: functionHeader : ^( FUNC_HDR type ID ( formalParameter )+ ) ;
    public final void functionHeader() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:27:5: ( ^( FUNC_HDR type ID ( formalParameter )+ ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:27:9: ^( FUNC_HDR type ID ( formalParameter )+ )
            {
            match(input,FUNC_HDR,FOLLOW_FUNC_HDR_in_functionHeader158); 

            match(input, Token.DOWN, null); 
            pushFollow(FOLLOW_type_in_functionHeader160);
            type();

            state._fsp--;

            match(input,ID,FOLLOW_ID_in_functionHeader162); 
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:27:28: ( formalParameter )+
            int cnt3=0;
            loop3:
            do {
                int alt3=2;
                int LA3_0 = input.LA(1);

                if ( (LA3_0==ARG_DEF) ) {
                    alt3=1;
                }


                switch (alt3) {
            	case 1 :
            	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:27:28: formalParameter
            	    {
            	    pushFollow(FOLLOW_formalParameter_in_functionHeader164);
            	    formalParameter();

            	    state._fsp--;


            	    }
            	    break;

            	default :
            	    if ( cnt3 >= 1 ) break loop3;
                        EarlyExitException eee =
                            new EarlyExitException(3, input);
                        throw eee;
                }
                cnt3++;
            } while (true);


            match(input, Token.UP, null); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "functionHeader"


    // $ANTLR start "formalParameter"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:30:1: formalParameter : ^( ARG_DEF type declarator ) ;
    public final void formalParameter() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:31:5: ( ^( ARG_DEF type declarator ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:31:9: ^( ARG_DEF type declarator )
            {
            match(input,ARG_DEF,FOLLOW_ARG_DEF_in_formalParameter186); 

            match(input, Token.DOWN, null); 
            pushFollow(FOLLOW_type_in_formalParameter188);
            type();

            state._fsp--;

            pushFollow(FOLLOW_declarator_in_formalParameter190);
            declarator();

            state._fsp--;


            match(input, Token.UP, null); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "formalParameter"


    // $ANTLR start "type"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:34:1: type : ( 'int' | 'char' | 'void' | ID );
    public final void type() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:35:5: ( 'int' | 'char' | 'void' | ID )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:
            {
            if ( input.LA(1)==ID||(input.LA(1)>=INT_TYPE && input.LA(1)<=VOID) ) {
                input.consume();
                state.errorRecovery=false;
            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }


            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "type"


    // $ANTLR start "block"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:41:1: block : ^( BLOCK ( variable )* ( stat )* ) ;
    public final void block() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:42:5: ( ^( BLOCK ( variable )* ( stat )* ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:42:9: ^( BLOCK ( variable )* ( stat )* )
            {
            match(input,BLOCK,FOLLOW_BLOCK_in_block273); 

            if ( input.LA(1)==Token.DOWN ) {
                match(input, Token.DOWN, null); 
                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:42:17: ( variable )*
                loop4:
                do {
                    int alt4=2;
                    int LA4_0 = input.LA(1);

                    if ( (LA4_0==VAR_DEF) ) {
                        alt4=1;
                    }


                    switch (alt4) {
                	case 1 :
                	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:42:17: variable
                	    {
                	    pushFollow(FOLLOW_variable_in_block275);
                	    variable();

                	    state._fsp--;


                	    }
                	    break;

                	default :
                	    break loop4;
                    }
                } while (true);

                // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:42:27: ( stat )*
                loop5:
                do {
                    int alt5=2;
                    int LA5_0 = input.LA(1);

                    if ( ((LA5_0>=BLOCK && LA5_0<=FOR)||(LA5_0>=EQEQ && LA5_0<=PLUS)) ) {
                        alt5=1;
                    }


                    switch (alt5) {
                	case 1 :
                	    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:42:27: stat
                	    {
                	    pushFollow(FOLLOW_stat_in_block278);
                	    stat();

                	    state._fsp--;


                	    }
                	    break;

                	default :
                	    break loop5;
                    }
                } while (true);


                match(input, Token.UP, null); 
            }

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "block"


    // $ANTLR start "stat"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:45:1: stat : ( forStat | expr | block );
    public final void stat() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:45:5: ( forStat | expr | block )
            int alt6=3;
            switch ( input.LA(1) ) {
            case FOR:
                {
                alt6=1;
                }
                break;
            case ID:
            case EQ:
            case INT:
            case EQEQ:
            case LT:
            case PLUS:
                {
                alt6=2;
                }
                break;
            case BLOCK:
                {
                alt6=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 6, 0, input);

                throw nvae;
            }

            switch (alt6) {
                case 1 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:45:7: forStat
                    {
                    pushFollow(FOLLOW_forStat_in_stat292);
                    forStat();

                    state._fsp--;


                    }
                    break;
                case 2 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:46:7: expr
                    {
                    pushFollow(FOLLOW_expr_in_stat300);
                    expr();

                    state._fsp--;


                    }
                    break;
                case 3 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:47:7: block
                    {
                    pushFollow(FOLLOW_block_in_stat308);
                    block();

                    state._fsp--;


                    }
                    break;

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "stat"


    // $ANTLR start "forStat"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:50:1: forStat : ^( 'for' expr expr expr block ) ;
    public final void forStat() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:51:5: ( ^( 'for' expr expr expr block ) )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:51:9: ^( 'for' expr expr expr block )
            {
            match(input,FOR,FOLLOW_FOR_in_forStat328); 

            match(input, Token.DOWN, null); 
            pushFollow(FOLLOW_expr_in_forStat330);
            expr();

            state._fsp--;

            pushFollow(FOLLOW_expr_in_forStat332);
            expr();

            state._fsp--;

            pushFollow(FOLLOW_expr_in_forStat334);
            expr();

            state._fsp--;

            pushFollow(FOLLOW_block_in_forStat336);
            block();

            state._fsp--;


            match(input, Token.UP, null); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "forStat"

    public static class expr_return extends TreeRuleReturnScope {
    };

    // $ANTLR start "expr"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:54:1: expr : ( ^( EQEQ expr expr ) | ^( LT expr expr ) | ^( PLUS expr expr ) | ^( EQ ID e= expr ) | atom );
    public final SimpleCTP.expr_return expr() throws RecognitionException {
        SimpleCTP.expr_return retval = new SimpleCTP.expr_return();
        retval.start = input.LT(1);

        ANTLRCommonTree ID1=null;
        SimpleCTP.expr_return e = null;


        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:54:5: ( ^( EQEQ expr expr ) | ^( LT expr expr ) | ^( PLUS expr expr ) | ^( EQ ID e= expr ) | atom )
            int alt7=5;
            switch ( input.LA(1) ) {
            case EQEQ:
                {
                alt7=1;
                }
                break;
            case LT:
                {
                alt7=2;
                }
                break;
            case PLUS:
                {
                alt7=3;
                }
                break;
            case EQ:
                {
                alt7=4;
                }
                break;
            case ID:
            case INT:
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
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:54:9: ^( EQEQ expr expr )
                    {
                    match(input,EQEQ,FOLLOW_EQEQ_in_expr352); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_expr_in_expr354);
                    expr();

                    state._fsp--;

                    pushFollow(FOLLOW_expr_in_expr356);
                    expr();

                    state._fsp--;


                    match(input, Token.UP, null); 

                    }
                    break;
                case 2 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:55:9: ^( LT expr expr )
                    {
                    match(input,LT,FOLLOW_LT_in_expr368); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_expr_in_expr370);
                    expr();

                    state._fsp--;

                    pushFollow(FOLLOW_expr_in_expr372);
                    expr();

                    state._fsp--;


                    match(input, Token.UP, null); 

                    }
                    break;
                case 3 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:56:9: ^( PLUS expr expr )
                    {
                    match(input,PLUS,FOLLOW_PLUS_in_expr384); 

                    match(input, Token.DOWN, null); 
                    pushFollow(FOLLOW_expr_in_expr386);
                    expr();

                    state._fsp--;

                    pushFollow(FOLLOW_expr_in_expr388);
                    expr();

                    state._fsp--;


                    match(input, Token.UP, null); 

                    }
                    break;
                case 4 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:57:9: ^( EQ ID e= expr )
                    {
                    match(input,EQ,FOLLOW_EQ_in_expr400); 

                    match(input, Token.DOWN, null); 
                    ID1=(ANTLRCommonTree)match(input,ID,FOLLOW_ID_in_expr402); 
                    pushFollow(FOLLOW_expr_in_expr406);
                    e=expr();

                    state._fsp--;


                    match(input, Token.UP, null); 
                     NSLog(@"assigning %@ to variable %@", (e!=null?(input.getTokenStream().toString(
                      input.getTreeAdaptor().getTokenStartIndex(e.start),
                      input.getTreeAdaptor().getTokenStopIndex(e.start))):null), (ID1!=null?ID1.getText():null)); 

                    }
                    break;
                case 5 :
                    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:58:9: atom
                    {
                    pushFollow(FOLLOW_atom_in_expr419);
                    atom();

                    state._fsp--;


                    }
                    break;

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "expr"


    // $ANTLR start "atom"
    // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:61:1: atom : ( ID | INT );
    public final void atom() throws RecognitionException {
        try {
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:62:5: ( ID | INT )
            // /usr/local/ANTLR3-ObjC2.0-Runtime/Framework/examples/simplecTreeParser/SimpleCTP.g:
            {
            if ( input.LA(1)==ID||input.LA(1)==INT ) {
                input.consume();
                state.errorRecovery=false;
            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }


            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "atom"

    // Delegated rules


 

    public static final BitSet FOLLOW_declaration_in_program43 = new BitSet(new long[]{0x0000000000000192L});
    public static final BitSet FOLLOW_variable_in_declaration63 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FUNC_DECL_in_declaration74 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_functionHeader_in_declaration76 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_FUNC_DEF_in_declaration88 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_functionHeader_in_declaration90 = new BitSet(new long[]{0x0000000000000200L});
    public static final BitSet FOLLOW_block_in_declaration92 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_VAR_DEF_in_variable113 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_type_in_variable115 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_declarator_in_variable117 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_ID_in_declarator137 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FUNC_HDR_in_functionHeader158 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_type_in_functionHeader160 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_ID_in_functionHeader162 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_formalParameter_in_functionHeader164 = new BitSet(new long[]{0x0000000000000028L});
    public static final BitSet FOLLOW_ARG_DEF_in_formalParameter186 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_type_in_formalParameter188 = new BitSet(new long[]{0x0000000000000400L});
    public static final BitSet FOLLOW_declarator_in_formalParameter190 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_set_in_type0 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_BLOCK_in_block273 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_variable_in_block275 = new BitSet(new long[]{0x00000000000E3E18L});
    public static final BitSet FOLLOW_stat_in_block278 = new BitSet(new long[]{0x00000000000E3E08L});
    public static final BitSet FOLLOW_forStat_in_stat292 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expr_in_stat300 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_block_in_stat308 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FOR_in_forStat328 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expr_in_forStat330 = new BitSet(new long[]{0x00000000000E1C00L});
    public static final BitSet FOLLOW_expr_in_forStat332 = new BitSet(new long[]{0x00000000000E1C00L});
    public static final BitSet FOLLOW_expr_in_forStat334 = new BitSet(new long[]{0x0000000000000200L});
    public static final BitSet FOLLOW_block_in_forStat336 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_EQEQ_in_expr352 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expr_in_expr354 = new BitSet(new long[]{0x00000000000E1C00L});
    public static final BitSet FOLLOW_expr_in_expr356 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_LT_in_expr368 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expr_in_expr370 = new BitSet(new long[]{0x00000000000E1C00L});
    public static final BitSet FOLLOW_expr_in_expr372 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_PLUS_in_expr384 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_expr_in_expr386 = new BitSet(new long[]{0x00000000000E1C00L});
    public static final BitSet FOLLOW_expr_in_expr388 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_EQ_in_expr400 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_ID_in_expr402 = new BitSet(new long[]{0x00000000000E1C00L});
    public static final BitSet FOLLOW_expr_in_expr406 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_atom_in_expr419 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_atom0 = new BitSet(new long[]{0x0000000000000002L});

}