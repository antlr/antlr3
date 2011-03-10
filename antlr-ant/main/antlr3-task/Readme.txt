 Changes:
 
 19.08.2008
 Dependency check for composed grammars added.
 Might need some further improvements.
 
 09.08.2008
 Inspecting environment variable ANTLR_HOME to detect and add
 antlr- and stringtemplate libraries to the classpath
 
 09.08.2008
 Removed routine checkGenerateFile. It got feeble with the
 introduction of composed grammars, e.g. "import T.g".
 From now one it is always antlr itself via the depend option
 which decides about dependecies
 
 31.12.2007
 With option "depend=true" proceed even if first pass failed so
 that ANTLR can spit out its errors

 31.12.2007 
 Support the -Xconversiontimeout option (Jim Idle)

 21.10.2007
 Evaluation of dependencies via ANTLRs 'depend' option.
 Added noprune and nocollapse option.
 'grammar parser' will be recognized.
 
 17.05.2007
 Adapted the grammar type recognition to the changed naming conventions for tree parsers.
 Compiled the antlr3 taks with -source 5 -target 5 for compatibility with Java 5.
 Dropped trace, tracelexer and traceparser options as they are not supported by antlr any more.
 Added depend and dbgST options.
 Added project "SimpleTreeWalker" as an example for a multi grammar project.
 
 How to build the antlr3 task:
 
 Prerequisites:
 1) apache-ant-1.7.0 installed
 2) antlr jar files (antlr-3.1b1.jar, antlr-2.7.7.jar and stringtemplate-3.1b1.jar) 
    contained in the CLASSPATH environment variable
 3) Java 5 or Java 6 installed
    
 javac -source 5 -target 5 -classpath C:/Programme/apache-ant-1.7.0/lib/ant.jar org/apache/tools/ant/antlr/ANTLR3.java
 jar cvf antlr3.jar org/apache/tools/ant/antlr/antlib.xml org/apache/tools/ant/antlr/ANTLR3.class
 
 a) d2u.tp
 
 Simple example on how to use the antlr3 task with ant
 
 b) simplecTreeParser.tp
 
 Example on how to build a multi grammar project with ant.
 
 c) polydiff_build.zip
 
 Example build file for polydiff example grammar added.
 
 d) composite-java_build.zip
 
  Example build file for composite-java example grammar added