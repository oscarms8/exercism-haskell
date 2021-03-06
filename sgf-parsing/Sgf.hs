module Sgf (parseSgf) where

import qualified Data.Map as Map
import Data.Text (Text, pack)
import Data.Tree
import Text.Parsec
import Data.Char (isSpace)

type SgfNode = Map.Map Text [Text]
type Parser a = Parsec Text () a

parseSgf :: Text -> Maybe (Tree (SgfNode))
parseSgf = toMaybe . parse tree ""
  where
    toMaybe = either (const Nothing) Just

tree :: Parser (Tree SgfNode)
tree = do
    text <- char '(' *> many1 node
    trees <- many tree <* char ')'
    return $ makeTree text trees

node :: Parser SgfNode
node = char ';' *> (Map.fromList <$> many properties)

properties :: Parser (Text, [Text])
properties = do
  key <- many1 upper
  vals <- many1 val
  return (pack key, vals)

val :: Parser Text
val = pack <$> (char '[' *> worker [] False)
  
worker :: String -> Bool -> Parser String
worker acc bs = do
    c <- anyChar
    case c of
        ']'  | not bs    -> return . reverse $ acc
        '\\' | not bs    -> worker acc True
        '\n' | bs        -> worker acc False
        _    | isSpace c -> worker (' ' : acc) False
        _                -> worker (c : acc) False

makeTree :: [SgfNode] -> [(Tree SgfNode)] -> Tree SgfNode
makeTree [] _ = error "Needs a root node"
makeTree [n] trees = Node n trees
makeTree (n:ns) trees = Node n [makeTree ns trees]
