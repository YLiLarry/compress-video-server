import Test.Hspec
import VC.Server
import VC.Server.Types
import Control.Monad.Reader
import Data.SL

testConfig :: Config
testConfig = Config {
      base = "./test/test-resource/",
      fingerprintFile = "/fingerprints.txt",
      userConfigDir = "/fingerprints/"
   }

main :: IO ()
main = hspec $ do
   describe "" $ do
      it "startServer" $ do
         save testConfig "./test/testConfig.txt"
         runReaderT startServer testConfig
         
         