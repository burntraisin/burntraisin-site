;; MELPA package
(require 'package)
(add-to-list 'package-archives
	'("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq inhibit-startup-message t) ;; Don't show splash screen

(setq make-backup-files nil) ;; Don't make backup files

(setq visible-bell t) ;; Flash on error

(tool-bar-mode -1) ;; No tool bar

(menu-bar-mode -1) ;; No menu bar

(add-to-list 'default-frame-alist '(vertical-scroll-bars)) ;; No vertical scroll bar

(global-display-line-numbers-mode) ;; Show line numbers

;; Scrolling - I found the default settings jarring, especially on a laptop; this is what works for me
(setq scroll-conservatively 101)
(setq scroll-margin 20)
(setq fast-but-imprecise-scrolling t)
(setq
     mouse-wheel-follow-mouse 't
     mouse-wheel-progressive-speed nil
     ;; Hold down shift to move twice as fast, or hold down control to move 3x as fast. Perfect for trackpads.
     mouse-wheel-scroll-amount '(1 ((shift) . 3) ((control) . 6)))

;; Font family
(set-frame-font "Hack 13" nil t)

;; Modeline settings
(setq display-time-default-load-average nil)
(line-number-mode)
(column-number-mode)
(display-time-mode -1)
(size-indication-mode 0)

;; Doom-modeline
(use-package doom-modeline
    :config
    (doom-modeline-mode)
    (setq doom-modeline-icon t
         doom-modeline-major-mode-icon t
	     doom-modeline-battery t
	     doom-modeline-buffer-name t
	     doom-modeline-height 50
	     doom-modeline-bar-width 7))

;; Doom theme
(require 'doom-themes)
(setq doom-themes-enable-bold t  
    doom-themes-enable-italic t)
(load-theme 'doom-xcode t) ; doom-gruvbox
(doom-themes-visual-bell-config)
(setq doom-themes-treemacs-theme "doom-colors")
(doom-themes-treemacs-config)
;; Change treemacs font face b/c doom-themes pkg forces treemacs to use a variable pitch font
(setq doom-themes-treemacs-enable-variable-pitch nil)
(doom-themes-org-config)

;; Org mode config
(setq org-ellipsis "...") ;; You can change the `...` to anything you want
(setq org-startup-folded t) ;; Fold headers
(setq org-startup-with-inline-images t) ;; Show inline images, may blow up the screen
(setq org-image-actual-width nil) ;; Lets you set your own image width
(setq org-hide-emphasis-markers t) ;; Hide markup elements
(add-hook 'org-mode-hook 'turn-on-auto-fill) ;; Wrap text at 80 char
(add-hook 'org-mode-hook 'org-indent-mode) ;; Automatically starts org-indent-mode

;; Retain new lines separating headings
(customize-set-variable 'org-blank-before-new-entry 
	    '((heading . nil)
          (plain-list-item . nil)))
(setq org-cycle-separator-lines 1)

;; Active Babel languages
(org-babel-do-load-languages
     'org-babel-load-languages
     '((scheme . t) ;; Here is where you can list what languages you want syntax highlighting for
       (ledger . t)
       (latex . t)
       (java . t)
       (C . t)))

;; Syntax highlighting for source blocks
(setq org-src-fontify-natively t)

(global-set-key "\C-ca" 'org-agenda) ;; Agenda view keybind

;; org-super-agenda
(require 'org-super-agenda)
     (setq org-agenda-custom-commands
	   '(
	     ("r" "Today's Agenda"
	      ((agenda ""
		       ((org-agenda-block-separator ?*) ;; Makes the separator *'s
			    (org-agenda-span 1) ;; Lists items scheduled or deadlined for today
			    (org-agenda-format-date "")
			    (org-agenda-files '("~/emacs/planner/college")) ;; Specify folder the .org files are in
			    (org-agenda-overriding-header "School"))) ;; Title of header
	       (agenda ""
		       ((org-agenda-block-separator ?*)
                (org-agenda-span 1)
                (org-agenda-format-date "")
                (org-agenda-files '("~/emacs/planner/work"))
                (org-agenda-overriding-header "\nWork")))
	       (agenda ""
		       ((org-agenda-block-separator ?*)
                (org-agenda-span 90)
                (org-agenda-entry-types '(:deadline)) ;; Show only deadlines
                (org-agenda-show-all-dates nil)
                (org-agenda-files '("~/emacs/planner/college" "~/emacs/planner/work"))
                (org-agenda-overriding-header "\nAll Upcoming\n")))
            ))
	     ("w" "Week's Agenda"
	      ((agenda ""
		       ((org-agenda-block-separator ?*)
                (org-agenda-span 7)
                (org-agenda-files '("~/emacs/planner/college" "~/emacs/planner/work"))
			))
	       ))
	     ("q" "Week's Deadlines"
	      ((agenda ""
		       ((org-agenda-block-separator ?*)
                (org-agenda-span 7)
                (org-agenda-entry-types '(:deadline))
                (org-agenda-files '("~/emacs/planner/college" "~/emacs/planner/work"))
			))
	       ))
	     ))
    