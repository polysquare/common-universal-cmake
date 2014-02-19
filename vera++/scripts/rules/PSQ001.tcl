#!/usr/bin/tclsh
# All opening brackets "()" should either be preceded by a single whitespace
# or a series of whitespace along with a new-line

foreach f [getSourceFileNames] {
    foreach t [getTokens $f 1 0 -1 -1 {leftparen less}] {
        set keyword [lindex $t 0]
        set line [lindex $t 1]
        set column [lindex $t 2]
        set type [lindex $t 3]
        set searchColumn [expr $column]

        set leftIgnoreTokens { star and not leftparen leftbracket rightbracket less }

        # Keep searching backwards until we hit either a token or the beginning
        # of the line. Error out if:
        # 1. The line counter cannot be decremented (excess whitespace before lparen)
        # 2. We found a token before us on this line, but with > 1 whitespace.
        # 3. We found a token before us on this line, but with < 1 whitespace.
        set previousTokens [getTokens $f $line $searchColumn $line [expr $searchColumn + 1] {}]
        set skipChecks [expr 0]
        while {$searchColumn != 0} {
            set searchColumn [expr $searchColumn -1]
            set previousTokens [getTokens $f $line $searchColumn $line [expr $searchColumn + 1] {}]

            if {[llength $previousTokens] > 0} {            
                set currentToken [lindex $previousTokens 0]
                set currentTokenType [lindex $currentToken 3]
                if {$currentTokenType == "space"} {
                    continue
                } else {
                    # Found a token, determine if we either want
                    # to do checks or skip them entirely
                    foreach ignoreToken $leftIgnoreTokens {
                        if {$ignoreToken == $currentTokenType} {
                            set skipChecks [expr 1]
                        }
                    }

                    break
                }
            }
        }

        if {$skipChecks == 1} {
            continue
        }

        if {[llength $previousTokens] > 0} {
            set token [lindex $previousTokens 0]
            if {[lindex $token 3] != "space"} {
                set tokenLen [string length [lindex $token 0]]
                set searchColumn [expr $searchColumn + $tokenLen]
            }
        }

        # If we're at the beginning of a line, its an error if
        # this is the first line in the file
        if {$searchColumn == 0} {
            if {$line == 1} {
                report $f $line "whitespace to leftparen at beginning of file"
            }
        }

        # If we're not at the beginning, then its an error if the distance
        # between our identifier and the relevant brace (taking into
        # account brackets and parens) is not equal to 1
        set distance [expr $column - $searchColumn]
        
        if {$distance > 1} {
            if {$searchColumn > 0} {
                report $f $line "excess whitespace before leftparen"
            }
        } else {
            if {$distance < 1} {
                # Not enough spaces and identifier is not next to a square
                # bracket
                if {$type != "leftbracket"} {
                    report $f $line "no whitespace between identifer and leftparen"
                }
            }
        }
    }
}
