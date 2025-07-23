;; Admin and pausing functionality
(define-constant ADMIN tx-sender)

(define-data-var is-paused bool false)
(define-data-var ticket-price uint u1000000) ;; 1 STX

(define-public (ensure-admin)
  (ok (asserts! (is-eq tx-sender ADMIN) (err u1001)))
)

(define-public (ensure-not-paused)
  (ok (asserts! (not (var-get is-paused)) (err u1002)))
)

(define-public (set-paused (paused bool))
  (begin
    (try! (ensure-admin))
    (var-set is-paused paused)
    (ok paused)
  )
)

(define-public (set-ticket-price (price uint))
  (begin
    (try! (ensure-admin))
    (var-set ticket-price price)
    (ok price)
  )
)

;; Read-only functions
(define-read-only (get-ticket-price)
  (var-get ticket-price)
)

(define-read-only (get-is-paused)
  (var-get is-paused)
)