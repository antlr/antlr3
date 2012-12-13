/*
 * [The "BSD license"]
 *  Copyright (c) 2010 Terence Parr
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.antlr.test;


import org.antlr.Tool;
import org.antlr.analysis.Label;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenSource;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;
import org.antlr.tool.ANTLRErrorListener;
import org.antlr.tool.ErrorManager;
import org.antlr.tool.GrammarSemanticsMessage;
import org.antlr.tool.Message;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.rules.TestRule;
import org.junit.rules.TestWatcher;
import org.junit.runner.Description;

import javax.tools.*;
import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import static org.junit.Assert.*;

public abstract class BaseTest {
	// -J-Dorg.antlr.test.BaseTest.level=FINE
	private static final Logger LOGGER = Logger.getLogger(BaseTest.class.getName());

	public static final String newline = System.getProperty("line.separator");

	public static final String jikes = null;//"/usr/bin/jikes";
	public static final String pathSep = System.getProperty("path.separator");

	public static final boolean TEST_IN_SAME_PROCESS = Boolean.parseBoolean(System.getProperty("antlr.testinprocess"));

   /**
    * When runnning from Maven, the junit tests are run via the surefire plugin. It sets the
    * classpath for the test environment into the following property. We need to pick this up
    * for the junit tests that are going to generate and try to run code.
    */
    public static final String SUREFIRE_CLASSPATH = System.getProperty("surefire.test.class.path", "");

    /**
     * Build up the full classpath we need, including the surefire path (if present)
     */
    public static final String CLASSPATH = System.getProperty("java.class.path") + (SUREFIRE_CLASSPATH.equals("") ? "" : pathSep + SUREFIRE_CLASSPATH);

	public String tmpdir = null;

	/** If error during parser execution, store stderr here; can't return
     *  stdout and stderr.  This doesn't trap errors from running antlr.
     */
	protected String stderrDuringParse;

	@Rule
	public final TestRule testWatcher = new TestWatcher() {

		@Override
		protected void succeeded(Description description) {
			// remove tmpdir if no error.
			eraseTempDir();
		}

	};

    @Before
	public void setUp() throws Exception {
        // new output dir for each test
        tmpdir = new File(System.getProperty("java.io.tmpdir"),
						  "antlr-"+getClass().getName()+"-"+
						  System.currentTimeMillis()).getAbsolutePath();
        ErrorManager.resetErrorState();
        STGroup.defaultGroup = new STGroup();
    }

    protected Tool newTool(String[] args) {
		Tool tool = new Tool(args);
		tool.setOutputDirectory(tmpdir);
		return tool;
	}

	protected Tool newTool() {
		Tool tool = new Tool();
		tool.setOutputDirectory(tmpdir);
		return tool;
	}

	protected boolean compile(String fileName) {
		String classpathOption = "-classpath";

		String[] args = new String[] {
					"javac", "-d", tmpdir,
					classpathOption, tmpdir+pathSep+CLASSPATH,
					tmpdir+"/"+fileName
		};
		String cmdLine = "javac" +" -d "+tmpdir+" "+classpathOption+" "+tmpdir+pathSep+CLASSPATH+" "+fileName;
		//System.out.println("compile: "+cmdLine);


		File f = new File(tmpdir, fileName);
		JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();

		StandardJavaFileManager fileManager =
			compiler.getStandardFileManager(null, null, null);

		Iterable<? extends JavaFileObject> compilationUnits =
			fileManager.getJavaFileObjectsFromFiles(Arrays.asList(f));

		Iterable<String> compileOptions =
			Arrays.asList(new String[]{"-d", tmpdir, "-cp", tmpdir+pathSep+CLASSPATH} );

		JavaCompiler.CompilationTask task =
			compiler.getTask(null, fileManager, null, compileOptions, null,
							 compilationUnits);
		boolean ok = task.call();

		try {
			fileManager.close();
		}
		catch (IOException ioe) {
			ioe.printStackTrace(System.err);
		}
		return ok;
	}

	/** Return true if all is ok, no errors */
	protected boolean antlr(String fileName, String grammarFileName, String grammarStr, boolean debug) {
		boolean allIsWell = true;
		mkdir(tmpdir);
		writeFile(tmpdir, fileName, grammarStr);
		try {
			final List<String> options = new ArrayList<String>();
			if ( debug ) {
				options.add("-debug");
			}
			options.add("-o");
			options.add(tmpdir);
			options.add("-lib");
			options.add(tmpdir);
			options.add(new File(tmpdir,grammarFileName).toString());
			final String[] optionsA = new String[options.size()];
			options.toArray(optionsA);
			/*
			final ErrorQueue equeue = new ErrorQueue();
			ErrorManager.setErrorListener(equeue);
			*/
			Tool antlr = newTool(optionsA);
			antlr.process();
			ANTLRErrorListener listener = ErrorManager.getErrorListener();
			if ( listener instanceof ErrorQueue ) {
				ErrorQueue equeue = (ErrorQueue)listener;
				if ( equeue.errors.size()>0 ) {
					allIsWell = false;
					System.err.println("antlr reports errors from "+options);
					for (int i = 0; i < equeue.errors.size(); i++) {
						Message msg = equeue.errors.get(i);
						System.err.println(msg);
					}
                    System.out.println("!!!\ngrammar:");
                    System.out.println(grammarStr);
                    System.out.println("###");
                }
			}
		}
		catch (Exception e) {
			allIsWell = false;
			System.err.println("problems building grammar: "+e);
			e.printStackTrace(System.err);
		}
		return allIsWell;
	}

	protected String execLexer(String grammarFileName,
							   String grammarStr,
							   String lexerName,
							   String input,
							   boolean debug)
	{
		boolean compiled = rawGenerateAndBuildRecognizer(grammarFileName,
									  grammarStr,
									  null,
									  lexerName,
									  debug);
		Assert.assertTrue(compiled);

		writeFile(tmpdir, "input", input);
		return rawExecRecognizer(null,
								 null,
								 lexerName,
								 null,
								 null,
								 false,
								 false,
								 false,
								 debug);
	}

	protected String execParser(String grammarFileName,
								String grammarStr,
								String parserName,
								String lexerName,
								String startRuleName,
								String input, boolean debug)
	{
		boolean compiled = rawGenerateAndBuildRecognizer(grammarFileName,
									  grammarStr,
									  parserName,
									  lexerName,
									  debug);
		Assert.assertTrue(compiled);

		writeFile(tmpdir, "input", input);
		boolean parserBuildsTrees =
			grammarStr.indexOf("output=AST")>=0 ||
			grammarStr.indexOf("output = AST")>=0;
		boolean parserBuildsTemplate =
			grammarStr.indexOf("output=template")>=0 ||
			grammarStr.indexOf("output = template")>=0;
		return rawExecRecognizer(parserName,
								 null,
								 lexerName,
								 startRuleName,
								 null,
								 parserBuildsTrees,
								 parserBuildsTemplate,
								 false,
								 debug);
	}

	protected String execTreeParser(String parserGrammarFileName,
									String parserGrammarStr,
									String parserName,
									String treeParserGrammarFileName,
									String treeParserGrammarStr,
									String treeParserName,
									String lexerName,
									String parserStartRuleName,
									String treeParserStartRuleName,
									String input)
	{
		return execTreeParser(parserGrammarFileName,
							  parserGrammarStr,
							  parserName,
							  treeParserGrammarFileName,
							  treeParserGrammarStr,
							  treeParserName,
							  lexerName,
							  parserStartRuleName,
							  treeParserStartRuleName,
							  input,
							  false);
	}

	protected String execTreeParser(String parserGrammarFileName,
									String parserGrammarStr,
									String parserName,
									String treeParserGrammarFileName,
									String treeParserGrammarStr,
									String treeParserName,
									String lexerName,
									String parserStartRuleName,
									String treeParserStartRuleName,
									String input,
									boolean debug)
	{
		// build the parser
		boolean compiled = rawGenerateAndBuildRecognizer(parserGrammarFileName,
									  parserGrammarStr,
									  parserName,
									  lexerName,
									  debug);
		Assert.assertTrue(compiled);

		// build the tree parser
		compiled = rawGenerateAndBuildRecognizer(treeParserGrammarFileName,
									  treeParserGrammarStr,
									  treeParserName,
									  lexerName,
									  debug);
		Assert.assertTrue(compiled);

		writeFile(tmpdir, "input", input);

		boolean parserBuildsTrees =
			parserGrammarStr.indexOf("output=AST")>=0 ||
			parserGrammarStr.indexOf("output = AST")>=0;
		boolean treeParserBuildsTrees =
			treeParserGrammarStr.indexOf("output=AST")>=0 ||
			treeParserGrammarStr.indexOf("output = AST")>=0;
		boolean parserBuildsTemplate =
			parserGrammarStr.indexOf("output=template")>=0 ||
			parserGrammarStr.indexOf("output = template")>=0;

		return rawExecRecognizer(parserName,
								 treeParserName,
								 lexerName,
								 parserStartRuleName,
								 treeParserStartRuleName,
								 parserBuildsTrees,
								 parserBuildsTemplate,
								 treeParserBuildsTrees,
								 debug);
	}

	/** Return true if all is well */
	protected boolean rawGenerateAndBuildRecognizer(String grammarFileName,
													String grammarStr,
													String parserName,
													String lexerName,
													boolean debug)
	{
		//System.out.println(grammarStr);
		boolean allIsWell =
			antlr(grammarFileName, grammarFileName, grammarStr, debug);
		if (!allIsWell) {
			return false;
		}

		if ( lexerName!=null ) {
			boolean ok;
			if ( parserName!=null ) {
				ok = compile(parserName+".java");
				if ( !ok ) { allIsWell = false; }
			}
			ok = compile(lexerName+".java");
			if ( !ok ) { allIsWell = false; }
		}
		else {
			boolean ok = compile(parserName+".java");
			if ( !ok ) { allIsWell = false; }
		}
		return allIsWell;
	}

	protected String rawExecRecognizer(String parserName,
									   String treeParserName,
									   String lexerName,
									   String parserStartRuleName,
									   String treeParserStartRuleName,
									   boolean parserBuildsTrees,
									   boolean parserBuildsTemplate,
									   boolean treeParserBuildsTrees,
									   boolean debug)
	{
        this.stderrDuringParse = null;
		writeRecognizerAndCompile(parserName, treeParserName, lexerName, parserStartRuleName, treeParserStartRuleName, parserBuildsTrees, parserBuildsTemplate, treeParserBuildsTrees, debug);

		return execRecognizer();
	}

	public String execRecognizer() {
		return execClass("Test");
	}

	public String execClass(String className) {
		if (TEST_IN_SAME_PROCESS) {
			try {
				ClassLoader loader = new URLClassLoader(new URL[] { new File(tmpdir).toURI().toURL() }, ClassLoader.getSystemClassLoader());
                final Class<?> mainClass = (Class<?>)loader.loadClass(className);
				final Method mainMethod = mainClass.getDeclaredMethod("main", String[].class);
				PipedInputStream stdoutIn = new PipedInputStream();
				PipedInputStream stderrIn = new PipedInputStream();
				PipedOutputStream stdoutOut = new PipedOutputStream(stdoutIn);
				PipedOutputStream stderrOut = new PipedOutputStream(stderrIn);
				String inputFile = new File(tmpdir, "input").getAbsolutePath();
				StreamVacuum stdoutVacuum = new StreamVacuum(stdoutIn, inputFile);
				StreamVacuum stderrVacuum = new StreamVacuum(stderrIn, inputFile);

				PrintStream originalOut = System.out;
				System.setOut(new PrintStream(stdoutOut));
				try {
					PrintStream originalErr = System.err;
					try {
						System.setErr(new PrintStream(stderrOut));
						stdoutVacuum.start();
						stderrVacuum.start();
						mainMethod.invoke(null, (Object)new String[] { inputFile });
					}
					finally {
						System.setErr(originalErr);
					}
				}
				finally {
					System.setOut(originalOut);
				}

				stdoutOut.close();
				stderrOut.close();
				stdoutVacuum.join();
				stderrVacuum.join();
				String output = stdoutVacuum.toString();
				if ( stderrVacuum.toString().length()>0 ) {
					this.stderrDuringParse = stderrVacuum.toString();
					System.err.println("exec stderrVacuum: "+ stderrVacuum);
				}
				return output;
			} catch (MalformedURLException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (IOException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (InterruptedException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (IllegalAccessException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (IllegalArgumentException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (InvocationTargetException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (NoSuchMethodException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (SecurityException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			} catch (ClassNotFoundException ex) {
				LOGGER.log(Level.SEVERE, null, ex);
			}
		}

		try {
			String inputFile = new File(tmpdir, "input").getAbsolutePath();
			String[] args = new String[] {
				"java", "-classpath", tmpdir+pathSep+CLASSPATH,
				className, inputFile
			};
			//String cmdLine = "java -classpath "+CLASSPATH+pathSep+tmpdir+" Test " + new File(tmpdir, "input").getAbsolutePath();
			//System.out.println("execParser: "+cmdLine);
			Process process =
				Runtime.getRuntime().exec(args, null, new File(tmpdir));
			StreamVacuum stdoutVacuum = new StreamVacuum(process.getInputStream(), inputFile);
			StreamVacuum stderrVacuum = new StreamVacuum(process.getErrorStream(), inputFile);
			stdoutVacuum.start();
			stderrVacuum.start();
			process.waitFor();
			stdoutVacuum.join();
			stderrVacuum.join();
			String output;
			output = stdoutVacuum.toString();
			if ( stderrVacuum.toString().length()>0 ) {
				this.stderrDuringParse = stderrVacuum.toString();
				System.err.println("exec stderrVacuum: "+ stderrVacuum);
			}
			return output;
		}
		catch (Exception e) {
			System.err.println("can't exec recognizer");
			e.printStackTrace(System.err);
		}
		return null;
	}

	public void writeRecognizerAndCompile(String parserName, String treeParserName, String lexerName, String parserStartRuleName, String treeParserStartRuleName, boolean parserBuildsTrees, boolean parserBuildsTemplate, boolean treeParserBuildsTrees, boolean debug) {
		if ( treeParserBuildsTrees && parserBuildsTrees ) {
			writeTreeAndTreeTestFile(parserName,
									 treeParserName,
									 lexerName,
									 parserStartRuleName,
									 treeParserStartRuleName,
									 debug);
		}
		else if ( parserBuildsTrees ) {
			writeTreeTestFile(parserName,
							  treeParserName,
							  lexerName,
							  parserStartRuleName,
							  treeParserStartRuleName,
							  debug);
		}
		else if ( parserBuildsTemplate ) {
			writeTemplateTestFile(parserName,
								  lexerName,
								  parserStartRuleName,
								  debug);
		}
		else if ( parserName==null ) {
			writeLexerTestFile(lexerName, debug);
		}
		else {
			writeTestFile(parserName,
						  lexerName,
						  parserStartRuleName,
						  debug);
		}

		compile("Test.java");
	}

	protected void checkGrammarSemanticsError(ErrorQueue equeue,
											  GrammarSemanticsMessage expectedMessage)
		throws Exception
	{
		/*
				System.out.println(equeue.infos);
				System.out.println(equeue.warnings);
				System.out.println(equeue.errors);
				assertTrue("number of errors mismatch", n, equeue.errors.size());
						   */
		Message foundMsg = null;
		for (int i = 0; i < equeue.errors.size(); i++) {
			Message m = equeue.errors.get(i);
			if (m.msgID==expectedMessage.msgID ) {
				foundMsg = m;
			}
		}
		assertNotNull("no error; "+expectedMessage.msgID+" expected", foundMsg);
		assertTrue("error is not a GrammarSemanticsMessage",
				   foundMsg instanceof GrammarSemanticsMessage);
		assertEquals(expectedMessage.arg, foundMsg.arg);
		if ( equeue.size()!=1 ) {
			System.err.println(equeue);
		}
	}

	protected void checkGrammarSemanticsWarning(ErrorQueue equeue,
												GrammarSemanticsMessage expectedMessage)
		throws Exception
	{
		Message foundMsg = null;
		for (int i = 0; i < equeue.warnings.size(); i++) {
			Message m = equeue.warnings.get(i);
			if (m.msgID==expectedMessage.msgID ) {
				foundMsg = m;
			}
		}
		assertNotNull("no error; "+expectedMessage.msgID+" expected", foundMsg);
		assertTrue("error is not a GrammarSemanticsMessage",
				   foundMsg instanceof GrammarSemanticsMessage);
		assertEquals(expectedMessage.arg, foundMsg.arg);
	}

    protected void checkError(ErrorQueue equeue,
                              Message expectedMessage)
        throws Exception
    {
        //System.out.println("errors="+equeue);
        Message foundMsg = null;
        for (int i = 0; i < equeue.errors.size(); i++) {
            Message m = equeue.errors.get(i);
            if (m.msgID==expectedMessage.msgID ) {
                foundMsg = m;
            }
        }
        assertTrue("no error; "+expectedMessage.msgID+" expected", equeue.errors.size()>0);
        assertTrue("too many errors; "+equeue.errors, equeue.errors.size()<=1);
        assertNotNull("couldn't find expected error: "+expectedMessage.msgID, foundMsg);
        /*
        assertTrue("error is not a GrammarSemanticsMessage",
                   foundMsg instanceof GrammarSemanticsMessage);
         */
        assertEquals(expectedMessage.arg, foundMsg.arg);
        assertEquals(expectedMessage.arg2, foundMsg.arg2);
        ErrorManager.resetErrorState(); // wack errors for next test
    }

    public static class StreamVacuum implements Runnable {
		StringBuffer buf = new StringBuffer();
		BufferedReader in;
		Thread sucker;
		String inputFile;
		public StreamVacuum(InputStream in, String inputFile) {
			this.in = new BufferedReader( new InputStreamReader(in) );
			this.inputFile = inputFile;
		}
		public void start() {
			sucker = new Thread(this);
			sucker.start();
		}
		@Override
		public void run() {
			try {
				String line = in.readLine();
				while (line!=null) {
					if (line.startsWith(inputFile))
						line = line.substring(inputFile.length()+1);
					buf.append(line);
					buf.append('\n');
					line = in.readLine();
				}
			}
			catch (IOException ioe) {
				System.err.println("can't read output from process");
			}
		}
		/** wait for the thread to finish */
		public void join() throws InterruptedException {
			sucker.join();
		}
		@Override
		public String toString() {
			return buf.toString();
		}
	}

    public static class FilteringTokenStream extends CommonTokenStream {
        public FilteringTokenStream(TokenSource src) { super(src); }
        Set<Integer> hide = new HashSet<Integer>();
		@Override
        protected void sync(int i) {
            super.sync(i);
            if ( hide.contains(get(i).getType()) ) get(i).setChannel(Token.HIDDEN_CHANNEL);
        }
        public void setTokenTypeChannel(int ttype, int channel) {
            hide.add(ttype);
        }
    }

	protected void writeFile(String dir, String fileName, String content) {
		try {
			File f = new File(dir, fileName);
			FileWriter w = new FileWriter(f);
			BufferedWriter bw = new BufferedWriter(w);
			bw.write(content);
			bw.close();
			w.close();
		}
		catch (IOException ioe) {
			System.err.println("can't write file");
			ioe.printStackTrace(System.err);
		}
	}

	protected void mkdir(String dir) {
		File f = new File(dir);
		f.mkdirs();
	}

	protected void writeTestFile(String parserName,
								 String lexerName,
								 String parserStartRuleName,
								 boolean debug)
	{
		ST outputFileST = new ST(
			"import org.antlr.runtime.*;\n" +
			"import org.antlr.runtime.tree.*;\n" +
			"import org.antlr.runtime.debug.*;\n" +
			"\n" +
			"class Profiler2 extends Profiler {\n" +
			"    public void terminate() { ; }\n" +
			"}\n"+
			"public class Test {\n" +
			"    public static void main(String[] args) throws Exception {\n" +
			"        CharStream input = new ANTLRFileStream(args[0]);\n" +
			"        <lexerName> lex = new <lexerName>(input);\n" +
			"        CommonTokenStream tokens = new CommonTokenStream(lex);\n" +
			"        <createParser>\n"+
			"        parser.<parserStartRuleName>();\n" +
			"    }\n" +
			"}"
			);
		ST createParserST =
			new ST(
			"        Profiler2 profiler = new Profiler2();\n"+
			"        <parserName> parser = new <parserName>(tokens,profiler);\n" +
			"        profiler.setParser(parser);\n");
		if ( !debug ) {
			createParserST =
				new ST(
				"        <parserName> parser = new <parserName>(tokens);\n");
		}
		outputFileST.add("createParser", createParserST);
		outputFileST.add("parserName", parserName);
		outputFileST.add("lexerName", lexerName);
		outputFileST.add("parserStartRuleName", parserStartRuleName);
		writeFile(tmpdir, "Test.java", outputFileST.render());
	}

	protected void writeLexerTestFile(String lexerName, boolean debug) {
		ST outputFileST = new ST(
			"import org.antlr.runtime.*;\n" +
			"import org.antlr.runtime.tree.*;\n" +
			"import org.antlr.runtime.debug.*;\n" +
			"\n" +
			"class Profiler2 extends Profiler {\n" +
			"    public void terminate() { ; }\n" +
			"}\n"+
			"public class Test {\n" +
			"    public static void main(String[] args) throws Exception {\n" +
			"        CharStream input = new ANTLRFileStream(args[0]);\n" +
			"        <lexerName> lex = new <lexerName>(input);\n" +
			"        CommonTokenStream tokens = new CommonTokenStream(lex);\n" +
			"        System.out.println(tokens);\n" +
			"    }\n" +
			"}"
			);
		outputFileST.add("lexerName", lexerName);
		writeFile(tmpdir, "Test.java", outputFileST.render());
	}

	protected void writeTreeTestFile(String parserName,
									 String treeParserName,
									 String lexerName,
									 String parserStartRuleName,
									 String treeParserStartRuleName,
									 boolean debug)
	{
		ST outputFileST = new ST(
			"import org.antlr.runtime.*;\n" +
			"import org.antlr.runtime.tree.*;\n" +
			"import org.antlr.runtime.debug.*;\n" +
			"\n" +
			"class Profiler2 extends Profiler {\n" +
			"    public void terminate() { ; }\n" +
			"}\n"+
			"public class Test {\n" +
			"    public static void main(String[] args) throws Exception {\n" +
			"        CharStream input = new ANTLRFileStream(args[0]);\n" +
			"        <lexerName> lex = new <lexerName>(input);\n" +
			"        TokenRewriteStream tokens = new TokenRewriteStream(lex);\n" +
			"        <createParser>\n"+
			"        <parserName>.<parserStartRuleName>_return r = parser.<parserStartRuleName>();\n" +
			"        <if(!treeParserStartRuleName)>\n" +
			"        if ( r.tree!=null ) {\n" +
			"            System.out.println(((Tree)r.tree).toStringTree());\n" +
			"            ((CommonTree)r.tree).sanityCheckParentAndChildIndexes();\n" +
			"		 }\n" +
			"        <else>\n" +
			"        CommonTreeNodeStream nodes = new CommonTreeNodeStream((Tree)r.tree);\n" +
			"        nodes.setTokenStream(tokens);\n" +
			"        <treeParserName> walker = new <treeParserName>(nodes);\n" +
			"        walker.<treeParserStartRuleName>();\n" +
			"        <endif>\n" +
			"    }\n" +
			"}"
			);
		ST createParserST =
			new ST(
			"        Profiler2 profiler = new Profiler2();\n"+
			"        <parserName> parser = new <parserName>(tokens,profiler);\n" +
			"        profiler.setParser(parser);\n");
		if ( !debug ) {
			createParserST =
				new ST(
				"        <parserName> parser = new <parserName>(tokens);\n");
		}
		outputFileST.add("createParser", createParserST);
		outputFileST.add("parserName", parserName);
		outputFileST.add("treeParserName", treeParserName);
		outputFileST.add("lexerName", lexerName);
		outputFileST.add("parserStartRuleName", parserStartRuleName);
		outputFileST.add("treeParserStartRuleName", treeParserStartRuleName);
		writeFile(tmpdir, "Test.java", outputFileST.render());
	}

	/** Parser creates trees and so does the tree parser */
	protected void writeTreeAndTreeTestFile(String parserName,
											String treeParserName,
											String lexerName,
											String parserStartRuleName,
											String treeParserStartRuleName,
											boolean debug)
	{
		ST outputFileST = new ST(
			"import org.antlr.runtime.*;\n" +
			"import org.antlr.runtime.tree.*;\n" +
			"import org.antlr.runtime.debug.*;\n" +
			"\n" +
			"class Profiler2 extends Profiler {\n" +
			"    public void terminate() { ; }\n" +
			"}\n"+
			"public class Test {\n" +
			"    public static void main(String[] args) throws Exception {\n" +
			"        CharStream input = new ANTLRFileStream(args[0]);\n" +
			"        <lexerName> lex = new <lexerName>(input);\n" +
			"        TokenRewriteStream tokens = new TokenRewriteStream(lex);\n" +
			"        <createParser>\n"+
			"        <parserName>.<parserStartRuleName>_return r = parser.<parserStartRuleName>();\n" +
			"        ((CommonTree)r.tree).sanityCheckParentAndChildIndexes();\n" +
			"        CommonTreeNodeStream nodes = new CommonTreeNodeStream((Tree)r.tree);\n" +
			"        nodes.setTokenStream(tokens);\n" +
			"        <treeParserName> walker = new <treeParserName>(nodes);\n" +
			"        <treeParserName>.<treeParserStartRuleName>_return r2 = walker.<treeParserStartRuleName>();\n" +
			"		 CommonTree rt = ((CommonTree)r2.tree);\n" +
			"		 if ( rt!=null ) System.out.println(((CommonTree)r2.tree).toStringTree());\n" +
			"    }\n" +
			"}"
			);
		ST createParserST =
			new ST(
			"        Profiler2 profiler = new Profiler2();\n"+
			"        <parserName> parser = new <parserName>(tokens,profiler);\n" +
			"        profiler.setParser(parser);\n");
		if ( !debug ) {
			createParserST =
				new ST(
				"        <parserName> parser = new <parserName>(tokens);\n");
		}
		outputFileST.add("createParser", createParserST);
		outputFileST.add("parserName", parserName);
		outputFileST.add("treeParserName", treeParserName);
		outputFileST.add("lexerName", lexerName);
		outputFileST.add("parserStartRuleName", parserStartRuleName);
		outputFileST.add("treeParserStartRuleName", treeParserStartRuleName);
		writeFile(tmpdir, "Test.java", outputFileST.render());
	}

	protected void writeTemplateTestFile(String parserName,
										 String lexerName,
										 String parserStartRuleName,
										 boolean debug)
	{
		ST outputFileST = new ST(
			"import org.antlr.runtime.*;\n" +
			"import org.antlr.stringtemplate.*;\n" +
			"import org.antlr.stringtemplate.language.*;\n" +
			"import org.antlr.runtime.debug.*;\n" +
			"import java.io.*;\n" +
			"\n" +
			"class Profiler2 extends Profiler {\n" +
			"    public void terminate() { ; }\n" +
			"}\n"+
			"public class Test {\n" +
			"    static String templates = \"group T; foo(x,y) ::= \\\"\\<x> \\<y>\\\"\";\n" +
			"    static StringTemplateGroup group ="+
			"    		new StringTemplateGroup(new StringReader(templates)," +
			"					AngleBracketTemplateLexer.class);"+
			"    public static void main(String[] args) throws Exception {\n" +
			"        CharStream input = new ANTLRFileStream(args[0]);\n" +
			"        <lexerName> lex = new <lexerName>(input);\n" +
			"        CommonTokenStream tokens = new CommonTokenStream(lex);\n" +
			"        <createParser>\n"+
			"		 parser.setTemplateLib(group);\n"+
			"        <parserName>.<parserStartRuleName>_return r = parser.<parserStartRuleName>();\n" +
			"        if ( r.st!=null )\n" +
			"            System.out.print(r.st.toString());\n" +
			"	 	 else\n" +
			"            System.out.print(\"\");\n" +
			"    }\n" +
			"}"
			);
		ST createParserST =
			new ST(
			"        Profiler2 profiler = new Profiler2();\n"+
			"        <parserName> parser = new <parserName>(tokens,profiler);\n" +
			"        profiler.setParser(parser);\n");
		if ( !debug ) {
			createParserST =
				new ST(
				"        <parserName> parser = new <parserName>(tokens);\n");
		}
		outputFileST.add("createParser", createParserST);
		outputFileST.add("parserName", parserName);
		outputFileST.add("lexerName", lexerName);
		outputFileST.add("parserStartRuleName", parserStartRuleName);
		writeFile(tmpdir, "Test.java", outputFileST.render());
	}

    protected void eraseFiles(final String filesEndingWith) {
        File tmpdirF = new File(tmpdir);
        String[] files = tmpdirF.list();
        for(int i = 0; files!=null && i < files.length; i++) {
            if ( files[i].endsWith(filesEndingWith) ) {
                new File(tmpdir+"/"+files[i]).delete();
            }
        }
    }

    protected void eraseFiles() {
        File tmpdirF = new File(tmpdir);
        String[] files = tmpdirF.list();
        for(int i = 0; files!=null && i < files.length; i++) {
            new File(tmpdir+"/"+files[i]).delete();
        }
    }

    protected void eraseTempDir() {
        File tmpdirF = new File(tmpdir);
        if ( tmpdirF.exists() ) {
            eraseFiles();
            tmpdirF.delete();
        }
    }

	public String getFirstLineOfException() {
		if ( this.stderrDuringParse ==null ) {
			return null;
		}
		String[] lines = this.stderrDuringParse.split("\n");
		String prefix="Exception in thread \"main\" ";
		return lines[0].substring(prefix.length(),lines[0].length());
	}

	public <T> List<T> realElements(List<T> elements) {
		List<T> n = new ArrayList<T>();
		for (int i = Label.NUM_FAUX_LABELS+Label.MIN_TOKEN_TYPE - 1; i < elements.size(); i++) {
			T o = elements.get(i);
			if ( o!=null ) {
				n.add(o);
			}
		}
		return n;
	}

	public List<String> realElements(Map<String, Integer> elements) {
		List<String> n = new ArrayList<String>();
		for (Map.Entry<String, Integer> entry : elements.entrySet()) {
			String tokenID = entry.getKey();
			if ( entry.getValue() >= Label.MIN_TOKEN_TYPE ) {
				n.add(tokenID+"="+entry.getValue());
			}
		}
		Collections.sort(n);
		return n;
	}

    public String sortLinesInString(String s) {
        String lines[] = s.split("\n");
        Arrays.sort(lines);
        List<String> linesL = Arrays.asList(lines);
        StringBuilder buf = new StringBuilder();
        for (String l : linesL) {
            buf.append(l);
            buf.append('\n');
        }
        return buf.toString();
    }

    /**
     * When looking at a result set that consists of a Map/HashTable
     * we cannot rely on the output order, as the hashing algorithm or other aspects
     * of the implementation may be different on differnt JDKs or platforms. Hence
     * we take the Map, convert the keys to a List, sort them and Stringify the Map, which is a
     * bit of a hack, but guarantees that we get the same order on all systems. We assume that
     * the keys are strings.
     *
     * @param m The Map that contains keys we wish to return in sorted order
     * @return A string that represents all the keys in sorted order.
     */
    public <K, V> String sortMapToString(Map<K, V> m) {

        System.out.println("Map toString looks like: " + m.toString());
        // Pass in crap, and get nothing back
        //
        if  (m == null) {
            return null;
        }

        // Sort the keys in the Map
        //
        TreeMap<K, V> nset = new TreeMap<K, V>(m);

        System.out.println("Tree map looks like: " + nset.toString());
        return nset.toString();
    }
}
