module VC.Server (startServer, module X) where

import VC.Server.Prelude as X
import VC.Server.Router
import VC.Server.Types
import VC.Server.Environment as X
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B
import GHC.Fingerprint
import Data.Aeson (encode)
import Control.Exception as E

startServer :: StateT Environment IO ()
startServer = do
   generateFingerprints
   env <- get
   liftIO $ simpleHTTP nullConf (runVCServerT env router `catchError` handler)
   where
      handler :: IOException -> ServerPart Response
      handler = simpleErrorHandler . show
   
-- | Generate the fingerprint file.
-- Used to check if there is an update of config file on the server.
generateFingerprints :: StateT Environment IO ()
generateFingerprints = do   
   cfgDir <- (presetDir . config) <$> get
   fpf <- (fingerprintFile . config) <$> get
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
         