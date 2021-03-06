# Tool reference

This page provides detailed documentation about the different tools as well as examples. Material for the individual tools is also available via the `--help` option.

* [Common options and behavior](#common-options-and-behavior)
* [tsv-filter reference](#tsv-filter-reference)
* [tsv-select reference](#tsv-select-reference)
* [tsv-summarize reference](#tsv-summarize-reference)
* [tsv-join reference](#tsv-join-reference)
* [tsv-append reference](#tsv-append-reference)
* [tsv-uniq reference](#tsv-uniq-reference)
* [tsv-sample reference](#tsv-sample-reference)
* [csv2tsv reference](#csv2tsv-reference)
* [number-lines reference](#number-lines-reference)
* [keep-header reference](#keep-header-reference)

## Common options and behavior

Information in this section applies to all the tools.

### Specifying options

Multi-letter options are specified with a double dash. Single letter options can be specified with a single dash or double dash. For example:

```
$ tsv-select -f 1,2         # Valid
$ tsv-select --f 1,2        # Valid
$ tsv-select --fields 1,2   # Valid
$ tsv-select -fields 1,2    # Invalid.
```

### Help (-h, --help, --help-verbose)

All tools print help if given the `-h` or `--help` option. Many of the tools provide more details with the `--help-verbose` option.

### Field indices

Field indices are one-upped integers, following Unix conventions. Some tools use zero to represent the entire line (`tsv-join`, `tsv-uniq`).

### UTF-8 input

These tools assume data is utf-8 encoded.

### File format and alternate delimiters (--delimiter)

Any character can be used as a delimiter, TAB is the default. However, there is no escaping for including the delimiter character or newlines within a field. This differs from CSV file format which provides an escaping mechanism. In practice the lack of an escaping mechanism is not a meaningful limitation for data oriented files.

Aside from a header line, all lines are expected to have data. There is no comment mechanism and no special handling for blank lines. Tools taking field indices as arguments expect the specified fields to be available on every line.

### Headers (-H, --header)

Most tools handle the first line of files as a header when given the `-H` or `--header` option. For example, `tsv-filter` passes the header through without filtering it. When `--header` is used, all files and stdin are assumed to have header lines. Only one header line is written to stdout. If multiple files are being processed, header lines from subsequent files are discarded.

### Multiple files and standard input

Tools can read from any number of files and from standard input. As per typical Unix behavior, a single dash represents standard input when included in a list of files. Terminate non-file arguments with a double dash (--) when using a single dash in this fashion. Example:
```
$ head -n 1000 file-c.tsv | tsv-filter --eq 2:1000 -- file-a.tsv file-b.tsv - > out.tsv
```

The above passes `file-a.tsv`, `file-b.tsv`, and the first 1000 lines of `file-c.tsv` to `tsv-filter` and write the results to `out.tsv`.

## tsv-filter reference

**Synopsis:** tsv-filter [options] [file...]

Filter lines of tab-delimited files via comparison tests against fields. Multiple tests can be specified, by default they are evaluated as AND clause. Lines satisfying the tests are written to standard output.

**General options:**
* `--help` - Print help.
* `--help-verbose` - Print detailed help.
* `--help-options` - Print the options list by itself.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header.
* `--d|delimiter CHR` - Field delimiter. Default: TAB. (Single byte UTF-8 characters only.)
* `--or` - Evaluate tests as an OR rather than an AND. This applies globally.
* `--v|invert` - Invert the filter, printing lines that do not match. This applies globally.

**Tests:**

Empty and blank field tests:
* `--empty FIELD` - True if field is empty (no characters)
* `--not-empty FIELD` - True if field is not empty.
* `--blank FIELD` - True if field is empty or all whitespace.
* `--not-blank FIELD` - True if field contains a non-whitespace character.

Numeric type tests:
* `--is-numeric FIELD` - True if the field can be interpreted as a number.
* `--is-finite FIELD` - True if the field can be interpreted as a number, and it is not NaN or infinity.
* `--is-nan FIELD` - True if the field is NaN (including: "nan", "NaN", "NAN").
* `--is-infinity FIELD` - True if the field is infinity (including: "inf", "INF", "-inf", "-INF")

Numeric comparisons:
* `--le FIELD:NUM` - FIELD <= NUM (numeric).
* `--lt FIELD:NUM` - FIELD <  NUM (numeric).
* `--ge FIELD:NUM` - FIELD >= NUM (numeric).
* `--gt FIELD:NUM` - FIELD >  NUM (numeric).
* `--eq FIELD:NUM` - FIELD == NUM (numeric).
* `--ne FIELD:NUM` - FIELD != NUM (numeric).

String comparisons:
* `--str-le FIELD:STR` - FIELD <= STR (string).
* `--str-lt FIELD:STR` - FIELD <  STR (string).
* `--str-ge FIELD:STR` - FIELD >= STR (string).
* `--str-gt FIELD:STR` - FIELD >  STR (string).
* `--str-eq FIELD:STR` - FIELD == STR (string).
* `--istr-eq FIELD:STR` - FIELD == STR (string, case-insensitive).
* `--str-ne FIELD:STR` - FIELD != STR (string).
* `--istr-ne FIELD:STR` - FIELD != STR (string, case-insensitive).
* `--str-in-fld FIELD:STR` - FIELD contains STR (substring search).
* `--istr-in-fld FIELD:STR` - FIELD contains STR (substring search, case-insensitive).
* `--str-not-in-fld FIELD:STR` - FIELD does not contain STR (substring search).
* `--istr-not-in-fld FIELD:STR` - FIELD does not contain STR (substring search, case-insensitive).

Regular expression tests:
* `--regex FIELD:REGEX` - FIELD matches regular expression.
* `--iregex FIELD:REGEX` - FIELD matches regular expression, case-insensitive.
* `--not-regex FIELD:REGEX` - FIELD does not match regular expression.
* `--not-iregex FIELD:REGEX` - FIELD does not match regular expression, case-insensitive.

Field to field comparisons:
* `--ff-le FIELD1:FIELD2` - FIELD1 <= FIELD2 (numeric).
* `--ff-lt FIELD1:FIELD2` - FIELD1 <  FIELD2 (numeric).
* `--ff-ge FIELD1:FIELD2` - FIELD1 >= FIELD2 (numeric).
* `--ff-gt FIELD1:FIELD2` - FIELD1 >  FIELD2 (numeric).
* `--ff-eq FIELD1:FIELD2` - FIELD1 == FIELD2 (numeric).
* `--ff-ne FIELD1:FIELD2` - FIELD1 != FIELD2 (numeric).
* `--ff-str-eq FIELD1:FIELD2` - FIELD1 == FIELD2 (string).
* `--ff-istr-eq FIELD1:FIELD2` - FIELD1 == FIELD2 (string, case-insensitive).
* `--ff-str-ne FIELD1:FIELD2` - FIELD1 != FIELD2 (string).
* `--ff-istr-ne FIELD1:FIELD2` - FIELD1 != FIELD2 (string, case-insensitive).
* `--ff-absdiff-le FIELD1:FIELD2:NUM` - abs(FIELD1 - FIELD2) <= NUM
* `--ff-absdiff-gt FIELD1:FIELD2:NUM` - abs(FIELD1 - FIELD2)  > NUM
* `--ff-reldiff-le FIELD1:FIELD2:NUM` - abs(FIELD1 - FIELD2) / min(abs(FIELD1), abs(FIELD2)) <= NUM
* `--ff-reldiff-gt FIELD1:FIELD2:NUM` - abs(FIELD1 - FIELD2) / min(abs(FIELD1), abs(FIELD2))  > NUM

**Examples:**

Basic comparisons:
```
$ # Field 2 non-zero
$ tsv-filter --ne 2:0 data.tsv

$ # Field 1 == 0 and Field 2 >= 100, first line is a header.
$ tsv-filter --header --eq 1:0 --ge 2:100 data.tsv

$ # Field 1 == -1 or Field 1 > 100
$ tsv-filter --or --eq 1:-1 --gt 1:100

$ # Field 3 is foo, Field 4 contains bar
$ tsv-filter --header --str-eq 3:foo --str-in-fld 4:bar data.tsv

$ # Field 3 == field 4 (numeric test)
$ tsv-filter --header --ff-eq 3:4 data.tsv
```

Regular expressions:

Official regular expression syntax defined by D (<http://dlang.org/phobos/std_regex.html>), however, basic syntax is rather standard, and forms commonly used with other tools usually work as expected. This includes unicode character classes.

```
$ # Field 2 has a sequence with two a's, one or more digits, then 2 a's.
$ tsv-filter --regex '2:aa[0-9]+aa' data.tsv

$ # Same thing, except the field starts and ends with the two a's.
$ tsv-filter --regex '2:^aa[0-9]+aa$' data.tsv

$ # Field 2 is a sequence of "word" characters with two or more embedded whitespace sequences
$ tsv-filter --regex '2:^\w+\s+(\w+\s+)+\w+$' data.tsv

$ # Field 2 containing at least one cyrillic character.
$ tsv-filter --regex '2:\p{Cyrillic}' data.tsv
```

Short-circuiting expressions:

Numeric tests like `--gt` (greater-than) assume field values can be interpreted as numbers. An error occurs if the field cannot be parsed as a number, halting the program. This can be avoiding by including a testing ensure the field is recognizable as a number. For example:

```
$ # Ensure field 2 is a number before testing for greater-than 10.
$ tsv-filter --is-numeric 2 --gt 2:10 data.tsv

$ # Ensure field 2 is a number, not NaN or infinity before testing for greater-than 10.
$ tsv-filter --is-finite 2 --gt 2:10 data.tsv
```

The above tests work because `tsv-filter` short-circuits evaluation, only running as many tests as necessary to filter each line. Tests are run in the order listed on the command line. In the first example, if `--is-numeric 2` is false, the remaining tests do not get run.

## tsv-select reference

**Synopsis:** tsv-select -f n[,n...] [options] [file...]

tsv-select reads files or standard input and writes specified fields to standard output in the order listed. Similar to 'cut' with the ability to reorder fields. Fields can be listed more than once, and fields not listed can be output using the `--rest` option. When working with multiple files, the `--header` option can be used to retain only the header from the first file.

**Options:**
* `--h|help` - Print help.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header. 
* `--f|fields n[,n...]` - (Required) Fields to extract. Fields are output in the order listed.
* `--r|rest none|first|last` - Location for remaining fields. Default: none
* `--d|delimiter CHR` - Character to use as field delimiter. Default: TAB. (Single byte UTF-8 characters only.)

**Examples:**
```
$ # Output fields 2 and 1, in that order
$ tsv-select -f 2,1 --rest first data.tsv

$ # Move field 1 to the end of the line
$ tsv-select -f 1 --rest first data.tsv

$ # Move fields 7 and 3 to the start of the line
$ tsv-select -f 7,3 --rest last data.tsv
```
## tsv-summarize reference

Synopsis: tsv-summarize [options] file [file...]

tsv-summarize reads tabular data files (tab-separated by default), tracks field values for each unique key, and runs summarization algorithms. Consider the file data.tsv:
```
make    color   time
ford    blue    131
chevy   green   124
ford    red     128
bmw     black   118
bmw     black   126
ford    blue    122
```

The min and average times for each make is generated by the command:
```
$ tsv-summarize --header --group-by 1 --min 3 --mean 3 data.tsv
```

This produces:
```
make   time_min time_mean
ford   122      127
chevy  124      124
bmw    118      122
```

Using `--group-by 1,2` will group by both 'make' and 'color'. Omitting the `--group-by` entirely summarizes fields for full file.

The program tries to generate useful headers, but custom headers can be specified. Example (using `-g` and `-H` shortcuts for `--header` and `--group-by`):
```
$ tsv-summarize -H -g 1 --min 3:fastest --mean 3:average data.tsv
```

Most operators take custom headers in a similarly way, generally following:
```
--<operator-name> FIELD[:header]
```

Operators can be specified multiple times. They can also take multiple fields (though not when a custom header is specified). Example:
```
--median 2,3,4
```

The quantile operator requires one or more probabilities after the fields:
```
--quantile 2:0.25                // Quantile 1 of field 2
--quantile 2,3,4:0.25,0.5,0.75   // Q1, Median, Q3 of fields 2, 3, 4
```

Summarization operators available are:
```
   count       range        mad            values
   retain      sum          var            unique-values
   first       mean         stddev         unique-count
   last        median       mode           missing-count
   min         quantile     mode-count     not-missing-count
   max
```

Numeric values are printed to 12 significant digits by default. This can be changed using the '--p|float-precision' option. If six or less it sets the number of significant digits after the decimal point. If greater than six it sets the total number of significant digits.

Calculations hold onto the minimum data needed while reading data. A few operations like median keep all data values in memory. These operations will start to encounter performance issues as available memory becomes scarce. The size that can be handled effectively is machine dependent, but often quite large files can be handled.

Operations requiring numeric entries will signal an error and terminate processing if a non-numeric entry is found.

Missing values are not treated specially by default, this can be changed using the '--x|exclude-missing' or '--r|replace-missing' option. The former turns off processing for missing values, the latter uses a replacement value.

**Options:**
* `--h|help` - Print help.
* `--help-verbose` - Print detailed help.
* `--V|version` - Print version information and exit.
* `--g|group-by n[,n...]` - Fields to use as key.
* `--H|header` - Treat the first line of each file as a header.
* `--w|write-header` - Write an output header even if there is no input header.
* `--d|delimiter CHR` - Field delimiter. Default: TAB. (Single byte UTF-8 characters only.)
* `--v|values-delimiter CHR` - Values delimiter. Default: vertical bar (|). (Single byte UTF-8 characters only.)
* `--p|float-precision NUM` - 'Precision' to use printing floating point numbers. Affects the number of digits printed and exponent use. Default: 12
* `--x|exclude-missing` - Exclude missing (empty) fields from calculations.
* `--r|replace-missing STR` - Replace missing (empty) fields with STR in calculations.

**Operators:**
* `--count` - Count occurrences of each unique key.
* `--count-header STR` - Count occurrences of each unique key, use header STR.
* `--retain n[,n...]` - Retain one copy of the field.
* `--first n[,n...][:STR]` - First value seen.
* `--last n[,n...][:STR]`- Last value seen.
* `--min n[,n...][:STR]` - Min value. (Numeric fields only.)
* `--max n[,n...][:STR]` - Max value. (Numeric fields only.)
* `--range n[,n...][:STR]` - Difference between min and max values. (Numeric fields only.)
* `--sum n[,n...][:STR]` - Sum of the values. (Numeric fields only.)
* `--mean n[,n...][:STR]` - Mean (average). (Numeric fields only.)
* `--median n[,n...][:STR]` - Median value. (Numeric fields only. Reads all values into memory.)
* `--quantile n[,n...]:p[,p...][:STR]` - Quantiles. One or more fields, then one or more 0.0-1.0 probabilities. (Numeric fields only. Reads all values into memory.)
* `--mad n[,n...][:STR]` - Median absolute deviation from the median. Raw value, not scaled. (Numeric fields only. Reads all values into memory.)
* `--var n[,n...][:STR]` - Variance. (Sample variance, numeric fields only).
* `--stdev n[,n...][:STR]` - Standard deviation. (Sample st.dev, numeric fields only).
* `--mode n[,n...][:STR]` - Mode. The most frequent value. (Reads all unique values into memory.)
* `--mode-count n[,n...][:STR]` - Count of the most frequent value. (Reads all unique values into memory.)
* `--unique-count n[,n...][:STR]` - Number of unique values. (Reads all unique values into memory).
* `--missing-count n[,n...][:STR]` - Number of missing (empty) fields. Not affected by the '--x|exclude-missing' or '--r|replace-missing' options.
* `--not-missing-count n[,n...][:STR]` - Number of filled (non-empty) fields. Not affected by '--r|replace-missing'.
* `--values n[,n...][:STR]` - All the values, separated by --v|values-delimiter. (Reads all values into memory.)
* `--unique-values n[,n...][:STR]` - All the unique values, separated by --v|values-delimiter. (Reads all unique values into memory.)

## tsv-join reference

**Synopsis:** tsv-join --filter-file file [options] file [file...]

tsv-join matches input lines against lines from a 'filter' file. The match is based on exact match comparison of one or more 'key' fields. Fields are TAB delimited by default. Matching lines are written to standard output, along with any additional fields from the key file that have been specified.

**Options:**
* `--h|help` - Print help.
* `--h|help-verbose` - Print detailed help.
* `--V|version` - Print version information and exit.
* `--f|filter-file FILE` - (Required) File with records to use as a filter.
* `--k|key-fields n[,n...]` - Fields to use as join key. Default: 0 (entire line).
* `--d|data-fields n[,n...]` - Data record fields to use as join key, if different than --key-fields.
* `--a|append-fields n[,n...]` - Filter fields to append to matched records.
* `--H|header` - Treat the first line of each file as a header.
* `--p|prefix STR` - String to use as a prefix for --append-fields when writing a header line.
* `--w|write-all STR` - Output all data records. STR is the --append-fields value when writing unmatched records. This is an outer join.
* `--e|exclude` - Exclude matching records. This is an anti-join.
* `--delimiter CHR` - Field delimiter. Default: TAB. (Single byte UTF-8 characters only.)
* `--z|allow-duplicate-keys` - Allow duplicate keys with different append values (last entry wins). Default behavior is that this is an error.

**Examples:**

Filter one file based on another, using the full line as the key.
```
$ # Output lines in data.txt that appear in filter.txt
$ tsv-join -f filter.txt data.txt

$ # Output lines in data.txt that do not appear in filter.txt
$ tsv-join -f filter.txt --exclude data.txt
```

Filter multiple files, using fields 2 & 3 as the filter key.
```
$ tsv-join -f filter.tsv --key-fields 2,3 data1.tsv data2.tsv data3.tsv
```

Same as previous, except use field 4 & 5 from the data files.
```
$ tsv-join -f filter.tsv --key-fields 2,3 --data-fields 4,5 data1.tsv data2.tsv data3.tsv
```

Append a field from the filter file to matched records.
```
$ tsv-join -f filter.tsv --key-fields 1 --append-fields 2 data.tsv
```

Write out all records from the data file, but when there is no match, write the 'append fields' as NULL. This is an outer join.
```
$ tsv-join -f filter.tsv --key-fields 1 --append-fields 2 --write-all NULL data.tsv
```

Managing headers: Often it's useful to join a field from one data file to anther, where the data fields are related and the headers have the same name in both files. They can be kept distinct by adding a prefix to the filter file header. Example:
```
$ tsv-join -f run1.tsv --header --key-fields 1 --append-fields 2 --prefix run1_ run2.tsv
```

## tsv-append reference

**Synopsis:** tsv-append [options] [file...]

tsv-append concatenates multiple TSV files, similar to the Unix 'cat' utility. Unlike 'cat', it is header-aware ('--H|header'), writing the header from only the first file. It also supports source tracking, adding a column indicating the original file to each row. Results are written to standard output.

Concatenation with header support is useful when preparing data for traditional Unix utilities like 'sort' and 'sed' or applications that read a single file.

Source tracking is useful when creating long/narrow form tabular data, a format used by many statistics and data mining packages. In this scenario, files have been used to capture related data sets, the difference between data sets being a condition represented by the file. For example, results from different variants of an experiment might each be recorded in their own files. Retaining the source file as an output column preserves the condition represented by the file.

The file-name (without extension) is used as the source value. This can customized using the --f|file option.

Example: Header processing:

   $ tsv-append -H file1.tsv file2.tsv file3.tsv

Example: Header processing and source tracking:

   $ tsv-append -H -t file1.tsv file2.tsv file3.tsv

Example: Source tracking with custom values:

   $ tsv-append -H -s test_id -f test1=file1.tsv -f test2=file2.tsv

**Options:**
* `--h|help` - Print help.
* `--help-verbose` - Print detailed help.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header.
* `--t|track-source` - Track the source file. Adds an column with the source name.
* `--s|source-header STR` - Use STR as the header for the source column. Implies --H|header and --t|track-source. Default: 'file'
* `--f|file STR=FILE` - Read file FILE, using STR as the 'source' value. Implies --t|track-source.
* `--d|delimiter CHR` - Field delimiter. Default: TAB. (Single byte UTF-8 characters only.)

## tsv-uniq reference

tsv-uniq identifies equivalent lines in tab-separated value files. Input is read line by line, recording a key based on one or more of the fields. Two lines are equivalent if they have the same key. When operating in 'uniq' mode, the first time a key is seen the line is written to standard output, but subsequent lines are discarded. This is similar to the Unix 'uniq' program, but based on individual fields and without requiring sorted data.

The alternate to 'uniq' mode is 'equiv-class' identification. In this mode, all lines are written to standard output, but with a new field added marking equivalent entries with an ID. The ID is simply a one-upped counter.

**Synopsis:** tsv-uniq [options] [file...]

**Options:**
* `-h|help` - Print help.
* `--help-verbose` - Print detailed help.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header.
* `--f|fields n[,n...]` - Fields to use as the key. Default: 0 (entire line).
* `--i|ignore-case` - Ignore case when comparing keys.
* `--e|equiv` - Output equiv class IDs rather than uniq'ing entries.
* `--equiv-header STR` - Use STR as the equiv-id field header. Applies when using '--header --equiv'. Default: 'equiv_id'.
* `--equiv-start INT` - Use INT as the first equiv-id. Default: 1.
* `--d|delimiter CHR` - Field delimiter. Default: TAB. (Single byte UTF-8 characters only.)

**Examples:**
```
$ # Uniq a file, using the full line as the key
$ tsv-uniq data.txt

$ # Same as above, but case-insensitive
$ tsv-uniq --ignore-case data.txt

$ # Unique a file based on one field
$ tsv-unique -f 1 data.tsv

$ # Unique a file based on two fields
$ tsv-uniq -f 1,2 data.tsv

$ # Output all the lines, generating an ID for each unique entry
$ tsv-uniq -f 1,2 --equiv data.tsv

$ # Generate uniq IDs, but account for headers
$ tsv-uniq -f 1,2 --equiv --header data.tsv
```

## tsv-sample reference

**Synopsis:** tsv-sample [options] [file...]

tsv-sample randomizes or samples input lines. By default, all lines are output in random order. `--n|num` can be used to limit the sample size produced. A weighted random sample is generated using the `--f|field` option, this identifies the field containing weights. Sampling is without replacement.

Weighted random sampling is done using an algorithm described by Efraimidis and Spirakis. Weights should be positive values representing the relative weight of the entry in the collection. Negative values are not meaningful and given the value zero. However, any positive real values can be used. Lines are output ordered by the randomized weight that was assigned. This means, for example, that a smaller sample can be produced by taking the first N lines of output. For more info on the sampling approach see:
* Wikipedia: https://en.wikipedia.org/wiki/Reservoir_sampling
* "Weighted Random Sampling over Data Streams", Pavlos S. Efraimidis (https://arxiv.org/abs/1012.0256)

The implementation uses reservoir sampling. All lines output must be held in memory. Memory needed for large inputs can reduced significantly using a sample size. Both `tsv-sample -n <num>` and  `tsv-sample | head -n <num>` produce the same results, but the former is faster.

Each run produces a different randomization. This can be changed using `--s|static-seed`. This uses the same initial seed each run to produce consistent randomization orders. The random seed can also be specified using `--v|seed-value`. This takes a non-zero, 32-bit positive integer. (A zero value is a no-op and ignored.)

**Options:**

* `--help-verbose` - Print more detailed help.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header.
* `--n|num NUM` - Number of lines to output. All lines are output if not provided or zero.
* `--f|field NUM` - Field containing weights. All lines get equal weight if not provided or zero.
* `--p|print-random` - Output the random values that were assigned.
* `--s|static-seed` - Use the same random seed every run.
* `--v|seed-value NUM` - Sets the initial random seed. Use a non-zero, 32 bit positive integer. Zero is a no-op.
* `--d|delimiter CHR` - Field delimiter.
* `--h|help` - This help information.
 
## csv2tsv reference

**Synopsis:** csv2tsv [options] [file...]

csv2tsv converts CSV (comma-separated) text to TSV (tab-separated) format. Records are read from files or standard input, converted records are written to standard output.

Both formats represent tabular data, each record on its own line, fields separated by a delimiter character. The key difference is that CSV uses escape sequences to represent newlines and field separators in the data, whereas TSV disallows these characters in the data. The most common field delimiters are comma for CSV and tab for TSV, but any character can be used.

Conversion to TSV is done by removing CSV escape syntax, changing field delimiters, and replacing newlines and field delimiters in the data. By default, newlines and field delimiters in the data are replaced by spaces. Most details are customizable.

There is no single spec for CSV, any number of variants can be found. The escape syntax is common enough: fields containing newlines or field delimiters are placed in double quotes. Inside a quoted field, a double quote is represented by a pair of double quotes. As with field separators, the quoting character is customizable.

Behaviors of this program that often vary between CSV implementations:
* Newlines are supported in quoted fields.
* Double quotes are permitted in a non-quoted field. However, a field starting with a quote must follow quoting rules.
* Each record can have a different numbers of fields.
* The three common forms of newlines are supported: CR, CRLF, LF.
* A newline will be added if the file does not end with one.
* No whitespace trimming is done.

This program does not validate CSV correctness, but will terminate with an error upon reaching an inconsistent state. Improperly terminated quoted fields are the primary cause.

UTF-8 input is assumed. Convert other encodings prior to invoking this tool.

**Options:**
* `--h|help` - Print help.
* `--help-verbose` - Print detailed help.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header. Only the header of the first file is output.
* `--q|quote CHR` - Quoting character in CSV data. Default: double-quote (")
* `--c|csv-delim CHR` - Field delimiter in CSV data. Default: comma (,).
* `--t|tsv-delim CHR` - Field delimiter in TSV data. Default: TAB
* `--r|replacement STR` - Replacement for newline and TSV field delimiters found in CSV input. Default: Space.

## number-lines reference

**Synopsis:** number-lines [options] [file...]

number-lines reads from files or standard input and writes each line to standard output preceded by a line number. It is a simplified version of the Unix 'nl' program. It supports one feature 'nl' does not: the ability to treat the first line of files as a header. This is useful when working with tab-separated-value files. If header processing used, a header line is written for the first file, and the header lines are dropped from any subsequent files.

**Options:**
* `--h|help` - Print help.
* `--V|version` - Print version information and exit.
* `--H|header` - Treat the first line of each file as a header. The first input file's header is output, subsequent file headers are discarded.
* `--s|header-string STR` - String to use as the header for the line number field. Implies --header. Default: 'line'.
* `--n|start-number NUM` - Number to use for the first line. Default: 1.
* `--d|delimiter CHR` - Character appended to line number, preceding the rest of the line. Default: TAB (Single byte UTF-8 characters only.)

**Examples:**
```
$ # Number lines in a file
$ number-lines file.tsv

$ # Number lines from multiple files. Treat the first line each file as a header.
$ number-lines --header data*.tsv
```

## keep-header reference

**Synopsis:** keep-header [file...] -- program [args]

Execute a command against one or more files in a header-aware fashion. The first line of each file is assumed to be a header. The first header is output unchanged. Remaining lines are sent to the given command via standard input, excluding the header lines of subsequent files. Output from the command is appended to the initial header line. A double dash (--) delimits the command, similar to how the pipe operator (|) delimits commands.

The following commands sort files in the usual way, except for retaining a single header line:
```
$ keep-header file1.txt -- sort
$ keep-header file1.txt file2.txt -- sort -k1,1nr
```

Data can also be read from from standard input. For example:
```
$ cat file1.txt | keep-header -- sort
$ keep-header file1.txt -- sort -r | keep-header -- grep red
```

The last example can be simplified using a shell command:
```
$ keep-header file1.txt -- /bin/sh -c '(sort -r | grep red)'
```

`keep-header` is especially useful for commands like `sort` and `shuf` that reorder input lines. It is also useful with filtering commands like `grep`, many `awk` uses, and even `tail`, where the header should be retained without filtering or evaluation.

`keep-header` works on any file where the first line is delimited by a newline character. This includes all TSV files and the majority of CSV files. It won't work on CSV files having embedded newlines in the header.

**Options:**
* `--h|help` - Print help.
* `--V|version` - Print version information and exit.
