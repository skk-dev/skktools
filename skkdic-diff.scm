#!/usr/bin/gosh
;; skkdic-diff.scm -- print diffs between two jisyo files in manued format
;;
;; Copyright (C) 2003-2004 Kimura Fuyuki <fuyuki@hadaly.org>
;;
;; Author: Kimura Fuyuki <fuyuki@hadaly.org>
;; Created: August 11, 2003
;; Last Modified: $Date: 2004/06/25 06:24:13 $
;; Version: $Id: skkdic-diff.scm,v 1.1 2004/06/25 06:24:13 fuyuki Exp $

(use gauche.process)
(use gauche.regexp)
(use gauche.charconv)
(use util.lcs)

(define (usage)
  (print "Usage: skkdic-diff from-jisyo to-jisyo")
  (exit 1))

(define (make-manuedifier . opts)
  (let-keywords* opts ((open "[") (close "]") (swap "|")
                       (delete "/") (comment ";") (escape "~"))
    (let* ((cmds (list open close swap delete comment escape))
           (rx-cmds (string->regexp (string-join (map regexp-quote cmds) "|")))
           (rx-open (string->regexp (regexp-quote open)))
           (escaped #`",|escape|\\0"))
      (define (escape-outer str)
        (regexp-replace-all rx-open str escaped))
      (define (escape-inner str)
        (regexp-replace-all rx-cmds str escaped))
      (define (manuedifier1 str1 str2)
        (let1 out (open-output-string)
          (define (display-outer)
            (display (escape-outer (get-output-string out)))
            (close-output-port out)
            (set! out (open-output-string)))
          (define (display-inner)
            (display (escape-inner (get-output-string out)))
            (close-output-port out)
            (set! out (open-output-string)))
          (define (a-proc c type)
            (cond ((eq? type '=)
                   (display-outer) (display open))
                  ((eq? type '+)
                   (display-outer)))
            (write-char c out)
            '-)
          (define (b-proc c type)
            (cond ((eq? type '=)
                   (display-outer) (display open) (display delete))
                  ((eq? type '-)
                   (display-inner) (display delete)))
            (write-char c out)
            '+)
          (define (both-proc1 type)
            (cond ((eq? type '-)
                   (display-inner) (display delete) (display close))
                  ((eq? type '+)
                   (display-inner) (display close))))
          (define (both-proc c type)
            (both-proc1 type)
            (write-char c out)
            '=)
          (let1 type (lcs-fold a-proc b-proc both-proc
                               '=
                               (string->list str1)
                               (string->list str2))
            (both-proc1 type)
            (display-outer))))

      (define (manuedifier str1 str2)
        (cond ((and (string=? str1 "") (string=? str2 "")) "")
              ((string=? str1 "")
               (string-append open delete (escape-inner str2) close))
              ((string=? str2 "")
               (string-append open (escape-inner str1) delete close))
              (else
               (with-output-to-string (cut manuedifier1 str1 str2)))))
      manuedifier)))

(define (skkdic-diff lis1 lis2)
  (define manuedifier (make-manuedifier :open "{" :close "}" :delete "->"))

  (define (print-added line)
    (print (manuedifier "" line)))
  (define (print-removed line)
    (print (manuedifier line "")))
  (define (print-modified line1 line2)
    (print (manuedifier line1 line2)))

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
             (let ((m1 (string-scan l1 " " 'before))
                   (m2 (string-scan l2 " " 'before)))
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
                      (print-modified l1 l2)
                      (loop (cdr lis1) (cdr lis2))))))))))

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
