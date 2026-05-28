{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Site.GeoGebra
  ( geogebraReferenceTransform,
    geogebraAssetCompiler,
  )
where

import Data.Aeson (Value (..), decode, encode)
import Data.Aeson.Key qualified as Key
import Data.Aeson.KeyMap qualified as KM
import Data.ByteString.Lazy.Char8 qualified as BL8
import Data.Char (isAlphaNum)
import Data.List (isInfixOf, isPrefixOf, isSuffixOf)
import Data.Maybe (mapMaybe)
import Data.Scientific (Scientific, toRealFloat)
import Data.Text qualified as T
import Data.Vector qualified as V
import Hakyll (Compiler, Identifier, Item, getResourceBody, itemBody, itemSetBody, replaceAll, toFilePath)
import Site.Routes (postSlug)
import System.FilePath (takeBaseName, (</>))
import Text.Pandoc qualified as Pandoc
import Text.Pandoc.Shared (stringify)
import Text.Pandoc.Walk (walk)
import Text.RawString.QQ (r)

data GeoGebraEmbed = GeoGebraEmbed
  { embedId :: String,
    embedSource :: String,
    embedCaption :: String
  }

geogebraReferenceTransform :: Identifier -> Pandoc.Pandoc -> Pandoc.Pandoc
geogebraReferenceTransform identifier =
  walk (geogebraBlockTransform identifier)

geogebraBlockTransform :: Identifier -> Pandoc.Block -> Pandoc.Block
geogebraBlockTransform identifier (Pandoc.Para [Pandoc.Link _ caption (target, _)])
  | isGeoGebraTarget target = geogebraFigureBlock identifier caption target
geogebraBlockTransform identifier (Pandoc.Plain [Pandoc.Link _ caption (target, _)])
  | isGeoGebraTarget target = geogebraFigureBlock identifier caption target
geogebraBlockTransform _ block = block

isGeoGebraTarget :: T.Text -> Bool
isGeoGebraTarget =
  isSuffixOf ".geogebra" . T.unpack

geogebraFigureBlock :: Identifier -> [Pandoc.Inline] -> T.Text -> Pandoc.Block
geogebraFigureBlock identifier caption target =
  Pandoc.RawBlock (Pandoc.Format "html") . T.pack $ renderGeoGebraFigure embed
  where
    source = T.unpack target
    embed =
      GeoGebraEmbed
        { embedId = "geogebra-" <> sanitizeId (takeBaseName source),
          embedSource = geogebraSourceUrl identifier source,
          embedCaption = T.unpack (stringify caption)
        }

renderGeoGebraFigure :: GeoGebraEmbed -> String
renderGeoGebraFigure embed =
  replace "{{id}}" (escapeHtmlText (embedId embed)) $
    replace "{{source}}" (escapeHtmlText (embedSource embed)) $
      replace "{{figcaption}}" (renderFigcaption (embedCaption embed)) geoGebraFigureTemplate

geoGebraFigureTemplate :: String
geoGebraFigureTemplate =
  [r|<figure class="geogebra-panel">
  <div id="{{id}}" class="geogebra-applet" data-geogebra data-source="{{source}}"></div>
{{figcaption}}</figure>|]

renderFigcaption :: String -> String
renderFigcaption caption
  | null caption = ""
  | otherwise = "  <figcaption>" <> escapeHtmlText caption <> "</figcaption>\n"

replace :: String -> String -> String -> String
replace needle value =
  replaceAll needle (const value)

geogebraSourceUrl :: Identifier -> String -> String
geogebraSourceUrl identifier source
  | "/" `isPrefixOf` source = source
  | "://" `isInfixOf` source = source
  | "posts/" `isPrefixOf` path = "/" <> ("post" </> postSlug identifier </> source)
  | "pages/" `isPrefixOf` path = "/" <> (takeBaseName path </> source)
  | otherwise = source
  where
    path = toFilePath identifier

sanitizeId :: String -> String
sanitizeId =
  map sanitizeChar
  where
    sanitizeChar char
      | isAlphaNum char = char
      | char == '-' = char
      | char == '_' = char
      | otherwise = '-'

escapeHtmlText :: String -> String
escapeHtmlText =
  concatMap escapeChar
  where
    escapeChar char =
      case char of
        '&' -> "&amp;"
        '<' -> "&lt;"
        '>' -> "&gt;"
        '"' -> "&quot;"
        '\'' -> "&#39;"
        _ -> [char]

----------------------------------------------------------------------
-- | Compile-time preprocessing of .geogebra files
----------------------------------------------------------------------

-- | Compiler for .geogebra asset files.
-- Parses JSON, serializes any structured command objects to GeoGebra
-- command strings, and writes the result.  This keeps the runtime JS
-- simple – it only ever sees flat command strings.
geogebraAssetCompiler :: Compiler (Item String)
geogebraAssetCompiler = do
  item <- getResourceBody
  let raw = itemBody item
  case decode (BL8.pack raw) of
    Nothing -> return item                -- invalid JSON: pass through unchanged
    Just val -> do
      let processed = serializeCommands val
      return $ itemSetBody (BL8.unpack (encode processed)) item

-- | Recursively walk the JSON tree.  When a \"commands\" key is
-- encountered, transform each item: plain strings stay as-is, and
-- structured objects are serialized to GeoGebra command strings.
serializeCommands :: Value -> Value
serializeCommands (Object obj) =
  Object $ KM.mapWithKey go obj
  where
    go :: Key.Key -> Value -> Value
    go k (Array cmds)
      | Key.toText k == "commands" = Array (V.map serializeCmdItem cmds)
    go _ v = serializeCommands v
serializeCommands (Array arr) =
  Array (V.map serializeCommands arr)
serializeCommands v = v

-- | Serialize a single command item.
-- Strings pass through unchanged; objects are converted to command strings.
serializeCmdItem :: Value -> Value
serializeCmdItem s@(String _) = s
serializeCmdItem obj@(Object _) = String (cmdObjToText obj)
serializeCmdItem v = v

-- | Convert a structured command object to a GeoGebra command string.
--
-- Format: @{\"type\": \"CmdName\", prop1: ..., prop2: ...}@
--
-- Special cases:
--   * @{\"type\":\"=\", \"var\":..., \"expr\":...}@  →  @var=expr@
--   * @{\"type\":\"Point\", \"x\":..., \"y\":...}@   →  @Point({x,y})@
--   * @{\"type\":\"Point\", \"on\":...}@             →  @Point(on)@
--   * @{\"type\":\"Polygon\", \"vertices\":[...]}@   →  @Polygon(v1,v2,...)@
cmdObjToText :: Value -> T.Text
cmdObjToText (Object obj) = case KM.lookup "type" obj of
  Just (String name)
    | name == "=" ->
        case (KM.lookup "var" obj, KM.lookup "expr" obj) of
          (Just (String var), Just expr) -> var <> "=" <> exprToText expr
          _ -> ""
    | name == "Point" ->
        case (KM.lookup "x" obj, KM.lookup "y" obj, KM.lookup "z" obj, KM.lookup "on" obj) of
          (Just (Number x), Just (Number y), Just (Number z), _) ->
            "Point({" <> showNum x <> "," <> showNum y <> "," <> showNum z <> "})"
          (Just (Number x), Just (Number y), _, _) ->
            "Point({" <> showNum x <> "," <> showNum y <> "})"
          (_, _, _, Just (String on)) -> "Point(" <> on <> ")"
          (_, _, _, Just on) -> "Point(" <> exprToText on <> ")"
          _ -> ""
    | name == "Polygon" ->
        case KM.lookup "vertices" obj of
          Just (Array verts) ->
            "Polygon(" <> T.intercalate "," (map exprToText (V.toList verts)) <> ")"
          _ -> ""
    | otherwise ->
        let argKeys = cmdArgOrder name
            args = mapMaybe (\k -> KM.lookup (Key.fromText k) obj) argKeys
        in if null args
             then name
             else name <> "(" <> T.intercalate "," (map exprToText args) <> ")"
  _ -> ""
cmdObjToText _ = ""

-- | Argument property names in GeoGebra positional order for each command.
cmdArgOrder :: T.Text -> [T.Text]
cmdArgOrder name = case name of
  "Circle"    -> ["center", "radius"]
  "Segment"   -> ["from", "to"]
  "Ellipse"   -> ["focus1", "focus2", "sum"]
  "Line"      -> ["p1", "p2"]
  "Intersect" -> ["a", "b"]
  "Curve"     -> ["exprX", "exprY", "exprZ", "var", "start", "end"]
  "Surface"   -> ["exprX", "exprY", "exprZ", "var1", "start1", "end1", "var2", "start2", "end2"]
  "Sequence"  -> ["expr", "var", "start", "end"]
  _           -> []

-- | Serialize an expression argument.
exprToText :: Value -> T.Text
exprToText (Number n) = showNum n
exprToText (String s) = s
exprToText obj@(Object _) = cmdObjToText obj
exprToText v = T.pack (show v)

-- | Format a Scientific number without unnecessary trailing zeros.
showNum :: Scientific -> T.Text
showNum n = T.pack $ show (toRealFloat n :: Double)
