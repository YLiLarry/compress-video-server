module VC.Server.Route.Release where
   
import VC.Server.Prelude
import VC.Server.Class
import VC.Server.Environment
import Happstack.Server.FileServe.BuildingBlocks


releaseVersion :: VCServer Response
releaseVersion = do
   release <- releaseZip <$> config <$> get 
   hs <- liftIO $ getFileHash release
   return $ toResponse hs

releaseDownload :: VCServer Response
releaseDownload = do
   release <- releaseZip <$> config <$> get 
   serveFile (guessContentTypeM mimeTypes) release
   
