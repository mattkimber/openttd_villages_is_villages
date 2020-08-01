class Towns
{
  town_list = [];
  handled_towns = {};
  current_town = 0;
  needs_data_setup = false;
  cargoes = null;
  town_data = {};
  town_data_cache = [];

  constructor(cargo_class)
  {
    this.cargoes = cargo_class;
  }

  function Count()
  {
    return town_list.len();
  }

  function SetTownData(townData) {
    // Need to do this to be able to load large game files
    // with many towns
    town_data = townData;
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
    town.Process();

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
