{-# LANGUAGE OverloadedStrings #-}

module Site.Context
  ( feedCtx,
    pageCtx,
    postCtx,
    siteCtx,
  )
where

import Data.List qualified as List
import Data.Maybe (fromMaybe)
import Hakyll
import Site.Config
import Site.Routes (dropDatePrefix)
import System.FilePath (takeBaseName, takeDirectory, takeFileName, (</>))

data Translation = Translation
  { translationLang :: String,
    translationTitle :: String,
    translationBody :: String
  }

feedCtx :: Context String
feedCtx =
  titleCtx
    <> dateField "date" "%Y-%m-%d"
    <> siteCtx
    <> bodyField "description"

siteCtx :: Context String
siteCtx =
  constField "root" siteRoot
    <> constField "feedTitle" feedTitleText
    <> constField "siteName" siteName
    <> constField "giscusRepo" giscusRepo
    <> constField "giscusRepoID" giscusRepoID
    <> constField "giscusCategory" giscusCategory
    <> constField "giscusCategoryID" giscusCategoryID
    <> constField "giscusMapping" giscusMapping
    <> constField "giscusStrict" giscusStrict
    <> constField "giscusReactionsEnabled" giscusReactionsEnabled
    <> constField "giscusEmitMetadata" giscusEmitMetadata
    <> constField "giscusInputPosition" giscusInputPosition
    <> giscusTermField
    <> metadataOrDefaultField "lang" defaultLang
    <> metadataOrDefaultField "desc" feedDescriptionText
    <> metadataOrDefaultField "author" feedAuthorNameText
    <> defaultContext

pageCtx :: Context String
pageCtx =
  dateField "date" "%Y-%m-%d"
    <> languageTitlesField
    <> languageSectionsField "post-content"
    <> siteCtx

postCtx :: Tags -> Tags -> Context String
postCtx tags categories =
  tagsField "tags" tags
    <> metadataTagsField "categories" "categories" categories
    <> dateField "date" "%Y-%m-%d"
    <> languageTitlesField
    <> languageSectionsField "post-content"
    <> siteCtx

metadataTagsField :: String -> String -> Tags -> Context a
metadataTagsField fieldName metadataName =
  tagsFieldWith
    (getTagsByField metadataName)
    simpleRenderLink
    (mconcat . List.intersperse ", ")
    fieldName

metadataOrDefaultField :: String -> String -> Context a
metadataOrDefaultField key fallback =
  field key $ \item ->
    fromMaybe fallback . lookupString key <$> getMetadata (itemIdentifier item)

giscusTermField :: Context a
giscusTermField =
  field "giscusTerm" $
    return . giscusTerm . itemIdentifier

giscusTerm :: Identifier -> String
giscusTerm identifier
  | "posts/" `List.isPrefixOf` path = "post:" <> postTerm path
  | "pages/" `List.isPrefixOf` path = "page:" <> stripLanguageSuffix (takeBaseName path)
  | otherwise = path
  where
    path = toFilePath identifier

postTerm :: FilePath -> String
postTerm path
  | isIndexMarkdown (takeFileName path) = dropDatePrefix (takeFileName (takeDirectory path))
  | otherwise = dropDatePrefix (stripLanguageSuffix (takeBaseName path))

titleCtx :: Context String
titleCtx =
  field "title" $
    fmap (replaceAmp . fromMaybe "no title" . lookupString "title")
      . getMetadata
      . itemIdentifier

replaceAmp :: String -> String
replaceAmp =
  replaceAll "&" (const "&amp;")

languageTitlesField :: Context String
languageTitlesField =
  field "languageTitles" $
    fmap (concatMap renderLanguageTitle) . translationsFor . itemIdentifier

languageSectionsField :: String -> Context String
languageSectionsField className =
  field "languageSections" $
    fmap (concatMap (renderLanguageSection className)) . translationsFor . itemIdentifier

translationsFor :: Identifier -> Compiler [Translation]
translationsFor identifier = do
  items <- loadAllSnapshots (translationPattern identifier) "content"
  translations <- mapM translationFromItem (filter ((/= identifier) . itemIdentifier) items)
  return (List.sortOn translationRank translations)

translationPattern :: Identifier -> Pattern
translationPattern identifier
  | isIndexMarkdown fileName = fromGlob (directory </> "index.*.md")
  | otherwise = fromGlob (directory </> stripLanguageSuffix (takeBaseName path) <> ".*.md")
  where
    path = toFilePath identifier
    fileName = takeFileName path
    directory = takeDirectory path

translationFromItem :: Item String -> Compiler Translation
translationFromItem item = do
  metadata <- getMetadata (itemIdentifier item)
  let lang = fromMaybe defaultLang (lookupString "lang" metadata)
      title = fromMaybe "no title" (lookupString "title" metadata)
  return
    Translation
      { translationLang = lang,
        translationTitle = title,
        translationBody = itemBody item
      }

translationRank :: Translation -> (Int, String)
translationRank translation
  | translationLang translation == defaultLang = (0, translationLang translation)
  | otherwise = (1, translationLang translation)

renderLanguageTitle :: Translation -> String
renderLanguageTitle translation =
  "<span class=\"language-version\" data-language-version=\""
    <> lang
    <> "\" lang=\""
    <> lang
    <> "\" hidden>"
    <> escapeHtmlText (translationTitle translation)
    <> "</span>"
  where
    lang = escapeHtmlText (translationLang translation)

renderLanguageSection :: String -> Translation -> String
renderLanguageSection className translation =
  "<section class=\""
    <> className
    <> " language-version\" data-language-version=\""
    <> lang
    <> "\" lang=\""
    <> lang
    <> "\" hidden>"
    <> translationBody translation
    <> "</section>"
  where
    lang = escapeHtmlText (translationLang translation)

isIndexMarkdown :: FilePath -> Bool
isIndexMarkdown fileName =
  fileName == "index.md"
    || ("index." `List.isPrefixOf` fileName && ".md" `List.isSuffixOf` fileName)

stripLanguageSuffix :: String -> String
stripLanguageSuffix value =
  case break (== '.') value of
    (prefix, '.' : suffix)
      | not (null prefix) && looksLikeLanguage suffix -> prefix
    _ -> value

looksLikeLanguage :: String -> Bool
looksLikeLanguage lang =
  not (null lang)
    && all isLanguageChar lang
  where
    isLanguageChar char =
      char == '-' || char == '_' || List.elem char (['a' .. 'z'] <> ['A' .. 'Z'] <> ['0' .. '9'])

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
