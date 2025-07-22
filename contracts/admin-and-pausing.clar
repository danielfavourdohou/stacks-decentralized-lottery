(define-constant ADMIN tx-sender)

(define-data-var is-paused bool false)

(define-public (ensure-admin)
  (asserts! (is-eq tx-sender ADMIN) ERR_UNAUTHORIZED)
)

(define-public (ensure-not-paused)
  (asserts! (not (var-get is-paused)) ERR_PAUSED)
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