;; Carrier Verification Contract
;; This contract validates transportation providers

(define-data-var contract-owner principal tx-sender)

;; Data map for storing verified carriers
(define-map verified-carriers principal
  {
    name: (string-utf8 100),
    license-id: (string-utf8 50),
    verification-date: uint,
    status: (string-utf8 20),
    rating: uint
  }
)

;; Public function to register a new carrier (only contract owner can call)
(define-public (register-carrier
                (carrier-principal principal)
                (name (string-utf8 100))
                (license-id (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-none (map-get? verified-carriers carrier-principal)) (err u2))
    (ok (map-set verified-carriers
                carrier-principal
                {
                  name: name,
                  license-id: license-id,
                  verification-date: block-height,
                  status: u"active",
                  rating: u0
                }))
  )
)

;; Public function to update carrier status
(define-public (update-carrier-status
                (carrier-principal principal)
                (new-status (string-utf8 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-some (map-get? verified-carriers carrier-principal)) (err u3))
    (ok (map-set verified-carriers
                carrier-principal
                (merge (unwrap-panic (map-get? verified-carriers carrier-principal))
                      { status: new-status })))
  )
)

;; Public function to update carrier rating
(define-public (update-carrier-rating
                (carrier-principal principal)
                (new-rating uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-some (map-get? verified-carriers carrier-principal)) (err u3))
    (asserts! (<= new-rating u5) (err u4))
    (ok (map-set verified-carriers
                carrier-principal
                (merge (unwrap-panic (map-get? verified-carriers carrier-principal))
                      { rating: new-rating })))
  )
)

;; Read-only function to check if a carrier is verified
(define-read-only (is-verified-carrier (carrier-principal principal))
  (is-some (map-get? verified-carriers carrier-principal))
)

;; Read-only function to get carrier details
(define-read-only (get-carrier-details (carrier-principal principal))
  (map-get? verified-carriers carrier-principal)
)

;; Function to transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
