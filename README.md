# QuickestRoute

## Origin

It might seem old-fashioned, but I use my public library often. One service they provide is
free tickets to local events, such as the zoo, the symphony, and the herbarium. These
tickets cannot be reserved, however; one must travel to one of several branches.

## Value

This project uses Google's map-related APIs to provide the trip duration
to multiple destinations. This obviates
the need to open several browser tabs, enter the same starting location for each,
and check the results one-by-one.

## Todo

* A user may not want to enter the full address of a destination. Google's Place API  would allow a user to use shorthand, like "The New York Public Library". This will also yield such a location's `place_id`, which
can improve the accuracy of trip durations in Google's Directions API.
* This should be containerized to facilitate deployment with a service like Fly.io
* The front page should be updated to be the search page
* Generally the search and results pages should look better