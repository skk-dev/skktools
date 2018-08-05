#!/usr/bin/gosh
;; skkdic-diff.scm -- print diffs between two jisyo files in manued format
;;
;; Copyright (C) 2003-2004 Kimura Fuyuki <fuyuki@hadaly.org>
;;
;; Author: Kimura Fuyuki <fuyuki@hadaly.org>
;; Created: August 11, 2003


(use gauche.process)
(use gauche.regexp)
(use gauche.charconv)
(use util.lcs)
(use util.match)
(use srfi-11)

(define (usage)
  (print "Usage: skkdic-diff from-jisyo to-jisyo")
  (exit 1))

(define (lcs-edit-list2 lis1 lis2)
  (let ((a '()) (b '()) (ab '())
        (r '()))
    (define (push-a)
      (unless (null? a)
        (push! r (list '/ (reverse a) '()))
        (set! a '())))
    (define (push-b)
      (unless (null? b)
        (push! r (list '/ '() (reverse b)))
        (set! b '())))
    (define (push-ab)
      (unless (null? ab)
        (push! r (list '= (reverse ab)))
        (set! ab '())))
    (define (push-a&b)
      (unless (or (null? a) (null? b))
        (push! r (list '/ (reverse a) (reverse b)))
        (set! a '())
        (set! b '())))

    (define (a-proc e _) (push-b) (push-ab) (push! a e))
    (define (b-proc e _) (push-ab) (push! b e))
    (define (both-proc e _) (push-a&b) (push-a) (push-b) (push! ab e))

    (lcs-fold a-proc b-proc both-proc '() lis1 lis2)
    (push-a&b) (push-ab) (push-a) (push-b)
    (reverse r)))

(define (manuediff lis1 lis2)
  (let loop ((el (lcs-edit-list2 lis1 lis2))
             (r '()))
    (match el
           ((('/ () a) ('= b) ('/ c ()) . rest) (=> next)
            (if (equal? a c)
                (loop rest (cons (list '$ b '() a) r))
                (next)))
           ((('/ a ()) ('= b) ('/ () c) . rest) (=> next)
            (if (equal? a c)
                (loop rest (cons (list '$ a '() b) r))
                (next)))
           ((('/ a1 a2) ('= b) ('/ c1 c2) . rest) (=> next)
            (if (and (equal? a1 c2) (equal? a2 c1))
                (loop rest (cons (list '$ a1 b c1) r))
                (next)))
           ((x . rest)
            (loop rest (cons x r)))
           (() (reverse r)))))

(define (skkdic-diff lis1 lis2)
  (let* ((open "{") (close "}") (swap "|")
         (delete "->") (comment ";") (escape "~")
         (cmds (list open close swap delete comment escape))
         (rx-cmds (string->regexp (string-join (map regexp-quote cmds) "|")))
         (rx-open (string->regexp (regexp-quote open)))
         (escaped #`",|escape|\\0"))

    (define (escape-outer str) (regexp-replace-all rx-open str escaped))
    (define (escape-inner str) (regexp-replace-all rx-cmds str escaped))

    (define (display-outer l to-string)
      (display (escape-outer (to-string l))))

    (define (display-inner ls to-string t)
      (let ((d (case t ((/) delete) (($) swap))))
        (display open)
        (display (string-join (map (lambda (l)
                                     (escape-inner (to-string l)))
                                   ls)
                              d))
        (display close)))

    (define (manuediff->string1 md)
      (with-output-to-string
        (lambda ()
          (for-each (lambda (e)
                      (match e
                             (('= l)
                              (display-outer l list->string))
                             ((t ls ...)
                              (display-inner ls list->string t))))
                    md))))

    (define (manuediff->string md)
      (with-output-to-string
        (lambda ()
          (for-each (lambda (e)
                      (define (to-s l)
                        (if (null? l) "" (string-join l "/" 'suffix)))
                      (match e
                             (('= l)
                              (display-outer l to-s))
                             (('/ a b) (=> next)
                              (if (or (null? a) (null? b))
                                  (next)
                                  (let ((l1 (string->list (to-s a)))
                                        (l2 (string->list (to-s b))))
                                    (display (manuediff->string1 (manuediff l1 l2))))))
                             ((t ls ...)
                              (display-inner ls to-s t))))
                    md))))

    (define (print-modified m c1 c2)
      (define (split-candidates str)
        ;; /a/b/c/
        ;; remove the first/last slash and do string-split
        ;; since string-tokenize is much slower
        (string-split (substring str 1 (- (string-length str) 1)) #\/))
      (print m " /" (manuediff->string (manuediff (split-candidates c1)
                                                  (split-candidates c2)))))
    (define (print-added line)
      (print open delete (escape-inner line) close))
    (define (print-removed line)
      (print open (escape-inner line) delete close))

    (let loop ((lis1 lis1) (lis2 lis2))
      (let ((l1 (if (null? lis1) #f (car lis1)))
            (l2 (if (null? lis2) #f (car lis2))))
        (cond ((not (or l1 l2)))
              ((not l1)
               (print-added l2)
               (loop lis1 (cdr lis2)))
              ((not l2)
               (print-removed l1)
               (loop (cdr lis1) lis2))
              ((string=? l1 l2)
               (loop (cdr lis1) (cdr lis2)))
              (else
               (let-values (((m1 c1) (string-scan l1 " " 'both))
                            ((m2 c2) (string-scan l2 " " 'both)))
                 (cond ((not m1) ;l1 is broken
                        (loop (cdr lis1) lis2))
                       ((not m2) ;l2 is broken
                        (loop lis1 (cdr lis2)))
                       ((string>? m1 m2)
                        (print-added l2)
                        (loop lis1 (cdr lis2)))
                       ((string<? m1 m2)
                        (print-removed l1)
                        (loop (cdr lis1) lis2))
                       (else
                        (print-modified m1 c1 c2)
                        (loop (cdr lis1) (cdr lis2)))))))))))

(define (read-jisyo file)
  (define (read-jisyo1 file)
    (with-input-from-file file
      (lambda ()
        (with-port-locking (current-input-port)
          (lambda ()
            (let loop ((l (read-line))
                       (r '()))
              (if (eof-object? l)
                  r
                  ;; ignore comments and blank lines
                  (if (eqv? (string-ref l 0 #\;) #\;)
                      (loop (read-line) r)
                      (loop (read-line) (cons l r))))))))
      :encoding "EUC-JP"))
  (sort! (read-jisyo1 file)))

(define (main args)
  (unless (= (length args) 3) (usage))

  (with-output-conversion (current-output-port)
    (lambda ()
      (skkdic-diff (read-jisyo (cadr args))
                   (read-jisyo (caddr args))))
    :encoding "EUC-JP")
  0)

;; Local variables:
;; mode: scheme
;; end:
