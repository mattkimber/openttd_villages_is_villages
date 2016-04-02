require("towns.nut");
require("town.nut");
require("industries.nut");
require("industry.nut");

import("util.superlib", "SuperLib", 38);
Helper <- SuperLib.Helper;

class VillagesIsVillages extends GSController
{
  data_loaded = false;
  towns = [];
  industries = [];

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

  industries = Industries();

  if(GSController.GetSetting("manage_industries"))
  {
    if(!GSGameSettings.IsValid("difficulty.industry_density"))
    {
      GSLog.Error("Cannot manage industries - industry funding level setting not found");
      return;
    }
    industries.Initialise();
  }

  while (true) {
    this.Sleep(1);

    local town_count = towns.Count();
    local industry_count = industries.Count();
    local i = 0;

    // We will loop the entire map approximately once per 15 days if there
    // are sufficient opcodes (2 x 1 tick sleeps between iterations)
    while(i < town_count / 500 && i < industry_count / 500 && i < 1 && this.GetOpsTillSuspend() > 500)
    {
      towns.ProcessNextTown();
      industries.ProcessNextIndustry();
      i++;
    }

    this.Sleep(1);

    // Process any events which happened while we were sleeping
    while(GSEventController.IsEventWaiting())
    {
      local event = GSEventController.GetNextEvent();
      if(event != null && event.GetEventType() == GSEvent.ET_TOWN_FOUNDED)
      {
        local townEvent = GSEventTownFounded.Convert(event);
        GSLog.Info("New town founded");
        towns.AddTown(townEvent.GetTownID());
      }
    }
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
