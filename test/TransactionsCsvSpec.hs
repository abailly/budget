{-# LANGUAGE OverloadedStrings #-}

module TransactionsCsvSpec
    where

import Test.Hspec
import Transaction
import Amount
import Account
import Name
import Note
import Category
import Date


import qualified Data.ByteString.Lazy as ByteString

spec :: SpecWith ()
spec = do
    describe "transactions" $ do
        it "can be decoded from a ByteString containing simple values" $ do
            let bs = "MyBank,,02/25/2020,some note,GOOGLE  DOMAINS,Online Services,12\nMyBank,,02/24/2020,,TRANSFERWISE INC,Training,-1242.26\n"
                ts = decodeTransactions bs
            ts `shouldBe` Right 
                [ Transaction (Account "MyBank") (theDay 2020 02 25) (Just $ Note "some note") (Just $ Name "GOOGLE  DOMAINS") (Category "Online Services") (amount 12.00)
                , Transaction (Account "MyBank") (theDay 2020 02 24) Nothing (Just $ Name "TRANSFERWISE INC") (Category "Training") (amount (-1242.26))
                ]
        it "strips the strings values from useless space" $ do
            let bs = "  MyBank  ,  ,  02/25/2020  ,  some note  ,  GOOGLE  DOMAINS  ,  Online Services  ,  12\n"
                ts = decodeTransactions bs
            ts `shouldBe` Right 
                [ Transaction (Account "MyBank") (theDay 2020 02 25) (Just $ Note "some note") (Just $ Name "GOOGLE  DOMAINS") (Category "Online Services") (amount 12.00)]
        it "can be decoded from a ByteString containing values with double minus sign" $ do
            let bs = "MyBank,,02/25/2020,,GOOGLE  DOMAINS,Online Services,--12\n"
                ts = decodeTransactions bs
            fmap (fmap transactionAmount) ts `shouldBe` Right [amount 12]

        it "can be decoded from a ByteString containing dates in an odd format" $ do
            let bs = "MyBank,,  2/ 5/20,,GOOGLE  DOMAINS,Online Services,-12\n"
                ts = decodeTransactions bs
            fmap (fmap transactionDate) ts `shouldBe` Right [theDay 2020 2 5]

        it "can be decoded from a ByteString containing more than the required number of fields" $ do
            let bs = "MyBank,,02/05/2020,,GOOGLE  DOMAINS,Online Services,-12,\n"
                ts = decodeTransactions bs
            fmap length ts `shouldBe` Right 1

        it "can notify an error when decoded from ill-formed data" $ do
            let bs1 = "MyBank,,02/25/2020,,GOOGLE  DOMAINS,Online Services,-1foo2\n"
                ts1 = decodeTransactions bs1
            ts1 `shouldBe` Left 
                "parse error (Failed reading: conversion error: expected Double, got \"1foo2\" (incomplete field parse, leftover: [102,111,111,50])) at \"\\n\""

            let bs2 = ",,02/25/2020,,GOOGLE  DOMAINS,Online Services,-12\n"
                ts2 = decodeTransactions bs2
            ts2 `shouldBe` Left
                "parse error (Failed reading: conversion error: account name required) at \"\\n\""
            let bs3 = "hello world\nthis is not a csv file\n"
                ts3 = decodeTransactions bs3
            ts3 `shouldBe` Left 
                "parse error (Failed reading: conversion error: [\"hello world\"]) at \"\\nthis is not a csv file\\n\""

        it "can be encoded to a ByteString containing values" $ do
            let ts = [ Transaction { transactionAccount = Account "MyBank"
                                   , transactionDate = theDay 2020 1 23
                                   , transactionNotes = Just $ Note "some notes"
                                   , transactionName = Just $ Name "a name"
                                   , transactionCategory = Category "Groceries"
                                   , transactionAmount = amount (-48.07) }
                     , Transaction { transactionAccount = Account "Invest"
                                   , transactionDate = theDay 2020 6 1
                                   , transactionNotes = Nothing
                                   , transactionName = Just $ Name "commerce"
                                   , transactionCategory = Category "Investments"
                                   , transactionAmount = amount (-48.07) }
                     ]
            let bs = encodeTransactions ts
            bs `shouldBe` "MyBank,,01/23/2020,some notes,a name,Groceries,-48.07\nInvest,,06/01/2020,,commerce,Investments,-48.07\n"

        it "can be saved to a csv file" $ do
            let ts = [ Transaction { transactionAccount = Account "MyBank"
                                   , transactionDate = theDay 2020 1 23
                                   , transactionNotes = Just $ Note "some notes"
                                   , transactionName = Just $ Name "a name"
                                   , transactionCategory = Category "Groceries"
                                   , transactionAmount = amount (-48.07) }
                     , Transaction { transactionAccount = Account "Invest"
                                   , transactionDate = theDay 2020 6 1
                                   , transactionNotes = Nothing
                                   , transactionName = Just $ Name "commerce"
                                   , transactionCategory = Category "Investments"
                                   , transactionAmount = amount (-48.07) }
                     ]
                fp = "test/test-encoded-transactions.csv"
            _ <- encodeTransactionsToFile ts fp
            us <- decodeTransactionsFromFile fp
            us `shouldBe` Right ts
        
        it "can be imported from a csv file" $ do
            let bs = "MyBank,,02/25/2020,some note,GOOGLE  DOMAINS,Online Services,12\nMyBank,,02/24/2020,,TRANSFERWISE INC,Training,-1242.26\n"
                fp = "test/test-transactions.csv" 
            ByteString.writeFile fp bs
            ts <- decodeTransactionsFromFile fp
            ts `shouldBe` Right 
                [ Transaction (Account "MyBank") (theDay 2020 02 25) (Just $ Note "some note") (Just $ Name "GOOGLE  DOMAINS") (Category "Online Services") (amount 12.00)
                , Transaction (Account "MyBank") (theDay 2020 02 24) Nothing (Just $ Name "TRANSFERWISE INC") (Category "Training") (amount (-1242.26))
                ]
        it "can notify an error when failing from importing from file" $ do
            let fp = "foo.csv"
            cats <- decodeTransactionsFromFile fp
            cats `shouldBe` Left 
                "foo.csv: openBinaryFile: does not exist (No such file or directory)"
