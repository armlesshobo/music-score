
-------------------------------------------------------------------------------------
-- |
-- Copyright   : (c) Hans Hoglund 2012-2014
--
-- License     : BSD-style
--
-- Maintainer  : hans@hanshoglund.se
-- Stability   : experimental
-- Portability : non-portable (TF,GNTD)
--
-- Provides a musical score representation.
--
-------------------------------------------------------------------------------------

module Music.Score (
        -- * Prerequisites
        module Control.Lens,
        module Control.Applicative,
        module Control.Monad,
        module Control.Monad.Plus,
        module Data.Semigroup,
        module Data.VectorSpace,
        module Data.AffineSpace,
        module Data.AffineSpace.Point,

        module Music.Time,
        -- module Music.Score.Combinators,

        -- * Music representation
        -- ** Musical elements
        module Music.Score.Part,
        module Music.Score.Pitch,
        module Music.Score.Dynamics,
        module Music.Score.Articulation,
        module Music.Score.Slide,
        module Music.Score.Tremolo,
        module Music.Score.Text,
        module Music.Score.Harmonics,
        module Music.Score.Color,

        -- ** Miscellaneous
        module Music.Score.Ties,
        module Music.Score.Phrases,
        module Music.Score.Clef,

        -- ** Meta-information
        module Music.Score.Meta,
        module Music.Score.Meta.Title,
        module Music.Score.Meta.Attribution,
        module Music.Score.Meta.RehearsalMark,
        module Music.Score.Meta.Barline,
        module Music.Score.Meta.Clef,
        module Music.Score.Meta.Fermata,
        module Music.Score.Meta.Key,
        module Music.Score.Meta.Time,
        module Music.Score.Meta.Tempo,
        module Music.Score.Meta.Annotations,

        -- * Import and export
        module Music.Score.Import.Abc,
        module Music.Score.Import.Lilypond,
        module Music.Score.Import.Midi,

        -- module Music.Score.Export.Abc,
        module Music.Score.Export.Backend,
        module Music.Score.Export.NoteList,
        module Music.Score.Export.Midi,
        module Music.Score.Export.SuperCollider,
        module Music.Score.Export.Lilypond,
        module Music.Score.Export.MusicXml,
)
where

import           Control.Applicative
import           Control.Lens                   hiding (Level, above, below,
                                                 inside, parts, reversed,
                                                 rewrite, simple, transform,
                                                 (<.>), (<|), (|>))
import           Control.Monad                  hiding (mapM)
import           Control.Monad.Plus
import           Data.AffineSpace
import           Data.AffineSpace.Point
import           Data.Basis
import           Data.Either
import           Data.Foldable
import           Data.Maybe
import           Data.Ratio
import           Data.Semigroup
import           Data.Traversable
import           Data.Typeable
import           Data.VectorSpace               hiding (Sum, getSum)

import           Music.Time                     hiding (time)

import           Music.Score.Articulation
import           Music.Score.Clef
import           Music.Score.Color
import           Music.Score.Dynamics
import           Music.Score.Export.Backend
import           Music.Score.Export.NoteList
import           Music.Score.Export.Midi
import           Music.Score.Export.SuperCollider
import           Music.Score.Export.Abc
import           Music.Score.Export.Lilypond
import           Music.Score.Export.Midi
import           Music.Score.Export.MusicXml
import           Music.Score.Harmonics
import           Music.Score.Import.Abc
import           Music.Score.Import.Lilypond
import           Music.Score.Import.Midi
import           Music.Score.Instances
import           Music.Score.Meta
import           Music.Score.Meta.Annotations
import           Music.Score.Meta.Attribution
import           Music.Score.Meta.Barline
import           Music.Score.Meta.Clef
import           Music.Score.Meta.Fermata
import           Music.Score.Meta.Key
import           Music.Score.Meta.RehearsalMark
import           Music.Score.Meta.Tempo
import           Music.Score.Meta.Time
import           Music.Score.Meta.Title
import           Music.Score.Part
import           Music.Score.Phrases
import           Music.Score.Pitch
import           Music.Score.Slide
import           Music.Score.Text
import           Music.Score.Ties
import           Music.Score.Tremolo
