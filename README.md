Snake in Elm
============


A simple snake game implemented in [Elm](http://elm-lang.org/), a programming language designed for functional reactive programming.  

You can try the game **[HERE!](http://elmsnake.herokuapp.com/)**  
or just copy everything in **snake.elm** into the [Try Elm, online editor](http://elm-lang.org/try) to play around with the code.  

![image:elm snake in action](http://i.imgur.com/zyCFL7H.png "look at him go!")

Making a game in Elm
--------------------
Designing games are quite simple in Elm and don't even require that many lines of code. Mostly everything needed to put together any game can be divided into three specific groups: **Models**, **Step functions** and **Display function**.  

The **models** contain information regarding the different elements of the game; i.e. their attributes and initial values.   
The **step functions** describe how the attributes of the game elements evolve from one step to another. Given the current model, a step function will return a new updated version of the model.  
Finally, the **display function** is what draws everything onto the screen. Given the models of the different elements in the game, the display function will draw them onto the specified area based on their attributes and current values.  


The game is then run by calling the **display function**, and feeding it the different versions of the **models** by iteratively calling the **step functions** on them for each frame. If there are any keyboard or mouse inputs for the game, these are also registered during each frame and can by read by the step functions that require them.  

Making snake.elm
----------------
I divided this game into 3 game elements: The snake, the snake-food and the game itself. For each of the elements I have a model and a step function.  
My model of the snake contains attributes such as its current position and number of body parts. The stepSnake function creates a *new snake* based on the *previous snake* and possible keyboard events. The display function contains code for drawing the snake and its body parts as white squares onto the screen using the attributes of the snake model.

The same things are done for the other game elements, such as the snake-food. The real magic happens on the last line:
```elm
main = display <~ Window.dimensions ~ (foldp stepGame defaultGame input)
```
Here I am calling the display function with two arguments: The window dimensions, and the result of folding stepGame over the input model (which contains the keyboard inputs as well as the fps). These two arguments are dynamic values (called signals in eml), and whenever one of them changes, the body of the display function will be evaluated again based on the new values.  
The stepGame function calls all the other step functions for each frame and returns a new game model, containing new models of all the other elements in the game. This leads to the body of the display function being evaluated again with the values of the new models, and we have a loop.
