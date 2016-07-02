{-# LANGUAGE OverloadedStrings #-}

module VC.Server.Route.Preset where

import VC.Server.Prelude
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B
import VC.Server.Class
import VC.Server.Environment
import qualified Data.List as L


-- | Retrive the content of the fingerprint file
showFingerprints :: VCServer ByteString
showFingerprints = do
   fp <- (fingerprintFile . config) <$> get
   liftIO $ B.readFile fp

-- | Route
fingerprints :: VCServer Response
fingerprints = toResponse <$> showFingerprints 


showPreset :: String -> VCServer ByteString
showPreset name = do
   dirPath <- (presetDir . config) <$> get
   let fpath = L.intercalate "/" [dirPath, name]
   liftIO $ B.readFile fpath
   
preset :: String -> VCServer Response
preset name = toResponse <$> showPreset name
      
