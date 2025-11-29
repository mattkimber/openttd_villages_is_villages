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
* Dividends discourage hoarding large cash surpluses by forcing companies to
  issue a dividend. (Note: you will currently not receive dividends from
  companies you own shares in - this may change in future depending on game
  balance).
* Tax and dividend modifiers on population.

== Dividends ==

Dividends work on a principle of avoiding large cash surpluses. When a
company has built up enough money to pay for a few years of its expenses
it will start to pay its surplus cash in the form of dividends, which will
increase for each year the company operates a large cash surplus.

There are several configuration values which can be used:

* Maximum base cash surplus can be considered a "float" that any company
  is allowed regardless of its operating expenses. This avoids the mechanic
  affecting small companies with low costs that are trying to build up money
  for a construction project. It's a good idea to set this to a reasonable
  value for building 1-2 new routes, depending on construction and vehicle
  costs.
* Years of costs to reserve is how many years basic expenses (vehicle running
  costs and infrastructure maintenance) the company should keep in hand before
  it is considered to have a cash surplus. This is combined with the float to
  get a total cash amount below which dividends will not be paid.

When the company is considered to have a surplus, dividends will be paid.
These will be a percentage of the available surplus, which will increase
each year the surplus is maintained (and decrease when the company is
not running a surplus). This is controlled by three settings:

* Initial % is the amount which will be paid the first time a company
  becomes eligible to pay dividends, and the minimum amount.
* Change per year is the amount dividends will increase or decrease
  by in a year.
* Maximum % is the maximum amount of surplus cash a dividend can take.

To disable the dividend mechanic, set the maximum % to 0. If the maximum
% is equal to or less than the initial %, then the initial value will always
be used and dividend amounts will not change.

When dividends are enabled a news article will be generated showing the status
of each company's dividend every January: whether it is paying one and how much 
that is. Note that the quoted % is in relation to the total company value and
not that of the surplus cash pile, so it will not match the configured percentages
(typically being much lower for a large and valuable company).

You can set dividend percentages above 100% if desired, to severely punish
holding cash surpluses. Use with care as this can bankrupt companies if set to
sufficiently high values.

== Taxation, Dividends and Population ==

[Applies when "Economic settings" are set to "on"]

Local authorities require income from taxation to provide services and support
local businesses. Cities require stock market profits or a successful local
company to grow.

Villages Is Villages assumes that when you generate a world, it is already
self-sufficient with a little room for growth (we're not that evil). However 
to grow larger it will need to generate taxes from economic activity. As 
your company and competitors pay larger amounts of corporation tax, the 
maximum world population at which towns can still grow increases.

Beware, though! If tax receipts fall over a long enough period, town growth
will stall. You'll see a reminder of this on the town window. To help your
towns become bustling metropolises, either make more profit or increase the
rate of corporation tax in the script settings. There's also a setting to
change the population limit increase per 1,000 tax paid if you want an
easier (or harder) time growing towns.

Changes in tax receipts don't affect growth instantly; it takes time for
local authorities to make their investment plans. This works both ways, so
while it takes a while to see the positive results from your record tax bills
you can also have a bad year or two without housebuilding coming to a halt.

Cities are not affected by this limit - they grow based on dividend income.
To start growing cities, you'll need to build your company's cash reserves
up to the point you start paying dividends. Bigger dividends mean larger
cities, but if they shrink so will the cities. Unlike tax the cities react
much faster to changes in dividend income, and it only takes a couple of
bad years for the skyscrapers to stop going up.

Note that while cities are not affected by the tax-influenced world population
limit, their population still counts toward it. If you pay large dividends 
while minimising your tax bill, vibrant cities will be offset by moribund 
towns.

Finally, the town closest to your HQ will benefit from *immediate* growth
when your company pays a large enough dividend. Think of it as a mini-boom
from all those employee bonuses being spent locally. While good early on,
this can be a hindrance if your erstwhile home village has become a concrete
jungle full of overloaded trains and wheezing buses. You may need to block 
further expansion... or perhaps relocate your HQ to provide an economic
stimulus for a neglected backwater?

== Attempt to get real economy year ==

This is an experimental setting which tries to align tax and dividends to
the calendar rather than OpenTTD's internal economy time.

As there is no officially supported way to get the calendar time from a
game script, this has a high risk of breaking or not working as expected.

Note that dividend calculations will still use economic quarters, so you
may need to adjust this setting for divdends to be taken as expected.

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

Translations: SilverSurferZzZ (ES), BolfriPL (PL)
