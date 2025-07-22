(use-trait ticket-nft-trait .ticket-nft.ticket-nft-trait)
(use-trait randomness-trait .randomness.randomness-trait)

(define-constant JACKPOT_PERCENTAGE u90)
(define-constant FEE_PERCENTAGE u10)

(define-data-var draw-block-height uint u0)
(define-data-var ticket-price uint u1000000) ;; 1 STX
(define-data-var current-draw-id uint u0)

(define-map tickets-per-draw {draw-id: uint} {count: uint})

(impl-trait .lottery-core.lottery-trait)

(define-trait lottery-trait
  (
    (buy-ticket (principal) (response uint uint))
    (draw-winner () (response principal uint))
  ))

(define-public (buy-ticket (buyer principal))
  (begin
    (try! (contract-call? .admin-and-pausing.ensure-not-paused))
    (let ((price (var-get ticket-price)))
      (asserts! (>= (stx-get-balance buyer tx-sender) price) ERR_INVALID_PRICE)
      (stx-transfer? price tx-sender (as-contract tx-sender))
      (let ((draw-id (var-get current-draw-id)))
        (map-set tickets-per-draw {draw-id: draw-id} {count: (+ (default-to u0 (map-get? tickets-per-draw {draw-id: draw-id})) u1)})
        (contract-call? .ticket-nft.mint buyer draw-id)
        (ok draw-id)
      )
    )
  )
)

(define-public (draw-winner)
  (begin
    (try! (contract-call? .admin-and-pausing.ensure-admin))
    (try! (contract-call? .admin-and-pausing.ensure-not-paused))
    (let ((draw-id (var-get current-draw-id))
      (asserts! (> (default-to u0 (map-get? tickets-per-draw {draw-id: draw-id})) u0) ERR_NO_TICKETS)
      (let ((random-value (contract-call? .randomness.get-random-number draw-id))
        (let ((winner (contract-call? .ticket-nft.select-winner draw-id random-value)))
          (let ((jackpot (* (var-get ticket-price) (default-to u0 (map-get? tickets-per-draw {draw-id: draw-id}))))
            (var-set current-draw-id (+ draw-id u1))
            (var-set draw-block-height block-height)
            (stx-transfer? (* jackpot JACKPOT_PERCENTAGE) (as-contract tx-sender) winner)
            (ok winner jackpot)
          )
        )
      )
    )
  )
)