import Test.Hspec
import VC.Server

testConfig :: Config
testConfig = Config {
      fingerprintFile = "./test/test-resource/current/fingerprints.txt",
      presetDir = "./test/test-resource/current/cfgs/",
      dbPath = "./test/test-resource/test.db"
   }

main :: IO ()
main = hspec $ do
   describe "" $ do
      it "startServer" $ do
         save testConfig "./test/testConfig.txt"
         env <- loadConfig testConfig
         runReaderT startServer env
         