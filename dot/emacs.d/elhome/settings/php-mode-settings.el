(add-hook 'php-mode-hook (lambda ()
  (c-set-offset 'arglist-intro '+)
  (c-set-offset 'arglist-close '0)
  ))
