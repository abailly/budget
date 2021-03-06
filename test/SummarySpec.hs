module SummarySpec
    where
import Test.Hspec
import ShouldBeOutput (shouldBeLine, shouldBeOutput)
import TransactionSpec (simplified)
import Sorting
import Category
import Period
import Summary
import Date

day1, day2, day3 :: Date
day1 = theDay 2020 04 01
day2 = theDay 2020 04 02
day3 = theDay 2020 04 13


spec :: SpecWith ()
spec = do
    describe "summary" $ do

        it "show the total for a category" $ do
            let t1 = simplified 2020 04 01 "Online Services" 48.07 
            let t2 = simplified 2020 04 02 "Online Services" 50.00
            let transactions = [t1, t2]
            [take 60 (head (summaryLines Nothing [] [] transactions))] `shouldBeOutput` 
                [ "Online Services : 98.07" ]

        it "show the total for two categories" $ do
            let t1 = simplified 2020 04 01 "Special" 48.07 
            let t2 = simplified 2020 04 02 "Online Services" 50.00 
            let t3 = simplified 2020 04 13 "Online Services" 42.00
            let transactions = [t1, t2, t3]
            map (take 60) (take 2 (summaryLines Nothing [] [] transactions))
            `shouldBeOutput` [ "Online Services : 92.00"
                             , "Special : 48.07" ]

        it "show the grand total, mentionning the min and max date" $ do
            let t1 = simplified 2020 04 01 "Special" 48.07 
            let t2 = simplified 2020 04 02 "Online Services" 50.00 
            let t3 = simplified 2020 04 13 "Online Services" 42.00
            let transactions = [t1, t2, t3]
            map (take 60) (summaryLines Nothing [] [] transactions)
            `shouldBeOutput` ["Online Services : 92.00"
                             ,"Special : 48.07"
                             ,"TOTAL from 04/01/2020 to 04/13/2020 : 140.07"]

        it "can select categories from a list of categories, for the period of the whole csv file" $ do
            let t1 = simplified 2020 04 01 "Special" 4807 
            let t2 = simplified 2020 04 02 "Online Services" 50.00 
            let t3 = simplified 2020 04 13 "Online Services" 42.00
            let transactions = [t1, t2, t3]
            let cats = [(Category "Online Services")]
            map (take 60) (summaryLines Nothing [] cats transactions)
            `shouldBeOutput` ["Online Services : 92.00"
                             ,"TOTAL from 04/01/2020 to 04/13/2020 : 92.00"]

        it "can show the categories of a transactions selected on a period" $ do
            let t1 = simplified 2020 04 01 "Special" 4807 
            let t2 = simplified 2019 12 02 "Online Services" 50.00 
            let t3 = simplified 2020 01 13 "Holidays" 42.00
            let p = period (theDay 2020 01 01) (theDay 2020 03 31)
            let transactions = [t1, t2, t3]
            map (take 60) (summaryLines (Just p) [] [] transactions)
            `shouldBeOutput` ["Holidays : 42.00"
                             ,"TOTAL from 01/01/2020 to 03/31/2020 : 42.00"]


        describe "sort the lines" $ do
            let t1 = simplified 2020 04 01 "Special" 48.07 
            let t2 = simplified 2020 04 02 "Online Services" 50.00 
            let t3 = simplified 2020 04 13 "Groceries" 42.00
            let transactions = [t1, t2, t3]
            it "by category name ascending (by default)" $ do
                map (take 60) (take 3 (summaryLines Nothing [] [] transactions))
                `shouldBeOutput` [ "Groceries : 42.00"
                                 , "Online Services : 50.00"
                                 , "Special : 48.07"
                                 ]
            it "by category name ascending (by specification)" $ do
                map (take 60) (take 3 (summaryLines Nothing [CategoryAsc] [] transactions))
                `shouldBeOutput` [ "Groceries : 42.00"
                                 , "Online Services : 50.00"
                                 , "Special : 48.07"
                                 ]
            it "by category name descending" $ do
                map (take 60) (take 3 (summaryLines Nothing [CategoryDesc] [] transactions))
                `shouldBeOutput` [ "Special : 48.07"
                                 , "Online Services : 50.00"
                                 , "Groceries : 42.00"
                                 ]
            it "by amount ascending" $ do
                map (take 60) (take 3 (summaryLines Nothing [AmountAsc] [] transactions))
                `shouldBeOutput` [ "Groceries : 42.00"
                                 , "Special : 48.07"
                                 , "Online Services : 50.00"
                                 ]                            
            it "by amount desscending" $ do
                map (take 60) (take 3 (summaryLines Nothing [AmountDesc] [] transactions))
                `shouldBeOutput` [ "Online Services : 50.00"
                                 , "Special : 48.07"
                                 , "Groceries : 42.00"
                                 ]                            
    describe "show the average amount of each category according to the number of month in the period" $ do
        it "for a one month period" $ do
            let t1 = simplified 2020 4 1  "Online Services" 48.07 
            let t2 = simplified 2020 4 5  "Online Services" 50.00 
            let transactions = [t1, t2]
            head (summaryLines Nothing [] [] transactions) `shouldBeLine`
                "Online Services : 98.07 | 98.07"
        it "for a two months period" $ do
            let t1 = simplified 2020 4 1  "Online Services" 48.07 
            let t2 = simplified 2020 5 5  "Online Services" 50.00 
            let transactions = [t1, t2]
            head (summaryLines Nothing [] [] transactions) `shouldBeLine` 
                "Online Services : 98.07 | 49.03"
        it "for a two months period in one category" $ do
            let t1 = simplified 2020 4 1  "Online Services" 48.07 
            let t2 = simplified 2020 5 31  "Training" 50.00 
            let transactions = [t1, t2]
            head (summaryLines Nothing [] [Category "Training"] transactions) `shouldBeLine` 
                "Training : 50.00 | 25.00"
        it "for one category in a selected period" $ do
            let t1 = simplified 2020 4 1  "Online Services" 48.07 
            let t2 = simplified 2020 5 31  "Training" 50.00 
            let transactions = [t1, t2]
            (summaryLines (Just (period (theDay 2020 1 1) (theDay 2020 5 31))) [] [Category "Training"] transactions) `shouldBeOutput` 
                ["Training : 50.00 | 10.00"
                ,"TOTAL from 01/01/2020 to 05/31/2020 : 50.00 | 10.00"]
    it "show the average amount for all transactions according to the number of month in the period" $ do
        let t1 = simplified 2020 4 1  "Online Services" 48.07 
        let t2 = simplified 2020 5 31  "Training" 50.00 
        let transactions = [t1,t2]
        last (summaryLines Nothing [] [] transactions) `shouldBeLine` 
                "TOTAL from 04/01/2020 to 05/31/2020 : 98.07 | 49.03"

    describe "summary title" $ do
        it "show a header for the given filename and period" $ do
            let begin = theDay 2020 01 01
                end = theDay 2020 03 31
            summaryTitle (Just "Bank.csv") Nothing Nothing (Period begin end) `shouldBeLine` 
                "Summary for file: Bank.csv from 01/01/2020 to 03/31/2020"

        it "show a header for the given filename and category list and period" $ do
            let begin = theDay 2020 01 01
                end = theDay 2020 03 31
            summaryTitle (Just "Bank.csv") (Just "categs.csv") Nothing (Period begin end) `shouldBeLine` 
                "Summary for file: Bank.csv for categories in the file: categs.csv from 01/01/2020 to 03/31/2020"

        it "show a header for the period" $ do
            let begin = theDay 2020 01 01
                end = theDay 2020 03 31
            summaryTitle Nothing Nothing Nothing (Period begin end) `shouldBeLine` 
                "Summary (main file) from 01/01/2020 to 03/31/2020"

        it "show a header for the period and a single category" $ do
            let begin = theDay 2020 01 01
                end = theDay 2020 03 31
            summaryTitle Nothing Nothing (Just (Category "Groceries")) (Period begin end) `shouldBeLine` 
                "Summary (main file) category: Groceries from 01/01/2020 to 03/31/2020"

        it "show a header for a selection of categories and the period" $ do
            let begin = theDay 2020 01 01
                end = theDay 2020 03 31
            summaryTitle Nothing (Just "categs.csv") Nothing (Period begin end) `shouldBeLine` 
                "Summary (main file) for categories in the file: categs.csv from 01/01/2020 to 03/31/2020"
