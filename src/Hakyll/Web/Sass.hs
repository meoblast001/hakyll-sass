-- |
-- Module: Hakyll.Web.Sass
-- Copyright: (C) 2015 Braden Walters
-- License: MIT (see LICENSE file)
-- Maintainer: Braden Walters <vc@braden-walters.info>
-- Stability: experimental
-- Portability: ghc

module Hakyll.Web.Sass
( sassCompiler
, renderSass
) where

import Control.Monad (join)
import Data.Default.Class
import Data.Functor
import Hakyll.Core.Compiler
import Hakyll.Core.Identifier
import Hakyll.Core.Item
import System.FilePath (takeExtension)
import Text.Sass.Compilation
import Text.Sass.Options

-- | Compiles a SASS file into CSS.
sassCompiler :: Compiler (Item String)
sassCompiler = getResourceBody >>= renderSass

-- | Compiles a SASS file item into CSS.
renderSass :: Item String -> Compiler (Item String)
renderSass item =
  let bodyStr = itemBody item
      extension = (takeExtension . toFilePath . itemIdentifier) item
  in case selectFileType def extension of
    Just options -> join $ unsafeCompiler $ do
      resultOrErr <- compileString bodyStr options
      case resultOrErr of
        Left sassError -> errorMessage sassError >>= fail
        Right result -> return (makeItem result)
    Nothing -> fail "File type must be .scss or .sass."

-- | Use the file extension to determine whether to use indented syntax.
selectFileType :: SassOptions -> String -> Maybe SassOptions
selectFileType options ".scss" = Just $ options { sassIsIndentedSyntax = False }
selectFileType options ".sass" = Just $ options { sassIsIndentedSyntax = True }
selectFileType _ _ = Nothing
