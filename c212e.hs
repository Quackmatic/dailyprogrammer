import Control.Arrow
import Control.Monad
import Data.Bool
import Data.Char

isSwCon = flip elem "bcdfghjklmnpqrstvwxz" . toLower
encodeC = uncurry (:) . (id &&& ('o':) . (:[]) . toLower)
main = interact $ foldMap $ (join $ bool (:[]) encodeC . isSwCon)
