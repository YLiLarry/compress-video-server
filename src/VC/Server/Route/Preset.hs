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
   fp <- (fingerprintFile . config) <$> ask
   liftIO $ B.readFile fp

-- | Route
routeFingerprints :: VCServer Response
routeFingerprints = toResponse <$> showFingerprints 

showUserConfig :: String -> VCServer ByteString
showUserConfig name = do
   dirPath <- (presetDir . config) <$> ask
   let fpath = intercalate "/" [dirPath, name]
   liftIO $ B.readFile fpath
   
routeUserConfig :: String -> VCServer Response
routeUserConfig name = toResponse <$> showUserConfig name
      
