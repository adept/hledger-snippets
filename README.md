# hledger-snippets

Collection of small Haskell snippets that use hledger-lib

* `combine-balance-reports.hs` : allows you to put two balance reports side by side.
  For example, you can see how day/week/month/quarter from this year looks vs the
  same period from the previous year

* `past-as-budget.hs` : allows you to use one balance report as "budget numbers" for
  another balance report. For example, you can quicky see how your current expenses
  line up to past year's expenses (both in absolute numbers and percents).
