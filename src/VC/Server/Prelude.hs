module VC.Server.Prelude 
   (module X, writeLog) 
   where

import System.IO as X
import Happstack.Server as X
import Data.Monoid as X
import Control.Monad as X
import Control.Applicative as X
import Control.Monad.State as X
import Control.Monad.Except as X
import Data.Maybe as X
import Data.Functor.Identity as X
import GHC.Generics as X
import GHC.Fingerprint as X
import System.IO as X
import System.Directory as X
import System.Environment as X
import Database.HDBC as X
import Database.HDBC.Sqlite3 as X
import DB.MonadModel.MultiTable as X
import Debug.Trace as X

writeLog :: MonadIO m => String -> m ()
writeLog str = liftIO $ hPutStrLn stderr str

