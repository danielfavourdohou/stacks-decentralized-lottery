;; Core lottery functionality

;; Constants
(define-constant JACKPOT_PERCENTAGE u90)
(define-constant FEE_PERCENTAGE u10)

;; Data variables
(define-data-var draw-block-height uint u0)
(define-data-var current-draw-id uint u1)
(define-data-var total-prize-pool uint u0)

;; Data maps
(define-map draw-info {draw-id: uint} {
  total-tickets: uint,
  prize-pool: uint,
  winner: (optional principal),
  is-completed: bool
})

;; Define trait for lottery functionality
(define-trait lottery-trait
  (
    (buy-ticket (principal) (response uint uint))
    (draw-winner () (response principal uint))
    (get-current-draw-id () (response uint uint))
  ))

;; Buy a ticket for the current draw
(define-public (buy-ticket (buyer principal))
  (begin
    (try! (contract-call? .admin-and-pausing ensure-not-paused))
    (let ((price (contract-call? .admin-and-pausing get-ticket-price))
          (draw-id (var-get current-draw-id)))
      (asserts! (>= (stx-get-balance tx-sender) price) (err u1003))
      (match (stx-transfer? price tx-sender (as-contract tx-sender))
        success (begin
          (let ((current-info (default-to {total-tickets: u0, prize-pool: u0, winner: none, is-completed: false}
                                         (map-get? draw-info {draw-id: draw-id}))))
            (map-set draw-info {draw-id: draw-id}
              (merge current-info {
                total-tickets: (+ (get total-tickets current-info) u1),
                prize-pool: (+ (get prize-pool current-info) price)
              }))
          )
          (match (contract-call? .ticket-nft mint buyer draw-id)
            ticket-id (begin
              ;; Collect fee
              (let ((fee-amount (contract-call? .utils calculate-percentage price FEE_PERCENTAGE)))
                (try! (contract-call? .fee-collector collect-fee fee-amount))
              )
              (ok ticket-id)
            )
            error (err u1008)
          )
        )
        error (err u1009)
      )
    )
  )
)

;; Draw winner for the current draw
(define-public (draw-winner)
  (begin
    (try! (contract-call? .admin-and-pausing ensure-admin))
    (try! (contract-call? .admin-and-pausing ensure-not-paused))
    (let ((draw-id (var-get current-draw-id)))
      (let ((draw-data (unwrap! (map-get? draw-info {draw-id: draw-id}) (err u1004))))
        (asserts! (> (get total-tickets draw-data) u0) (err u1004))
        (asserts! (not (get is-completed draw-data)) (err u1010))

        ;; Get random number and select winner
        (let ((random-result (try! (contract-call? .randomness get-random-number draw-id))))
          (let ((winner-result (try! (contract-call? .ticket-nft select-winner draw-id random-result))))
            ;; Calculate jackpot (90% of prize pool)
            (let ((jackpot (contract-call? .utils calculate-percentage (get prize-pool draw-data) JACKPOT_PERCENTAGE)))
              ;; Transfer jackpot to winner
              (match (as-contract (stx-transfer? jackpot tx-sender winner-result))
                success (begin
                  ;; Mark draw as completed
                  (map-set draw-info {draw-id: draw-id}
                    (merge draw-data {winner: (some winner-result), is-completed: true}))
                  ;; Start new draw
                  (var-set current-draw-id (+ draw-id u1))
                  (var-set draw-block-height burn-block-height)
                  (ok winner-result)
                )
                error (err u1009)
              )
            )
          )
        )
      )
    )
  )
)

;; Get current draw ID
(define-read-only (get-current-draw-id)
  (ok (var-get current-draw-id))
)

;; Get draw information
(define-read-only (get-draw-info (draw-id uint))
  (ok (map-get? draw-info {draw-id: draw-id}))
)

;; Get total prize pool for current draw
(define-read-only (get-current-prize-pool)
  (let ((draw-id (var-get current-draw-id)))
    (match (map-get? draw-info {draw-id: draw-id})
      info (ok (get prize-pool info))
      (ok u0)
    )
  )
)