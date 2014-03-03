import Window
import Keyboard


grid             = 10
pointsReward     = 10
pointsNormalizer = 14

(width, height)   = (600, 400)
(iWidth, iHeight) = (width - grid, height - grid)
(hWidth, hHeight) = (width / 2, height / 2)


-- Input

delta = inSeconds <~ fps 20
type Input = { space:Bool, arrowX:Int, arrowY:Int, delta:Time }
input = sampleOn delta (Input <~ Keyboard.space
                               ~ lift .x Keyboard.arrows
                               ~ lift .y Keyboard.arrows
                               ~ delta)




-- Models

data State = Play | Over
type Vec   = (Float, Float)
type Game  = { snake: Snake, food: Food, points: Int, state: State }
type Snake = { pos: Vec, vel:Vec, length: Int, body: [Vec]}
type Food  = { pos: Vec, color: Color, colors: [Color] }

defaultGame  = { snake  = defaultSnake,
                 food   = defaultFood,
                 points = 0,
                 state  = Over }

defaultSnake = { pos    = ((2 * grid - hWidth), 0),
                 vel    = (grid, 0),
                 length = 10,
                 body   = [] }

defaultFood = { pos    = (0,0),
                color  = green,
                colors = [green, lightBlue, yellow, lightRed, lightPurple, lightBrown]}




-- Step functions

stepGame : Input -> Game -> Game
stepGame input g =
  let snakeEatsFood = vecEqual g.food.pos g.snake.pos

  in  if g.state == Play
      then { g | snake  <- stepSnake input g.snake snakeEatsFood,
                 food   <- stepFood g.snake.body g.food snakeEatsFood,
                 points <- if snakeEatsFood then g.points + (pointsReward * g.snake.length)
                                            else g.points - ceiling (toFloat g.snake.length / pointsNormalizer),
                 state  <- if | abs (fst g.snake.pos) > hWidth - grid   -> Over
                              | abs (snd g.snake.pos) > hHeight - grid  -> Over
                              | any (vecEqual g.snake.pos) g.snake.body -> Over
                              | otherwise                               -> Play
           }
      else if input.space then { defaultGame | state <- Play } else g
  
stepSnake : Input -> Snake -> Bool -> Snake
stepSnake {arrowX, arrowY} s ateFood = 
  {s | vel    <- if | arrowX /= 0 && (fst s.vel) == 0 -> (toFloat (arrowX * grid), 0)
                    | arrowY /= 0 && (snd s.vel) == 0 -> (0, toFloat (arrowY * grid))
                    | otherwise                       -> s.vel,
       pos    <- vecAdd s.pos s.vel,
       length <- s.length + (if ateFood then 10 else 0),
       body   <- s.pos :: (if length s.body >= s.length then take (s.length - 1) s.body else s.body)
  }

stepFood : [Vec] -> Food -> Bool -> Food
stepFood body f eaten =
  if eaten 
  then { f | pos    <- last body,
             color  <- last f.colors,
             colors <- (last f.colors) :: take ((length f.colors)-1 ) f.colors
       }
  else f

vecAdd : Vec -> Vec -> Vec
vecAdd (ax, ay) (bx, by) = (ax + bx, ay + by)

vecEqual : Vec -> Vec -> Bool
vecEqual (ax, ay) (bx, by) = floor (ax - bx) == 0 && floor (ay - by) == 0




-- Display

display : (Int, Int) -> Game -> Element
display (w, h) game = 
  let drawBackground = rect width height |> filled black
      drawBorders    = rect (iWidth) (iHeight) |> outlined borderLine
      drawSnake pos  = square grid |> filled (if game.state == Over then black else white) |> move pos
      drawFood       = square grid |> filled (if game.state == Over then black else game.food.color) |> move game.food.pos
      drawScoreTxt   = scoreTxt game |> bluTxt (Text.height 30) |> toForm |> move (0, hHeight - 30)
      drawDeathTxt   = deathTxt game |> redTxt (Text.height 50) |> toForm |> move (0, 10)
      drawAgainTxt   = againTxt game |> whtTxt (Text.height 20) |> toForm |> move (0, 0 - 30)
  in  color charcoal <| container w h middle
                     <| collage width height (drawBackground
                                              :: drawSnake game.snake.pos
                                              :: map drawSnake game.snake.body
                                              ++ [drawFood,
                                                  drawBorders,
                                                  drawScoreTxt,
                                                  drawDeathTxt,
                                                  drawAgainTxt])

scoreTxt g = show g.points ++ " points"
deathTxt g = (if g.state == Over && g.points /= 0 then  "Game over" else "")
againTxt g = (if g.state == Over then "Hit space to start a new game." else "")

bluTxt   f = text . f . monospace . Text.color blue . toText
whtTxt   f = text . f . italic . Text.color white . toText
redTxt   f = text . f . bold . Text.color darkRed . toText
borderLine = { defaultLine | width <- grid,
                             color <- lightGray }



main = display <~ Window.dimensions ~ (foldp stepGame defaultGame input)
