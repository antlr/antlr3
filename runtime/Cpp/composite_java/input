import java.io.*;
import org.antlr.runtime.*;

/** Parse a java file or directory of java files using the generated parser
 *  ANTLR builds from java.g
 */
class Main {

	static CommonTokenStream tokens = new CommonTokenStream();

    public static void main(String[] args) {
		try {
			if (args.length > 0 ) {
				// for each directory/file specified on the command line
				for(int i=0; i< args.length;i++) {
					doFile(new File(args[i])); // parse it
				}
			}
			else {
				System.err.println("Usage: java Main <directory or file name>");
			}
		}
		catch(Exception e) {
			System.err.println("exception: "+e);
			e.printStackTrace(System.err);   // so we can get stack trace
		}
	}


	// This method decides what action to take based on the type of
	//   file we are looking at
	public static void doFile(File f)
							  throws Exception {
		// If this is a directory, walk each file/dir in that directory
		if (f.isDirectory()) {
			String files[] = f.list();
			for(int i=0; i < files.length; i++)
				doFile(new File(f, files[i]));
		}

		// otherwise, if this is a java file, parse it!
		else if ((f.getName().length()>5) &&
				f.getName().substring(f.getName().length()-5).equals(".java")) {
			System.err.println("   "+f.getAbsolutePath());
			// parseFile(f.getName(), new FileInputStream(f));
			parseFile(f.getAbsolutePath());
		}
	}

	// Here's where we do the real work...
	public static void parseFile(String f)
								 throws Exception {
		try {
			// Create a scanner that reads from the input stream passed to us
			JavaParserLexer lexer = new JavaParserLexer(new ANTLRFileStream(f));
			//tokens.discardOffChannelTokens(true);
			tokens.setTokenSource(lexer);
			/*
			long t1 = System.currentTimeMillis();
			tokens.LT(1);
			long t2 = System.currentTimeMillis();
			System.out.println("lexing time: "+(t2-t1)+"ms");
			*/
			//System.out.println(tokens);

			// Create a parser that reads from the scanner
			JavaParser parser = new JavaParser(tokens);

			// start parsing at the compilationUnit rule
			parser.compilationUnit();
			
		}
		catch (Exception e) {
			System.err.println("parser exception: "+e);
			e.printStackTrace();   // so we can get stack trace		
		}
	}
	
}

