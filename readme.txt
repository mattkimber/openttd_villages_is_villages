Villages Is Villages
====================

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
* Delivering goods or food (plus building materials and alcohol if you are using
  FIRS) will increase the population limit in proportion to the amount
  delivered, up to a limit of 20% above the town's current population.
  By default, building materials have the largest impact, with food and alcohol
  having the least.

Cargo delivery is checked once per 90 days.

== Manage Industries ==

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

== Economic Settings ==

Economic settings are designed to increase difficulty for solo games, or
level the playing field in multiplayer by providing gameplay elements that
are harder for large and profitable companies to overcome.

The current settings available are:

* Corporation Tax applies a fixed rate of tax to the company's pre-tax
  profit for the previous year. When playing with this enabled you can
  expect a large tax bill every January! This significantly reduces the
  advantage for a player who leaves a profitable company running without
  continuing to invest in their network.
* Infrastructure Cost Modifier increases the amount by which infrastructure
  costs scale by, where 100 is no change, and 200 is the original cost 
  squared (which is a huge increase, and almost certainly impractical for
  gameplay). Values in the range 101 to 105 are recommended, where 105
  is equal to (original infrastructure cost) ^ 1.05. This setting can be used
  to increase the challenge of operating a large network, and encourages
  careful usage of the existing routes over creating new ones. It can 
  also be reduced below 100 for an easier game.

== Large Maps ==

If you have over 2000 towns on your map, it can take more than a month
of game time for growth statistics to be updated - meaning towns may grow
when they shouldn't, or be unable to grow when they should be able to. This
is most noticeable when first starting or loading a game, as Villages is
Villages caches results to improve subsequent runs through the town processing
loop.

You can reduce the amount of time each town takes to process by setting the
required mail and/or passenger percentages to 0 - although the calculation
is not expensive, needing to change the town texts to display the shortfalls
is.

In addition, then setting "Show growth statistics in town window" will
provide a useful speed increase, particularly on the first run through towns
after a game is started or loaded.

Note that industry processing does not take a long time even if there are a
huge number of them on the map.

== Credits ==

Code: Timberwolf

Translations: SilverSurferZzZ (ES)
