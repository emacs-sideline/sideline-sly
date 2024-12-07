;;; sideline-sly.el --- Show SLY result with sideline  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/emacs-sideline/sideline-sly
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (sideline "0.1.0") (sly-overlay "1.0.1"))
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Show SLY result with sideline.
;;

;;; Code:

(require 'sideline)
(require 'sly-overlay)

(defgroup sideline-sly nil
  "Show SLY result with sideline."
  :prefix "sideline-sly-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/emacs-sideline/sideline-sly"))

(defface sideline-sly-result-overlay-face
  '((((class color) (background light))
     :background "grey90" :box (:line-width -1 :color "yellow"))
    (((class color) (background dark))
     :background "grey10" :box (:line-width -1 :color "black")))
  "Face used to display evaluation results."
  :group 'sideline-sly)

(defvar sideline-sly--buffer nil
  "Record the evaluation buffer.")

(defvar-local sideline-sly--callback nil
  "Callback to display result.")

;;;###autoload
(defun sideline-sly (command)
  "Backend for sideline.

Argument COMMAND is required in sideline backend."
  (cl-case command
    (`candidates (cons :async
                       (lambda (callback &rest _)
                         (setq sideline-sly--callback callback
                               sideline-sly--buffer (current-buffer)))))
    (`face 'sideline-sly-result-overlay-face)))

(defun sideline-sly--result (value)
  "Display the result VALUE."
  (when (and value
             sideline-sly--buffer)
    (with-current-buffer sideline-sly--buffer
      (funcall sideline-sly--callback (list (sideline-2str value))))))

(defun sideline-sly--mode ()
  "Add hook to `sideline-mode-hook'."
  (cond (sideline-mode
         (advice-add #'sly-display-eval-result :after #'sideline-sly--result))
        (t
         (advice-remove #'sly-display-eval-result #'sideline-sly--result))))

;;;###autoload
(defun sideline-sly-setup ()
  "Setup for `sly'."
  (add-hook 'sideline-mode-hook #'sideline-sly--mode)
  (sideline-sly--mode))  ; Run once

(provide 'sideline-sly)
;;; sideline-sly.el ends here
