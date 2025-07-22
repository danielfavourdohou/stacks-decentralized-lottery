;; Utility functions
(define-private (element-at (items (list 100 principal)) (index uint))
  (unwrap! (element-at items index) ERR_INVALID_TICKET)
)

(define-private (xor (a uint) (b uint))
  (bitwise-xor a b)
)