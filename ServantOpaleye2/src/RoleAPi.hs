{-# LANGUAGE Arrows                #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}

module RoleApi
  (
   createRole
  , updateRole
  , removeRole
  , readRolesForTenant
  , readRoleById
  ) where

import           AppCore
import           Control.Arrow
import           Control.Lens
import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.HashMap.Strict as HM
import           GHC.Int
import           Opaleye
import           Utils
import           Prelude             hiding (id)

createRole :: (DbConnection m) => RoleIncoming -> m Role
createRole role = createRow roleTable role

updateRole :: (DbConnection m, CurrentUser m, CurrentTenant m) => Role -> m Role
updateRole role = updateAuditableRow roleTable role

removeRole :: (DbConnection m) => Role -> m GHC.Int.Int64
removeRole role = do
  _ <- removeRawDbRows userRolePivotTable (\(_, roleId) -> roleId .== constant (role ^. id))
  removeRawDbRows roleTable matchFunc
    where
    tId = role ^. id
    matchFunc role' = (role' ^. id).== constant tId

readRoles :: (DbConnection m) => m [Role]
readRoles = readRow roleQuery

readRoleById :: (DbConnection m) => RoleId -> m Role
readRoleById rId = (readRow query) >>= (returnOneIfNE "Role not found")
  where
    query :: RoleQuery
    query = proc () ->
      do role <- roleQuery -< ()
         restrict -< (role ^. id) .== (constant rId)
         returnA -< role
    
readRolesForTenant :: (DbConnection m) => TenantId -> m [Role]
readRolesForTenant tId = do
  readRow $ roleQueryForTenant tId

roleQueryForTenant :: TenantId -> RoleQuery
roleQueryForTenant tTenantid =
  proc () ->
  do role <- roleQuery -< ()
     restrict -< (role ^. tenantid) .== (constant tTenantid)
     returnA -< role