;; View functions for the lottery system

;; Get ticket price from admin contract
(define-read-only (get-ticket-price)
  (ok (contract-call? .admin-and-pausing get-ticket-price))
)

;; Get ticket count for a specific draw from ticket-nft
(define-read-only (get-tickets-count (draw-id uint))
  (contract-call? .ticket-nft get-ticket-count draw-id)
)

;; Check if the system is paused
(define-read-only (is-paused)
  (ok (contract-call? .admin-and-pausing get-is-paused))
)

;; Get collected fees from fee-collector
(define-read-only (get-collected-fees)
  (contract-call? .fee-collector get-collected-fees)
)

;; Get tickets for a specific draw
(define-read-only (get-draw-tickets (draw-id uint))
  (contract-call? .ticket-nft get-tickets-for-draw draw-id)
)