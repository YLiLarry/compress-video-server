{-# LANGUAGE DeriveGeneric #-}

module VC.Server.Environment where
   
import VC.Server.Prelude
import Data.SL
import Database.HDBC.Sqlite3
import VC.Server.DB.User
import DB.Model.MultiTable

data Config = Config {
   -- ^ fingerprint lockfile
   fingerprintFile :: FilePath,
   -- ^ video presets
   presetDir :: FilePath,
   dbPath    :: FilePath
} deriving (Generic)

data Environment = Environment {
   config :: Config,
   dbConnect :: Connection,
   user :: Maybe (User Value)
}

instance FromJSON Config
instance ToJSON Config
instance SL Config

loadConfig :: Config -> IO Environment
loadConfig cfg = do
   dbCon <- connectSqlite3 $ dbPath cfg 
   return Environment {
      config    = cfg,
      dbConnect = dbCon,
      user = Nothing
   }
   