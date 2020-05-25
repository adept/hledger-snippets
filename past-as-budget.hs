{-| Construct two balance reports for two different time periods and use one of the as "budget" for
    the other, thus comparing them
-}  
import Hledger.Cli
import Data.Default

main :: IO ()
main = do
  d <- getCurrentDay
  Right j2019 <- readJournalFile definputopts  "2019.journal"
  Right j2020 <- readJournalFile definputopts  "2020.journal"
  let o2019 = def{query_="expenses",average_=True,row_total_=True,period_=MonthPeriod 2019 4}
  let o2020 = def{query_="expenses",average_=True,row_total_=True,period_=MonthPeriod 2020 4}
  let y2019report = multiBalanceReport d o2019 j2019
  let y2020report = multiBalanceReport d o2020 j2020

  let pastAsBudget = combineBudgetAndActual y2019report{prDates=prDates y2020report} y2020report 
  putStrLn $ budgetReportAsText def pastAsBudget
