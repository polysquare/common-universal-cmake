#!/usr/bin/tclsh
# Line cannot be too long

foreach f [getSourceFileNames] {
    set lineNumber 1
    foreach line [getAllLines $f] {
        if {[string length $line] > 80} {
            report $f $lineNumber "line is longer than 80 characters"
        }
        incr lineNumber
    }
}
