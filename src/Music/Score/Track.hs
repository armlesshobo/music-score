                              
{-# LANGUAGE
    TypeFamilies,
    DeriveFunctor,
    DeriveFoldable,
    GeneralizedNewtypeDeriving #-} 

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
-- Provides a musical score represenation.
--
-------------------------------------------------------------------------------------

module Music.Score.Track (
        Track(..)
  ) where

import Prelude hiding (foldr, concat, foldl, mapM, concatMap, maximum, sum, minimum)

import Data.Semigroup
import Control.Applicative
import Control.Monad (ap, join, MonadPlus(..))
import Data.Foldable
import Data.Traversable
import Data.Maybe
import Data.Either
import Data.Function (on)
import Data.Ord (comparing)
import Data.Ratio
import Data.VectorSpace
import Data.AffineSpace
import qualified Data.Map as Map
import qualified Data.List as List

import Music.Score.Time
import Music.Score.Duration

-------------------------------------------------------------------------------------
-- Track type
-------------------------------------------------------------------------------------

-- |
-- A track is a sorted list of absolute-time occurences.
--
-- Track is a 'Monoid' under parallel composition. 'mempty' is the empty track and 'mappend'
-- interleaves values.
--
-- Track has an 'Applicative' instance derived from the 'Monad' instance.
--
-- Track is a 'Monad'. 'return' creates a track containing a single value at time
-- zero, and '>>=' transforms the values of a track, allowing the addition and
-- removal of values relative to the time of the value. Perhaps more intuitively,
-- 'join' delays each inner track to start at the offset of an outer track, then
-- removes the intermediate structure. 
--
-- > let t = Track [(0, 65),(1, 66)] 
-- >
-- > t >>= \x -> Track [(0, 'a'), (10, toEnum x)]
-- >
-- >   ==> Track {getTrack = [ (0.0,  'a'),
-- >                           (1.0,  'a'),
-- >                           (10.0, 'A'),
-- >                           (11.0, 'B') ]}
--
-- Track is an instance of 'VectorSpace' using parallel composition as addition, 
-- and time scaling as scalar multiplication. 
--
newtype Track a = Track { getTrack :: [(Time, a)] }
    deriving (Eq, Ord, Show, Functor, Foldable)

instance Semigroup (Track a) where
    (<>) = mappend

-- Equivalent to the derived Monoid, except for the sorted invariant.
instance Monoid (Track a) where
    mempty = Track []
    Track as `mappend` Track bs = Track (as `m` bs)
        where
            m = mergeBy (comparing fst)

instance Applicative Track where
    pure  = return
    (<*>) = ap

instance Monad Track where
    return a = Track [(0, a)]
    a >>= k = join' . fmap k $ a
        where
            join' (Track ts) = foldMap (uncurry delay') $ ts
            delay' t = delay (Duration . getTime $ t)

instance Alternative Track where
    empty = mempty
    (<|>) = mappend

-- Satisfies left distribution
instance MonadPlus Track where
    mzero = mempty
    mplus = mappend

instance AdditiveGroup (Track a) where
    zeroV   = mempty
    (^+^)   = mappend
    negateV = id

instance VectorSpace (Track a) where
    type Scalar (Track a) = Time
    n *^ Track tr = Track . (fmap (first (n*^))) $ tr

instance Delayable (Track a) where
    d `delay` Track tr = Track . fmap (first (.+^ d)) $ tr

instance HasOnset (Track a) where
    onset  (Track []) = 0
    onset  (Track xs) = minimum (fmap on xs)  where on   (t,x) = t
    offset (Track []) = 0
    offset (Track xs) = maximum (fmap off xs) where off  (t,x) = t

instance HasDuration (Track a) where
    duration x = offset x .-. onset x

--    offset x = maximum (fmap off x)   where off (t,x) = t
                                                              


list z f [] = z
list z f xs = f xs

first f (x,y)  = (f x, y)
second f (x,y) = (x, f y)


mergeBy :: (a -> a -> Ordering) -> [a] -> [a] -> [a]
mergeBy f as bs = List.sortBy f $ as <> bs
