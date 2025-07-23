;; Ticket NFT contract for lottery system

;; Define the NFT
(define-non-fungible-token lottery-ticket {draw-id: uint, ticket-id: uint})

;; Define trait for ticket NFT functionality
(define-trait ticket-nft-trait
  (
    (mint (principal uint) (response uint uint))
    (select-winner (uint uint) (response principal uint))
    (get-tickets-for-draw (uint) (response (list 100 principal) uint))
  ))

;; Data storage
(define-map draw-tickets {draw-id: uint} (list 100 principal))
(define-map ticket-counter {draw-id: uint} uint)

;; Mint a new ticket for a draw
(define-public (mint (owner principal) (draw-id uint))
  (let ((ticket-id (+ (default-to u0 (map-get? ticket-counter {draw-id: draw-id})) u1)))
    (match (nft-mint? lottery-ticket {draw-id: draw-id, ticket-id: ticket-id} owner)
      success (begin
        (map-set ticket-counter {draw-id: draw-id} ticket-id)
        (let ((current-tickets (default-to (list) (map-get? draw-tickets {draw-id: draw-id}))))
          (map-set draw-tickets {draw-id: draw-id} (unwrap! (as-max-len? (append current-tickets owner) u100) (err u1008)))
          (ok ticket-id)
        )
      )
      error (err u1008)
    )
  )
)

;; Select a winner from the tickets for a specific draw
(define-public (select-winner (draw-id uint) (random-value uint))
  (let ((tickets (unwrap! (map-get? draw-tickets {draw-id: draw-id}) (err u1004))))
    (if (> (len tickets) u0)
      (let ((index (mod random-value (len tickets))))
        (ok (unwrap! (element-at tickets index) (err u1007)))
      )
      (err u1004)
    )
  )
)

;; Get all tickets for a specific draw
(define-read-only (get-tickets-for-draw (draw-id uint))
  (ok (default-to (list) (map-get? draw-tickets {draw-id: draw-id})))
)

;; Get ticket count for a draw
(define-read-only (get-ticket-count (draw-id uint))
  (ok (len (default-to (list) (map-get? draw-tickets {draw-id: draw-id}))))
)