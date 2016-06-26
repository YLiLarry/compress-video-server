{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module VC.Server.Types where

import VC.Server.Prelude
import VC.Server.Environment

type Version = String
type PathConfigName = String

data UserQuery = UserQuery {
   activation :: String
}

userQuery :: RqData UserQuery
userQuery = do
   a <- look "activation"
   return $ UserQuery a
   
instance FromData UserQuery where
   fromData = userQuery

newtype VCServerT m v = VCServerT { unVCServerT :: (ReaderT Environment (ServerPartT m) v) }
-- deriving instance (Functor m) => Functor (VCServerT m)
deriving instance (Functor m) => Functor (VCServerT m)
deriving instance (Monad m) => Applicative (VCServerT m)
deriving instance (Monad m) => Monad (VCServerT m)
deriving instance (Monad m) => MonadReader Environment (VCServerT m) 
deriving instance (Monad m) => ServerMonad (VCServerT m)
deriving instance (MonadIO m) => MonadIO (VCServerT m)
deriving instance Alternative (VCServerT IO)
deriving instance MonadPlus (VCServerT IO)

type VCServer = VCServerT IO

liftServerPartT :: (Monad m) => ServerPartT m v -> VCServerT m v
liftServerPartT = VCServerT . lift

runVCServerT :: Environment -> VCServerT m v -> ServerPartT m v
runVCServerT e a = runReaderT (unVCServerT a) e
