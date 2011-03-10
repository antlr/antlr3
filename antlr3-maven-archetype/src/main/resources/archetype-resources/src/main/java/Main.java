#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package};

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;

import java.io.*;
import ${package}.TParser.a_return;


/**
 * Test driver program for the ANTLR3 Maven Architype demo
 *
 * @author Jim Idle (jimi@temporal-wave.com)
 */
class Main {

    private static boolean makeDot = false;

    static  TLexer lexer;

    /** Just a simple test driver for the ASP parser
     * to show how to call it.
     */

    	public static void main(String[] args)
        {
            try
            {
                // Create the lexer, which we can keep reusing if we like
                //
                lexer = new TLexer();

                if  (args.length > 0)
                {
                    int s = 0;

                    if  (args[0].startsWith("-dot"))
                    {
                        makeDot = true;
                        s = 1;
                    }
                    // Recursively parse each directory, and each file on the
                    // command line
                    //
                    for (int i=s; i<args.length; i++)
                    {
                        parse(new File(args[i]));
                    }
                }
                else
                {
                    System.err.println("Usage: java -jar ${artifactId}-${version}-jar-with-dependencies.jar <directory | filename.dmo>");
                }
            }
            catch (Exception ex)
            {
                System.err.println("ANTLR demo parser threw exception:");
                ex.printStackTrace();
            }
        }

        public static void parse(File source) throws Exception
        {

            // Open the supplied file or directory
            //
            try
            {

                // From here, any exceptions are just thrown back up the chain
                //
                if (source.isDirectory())
                {
                    System.out.println("Directory: " + source.getAbsolutePath());
                    String files[] = source.list();

                    for (int i=0; i<files.length; i++)
                    {
                        parse(new File(source, files[i]));
                    }
                }

                // Else find out if it is an ASP.Net file and parse it if it is
                //
                else
                {
                    // File without paths etc
                    //
                    String sourceFile = source.getName();

                    if  (sourceFile.length() > 3)
                    {
                        String suffix = sourceFile.substring(sourceFile.length()-4).toLowerCase();

                        // Ensure that this is a DEMO script (or seemingly)
                        //
                        if  (suffix.compareTo(".dmo") == 0)
                        {
                            parseSource(source.getAbsolutePath());
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.err.println("ANTLR demo parser caught error on file open:");
                ex.printStackTrace();
            }

        }

        public static void parseSource(String source) throws Exception
        {
            // Parse an ANTLR demo file
            //
            try
            {
                // First create a file stream using the povided file/path
                // and tell the lexer that that is the character source.
                // You can also use text that you have already read of course
                // by using the string stream.
                //
                lexer.setCharStream(new ANTLRFileStream(source, "UTF8"));

                // Using the lexer as the token source, we create a token
                // stream to be consumed by the parser
                //
                CommonTokenStream tokens = new CommonTokenStream(lexer);

                // Now we need an instance of our parser
                //
                TParser parser = new TParser(tokens);

                System.out.println("file: " + source);

                // Provide some user feedback
                //
                System.out.println("    Lexer Start");
                long start = System.currentTimeMillis();
                
                // Force token load and lex (don't do this normally, 
                // it is just for timing the lexer)
                //
                tokens.LT(1);
                long lexerStop = System.currentTimeMillis();
                System.out.println("      lexed in " + (lexerStop - start) + "ms.");

                // And now we merely invoke the start rule for the parser
                //
                System.out.println("    Parser Start");
                long pStart = System.currentTimeMillis();
                a_return psrReturn = parser.a();
                long stop = System.currentTimeMillis();
                System.out.println("      Parsed in " + (stop - pStart) + "ms.");

                // If we got a valid a tree (the syntactic validity of the source code
                // was found to be solid), then let's print the tree to show we
                // did something; our testing public wants to know!
                // We do something fairly cool here and generate a graphviz/dot
                // specification for the tree, which will allow the users to visualize
                // it :-) we only do that if asked via the -dot option though as not
                // all users will hsve installed the graphviz toolset from
                // http://www.graphviz.org
                //

                // Pick up the generic tree
                //
                Tree t = (Tree)psrReturn.getTree();

                // NOw walk it with the generic tree walker, which does nothing but
                // verify the tree really.
                //
                try
                {
                    if (parser.getNumberOfSyntaxErrors() == 0) {
                        TTree walker = new TTree(new CommonTreeNodeStream(t));
                        System.out.println("    AST Walk Start${symbol_escape}n");
                        pStart = System.currentTimeMillis();
                        walker.a();
                        stop = System.currentTimeMillis();
                        System.out.println("${symbol_escape}n      AST Walked in " + (stop - pStart) + "ms.");
                     }
                }
                catch(Exception w)
                {
                    System.out.println("AST walk caused exception.");
                    w.printStackTrace();
                }

                if  (makeDot && tokens.size() < 4096)
                {

                    // Now stringify it if you want to...
                    //
                    // System.out.println(t.toStringTree());

                    // Use the ANLTR built in dot generator
                    //
                    DOTTreeGenerator gen = new DOTTreeGenerator();

                    // Which we can cause to generate the DOT specification
                    // with the input file name suffixed with .dot. You can then use
                    // the graphviz tools or zgrviewer (Java) to view the graphical
                    // version of the dot file.
                    //
                    source = source.substring(0, source.length()-3);
                    String outputName = source + "dot";

                    System.out.println("    Producing AST dot (graphviz) file");

                    // It produces a jguru string template.
                    //
                    StringTemplate st = gen.toDOT(t, new CommonTreeAdaptor());

                    // Create the output file and write the dot spec to it
                    //
                    FileWriter outputStream = new FileWriter(outputName);
                    outputStream.write(st.toString());
                    outputStream.close();

                    // Invoke dot to generate a .png file
                    //
                    System.out.println("    Producing png graphic for tree");
                    pStart = System.currentTimeMillis();
                    Process proc = Runtime.getRuntime().exec("dot -Tpng -o" + source + "png " + outputName);
                    proc.waitFor();
                    stop = System.currentTimeMillis();
                    System.out.println("      PNG graphic produced in " + (stop - pStart) + "ms.");
                }
            }
            catch (FileNotFoundException ex)
            {
                // The file we tried to parse does not exist
                //
                System.err.println("${symbol_escape}n  !!The file " + source + " does not exist!!${symbol_escape}n");
            }
            catch (Exception ex)
            {
                // Something went wrong in the parser, report this
                //
                System.err.println("Parser threw an exception:${symbol_escape}n${symbol_escape}n");
                ex.printStackTrace();
            }
        }

}
