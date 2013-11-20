;;; java-mode-plus.el --- Java and java-mode Emacs enhancements

;; This is free and unencumbered software released into the public domain.

;;; Install:

;; Put this file somewhere on your load path (like in .emacs.d), and
;; require it. That's it!

;;    (require 'java-mode-plus)

;;; Commentary:

;; I'm not a fan of giant IDEs. In a corporate setting, someone who
;; doesn't know what they're doing will usually pick a big IDE for you
;; and make it difficult to use anything else. I think everyone should
;; be able to use their preferred source editing tools, whether it be
;; Emacs, Vim, or Eclipse.

;; The unix-way is to make many small, well-defined and well-focused
;; programs do all the work, so that's what I recommend below. Ant for
;; project management, Ivy for dependency management, AStyle for
;; syntactic style, Checkstyle for semantic style, and (not so small)
;; Emacs as the magic wand that directs all the tools. It's like The
;; Sorcerer's Apprentice, but with positive results.

;; With all these tools, the downside compared to a big Java IDE is no
;; tool has a complete understanding of the code base. Java is a
;; verbose language and it helps when the computer can fill in all the
;; redundant details for you. I don't think Emacs will ever be able to
;; do this as completely as an IDE. However, I think Emacs provides
;; plenty of advantages to counter that level of code awareness.

;; It is strongly recommended to use in conjunction with this package:
;;
;; * java-docs - Found alongside java-mode-plus. Provides the
;;               `add-java-import' function for quickly adding import
;;               statements to the top of the source file.
;;
;; * ido-mode - Packaged with Emacs for great minibuffer completion.
;;
;; * winner-mode - Maximize Emacs, split into a bunch of windows, and
;;                 hop around them quickly with this.

;; Enhancements to java-mode:

;; * `insert-java-import' - If you have java-docs set up, you can
;;     access the quick import insertion function.
;;
;;     * C-c C-j i - quickly select an import to insert


;;; Code:

(require 'cc-mode)
(require 'cl)

(defvar java-mode-plus-map (make-sparse-keymap)
  "Keymap for the java-mode-plus minor mode.")

;;;###autoload
(define-minor-mode java-mode-plus
  "Extensions to java-mode for further support with standard Java tools."
  :lighter " jm+"
  :keymap 'java-mode-plus-map)

(defvar java-root-convention '("src/main/java" "src/test/java")
  "List of directories that tend to be at the root of packages.") 

;;;###autoload
(defun java-package ()
  "Returns a guess of the package of the current Java source
file, based on the absolute filename. Package roots are matched
against `java-root-convention'."
  (java-mode-plus-search-for-root-convention java-root-convention 
			      (file-name-directory buffer-file-name)))

(defun java-mode-plus-search-for-root-convention (convention-test-list parent-directory)
  (if (string-match (car convention-test-list) parent-directory)
      (java-mode-plus-guess-package (java-mode-plus-split-at-convention (car convention-test-list) parent-directory))
    (java-mode-plus-search-for-root-convention (cdr convention-test-list) parent-directory)))

(defun java-mode-plus-split-at-convention (convention parent-directory)
  (split-string parent-directory (concat convention "/")))

(defun java-mode-plus-guess-package (package-list)
  (substring (replace-regexp-in-string "/" "." (pop (cdr package-list))) 0 -1))

;;;###autoload
(defun java-class-name ()
  "Determine the class name from the filename."
  (file-name-sans-extension (file-name-nondirectory buffer-file-name)))

;; Add the very handy binding from java-docs
(define-key java-mode-plus-map (kbd "C-c C-j i") 'add-java-import)

;; Enable the minor mode wherever java-mode is used.
;;;###autoload
(add-hook 'java-mode-hook 'java-mode-plus)

(provide 'java-mode-plus)

;; java-mode-plus.el ends here
