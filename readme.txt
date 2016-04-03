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
from the town before it can grow. This uses the town statistics on
passengers/mail last month compared to their maximum value. If the town can
produce a maximum of 100 passengers and you configure 50% as the amount
required, then 50 passengers must have been transported in the previous month
for the town to grow.

If there is a shortfall in the number of passengers or mail required to be
transported, it will be shown on the town information display.

== Growing Towns ==

If a town has hit its growth limit and you'd like it to be larger:

* "Fund New Buildings" will permanently increase the population limit to 20%
  above the town's current population for every month where new buildings are
  being funded and the town is already at its population limit.

== Manage Industries ==

This is an experimental feature as it relies on manipulating a game setting
(the one specifying industry density) in order to control the opening of new
industries.

Manage Industries will prevent new industries from opening unless a certain
proportion of those already on the map have service. This prevents the situation
in long games where the map is completely dominated by industries, without the
restrictions of running the whole game in "funding only" mode.

There are two settings to tune the industry management behaviour:

* The percentage of cargo which must be transported from a producing industry
  in order for it to be considered "served"
* The percentage of industries on the map which must be served before new
  industries are constructed.

Industries which do not produce any output (either non-producing sink industries
or dormant factories) are considered served if there is a station within their
vicinity.

== Large Maps ==

If you have more than about 1000 towns on your map, it can take a few months
of game time for growth statistics to be updated - meaning towns may grow
when they shouldn't, or be unable to grow when they should be able to.

You can reduce the amount of time each town takes to process by setting the
required mail and/or passenger percentages to 0 - although the calculation
is not expensive, needing to change the town texts to display the shortfalls
is.

In addition, then setting "Show growth statistics in town window" will
provide a useful speed increase, particularly on the first run through towns
after a game is started or loaded.

Note that industry processing does not take a long time even if there are a
huge number of them on the map.
