
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE ConstraintKinds            #-}
{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE DeriveFoldable             #-}
{-# LANGUAGE DeriveFunctor              #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoMonomorphismRestriction  #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}

-------------------------------------------------------------------------------------
-- |
-- Copyright   : (c) Hans Hoglund 2012
--
-- License     : BSD-style
--
-- Maintainer  : hans@hanshoglund.se
-- Stability   : experimental
-- Portability : non-portable (TF,GNTD)
--
-- Provides functions for manipulating ornaments (and miscellaneous stuff to be
-- given its own module soon...).
--
-------------------------------------------------------------------------------------


module Music.Score.Text (
        -- * Text
        HasText(..),
        TextT(..),
        text,
  ) where

import           Control.Applicative
import           Control.Comonad
import           Control.Lens hiding (transform)
import           Data.Functor.Couple
import           Data.Foldable
import           Data.Foldable
import           Data.Ratio
import           Data.Word
import           Data.Semigroup
import           Data.Typeable

-- import           Music.Score.Combinators
import           Music.Score.Part
import           Music.Time
import           Music.Pitch.Literal
import           Music.Dynamics.Literal
import           Music.Pitch.Alterable
import           Music.Pitch.Augmentable
import           Music.Score.Phrases



class HasText a where
    addText :: String -> a -> a

newtype TextT a = TextT { getTextT :: Couple [String] a }
    deriving (Eq, Show, Ord, Functor, Foldable, Typeable, Applicative, Monad, Comonad)

instance HasText a => HasText (b, a) where
    addText       s                                 = fmap (addText s)

instance HasText a => HasText (Couple b a) where
    addText       s                                 = fmap (addText s)

instance HasText a => HasText [a] where
    addText       s                                 = fmap (addText s)

instance HasText a => HasText (Score a) where
    addText       s                                 = fmap (addText s)


-- | Unsafe: Do not use 'Wrapped' instances
instance Wrapped (TextT a) where
  type Unwrapped (TextT a) = Couple [String] a
  _Wrapped' = iso getTextT TextT

instance Rewrapped (TextT a) (TextT b)

instance HasText (TextT a) where
    addText      s (TextT (Couple (t,x)))                    = TextT (Couple (t ++ [s],x))

-- Lifted instances
deriving instance Num a => Num (TextT a)
deriving instance Fractional a => Fractional (TextT a)
deriving instance Floating a => Floating (TextT a)
deriving instance Enum a => Enum (TextT a)
deriving instance Bounded a => Bounded (TextT a)
deriving instance (Num a, Ord a, Real a) => Real (TextT a)
deriving instance (Real a, Enum a, Integral a) => Integral (TextT a)

-- |
-- Attach the given text to the first note in the score.
--
text :: (HasPhrases' s a, HasText a) => String -> s -> s
text s = over (phrases'.headV) (addText s)


