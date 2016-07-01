{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}

module VC.Server.Types where

import VC.Server.Prelude
import VC.Server.Environment
import DB.MonadModel.MultiTable

type Version = String
type PathConfigName = String


newtype VCServerT m v = VCServerT { 
   unVCServerT :: StateT Environment (ModelT Connection (ServerPartT m)) v
}

deriving instance (ServerMonad m) => ServerMonad (ModelT cnn m)

deriving instance (Functor m) => Functor (VCServerT m)
deriving instance (Monad m) => Applicative (VCServerT m)
deriving instance (Monad m) => Monad (VCServerT m)
deriving instance (Monad m) => MonadState Environment (VCServerT m) 
deriving instance (Monad m) => ServerMonad (VCServerT m)
deriving instance (MonadIO m) => MonadIO (VCServerT m)
deriving instance Alternative (VCServerT IO)
deriving instance MonadPlus (VCServerT IO)
deriving instance HasRqData (VCServerT IO) 

deriving instance (HasRqData m, Monad m) => HasRqData (ModelT c m) 

type VCServer = VCServerT IO

liftServerPartT :: (Monad m) => ServerPartT m v -> VCServerT m v
liftServerPartT = VCServerT . lift . lift

liftModelT :: (Monad m) => ServerPartT m v -> VCServerT m v
liftModelT = VCServerT . lift . lift


runVCServerT :: (Monad m) => Environment -> VCServerT m Response -> ServerPartT m Response
runVCServerT e a = 
   runModelT (evalStateT (unVCServerT a) e) (dbConnect e)
   >>= \case Left msg -> simpleErrorHandler msg
             Right v  -> return v

-- instance (IConnection cnn, Monad m) => HasRqData (ModelT cnn m)

class ToVCServerT m where
   toVCServerT :: m a 

instance MonadModel Connection (VCServerT IO) where
   fromModel x = VCServerT $ lift $ mapModelT lift x
