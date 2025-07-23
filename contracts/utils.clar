;; Utility functions for the lottery system

;; Calculate percentage of an amount
(define-read-only (calculate-percentage (amount uint) (percentage uint))
  (/ (* amount percentage) u100)
)

;; Check if a value is within a range
(define-read-only (is-in-range (value uint) (min-val uint) (max-val uint))
  (and (>= value min-val) (<= value max-val))
)

;; Get the minimum of two values
(define-read-only (min (a uint) (b uint))
  (if (<= a b) a b)
)

;; Get the maximum of two values
(define-read-only (max (a uint) (b uint))
  (if (>= a b) a b)
)