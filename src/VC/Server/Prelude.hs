module VC.Server.Prelude 
   (module X, writeLog) 
   where

import System.IO as X
import Happstack.Server as X
import Control.Monad.Reader as X
import Data.Monoid as X
import Control.Applicative as X
import Control.Monad.Error.Class as X
import Data.Functor.Identity as X
import GHC.Generics as X
import System.Directory as X
import System.Environment as X
import Data.SL as X
import Database.HDBC as X
import Database.HDBC.Sqlite3 as X

writeLog :: MonadIO m => String -> m ()
writeLog str = liftIO $ hPutStrLn stderr str

