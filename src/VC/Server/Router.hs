{-# LANGUAGE LambdaCase #-}

module VC.Server.Router where
   
import Happstack.Server
import Data.Monoid
import Control.Monad.Reader
import VC.Server.Routes
import VC.Server.Types
import Control.Monad.Error.Class

router :: ReaderT Config (ServerPartT IO) Response
router = 
   msum [
            dirs "/api/config/fingerprints" $ 
               guardQParams userQuery `mplus`
               guardUserActivated `mplus` do 
               routeFingerprints
            ,
            dirs "/api/config/" $ path $ \configName -> 
               guardQParams userQuery `mplus`
               guardUserActivated `mplus` do
               routeUserConfig configName
         ] 

guardUserActivated :: ReaderT Config (ServerPartT IO) Response
guardUserActivated = lift $ 
   withData $ \q -> 
      case activation q of
         "activation-code" -> mzero
         otherwise -> simpleErrorHandler "inactivated"

guardQParams :: RqData q -> ReaderT Config (ServerPartT IO) Response
guardQParams q = lift $ 
   getDataFn q >>= 
      \case (Left msg) -> simpleErrorHandler $ unlines msg
            (Right _) -> mzero
 
