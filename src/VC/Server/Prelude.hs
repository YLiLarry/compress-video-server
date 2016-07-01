module VC.Server.Prelude 
   (module X, writeLog) 
   where

import System.IO as X
import Happstack.Server as X
import Data.Monoid as X
import Control.Applicative as X
import Control.Monad.State as X
import Control.Monad.Error as X
import Data.Functor.Identity as X
import GHC.Generics as X
import System.Directory as X
import System.Environment as X
import Database.HDBC as X
import Database.HDBC.Sqlite3 as X
import DB.MonadModel.MultiTable as X

writeLog :: MonadIO m => String -> m ()
writeLog str = liftIO $ hPutStrLn stderr str

