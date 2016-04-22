{-# LANGUAGE DeriveGeneric #-}

module VC.Server.Types where

import Data.Aeson
import GHC.Generics
import Data.SL
import Happstack.Server
import Control.Monad.Reader

type Version = String
type ConfigName = String
data Config = Config {
   fingerprintFile :: FilePath,
   userConfigDir :: FilePath
} deriving (Generic)

defaultConfig :: Config
defaultConfig = Config "" ""

instance FromJSON Config
instance ToJSON Config
instance SL Config

data UserQuery = UserQuery {
   activation :: String
}

userQuery :: RqData UserQuery
userQuery = do
   a <- look "activation"
   return $ UserQuery a
   
instance FromData UserQuery where
   fromData = userQuery
   