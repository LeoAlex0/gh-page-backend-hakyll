{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Site.GeoGebra
  ( geogebraReferenceTransform,
  )
where

import Data.Char (isAlphaNum)
import Data.List (isInfixOf, isPrefixOf, isSuffixOf)
import Data.Text qualified as T
import Hakyll (Identifier, replaceAll, toFilePath)
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
