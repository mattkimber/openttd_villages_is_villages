Villages Is Villages

This is a simple game script to apply population growth limits to towns in
order to prevent everything on the map growing to an enormous metropolis
that can only be served by express trains.

The town growth rules are changed as follows:

* Cities can still grow without limit (other than that imposed by newGRF sets).
* All other towns have a maximum population to which they may grow. The town
  information window will show the growth potential of a town so you can
  decide what kind of transport service to provide.

== Growing Towns ==

If a town has hit its growth limit and you'd like it to be larger:

* "Fund New Buildings" will permanently increase the population limit to 20%
  above the town's current population for every month where new buildings are
  being funded and the town is already at its population limit.
