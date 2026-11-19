# Testing documentation

## Automated (`cd backend && pytest -q`)
| Test | Verifies |
|---|---|
| seed is labelled simulated | all generated rows flagged; banner warning present |
| weekly menu complete and flagged | 7 days x 4 meals; unclear names flagged `needs_confirmation` |
| real timetable loaded | transcribed dishes present, unclear ones flagged, no recipe invented for "One Sachet" |
| only vegetarian dishes | meat/egg/fish names rejected |
| model comparison | baseline + 3 models, finite metrics, exactly one selected, selected CV-RMSE <= baseline |
| hold-out chronology | back-test forecasts exist for the later period |
| planner | attendance override and buffer applied; doubling attendance doubles quantities; ingredients vs stock |
| unconfirmed dishes warned | planner warns about unverified menu items |
| record validation | served+leftover > prepared, plate waste > served, discard > leftover, future date, negatives all rejected |
| record saving | leftover and plate waste stored separately; stock reduced once; re-save does not double-deduct |
| waste separation | no merged "total waste" figure |
| feedback | does not create attendance; HTML stripped; one rating per dish per day |
| menu CSV import | unknown dish flagged, invalid day/meat rejected, import is atomic |
| dish archive | dishes with history are archived, not deleted |
| reports | daily/weekly/monthly build; PDF and XLSX valid; invalid period rejected |
| purge | removing simulated data falls back to a capacity prior |
| API tests (`test_api.py`) | 401/403 matrix for all four roles, students cannot write production data, validation errors (422), registration, export endpoints |

## Manual end-to-end checklist
1. Sign in as each demo role; confirm sidebar differs; student can open only Menu and Feedback.
2. Dashboard: banner shows simulated data; charts render; alerts list a Paneer shortage (demo stock is deliberately low).
3. Menu: add/remove a dish in a slot, create a dish with recipe, set a special-day menu and revert it, import a CSV (try one with a bad day -> nothing changes).
4. Planner: change attendance, buffer, weather, tick "Exam period" -> quantities update; "what-if active" badge appears.
5. Food Waste -> Enter record: try served > prepared (blocked), then a valid record; Inventory stock drops; record appears in Recent records.
6. Inventory: restock, edit, add/delete an ingredient.
7. Feedback as student: submit; submit again same dish (rejected).
8. Reports: preview daily/weekly/monthly; download PDF and Excel.
9. Forecast & Models: retrain; comparison table updates; warning about simulated metrics is shown.
10. Admin: create a user, change role, remove simulated data -> app falls back to prior/baseline and says so.

## Note on how this was verified when generated
Database, ML, services, report export and the endpoint functions were executed against a seeded database (16 service tests pass). The React code was syntax-checked but `npm install/build` and live HTTP tests (`test_api.py`) could not be run in the generation sandbox (no internet) - run them once locally before presenting.
