-- |
-- Module: Hakyll.Web.Sass
-- Copyright: (C) 2015 Braden Walters
-- License: MIT (see LICENSE file)
-- Maintainer: Braden Walters <vc@braden-walters.info>
-- Stability: experimental
-- Portability: ghc

module Hakyll.Web.Sass
( sassCompiler
, sassCompilerWith
, renderSass
, renderSassWith
, selectFileType
, sassDefConfig
, module Text.Sass.Options
) where

import Control.Monad (join)
import Data.Default.Class
import Hakyll.Core.Compiler
import Hakyll.Core.Identifier
import Hakyll.Core.Compiler.Internal
import Hakyll.Core.Item
import Hakyll.Core.Provider
import System.FilePath (takeExtension)
import Text.Sass.Compilation
import Text.Sass.Options
import Prelude

-- | Compiles a SASS file into CSS. Use the file extension to determine SCSS
-- from SASS formatting.
sassCompiler :: Compiler (Item String)
sassCompiler = getResourceBody >>= renderSass

-- | Compiles a SASS file into CSS with options. The file extension will not
-- be used to determine SCSS from SASS formatting.
sassCompilerWith :: SassOptions -> Compiler (Item String)
sassCompilerWith options = getResourceBody >>= renderSassWith options

-- | Compiles a SASS file item into CSS. Use the file extension to determine
-- SCSS from SASS formatting.
renderSass :: Item String -> Compiler (Item String)
renderSass item =
  let extension = (takeExtension . toFilePath . itemIdentifier) item
  in case selectFileType sassDefConfig extension of
       Just options -> renderSassWith options item
       Nothing -> fail "File type must be .scss or .sass."

-- | Compiles a SASS file item into CSS with options. The file extension will
-- not be used to determine SCSS from SASS formatting.
renderSassWith :: SassOptions -> Item String -> Compiler (Item String)
renderSassWith options item = join $ do
  provider <- compilerProvider <$> compilerAsk
  let filePath = resourceFilePath provider (itemIdentifier item)
  unsafeCompiler $ do
    resultOrErr <- compileFile filePath options
    case resultOrErr of
      Left sassError -> errorMessage sassError >>= fail
      Right result -> return (makeItem result)

-- | Use the file extension to determine whether to use indented syntax.
selectFileType :: SassOptions -> String -> Maybe SassOptions
selectFileType options ".scss" = Just $ options { sassIsIndentedSyntax = False }
selectFileType options ".sass" = Just $ options { sassIsIndentedSyntax = True }
selectFileType _ _ = Nothing

-- | Default sass configuration.
sassDefConfig :: SassOptions
sassDefConfig = def
