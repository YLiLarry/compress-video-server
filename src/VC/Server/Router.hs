{-# LANGUAGE LambdaCase #-}

module VC.Server.Router where
   
import Happstack.Server
import Data.Monoid
import Control.Monad.Reader
import VC.Server.Routes
import VC.Server.Types
import Control.Monad.Error.Class

router :: ReaderT Config (ServerPartT IO) Response
router = do
   cfg <- ask 
   lift $ do
      msum [
               dirs "/api/config/fingerprints" $ 
                  guardQParams userQuery `mplus`
                  guardUserActivated `mplus` do 
                  v <- look "version"
                  runReaderT routeFingerprints (cfg, v)
               ,
               dirs "/api/config/" $ path $ 
               \configName -> 
                  guardQParams userQuery `mplus`
                  guardUserActivated `mplus` do
                  v <- look "version"
                  runReaderT (routeUserConfig configName) (cfg,v)
            ] 

guardUserActivated :: ServerPartT IO Response
guardUserActivated = 
   withData $ \q -> 
      case activation q of
         "activation-code" -> mzero
         otherwise -> simpleErrorHandler "inactivated"

guardQParams :: RqData q -> ServerPart Response
guardQParams q = 
   getDataFn q >>= 
      \case (Left msg) -> simpleErrorHandler $ unlines msg
            (Right _) -> mzero
 
