;; Asset Registration Contract
;; Records transportation equipment

(define-data-var contract-owner principal tx-sender)

;; Data map for storing transportation assets
(define-map transportation-assets uint
  {
    owner: principal,
    asset-type: (string-utf8 50),
    capacity: uint,
    registration-date: uint,
    status: (string-utf8 20),
    metadata: (string-utf8 256)
  }
)

;; Counter for asset IDs
(define-data-var asset-id-counter uint u0)

;; Public function to register a new transportation asset
(define-public (register-asset
                (asset-type (string-utf8 50))
                (capacity uint)
                (metadata (string-utf8 256)))
  (let ((new-id (+ (var-get asset-id-counter) u1)))
    (begin
      (var-set asset-id-counter new-id)
      (ok (map-set transportation-assets
                  new-id
                  {
                    owner: tx-sender,
                    asset-type: asset-type,
                    capacity: capacity,
                    registration-date: block-height,
                    status: u"active",
                    metadata: metadata
                  }))
    )
  )
)

;; Public function to update asset status
(define-public (update-asset-status
                (asset-id uint)
                (new-status (string-utf8 20)))
  (let ((asset (map-get? transportation-assets asset-id)))
    (begin
      (asserts! (is-some asset) (err u1))
      (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))
      (ok (map-set transportation-assets
                  asset-id
                  (merge (unwrap-panic asset)
                        { status: new-status })))
    )
  )
)

;; Public function to update asset capacity
(define-public (update-asset-capacity
                (asset-id uint)
                (new-capacity uint))
  (let ((asset (map-get? transportation-assets asset-id)))
    (begin
      (asserts! (is-some asset) (err u1))
      (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))
      (ok (map-set transportation-assets
                  asset-id
                  (merge (unwrap-panic asset)
                        { capacity: new-capacity })))
    )
  )
)

;; Public function to transfer asset ownership
(define-public (transfer-asset-ownership
                (asset-id uint)
                (new-owner principal))
  (let ((asset (map-get? transportation-assets asset-id)))
    (begin
      (asserts! (is-some asset) (err u1))
      (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))
      (ok (map-set transportation-assets
                  asset-id
                  (merge (unwrap-panic asset)
                        { owner: new-owner })))
    )
  )
)

;; Read-only function to get asset details
(define-read-only (get-asset-details (asset-id uint))
  (map-get? transportation-assets asset-id)
)

;; Read-only function to get asset count
(define-read-only (get-asset-count)
  (var-get asset-id-counter)
)

;; Function to transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
