{-# LANGUAGE OverloadedStrings #-}

module Site.Routes
  ( dropDatePrefix,
    pageRoute,
    postAssetPattern,
    postAssetRoute,
    postPattern,
    primaryPostPattern,
    postRoute,
    postSlug,
    translatedPostPattern,
  )
where

import Data.Char (isDigit)
import Data.List (isPrefixOf, isSuffixOf)
import Hakyll
import Site.Config (defaultLang)
import System.FilePath (makeRelative, takeBaseName, takeDirectory, takeFileName, (</>))

postPattern :: Pattern
postPattern =
  primaryPostPattern .||. translatedPostPattern

primaryPostPattern :: Pattern
primaryPostPattern =
  ("posts/*/index.md" .||. "posts/*.md") .&&. complement translatedPostPattern

translatedPostPattern :: Pattern
translatedPostPattern =
  "posts/*/index.*.md" .||. "posts/*.*.md"

postAssetPattern :: Pattern
postAssetPattern =
  "posts/*/**" .&&. complement postPattern

postRoute :: Routes
postRoute =
  metadataRoute $ \metadata ->
    customRoute $ \identifier ->
      languagePrefix metadata ("post" </> postSlugWithMetadata metadata identifier <> ".html")

postAssetRoute :: Routes
postAssetRoute =
  customRoute $ \identifier ->
    let path = toFilePath identifier
        dir = takeDirectory path
        slug = dropDatePrefix (takeFileName dir)
        relativePath = makeRelative dir path
     in "post" </> slug </> relativePath

pageRoute :: Routes
pageRoute =
  metadataRoute $ \metadata ->
    customRoute $ \identifier ->
      languagePrefix metadata (pageSlug metadata identifier </> "index.html")

dropDatePrefix :: String -> String
dropDatePrefix slug
  | hasDatePrefix slug = drop 11 slug
  | otherwise = slug

hasDatePrefix :: String -> Bool
hasDatePrefix slug =
  length slug > 11
    && all isDigit (take 4 slug)
    && charAt 4 == '-'
    && all isDigit (take 2 (drop 5 slug))
    && charAt 7 == '-'
    && all isDigit (take 2 (drop 8 slug))
    && charAt 10 == '-'
  where
    charAt n = slug !! n

postSlug :: Identifier -> String
postSlug =
  postSlugWithLanguage Nothing

postSlugWithMetadata :: Metadata -> Identifier -> String
postSlugWithMetadata metadata =
  postSlugWithLanguage (lookupString "lang" metadata)

postSlugWithLanguage :: Maybe String -> Identifier -> String
postSlugWithLanguage lang identifier
  | isIndexPostFile fileName = dropDatePrefix (takeFileName (takeDirectory path))
  | otherwise = dropDatePrefix (dropLanguageSuffix lang (takeBaseName path))
  where
    path = toFilePath identifier
    fileName = takeFileName path

pageSlug :: Metadata -> Identifier -> String
pageSlug metadata =
  dropLanguageSuffix (lookupString "lang" metadata) . takeBaseName . toFilePath

isIndexPostFile :: FilePath -> Bool
isIndexPostFile fileName =
  fileName == "index.md"
    || ("index." `isPrefixOf` fileName && ".md" `isSuffixOf` fileName)

languagePrefix :: Metadata -> FilePath -> FilePath
languagePrefix metadata path =
  case lookupString "lang" metadata of
    Just lang
      | not (null lang) && lang /= defaultLang -> lang </> path
    _ -> path

dropLanguageSuffix :: Maybe String -> String -> String
dropLanguageSuffix Nothing slug = slug
dropLanguageSuffix (Just lang) slug
  | suffix `isSuffixOf` slug = take (length slug - length suffix) slug
  | otherwise = slug
  where
    suffix = "." <> lang
