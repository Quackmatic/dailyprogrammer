import Data.Char
import Data.List
import Control.Monad

squareFactor :: Int -> Int
squareFactor x = let desc n   = n : desc (n - 1)
                     isqrt n  = ceiling $ sqrt $ fromIntegral x
                     fact n m = n `mod` m == 0
                     f1       = head $ filter (fact x) $ desc $ isqrt x
                 in  x `div` f1

splitS :: [a] -> Int -> [[a]] -> [[a]]
splitS [] _ acc     = reverse acc
splitS xs width acc = let (first, rest) = splitAt width xs
                          serpFunction  = [id, reverse] !! (length acc `mod` 2)
                      in  splitS rest width (serpFunction first : acc) 

main :: IO ()
main = do input    <- getLine
          sentence <- return $ filter isLetter input
          boxWidth <- return $ squareFactor $ length sentence
          putStrLn "0 0"
          foldr1 (>>) $ map putStrLn $ splitS sentence boxWidth []
