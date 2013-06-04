import argparse
import os
import os.path
import stat
import re
import sys

def ensure_directory_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if os.path.exists(path) and os.path.isdir(path):
            pass
        else:
            raise exception

COMBINED_GRAMMAR = 1
TREE_PARSER_GRAMMAR = 2

def grammar_type(grammarFile):
    f = file(grammarFile, "r")
    header = f.readline()
    f.close()
    if header.startswith("grammar"):
        return COMBINED_GRAMMAR
    if header.startswith("tree grammar"):
        return TREE_PARSER_GRAMMAR
    print "Unknown grammar type"
    sys.exit(0)

def suffixes_for_grammar_type(grammarType):
    return {
        COMBINED_GRAMMAR : [
            "Tokens.hxx",
            "Lexer.hpp",
            "Lexer.cpp",
            "Parser.hpp",
            "Parser.cpp"
        ],
        TREE_PARSER_GRAMMAR : [
            "Tokens.hxx",
            ".hpp",
            ".cpp"
        ]
    }[grammarType]

def grammar_name(grammarFile):
    grammarName = os.path.basename(grammarFile)
    return str.split(grammarName, '.')[0]

def generated_file(outputDir, grammarName, suffix):
    name = grammarName + suffix
    return outputDir + "/" + name

def generated_files(outputDir, grammarName, suffixes):
    retVal = []
    for s in suffixes:
        path = generated_file(outputDir, grammarName, s)
        retVal.append(path)
    return retVal

def should_regenerate(outputFiles, grammarFile, jarFile):
    grammarTime = os.path.getmtime(grammarFile)
    jarTime = os.path.getmtime(jarFile)
    for path in outputFiles:
        if not os.path.exists(path):
            return True
        if not os.path.isfile(path):
            return True
        t = os.path.getmtime(path) 
        if t < grammarTime or t < jarTime:
            return True
    return False

parser = argparse.ArgumentParser(description='Wrapper script for launching ANTLR.')
parser.add_argument('grammarFile', help='ANTLR grammar file to process')
parser.add_argument('-j', '--jar', dest='jarFile', help='Path to antlr-X.X-with-cpp.jar')
parser.add_argument('-o', '--output', dest='outputDir', help='Directory to put generated files')
parser.add_argument('-d', '--debug', dest='generateDebug', default=False, const=True, action='store_const', help='Add support for remote debugging')
parser.add_argument('-l', '--list', dest='listFilesAndExit', default=False, const=True, action='store_const', help='Print list generated files')
args = parser.parse_args()

if not os.path.isfile(args.grammarFile):
    print "Grammar file \"%s\" does not exist" % args.grammarFile
    sys.exit(1)

grammarName = grammar_name(args.grammarFile)
grammarType = grammar_type(args.grammarFile)
suffixes = suffixes_for_grammar_type(grammarType)
outputFiles = generated_files(args.outputDir, grammarName, suffixes)

if args.listFilesAndExit:
    # CMake uses semicolon as list separator
    print ";".join(outputFiles)
    sys.exit(0)

if should_regenerate(outputFiles, args.grammarFile, args.jarFile):

    print "Running ANTLR..."
    
    ensure_directory_exists(args.outputDir)

    tokensFile = generated_file(args.outputDir, grammarName,  ".tokens")

    # Remove existing generated files
    for path in (outputFiles + [tokensFile]):
        if os.path.exists(path):
            mode = os.stat(path).st_mode
            os.chmod(path, mode | stat.S_IWRITE | stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH)
            os.remove(path)

    # Run ANTLR
    classPath = os.path.abspath(args.jarFile)
    if "CLASSPATH" in os.environ:
        classPath = classPath + os.pathsep + os.environ["CLASSPATH"]
    os.environ["CLASSPATH"] = classPath

    commandLine = "java org.antlr.Tool -fo \"" + args.outputDir + "\""

    if args.generateDebug:
        commandLine = commandLine + " -debug"

    commandLine = commandLine + " \"" + args.grammarFile + "\""
    os.system(commandLine)

    # Pre-process tokens file for including inside C++ sources
    antlrTokens = file(tokensFile, "r")
    cxxTokens = file(outputFiles[0], "w")
    r1 = re.compile("T__[0-9]*=[0-9]*\n")
    r2 = re.compile("([A-Z0-9_][A-Z0-9_]*)=([0-9]*)")
    r3 = re.compile("\'(.*)\'=([0-9]*)")
    for line in antlrTokens:
        if r1.match(line):
            continue
        line = r2.sub("{ \\2, \"\\1\" },", line)
        line = r3.sub("{ \\2, \"\'\\1\'\" },", line)
        cxxTokens.write(line)
    antlrTokens.close()
    antlrTokens = None
    cxxTokens.close()
    cxxTokens = None

    # Make generated files read-only
    for path in outputFiles:
        os.chmod(path, stat.S_IREAD | stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH)
else:
    print "Generated files are up-to-date"
