{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase #-}

module VC.Server.Router where
   
import VC.Server.Prelude
import VC.Server.Route
import VC.Server.Types
import VC.Server.Environment
import qualified Data.List as L
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B

import VC.Server.DB.User

userQuery :: VCServer (User Value)
userQuery = do
   a <- look "activation"
   r <- load (activation =. a) 
   when (null r) $ fail "No user found!"
   return $ head r
   
router :: VCServer Response
router = 
   msum [
            guardUserActivated,
            dirs "/api/config/fingerprints" routeFingerprints,
            dirs "/api/config/" $ path routeUserConfig
         ] 

-- | User must provide an activated hash code
guardUserActivated :: VCServer Response
guardUserActivated = do
   usr <- userQuery
   case usr # activation of
      "activation-code" -> modify (\e -> e {user = Just usr}) >> mzero
      otherwise -> liftServerPartT $ simpleErrorHandler "inactivated"

guardQParams :: RqData q -> VCServer Response
guardQParams q = liftServerPartT $
   getDataFn q >>= 
      \case (Left msg) -> simpleErrorHandler $ unlines msg
            (Right _) -> mzero
 

showPreset :: String -> VCServer ByteString
showPreset name = do
   dirPath <- (presetDir . config) <$> get
   let fpath = L.intercalate "/" [dirPath, name]
   liftIO $ B.readFile fpath
   
routeUserConfig :: String -> VCServer Response
routeUserConfig name = toResponse <$> showPreset name
      
