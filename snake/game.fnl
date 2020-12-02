(local fennel (require "lib.fennel"))

(fn love.load []
  (global state {:timer 0
                 :direction "right"
                 :dirQueue ["right"]
                 :gridX (math.floor (/ (love.graphics.getWidth) 15))
                 :gridY (/ (love.graphics.getHeight) 15)
                 :size 15
                 :snakeSegments [{:x 3 :y 1} {:x 2 :y 1} {:x 1 :y 1}]
                 :alive true
                 :food {:x -1 :y -1}}))

(fn moveFood []
  (let [positions {:possible {}}]
    (for [foodX 1 state.gridX 1]
      (for [foodY 1 state.gridY 1]
        (let [is {:possible true}]
          (each [si segment (ipairs state.snakeSegments)]
            (if (and (= foodX segment.x) (= foodY segment.y))
                (tset is :possible false)))
          (if is.possible
              (table.insert positions.possible {:x foodX :y foodY})))))
    (set state.food
         (. positions.possible (love.math.random (# positions.possible))))))

(fn love.update [dt]
  (let [utils {:limit 0.10
               :can-move true}]
    (set state.timer (+ state.timer dt))
    ;; (print "gridX" state.gridX " gridY " state.gridY)
    (if state.alive
        (if (>= state.timer utils.limit)
            (do
              (set state.timer (- state.timer utils.limit))

              (if (and (= state.food.x -1) (= state.food.y -1))
                  (moveFood))

              (if (> (# state.dirQueue) 1)
                  (table.remove state.dirQueue 1))

              (let [oldX (. (. state.snakeSegments 1) :x)
                    oldY (. (. state.snakeSegments 1) :y)
                    direction (. state.dirQueue 1)
                    nextX (if (= direction "right") (+ oldX 1)
                              (= direction "left") (- oldX 1)
                              oldX)
                    nextY (if (= direction "down") (+ oldY 1)
                              (= direction "up") (- oldY 1)
                              oldY)
                    nextX (if (> nextX state.gridX) 1
                              (< nextX 1) state.gridX
                              nextX)
                    nextY (if (> nextY state.gridY) 1
                              (< nextY 1) state.gridY
                              nextY)]

                (each [si segment (ipairs state.snakeSegments)]
                  (if (and (~= si (# state.snakeSegments))
                           (= nextX segment.x)
                           (= nextY segment.y))
                      (tset utils :can-move false)))

                (if (. utils :can-move)
                    (do
                      (table.insert state.snakeSegments 1 {:x nextX :y nextY})
                      (if (and (= oldX state.food.x) (= oldY state.food.y))
                          (moveFood)
                          (table.remove state.snakeSegments)))
                    (set state.alive false)))))
        (>= state.timer 2) (love.load))))

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit 0))
  (let [lastQueue (. state.dirQueue (# state.dirQueue))]
    (if (and (= key "right") (~= lastQueue "left") (~= lastQueue "right"))
        (table.insert state.dirQueue "right")
        (and (= key "left") (~= lastQueue "right") (~= lastQueue "left"))
        (table.insert state.dirQueue "left")
        (and (= key "down") (~= lastQueue "up") (~= lastQueue "down"))
        (table.insert state.dirQueue "down")
        (and (= key "up") (~= lastQueue "down") (~= lastQueue "up"))
        (table.insert state.dirQueue "up"))))

(fn drawCell [element]
  (love.graphics.rectangle "fill"
                           (* (- element.x 1) state.size)
                           (* (- element.y 1) state.size)
                           (- state.size 1)
                           (- state.size 1)))

(fn love.draw []
  (love.graphics.setColor .28 .28 .28)
  (love.graphics.rectangle "fill" 0 0
                           (* state.gridX state.size)
                           (* state.gridY state.size))

  (each [si segment (ipairs state.snakeSegments)]
    (if state.alive
        (love.graphics.setColor .6 1 .32)
        (love.graphics.setColor .5 .5 .5))
    (drawCell segment))

  (love.graphics.setColor 1 .3 .3)
  (drawCell state.food))
