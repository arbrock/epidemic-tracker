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

(define (interpolate/r data rest)
  (if (null? data)
    (reverse rest)
    (if (null? rest) (interpolate/r (cdr data) (cons (car data) rest))
    (let* ((today (car data))
           (yesterday (car rest))
           (time-today (date->time-utc (list-ref today 0)))
           (time-yesterday (date->time-utc (list-ref yesterday 0)))
           (one-day (make-time 'time-duration 0 86400))
           (one-dst-day (make-time 'time-duration 0 (+ 86400 3600)))
           (next-day (add-duration time-yesterday one-day))
           (next-dst-day (add-duration time-yesterday one-dst-day)))
          (if (<= (time-second time-today) (time-second next-dst-day))
            ; no interpolation
            (interpolate/r (cdr data) (cons (car data) rest))
            ; yes interpolation
            (let* ((cases-today (list-ref today 1))
                   (cases-yesterday (list-ref yesterday 1))
                   (diff (time-difference time-today time-yesterday))
                   (diff-days (/ (time-second diff) 86400))
                   (interpolated-cases (round (+ cases-yesterday (/ (- cases-today cases-yesterday) diff-days))))
                   (fake-today (list (time-utc->date next-day) interpolated-cases)))
            (interpolate/r data (cons fake-today rest))))))))


(define (interpolate data)
  (interpolate/r data '()))

(define (arithsmooth/r window count sum old)
  (if (or (null? old) (= count window))
    (/ sum count)
    (arithsmooth/r window (+ 1 count) (+ (list-ref (car old) 2) sum) (cdr old))))

(define (arithsmooth window new-entry old)
  (arithsmooth/r window 1 new-entry old))

(define (geomsmooth/r window count sum old)
  (if (or (null? old) (= count window))
    (exp (/ sum count))
    (geomsmooth/r window (+ 1 count) (+ (log (list-ref (car old) 4)) sum) (cdr old))))

(define (geomsmooth window new-entry old)
  (geomsmooth/r window 1 (log new-entry) old))

(define (geom window count new sum old)
  (if (or (null? old) (= count window))
    (if (= sum 0)
      0
      (* (/ new sum) count))
    (geom window (+ 1 count) new (+ (list-ref (car old) 2) sum) (cdr old))))

(define (process/r data prev)
  (if (null? data)
    prev
    (let* ((date (list-ref (car data) 0))
          ; cases: cumulative cases
          (today (list-ref (car data) 1))
          (yesterday (if (null? prev) 0 (list-ref (car prev) 1)))
          ; arith: new cases
          (arith (- today yesterday))
          ; arithsmoothed: running 7-day window average 
          (arithsmoothed (arithsmooth 7 arith prev))
          ; geom: normalized fraction of new cases in last 14 days that happened today
          ; the original awk code is as follows:
          ; geom=arith/basissum*livedays;
          (geom (geom 14 1 arith arith prev))
          ; geomsmoothed: smooth geom over 7-day window
          (geomsmoothed (geomsmooth 7 geom prev)))
    (process/r
      (cdr data)
      (cons (list date today arith arithsmoothed geom geomsmoothed) prev)))))

(define (process data)
  (reverse (process/r data '())))

(define (format-record record)
  (string-join (list
    (date->string (list-ref record 0) "~Y~m~d")
    (number->string (list-ref record 1))
    (number->string (list-ref record 2))
    (number->string (exact->inexact (list-ref record 3)))
    (number->string (exact->inexact (list-ref record 4)))
    (number->string (exact->inexact (list-ref record 5)))
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
