#!/usr/bin/tclsh
# Curly brackets from the same pair should be either in the same line or in the same column

proc acceptPairs {} {
    global file parens index end

    set vitiatingColumns [list]

    while {$index != $end} {
        set nextToken [lindex $parens $index]
        set tokenValue [lindex $nextToken 0]
        set tokenType [lindex $nextToken 3]

        set line [lindex $nextToken 1]

        set processingIndex $index
        incr index

        # Initially set vitiatingColumn
        # to [list] and if we find a token which might indicate the
        # existence of either an EXPECT_* or ASSERT_* or
        # or a lambda then set it to the current
        # line and use that to override the position of the
        # leftmost paren
        set expectation [string last "EXPECT_" $tokenValue]
        set assertion [string last "ASSERT_" $tokenValue]

        if {$expectation != -1 || $assertion != -1} {
            # This might be an EXPECT_EXIT or EXPECT_NO_THROW block - to test
            # that, continue until the first ( and then check if the
            # token after that is a rightbrace
            set braceSearchColumn $processingIndex
            set braceSearchColumnTokenType [lindex [lindex $parens $braceSearchColumn] 3]
            while {$braceSearchColumnTokenType != "leftparen"} {
                incr braceSearchColumn
                set braceSearchColumnTokenType [lindex [lindex $parens $braceSearchColumn] 3]
            }

            incr braceSearchColumn

            if {[lindex [lindex $parens $braceSearchColumn] 3] == "leftbrace"} {
                set vitiatingColumns [list [lindex $nextToken 2]]
                continue;
            }
        } elseif {$tokenValue == "\["} {
            # This might be a lambda. Search for the closing ] and check if an
            # opening ( is right after it
            set lambdaSearchColumn $processingIndex
            set lambdaSearchColumnTokenType [lindex [lindex $parens $lambdaSearchColumn] 3]
            while {$lambdaSearchColumnTokenType != "rightbracket"} {
                incr lambdaSearchColumn
                set lambdaSearchColumnTokenType [lindex [lindex $parens $lambdaSearchColumn] 3]
            }

            # This is a lambda if the next token is a (
            set lambdaSearchColumn [expr {$lambdaSearchColumn + 1}]
            if {[lindex [lindex $parens $lambdaSearchColumn] 3] == "leftparen"} {

                # If we hit a lambda declaration, then
                # the acceptable columns are either the
                # lambda declaration itself or the first
                # token on the line
                set vitiatingColumns [lindex $nextToken 2]
                set currentIndexOnLine $processingIndex
                set evaluatingIndex $currentIndexOnLine

                while {"true"} {
                    set previousIndex [expr {$evaluatingIndex - 1}]
                    set previousToken [lindex $parens $previousIndex]
                    set previousValue [lindex $previousToken 0]
                    set previousType [lindex $previousToken 3]

                    # Always decrement evaluatingIndex
                    set evaluatingIndex $previousIndex

                    if {$previousType == "space"} {
                        # Ignore spaces
                        continue;
                    } elseif {$previousType == "newline"} {
                        break;
                    }

                    # The is the index we actually want to revert
                    # back to later
                    set currentIndexOnLine $evaluatingIndex
                }

                set currentTokenOnLine [lindex $parens $currentIndexOnLine]
                lappend vitiatingColumns [lindex $currentTokenOnLine 2]
                continue
            }
        }

        if {[lsearch [list "rightbrace" "semicolon"] $tokenType] != -1} {
            set vitiatingColumns [list]
        }

        if {$tokenValue == "\{"} {

            set leftParenLine [lindex $nextToken 1]
            set leftParenColumns [list [lindex $nextToken 2]]

            if {[llength $vitiatingColumns] > 0} {
                set leftParenColumns ${vitiatingColumns}
            }

            # Now that we have a paren and we've either
            # substituted the vitiating line or column
            # we can reset these
            set vitiatingColumns [list]

            acceptPairs

            if {$index == $end} {
                #ignore EOF whitespace
                set thisToken [lindex $parens $index]
                set thisTokenValue [lindex $thisToken 3]
                if {$thisTokenValue == ""} {
                    return
                }

                report $file $leftParenLine "opening curly bracket is not closed"
                return
            }

            # The index will be incremented past the
            # end paren at this point, so we need to
            # use the last one
            set prevIndex [expr {$index - 1}]
            set nextToken [lindex $parens $prevIndex]
            set tokenValue [lindex $nextToken 0]

            # tokenValue must be a right brace
            if {$tokenValue == "\}"} {

                set rightParenLine [lindex $nextToken 1]
                set rightParenColumn [lindex $nextToken 2]

                set foundLeftParenColumnIndex [lsearch $leftParenColumns $rightParenColumn]

                if {($leftParenLine != $rightParenLine) && ($foundLeftParenColumnIndex == -1)} {
                    # make an exception for line continuation
                    set leftLine [getLine $file $leftParenLine]
                    set rightLine [getLine $file $rightParenLine]
                    if {[string index $leftLine end] != "\\" && [string index $rightLine end] != "\\"} {
                        set helpLines "can be column numbers: "
                        foreach line $leftParenColumns {
                            append helpLines [format "%d " $line]
                        }

                        set reportString [format "closing curly bracket not on the same line or column %s" $helpLines]

                        report $file $rightParenLine $reportString
                    }
                }
            }
        } elseif {$tokenValue == "\}"} {
            return
        }
    }
}

foreach file [getSourceFileNames] {
    set parens [getTokens $file 1 0 -1 -1 {}]
    set index 0
    set vitiatingColumn -1
    set end [llength $parens]
    acceptPairs
    if {$index != $end} {
        report $file [lindex [lindex $parens $index] 1] "excessive closing bracket?"
    }
}
