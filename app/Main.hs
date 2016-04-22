module Main where

import VC.Server
import VC.Server.Types
import Control.Monad.Reader
import System.Environment
import Data.SL

main :: IO ()
main = do
   [configPath] <- getArgs
   config <- load configPath
   runReaderT startServer config

