{-# LANGUAGE FlexibleContexts #-}

module Main where

import DataSource       (getDataSource)
import DomainAPI
import Relations.Tenant hiding (getTenant)
import Relations.User   hiding (getUser)
import Relations.Role   hiding (getRole)
import DBInterface

import Data.Aeson       (ToJSON)
import Data.Aeson.Encode.Pretty
import qualified Data.ByteString.Lazy.Char8 as BL


someTenant :: TenantInsert
someTenant = TenantInsert
    "TestTenant" "Sylvain" "Duchamps" "sly@champsxxx.fr" "3980" Nothing "sy.chasmps.xxxx.fr"

someUser :: UserInsert
someUser = UserInsert
    1 "testuser2" "testpass" (Just "tesss") (Just "usserrr")

printJson :: ToJSON a => DBUniqueResult a -> IO ()
printJson (Left err)  = print err
printJson (Right val) = BL.putStrLn $
    encodePretty' defConfig {confCompare = compare} val

main :: IO ()
main = do
    conn    <- getDataSource

    dbUpdate conn (updateTenant updName) 1 "lalala" >>= print

    createUser conn someUser >>= print
    createTenant conn someTenant >>= print
    -- activateTenant conn 1 >>= print

    getTenant conn 1 >>= printJson
    getUser conn 1 >>= printJson

    dbDelete conn deleteRoleById 4 >>= print

    dbQuery conn allRoles () >>= print

    dbQuery conn allTenants () >>= print
