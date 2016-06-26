{-# LANGUAGE LambdaCase #-}

module Main where

import VC.Server

main :: IO ()
main = do
   getArgs >>= \case 
      [configPath] -> do
         cfg <- load configPath
         env <- loadConfig cfg
         runReaderT startServer env
      _ -> fail "compress-video-server: <config-file-path>"

