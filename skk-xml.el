;;; skk-xml.el --- SKK dictionary XML conversion tool
;; Copyright (C) 2002 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>

;; Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
;; Version: $Id: skk-xml.el,v 1.1 2002/08/18 04:09:26 minakaji Exp $
;; Keywords: japanese
;; Created: Aug. 15, 2002
;; Last Modified: $Date: 2002/08/18 04:09:26 $

;; This file is part of Daredevil SKK.

;; Daredevil SKK is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.

;; Daredevil SKK is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Daredevil SKK, see the file COPYING.  If not, write to
;; the Free Software Foundation Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

(defun skk-convert-jisyo-to-xml (file &optional reference reference-name)
  (interactive "fFile: ")
  (let ((working-buffer
	 (let ((temp (get-buffer-create " *skk-xml-temp*")))
	   (save-excursion
	     (set-buffer temp)
	     (erase-buffer)
	     (insert-file-contents (expand-file-name file))
	     temp)))
	(output-buffer
	 (let ((temp (get-buffer-create "*skk-xml-dictionary*")))
	   (save-excursion
	     (set-buffer temp)
	     (erase-buffer)
	     (insert "<?xml version=\"1.0\" encoding=\"EUC-JP\" standalone=\"yes\"?>\n")
	     (insert "<skk-dictionary>\n  <okuri-ari>\n")
	     temp)))
	(reference-buffer
	 (if reference
	     (let ((temp (get-buffer-create " *skk-xml-reference*")))
	       (save-excursion
		 (set-buffer temp)
		 (erase-buffer)
		 (insert-file-contents (expand-file-name reference))
		 temp))))
	okuri-ari okuri-nasi)
    (if (and reference-buffer (not reference-name))
	(progn
	  (setq reference-name (file-name-nondirectory reference))
	  (if (string-match "^SKK-JISYO\\.\\(.+\\)" reference-name)
	      (setq reference-name (match-string 1 reference-name)))))
    (unwind-protect
	(save-excursion
	  (if reference-buffer
	      (progn
		(set-buffer reference-buffer)
		(goto-char (point-min))
		(if (not (search-forward ";; okuri-ari entries." nil t nil))
		    (error "This file is not SKK dictionary format!")
		  (setq okuri-ari (point)))
		(if (not (search-forward ";; okuri-nasi entries." nil t nil))
		    (error "This file is not SKK dictionary format!")
		  (setq okuri-nasi (point)))))
	  (set-buffer working-buffer)
	  (goto-char (point-min))
	  (or (search-forward ";; okuri-nasi entries." nil t nil)
	      (error "This file is not SKK dictionary format!"))
	  (goto-char (point-min))
	  (or (search-forward ";; okuri-ari entries." nil t nil)
	      (error "This file is not SKK dictionary format!"))
	  (skk-convert-jisyo-to-xml-1
	   output-buffer reference-buffer reference-name okuri-ari okuri-nasi))
      (if reference
	(progn
	  (kill-buffer working-buffer)
	  (kill-buffer reference-buffer))))
    (pop-to-buffer output-buffer)))

(defun skk-convert-jisyo-to-xml-1
  (output-buffer reference-buffer reference-name okuri-ari okuri-nasi)
  ;;to be called in WORKING-BUFFER (original SKK-JISYO format buffer)
  (let ((max (point-max))
	(min (point-min))
	okuri-nasi-flag)
    (while (not (eobp))
      (forward-line 1)
      (message "Converting SKK dictionary to XML format...%3d%% done"
	       (if (fboundp 'float)
		   (round (* (/ (float (- (point) min)) max) 100))
		 ;; maybe Emacs integer will be overflowed when file has too many lines.
		 (/ (* 100 (- (point) min)) max)))
      (cond
       ;; next we are processing okuri-nasi entries.
       ((and (not okuri-nasi-flag) (looking-at ";; okuri-nasi entries."))
	(save-excursion
	  (set-buffer output-buffer)
	  (goto-char (point-max))
	  (insert "  </okuri-ari>\n  <okuri-nasi>\n")
	  (setq okuri-nasi-flag t)))
       ;; skip comments
       ((looking-at ";"))
       ;; final line
       ((eobp))
       (t
	(skk-convert-jisyo-to-xml-2
	 output-buffer reference-buffer reference-name
	 okuri-ari okuri-nasi okuri-nasi-flag))))
    (save-excursion
      (set-buffer output-buffer)
      (goto-char (point-max))
      (insert "  </okuri-nasi>\n</skk-dictionary>\n"))))

(defun skk-convert-jisyo-to-xml-2
  (output-buffer reference-buffer reference-name okuri-ari okuri-nasi okuri-nasi-flag)
  ;;to be called in WORKING-BUFFER (original SKK-JISYO format buffer)
  (let (midasi candidates temp-candidates okurigana word)
    (beginning-of-line)
    (setq midasi (buffer-substring-no-properties
		  (point) (1- (search-forward " "))))
    (setq midasi (skk-xml-substitute-special midasi))
    (search-forward "/")
    (setq temp-candidates (buffer-substring-no-properties
			   (point) (progn (end-of-line) (1- (point)))))
    (if (string-match "/\\(\\[[¤¡-¤ó]/.+\\)" temp-candidates)
	(progn
	  (setq temp-candidates (match-string 1 temp-candidates))
	  (or (eq (aref temp-candidates (1- (length temp-candidates)))
		  ?\])
	      (setq temp-candidates (concat temp-candidates "]")))))
    (setq candidates (split-string temp-candidates "/"))
    (save-excursion
      (set-buffer output-buffer)
      (goto-char (point-max))
      (insert "    <entry>\n    <key>" midasi "</key>\n")
      (while (setq word (car candidates))
	(catch 'exit
	  (let (annotation)
	    (if (string-equal word "]")
		(progn
		  (setq okurigana nil)
		  (throw 'exit nil)))
	    (if (and (not okurigana)
		     (string-match "\\[\\([¤¡-¤ó]\\)" word))
		(progn
		  (setq okurigana (match-string 1 word))
		  (throw 'exit nil)))
	    (if (string-match "\\([^;]+\\);\\([^;]+\\)" word)
		(setq annotation (skk-xml-substitute-special
				  (match-string 2 word))
		      word (skk-xml-substitute-special
			    (match-string 1 word)))
	      (setq word (skk-xml-substitute-special word)))
	    (insert "      <candidate>\n")
	    (insert "        <word>" word "</word>\n")
	    (if okurigana
		(insert "          <okurigana>" okurigana "</okurigana>\n"))
	    (if annotation
		(insert "          <annotation>" annotation "</annotation>\n"))
	    (if reference-buffer
		(let (pos max found)
		  (save-excursion
		    (set-buffer reference-buffer)
		    (goto-char (if okuri-nasi-flag okuri-nasi okuri-ari))
		    (search-forward (concat "\n" midasi " ")
				    (if okuri-nasi-flag nil okuri-nasi)
				    t nil)
		    (setq pos (point))
		    (end-of-line)
		    (setq max (point))
		    (goto-char pos)
		    (setq found (search-forward (concat "/" word "/") max t nil)))
		  (if found
		      (insert "          <" reference-name "/>\n")))))
	  (insert "      </candidate>\n"))
	(setq candidates (cdr candidates)))
      (insert "    </entry>\n"))))

(defun skk-xml-substitute-special (string)
  (let ((list (append string nil))
	c val)
    (while (setq c (car list))
      (cond ((eq c ?&)
	     (setq val (append '(?\; ?p ?m ?a ?&) val)))
	    ((eq c ?<)
	     (setq val (append '(?\; ?t ?l ?&) val)))
	    ((eq c ?>)
	     (setq val (append '(?\; ?t ?g ?&) val)))
	    ((eq c ?')
	     (setq val (append '(?\; ?s ?o ?p ?a ?&) val)))
	    ((eq c ?\")
	     (setq val (append '(?\; ?t ?o ?u ?q ?&) val)))
	    (t (setq val (cons c val))))
      (setq list (cdr list)))
    (mapconcat 'char-to-string (nreverse val) "")))

(defun skk-xml-make-jisyo-reference (xml skk-jisyo)
  (let* ((output-buffer
	  (let ((temp (get-buffer-create "*skk-xml-dictionary*"))
		(comment (concat "<!-- " (file-name-nondirectory xml) " -->")))
	    (save-excursion
	      (set-buffer temp)
	      (erase-buffer)
	      (insert-file-contents (expand-file-name xml))
	      (goto-char (point-min))
	      (or (re-search-forward (concat "^" comment "$") nil t nil)
		  (progn
		    (search-forward "?>\n" nil t nil)
		    (insert comment "\n")))
	      temp)))
	 (reference-buffer
	  (let ((temp (get-buffer-create " *skk-xml-reference*")))
	    (save-excursion
	      (set-buffer temp)
	      (erase-buffer)
	      (insert-file-contents (expand-file-name skk-jisyo))
	      temp)))
	 (reference-tag
	  (if (string-match "^SKK-JISYO\\.\\(.+\\)"
			    (file-name-nondirectory skk-jisyo))
	      (concat "<"
		      (match-string 1 (file-name-nondirectory skk-jisyo))
		      "/>\n")))
	 max min)
    (unwind-protect
	(save-excursion
	  (set-buffer reference-buffer)
	  (goto-char (point-min))
	  (or (search-forward ";; okuri-nasi entries." nil t nil)
	      (error "This file is not SKK dictionary format!"))
	  (goto-char (point-min))
	  (or (search-forward ";; okuri-ari entries." nil t nil)
	      (error "This file is not SKK dictionary format!"))
	  (setq max (point-max)
		min (point-min))
	  (while (not (eobp))
	    (forward-line 1)
	    (message "Making reference tags to %s...%3d%% done"
		     (file-name-nondirectory skk-jisyo)
		     (if (fboundp 'float)
			 (round (* (/ (float (- (point) min)) max) 100))
		       (/ (* 100 (- (point) min)) max)))
	    (cond
	     ;; skip comments
	     ((looking-at ";"))
	     ;; final line
	     ((eobp))
	     (t
	      (skk-xml-make-jisyo-reference-1 output-buffer reference-tag)
	      ))))
      (kill-buffer reference-buffer))
    (pop-to-buffer output-buffer)))

(defun skk-xml-make-jisyo-reference-1 (output-buffer reference-tag)
  (let (midasi temp-candidates candidates word tags
	       pos max found r0 r1)
    (setq midasi (buffer-substring-no-properties
		  (point) (1- (search-forward " "))))
    (setq midasi (skk-xml-substitute-special midasi))
    (search-forward "/")
    (setq temp-candidates (buffer-substring-no-properties
			   (point) (progn (end-of-line) (1- (point)))))
    (if (string-match "/\\([^[]+\\)\\[[¤¡-¤ó]/.+" temp-candidates)
	(setq temp-candidates (match-string 1 temp-candidates)))
    (setq candidates (split-string temp-candidates "/"))
    (save-excursion
      (set-buffer output-buffer)
      (while (setq word (car candidates))
	(if (string-match "\\([^;]+\\);[^;]+" word)
	    (setq word (match-string 1 word)))
	(setq word (skk-xml-substitute-special word))
	(goto-char (point-min))
	(search-forward (concat "<key>" midasi "</key>") nil t nil)
	(setq pos (point))
	(or (search-forward "</entry>" nil t nil)
	    (error "Missing closing tag </entry>!"))
	(setq max (point))
	(goto-char pos)
	(setq found (search-forward (concat "<word>" word "</word>") max t nil))
	(if (not found)
	    nil
	  (forward-char 1)
	  (setq r0 (point))
	  (or (search-forward "</candidate>" nil t nil)
	      (error "Missing closing tag </canidate>!"))
	  (beginning-of-line)
	  (setq r1 (point))
	  (setq tags (buffer-substring-no-properties r0 r1))
	  (if (string-match "\\([-_<>/a-zA-Z0-9]+\\)" tags)
	      (setq tags (match-string 1 tags)))
	  (delete-region r0 r1)
	  (goto-char r0)
	  (insert "          " tags reference-tag))
	(setq candidates (cdr candidates))))))

;; end of skk-xml.el
