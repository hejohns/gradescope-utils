module Main
  ( main
  ) where

import Data.Aeson
import Data.Aeson.Types
import Data.ByteString.Lazy.UTF8
import Data.Vector
import System.Environment
import System.Exit
import System.IO

main :: IO ()
main = do
  argv <- getArgs
  let column_index :: Int = read $ argv !! 0
  match :: Value <- throwDecode $ fromString (argv !! 1)
  csv_line <- getContents'
  array :: Value <- throwDecode $ fromString csv_line
  case parse (withArray "foobar" return) array of
    Success vec ->
      let field_n :: Value = vec ! column_index
       in if field_n == match
            then exitWith ExitSuccess
            else exitWith $ ExitFailure 1
    Error msg -> error msg
