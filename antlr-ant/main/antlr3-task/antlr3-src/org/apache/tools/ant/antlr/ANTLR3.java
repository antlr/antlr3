/*
 * Copyright  2000-2004 The Apache Software Foundation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  2006-12-29: Modified to work for antlr3 by Jürgen Pfundt
 *  2007-01-04: Some minor correction after checking code with findBugs tool
 *  2007-02-10: Adapted the grammar type recognition to the changed naming
 *              conventions for Tree Parser
 *  2007-10-17: Options "trace", "traceLexer", "traceParser" and "glib" emit
 *              warnings when being used.
 *              Added recognition of "parser grammar T".
 *              Added options "nocollapse", "noprune".
 *              ANTLR option "depend" is being used to resolve build dependencies.
 *  2007-11-15: Embedded Classpath statement had not been observed
 *              with option depend="true" (Reported by Mats Behre)
 *  2008-03-31: Support the option conversiontimeout. (Jim Idle)
 *  2007-12-31: With option "depend=true" proceed even if first pass failed so
 *              that ANTLR can spit out its errors
 *  2008-08-09: Inspecting environment variable ANTLR_HOME to detect and add
 *              antlr- and stringtemplate libraries to the classpath
 *  2008-08-09: Removed routine checkGenerateFile. It got feeble with the
 *              introduction of composed grammars, e.g. "import T.g" and after
 *              a short struggle it started it's journey to /dev/null.
 *              From now one it is always antlr itself via the depend option
 *              which decides about dependecies
 *  2008-08-19: Dependency check for composed grammars added.
 *              Might need some further improvements.
 */
package org.apache.tools.ant.antlr;

import java.util.regex.*;
import java.io.*;
import java.util.Map;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Execute;
import org.apache.tools.ant.taskdefs.LogOutputStream;
import org.apache.tools.ant.taskdefs.PumpStreamHandler;
import org.apache.tools.ant.taskdefs.Redirector;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.CommandlineJava;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.util.JavaEnvUtils;
import org.apache.tools.ant.util.LoaderUtils;
import org.apache.tools.ant.util.TeeOutputStream;
import org.apache.tools.ant.util.FileUtils;

/**
 *  Invokes the ANTLR3 Translator generator on a grammar file.
 *
 */
public class ANTLR3 extends Task {

    private CommandlineJava commandline = new CommandlineJava();
    /** the file to process */
    private File target = null;
    /** where to output the result */
    private File outputDirectory = null;
    /** location of token files */
    private File libDirectory = null;
    /** an optional super grammar file */
    private File superGrammar;
    /** depend */
    private boolean depend = false;
    /** fork */
    private boolean fork;
    /** name of output style for messages */
    private String messageFormatName;
    /** optional flag to print out a diagnostic file */
    private boolean diagnostic;
    /** optional flag to add methods */
    private boolean trace;
    /** optional flag to add trace methods to the parser only */
    private boolean traceParser;
    /** optional flag to add trace methods to the lexer only */
    private boolean traceLexer;
    /** working directory */
    private File workingdir = null;
    /** captures ANTLR's output */
    private ByteArrayOutputStream bos = new ByteArrayOutputStream();
    /** The debug attribute */
    private boolean debug;
    /** The report attribute */
    private boolean report;
    /** The print attribute */
    private boolean print;
    /** The profile attribute */
    private boolean profile;
    /** The nfa attribute */
    private boolean nfa;
    /** The dfa attribute */
    private boolean dfa;
    /** multi threaded analysis */
    private boolean multiThreaded;
    /** collapse incident edges into DFA states */
    private boolean nocollapse;
    /** test lookahead against EBNF block exit branches */
    private boolean noprune;
    /** put tags at start/stop of all templates in output */
    private boolean dbgST;
    /** print AST */
    private boolean grammarTree;
    /** Instance of a utility class to use for file operations. */
    private FileUtils fileUtils;
    /**
     * Whether to override the default conversion timeout with -Xconversiontimeout nnnn
     */
    private String conversiontimeout;

    public ANTLR3() {
        commandline.setVm(JavaEnvUtils.getJreExecutable("java"));
        commandline.setClassname("org.antlr.Tool");
        fileUtils = FileUtils.getFileUtils();
    }

    /**
     * The grammar file to process.
     */
    public void setTarget(File targetFile) {
        log("Setting target to: " + targetFile.toString(), Project.MSG_VERBOSE);
        this.target = targetFile;
    }

    /**
     * The directory to write the generated files to.
     */
    public void setOutputdirectory(File outputDirectoryFile) {
        log("Setting output directory to: " + outputDirectoryFile.toString(), Project.MSG_VERBOSE);
        this.outputDirectory = outputDirectoryFile;
    }

    /**
     * The directory to write the generated files to.
     */
    public File getOutputdirectory() {
        return outputDirectory;
    }

    /**
     * The token files output directory.
     */
    public void setLibdirectory(File libDirectoryFile) {
        log("Setting lib directory to: " + libDirectoryFile.toString(), Project.MSG_VERBOSE);
        this.libDirectory = libDirectoryFile;
    }

    /**
     * The output style for messages.
     */
    public void setMessageformat(String name) {
        log("Setting message-format to: " + name, Project.MSG_VERBOSE);
        this.messageFormatName = name;
    }

    /**
     * Sets an optional super grammar file
     * @deprecated
     */
    public void setGlib(File superGrammarFile) {
        this.superGrammar = superGrammarFile;
    }

    /**
     * Sets a flag to enable ParseView debugging
     */
    public void setDebug(boolean enable) {
        this.debug = enable;
    }

    /**
     * Sets a flag to enable report statistics
     */
    public void setReport(boolean enable) {
        this.report = enable;
    }

    /**
     * Sets a flag to print out the grammar without actions
     */
    public void setPrint(boolean enable) {
        this.print = enable;
    }

    /**
     * Sets a flag to enable profiling
     */
    public void setProfile(boolean enable) {
        this.profile = enable;
    }

    /**
     * Sets a flag to enable nfa generation
     */
    public void setNfa(boolean enable) {
        this.nfa = enable;
    }

    /**
     * Sets a flag to enable nfa generation
     */
    public void setDfa(boolean enable) {
        this.dfa = enable;
    }

    /**
     * Run the analysis multithreaded
     * @param enable
     */
    public void setMultithreaded(boolean enable) {
        multiThreaded = enable;
    }

    /**
     * collapse incident edges into DFA states
     * @param enable
     */
    public void setNocollapse(boolean enable) {
        nocollapse = enable;
    }

    /**
     * test lookahead against EBNF block exit branches
     * @param enable
     */
    public void setNoprune(boolean enable) {
        noprune = enable;
    }

    /**
     * test lookahead against EBNF block exit branches
     * @param enable
     */
    public void setDbgST(boolean enable) {
        dbgST = enable;
    }

    /**
     * override the default conversion timeout with -Xconversiontimeout nnnn
     * @param conversiontimeoutString
     */
    public void setConversiontimeout(String conversiontimeoutString) {
        log("Setting conversiontimeout to: " + conversiontimeoutString, Project.MSG_VERBOSE);
        try {
            int timeout = Integer.valueOf(conversiontimeoutString);
            this.conversiontimeout = conversiontimeoutString;
        } catch (NumberFormatException e) {
            log("Option ConversionTimeOut ignored due to illegal value: '" + conversiontimeoutString + "'", Project.MSG_ERR);
        }
    }

    /**
     * Set a flag to enable printing of the grammar tree
     */
    public void setGrammartree(boolean enable) {
        grammarTree = enable;
    }

    /**
     * Set a flag to enable dependency checking by ANTLR itself
     * The depend option is always used implicitely inside the antlr3 task
     * @deprecated
     */
    public void setDepend(boolean s) {
        this.depend = s;
    }

    /**
     * Sets a flag to emit diagnostic text
     */
    public void setDiagnostic(boolean enable) {
        diagnostic = enable;
    }

    /**
     * If true, enables all tracing.
     * @deprecated
     */
    public void setTrace(boolean enable) {
        trace = enable;
    }

    /**
     * If true, enables parser tracing.
     * @deprecated
     */
    public void setTraceParser(boolean enable) {
        traceParser = enable;
    }

    /**
     * If true, enables lexer tracing.
     * @deprecated
     */
    public void setTraceLexer(boolean enable) {
        traceLexer = enable;
    }

    // we are forced to fork ANTLR since there is a call
    // to System.exit() and there is nothing we can do
    // right now to avoid this. :-( (SBa)
    // I'm not removing this method to keep backward compatibility
    /**
     * @ant.attribute ignore="true"
     */
    public void setFork(boolean s) {
        this.fork = s;
    }

    /**
     * The working directory of the process
     */
    public void setDir(File d) {
        this.workingdir = d;
    }

    /**
     * Adds a classpath to be set
     * because a directory might be given for Antlr debug.
     */
    public Path createClasspath() {
        return commandline.createClasspath(getProject()).createPath();
    }

    /**
     * Adds a new JVM argument.
     * @return  create a new JVM argument so that any argument can be passed to the JVM.
     * @see #setFork(boolean)
     */
    public Commandline.Argument createJvmarg() {
        return commandline.createVmArgument();
    }

    /**
     * Adds the jars or directories containing Antlr and associates.
     * This should make the forked JVM work without having to
     * specify it directly.
     */
    @Override
    public void init() throws BuildException {
        /* Inquire environment variables */
        Map<String, String> variables = System.getenv();
        /* Get value for key "ANTLR_HOME" which should hopefully point to
         * the directory where the current version of antlr3 is installed */
        String antlrHome = variables.get("ANTLR_HOME");
        if (antlrHome != null) {
            /* Environment variable ANTLR_HOME has been defined.
             * Now add all antlr and stringtemplate libraries to the
             * classpath */
            addAntlrJarsToClasspath(antlrHome + "/lib");
        }
        addClasspathEntry("/antlr/ANTLRGrammarParseBehavior.class", "AntLR2");
        addClasspathEntry("/org/antlr/tool/ANTLRParser.class", "AntLR3");
        addClasspathEntry("/org/antlr/stringtemplate/StringTemplate.class", "Stringtemplate");


    }

    /**
     * Search for the given resource and add the directory or archive
     * that contains it to the classpath.
     *
     * <p>Doesn't work for archives in JDK 1.1 as the URL returned by
     * getResource doesn't contain the name of the archive.</p>
     */
    protected void addClasspathEntry(String resource, String msg) {
        /*
         * pre Ant 1.6 this method used to call getClass().getResource
         * while Ant 1.6 will call ClassLoader.getResource().
         *
         * The difference is that Class.getResource expects a leading
         * slash for "absolute" resources and will strip it before
         * delegating to ClassLoader.getResource - so we now have to
         * emulate Class's behavior.
         */
        if (resource.startsWith("/")) {
            resource = resource.substring(1);
        } else {
            resource = "org/apache/tools/ant/taskdefs/optional/" + resource;
        }

        File f = LoaderUtils.getResourceSource(getClass().getClassLoader(), resource);
        if (f != null) {
            log("Found via classpath: " + f.getAbsolutePath(), Project.MSG_VERBOSE);
            createClasspath().setLocation(f);
        } else {
            log("Couldn\'t find resource " + resource + " for library " + msg + " in external classpath", Project.MSG_VERBOSE);
        }
    }

    /**
     * If the environment variable ANTLR_HOME is defined and points
     * to the installation directory of antlr3 then look for all antlr-*.jar and
     * stringtemplate-*.jar files in the lib directory and add them
     * to the classpath.
     * This feature should make working with eclipse or netbeans projects a
     * little bit easier. As wildcards are being used for the version part
     * of the jar-archives it makes the task independent of
     * new releases. Just let ANTLR_HOME point to the new installation
     * directory.
     */
    private void addAntlrJarsToClasspath(String antlrLibDir) {
        String[] includes = {"antlr-*.jar", "stringtemplate-*.jar"};

        DirectoryScanner ds = new DirectoryScanner();
        ds.setIncludes(includes);
        ds.setBasedir(new File(antlrLibDir));
        ds.setCaseSensitive(true);
        ds.scan();

        String separator = System.getProperty("file.separator");
        String[] files = ds.getIncludedFiles();
        for (String file : files) {
            File f = new File(antlrLibDir + separator + file);
            log("Found via ANTLR_HOME: " + f.getAbsolutePath(), Project.MSG_VERBOSE);
            createClasspath().setLocation(f);
        }
    }

    @Override
    public void execute() throws BuildException {

        validateAttributes();

        // Use ANTLR itself to resolve dependencies and decide whether
        // to invoke ANTLR for compilation
        if (dependencyCheck()) {
            populateAttributes();
            commandline.createArgument().setValue(target.toString());

            log(commandline.describeCommand(), Project.MSG_VERBOSE);
            int err = 0;
            try {
                err = run(commandline.getCommandline(), new LogOutputStream(this, Project.MSG_INFO), new LogOutputStream(this, Project.MSG_WARN));
            } catch (IOException e) {
                throw new BuildException(e, getLocation());
            } finally {
                try {
                    bos.close();
                } catch (IOException e) {
                    // ignore
                }
            }

            if (err != 0) {
                throw new BuildException("ANTLR returned: " + err, getLocation());
            } else {
                Pattern p = Pattern.compile("error\\([0-9]+\\):");
                Matcher m = p.matcher(bos.toString());
                if (m.find()) {
                    throw new BuildException("ANTLR signaled an error.", getLocation());
                }
            }
        } else {
            try {
                log("All dependencies of grammar file \'" + target.getCanonicalPath() + "\' are up to date.", Project.MSG_VERBOSE);
            } catch (IOException ex) {
                log("All dependencies of grammar file \'" + target.toString() + "\' are up to date.", Project.MSG_VERBOSE);
            }
        }
    }

    /**
     * A refactored method for populating all the command line arguments based
     * on the user-specified attributes.
     */
    private void populateAttributes() {

        commandline.createArgument().setValue("-o");
        commandline.createArgument().setValue(outputDirectory.toString());

        commandline.createArgument().setValue("-lib");
        commandline.createArgument().setValue(libDirectory.toString());

        if (superGrammar != null) {
            log("Option 'glib' is not supported by ANTLR v3. Option ignored!", Project.MSG_WARN);
        }

        if (diagnostic) {
            commandline.createArgument().setValue("-diagnostic");
        }
        if (depend) {
            log("Option 'depend' is implicitely always used by ANTLR v3. Option can safely be omitted!", Project.MSG_WARN);
        }
        if (trace) {
            log("Option 'trace' is not supported by ANTLR v3. Option ignored!", Project.MSG_WARN);
        }
        if (traceParser) {
            log("Option 'traceParser' is not supported by ANTLR v3. Option ignored!", Project.MSG_WARN);
        }
        if (traceLexer) {
            log("Option 'traceLexer' is not supported by ANTLR v3. Option ignored!", Project.MSG_WARN);
        }
        if (debug) {
            commandline.createArgument().setValue("-debug");
        }
        if (report) {
            commandline.createArgument().setValue("-report");
        }
        if (print) {
            commandline.createArgument().setValue("-print");
        }
        if (profile) {
            commandline.createArgument().setValue("-profile");
        }
        if (messageFormatName != null) {
            commandline.createArgument().setValue("-message-format");
            commandline.createArgument().setValue(messageFormatName);
        }
        if (nfa) {
            commandline.createArgument().setValue("-nfa");
        }
        if (dfa) {
            commandline.createArgument().setValue("-dfa");
        }
        if (multiThreaded) {
            commandline.createArgument().setValue("-Xmultithreaded");
        }
        if (nocollapse) {
            commandline.createArgument().setValue("-Xnocollapse");
        }
        if (noprune) {
            commandline.createArgument().setValue("-Xnoprune");
        }
        if (dbgST) {
            commandline.createArgument().setValue("-XdbgST");
        }
        if (conversiontimeout != null) {
            commandline.createArgument().setValue("-Xconversiontimeout");
            commandline.createArgument().setValue(conversiontimeout);
        }
        if (grammarTree) {
            commandline.createArgument().setValue("-Xgrtree");
        }
    }

    private void validateAttributes() throws BuildException {

        if (target == null) {
            throw new BuildException("No target grammar, lexer grammar or tree parser specified!");
        } else if (!target.isFile()) {
            throw new BuildException("Target: " + target + " is not a file!");
        }

        // if no output directory is specified, use the target's directory
        if (outputDirectory == null) {
            setOutputdirectory(new File(target.getParent()));
        }

        if (!outputDirectory.isDirectory()) {
            throw new BuildException("Invalid output directory: " + outputDirectory);
        }

        if (workingdir != null && !workingdir.isDirectory()) {
            throw new BuildException("Invalid working directory: " + workingdir);
        }

        // if no libDirectory is specified, use the target's directory
        if (libDirectory == null) {
            setLibdirectory(new File(target.getParent()));
        }

        if (!libDirectory.isDirectory()) {
            throw new BuildException("Invalid lib directory: " + libDirectory);
        }
    }

    private boolean dependencyCheck() throws BuildException {
        // using "antlr -o <OutputDirectory> -lib <LibDirectory> -depend <T>"
        // to get the list of dependencies
        CommandlineJava cmdline;
        try {
            cmdline = (CommandlineJava) commandline.clone();
        } catch (java.lang.CloneNotSupportedException e) {
            throw new BuildException("Clone of commandline failed: " + e);
        }

        cmdline.createArgument().setValue("-depend");
        cmdline.createArgument().setValue("-o");
        cmdline.createArgument().setValue(outputDirectory.toString());
        cmdline.createArgument().setValue("-lib");
        cmdline.createArgument().setValue(libDirectory.toString());
        cmdline.createArgument().setValue(target.toString());

        log(cmdline.describeCommand(), Project.MSG_VERBOSE);

        // redirect output generated by ANTLR to temporary file
        Redirector r = new Redirector(this);
        File f;
        try {
            f = File.createTempFile("depend", null, getOutputdirectory());
            f.deleteOnExit();
            log("Write dependencies for '" + target.toString() + "' to file '" + f.getCanonicalPath() + "'", Project.MSG_VERBOSE);
            r.setOutput(f);
            r.setAlwaysLog(false);
            r.createStreams();
        } catch (IOException e) {
            throw new BuildException("Redirection of output failed: " + e);
        }

        // execute antlr -depend ...
        int err = 0;
        try {
            err = run(cmdline.getCommandline(), r.getOutputStream(), null);
        } catch (IOException e) {
            try {
                r.complete();
                log("Redirection of output terminated.", Project.MSG_VERBOSE);
            } catch (IOException ex) {
                log("Termination of output redirection failed: " + ex, Project.MSG_ERR);
            }
            throw new BuildException(e, getLocation());
        } finally {
            try {
                bos.close();
            } catch (IOException e) {
                // ignore
            }
        }

        try {
            r.complete();
            log("Redirection of output terminated.", Project.MSG_VERBOSE);
        } catch (IOException e) {
            log("Termination of output redirection failed: " + e, Project.MSG_ERR);
        }

        if (err != 0) {
            if (f.exists()) {
                f.delete();
            }
            if (cmdline.getClasspath() == null) {
                log("Antlr libraries not found in external classpath or embedded classpath statement ", Project.MSG_ERR);
            }
            log("Dependency check failed. ANTLR returned: " + err, Project.MSG_ERR);
            return true;
        } else {
            Pattern p = Pattern.compile("error\\([0-9]+\\):");
            Matcher m = p.matcher(bos.toString());
            if (m.find()) {
                if (f.exists()) {
                    f.delete();
                }
                // On error always recompile
                return true;
            }
        }

        boolean compile = false;

        // open temporary file
        BufferedReader in = null;
        try {
            in = new BufferedReader(new FileReader(f));
        } catch (IOException e) {
            try {
                if (in != null) {
                    in.close();
                }
            } catch (IOException ex) {
                throw new BuildException("Could not close file\'" + f.toString() + "\'.");
            }
            if (f.exists()) {
                f.delete();
            }
            try {
                throw new BuildException("Could not open \'" + f.getCanonicalPath() + "\' for reading.");
            } catch (IOException ex) {
                throw new BuildException("Could not open \'" + f.toString() + "\' for reading.");
            }
        }

        // evaluate dependencies in temporary file
        String s;

        try {
            while ((s = in.readLine()) != null) {
                String a;
                String b;
                // As the separator string in lines emitted by the depend option
                // is either " : " or ": " trim is invoked for the first file name of a line
                int to = s.indexOf(": ");
                if (to >= 0) {
                    a = s.substring(0, to).trim();
                    File lhs = new File(a);
                    if (!lhs.isFile()) {
                        log("File '" + a + "' is not a regular file", Project.MSG_VERBOSE);
                        String name = lhs.getName();
                        String[] parts = splitRightHandSide(name, "\\u002E");
                        if (parts.length <= 1) {
                            a += ".java";
                            lhs = new File(a);
                            if (lhs.isFile()) {
                                log("File '" + a + "' is a regular file last modified at " + lhs.lastModified(), Project.MSG_VERBOSE);
                            }
                        }
                    }

                    b = s.substring(to + ": ".length());
                    String[] names = splitRightHandSide(b, ", ?");
                    File aFile = new File(a);
                    for (String name : names) {
                        File bFile = new File(name);
                        log("File '" + a + "' depends on file '" + name + "'", Project.MSG_VERBOSE);
                        log("File '" + a + "' modified at " + aFile.lastModified(), Project.MSG_VERBOSE);
                        log("File '" + name + "' modified at " + bFile.lastModified(), Project.MSG_VERBOSE);
                        if (fileUtils.isUpToDate(aFile, bFile)) {
                            log("Compiling " + target + " as '" + name + "' is newer than '" + a + "'", Project.MSG_VERBOSE);
                            // Feeling not quite comfortable with touching the file
                            fileUtils.setFileLastModified(aFile, -1);
                            log("Touching file '" + a + "'", Project.MSG_VERBOSE);
                            compile = true;
                            break;
                        }
                    }
                    if (compile) {
                        break;
                    }
                }
            }
            in.close();
        } catch (IOException e) {
            if (f.exists()) {
                f.delete();
            }
            throw new BuildException("Error reading file '" + f.toString() + "'");
        }

        if (f.exists()) {
            f.delete();
        }

        return compile;
    }

    private String[] splitRightHandSide(String fileNames, String pattern) {
        String[] names = fileNames.split(pattern);
        for (String name : names) {
            log("Split right hand side '" + name + "'", Project.MSG_VERBOSE);
        }
        return names;
    }

    /** execute in a forked VM */
    private int run(String[] command, OutputStream out, OutputStream err) throws IOException {
        PumpStreamHandler psh;
        if (err == null) {
            psh = new PumpStreamHandler(out, bos);
        } else {
            psh = new PumpStreamHandler(out, new TeeOutputStream(err, bos));
        }

        Execute exe = new Execute(psh, null);

        exe.setAntRun(getProject());
        if (workingdir != null) {
            exe.setWorkingDirectory(workingdir);
        }

        exe.setCommandline(command);

        return exe.execute();
    }
}
