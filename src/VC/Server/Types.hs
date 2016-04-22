{-# LANGUAGE DeriveGeneric #-}

module VC.Server.Types where

import Data.Aeson
import GHC.Generics
import Data.SL
import Happstack.Server

type Version = String
type ConfigName = String
data Config = Config {
   base :: FilePath,
   fingerprintFile :: FilePath,
   userConfigDir :: FilePath
} deriving (Generic)

instance FromJSON Config
instance ToJSON Config
instance SL Config

data UserQuery = UserQuery {
   version :: String,
   activation :: String
}

userQuery :: RqData UserQuery
userQuery = do
   v <- look "version"
   a <- look "activation"
   return $ UserQuery v a
   
instance FromData UserQuery where
   fromData = userQuery
   