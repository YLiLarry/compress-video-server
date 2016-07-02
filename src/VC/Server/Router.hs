{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase #-}

module VC.Server.Router where
   
import VC.Server.Prelude
import VC.Server.Route
import VC.Server.Class
import VC.Server.Environment
import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as B

import VC.Server.DB.User

-- | User must provide an activated hash code
guardUserActivated :: VCServer Response
guardUserActivated = do {
   a <- looks "activation";
   check (null a) (badRequest $ toResponse "Missing activation")
   <|> do {
      r <- load (activation =. head a);
      check (null r) (badRequest $ toResponse "No user found!")
      <|> (modify (\e -> e {user = Just $ head r}) >> mzero)
   }
}

router :: VCServer Response
router = do
   tmp <- tmpDir <$> config <$> get
   decodeBody $ defaultBodyPolicy tmp 1024 1024 1024
   msum [
            guardUserActivated,
            dirs "/api/config/fingerprints" fingerprints,
            dirs "/api/config/" $ path preset,
            dirs "/api/release/" $ path release
         ] 

check :: Bool -> VCServer Response -> VCServer Response
check b x = if b then x else mzero
