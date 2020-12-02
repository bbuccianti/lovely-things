(local lurker (require "lib.lurker"))

(fn love.load []
  (love.graphics.setNewFont 30)
  (global config {:size 4})
  (global grid {})

  (global initial-value
          (fn [x y]
            (+ x (* (- y 1) config.size))))

  (for [y 1 config.size]
    (tset grid y {})
    (for [x 1 config.size]
      (tset (. grid y) x (initial-value x y))))

  (global is-completed?
          (fn  []
            (let [state {:complete true}]
              (for [y 1 config.size]
                (for [x 1 config.size]
                  (if (~= (. grid y x) (initial-value x y))
                      (set state.complete false))))
              state.complete)))

  (global get-empty-position
          (fn [grid size]
            (let [empty {:x -1 :y -1}]
              (for [y 1 size]
                (for [x 1 size]
                  (if (= (. (. grid y) x) (* size size))
                      (do
                        (set empty.x x)
                 (set empty.y y)))))
              empty)))

  (global move
          (fn [direction]
            (let [empty (get-empty-position grid config.size)
                  movement {:x empty.x :y empty.y}]
              (if (= direction "down")
                  (set movement.y (- movement.y 1))
                  (= direction "up")
                  (set movement.y (+ movement.y 1))
                  (= direction "left")
                  (set movement.x (+ movement.x 1))
                  (= direction "right")
                  (set movement.x (- movement.x 1)))

              (when (and (. grid movement.y) (. grid movement.y movement.x))
                (let [old (. (. grid movement.y) movement.x)
                      old2 (. (. grid empty.y) empty.x)]
                  (tset (. grid movement.y) movement.x old2)
                  (tset (. grid empty.y) empty.x old))))))

  (for [move-number 1 1000]
    (let [empty (get-empty-position grid config.size)
          movement {:x empty.x :y empty.y}
          roll {:random (love.math.random 4)}]
      (if (= roll.random 1) (move "down")
          (= roll.random 2) (move "up")
          (= roll.random 3) (move "left")
          (= roll.random 4) (move "right"))))

  (for [i 1 (- config.size 1)]
    (move "left"))
  (for [i 1 (- config.size 1)]
    (move "up")))

(fn love.update [dt]
  (lurker.update))

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit))
  (if (= key "down") (move "down")
      (= key "up") (move "up")
      (= key "right") (move "right")
      (= key "left") (move "left"))
  (if (is-completed?) (love.load)))

(fn love.draw []
  (for [y 1 config.size]
    (for [x 1 config.size]
      (let [size 100
            drawSize (- size 1)
            number (. (. grid y) x)]
        (if (~= number (* config.size config.size))
            (do
              (love.graphics.setColor .4 .1 .6)
              (love.graphics.rectangle "fill"
                                       (* (- x 1) size)
                                       (* (- y 1) size)
                                       drawSize
                                       drawSize)
              (love.graphics.setColor 1 1 1)
              (love.graphics.print number
                                   (* (- x 1) size)
                                   (* (- y 1) size))))))))
