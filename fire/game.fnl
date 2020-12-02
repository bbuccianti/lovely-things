(local fennel (require :lib.fennel))
(local colors (require :colors))

(fn love.load []
  (print colors))

(fn love.update [dt])

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit 0)
      (= key "r")
      (love.load)))

(fn love.draw [])
