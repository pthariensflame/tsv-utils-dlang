/**
A variant of the unix 'cut' program, with the ability to reorder fields.

tsv-select is a variation on the Unix 'cut' utility, with the added ability to reorder
fields. Lines are read from files or standard input and split on a delimiter character.
Fields are written to standard output in the order listed. Fields can be listed more
than once, and fields not listed can be written out as a group.

This program is intended both as a useful utility and a D programming language example.
Functionality and constructs used include command line argument processing, file I/O,
exception handling, ranges, tuples and strings, templates, universal function call syntax
(UFCS), lambdas and functional programming constructs. Comments are more verbose than
typical to shed light on D programming constructs, but not to the level of a tutorial.

Copyright (c) 2015-2017, eBay Software Foundation
Initially written by Jon Degenhardt

License: Boost Licence 1.0 (http://boost.org/LICENSE_1_0.txt)
*/

// Module name defaults to file name, but hyphens not allowed, so set it here.
module tsv_select;

// Imports used by multiple routines. Others imports made in local context.
import std.stdio;
import std.typecons : tuple, Tuple;

// 'Heredoc' style help text. When printed it is followed by a getopt formatted option list.
auto helpText = q"EOS
Synopsis: tsv-select -f n[,n...] [options] [file...]

tsv-select reads files or standard input and writes specified fields to standard
output in the order listed. Similar to 'cut' with the ability to reorder fields.
Fields can be listed more than once, and fields not listed can be output using
the --rest option. Multiple files with header lines can be managed with the
--header option, which retains the header of the first file and drops the rest.

Examples:

   tsv-select -f 4,2,9 file1.tsv file2.tsv
   tsv-select --delimiter ' ' -f 2,4,6 --rest last file1.txt
   cat file*.tsv | tsv-select -f 3,2,1

Options:
EOS";

/** 
Container for command line options. 
 */
struct TsvSelectOptions
{
    // The allowed values for the --rest option.
    enum RestOptionVal { none, first, last };

    bool hasHeader = false;     // --H|header
    char delim = '\t';          // --d|delimiter
    size_t[] fields;            // --f|fields
    RestOptionVal rest;         // --rest none|first|last
    bool versionWanted = false; // --V|version

    /** Process command line arguments (getopt cover).
     * 
     * processArgs calls getopt to process command line arguments. It does any additional
     * validation and parameter derivations needed. A tuple is returned. First value is
     * true if command line arguments were successfully processed and execution should
     * continue, or false if an error occurred or the user asked for help. If false, the
     * second value is the appropriate exit code (0 or 1).
     *
     * Returning true (execution continues) means args have been validated and derived
     * values calculated. In addition, field indices have been converted to zero-based.
     */ 
    auto processArgs (ref string[] cmdArgs)
    {
        import std.algorithm : any, each;
        import std.getopt;
        
        try
        {
            arraySep = ",";    // Use comma to separate values in command line options
            auto r = getopt(
                cmdArgs,
                std.getopt.config.caseSensitive,
                "H|header",    "                 Treat the first line of each file as a header.", &hasHeader,
                std.getopt.config.caseInsensitive,
                "f|fields",    "n[,n...]         (Required) Fields to extract. Fields are output in the order listed.", &fields,
                "r|rest",      "none|first|last  Location for remaining fields. Default: none", &rest,
                "d|delimiter", "CHR              Character to use as field delimiter. Default: TAB. (Single byte UTF-8 characters only.)", &delim,
                std.getopt.config.caseSensitive,
                "V|version",   "                 Print version information and exit.", &versionWanted,
                std.getopt.config.caseInsensitive,
                );
            
            if (r.helpWanted)
            {
                defaultGetoptPrinter(helpText, r.options);
                return tuple(false, 0);
            }
            else if (versionWanted)
            {
                import tsvutils_version;
                writeln(tsvutilsVersionNotice("tsv-select"));
                return tuple(false, 0);
            }
        
            /* Consistency checks */
            if (fields.length == 0)
            {
                throw new Exception("Required option --f|fields was not supplied.");
            }
        
            if (fields.length > 0 && fields.any!(x => x == 0))
            {
                throw new Exception("Zero is not a valid field number (--f|fields).");
            }

            /* Derivations */
            fields.each!((ref x) => --x);  // Convert to 1-based indexing. Using 'ref' in the lambda allows the actual
                                           // field value to be modified. Otherwise a copy would be passed.
            
        }
        catch (Exception exc)
        {
            stderr.writeln("Error processing command line arguments: ", exc.msg);
            return tuple(false, 1);
        }
        return tuple(true, 0);
    }
}

/**
Main program.
 */
int main(string[] cmdArgs)
{
    /* When running in DMD code coverage mode, turn on report merging. */
    version(D_Coverage) version(DigitalMars)
    {
        import core.runtime : dmd_coverSetMerge;
        dmd_coverSetMerge(true);
    }
    
    TsvSelectOptions cmdopt;
    auto r = cmdopt.processArgs(cmdArgs);
    if (!r[0]) return r[1];
    try
    {
        /* Invoke the tsvSelect template matching the --rest option chosen. Option args
         * are removed by command line processing (getopt). The program name and any files
         * remain. Pass the files to tsvSelect.
         */
        switch (cmdopt.rest)
        {
        case TsvSelectOptions.RestOptionVal.none:
            tsvSelect!(CTERestLocation.none)(cmdopt, cmdArgs[1..$]);
            break;
        case TsvSelectOptions.RestOptionVal.first: 
            tsvSelect!(CTERestLocation.first)(cmdopt, cmdArgs[1..$]);
            break;
        case TsvSelectOptions.RestOptionVal.last: 
            tsvSelect!(CTERestLocation.last)(cmdopt, cmdArgs[1..$]);
            break;
        default:
            // Note: assert(false) triggers even in release mode compiles.
            assert(false, "Program error. Unexpected TsvSelectOptions.RestOptionVal.");
        }
    }
    catch (Exception exc)
    {
        stderr.writeln("Error: ", exc.msg);
        return 1;
    }

    return 0;
}

// tsvSelect

/**
Enumeration of the different specializations of the tsvSelect template.

CTERestLocation is logically equivalent to the TsvSelectOptions.RestOptionVal enum. It
is used by main to choose the appropriate tsvSelect template instantiation to call. It
is distinct from the TsvSelectOptions enum to separate it from the end-user UI. The
TsvSelectOptions version specifies the text of allowed values in command line arguments.
*/
enum CTERestLocation { none, first, last };

/**
tsvSelect does the primary work of the tsv-select program.
 
Input is read line by line, extracting the listed fields and writing them out in the order
specified. An exception is thrown on error.

This function is templatized with instantiations for the different --rest options. This
avoids repeatedly running the same if-tests inside the inner loop. The main function
instantiates this function three times, once for each of the --rest options. It results
in a larger program, but is faster. Run-time improvements of 25% were measured compared
to the non-templatized version. (Note: 'cte' stands for 'compile time evaluation'.)
*/
void tsvSelect(CTERestLocation cteRest)(in TsvSelectOptions cmdopt, in string[] inputFiles)
{
    import tsvutil: InputFieldReordering;
    import std.algorithm: splitter;
    import std.format: format;
    import std.range;

    // Ensure the correct template instantiation was called. 
    static if (cteRest == CTERestLocation.none)
        assert(cmdopt.rest == TsvSelectOptions.RestOptionVal.none);
    else static if (cteRest == CTERestLocation.first)
        assert(cmdopt.rest == TsvSelectOptions.RestOptionVal.first);
    else static if (cteRest == CTERestLocation.last)
        assert(cmdopt.rest == TsvSelectOptions.RestOptionVal.last);
    else
        static assert (false, "Unexpected cteRest value.");

    /* InputFieldReordering copies select fields from an input line to a new buffer.
     * The buffer is reordered in the process.
     */
    auto fieldReordering = new InputFieldReordering!char(cmdopt.fields);

    /* Fields not on the --fields list are added to a separate buffer so they can be
     * output as a group (the --rest option). This is done using an 'Appender', which
     * is faster than the ~= operator. The Appender is passed a GC allocated buffer
     * that grows as needed and is reused for each line. Typically it'll grow only
     * on the first line.
     */
    static if (cteRest != CTERestLocation.none)
    {
        auto leftOverFieldsAppender = appender!(char[][]);
    }

    /* Read each input file (or stdin) and iterate over each line. A filename of "-" is
     * interpreted as stdin, common behavior for unix command line tools.
     */
    foreach (fileNum, filename; (inputFiles.length > 0) ? inputFiles : ["-"])
    {
        auto inputStream = (filename == "-") ? stdin : filename.File();
        foreach (lineNum, line; inputStream.byLine.enumerate(1))
        {
            if (lineNum == 1 && fileNum > 0 && cmdopt.hasHeader)
            {
                continue;   // Drop the header line from all but the first file.
            }
            static if (cteRest != CTERestLocation.none)
            {
                leftOverFieldsAppender.clear;
            }
            fieldReordering.initNewLine;
            foreach (fieldIndex, fieldValue; line.splitter(cmdopt.delim).enumerate)
            {
                static if (cteRest == CTERestLocation.none)
                {
                    fieldReordering.processNextField(fieldIndex, fieldValue);
                    if (fieldReordering.allFieldsFilled) break;
                }
                else
                {
                    auto numMatched = fieldReordering.processNextField(fieldIndex, fieldValue);
                    if (numMatched == 0) leftOverFieldsAppender.put(fieldValue);
                }
            }
            // Finished with all fields in the line.
            if (!fieldReordering.allFieldsFilled)
            {
                throw new Exception(
                    format("Not enough fields in line. File: %s,  Line: %s",
                           (filename == "-") ? "Standard Input" : filename, lineNum));
            }

            // Write the re-ordered line.
            static if (cteRest == CTERestLocation.none)
            {
                writeln(fieldReordering.outputFields.join(cmdopt.delim));
            }

            else static if (cteRest == CTERestLocation.first)
            {
                if (leftOverFieldsAppender.data.length > 0)
                {
                    write(leftOverFieldsAppender.data.join(cmdopt.delim), cmdopt.delim);
                }
                writeln(fieldReordering.outputFields.join(cmdopt.delim));
            }
            else static if (cteRest == CTERestLocation.last)
            {
                write(fieldReordering.outputFields.join(cmdopt.delim));
                if (leftOverFieldsAppender.data.length > 0)
                {
                    write(cmdopt.delim, leftOverFieldsAppender.data.join(cmdopt.delim));
                }
                writeln();
            }
            else
            {
                static assert (false, "Unexpected cteRest value.");
            }
        }
    }
}
