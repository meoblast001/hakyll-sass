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

-- | Compiles a SASS file into CSS.
sassCompiler :: Compiler (Item String)
sassCompiler = do
  bodyStr <- itemBody <$> getResourceBody
  resultOrErr <- unsafeCompiler (compileString bodyStr def)
  case resultOrErr of
    Left sassError -> fail (unsafePerformIO $ errorMessage sassError)
    Right result -> makeItem result
