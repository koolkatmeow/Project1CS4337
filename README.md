# Project 1: Prefix Calculator

## Files
- calc.rkt: the calculator (Racket)
- devlog.md: development log
- README.md: this file

## Running
Interactive mode:   racket calc.rkt
Batch mode:         racket calc.rkt -b   (or --batch)
Batch mode reads expressions from standard input and prints only results/errors.
Example: printf "+ 10 3\nquit\n" | racket calc.rkt -b

## Notes for the TA
- Division is integer division and numbers print via real->double-flonum
  (e.g. 4.0), as written in the project description. The provided sample
  outputs show `4` and `2.5`, which disagree with the description, so
  results differ from the samples in those two ways.
- Error messages are "Error: Invalid Expression".
