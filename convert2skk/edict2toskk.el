;;; edict2toskk.el ---   -*- coding: utf-8 -*-

;; Copyright (C) 2020 Tsuyoshi Kitamoto  <tsuyoshi.kitamoto@gmail.com>
;; Author: 2020 Tsuyoshi Kitamoto  <tsuyoshi.kitamoto@gmail.com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program, If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;    edict2skk.awk と同じ動作を目指したもの
;;    edict2 フォーマットにも対応

;;; Code:

(defun main ()
  (princ ";; okuri-ari entry\n")
  (princ ";; okuri-nasi entry\n")

  (with-temp-buffer
    (insert-file-contents (expand-file-name "edict2u" "./"))
    (goto-char (point-min))
    (forward-line)

    (while (re-search-forward "^\\([^ ].*\\) /\\(.+\\)/$" nil t)
      (let ((jp-span (match-string 1))
            (en-span (split-string (match-string 2) "/")))
        (mapc #'(lambda (en-sense)
                  (when (setq midasi-list (get-midasi en-sense))
                    (mapc #'(lambda (midasi)
                              (mapc #'(lambda (cand)
                                        (princ (format "%s /%s/\n" midasi cand)))
                                    (get-cand jp-span)))
                          midasi-list)))
              en-span)))))

(defun get-cand (jp-span)
  (setq jp-span (replace-regexp-in-string " \\[.+\\]" "" jp-span))
  (split-string (replace-regexp-in-string "(.+)" "" jp-span) ";"))

(defun get-midasi (en-sense)
  (setq en-sense (replace-regexp-in-string (char-to-string 34) "" en-sense))
  (cond ((or (string-match " " en-sense) ; スペースが含まれていたら
             (string-match "EntL[0-9]" en-sense)
             (string-match "(P)" en-sense)
             (string-match "(N)" en-sense)
             (string-match "[^!-~]" en-sense)) ; ASCII 以外が含まれていたら
         nil) ;; 上記のものは出力しない

        ;; 前置カッコをふたつに分解。カッコ内のハイフンは削除
        ;; (un)foo       | (self-)bar
        ;; => foo, unfoo | => bar, selfbar
        ((string-match "^(\\([^-]+\\)-?)\\(.+\\)$" en-sense)
         (list (match-string 2 en-sense)
               (format "%s%s" (match-string 1 en-sense)
                       (match-string 2 en-sense))))

        ;; 後置カッコを処理する前に、個別処理
        ;; `NRZ(M)' と `NRZ(C)' は、そのまま出力
        ((string-match "^NRZ(.)$" en-sense)
         (list en-sense))

        ;; 後置カッコをふたつに分解。カッコ内のハイフンは削除
        ;; foo(ing)
        ;; => foo, fooing
        ((string-match "^\\(.+\\)(-?\\(.*\\))$" en-sense)
         (list (match-string 1 en-sense)
               (format "%s%s" (match-string 1 en-sense) (match-string 2 en-sense))))

        (t
         (list en-sense))))

(defun after ()
  (let ((make-backup-files nil) )
    (with-current-buffer (find-file-noselect (expand-file-name "SKK-JISYO.edict2.tmp" "./"))
      (goto-char (point-min))
      (insert ";; -*- mode: fundamental; coding: utf-8 -*-
;; edict dictionary for SKK system
;;
;; Copyright (C) 2017
;;     The Electronic Dictionary Research and Development Group.
;;     http://www.edrdg.org/
;;
;; Author: James William Breen
;;
;;; Commentary:
;;
;; SKK-JISYO.edict は The Electronic Dictionary Research and Development Group
;; による「和英辞典」edict を SKK 辞書形式の「英和辞典」に機械的に変換したもの
;; です。
;;
;; The EDICT Dictionary File -- http://www.edrdg.org/jmdict/edict.html
;;     EDICT can be freely used provided satisfactory acknowledgement is made
;;     in any software product, server, etc. that uses it. There are a few other
;;     conditions relating to distributing copies of EDICT with or without modification.
;;     Copyright is vested in the EDRG (Electronic Dictionary Research Group)
;;     with the file available under a Creative Commons Attribution-ShareAlike Licence (V3.0).
;;     You can see the specific licence statement at the Group's site. 
;;
;; Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
;;     <https://creativecommons.org/licenses/by-sa/3.0/deed>
;;     <https://creativecommons.org/licenses/by-sa/3.0/legalcode>
;;
")
      (basic-save-buffer))))

(provide 'edict2toskk)

;;; edict2toskk.el ends here
