# ML workflow and evaluation

## Targets
| Target | Row | y | Key features |
|---|---|---|---|
| Attendance | date x meal | students attending | weekday (+one-hot), meal, month, holiday/event/exam/break flags, temperature, rain, menu appeal (mean preference score of the dishes), last same-weekday attendance (`lag1`), mean of last 4 (`roll4`) |
| Dish demand | date x meal x dish | grams taken per attending student = (served + shortage) / attendance | serving size, preference score, category, meal, weekday, weather, calendar flags, number of dishes in the meal, dish's recent mean (`hist10`) |

Demand uses *served + shortage* so a dish that ran out is not mistaken for low demand. Plate waste is not subtracted (it is food students took).

## Validation (no leakage)
1. Sort by date. The last 20% of dates is a **hold-out**, never used for selection.
2. On the earlier 80%, `TimeSeriesSplit(4)` (always train on the past, validate on the future) gives each candidate a CV-RMSE.
3. Candidates: **Historical average baseline** (mean by weekday x meal, or by dish), Linear Regression (standardised), Random Forest (200 trees), Gradient Boosting (250 stages).
4. The model with the lowest CV-RMSE is selected - the baseline wins if nothing beats it.
5. Reported MAE, RMSE, R², WAPE are measured on the hold-out with the model fitted on the training period only. The selected model is then refitted on all data for production.
6. Hold-out predictions are stored as `backtest` forecasts, giving the predicted-vs-actual charts/reports real out-of-sample content.

## Cold start / insufficient data
* < 60 usable rows -> baseline only, labelled in the UI.
* No history at all -> capacity-based prior (`MESSMIND_CAPACITY`).
* Real records < 60 -> models train on simulated data (labelled); >= 60 -> real data only.

## Results on the bundled simulated data (270 days, 148-dish menu; changes slightly with the run date)
| Target | Baseline | Linear | Random Forest | Gradient Boosting | Selected (by CV) |
|---|---|---|---|---|---|
| Attendance, hold-out MAE / RMSE | 40.5 / 53.5 | 29.7 / 38.8 | 25.0 / 33.2 | 23.5 / 29.9 | Gradient Boosting |
| Dish demand, hold-out WAPE | 5.5% | 5.6% | 5.7% | 5.7% | Linear Regression |

Attendance: all three models clearly beat the baseline. Dish demand: **no model meaningfully beats the dish-history baseline** (the selected model wins CV by a hair and is marginally worse on the hold-out) - an honest result, because in the simulator dish demand is mostly dish-specific. With real data this may differ.
**These numbers describe the simulator, not your mess.** Real accuracy must be re-measured after real records exist.

## Monitoring
Every training run is stored in `model_runs`; Forecast & Models shows the latest comparison and the live error of stored forecasts against recorded actuals.
