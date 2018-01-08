;;; setup-clojure.el --- My Clojure development configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; (require 'inf-clojure)

;; Planck setup
;; (setq inf-clojure-project-root-files '("project.clj" "build.boot" "src"))
;; (setq inf-clojure-program "planck -c src/main:src/test")

;; (setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")
;; (require 'clojure)
;; Mode hooks
;; (add-hook 'clojure-mode-hook
;;           (lambda ()
;;             (paredit-mode)
;;             (cider-mode)))

;; (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)


;; ----- Custom indentation -----

;; Untangled Web
(defvar my/clojure-indentations
  '(

    ;;; Arachne
    (server . 1)
    (id . 1)
    (map-transform . 2)
    (type . 2)
    (attr . 4)
    (endpoint . 2)

    ;;; antizer
    (form . 1)
    (form-item . 1)
    (row . 1)
    (col . 1)
    (decorate-field . 2)

    ;;; boot

    ;; (set-env! . 1)

    ;;; me
    (keybinding . 1)

    ;;; clojure.data.xml
    (element . 2)

    ;;; Garden
    (at-media . 1)

    (specification . 1)
    (behavior . 1)
    (assertions . 1)
    (component . 1)
    (provided . 1)

    ;; Generic Clojure
    (apply . 1)
    (assoc . 1)
    (assoc-in . 1)
    (into . 1)
    (join . 1)
    (merge-with . 1)
    (updatein . 2)
    (update . 1)

    ;; React related
    (parser . 1)
    (a . 1)
    (article . 1)
    (section . 1)
    (button . 1)
    (canvas . 1)
    (code . 1)
    (componentWillReceiveProps . 1)
    (componentWillUpdate . 1)
    (componentDidUpdate . 1)
    (componentWillMount . 1)
    (componentDidMount . 1)
    (componentWillUnmount . 1)
    (computed . 1)
    (defui . (1 nil nil (1)))
    (div . 1)
    (nav . 1)
    ;; (form . 1)
    (table . 1)
    (thead . 1)
    (tbody . 1)
    (tr . 1)
    (td . 1)
    (th . 1)
    (execute! . 1)
    (execute-query! . 1)
    (h1 . 1)
    (h2 . 1)
    (h3 . 1)
    (h4 . 1)
    (h5 . 1)
    (h6 . 1)
    (header . 1)
    (ident . 1)
    (initLocalState . 1)
    (input . 1)
    (li . 1)
    (navigated-to . 1)
    (params . 1)
    (pre . 1)
    (query . 1)
    (render . 1)
    (render-invalid . 1)
    (run-query . 1)
    (span . 1)
    (swap! . 1)
    (svg . 1)
    (Text . 1)
    (transact! . 1)
    (ul . 1)
    (p . 1)

    ;; Custom dom things
    (col . 1)
    ;; (row . 1)

    ;; React native
    (View . 1)
    (view . 1)
    (text . 1)
    (image . 1)
    (touchable-highlight . 1)

    ;; Component
    (start . 1)
    (stop . 1)

    ;; Gloss
    (enum . 1)
    (finite-frame . 1)

    ;; Leiningen templates
    (->files . 1)

    ;; Monet
    (add-entity . 2)
    (entity . 1)))

(provide 'clojure-indentations)
;;; setup-clojure.el ends here
