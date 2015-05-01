import Control.Monad
import System.Random

score :: [Int] -> Int
score []         = 0
score (_:[])     = 0
score (x1:x2:xs) = scoreR (x2:xs) x1 (score2 x1 x2) where
    score3 a b c
        | b < a && b < c = -1
        | b > a && b > c = 1
        | otherwise      = 0
    score2 a b
        | a < b     = -1
        | a > b     = 1
        | otherwise = 0
    scoreR (xf:[]) x s    = s + score2 xf x
    scoreR (x1:x2:xs) x s = scoreR (x2:xs) x1 $ s + score3 x x1 x2

combinations :: [a] -> [[a]]
combinations l = let nth [map [0..length l]

optimalArrangement :: [Int] -> String
optimalArrangement a = show $ score a

main = interact (optimalArrangement . map (read) . words)
