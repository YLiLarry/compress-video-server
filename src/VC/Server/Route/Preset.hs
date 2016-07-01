{-# LANGUAGE OverloadedStrings #-}

module VC.Server.Route.Preset where

import VC.Server.Prelude
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B
import VC.Server.Types
import VC.Server.Environment
import Data.List


-- | Retrive the content of the fingerprint file
showFingerprints :: VCServer ByteString
showFingerprints = do
   fp <- (fingerprintFile . config) <$> get
   liftIO $ B.readFile fp

-- | Route
routeFingerprints :: VCServer Response
routeFingerprints = toResponse <$> showFingerprints 
