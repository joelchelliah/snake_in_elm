elm snake.elm --make --build-dir=build --runtime=./elm-runtime.js
cp $HASKELL_HOME/ghc-7.6.3/lib/Elm-0.11/share/elm-runtime.js ./elm-runtime.js
mv ./build/snake.html ./home.html