### Hakyll SASS ###
A library for [Hakyll](http://jaspervdj.be/hakyll/) providing a compiler for
[SASS](http://sass-lang.com/) using
[hsass](http://hackage.haskell.org/package/hsass). This package can be found on
Hackage under [hakyll-sass](https://hackage.haskell.org/package/hakyll-sass).

To install, run the following command:

    cabal install hakyll-sass

To use in a Hakyll project, do something similar to the following:

    -- css/default.sass

    *
        box-sizing: border-box


    -- templates/default.html

    -- ...
    <link rel="stylesheet" href="/css/default.css" />
    -- ...


    -- site.hs

    -- ...
    import Hakyll.Web.Sass (sassCompiler)
    -- ...

    main = hakyll $ do
        match "css/*.sass" $ do
            route $ setExtension "css"
            let compressCssItem = fmap compressCss
            compile (compressCssItem <$> sassCompiler)
        -- ...
