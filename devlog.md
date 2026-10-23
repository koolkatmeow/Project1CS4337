\# 10-20-2026 08:00 AM



I am starting Project 1 for CS4337, a prefix-notation calculator written in Racket.

The program has an interactive mode and a batch mode (`-b` / `--batch`), keeps a history of results that expressions can refer to with `$n`, and must report errors for bad input.

I read the project description and looked through the provided files: the mode-detection snippet and five sample input/output pairs.



Before writing code I want to settle the design.

The project tips suggest writing functions that evaluate one kind of expression and return a two element list: the value, and the characters that remain.

That fits a prefix grammar well.

An expression is a number, a `$n` reference, a unary `-`, or a binary `+`, `\*`, `/` followed by two sub-expressions.

So the evaluator reads one character to decide which case it is in, and the binary case simply calls the evaluator twice, passing the remaining characters from the first call into the second.

After the top-level expression is evaluated, any non-whitespace text left over is an error (for example `+1 2 2`).



For errors I plan to have each function return `#f` instead of the two element list when something goes wrong, and have every caller check for that and pass it up.

Racket has exceptions, but returning a failure value keeps everything as plain functions, which seems closer to what the assignment wants.



\# 10-22 09:25 PM



Notes from comparing the sample runs against the project description.

They do not agree in a few places:



\- The description says to print with `real->double-flonum`, which would print `4.0`, but the sample output shows `4`.

\- The description says `/` is integer division, but in sample 2 `/5 $1` (5 divided by 2) prints `2.5`.

\- The sample error messages are "Invalid expression" and "Unexpected trailing characters", while the description says a generic "Invalid Expression" is fine.

\- The mode snippet defines `prompt?`, but the description calls it `interactive?`.



I decided to follow the written description, since it is the actual spec for this semester and the samples look like they came from an earlier version.

I will isolate the division and the printing code so that it is easy to switch if the instructor says otherwise.

I should ask about this before the deadline.



\# 10-23 03:15 PM



Finished a first complete version, `calc.rkt`.

Pieces:



\- `eval-expr` skips whitespace, looks at the first character and dispatches.

\- `eval-binary` takes the operator as an argument so `+`, `\*` and my `divide` all share the same code. The divide-by-zero check lives here.

\- `eval-number` and `eval-history` both use a small `take-while` helper that splits off a leading run of characters and returns the run plus the rest.

\- `eval-history` reverses the history (it is stored newest first) and uses `list-ref`, and treats ids that are less than 1 or past the end as errors.

\- `evaluate` wraps the whole line and rejects leftover text.

\- `loop` takes the history as a parameter and conses each new result onto it, so there is no mutable state.



A design question I considered: whether `-` followed by a number should be read as a negative literal.

I decided not to, because the description says `-` is a unary operator, and this way `+1-1` is naturally `1 + (-1)`.

Numbers in the source never include a sign, and negatives only come from the operator.



I tested all five sample runs in batch mode.

The error cases and history references behave the same as the samples.

The only differences are the ones I listed above (`4.0` vs `4`, and integer division giving `19.0` instead of `19.5` in sample 3).

I also checked that interactive mode prints the `> ` prompt and batch mode does not.



\# 10-23 3:46 PM



Installed Racket and ran the program for the first time. Interactive mode works. `+ 3 10` gives 13.0. Also tested history (`\*$1 2`), negation (`-$1`), and division by zero (error).



\# 10-23 03:57



Racket was not on the Git Bash PATH, so I ran it by its full path.

Typing straight into batch mode in the terminal gave confusing output, but piping input in worked: `printf "+ 10 3\\n\*\\$1 2\\nquit\\n" | racket.exe calc.rkt -b` printed 1: 13.0 and 2: 26.0.

Batch mode prints only results, with no prompt.



