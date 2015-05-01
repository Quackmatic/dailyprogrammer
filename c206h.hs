import Data.Maybe
import Data.List
import Data.Char

-- AST structure for successors
data Successor = Literal Double
               | Previous Int
               | Binary (Double -> Double -> Double) Successor Successor
               | Unary (Double -> Double) Successor

-- Already-known terms of a series (for example, the 1 1 at the start of the
-- Fibonacci sequence) are stored as Terms. A list of Terms is a Series
type Term = (Int, Double)
type Series = [Term]

-- Gets the i-th term of the given series, or Nothing if it's not yet known
getTerm :: Series -> Int -> Maybe Double
getTerm series i = lookup i series

-- Evaluates i-th term of the given series with the given successor - this
-- may need to know previous values in the series
evalSucc :: Series -> Int -> Successor -> Double
evalSucc series i (Previous j) = fromJust $ getTerm series (i - j)
evalSucc series i (Binary f l r) = (evalSucc series i l) `f` (evalSucc series i r)
evalSucc series i (Literal x) = x

-- Gets the required previous values of the given successor. The Fibonacci
-- successor would return [-1, -2] as it requires the (i-1)th and (i-2)th
-- terms in order to determine the i-th term
getReq :: Successor -> [Int]
getReq (Previous i) = [-i]
getReq (Binary _ l r) = getReq l `union` getReq r
getReq (Literal _) = []

-- Determines if the i-th term is defined, using only the already-known terms
-- in the given series
isDefinedAt :: Series -> [Int] -> Int -> Bool
isDefinedAt series req i = all (\j -> isJust $ getTerm series (i + j)) req 

-- Gets all the term indices that can be defined with the information that we
-- know already; that is, already-known terms and the successor rule we have
getDefinedIndices :: Series -> [Int] -> [Int]
getDefinedIndices series req =
    let order        = -(minimum req)
        knownIndices = map ((+)order . fst) series
    in  filter (isDefinedAt series req) knownIndices

-- Gets an infinite list of Terms representing the series defined with the
-- initial values given and the successor term
getSeries :: Series -> Successor -> Series
getSeries initial succ =
    initial ++ (getSeriesR initial) where
        req            = getReq succ
        -- Recursive function for getting the next terms in the series. Acc, the
        -- accumulator, stores all terms in the series that are already known.
        getSeriesR acc =
            let newTerms = map (\i -> (i, evalSucc acc i succ))
                         $ dropWhile (\i -> isJust $ find ((==) i . fst) acc)
                         $ getDefinedIndices acc req
            in  if null newTerms
                    then []
                    else newTerms ++ (getSeriesR (acc ++ newTerms))

-- Parses a successor in postfix notation
parseSuccessor :: [Char] -> Either [Char] Successor
parseSuccessor s = parseSuccessorR s [] where
    validOps                  = "+-*/^" `zip` [(+), (-), (*), (/), (\ b p -> exp $ p * (log b))]
    validRealChars            = "0123456789.eE+-"
    parseSuccessorR [] []     = Left $ "Nothing on stack after parsing."
    parseSuccessorR [] [succ] = Right succ
    parseSuccessorR [] stk    = Left $ (show $ length stk) ++ " too many things on stack after parsing."
    parseSuccessorR (c:s) stk
        | c == ' '            = parseSuccessorR s stk
        | c == '('            = let (index, s') = break ((==) ')') s
                                in  parseSuccessorR (tail s') $ (Previous $ read index):stk
        | c `elem` (map fst validOps) 
                              = case stk of 
                                    r:l:stk' -> parseSuccessorR s $ (Binary (fromJust $ lookup c validOps) l r):stk'
                                    _        -> Left $ "Not enougn operands for " ++ [c] ++ "."
        | isDigit c           = let (value, s') = span (\ c' -> c' `elem` validRealChars) (c:s)
                                in  parseSuccessorR s' $ (Literal $ read value):stk
        | otherwise           = Left $ "Unknown character " ++ [c] ++ "."

-- Parses a term from a line
parseTerm :: [Char] -> Term
parseTerm s = let (index, s') = break ((==) ':') s
                  value = tail s'
              in  (read index, read value)

-- Splits l on any occurrence of delims, ignoring empty sub-lists
splitOneOf :: [Char] -> [Char] -> [[Char]]
splitOneOf delims l = splitOneOfR delims l [] [] where
    adjoin cs parts                = if null cs then parts else (reverse cs):parts
    splitOneOfR delims [] cs parts = reverse $ adjoin cs parts
    splitOneOfR delims (c:s) cs parts
        | c `elem` delims          = splitOneOfR delims s [] $ adjoin cs parts
        | otherwise                = splitOneOfR delims s (c:cs) parts

main = do content <- getContents
          let (succInput:rest)    = splitOneOf "\r\n" content
          let (termsInput, count) = (init rest, read $ last rest)              
              (terms, succParsed) = (sortBy (\a b -> fst a `compare` fst b)
                                  $ map parseTerm termsInput, parseSuccessor succInput)
          case succParsed of
              Left err   -> putStrLn $ "In successor: " ++ err
              Right succ -> putStrLn
                          $ intercalate "\n"
                          $ map (\ (i, x) -> (show i) ++ ": " ++ (show x))
                          $ takeWhile (\t -> fst t <= count)
                          $ getSeries terms succ
