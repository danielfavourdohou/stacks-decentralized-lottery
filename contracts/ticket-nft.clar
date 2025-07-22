(define-non-fungible-ticket ticket (draw-id uint))

(impl-trait .ticket-nft.ticket-nft-trait)

(define-trait ticket-nft-trait
  (
    (mint (principal uint) (response uint uint))
    (select-winner (uint uint) (response principal uint))
  ))

(define-map draw-tickets {draw-id: uint} (list 100 principal))

(define-public (mint (owner principal) (draw-id uint))
  (begin
    (nft-mint? ticket owner {draw-id: draw-id})
    (map-set draw-tickets {draw-id: draw-id} (append (default-to (list principal) (map-get? draw-tickets {draw-id: draw-id})) owner))
    (ok draw-id (nft-get-last-token-id ticket))
  )
)

(define-public (select-winner (draw-id uint) (random-value uint))
  (let ((tickets (unwrap! (map-get? draw-tickets {draw-id: draw-id}) ERR_NO_TICKETS)))
    (let ((index (mod random-value (len tickets))))
      (ok (element-at tickets index) draw-id)
    )
  )
)