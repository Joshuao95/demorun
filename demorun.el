;;; demorun.el --- Run live coding demos -*- lexical-binding: t -*-

;; Author: Joshua O'Connor
;; Maintainer: Joshua O'Connor
;; Version: 0.1

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; TODO: Add docs

;;; Code:
(require 'map)

(defvar demorun--demo-frame)
(defvar demorun-typing-speed 0.01 "Delay in seconds between characters for :type.")

;; TODO: Should be a customisable dude
(defvar demorun-commands '((:file . find-file)
			   (:run . (lambda (command) (insert command) (sit-for 5) (comint-send-input)))
			   (:type . demorun--type)
			   (:lisp . (lambda (form-list) (mapc (lambda (form) (eval form)) form-list)))))

;; Demo Helpers

(defun demorun--type (string &optional delay)
  "Insert STRING at one char/DELAY speed."
  (let ((delay (or delay demorun-typing-speed)))
    (mapc (lambda (c) (sleep-for delay) (insert c) (redisplay t))
	  string)))

(defmacro demorun--save-frame-excursion (&rest BODY)
  "Eval BODY in the demo frame."
  `(progn
     (select-frame-set-input-focus demorun--demo-frame)
     ,@BODY
     (select-frame-set-input-focus (selected-frame))))

(defun demorun-init (dir)
  "Create a demo frame and set default-dir to DIR."
  (setq demorun--demo-frame (make-frame '((name . "demorun"))))
  (demorun--save-frame-excursion
   (switch-to-buffer "Demorun")
   (setq-local default-directory dir)))


(defun demorun--run-command-pair (command-name arg)
  "Call the demorun-command COMMAND-NAME with ARG."
  (demorun--save-frame-excursion (funcall (alist-get command-name demorun-commands) arg)))


(defun demorun (&rest commands)
  "Run COMMANDS in demo frame.
COMMANDS should be a PLIST of keywords and args as defined by demorun-commands"
  ;; TODO: This currently does a save-frame-excursion for each command, instead we should bunch
  ;;       the expanded commands into a list and run em at once
  (map-do 'demorun--run-command-pair commands))


(provide 'demorun)

;;; demorun.el ends here
