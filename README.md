Snake in Elm
============


A simple snake game implemented in [Elm](http://elm-lang.org/), a programming language designed for functional reactive programming.  

You can copy the code in **snake.elm** into the [Try Elm, online editor](http://elm-lang.org/try) to test it out.  


Making a game in Elm
--------------------
Designing games are quite simple in Elm. The code needed to put together any game can be divided into three specific groups: **Models**, **Step functions** and **Display function**.  
The **models** contain information of the different elements in the game; i.e. their attributes and initial values. The **step functions** describe how the attributes of the game elements evolve from one step to another, so given the current model, a step function will return a new updated version of the model. Finally, the **display function** is what draws everything onto the screen. Given the models of the different elements in the game, the display function will draw them onto the specified area based on their attributes and current values.  
The game is then run by calling the display function, and feeding it the different versions of the models by iteratively calling the step functions on them for each frame. If there are any keyboard or mouse inputs for the game, these are also registered during each frame and can by read by the step functions that require them.  

Making snake.elm
----------------
In this game there are 3 game elements: The snake, the snake-food and the game itself. For each of the elements I have a model and a step function.  
My model of the snake contains its current position, velocity (which is basically the same as direction in this case), length, and the positions of each of its *body parts*.  
The stepSnake function creates a *new snake* based on the old one and possible keyboard events: The velocity will have a new value if a valid arrow key was pressed, and the head and body parts will have new positions based on the attributes of the *old snake*.  
The display function contains code for drawing the snake and its body parts as white squares on the screen using the *position* and *body* attributes of the snake model of the snake model.  
The same things are done for the other game elements such as snake-food and points. The real magic happens on the last line:
```elm
main = display <~ Window.dimensions ~ (foldp stepGame defaultGame input)
```
Here we are calling the display function, giving it the window dimensions, and the result of folding stepGame over the input model (which contains the keyboard inputs as well as the fps). These two arguments are dynamic values (called signals in eml), and whenever one of them changes, the body of the display function will be evaluated again with the new values.  
The stepGame function calls all the other step functions for each frame and returns a new game model, containing new models of all the other elements in the game. This leads to the body of the display function being evaluated again with the values of the new model, and we have a loop.