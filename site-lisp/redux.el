;;; redux.el --- Utilities for generating redux boilerplate -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun redux-inflate-template (filename snippet-key)
  (interactive)
  (save-window-excursion
    (find-file filename)
    (insert snippet-key)
    (yas-expand)
    (save-buffer)))

(defvar redux-templates
  '(("index.js" "index")
    ("actions.js" "actions")
    ("constants.js" "constants")
    ("reducer.js" "reducer")
    ("selectors.js" "selectors")))

(defun redux-create-boilerplate ()
  (interactive)
  (save-window-excursion
    (dolist (args redux-templates)
      (apply 'redux-inflate-template args))))

(provide 'redux)
;;; redux.el ends here
