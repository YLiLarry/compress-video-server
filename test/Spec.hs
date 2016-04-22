import Test.Hspec
import VC.Server
import VC.Server.Types
import Control.Monad.Reader
import Data.SL

testConfig :: Config
testConfig = Config {
      fingerprintFile = "./test/test-resource/current/fingerprints.txt",
      userConfigDir = "./test/test-resource/current/cfgs/"
   }

main :: IO ()
main = hspec $ do
   describe "" $ do
      it "startServer" $ do
         save testConfig "./test/testConfig.txt"
         runReaderT startServer testConfig
         
         