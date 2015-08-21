-- |
-- Module: Hakyll.Web.Sass
-- Copyright: (C) 2015 Braden Walters
-- License: MIT (see LICENSE file)
-- Maintainer: Braden Walters <vc@braden-walters.info>
-- Stability: experimental
-- Portability: ghc

module Hakyll.Web.Sass (sassCompiler) where

import Data.Default.Class
import Data.Functor
import Hakyll.Core.Compiler
import Hakyll.Core.Item
import System.IO.Unsafe
import Text.Sass.Compilation
import Text.Sass.Options

-- | Compiles a SASS file into CSS.
sassCompiler :: Compiler (Item String)
sassCompiler = do
  bodyStr <- itemBody <$> getResourceBody
  extension <- getUnderlyingExtension
  let mayOptions = selectFileType def extension
  case mayOptions of
    Just options -> do
      resultOrErr <- unsafeCompiler (compileString bodyStr options)
      case resultOrErr of
        Left sassError -> fail (unsafePerformIO $ errorMessage sassError)
        Right result -> makeItem result
    Nothing -> fail "File type must be .scss or .sass."

-- | Use the file extension to determine whether to use indented syntax.
selectFileType :: SassOptions -> String -> Maybe SassOptions
selectFileType options ".scss" = Just $ options { sassIsIndentedSyntax = False }
selectFileType options ".sass" = Just $ options { sassIsIndentedSyntax = True }
selectFileType _ _ = Nothing
