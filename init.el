
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(server-start)
(add-to-list 'exec-path "/usr/local/bin/")
(add-to-list 'exec-path "/usr/local/mysql/bin")

;; SET THE PATH
(setenv "PATH"
	(concat
	 "/usr/local/bin/" ":"
	 "/usr/local/mysql/bin" ":"
	 "/opt/local/bin" ":"
	 "/opt/local/sbin" ":"
	 "/usr/local/mysql/bin" ":"
	 "/usr/local/bin" ":"
	 "/usr/bin" ":"
	 (getenv "PATH")
	 )
	)

;; GET RID OF TOOLBAR
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;; HANDY F1
(global-set-key (kbd "<f1>") 'execute-extended-command)

;; ADD ASPELL
(setq-default ispell-program-name "/usr/local/bin/aspell")


;; TSV in ORGMODE
(defun my-export-to-parent ()
  "Exports the table in the current buffer back to its parent DSV file and
    then closes this buffer."
  (let ((buf (current-buffer)))
    (org-table-export parent-file export-func)
    (set-buffer-modified-p nil)
    (switch-to-buffer (find-file parent-file))
    (kill-buffer buf)))

(defun my-edit-dsv-as-orgtbl (&optional arg)
  "Convet the current DSV buffer into an org table in a separate file. Saving
    the table will convert it back to DSV and jump back to the original file"
  (interactive "P")
  (let* ((buf (current-buffer))
         (file (buffer-file-name buf))
         (txt (substring-no-properties (buffer-string)))
         (org-buf (find-file-noselect (concat (buffer-name) ".org"))))
    (save-buffer)
    (with-current-buffer org-buf
      (erase-buffer)
      (insert txt)
      (org-table-convert-region 1 (buffer-end 1) arg)
      (setq-local parent-file file)
      (cond 
       ((equal arg '(4)) (setq-local export-func "orgtbl-to-csv"))
       ((equal arg '(16)) (setq-local export-func "orgtbl-to-tsv"))
       (t (setq-local export-func "orgtbl-to-tsv")))
      (add-hook 'after-save-hook 'my-export-to-parent nil t))
    (switch-to-buffer org-buf)
    (kill-buffer buf)))

;; Open the current TSV file as an Org table
(global-set-key (kbd "C-c |") 'my-edit-dsv-as-orgtbl)

;;
(defadvice sql-mysql (around sql-mysql-around activate)
  "SSH to linux, then connect"
  (let ((default-directory "/ssh:veeva@sg1.linkxion.com:"))
    ad-do-it))

;; MYSQL port
(setq sql-connection-alist
      '((rds (sql-product 'mysql)
                  (sql-port 3306)
                  (sql-server "veeva.cky8tznrfseu.ap-southeast-1.rds.amazonaws.com")
                  (sql-user "admin")
                  (sql-database "master"))
	(local (sql-product 'mysql)
	      (sql-port 3306)
	      (sql-server "127.0.0.1")
	      (sql-user "lauriekoudstaal")
	      (sql-password "#48vz6Vc")
	      (sql-database "master"))))

;; FOR MAGIT
(global-set-key (kbd "C-x g") 'magit-status)

;; ADD MELPA TO PACKAGE
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(setq mac-command-modifier 'control)
(let ((default-directory "/usr/local/share/emacs/site-lisp/"))
  (normal-top-level-add-subdirs-to-load-path))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (leuven)))
 '(package-selected-packages (quote (web-mode org org-journal magit))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; BACKUPS
(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)


;; MAKE 4-BASE36 ID
(defun base-36 (n)
  (interactive)
  (defconst char-list "abcdefghijklmnopqrstuvwxyz0123456789")
  (defvar encoding "")
  (while (> n 0)
    (setq encoding (concat encoding (elt char-list (random 36))))
    (1- n)))


;; FIX A BUG IN ESHELL SO I CAN RUN SOURCES
(defadvice eshell-gather-process-output (before absolute-cmd (command args) act)
  (setq command (file-truename command)))


;; MAKE SSH THE DEFAULT TRAMP MODE
(require 'tramp) (setq tramp-default-method "ssh")

;; RESTART SHELL PROCESS
(defun restart-shell () (interactive) (shell (current-buffer)))

;; RUN SHELL ON RDS
(defun rds-shell (arg)
  (interactive "P")
  (let ((default-directory "/ssh:veeva@sg1.linkxion.com:"))
    (setq current-prefix-arg arg)
    (call-interactively 'shell)))

;; FOR JSX
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
(defadvice web-mode-highlight-part (around tweak-jsx activate)
  (if (equal web-mode-content-type "jsx")
      (let ((web-mode-enable-part-face nil))
        ad-do-it)
    ad-do-it))
