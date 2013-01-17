;;; java-mode-plus.el --- Java and java-mode Emacs enhancements

;; This is free and unencumbered software released into the public domain.

;;; Install:

;; Put this file somewhere on your load path (like in .emacs.d), and
;; require it. That's it!

;;    (require 'java-mode-plus)

;;; Commentary:

;; This package provides a minor-mode that enhances java-mode a bit
;; when working with Ant-based projects. This is something to do
;; *instead* of using a large extension like JDEE, which is large,
;; complex, difficult to set up, and doesn't work very well anyway.

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

;; * `ant-compile' - Like normal `compile', but automatically search
;;     up the path looking for a build.xml.

;; * `open-java-project' - Use this on your project's root
;;     directory. Open up an entire source hierarchy at once, making
;;     it easy to switch between source files with ido-mode, and at
;;     the same time exposing lots of names for `dabbrev-expand'
;;     (M-/) to use.

;; * `ant-bind' and `ant-bind*' - Create a keybinding for a specific
;;     Ant target. These have already been defined.
;;
;;     * C-c C-j c - "compile" target
;;     * C-c C-j j - "jar" target
;;     * C-c C-j C - "clean" target
;;     * C-c C-j r - "run" target
;;     * C-c C-j t - "test" target
;;     * C-c C-j y - "check" target, if you're using Checkstyle
;;     * C-c C-j f - "format" target, if you set up a Java indenter
;;     * C-c C-j x - "hotswap" target, if you set up Ant hotswap
;;
;;     Also provided is `java-mode-short-keybindings', which sets up
;;     shorter bindings by replacing C-c C-j with C-x. This is not the
;;     default because they trample the keybinding namespace a bit,
;;     but they are the bindings I personally use.
;;
;;     These compilation bindings all accept a prefix argument, which
;;     appends the number to the compilation buffer name. This is
;;     useful when you need to run two compilation buffers at once:
;;     give each one a different prefix. My favorite use of this is
;;     for code hotswapping.

;; * `insert-java-import' - If you have java-docs set up, you can
;;     access the quick import insertion function.
;;
;;     * C-c C-j i - quickly select an import to insert

;; Recommended usage:

;; A typical Ant-based project typically consists of a directory
;; layout like so,

;;   src/    - source files
;;   test/   - JUnit test source
;;   doc/    - documentation, not including generated (Javadoc)
;;   dist/   - final deliverable, created and destroyed by Ant
;;   build/  - generated/compiled files, created and destroyed by Ant

;; See my SampleJavaProject for an example of this in action,
;; https://github.com/skeeto/SampleJavaProject

;; Like using the mouse, I like to avoid dropping to a shell whenever
;; I can, even if that shell is inside Emacs. If I can stay inside the
;; context of Emacs, that's really what I prefer to do. Emacs provides
;; a generic front end to various source management systems (`vc-*'),
;; but my favorite one is Git. I use Magit to interface with Git, and
;; I rarely have to visit the shell to perform maintenance. Figure out
;; what works best for you.

;; Use Emacs in daemon mode! This got *really* good in recent versions
;; of Emacs, so use it! You can either fire off an 'emacs --daemon'
;; when you first log in, and then use 'emacsclient' later, or you can
;; use "emacsclient -ca ""' any time you need to use Emacs, which will
;; create a daemon for you if needed. As you'll see below, once you're
;; set up with your project, you don't want to make Emacs do it all
;; over again when you get back from lunch.

;; You'll want to dedicate a(n Emacs) window specifically to the
;; *compilation* buffer. Any time you do a compilation, it will
;; reliably be done here, rather than hopping around to various
;; windows. I make mine a half-tall window on the top right.

;; So when you sit down to do some work at a fresh Emacs instance, the
;; first thing you will do is run `open-java-project' on your
;; project's root directory (this may not be practical on very large
;; projects). This will open all of your sources so they're very
;; accessible. Using ido-mode will make switching between the sources
;; pretty zippy.

;; To help navigate, take advantage of a TAGS file. Use `find-tag'
;; (M-.) to move around your source. You can set up an Ant "tags"
;; target like so,

;; <target name="tags" description="Generate a TAGS file for your editor.">
;;   <delete file="TAGS"/>
;;   <apply executable="etags">
;;     <arg value="-a"/>
;;     <fileset dir="src" includes="**/*.java"/>
;;     <fileset dir="test" includes="**/*.java"/>
;;   </apply>
;; </target>

;; Hack away at the code, using `dabbrev-expand' and family to help
;; save time typing. When it comes time to compile, use the C-c C-j c
;; binding. Need to run your program? Use the C-c C-j r binding, and
;; it will launch from Emacs. Use C-x ` to step through and correct
;; the errors.

;; With tabs turned off (`indent-tabs-mode'), Emacs should do a good
;; job of indentation, but a tool like Artistic Style (AStyle) can
;; tidy up a bit better. Use C-c C-j f to syntactically tidy up your
;; changes (and you'll need to `revert-buffer' to get the style fixes
;; in the buffer, so I recommend binding it to something). I recommend
;; setting up a "format" target to do this like so,

;; <target name="format" description="Run the indenter on all source files.">
;;   <apply executable="astyle">
;;     <arg value="--mode=java"/>
;;     <arg value="--suffix=none"/>
;;     <fileset dir="src" includes="**/*.java"/>
;;     <fileset dir="test" includes="**/*.java"/>
;;   </apply>
;; </target>

;; Adjust to taste.

;; AStyle checked your syntax style, so next Checkstyle can check your
;; semantic style. So if you're using Checkstyle, which I also
;; recommend, you'll use C-c C-j y to check and correct (with C-x `)
;; any issues.

;; Once you're satisfied, use your preferred Emacs SCM interface to
;; check in your code. Repeat.

;; If you want to run a particular target not bound to a short key
;; binding, use `ant-compile', which will ask you for the Ant command
;; you want to use. You can run this from any source file, and it will
;; go find your build.xml. No need to add a "-find".

;; Closing remarks:

;; As I develop and improve my Java workflow, I'm gradually building
;; up java-mode-plus to match. As long as I continue to use Java, this
;; package will slowly grow.

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

;;;###autoload
(defun java-package ()
  "Returns a guess of the package of the current Java source
file, based on the absolute filename. Package roots are matched
against `java-package-roots'."
  (labels ((search-root (stack path)
             (if (or (null path) (member (car path) java-package-roots))
                 (mapconcat 'identity stack ".")
               (search-root (cons (car path) stack) (cdr path)))))
    (search-root '() (cdr (reverse (split-string (file-name-directory
                                                  buffer-file-name) "/"))))))

;;;###autoload
(defun java-class-name ()
  "Determine the class name from the filename."
  (file-name-sans-extension (file-name-nondirectory buffer-file-name)))

;; Add the very handy binding from java-docs
(define-key java-mode-plus-map (kbd "C-c C-j i") 'add-java-import)

(defun java-mode-short-keybindings ()
  "Create (old) short bindings for java-mode."
  (interactive)
  (define-key java-mode-plus-map (kbd "C-x I") 'add-java-import))

;; Enable the minor mode wherever java-mode is used.
;;;###autoload
(add-hook 'java-mode-hook 'java-mode-plus)

(provide 'java-mode-plus)

;; java-mode-plus.el ends here
