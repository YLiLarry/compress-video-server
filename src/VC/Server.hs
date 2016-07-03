module VC.Server (startServer, module X) where

import VC.Server.Prelude as X
import VC.Server.Router
import VC.Server.Class
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
   liftIO $ simpleHTTP nullConf (runVCServer env router)

   
-- | Generate the fingerprint file.
-- Used to check if there is an update of config file on the server.
generateFingerprints :: StateT Environment IO ()
generateFingerprints = do   
   presetDir' <- presetDir <$> config <$> get
   -- releaseDir' <- releaseDir <$> config <$> get
   fpf <- fingerprintFile <$> config <$> get
   writeLog $ "Generate fingerprints for files in " ++ presetDir'
   -- writeLog $ "Generate fingerprints for files in " ++ releaseDir'
   writeLog $ "Generate fingerprints to " ++ fpf
   configs <- liftIO $ getDirectoryContents presetDir'
   -- releases <- liftIO $ getDirectoryContents releaseDir'
   liftIO $ do
      ls <- sequence [ make presetDir' f | f <- configs, notElem f [".", ".."] ]
      B.writeFile fpf $ encode ls
   where
      make p f = do
         p <- show <$> getFileHash (p ++ f)
         return (f, p)    
         
         