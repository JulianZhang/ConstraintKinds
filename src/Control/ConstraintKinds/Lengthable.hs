{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TypeFamilies #-}

module Control.ConstraintKinds.Lengthable
    where

import GHC.Prim

import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as VU
import qualified Data.Vector.Generic as G

import Prelude hiding (foldl, foldr)
import qualified Prelude as P

-------------------------------------------------------------------------------
-- Foldable

class Lengthable t where
    type LengthableConstraint t x :: Constraint
    type LengthableConstraint t x = ()
    
    length :: t -> Int
    -- I was too lazy to work out the new default instances for these because all the important structures already provide the instances.  Also, it adds additional constraints into the functions that look ugly, and I'm not sure if it affects the functionality.
    foldr :: (FoldableConstraint t a, FoldableConstraint t b) => (a -> b -> b) -> b -> t a -> b
    foldl :: (FoldableConstraint t a, FoldableConstraint t b) => (a -> b -> a) -> a -> t b -> a
    foldl' :: (FoldableConstraint t a, FoldableConstraint t b) => (a -> b -> a) -> a -> t b -> a
    foldr1 :: (FoldableConstraint t a) => (a -> a -> a) -> t a -> a
    foldl1 :: (FoldableConstraint t a) => (a -> a -> a) -> t a -> a

    -- These functions get default implementations because they aren't provided for some structures
    fold :: (FoldableConstraint t m, Monoid m) => t m -> m
    fold = foldMap id
    
    foldMap :: (FoldableConstraint t a, FoldableConstraint t m, Monoid m) => (a -> m) -> t a -> m
    foldMap f = foldr (mappend . f) mempty
    
    foldr' :: (FoldableConstraint t a, FoldableConstraint t (b->b), FoldableConstraint t b) => (a -> b -> b) -> b -> t a -> b
    foldr' f z0 xs = foldl f' id xs z0
        where f' k x z = k $! f x z

-------------------------------------------------------------------------------
-- functions

{-# INLINE toList #-}
toList :: (Foldable t, FoldableConstraint t [a], FoldableConstraint t a) => t a -> [a]
toList = foldr (:) []

-------------------------------------------------------------------------------
-- Instances

instance Foldable [] where
    type FoldableConstraint [] x = ()
    {-# INLINE foldr #-}
    {-# INLINE foldl #-}
    {-# INLINE foldl' #-}
    {-# INLINE foldr1 #-}
    {-# INLINE foldl1 #-}
    
    foldr = L.foldr
    foldl = L.foldl
    foldl' = L.foldl'
    foldr1 = L.foldr1
    foldl1 = L.foldl1

--     fold = L.fold
--     foldMap = L.foldMap
--     foldr' = L.foldr'

instance Foldable V.Vector where
    type FoldableConstraint V.Vector x = ()
    {-# INLINE foldr #-}
    {-# INLINE foldl #-}
    {-# INLINE foldl' #-}
    {-# INLINE foldr1 #-}
    {-# INLINE foldl1 #-}
    
    foldr = V.foldr
    foldl = V.foldl
    foldl' = V.foldl'
    foldr1 = V.foldr1
    foldl1 = V.foldl1

instance Foldable VU.Vector where
    type FoldableConstraint VU.Vector x = VU.Unbox x
    {-# INLINE foldr #-}
    {-# INLINE foldl #-}
    {-# INLINE foldl' #-}
    {-# INLINE foldr1 #-}
    {-# INLINE foldl1 #-}
    
    foldr = VU.foldr
    foldl = VU.foldl
    foldl' = VU.foldl'
    foldr1 = VU.foldr1
    foldl1 = VU.foldl1
