{-# OPTIONS_GHC -Wall #-}

module AST.Expression where

import qualified AST.Helpers as Help
import qualified AST.Literal as Literal
import qualified AST.Pattern as Pattern
import qualified AST.Type as Type
import qualified AST.Variable as Var
import qualified Reporting.Annotation as A
import qualified Reporting.Region as R


---- GENERAL AST ----

type Def =
  A.Located Def'


data Def'
    = Definition Pattern.Pattern Expr
    | TypeAnnotation String Type.Type
    deriving (Show)


type Expr =
    A.Annotated R.Region Expr'


data Expr'
    = Literal Literal.Literal
    | Var Var.Var
    | Range Expr Expr
    | ExplicitList [Expr]
    | Binop Var.Var Expr Expr
    | Lambda Pattern.Pattern Expr
    | App Expr Expr
    | If [(Expr, Expr)] Expr
    | Let [Def] Expr
    | Case Expr [(Pattern.Pattern, Expr)]
    | Data String [Expr]
    | Access Expr String
    | Update Expr [(String, Expr)]
    | Record [(String, Expr)]
    -- for type checking and code gen only
    | Port PortImpl
    | GLShader String String Literal.GLShaderTipe
    deriving (Show)


-- PORTS

data PortImpl
    = In String (Type.Port Type.Type)
    | Out String Expr (Type.Port Type.Type)
    | Task String Expr (Type.Port Type.Type)
    deriving (Show)


portName :: PortImpl -> String
portName impl =
  case impl of
    In name _ -> name
    Out name _ _ -> name
    Task name _ _ -> name


---- UTILITIES ----

rawVar :: String -> Expr'
rawVar x =
  Var (Var.Var x)


tuple :: [Expr] -> Expr'
tuple expressions =
  Data ("_Tuple" ++ show (length expressions)) expressions


saveEnvName :: String
saveEnvName =
  "_save_the_environment!!!"