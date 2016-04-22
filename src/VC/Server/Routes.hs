{-# LANGUAGE OverloadedStrings #-}

module VC.Server.Routes where

import Control.Monad.Reader
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B
import Happstack.Server
import VC.Server.Types
import Data.Functor.Identity
import System.Directory
import GHC.Fingerprint
import Data.Aeson
import System.IO

writeLog :: MonadIO m => String -> m ()
writeLog str = liftIO $ hPutStrLn stderr str

-- | Retrive a path
fingerprintPath :: Reader (Config, Version) FilePath
fingerprintPath = do
   (cfg, vs) <- ask
   return $ concat [base cfg, vs, "/", fingerprintFile cfg]

-- | Retrive the content of the fingerprint file
fingerprints :: ReaderT (Config, Version) IO ByteString
fingerprints = do
   mapReaderT (B.readFile . runIdentity) fingerprintPath

-- | Route
routeFingerprints :: ReaderT (Config, Version) (ServerPartT IO) Response
routeFingerprints = do
   mapReaderT (liftIO . fmap toResponse) fingerprints

-- | Generate the fingerprint file
generateFingerprints :: ReaderT Config IO ()
generateFingerprints = do   
   cfgDir <- userConfigDir <$> ask
   fpf <- fingerprintFile <$> ask
   cfgs <- liftIO $ getDirectoryContents cfgDir
   writeLog $ "Generate fingerprints for files in " ++ cfgDir
   writeLog $ "Generate fingerprints to " ++ fpf
   liftIO $ do
      ls <- sequence [ make cfgDir f | f <- cfgs, notElem f [".", ".."] ]
      B.writeFile fpf $ encode ls
   where
      make p f = do
         p <- show <$> getFileHash (p ++ f)
         return (f, p)     
   
userConfigPath :: ConfigName -> Reader (Config, Version) FilePath
userConfigPath name = do
   (cfg, vs) <- ask
   return $ concat [base cfg, vs, userConfigDir cfg, name]

showUserConfig :: ConfigName -> ReaderT (Config, Version) IO ByteString
showUserConfig name = do
   mapReaderT (B.readFile . runIdentity) $ userConfigPath name
   
routeUserConfig :: ConfigName -> ReaderT (Config, Version) (ServerPartT IO) Response
routeUserConfig name = do
   mapReaderT (liftIO . fmap toResponse) $ showUserConfig name

