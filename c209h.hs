import Control.Monad
import Data.Array
import Data.Char
import Data.List
import Data.Ord
import System.Environment
import System.IO

type GridLine = Array Int Char
type Grid = Array Int GridLine

-- Sentence data structure
data Sentence = Total [String]
              | Partial [String] String
              | Invalid deriving (Eq)

-- This is so we can print sentences
instance Show Sentence where
    show (Total w)     = map toUpper $ unwords $ w
    show (Partial w t) = (map toUpper $ unwords $ w) ++ " " ++ t ++ "?"
    show (Invalid)     = "Invalid"

-- Strip non-alphabetic characters, and put into lower case
sanitise :: String -> String
sanitise = (map toLower) . (filter isLetter)

-- Reads the first line of input. Discards first number because we do not
-- need it. Reads 2nd and 3rd numbers as starting point co-ordinates
getStart :: String -> (Int, Int)
getStart s = (s' !! 1, s' !! 2) where s' = map read $ words s

-- Converts a list into a 1-indexed array
getGridArray :: [a] -> Array Int a
getGridArray xs = listArray (1, length xs) xs

-- Gets the boundaries (Width, Height) of a 2-D array
getGridBound :: Grid -> (Int, Int)
getGridBound g = let (y1, y2) = bounds g
                     (x1, x2) = bounds (g ! y1)
                 in  (x2, y2)

-- Resolves a sentence into a list of possible combinations of words or
-- partial words by a nasty definitely-not-polynomial algorithm
resolve :: [String] -> String -> [Sentence]
resolve wl s = resolveR (sanitise s) [] where
    resolveR [] acc = [Total (reverse acc)]
    resolveR  s acc = let ws = sortBy (comparing $ negate . length) $ filter (`isPrefixOf` s) wl
                      in  if null ws
                              then let partials = filter (isPrefixOf s) wl
                                   in  if null partials
                                           then []
                                       else [Partial (reverse acc) $ head partials]
                              else foldr1 (++) $ map (\w -> resolveR (s \\ w) (w : acc)) ws

-- Unpacks a string by recursively traversing the grid on every possible
-- Hamiltonian path, and only stopping when the resulting sentence is not
-- valid (cannot be resolved). Hence, this is O(4^n) in the worst case
unpack :: [String] -> Grid -> (Int, Int) -> Sentence
unpack wl g s = unpackR [] [] s where
    (w, h) = getGridBound g
    unpackR s v (x, y)
        | x < 1 || y < 1 || x > w || y > h = Invalid
        | (x, y) `elem` v = Invalid
        | otherwise
            = let s' = s ++ [g ! y ! x]
                  rs = resolve wl s'
              in  if null rs
                      then Invalid
                      else let v' = (x, y) : v
                               vn = [(x-1, y), (x+1, y), (x, y-1), (x, y+1)]
                           in  if length v' == w * h
                                   then head rs
                               else
                                   case filter ((/=) Invalid) $
                                        map (unpackR s' v') vn  of
                                       Invalid -> Invalid
                                       (s:_)   -> s

-- Handles I/O - can you tell that I just found out about fmap and monads?
main :: IO ()
main = do args  <- getArgs
          words <- fmap (map sanitise . lines) $ readFile $ head args
          start <- fmap getStart $ getLine
          grid  <- fmap (getGridArray . map (getGridArray . sanitise) . lines) getContents
          putStrLn $ show $ unpack words grid start