#!/usr/bin/tclsh
# All opening brackets "()" should either be preceded by a single whitespace
# or a series of whitespace along with a new-line

foreach f [getSourceFileNames] {
    foreach t [getTokens $f 1 0 -1 -1 {leftparen}] {
        set keyword [lindex $t 0]
        set line [lindex $t 1]
        set column [lindex $t 2]
        set searchColumn [expr $column - 1]

        # Keep searching backwards until we hit either a token or the beginning
        # of the line. Error out if:
        # 1. The line counter cannot be decremented (excess whitespace before lparen)
        # 2. We found a token before us on this line, but with > 1 whitespace.
        # 3. We found a token before us on this line, but with < 1 whitespace.
        set previousTokens [getTokens $f $line $searchColumn $line [expr $searchColumn + 1] {}]
        set parenAndBracketsSize [expr 0]
        while {$searchColumn != 0} {
            set searchColumn [expr $searchColumn -1]
            set previousTokens [getTokens $f $line $searchColumn $line [expr $searchColumn + 1] {}]

            if {[llength $previousTokens] > 0} {            
                set currentToken [lindex $previousTokens 0]
                set currentTokenType [lindex $currentToken 3]
                if {$currentTokenType == "space"} {
                    set parenAndBracketsSize [expr $parenAndBracketsSize + 1]
                    continue
                } else {
                    if {$currentTokenType == "leftparen"} {
                        set parenAndBracketsSize [expr $parenAndBracketsSize + 1]
                        continue
                    } else {
                        if {$currentTokenType == "leftbracket"} {
                            set parenAndBracketsSize [expr $parenAndBracketsSize + 1]
                            continue
                        } else {
                            break
                        }
                    }
                }
            }
        }

        # If we're at the beginning of a line, its an error if
        # this is the first line in the file
        if {$searchColumn == 0} {
            if {$line > 1} {
                report $f $line "whitespace to leftparen at beginning of file"
            }
        }

        # If we're not at the beginning, then its an error if the distance
        # between our identifier and the relevant brace (taking into
        # account brackets and parens) is not equal to 1
        set currentIdentifier [lindex $previousTokens 0]
        set currentIdentifierWord [lindex $currentIdentifier 0]
        set currentIdentifierLength [string length $currentIdentifierWord]
        set distance [expr $column - $searchColumn]
        set distance [expr $distance - $currentIdentifierLength]
        set distance [expr $distance - $parenAndBracketsSize]
        
        if {$distance > 1} {
            if {$searchColumn > 0} {
                report $f $line "excess whitespace before leftparen"
            }
        } else {
            if {$distance < 1} {
                # Not enough spaces
                report $f $line "no whitespace between identifer and leftparen"
            }
        }
    }
}
