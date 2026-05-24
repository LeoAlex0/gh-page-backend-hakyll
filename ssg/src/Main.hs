{-# LANGUAGE OverloadedStrings #-}

import Hakyll (hakyllWith)
import Site.Config (siteConfig)
import Site.Rules (siteRules)

main :: IO ()
main =
  hakyllWith siteConfig siteRules
