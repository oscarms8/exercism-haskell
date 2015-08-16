module Matrix (saddlePoints) where

import Data.Array

type Point a = (a, a)

saddlePoints :: Array (Point Int) Int -> [Point Int]
saddlePoints matrix = 
  let
    ((minRow, minCol), (maxRow, maxCol)) = bounds matrix
    maxRows = [ maximum [ matrix ! (x, y)
      | y <- [minCol .. maxCol] ]
      | x <- [minRow .. maxRow] ]
    minCols = [ minimum [ matrix ! (x, y) 
      | x <- [minRow .. maxRow] ] 
      | y <- [minCol .. maxCol] ]
    findPoints (p@(r,c), v) acc = 
        if maxRows !! r == v && minCols !! c == v
          then p:acc
          else acc
  in 
    foldr findPoints [] $ assocs matrix
