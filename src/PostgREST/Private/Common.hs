{-|
Module      : PostgREST.Common
Description : Common helper functions.
-}
module PostgREST.Private.Common where

import           Data.Maybe
import qualified Hasql.Decoders                  as HD
import qualified Hasql.DynamicStatements.Snippet as H
import qualified Hasql.Encoders                  as HE
import           Protolude

import Data.Foldable (foldr1)

column :: HD.Value a -> HD.Row a
column = HD.column . HD.nonNullable

nullableColumn :: HD.Value a -> HD.Row (Maybe a)
nullableColumn = HD.column . HD.nullable

arrayColumn :: HD.Value a -> HD.Row [a]
arrayColumn = column . HD.array . HD.dimension replicateM . HD.element . HD.nonNullable

param :: HE.Value a -> HE.Params a
param = HE.param . HE.nonNullable

arrayParam :: HE.Value a -> HE.Params [a]
arrayParam = param . HE.array . HE.dimension foldl' . HE.element . HE.nonNullable

emptySnippetOnFalse :: H.Snippet -> Bool -> H.Snippet
emptySnippetOnFalse val cond = if cond then mempty else val

intercalateSnippet :: ByteString -> [H.Snippet] -> H.Snippet
intercalateSnippet _ [] = mempty
intercalateSnippet frag snippets = foldr1 (\a b -> a <> H.sql frag <> b) snippets
