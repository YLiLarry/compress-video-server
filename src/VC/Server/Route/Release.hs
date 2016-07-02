module VC.Server.Route.Release where
   
import VC.Server.Prelude
import VC.Server.Class
import VC.Server.Environment
import Happstack.Server.FileServe.BuildingBlocks

release :: String -> VCServer Response
release version = do
   dir <- releaseDir <$> config <$> get 
   serveFileFrom dir (guessContentTypeM mimeTypes) version
   
