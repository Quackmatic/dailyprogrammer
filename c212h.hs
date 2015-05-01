import Control.Monad
import Data.Array
import Data.Char
import Data.Functor
import Data.List
import Data.Maybe
import Text.Printf

-- For storing the (steps of) the input path
data Step  = TurnL | TurnR | Move deriving Show
type Path  = [Step]

-- 2D array for the maze itself
type Maze  = Array Int (Array Int Bool)

-- State of the maze traversal - current direction facing is stored as an int
--
--     0
--     |
--   3-#-1
--     |
--     2
type State = (Int, Int, Int)

-- Converts a list to a zero-indexed array
toArr :: [a] -> Array Int a
toArr l = listArray (0, length l - 1) l

-- IO monad for reading a maze from stdin
readMaze :: Int -> IO Maze
readMaze height = toArr <$> (sequence $ replicate height $ toArr . map (== ' ') <$> getLine)

-- IO monad for reading a path from stdin
readPath :: IO Path
readPath = readPathR [] <$> getLine where
    readPathR acc []      = reverse acc
    readPathR acc ('l':p) = readPathR (TurnL : acc) p
    readPathR acc ('r':p) = readPathR (TurnR : acc) p
    readPathR acc p       = let (lenString, p') = span isDigit p
                                len = read lenString
                            in  readPathR (replicate len Move ++ acc) p'

-- Checks if the given state is valid for the given maze
valid :: State -> Maze -> Bool
valid (i, j, _) m = i >= il && i <= ih && j >= jl && j <= jh && m ! j ! i where
    ((il, ih), (jl, jh)) = (bounds $ m ! 0, bounds m)

-- Gets the next state from the current state and the next step in the path
nextStateU :: State -> Step -> State
nextStateU (i, j, d) TurnL = (i, j, (d + 3) `mod` 4)
nextStateU (i, j, d) TurnR = (i, j, (d + 1) `mod` 4)
nextStateU (i, j, d) Move  = (i + [0, 1, 0, -1] !! d,
                              j + [-1, 0, 1, 0] !! d, d)

-- Maybe monad which gets the next valid state from the current state and the next
-- step in the path, or Nothing if the next step would be invalid (out of bounds,
-- or inside a wall)
nextState :: (State, Maze) -> Step -> Maybe (State, Maze)
nextState (s, m) st = if valid s' m then Just (s', m) else Nothing
                         where s'@(i', j', d') = nextStateU s st

-- Checks if there is a valid point at the given location, pointing in any direction,
-- and returns the end-point(s) of that path
validPathAt :: Maze -> Path -> (Int, Int) -> [(Int, Int)]
validPathAt m p (i, j) =
    map (getEndPoint . fromJust) $ filter isJust $
    map (\o -> foldM nextState ((i, j, o), m) p) [0..3] where
        getEndPoint ((i, j, _), _) = (i, j)

-- Gets all locations in the given maze where the given path is valid, and returns
-- the start and end points of the corresponding path
validPath :: Maze -> Path -> [((Int, Int), (Int, Int))]
validPath m p = sortOn (\((i, j), (i', j')) -> i * 1000000 + j) $
                foldl (\l r -> (map ((,) r) $ validPathAt m p r) ++ l) [] $
                filter (\(i, j) -> valid (i, j, 0) m) $
                concat $ map (\j -> map (\i -> (i, j)) $ indices $ m ! j) $ indices m

main :: IO ()
main = do mazeSize  <- getLine
          maze      <- readMaze $ read mazeSize
          path      <- readPath
          let valids = validPath maze path
          sequence_ $ map (\((i, j), (i', j')) ->
              printf "From (%d, %d) to (%d, %d)\n" i j i' j') valids
