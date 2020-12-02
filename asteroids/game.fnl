(local fennel (require "lib.fennel"))

(fn love.load []
  (global arena {:width 800 :height 600})
  (global joysticks (love.joystick.getJoysticks))

  (global ship {:x (/ (. arena :width) 2)
                :y (/ (. arena :height) 2)
                :radius 15
                :angle 0
                :speed 0
                :acceleration 10})
  (global bulletDefault {:timeLeft 5 :speed 300 :radius 5})
  (global bullets {})
  (global asteroids
          {1 {:x 100 :y 100
              :radius 30 :speed 30
              :angle (* (love.math.random) (* 2 math.pi))}
           2 {:x (- arena.width 100) :y 100
              :radius 30 :speed 30
              :angle (* (love.math.random) (* 2 math.pi))}
           3 {:x (/ arena.width 2) :y (- arena.height 100)
              :radius 30 :speed 30
              :angle (* (love.math.random) (* 2 math.pi))}}))

(fn circles-colliding? [a b]
  (<= (+ (^ (- a.x b.x) 2)
         (^ (- a.y b.y ) 2))
      (^ (+ a.radius b.radius) 2)))

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit)))

(fn love.update [dt]
  (if (> (love.joystick.getJoystickCount) 0)
      (let [player (. joysticks 1)
            leftx (player:getGamepadAxis "leftx")
            lefty (player:getGamepadAxis "lefty")]
        (if (> (player:getGamepadAxis "triggerright") 0.1)
            (set ship.speed
                 (math.min 70 (+ ship.speed
                                 (* (player:getGamepadAxis "triggerright")
                                    ship.acceleration))))
            (> ship.speed 0)
            (set ship.speed (- ship.speed (* ship.acceleration dt))))

        (if (and (> (math.abs leftx) 0.1) (> (math.abs lefty) 0.1))
            (set ship.angle (math.atan2 lefty leftx)))

        (if (and (player:isGamepadDown "a") (< (# bullets) 5))
            (table.insert bullets
                          {:x (+ ship.x (* (math.cos ship.angle) ship.radius))
                           :y (+ ship.y (* (math.sin ship.angle) ship.radius))
                           :timeLeft 5
                           :radius bulletDefault.radius
                           :speed bulletDefault.speed
                           :angle ship.angle}))))

  ;; move ship
  (set ship.x (+ ship.x (* (math.cos ship.angle) ship.speed dt)))
  (set ship.y (+ ship.y (* (math.sin ship.angle) ship.speed dt)))

  (for [bi (# bullets) 1 -1]
    (let [bullet (. bullets bi)]
      ;; move bullets
      (if (> bullet.timeLeft 0)
          (do
            (set bullet.timeLeft (- bullet.timeLeft 0.1))
            (set bullet.x (+ bullet.x
                             (* (math.cos bullet.angle)
                                bulletDefault.speed
                                dt)))
            (set bullet.y (+ bullet.y
                             (* (math.sin bullet.angle)
                                bulletDefault.speed
                                dt))))
          (table.remove bullets bi))

      ;; check collisions of bullets with asteroids
      (for [ai (# asteroids) 1 -1]
        (let [asteroid (. asteroids ai)]
          (when (circles-colliding? bullet asteroid)
            (let [angle1 (* (love.math.random) (* 2 math.pi))
                  angle2 (% (- angle1 math.pi) (* 2 math.pi))
                  radius (- asteroid.radius 4)]
              (table.remove bullets bi)
              (if (>= radius 10)
                  (do
                    (table.remove asteroids ai)
                    (table.insert asteroids {:x asteroid.x
                                             :y asteroid.y
                                             :radius radius
                                             :speed (math.random 50)
                                             :angle angle1})
                    (table.insert asteroids {:x asteroid.x
                                             :y asteroid.y
                                             :radius radius
                                             :speed 30
                                             :angle angle2}))
                  (table.remove asteroids ai))))))))

  ;; move asteroids
  (each [_ asteroid (ipairs asteroids)]
    (set asteroid.x (% (+ asteroid.x (* (math.cos asteroid.angle)
                                        asteroid.speed dt))
                       arena.width))
    (set asteroid.y (% (+ asteroid.y (* (math.sin asteroid.angle)
                                        asteroid.speed dt))
                       arena.height))
    (if (circles-colliding? ship asteroid)
        (love.load)))

  (if (= (# asteroids) 0)
      (love.load)))

(fn love.draw []
  (for [y -1 1]
    (for [x -1 1]
      (love.graphics.origin)
      (love.graphics.translate (* x arena.width) (* y arena.height))

      (love.graphics.setColor 0 0 1)
      (love.graphics.circle "fill" ship.x ship.y ship.radius)

      (love.graphics.setColor 0 1 1)
      (love.graphics.circle
       "fill"
       (+ ship.x (* (math.cos ship.angle) ship.radius))
       (+ ship.y (* (math.sin ship.angle) ship.radius))
       5)

      (each [_ bullet (ipairs bullets)]
        (love.graphics.setColor 0 1 0)
        (love.graphics.circle "fill" bullet.x bullet.y bullet.radius))

      (each [_ asteroid (ipairs asteroids)]
        (love.graphics.setColor 1 1 0)
        (love.graphics.circle "fill" asteroid.x asteroid.y asteroid.radius)))))
