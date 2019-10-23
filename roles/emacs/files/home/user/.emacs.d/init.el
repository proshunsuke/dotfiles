;; load-path
(defun add-to-load-path (&rest paths)
  (mapc '(lambda (path)
           (add-to-list 'load-path path))
        (mapcar 'expand-file-name paths)))

;; lisp directory's path
(add-to-load-path "~/.emacs.d/lisp")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; load
(load-theme 'Darkula t)
(custom-set-variables
 ;; 諸々設定変更 
 '(auto-save-default nil)
 '(global-linum-mode t)
 '(make-backup-files nil)
 '(ring-bell-function (quote ignore) t))
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

(custom-set-faces
 '(default ((t (:family "Myrica M" :foundry "unknown" :slant normal :weight normal :height 113 :width normal)))))

;; cask
(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; undo redo
(require 'redo+)
(define-key global-map (kbd "C-_") 'undo)
(global-set-key [(control shift z)] 'redo)
(setq undo-no-redo t) ; 過去のundoがredoされないようにする

;; neotree
(require 'neotree)
(define-key global-map (kbd "M-1") 'neotree-toggle)
(with-eval-after-load 'neotree
  (define-key neotree-mode-map (kbd "j") 'next-line)
  (define-key neotree-mode-map (kbd "k") 'previous-line)
  (define-key neotree-mode-map [right] 'neotree-enter)
  (define-key neotree-mode-map [left] 'neotree-enter)
  (define-key neotree-mode-map (kbd "r") 'neotree-refresh)
  (define-key neotree-mode-map [S-f6] 'neotree-rename-node)
  (define-key neotree-mode-map [delete] 'neotree-delete-node)
  )
;; 隠しファイルをデフォルトで表示
(setq neo-show-hidden-files t)

;; neotree でファイルを新規作成した後、自動的にファイルを開く
(setq neo-create-file-auto-open t)

;; neotree ウィンドウを表示する毎に current file のあるディレクトリを表示する
(setq neo-smart-open t)

;; find-file-project
(require 'find-file-in-project)
(define-key global-map (kbd "C-x f") 'find-file-in-project)
(defun neotree-project-dir ()
    "Open NeoTree using the git root."
    (interactive)
    (let ((project-dir (ffip-project-root))
          (file-name (buffer-file-name)))
      (if project-dir
          (progn
            (neotree-dir project-dir)
            (neotree-find file-name))
        (message "Could not find git project root."))))
  
  (global-set-key (kbd "C-c C-p") 'neotree-project-dir)


;;-------------------------------------------------------------------------
;; tabbar.el
;;-------------------------------------------------------------------------
(require 'tabbar)
(tabbar-mode 1)
;;
;; マウスホイールは使わない
(tabbar-mwheel-mode nil)
;;
;; グループ化しない
(setq tabbar-buffer-groups-function nil)
;;
;; 左側のボタンを消す
(dolist (btn '(tabbar-buffer-home-button
tabbar-scroll-left-button
tabbar-scroll-right-button))
(set btn (cons (cons "" nil)
(cons "" nil))))
;;
;; タブの色設定
(set-face-attribute ; バーの色
'tabbar-default nil
:background "#222222"
:family "Inconsolata"
:height 1.0)
;;
(set-face-attribute ; アクティブタブ
'tabbar-selected nil
:background "#c9c9c9"
:foreground "#4b4b4b"
:weight 'bold)
;;
(set-face-attribute ; ノンアクティブタブ
'tabbar-unselected nil
:background "#c9c9c9"
:foreground "#222222")

(set-face-attribute
 'tabbar-modified nil
:background "#c9c9c9"
:foreground "#222222")
;;
;;キーバインディング
(global-set-key (kbd "<C-tab>") 'tabbar-forward) ;C-Tabで次のタブ
(global-set-key (kbd "<C-iso-lefttab>") 'tabbar-backward) ;C-Shift-Tabで前のタブ
;;-------------------------------------------------------------------------

;; Removes *scratch* from buffer after the mode has been set.
(defun remove-scratch-buffer ()
  (if (get-buffer "*scratch*")
      (kill-buffer "*scratch*")))
(add-hook 'after-change-major-mode-hook 'remove-scratch-buffer)

;; Removes *messages* from the buffer.
(setq-default message-log-max nil)
(kill-buffer "*Messages*")

;; jsx関連
(require 'flycheck)
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))
(flycheck-add-mode 'javascript-eslint 'js2-jsx-mode)
(add-hook 'js2-jsx-mode-hook 'flycheck-mode)

;; ==============================
;;; auto-complete設定
;; ==============================
(add-hook 'emacs-lisp-mode-hook '(lambda ()
                                   (require 'auto-complete)
                                   (auto-complete-mode t)
                                   ))
(require 'auto-complete-config)
(global-auto-complete-mode t)
(ac-config-default)
(add-to-list 'ac-modes 'swift-mode)
(add-to-list 'ac-modes 'js2-mode)
(add-to-list 'ac-modes 'js2-jsx-mode)

;; スクリーンの最大化
(set-frame-parameter nil 'fullscreen 'maximized)

;; 独自キーバインド
;; ウィンドウ間のカーソル移動
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))
(global-set-key (kbd "C-o") 'other-window-or-split)


;; auto-complete
(require 'auto-complete)
(global-auto-complete-mode t)
(setq ac-use-menu-map t)       ;; 補完メニュー表示時にC-n/C-pで補完候補選択
(setq ac-use-fuzzy t)          ;; 曖昧マッチ

;; 右クリック
;; マウスの右クリックの割り当て(押しながらの操作)をはずす
(if window-system (progn
		    (global-unset-key [down-mouse-3])
		    ;; マウスの右クリックメニューを使えるようにする
		    (defun bingalls-edit-menu (event)  (interactive "e")
			   (popup-menu menu-bar-edit-menu))
		    (global-set-key [mouse-3] 'bingalls-edit-menu)))

;; helm
(require 'helm-config)
(helm-mode 1)
(define-key global-map (kbd "C-x C-f") 'helm-find-files)
;; For find-file etc.
(define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
;; For helm-find-files etc.
(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)

;; lockfiles
(setq create-lockfiles nil)

;; smartparens
(require 'smartparens-config)
(add-hook 'js2-jsx-mode-hook #'smartparens-mode)

;; dired+
(require 'dired+)
cask upgrade-cask
;; git-gutter+
(require 'git-gutter+)
;; git-gutter-fringe+
(require 'git-gutter-fringe+)

(global-git-gutter+-mode t)
(use-package git-gutter+
  :ensure t
  :init (global-git-gutter+-mode)
  :config (progn
            (define-key git-gutter+-mode-map (kbd "C-x n") 'git-gutter+-next-hunk)
            (define-key git-gutter+-mode-map (kbd "C-x p") 'git-gutter+-previous-hunk)
            (define-key git-gutter+-mode-map (kbd "C-x v =") 'git-gutter+-show-hunk)
            (define-key git-gutter+-mode-map (kbd "C-x r") 'git-gutter+-revert-hunks)
            (define-key git-gutter+-mode-map (kbd "C-x t") 'git-gutter+-stage-hunks)
            (define-key git-gutter+-mode-map (kbd "C-x c") 'git-gutter+-commit)
            (define-key git-gutter+-mode-map (kbd "C-x C") 'git-gutter+-stage-and-commit)
            (define-key git-gutter+-mode-map (kbd "C-x C-y") 'git-gutter+-stage-and-commit-whole-buffer)
            (define-key git-gutter+-mode-map (kbd "C-x U") 'git-gutter+-unstage-whole-buffer))
  :diminish (git-gutter+-mode . "gg"))
(setq git-gutter+-modified-sign "  ") ;; two space
(setq git-gutter+-added-sign "++")    ;; multiple character is OK
(setq git-gutter+-deleted-sign "--")

(set-face-background 'git-gutter+-modified "purple") ;; background color
(set-face-foreground 'git-gutter+-added "green")
(set-face-foreground 'git-gutter+-deleted "red")

;; auto-save-buffers-enhanced
(require 'auto-save-buffers-enhanced)

;; not-save-fileと.ignoreは除外する
(setq auto-save-buffers-enhanced-exclude-regexps '("^not-save-file" "\\.ignore$"))
;;; Wroteのメッセージを抑制
(setq auto-save-buffers-enhanced-quiet-save-p t)

;;; C-x a sでauto-save-buffers-enhancedの有効・無効をトグル
(global-set-key "\C-xas" 'auto-save-buffers-enhanced-toggle-activity)

;; If you're using CVS or Subversion or git
(auto-save-buffers-enhanced-include-only-checkout-path t)
(auto-save-buffers-enhanced t)

;; scroll one line at a time (less "jumpy" than defaults)

(setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; one line at a time

(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(setq scroll-step 1) ;; keyboard scroll one line at a time

; macだけの設定はここ
(if (eq system-type 'darwin)
    ;; CommandとOptionを入れ替える
    (setq ns-command-modifier (quote meta))
  (setq ns-alternate-modifier (quote super))
  )
