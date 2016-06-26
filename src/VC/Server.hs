module VC.Server (startServer, module X) where

import VC.Server.Prelude as X
import VC.Server.Router
import VC.Server.Types
import VC.Server.Environment as X
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B
import GHC.Fingerprint
import Data.Aeson (encode)

startServer :: ReaderT Environment IO ()
startServer = do
   generateFingerprints
   mapReaderT (simpleHTTP nullConf) (unVCServerT router)
   

-- | Generate the fingerprint file.
-- Used to check if there is an update of config file on the server.
generateFingerprints :: ReaderT Environment IO ()
generateFingerprints = do   
   cfgDir <- (presetDir . config) <$> ask
   fpf <- (fingerprintFile . config) <$> ask
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
         