(local fennel (require :lib.fennel))
(local lume (require :lib.lume))
(local lurker (require :lib.lurker))
(local colors (require :colors))

(fn love.load []
  (global constants {:cellw 2
                     :cellh 2})
  (global fire {:width (/ (love.graphics.getWidth) constants.cellw)
                :height (/ (love.graphics.getHeight) constants.cellh)
                :state []})
  (for [x 1 fire.width]
    (tset fire.state x {})
    (for [y 1 fire.height]
      (let [amount (if (= y fire.height) 36 1)]
        (tset (. fire.state x) y amount)))))

(fn spread-fire [x y]
  (let [rand (lume.round (bit.band (* (lume.random) 3.0) 3))
        from (. fire.state x y)
        to (+ 1 (- y 1 rand))]
    (tset (. fire.state
             (if (> (math.random) 0.5)
                 (math.max (- x (bit.band rand 1)) 1)
                 (math.min (+ x (bit.band rand 1)) fire.width)))
          (math.max to 1)
          (math.max (- from (bit.band rand 1)) 1))))

(fn love.update [dt]
  (lurker.update)
  (for [x 1 fire.width]
    (for [y 2 fire.height]
      (spread-fire x y))))

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit 0)
      (= key "r")
      (love.load)))

(fn love.draw []
  (for [x 1 fire.width]
    (for [y 1 fire.height]
      (love.graphics.setColor (. colors (. fire.state x y)))
      (love.graphics.rectangle "fill"
                               (* constants.cellw (- x 1))
                               (* constants.cellh (- y 1))
                               constants.cellw
                               constants.cellh))))
