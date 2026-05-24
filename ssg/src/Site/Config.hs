{-# LANGUAGE OverloadedStrings #-}

module Site.Config
  ( defaultLang,
    deployCommandText,
    feedAuthorEmailText,
    feedAuthorNameText,
    feedDescriptionText,
    feedRootUrl,
    feedTitleText,
    giscusCategory,
    giscusCategoryID,
    giscusEmitMetadata,
    giscusInputPosition,
    giscusMapping,
    giscusReactionsEnabled,
    giscusRepo,
    giscusRepoID,
    giscusStrict,
    siteConfig,
    siteName,
    siteRoot,
    sourceDirectoryText,
  )
where

import Data.List (isPrefixOf, isSuffixOf)
import Hakyll
import System.FilePath (takeFileName)

siteName :: String
siteName = "zLeoAlex's Blog"

siteRoot :: String
siteRoot = "https://leoalex0.github.io"

feedTitleText :: String
feedTitleText = siteName

feedDescriptionText :: String
feedDescriptionText = "with Memos"

defaultLang :: String
defaultLang = "zh-CN"

feedAuthorNameText :: String
feedAuthorNameText = "zLeoAlex"

feedAuthorEmailText :: String
feedAuthorEmailText = "leoalex0@users.noreply.github.com"

feedRootUrl :: String
feedRootUrl = siteRoot

sourceDirectoryText :: FilePath
sourceDirectoryText = "src"

giscusRepo :: String
giscusRepo = "LeoAlex0/blog-comments"

giscusRepoID :: String
giscusRepoID = "MDEwOlJlcG9zaXRvcnkyNDg3NTc4Njc="

giscusCategory :: String
giscusCategory = "General"

giscusCategoryID :: String
giscusCategoryID = "DIC_kwDODtO-a84C9uOc"

giscusMapping :: String
giscusMapping = "specific"

giscusStrict :: String
giscusStrict = "0"

giscusReactionsEnabled :: String
giscusReactionsEnabled = "1"

giscusEmitMetadata :: String
giscusEmitMetadata = "0"

giscusInputPosition :: String
giscusInputPosition = "bottom"

deployCommandText :: String
deployCommandText = "scripts/deploy.sh"

siteConfig :: Configuration
siteConfig =
  defaultConfiguration
    { destinationDirectory = "dist",
      deployCommand = deployCommandText,
      ignoreFile = ignoreFile',
      previewHost = "127.0.0.1",
      previewPort = 8000,
      providerDirectory = sourceDirectoryText,
      storeDirectory = "ssg/_cache",
      tmpDirectory = "ssg/_tmp"
    }

ignoreFile' :: FilePath -> Bool
ignoreFile' path
  | "." `isPrefixOf` fileName = False
  | "#" `isPrefixOf` fileName = True
  | "~" `isSuffixOf` fileName = True
  | ".swp" `isSuffixOf` fileName = True
  | otherwise = False
  where
    fileName = takeFileName path
