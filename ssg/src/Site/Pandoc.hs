{-# LANGUAGE OverloadedStrings #-}

module Site.Pandoc
  ( pandocCompilerCustom,
  )
where

import Hakyll
import Site.GeoGebra (geogebraReferenceTransform)
import Text.Pandoc qualified as Pandoc
import Text.Pandoc.Highlighting (Style, breezeDark)

pandocCompilerCustom :: Compiler (Item String)
pandocCompilerCustom = do
  identifier <- getUnderlying
  pandocCompilerWithTransform pandocReaderOpts pandocWriterOpts (geogebraReferenceTransform identifier)

pandocExtensionsCustom :: Pandoc.Extensions
pandocExtensionsCustom =
  Pandoc.githubMarkdownExtensions
    <> Pandoc.extensionsFromList
      [ Pandoc.Ext_fenced_code_attributes,
        Pandoc.Ext_gfm_auto_identifiers,
        Pandoc.Ext_implicit_header_references,
        Pandoc.Ext_smart,
        Pandoc.Ext_footnotes,
        Pandoc.Ext_tex_math_dollars,
        Pandoc.Ext_tex_math_double_backslash,
        Pandoc.Ext_latex_macros
      ]

pandocReaderOpts :: Pandoc.ReaderOptions
pandocReaderOpts =
  defaultHakyllReaderOptions
    { Pandoc.readerExtensions = pandocExtensionsCustom
    }

pandocWriterOpts :: Pandoc.WriterOptions
pandocWriterOpts =
  defaultHakyllWriterOptions
    { Pandoc.writerExtensions = pandocExtensionsCustom,
      Pandoc.writerHTMLMathMethod = Pandoc.MathJax "",
      Pandoc.writerHighlightMethod = Pandoc.Skylighting pandocHighlightStyle
    }

pandocHighlightStyle :: Style
pandocHighlightStyle =
  breezeDark
