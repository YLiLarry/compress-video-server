{-# LANGUAGE DeriveGeneric #-}

module VC.Server.DB.User where
   
import VC.Server.Prelude

data User m = User {
   activation :: m String
} deriving (Generic)

