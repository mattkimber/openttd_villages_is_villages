class Towns
{
  town_list = [];
  handled_towns = {};
  total_population = 0;
  current_town = 0;
  needs_data_setup = false;
  cargoes = null;
  town_data = {};
  town_data_cache = [];
  world_population = 0;
  baseline_world_population = 0;
  world_can_grow = false;
  max_population = 0;
  max_city_population = 0;

  constructor(cargo_class)
  {
    this.cargoes = cargo_class;
  }

  function Count()
  {
    return town_list.len();
  }

  function GetBaselinePopulation() {
    return this.baseline_world_population;
  }

  function EnableUnlimitedWorldGrowth() {
    this.world_can_grow = true;
  }

  function GetPopulation() {
    local population = 0;

    foreach(t in this.town_list) {
      population += t.GetCurrentPopulation()
    }

    return population;
  }

  function UpdateWorldPopulation(max_additional_population, max_city_population) 
  { 
    this.world_population = GetPopulation();

    if(this.baseline_world_population == 0 && GSDate.GetMonth(GSDate.GetCurrentDate()) >= 4) {
        // World population is quite unstable when starting a game,
        // give it plenty of time to settle down.
        this.world_population = GetPopulation();
       
        GSLog.Info("World population stabilised at " + this.world_population);
        this.baseline_world_population = this.world_population + (this.world_population / 20);

    }

    this.max_population = this.baseline_world_population + max_additional_population;
    // Cities have a "free" population allowance of 500
    this.max_city_population = max_city_population + 500;

    this.world_can_grow = this.baseline_world_population == 0 || this.world_population < this.max_population;

  }

  function SetTownData(townData, baseline_population) {
    // Need to do this to be able to load large game files
    // with many towns
    town_data = townData;
    this.baseline_world_population = baseline_population;
    GSLog.Info("Baseline population in save file: " + baseline_population);
    needs_data_setup = true;
  }

  function InitialiseFromData()
  {
    local i = 0;

    this.town_list = [];

    foreach(t in town_data)
    {
      i++;

      local town = Town(t.id, this.cargoes);
      town.InitialiseWithSize(t.max_population);
      this.town_list.append(town);
      this.handled_towns[t.id] <- true;
    }

    needs_data_setup = false;
    GSLog.Info("Number of towns managed: " + this.Count());
  }

  function GetTownList()
  {
    return this.town_list;
  }

  function AddTown(town_id)
  {
    if(town_id in this.handled_towns) return;

    local town = Town(town_id, this.cargoes);
    town.Initialise();
    this.town_list.append(town);
    this.handled_towns[town_id] <- true;
  }

  function ProcessNextTown()
  {
    if(this.needs_data_setup) {
      InitialiseFromData();
    }

    local town = this.town_list[current_town];
    town.Process(this.world_can_grow, this.max_population, this.max_city_population);

    current_town = (current_town + 1) % this.town_list.len();
  }

  function GetTownCache()
  {
    return this.town_data_cache;
  }

  function UpdateTownList()
  {
    local towns = GSTownList();

    foreach(t, _ in towns)
    {
      this.AddTown(t);
    }

    local townData = [];

    foreach(t in this.GetTownList())
    {
      townData.append({ id = t.GetId(), max_population = t.GetMaxPopulation() });
    }

    this.town_data_cache = townData;
  }
}
