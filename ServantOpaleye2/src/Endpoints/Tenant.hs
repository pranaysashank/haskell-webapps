{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TypeFamilies        #-}

module Endpoints.Tenant (
  Type
  ,server
) where

import           Servant
import           AppM
import           AppCore
import           TenantApi
import           UserApi
import           Utils

import Servant.Server.Experimental.Auth.Cookie

type instance AuthCookieData = CookieData

type Type = "tenants" :> AuthProtect "cookie-auth" :> Get '[JSON] [Tenant]

allTenants :: (DbConnection m) => CookieData -> m [Tenant]
allTenants cd = requireRole cd (RoleName "manager") >> readTenants

server::ServerT Type AppM
server = allTenants