module VC.Server where

import Happstack.Server
import VC.Server.Router
import VC.Server.Routes
import VC.Server.Types
import Control.Monad.Reader

defaultConfig :: Config
defaultConfig = Config "" "" ""

startServer :: ReaderT Config IO ()
startServer = do
   generateFingerprints
   mapReaderT (simpleHTTP nullConf) router

