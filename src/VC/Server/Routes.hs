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
import Data.List

writeLog :: MonadIO m => String -> m ()
writeLog str = liftIO $ hPutStrLn stderr str

-- | Retrive the content of the fingerprint file
showFingerprints :: ReaderT Config IO ByteString
showFingerprints = do
   mapReaderT (B.readFile . runIdentity) $ fingerprintFile <$> ask

-- | Route
routeFingerprints :: ReaderT Config (ServerPartT IO) Response
routeFingerprints = toResponse <$> mapReaderT liftIO showFingerprints

-- | Generate the fingerprint file
generateFingerprints :: ReaderT Config IO ()
generateFingerprints = do   
   cfgDir <- userConfigDir <$> ask
   fpf <- fingerprintFile <$> ask
   writeLog $ "Generate fingerprints for files in " ++ cfgDir
   writeLog $ "Generate fingerprints to " ++ fpf
   cfgs <- liftIO $ getDirectoryContents cfgDir
   liftIO $ do
      ls <- sequence [ make cfgDir f | f <- cfgs, notElem f [".", ".."] ]
      B.writeFile fpf $ encode ls
   where
      make p f = do
         p <- show <$> getFileHash (p ++ f)
         return (f, p)     

showUserConfig :: ConfigName -> ReaderT Config IO ByteString
showUserConfig name = do
   dirPath <- userConfigDir <$> ask
   let fpath = intercalate "/" [dirPath, name]
   liftIO $ B.readFile fpath
   
routeUserConfig :: ConfigName -> ReaderT Config (ServerPartT IO) Response
routeUserConfig name = mapReaderT liftIO $ toResponse <$> showUserConfig name
      

