import Data.Char
import Data.List
import Data.Maybe
import qualified Data.Map.Strict as Dm

type Symbol = Char
type Alphabet = [Symbol]
type State = String
type Tape = Dm.Map Int Symbol

type Rule = (State, Symbol, State, Symbol, Int -> Int)
type Machine = (Alphabet, [State], State, State, Tape, Int, [Rule])

splitStr :: (Char -> Bool) -> String -> (String, String)
splitStr d s = let (first, rest) = break     d s
                   second        = dropWhile d rest
               in  (first, second)

readRule :: String -> Maybe Rule
readRule s0 = let actionOf "<" = \a -> a - 1
                  actionOf ">" = \a -> a + 1
                  (state, s1)  = splitStr isSpace s0
                  (sym:_, s2)  = splitStr isSpace s1
                  (arrow, s3)  = splitStr isSpace s2
                  (state', s4)  = splitStr isSpace s3
                  (sym':_, s5) = splitStr isSpace s4
                  (action, _) = splitStr isSpace s5
              in  if arrow == "="
                      then Just (state, sym, state', sym', actionOf action)
                      else Nothing

readStates :: String -> Maybe [State]
readStates s = readStatesR s [] where
    readStatesR [] a = Just $ reverse a
    readStatesR s a  = let (state, states) = splitStr isSpace s
                       in  readStatesR states (state : a)

readMachine :: [String] -> Maybe Machine
readMachine (alphabet':s:si:sf:t:r) = do
    let alphabet = '_':alphabet'
    states <- readStates s
    if all (`elem` states) [si, sf] then
        let rules = map readRule $ r
        in  if all isJust rules then
                return $ (alphabet,
                          states, si, sf, 
                          Dm.fromList $ zip [0 ..] t, 0,
                          map fromJust rules)
            else
                fail "Bad rule set"
    else
        fail "Unknown states"

stepMachine :: Machine -> Maybe Machine
stepMachine m@(a, states, si, sf, tape, pos, rules)
    | si == sf  = Just m
    | otherwise = let sym  = Dm.findWithDefault '_' pos tape
                  in  case find (\(st, s, _, _, _) -> si == st && s == sym) rules of
                        Just (_, _, st', s', act) -> stepMachine (a, states, st', sf, Dm.insert pos s' tape, act pos, rules)
                        Nothing                   -> Nothing -- no rule found

printTape :: Tape -> Int -> IO ()
printTape tape fi = let indices       = Dm.keys tape
                        (min, max)    = (minimum indices, maximum indices)
                        tagInd 0      = '|'
                        tagInd i
                          | i == fi   = '^'
                          | otherwise = ' '
                    in  do putStrLn $ map (\i -> Dm.findWithDefault '_' i tape) [min..max]
                           putStrLn $ map tagInd [min..max]

main :: IO ()
main = do
   contents <- getContents
   let input = filter (not . null) $ lines contents
   case readMachine input of
       Just m -> case stepMachine m of
                     Just (a, states, si, sf, tape, pos, rules) -> printTape tape pos
                     Nothing                                    -> putStrLn "Badly defined machine."
       Nothing -> putStrLn "Badly initialized machine."
