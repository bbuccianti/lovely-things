;; Rules
;; 1) Any live cell with two or three live neighbours survives.
;; 2) Any dead cell with three live neighbours becomes a live cell.
;; 3) All other live cells die in the next generation.

(local lurker (require "lib.lurker"))

(fn init-grid [size]
  (let [grid []]
    (for [i 1 size]
      (tset grid i 0))
    grid))

(fn love.load []
  (global config {:gridSize 10
                   :cellSize 30})
  (global state {:grid (init-grid (math.pow config.gridSize 2))}))

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit 0)))

(fn love.update [dt]
  (lurker.update))

(fn love.mousepressed [x y button]
  (let [cellX (math.ceil (/ x config.cellSize))
        cellY (math.ceil (/ y config.cellSize))
        index (+ cellX (* (- cellY 1) 10))]
    (if (= button 1)
        (tset state.grid index
              (if (= (. state.grid index) 1) 0 1)))))

(fn love.draw []
  (each [ci cell (ipairs state.grid)]
    (let [x (* config.cellSize (% (- ci 1) config.gridSize))
          y (* config.cellSize (math.floor (/ (- ci 1) 10)))]
      (if (= cell 1)
          (love.graphics.setColor 1 0 0)
          (love.graphics.setColor .4 .4 .4))

      (love.graphics.rectangle "fill"
                               x
                               y
                               (- config.cellSize 1)
                               (- config.cellSize 1)))))
