{-| Construct two balance reports for two different time periods and render them side by side
-}  
import Hledger.Cli
import Data.Default
import qualified Data.Map as M
import Data.Map.Merge.Strict

appendReports :: MultiBalanceReport -> MultiBalanceReport -> MultiBalanceReport
appendReports r1 r2 =
  PeriodicReport
  { prDates = prDates r1 ++ prDates r2
  , prRows = map snd $ M.toAscList mergedRows 
  , prTotals = mergeRows (prTotals r1) (prTotals r2)
  }
  where
    rowsByAcct report = M.fromList $ map (\r -> (prrName r, r)) (prRows report)
    r1map = rowsByAcct r1
    r2map = rowsByAcct r2
    
    mergedRows = merge (mapMissing left) (mapMissing right) (zipWithMatched both) r1map r2map
    left _ row = row{prrAmounts = prrAmounts row ++ [nullmixedamt]}
    right _ row = row{prrAmounts = nullmixedamt:(prrAmounts row) }
    both _ = mergeRows

    -- name/depth in the second row would be the same by contruction
    mergeRows (PeriodicReportRow name depth amt1 tot1 avg1) (PeriodicReportRow _ _ amt2 tot2 avg2) =
      PeriodicReportRow { prrName = name
        , prrDepth = depth
        , prrAmounts = amt1++amt2
        , prrTotal = tot1+tot2
        , prrAverage = averageMixedAmounts [avg1,avg2]
        }

main :: IO ()
main = do
  d <- getCurrentDay
  Right j2019 <- readJournalFile definputopts  "2019.journal"
  Right j2020 <- readJournalFile definputopts  "2020.journal"
  let o2019 = def{query_="expenses",average_=True,row_total_=True,period_=MonthPeriod 2019 4}
  let o2020 = def{query_="expenses",average_=True,row_total_=True,period_=MonthPeriod 2020 4}
  let y2019report = multiBalanceReport d o2019 j2019
  let y2020report = multiBalanceReport d o2020 j2020
  let merged = appendReports y2019report y2020report
  --putStrLn $ multiBalanceReportAsText o2019 y2019report
  --putStrLn $ multiBalanceReportAsText o2020 y2020report
  putStrLn $ multiBalanceReportAsText def{average_=True,row_total_=True} merged
