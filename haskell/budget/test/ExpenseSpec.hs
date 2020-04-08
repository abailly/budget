
module ExpenseSpec
    where
import Test.Hspec
import Amount
import Category
import Expense
import Data.List

spec = do
    describe "Expense" $ do
        it "has a date, category and amount" $ do
            let exp = Expense (mkDate 2020 4 5) (Category "Training") (mkAmount 48.07)
            date exp `shouldBe` (mkDate 2020 4 5)
            category exp `shouldBe` (Category "Training")
            amount exp `shouldBe` (mkAmount 48.07)

    describe "a list of Expenses" $ do
        it "can be totaled" $ do
            let exps = [Expense (mkDate 2020 4 5) (Category "Training") (mkAmount 48.07)
                       ,Expense (mkDate 2020 4 7) (Category "Food") (mkAmount 42.17)  
                       ,Expense (mkDate 2020 4 9) (Category "Business Expenses") (mkAmount 1000.00)]
            totalExpenses exps `shouldBe` mkAmount 1090.24

        describe "can have an average" $ do
            it "for a period of one months" $ do
                let exps = [Expense (mkDate 2020 4 5) (Category "Training") (mkAmount 48.07)
                           ,Expense (mkDate 2020 4 7) (Category "Training") (mkAmount 42.17)  
                           ,Expense (mkDate 2020 4 9) (Category "Training") (mkAmount 1000.00)]
                averageExpenses exps `shouldBe` mkAmount 1090.24
            it "for a two month period " $ do
                let exps = [Expense (mkDate 2020 1 1) (Category "Training") (mkAmount 48.07)
                           ,Expense (mkDate 2020 2 7) (Category "Training") (mkAmount 42.17)  
                           ,Expense (mkDate 2020 2 1) (Category "Training") (mkAmount 2000.00)]
                show (averageExpenses exps) `shouldBe` "1045.12"

        it "can determine a period" $ do
            let exps = [Expense (mkDate 2020 4 31) (Category "Training") (mkAmount 48.07)
                       ,Expense (mkDate 2020 4 7) (Category "Training") (mkAmount 42.17)  
                       ,Expense (mkDate 2020 3 4) (Category "Training") (mkAmount 1000.00)]
            expensesPeriod exps `shouldBe` (mkDate 2020 3 4, mkDate 2020 4 31)


                        