(use-modules (ice-9 textual-ports))
(use-modules (ice-9 regex))
(use-modules (srfi srfi-19))

(define raw-regex (make-regexp "([0-9]+),([0-9]+)"))

(define (split-raw-rec line)
  (let* ((split (regexp-exec raw-regex line))
         (date (match:substring split 1))
         (cases (match:substring split 2)))
    (list (string->date date "~Y~m~d") (string->number cases))))

(define (read-raw-csv port prev)
  (let ((line (get-line port)))
    (if (eof-object? line)
      (reverse prev)
      (read-raw-csv port (cons (split-raw-rec line) prev)))))

(define (interpolate data)
  data)

(define (smooth window count sum old index)
  (if (or (null? old) (= count window))
    (/ sum count)
    (smooth window (+ 1 count) (+ (list-ref (car old) index) sum) (cdr old) index)))

(define (arithsmooth window new-entry old)
  (smooth window 1 new-entry old 2))

(define (geomsmooth window new-entry old)
  (smooth window 1 new-entry old 4))

(define (geom window count new sum old)
  (if (or (null? old) (= count window))
    (if (= sum 0)
      0
      (* (/ new sum) count))
    (geom window (+ 1 count) new (+ (list-ref (car old) 1) sum) (cdr old))))

(define (process/r data prev)
  (if (null? data)
    prev
    (let* ((date (list-ref (car data) 0))
          ; cases: cumulative cases
          (today (list-ref (car data) 1))
          (yesterday (if (null? prev) 0 (list-ref (car prev) 1)))
          ; arith: new cases
          (arith (- today yesterday))
          ; geom: normalized fraction of new cases in last 14 days that happened today
          ; the original awk code is as follows:
          ; geom=arith/basissum*livedays;
          (geom (geom 14 0 arith 0 prev))
          )
    (process/r
      (cdr data)
      (cons
        (list date
          today
          arith
          ; arithsmoothed: running 7-day window average 
          (arithsmooth 7 (- today yesterday) prev)
          geom
          ; geomsmoothed: smooth geom over 7-day window
          (geomsmooth 7 geom prev)
) prev)))))

(define (process data)
  (reverse (process/r data '())))

(define (format-record record)
  (string-join (list
    (date->string (list-ref record 0) "~Y~m~d")
    (number->string (list-ref record 1) 10)
    (number->string (list-ref record 2))
    (number->string (list-ref record 3))
    (number->string (list-ref record 4))
    (number->string (list-ref record 5) 10)
    )
  ","))

(define (print-csv data)
  (if (null? data)
    #t
    (begin (display (format-record (car data)))
           (newline)
           (print-csv (cdr data)))))

(let* ((port (open-input-file "cases.csv"))
       (raw (read-raw-csv port '()))
       (interpolated (interpolate raw))
       (processed (process interpolated)))
  (print-csv processed))
