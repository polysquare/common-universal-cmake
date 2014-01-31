#!/usr/bin/tclsh
# Right-binding form of "const" is not permitted.
# Scan each sub-expression. If "const" is reached before an identifier
# then bail out

foreach f [getSourceFileNames] {
    set lineNo 1
    foreach line [getAllLines $f] {
        set caringAboutConst [expr 1]
        set scanIdentifiers {const rightparen leftparen identifier unsigned int double float char bool auto newline semicolon comma}
        set typeIdentifiers {identifier unsigned int double float char bool auto}
        set resetIdentifiers { leftparen newline semicolon comma }

        foreach t [getTokens $f $lineNo 0 [expr $lineNo + 1] -1 $scanIdentifiers] {
            set type [lindex $t 3]

            # If we hit "const" and we 'care' about const, (eg, we're inside
            # a sub-expression and haven't yet hit an identifier) then bail
            # out here.
            if {$type == "const"} {
                if {$caringAboutConst == 1} {
                    report $f $lineNo "only left-binding form of 'const' is permitted"
                }
            }

            # If we hit an type identifier, then we no longer care about
            # const this sub-expression
            foreach typeId $typeIdentifiers {
                if {$type == $typeId} {
                    set caringAboutConst [expr 0]
                }
            }

            # If we hit a "reset" identifier, then we're in a new
            # sub-expression and care about const once again
            foreach typeId $resetIdentifiers {
                if {$type == $typeId} {
                    set caringAboutConst [expr 0]
                }
            }
        }

        incr lineNo
    }
}
