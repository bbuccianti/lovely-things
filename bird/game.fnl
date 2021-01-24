(local fennel (require :lib.fennel))
(local lume (require :lib.lume))
(local lurker (require :lib.lurker))

(fn new-pipe-spacey [p scr]
  (let [min 54]
    (tset p :spacey (lume.random min
                                 (- scr.height
                                    p.spaceh
                                    min)))))

(fn love.load []
  (global state {:score 0
                 :next-pipe 1})

  (global screen {:width (love.graphics.getWidth)
                  :height (love.graphics.getHeight)})

  (global bird {:y 200
                :x (- (/ screen.width 2) 15)
                :speedy 0
                :width 30
                :height 25})

  (global pipe1 {:x screen.width
                 :width 54
                 :spaceh 100
                 :spacey 100})

  (global pipe2 {:x (+ screen.width (/ (+ screen.width 54) 2))
                 :width 54
                 :spaceh 100
                 :spacey 100})

  (new-pipe-spacey pipe1 screen)
  (new-pipe-spacey pipe2 screen))

(fn move-pipe [dt pipe]
  (tset pipe :x (- pipe.x (* 60 dt)))

  ;; reset if reaching start of screen
  (when (< (+ pipe.x pipe.width) 0)
    (tset pipe :x screen.width)
    (new-pipe-spacey pipe screen)))

(fn bird-pipe-collide? []
  (each [i pipe (ipairs [pipe1 pipe2])]
    (when (and (< bird.x (+ pipe.x pipe.width))
               (> (+ bird.x bird.width) pipe.x)
               (or (< bird.y pipe.spacey)
                   (> (+ bird.y bird.height) (+ pipe.spacey pipe.spaceh))))
      (love.load))))

(fn love.update [dt]
  (lurker.update)

  ;; move bird
  (tset bird :speedy (+ (* 516 dt) bird.speedy))
  (tset bird :y (+ (* bird.speedy dt) bird.y))

  ;; move pipe
  (move-pipe dt pipe1)
  (move-pipe dt pipe2)

  (bird-pipe-collide?)

  ;; bird falling of playing area
  (when (> bird.y screen.height)
    (love.load))

  ;; scoring!
  (when (and (= state.next-pipe 1)
             (> bird.x (+ pipe1.x pipe1.width)))
    (tset state :score (+ state.score 1))
    (tset state :next-pipe 2))

  (when (and (= state.next-pipe 2)
             (> bird.x (+ pipe2.x pipe2.width)))
    (tset state :score (+ state.score 1))
    (tset state :next-pipe 1)))

(fn love.keypressed [key]
  (if (= key "escape")
      (love.event.quit 0)
      (= key "r")
      (love.load))

  (when (>= bird.y 0)
    (tset bird :speedy -165)))

(fn draw-pipe [pp]
  ;; pipe
  (love.graphics.setColor .37 .82 .28)

  ;; top segment
  (love.graphics.rectangle "fill"
                           pp.x
                           0
                           pp.width
                           pp.spacey)

  ;; bottom segment
  (love.graphics.rectangle "fill"
                           pp.x
                           (+ pp.spacey pp.spaceh)
                           pp.width
                           (- screen.height pp.spacey pp.spaceh)))

(fn love.draw []
  ;; backgroud
  (love.graphics.setColor .14 .36 .46)
  (love.graphics.rectangle "fill" 0 0 screen.width screen.height)

  ;; bird
  (love.graphics.setColor .87 .84 .27)
  (love.graphics.rectangle "fill" bird.x bird.y bird.width bird.height)

  (draw-pipe pipe1)
  (draw-pipe pipe2)

  ;; draw score
  (love.graphics.setColor 1 1 1)
  (love.graphics.print state.score 15 15))
