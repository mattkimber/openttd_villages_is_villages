Villages Is Villages

This is a simple game script to apply population growth limits to towns in
order to prevent everything on the map growing to an enormous metropolis
that can only be served by express trains.

The town growth rules are changed as follows:

* Cities are limited in growth solely by the provision of transport service
  (although limits may be imposed by newGRF sets).
* All other towns have a maximum population to which they may grow. The town
  information window will show the growth potential of a town so you can
  decide what kind of transport service to provide.

You can configure the minimum amounts of mail and passengers to be transported
from the town before it can grow. This uses the town statistics on passengers/mail
last month compared to their maximum value. If the town can produce a maximum of
100 passengers and you configure 50% as the amount required, then 50 passengers must
have been transported in the previous month for the town to grow.

If there is a shortfall in the number of passengers or mail required to be
transported, it will be shown on the town information display.

== Growing Towns ==

If a town has hit its growth limit and you'd like it to be larger:

* "Fund New Buildings" will permanently increase the population limit to 20%
  above the town's current population for every month where new buildings are
  being funded and the town is already at its population limit.
