require("towns.nut");
require("town.nut");

import("util.superlib", "SuperLib", 38);
Helper <- SuperLib.Helper;

class VillagesIsVillages extends GSController
{
  data_loaded = false;
  towns = [];

  constructor()
  {
  }
}

function VillagesIsVillages::Start()
{
  GSLog.Info("Villages Is Villages started");

  if(!data_loaded)
  {
    towns = Towns();
    towns.Initialise();
  }

  while (true) {
    towns.Process();
    // 2100 ticks ~= 30 days
    this.Sleep(2100);
  }
}

function VillagesIsVillages::Save()
{
  local townData = [];

  foreach(t in towns.GetTownList())
  {
    townData.append({ id = t.GetId(), max_population = t.GetMaxPopulation() });
  }

  GSLog.Info("Saved town data");

  return { towns = townData };
}

function VillagesIsVillages::Load(version, data)
{
  local townData = [];

  if(data.rawin("towns")) {
    townData = data.rawget("towns");
    towns = Towns();
    towns.InitialiseWithData(townData);

    GSLog.Info("Loaded town data");

    data_loaded = true;
  }
}
