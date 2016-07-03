{-# LANGUAGE LambdaCase #-}

module Main where

import VC.Server
import qualified Data.SL as SL

main :: IO ()
main = do
   getArgs >>= \case 
      [configPath] -> do
         cfg <- SL.load configPath
         env <- loadConfig cfg
         evalStateT startServer env
      _ -> fail "compress-video-server: <config-file-path>"

