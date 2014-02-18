
;; =========== For MATLAB Mode ==========

;; Add hook for matlab mode
(add-hook 'matlab-mode-hook 'my-matlab-key-bindings)

(defun my-matlab-key-bindings ()
  "Crpi's key bindings for Matlab mode"

  (define-key matlab-eei-mode-map [(f10)] 'matlab-eei-step)
  (define-key matlab-eei-mode-map [(f11)] 'matlab-eei-step-in)
  (define-key matlab-eei-mode-map [(shift f11)] 'matlab-eei-step-out)
  (define-key matlab-eei-mode-map [(f5)] 'matlab-eei-run-continue)
  (define-key matlab-eei-mode-map [(f12)] 'matlab-eei-breakpoint-set-clear)
  (define-key matlab-eei-mode-map [(f6)] 'matlab-eei-eval-region)
)



;; =========== End MATLAB Mode ==========
