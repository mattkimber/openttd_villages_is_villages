require("towns.nut");
require("town.nut");
require("industries.nut");
require("industry.nut");
require("cargoes.nut");
require("cargo.nut");

import("util.superlib", "SuperLib", 39);
Helper <- SuperLib.Helper;

class VillagesIsVillages extends GSController
{
  data_loaded = false;
  towns = null;
  industries = null;
  cargoes = null;
  total_towns_processed = 0;

  constructor()
  {
    GSLog.Info("Starting Villages Is Villages...")
    cargoes = Cargoes();
  }
}

function VillagesIsVillages::Start()
{
  GSLog.Info("Villages Is Villages has started");

  if(!data_loaded)
  {
    GSLog.Info("Initialising towns");
    towns = Towns(cargoes);
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

  GSLog.Info("Number of towns: " + towns.Count());
  GSLog.Info("Number of industries: " + industries.Count());

  while (true) {
    this.Sleep(1);

    // GSLog.Info("Starting town processing loop on tick " + this.GetTick());

    local i = 0;

    local town_count = towns.Count();
    local end_town_processing_tick = this.GetTick() + 250;

    while(i < town_count && this.GetTick() < end_town_processing_tick)
    {
      towns.ProcessNextTown();
      i++;
    }

    this.total_towns_processed = total_towns_processed + i;
    // GSLog.Info("Processed " + i + " towns by tick " + this.GetTick());

    if(GSController.GetSetting("manage_industries"))
    {
      this.Sleep(1);
      industries.Process();
    }

    // GSLog.Info("All industries processed by tick " + this.GetTick());

    if(this.total_towns_processed >= town_count) {
      this.total_towns_processed = 0;
      // GSLog.Info("All towns have been processed - sleeping for 10 days");
      this.Sleep(10 * 74);
    }
    else
    {
      this.Sleep(1);
    }

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
    towns = Towns(cargoes);
    towns.InitialiseWithData(townData);

    GSLog.Info("Loaded town data from save file");

    data_loaded = true;
  }
}
