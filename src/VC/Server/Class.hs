{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module VC.Server.Class where

import VC.Server.Prelude
import VC.Server.Environment
import DB.MonadModel.MultiTable

type Version = String
type PathConfigName = String


newtype VCServer v = VCServer { 
   unVCServer :: StateT Environment (ModelT Connection (ServerPartT IO)) v
}


deriving instance Functor VCServer
deriving instance Applicative VCServer
deriving instance Monad VCServer
deriving instance MonadState Environment VCServer 
deriving instance MonadError String VCServer 
deriving instance ServerMonad VCServer
deriving instance MonadIO VCServer
deriving instance Alternative VCServer
deriving instance MonadPlus VCServer
deriving instance HasRqData VCServer 
deriving instance FilterMonad Response VCServer
deriving instance WebMonad Response VCServer

deriving instance (ServerMonad m) => ServerMonad (ModelT cnn m)
deriving instance (HasRqData m, Monad m) => HasRqData (ModelT c m) 
deriving instance (WebMonad Response m) => WebMonad Response (ModelT c m) 
deriving instance (FilterMonad Response m) => FilterMonad Response (ModelT c m) 

liftServerPart :: ServerPart v -> VCServer v
liftServerPart = VCServer . lift . lift

liftModel :: ServerPart v -> VCServer v
liftModel = VCServer . lift . lift


runVCServer :: Environment -> VCServer Response -> ServerPart Response
runVCServer e a = do {
   r <- runModelT (evalStateT (unVCServer a) e) (dbConnect e);
   case r of {
      Left ""  -> mzero;
      Left msg -> simpleErrorHandler msg;
      Right v  -> return v;
   };
}


instance MonadModel Connection VCServer where
   fromModel x = VCServer $ lift $ mapModelT lift x

instance ToMessage Fingerprint where
   toResponse = toResponse . show