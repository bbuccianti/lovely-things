(local lurker (require "lib.lurker"))

(fn love.load []
  (love.keyboard.setKeyRepeat true)
  (love.graphics.setBackgroundColor 1 1 1)
  (global cell {:size 8})
  (global state {:x 0 :y 0})
  (global grid {:rows 70
                :columns 50
                :table {}})
  (for [y 1 grid.columns]
    (tset grid.table y {})
    (for [x 1 grid.rows]
      (tset (. grid.table y) x 0))))

(fn love.update []
  (lurker.update)
  (set state.x (+ 1 (math.floor (/ (love.mouse.getX) cell.size))))
  (set state.y (+ 1 (math.floor (/ (love.mouse.getY) cell.size))))

  (when (and (<= state.x grid.rows) (<= state.y grid.columns))
    (if (love.mouse.isDown 1)
        (tset (. grid.table state.y) state.x 1)
        (love.mouse.isDown 2)
        (tset (. grid.table state.y) state.x 0))))

(fn love.keypressed [key]
  (when (= key "r")
    (love.load)
    (print "Loaded!"))

  (when (= key "n")
    (let [next {}]
      (for [y 1 grid.columns]
        (tset next y {})
        (for [x 1 grid.rows]
          (let [neighbours {:count 0}]
            (for [dy -1 1]
              (for [dx -1 1]
                (if (and (not (= dy dx 0))
                         (. grid.table (+ y dy))
                         (= 1 (. grid.table (+ y dy) (+ x dx))))
                    (set neighbours.count (+ 1 neighbours.count)))))
            (if (and (= 1 (. grid.table y x))
                     (or (= neighbours.count 2) (= neighbours.count 3)))
                (tset (. next y) x 1)
                (and (= 0 (. grid.table y x))
                     (= neighbours.count 3))
                (tset (. next y) x 1)
                (tset (. next y) x 0)))))
      (set grid.table next))))

(fn love.draw []
  (for [y 1 grid.columns]
    (for [x 1 grid.rows]
      (let [size (- cell.size 1)]
        (if (and (= x state.x) (= y state.y))
            (love.graphics.setColor 0 1 1)
            (= 1 (. grid.table y x))
            (love.graphics.setColor 1 0 1)
            (love.graphics.setColor .86 .86 .86))
        (love.graphics.rectangle "fill"
                                 (* cell.size (- x 1))
                                 (* cell.size (- y 1))
                                 size
                                 size)))))
