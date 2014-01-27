#!/usr/bin/tclsh
# Calls to min/max should be protected against accidental macro substitution

foreach file [getSourceFileNames] {
    set previousTokenWasColonColon "false"

    foreach identifier [getTokens $file 1 0 -1 -1 {}] {
        set value [lindex $identifier 0]
        set name [lindex $identifier 3]

        # Ignore max/min when the previous token was :: as it means
        # that we're accessing a static method and not using the
        # macro
        if {$previousTokenWasColonColon == "false"} {
            if {$value == "min" || $value == "max"} {
                set lineNumber [lindex $identifier 1]
                set columnNumber [expr [lindex $identifier 2] + [string length $value]]
                set restOfLine [string range [getLine $file $lineNumber] $columnNumber end]

                if {[regexp {^[[:space:]]*\(} $restOfLine] == 1} {
                    report $file $lineNumber "min/max potential macro substitution problem"
                }
            }
        }

        set previousTokenWasColonColon "false"

        if {$name == "colon_colon" } {
            set previousTokenWasColonColon "true"
        }
    }
}

