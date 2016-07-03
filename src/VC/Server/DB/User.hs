{-# LANGUAGE DeriveGeneric #-}

module VC.Server.DB.User where
   
import VC.Server.Prelude

data User m = User {
   key :: m Integer,
   activation :: m String
} deriving (Generic)

instance MultiTable User where
   relation = User {
      key = IsKey [("Activation", "id")],
      activation = IsCol "Activation" "code"
   }
   