(impl-trait .randomness.randomness-trait)

(define-trait randomness-trait
  ((get-random-number (uint) (response uint uint))))

(define-map random-seeds {draw-id: uint} {seed: uint})

(define-public (get-random-number (draw-id uint))
  (let ((seed (default-to block-height (map-get? random-seeds {draw-id: draw-id}))))
    (map-set random-seeds {draw-id: draw-id} {seed: (+ seed block-height tx-sender)})
    (ok draw-id (xor seed block-height))
  )
)