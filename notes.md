**MUSA 508 FINAL PROJECT NOTES**

**Project option 4 - Forecast Metro train delays in and around NYC:** An amazing new dataset has popped up on Kaggle recently that list origin/destinations delays for Amtrak and NJ Transit trains. Can you predict train delays? Consider the time frame that it would be useful to have such predictions. Predicting 5 minutes out is not going to be as useful as 2-3 hours out. Consider training on a month and predicting for the next week or two. Consider time/space (train line, county etc.) cross validation. Many app use cases here.

- _tentative time period:_ september 2019 as training data, first two weeks of oct 2019 as test data? (alt. use three sets - test, training, and validation?)

**data issues**

- at first glace, amtrak trains in at least sep 2019 have no scheduled time and NA values for `delay_minutes` and `stop_sequence`. look for more info in documentation? we could omit all amtrak trains and just look at nj transit, but what if amtrak train timing affects nj transit on-time performance? need to look into this more

**time**

- use lubridate as in ch. 8 to standardize time format and create features for e.g. day of week 
- how granular should we be? chapter used 15- and 60-minute time increments; is that meaningful here? (probably for `scheduled_time`? could experiment with different intervals?)
- _holidays:_ labor day in september; anything else?

**space**

- ch. 8 example used census tracts as units and calculated spatial lag that way
- train data arguably has two spatial aspects: the current station (and all trains passing through it), and the previous station on the same line. do we incorporate lag features for both? maybe test both alone and in combination?


**model**

- ch. 8 used linear regression; should we try something like random forest, or is that overkill? (probably start with linear regardless to have more to show at presentation)

**predictions**

- presumably, prediction field is `delay_minutes`