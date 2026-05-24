{-# LANGUAGE OverloadedStrings #-}

module Site.Rules
  ( siteRules,
  )
where

import Control.Monad (forM_)
import Hakyll
import Site.Context (pageCtx, postCtx, siteCtx)
import Site.Feed (feedCompiler)
import Site.Pandoc (pandocCompilerCustom)
import Site.Routes (pageRoute, postAssetPattern, postAssetRoute, postRoute, primaryPostPattern, translatedPostPattern)

siteRules :: Rules ()
siteRules = do
  tags <- buildTags primaryPostPattern (fromCapture "tags/*.html")
  categories <- buildTagsWith (getTagsByField "categories") primaryPostPattern (fromCapture "categories/*.html")

  forM_ staticFiles $ \pattern' -> match pattern' $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route idRoute
    compile compressCssCompiler

  match postAssetPattern $ do
    route postAssetRoute
    compile copyFileCompiler

  match translatedPostPattern $ do
    compile $
      pandocCompilerCustom
        >>= saveSnapshot "content"

  match primaryPostPattern $ do
    let ctx = constField "type" "article" <> postCtx tags categories

    route postRoute
    compile $
      pandocCompilerCustom
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/post.html" ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx

  match translatedPagePattern $ do
    compile $
      pandocCompilerCustom
        >>= saveSnapshot "content"

  match primaryPagePattern $ do
    let ctx = constField "type" "profile" <> pageCtx

    route pageRoute
    compile $
      pandocCompilerCustom
        >>= loadAndApplyTemplate "templates/page.html" ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx

  archiveRules tags categories
  taxonomyIndexRules tags categories
  taxonomyPageRules tags categories
  homeRules tags categories
  templateRules
  sitemapRules
  feedRules

archiveRules :: Tags -> Tags -> Rules ()
archiveRules tags categories =
  create ["archives/index.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll primaryPostPattern

      let archiveCtx =
            constField "title" "归档"
              <> bilingualHeaderCtx "归档" "Archives" "按时间回看所有文章。" "Browse all posts by date."
              <> listField "posts" (postCtx tags categories) (return posts)
              <> siteCtx

      makeItem ("" :: String)
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx

taxonomyIndexRules :: Tags -> Tags -> Rules ()
taxonomyIndexRules tags categories = do
  create ["tags/index.html"] $ do
    route idRoute
    compile $ do
      let tagsCtx =
            constField "title" "标签"
              <> bilingualHeaderCtx "标签" "Tags" "按标签浏览文章。" "Browse posts by tag."
              <> tagCloudField "tagCloud" 80 180 tags
              <> siteCtx

      makeItem ("" :: String)
        >>= loadAndApplyTemplate "templates/taxonomy.html" tagsCtx
        >>= loadAndApplyTemplate "templates/default.html" tagsCtx

  create ["categories/index.html"] $ do
    route idRoute
    compile $ do
      let categoriesCtx =
            constField "title" "分类"
              <> bilingualHeaderCtx "分类" "Categories" "按分类浏览文章。" "Browse posts by category."
              <> tagCloudField "tagCloud" 80 180 categories
              <> siteCtx

      makeItem ("" :: String)
        >>= loadAndApplyTemplate "templates/taxonomy.html" categoriesCtx
        >>= loadAndApplyTemplate "templates/default.html" categoriesCtx

taxonomyPageRules :: Tags -> Tags -> Rules ()
taxonomyPageRules tags categories = do
  tagsRules tags $ \tag pattern' -> do
    route idRoute
    compile $
      taxonomyPageCompiler
        tags
        categories
        ("标签：" <> tag)
        ("Tag: " <> tag)
        "这个标签下的文章。"
        ("Posts tagged " <> tag <> ".")
        pattern'

  tagsRules categories $ \category pattern' -> do
    route idRoute
    compile $
      taxonomyPageCompiler
        tags
        categories
        ("分类：" <> category)
        ("Category: " <> category)
        "这个分类下的文章。"
        ("Posts in " <> category <> ".")
        pattern'

taxonomyPageCompiler :: Tags -> Tags -> String -> String -> String -> String -> Pattern -> Compiler (Item String)
taxonomyPageCompiler tags categories titleZh titleEn leadZh leadEn pattern' = do
  posts <- recentFirst =<< loadAll pattern'

  let ctx =
        constField "title" titleZh
          <> bilingualHeaderCtx titleZh titleEn leadZh leadEn
          <> listField "posts" (postCtx tags categories) (return posts)
          <> siteCtx

  makeItem ("" :: String)
    >>= loadAndApplyTemplate "templates/archive.html" ctx
    >>= loadAndApplyTemplate "templates/default.html" ctx

homeRules :: Tags -> Tags -> Rules ()
homeRules tags categories =
  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll primaryPostPattern

      let indexCtx =
            constField "home" "true"
              <> listField "posts" (postCtx tags categories) (return posts)
              <> siteCtx

      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx

templateRules :: Rules ()
templateRules =
  match "templates/*" $
    compile templateBodyCompiler

sitemapRules :: Rules ()
sitemapRules =
  create ["sitemap.xml"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll primaryPostPattern
      pages <- loadAll primaryPagePattern

      let sitemapPages = posts <> pages
          sitemapCtx =
            listField "pages" pageCtx (return sitemapPages)
              <> siteCtx

      makeItem ("" :: String)
        >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx

feedRules :: Rules ()
feedRules = do
  create ["rss.xml"] $ do
    route idRoute
    compile (feedCompiler renderRss)

  create ["atom.xml"] $ do
    route idRoute
    compile (feedCompiler renderAtom)

bilingualHeaderCtx :: String -> String -> String -> String -> Context a
bilingualHeaderCtx titleZh titleEn leadZh leadEn =
  constField "pageTitle" titleZh
    <> constField "pageTitleEn" titleEn
    <> constField "pageLead" leadZh
    <> constField "pageLeadEn" leadEn

staticFiles :: [Pattern]
staticFiles =
  [ "favicon.ico",
    "robots.txt",
    "_config.yaml",
    "imgs/*",
    "js/*",
    "fonts/*"
  ]

primaryPagePattern :: Pattern
primaryPagePattern =
  "pages/*.md" .&&. complement translatedPagePattern

translatedPagePattern :: Pattern
translatedPagePattern =
  "pages/*.*.md"
