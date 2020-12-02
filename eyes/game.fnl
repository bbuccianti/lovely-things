(local fennel (require "lib.fennel"))

(fn draw-eye [eyeX eyeY]
  (let [distanceX (- (love.mouse.getX) eyeX)
        distanceY (- (love.mouse.getY) eyeY)
        distance (math.min (math.sqrt (+ (^ distanceX 2)
                                         (^ distanceY 2)))
                           30)
        angle (math.atan2 distanceY distanceX)
        pupilX (+ eyeX (* (math.cos angle) distance))
        pupilY (+ eyeY (* (math.sin angle) distance))]
    (love.graphics.setColor 1 1 1)
    (love.graphics.circle "fill" eyeX eyeY 50)

    (love.graphics.setColor 0 0 .4)
    (love.graphics.circle "fill" pupilX pupilY 15)))

(fn love.draw []
  (draw-eye 200 200)
  (draw-eye 330 200))
