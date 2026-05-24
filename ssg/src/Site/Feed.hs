{-# LANGUAGE OverloadedStrings #-}

module Site.Feed
  ( feedCompiler,
  )
where

import Hakyll
import Site.Config
import Site.Context (feedCtx)
import Site.Routes (primaryPostPattern)

type FeedRenderer =
  FeedConfiguration ->
  Context String ->
  [Item String] ->
  Compiler (Item String)

feedCompiler :: FeedRenderer -> Compiler (Item String)
feedCompiler renderer =
  renderer feedConfiguration feedCtx
    =<< recentFirst
    =<< loadAllSnapshots primaryPostPattern "content"

feedConfiguration :: FeedConfiguration
feedConfiguration =
  FeedConfiguration
    { feedTitle = feedTitleText,
      feedDescription = feedDescriptionText,
      feedAuthorName = feedAuthorNameText,
      feedAuthorEmail = feedAuthorEmailText,
      feedRoot = feedRootUrl
    }
