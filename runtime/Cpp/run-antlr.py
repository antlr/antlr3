import argparse
import os
import os.path
import stat
import re
import sys

EXIT_CODE_SUCCESS = 0
EXIT_CODE_GRAMMAR_FILE_NOT_FOUND = 1
EXIT_CODE_GRAMMAR_FILE_PARSING_ERROR = 2
EXIT_CODE_INVALID_GRAMMAR_EXTENSION = 3
EXIT_CODE_RECURSIVE_IMPORTS_NOT_SUPPORTED = 4

def ensure_directory_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if os.path.exists(path) and os.path.isdir(path):
            pass
        else:
            raise exception

LEXER_GRAMMAR = 1
PARSER_GRAMMAR = 2
COMBINED_GRAMMAR = 3
TREE_PARSER_GRAMMAR = 4

IMPORT_KEYWORD = "import "

def scan_grammar(grammarFile):
    f = file(grammarFile, "r")
    retVal = None
    imports = []
    while True:
        line = f.readline()
        if line == "":
            break
        elif line.startswith("lexer grammar"):
            retVal = LEXER_GRAMMAR
        elif line.startswith("parser grammar"):
            retVal = PARSER_GRAMMAR
        elif line.startswith("grammar"):
            retVal = COMBINED_GRAMMAR
        elif line.startswith("tree grammar"):
            retVal = TREE_PARSER_GRAMMAR
            break
        elif line.startswith(IMPORT_KEYWORD):
            end = line.find(";")
            if end == -1:
                print "Failed to parse import statement"
                sys.exit(EXIT_CODE_GRAMMAR_FILE_PARSING_ERROR)
            importsStr = line[len(IMPORT_KEYWORD):end]
            for importStr in importsStr.split(","):
                imports.append(importStr.strip())
    f.close()

    if retVal != None:
        return (retVal, imports)
    else:
        print "Grammar type clause not found"
        sys.exit(EXIT_CODE_GRAMMAR_FILE_PARSING_ERROR)

def suffixes_for_grammar_type(grammarType):
    if grammarType == COMBINED_GRAMMAR:
        return [ "Lexer.hpp", "Lexer.cpp", "Parser.hpp", "Parser.cpp" ]
    else:
        return [ ".hpp", ".cpp" ]

def grammar_name(grammarFile):
    grammarName = os.path.basename(grammarFile)
    if not grammarName.endswith(".g"):
        print "Invalid grammar extension"
        sys.exit(EXIT_CODE_INVALID_GRAMMAR_EXTENSION)
    return str.split(grammarName, '.')[0]

def grammar_dir(grammarFile):
    return os.path.dirname(grammarFile)

def grammar_file(grammarDir, grammarName):
    return os.path.join(grammarDir, grammarName + ".g")

def generated_file(outputDir, rootGrammarName, grammarName, suffix):
    return os.path.join(outputDir, rootGrammarName + grammarName + suffix)

def collect_output_files(outs, grammarFiles, tokensMapping, outputDir, rootGrammarName, grammarDir, grammarName, grammarFile):
    (grammarType, imports) = scan_grammar(grammarFile)
    if rootGrammarName != "" and len(imports) > 0:
        print "Recursive grammar imports are not supported"
        sys.exit(EXIT_CODE_RECURSIVE_IMPORTS_NOT_SUPPORTED)

    antlrTokensFile = generated_file(outputDir, "", grammarName,  ".tokens")
    cxxTokensFile = generated_file(outputDir, "", grammarName,  "Tokens.hxx")
    tokensMapping[antlrTokensFile] = cxxTokensFile
    outs.append(cxxTokensFile)

    suffixes = suffixes_for_grammar_type(grammarType)
    for s in suffixes:
        path = generated_file(outputDir, rootGrammarName, grammarName, s)
        outs.append(path)

    for importedGrammarName in imports:
        grammarFile = grammar_file(grammarDir, importedGrammarName)
        grammarFiles.append(grammarFile)
        collect_output_files(outs, grammarFiles, tokensMapping, outputDir, grammarName + "_", grammarDir, importedGrammarName, grammarFile)

def output_files(outputDir, grammarName, grammarFile):
    outs = []
    grammarFiles = [ grammarFile ]
    tokensMapping = {}
    grammarDir = grammar_dir(grammarFile)
    collect_output_files(outs, grammarFiles, tokensMapping, outputDir, "", grammarDir, grammarName, grammarFile)
    return (outs, grammarFiles, tokensMapping)

def should_regenerate(outputFiles, grammarFiles, jarFile):
    lastTime = os.path.getmtime(jarFile)

    for path in grammarFiles:
        lastTime = max(lastTime, os.path.getmtime(path))

    for path in outputFiles:
        if not os.path.exists(path):
            return True
        if not os.path.isfile(path):
            return True
        if os.path.getmtime(path) < lastTime:
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
    sys.exit(EXIT_CODE_GRAMMAR_FILE_NOT_FOUND)

grammarName = grammar_name(args.grammarFile)
(outputFiles, grammarFiles, tokensMapping) = output_files(args.outputDir, grammarName, args.grammarFile)

if args.listFilesAndExit:
    # CMake uses semicolon as list separator
    print ";".join(outputFiles)
    sys.exit(EXIT_CODE_SUCCESS)

if should_regenerate(outputFiles, grammarFiles, args.jarFile):

    print "Running ANTLR..."
    
    ensure_directory_exists(args.outputDir)

    # Remove existing generated files
    for path in (outputFiles + tokensMapping.keys()):
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
    r1 = re.compile("T__[0-9]*=[0-9]*\n")
    r2 = re.compile("([A-Z0-9_][a-zA-Z0-9_]*)=([0-9]*)")
    r3 = re.compile("\'(.*)\'=([0-9]*)")
    for tokensFile, cxxTokensFile in tokensMapping.iteritems():
        antlrTokens = file(tokensFile, "r")
        cxxTokens = file(cxxTokensFile, "w")
        for line in antlrTokens:
            if r1.match(line):
                continue
            line = r2.sub("{ \\2, \"\\1\" },", line)
            line = r3.sub("{ \\2, \"\\\'\\1\\\'\" },", line)
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

sys.exit(EXIT_CODE_SUCCESS)
