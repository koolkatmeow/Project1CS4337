#lang racket
;; Prefix-notation calculator with history.
;; Usage: racket calc.rkt [-b | --batch]

;; ---- mode detection (from the provided mode-1.rkt; spec calls it interactive?) ----
(define interactive?
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]
      [(string=? (vector-ref args 0) "-b") #f]
      [(string=? (vector-ref args 0) "--batch") #f]
      [else #t])))

;; ---- helpers ----
(define (skip-ws chars)
  (cond [(and (pair? chars) (char-whitespace? (car chars)))
         (skip-ws (cdr chars))]
        [else chars]))

;; Split off the leading run of chars satisfying pred.
;; Returns (list taken-chars remaining-chars)
(define (take-while pred chars)
  (cond [(and (pair? chars) (pred (car chars)))
         (let ([r (take-while pred (cdr chars))])
           (list (cons (car chars) (car r)) (cadr r)))]
        [else (list '() chars)]))

(define (number-char? c) (or (char-numeric? c) (char=? c #\.)))

;; Division: integer division when both operands are integers, else ordinary.
;; (To get real division like the old sample runs, just change this to (/ a b).)
(define (divide a b)
  (if (and (exact-integer? a) (exact-integer? b))
      (quotient a b)
      (/ a b)))

;; ---- expression parsing/evaluation ----
;; Each function takes the remaining chars and the history (most recent first)
;; and returns (list value remaining-chars), or #f on error.

(define (eval-expr chars history)
  (let ([chars (skip-ws chars)])
    (cond
      [(null? chars) #f]
      [else
       (let ([c (car chars)] [rest (cdr chars)])
         (cond
           [(char=? c #\+) (eval-binary + rest history)]
           [(char=? c #\*) (eval-binary * rest history)]
           [(char=? c #\/) (eval-binary divide rest history)]
           [(char=? c #\-) (eval-negate rest history)]
           [(char=? c #\$) (eval-history rest history)]
           [(number-char? c) (eval-number chars)]
           [else #f]))])))

(define (eval-binary op chars history)
  (let ([left (eval-expr chars history)])
    (and left
         (let ([right (eval-expr (cadr left) history)])
           (and right
                (let ([a (car left)] [b (car right)])
                  (and (not (and (eq? op divide) (zero? b)))
                       (list (op a b) (cadr right)))))))))

(define (eval-negate chars history)
  (let ([r (eval-expr chars history)])
    (and r (list (- (car r)) (cadr r)))))

(define (eval-number chars)
  (let* ([split (take-while number-char? chars)]
         [n (string->number (list->string (car split)))])
    (and n (real? n) (list n (cadr split)))))

(define (eval-history chars history)
  (let* ([split (take-while char-numeric? chars)]
         [n (string->number (list->string (car split)))])
    (and n
         (<= 1 n (length history))
         (list (list-ref (reverse history) (- n 1)) (cadr split)))))

;; Evaluate a whole line. Returns (list 'ok value), or (list 'error message).
(define (evaluate line history)
  (let ([r (eval-expr (string->list line) history)])
    (cond
      [(not r) (list 'error "Invalid Expression")]
      [(pair? (skip-ws (cadr r))) (list 'error "Invalid Expression")]
      [else (list 'ok (car r))])))

;; ---- main loop (history is a parameter, newest first) ----
(define (loop history)
  (when interactive? (display "> ") (flush-output))
  (let ([line (read-line)])
    (cond
      [(eof-object? line) (void)]
      [(string=? line "quit") (void)]
      [else
       (let ([result (evaluate line history)])
         (cond
           [(eq? (car result) 'ok)
            (let ([new-history (cons (cadr result) history)])
              (display (length new-history))
              (display ": ")
              (displayln (real->double-flonum (cadr result)))
              (loop new-history))]
           [else
            (display "Error: ")
            (displayln (cadr result))
            (loop history)]))])))

(loop '())
