require("towns.nut");
require("town.nut");
require("industries.nut");
require("industry.nut");
require("cargoes.nut");
require("cargo.nut");
require("economy.nut");
require("company.nut");

import("util.superlib", "SuperLib", 40);
Helper <- SuperLib.Helper;

class VillagesIsVillages extends GSController
{
  data_loaded = false;
  towns = null;
  industries = null;
  cargoes = null;
  economy = null;
  total_towns_processed = 0;

  constructor()
  {
    GSLog.Info("Starting Villages Is Villages...")
    this.cargoes = Cargoes();
  }
}

function VillagesIsVillages::Start()
{
  GSLog.Info("Villages Is Villages has started");

  if(!this.data_loaded)
  {
    GSLog.Info("Initialising towns");
    this.towns = Towns(cargoes);
    this.towns.UpdateTownList();

    // Start with no  previous tax year
    this.economy = Economy(null);
  }

  GSLog.Info("Number of towns managed: " + this.towns.Count());

  this.industries = Industries();

  if(GSController.GetSetting("manage_industries"))
  {
    if(!GSGameSettings.IsValid("difficulty.industry_density"))
    {
      GSLog.Error("Cannot manage industries - industry funding level setting not found");
      return;
    }
    this.industries.Initialise();
    GSLog.Info("Number of industries managed: " + this.industries.Count());
  }
  else
  {
    GSLog.Info("Not managing industries.")
  }

  local last_industry_process_tick = this.GetTick() - 750;
  local last_town_complete_tick = this.GetTick() - 750;


  while (true) {
    this.Sleep(1);
 
    if(GSController.GetSetting("manage_economy"))
    {
      this.economy.Process();
    }

    if(this.GetTick() > last_town_complete_tick + 740)
    {
      local i = 0;
      local town_count = towns.Count();
      local end_town_processing_tick = this.GetTick() + 70;

      while(i < town_count && this.GetTick() < end_town_processing_tick)
      {
        this.towns.ProcessNextTown();
        i++;
      }

      this.total_towns_processed = this.total_towns_processed + i;

      if(this.total_towns_processed >= town_count) {
        this.total_towns_processed = 0;
        this.towns.UpdateTownList();
        last_town_complete_tick = this.GetTick();
        this.Sleep(1);
      }
    }

    if(GSController.GetSetting("manage_industries") && this.GetTick() > last_industry_process_tick + 740)
    {
      this.Sleep(1);
      this.industries.Process();
      last_industry_process_tick = this.GetTick();
    }

    // Process any events which happened while we were sleeping
    while(GSEventController.IsEventWaiting())
    {
      local event = GSEventController.GetNextEvent();
      if(event != null)
      {
        if(event.GetEventType() == GSEvent.ET_TOWN_FOUNDED)
        {
          local townEvent = GSEventTownFounded.Convert(event);
          this.towns.AddTown(townEvent.GetTownID());
        }

        if(event.GetEventType() == GSEvent.ET_COMPANY_NEW)
        {
          local companyEvent = GSEventCompanyNew.Convert(event);
          this.economy.AddCompany(companyEvent.GetCompanyID());
        }

        if(event.GetEventType() == GSEvent.ET_COMPANY_MERGER)
        {
          local companyEvent = GSEventCompanyMerger.Convert(event);
          this.economy.RemoveCompanyIfExists(companyEvent.GetOldCompanyID());
        }

        if(event.GetEventType() == GSEvent.ET_COMPANY_BANKRUPT)
        {
          local companyEvent = GSEventCompanyBankrupt.Convert(event);
          this.economy.RemoveCompanyIfExists(companyEvent.GetCompanyID());
        }
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

  return { towns = townData, economy = economy.GetSaveData() };
}

function VillagesIsVillages::Load(version, data)
{
  local townData = [];

  if(data.rawin("economy")) {
    local economy_data = data.rawget("economy");
    this.economy = Economy(economy_data);
  } else {
    this.economy = Economy(null);
  }

  if(data.rawin("towns")) {
    townData = data.rawget("towns");

    this.towns = Towns(cargoes);
    towns.InitialiseWithData(townData);

    GSLog.Info("Loaded town data from save file");

    this.data_loaded = true;
  }
}
