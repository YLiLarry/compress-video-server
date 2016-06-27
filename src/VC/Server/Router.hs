{-# LANGUAGE LambdaCase #-}

module VC.Server.Router where
   
import VC.Server.Prelude
import VC.Server.Route
import VC.Server.Types
import VC.Server.Environment
import qualified Data.List as L
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B

router :: VCServer Response
router = 
   msum [
            guardQParams userQuery,
            guardUserActivated,
            dirs "/api/config/fingerprints" routeFingerprints,
            dirs "/api/config/" $ path routeUserConfig
         ] 

-- | User must provide an activated hash code
guardUserActivated :: VCServer Response
guardUserActivated = liftServerPartT $
   withData $ \q -> 
      case activation q of
         "activation-code" -> mzero
         otherwise -> simpleErrorHandler "inactivated"

guardQParams :: RqData q -> VCServer Response
guardQParams q = liftServerPartT $
   getDataFn q >>= 
      \case (Left msg) -> simpleErrorHandler $ unlines msg
            (Right _) -> mzero
 

showPreset :: String -> VCServer ByteString
showPreset name = do
   dirPath <- (presetDir . config) <$> ask
   let fpath = L.intercalate "/" [dirPath, name]
   liftIO $ B.readFile fpath
   
routeUserConfig :: String -> VCServer Response
routeUserConfig name = toResponse <$> showPreset name
      
