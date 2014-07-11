--Connor Cormier, 7/11/14

{-# LANGUAGE FlexibleContexts #-}

import Happstack.Server
import Happstack.Server.Proxy
import Data.List (elemIndex, partition)
import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent
import System.Process
import System.Directory

main = do
     let conf = nullConf { port = 80 }
     config <- readConfig
     let (reCont, cmdCont) = partition (not . (=='$') . head) . filter (not . (=='#') . head)  . lines $ config
         cmds = map (tail) cmdCont
         redirs = map (split) reCont
         routes = map (reverseProxy) redirs
         handler = msum (routes ++ [badRequest "Invalid path!"])
     --Execute startup commands from file
     mapM_ execute cmds
     --Now run reverse proxy
     simpleHTTP conf $ handler
     where split str = let Just ind = '|' `elemIndex` str
                       in (take ind str, drop (ind + 1) str)

readConfig :: IO String
readConfig = do
           fileExists <- doesFileExist "proxy.conf"
           if fileExists
              then readFile "proxy.conf"
              else readFile "/etc/reverse_proxy/proxy.conf"

execute :: String -> IO ThreadId
execute cmd = forkIO $ do
                     system cmd
                     return ()

reverseProxy :: (Control.Monad.IO.Class.MonadIO m, FilterMonad Response m, ServerMonad m, WebMonad Response m, MonadPlus m) => (FilePath, String) -> m String
reverseProxy (match, port) = dirs match $ handle port
             where handle fwd = do
                          request <- askRq
                          let nRq = request { rqPaths = ("localhost:" ++ port): rqPaths request }
                          response <- liftIO $ getResponse (unproxify nRq)
                          case response of Right r -> escape' r
                                           Left x -> badRequest x
