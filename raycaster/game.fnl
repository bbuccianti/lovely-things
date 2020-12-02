(local fennel (require "lib.fennel"))

(local map (require "map"))

(fn love.load []
  (global state {:mapWidth 24
                 :mapHeight 24
                 :screenWidth 640
                 :screenHeight 480
                 :posX 22
                 :posY 12
                 :dirX -1
                 :dirY 0
                 :planeX 0
                 :planeY 0.66
                 :time 0
                 :old-time 0}))

(fn love.update [dt])

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit 0)
      (= key "r")
      (love.load)))

(fn love.draw [])
