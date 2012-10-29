{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-fields #-}
module Text.Cassius
    ( -- * Datatypes
      Css
    , CssUrl
      -- * Type class
    , ToCss (..)
      -- * Rendering
    , renderCss
    , renderCssUrl
      -- * Parsing
    , cassius
    , cassiusFile
    , cassiusFileDebug
    , cassiusFileReload
      -- * ToCss instances
      -- ** Color
    , Color (..)
    , colorRed
    , colorBlack
      -- ** Size
    , mkSize
    , AbsoluteUnit (..)
    , AbsoluteSize (..)
    , absoluteSize
    , EmSize (..)
    , ExSize (..)
    , PercentageSize (..)
    , percentageSize
    , PixelSize (..)
    ) where

import Text.Css
import Text.Shakespeare.Base
import Language.Haskell.TH.Quote (QuasiQuoter (..))
import Language.Haskell.TH.Syntax
import qualified Data.Text.Lazy as TL
import Text.CssCommon
import Text.Lucius (lucius)
import qualified Text.Lucius
import Text.IndentToBrace (i2b)

cassius :: QuasiQuoter
cassius = QuasiQuoter { quoteExp = quoteExp lucius . i2b }

cassiusFile :: FilePath -> Q Exp
cassiusFile fp = do
#ifdef GHC_7_4
    qAddDependentFile fp
#endif
    contents <- fmap TL.unpack $ qRunIO $ readUtf8File fp
    quoteExp cassius contents

cassiusFileDebug, cassiusFileReload :: FilePath -> Q Exp
cassiusFileDebug = cssFileDebug True [|Text.Lucius.parseTopLevels|] Text.Lucius.parseTopLevels
cassiusFileReload = cassiusFileDebug
