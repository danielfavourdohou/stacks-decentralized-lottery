(define-read-only (get-current-draw)
  (ok (var-get current-draw-id))
)

(define-read-only (get-ticket-price)
  (ok (var-get ticket-price))
)

(define-read-only (get-tickets-count (draw-id uint))
  (ok (default-to u0 (map-get? tickets-per-draw {draw-id: draw-id})))
)

(define-read-only (is-paused)
  (ok (var-get is-paused))
)

(define-read-only (get-collected-fees)
  (ok (var-get collected-fees))
)