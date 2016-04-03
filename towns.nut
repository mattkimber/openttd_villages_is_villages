class Towns
{
  town_list = [];
  current_town = 0;
  cargoes = null;

  constructor(cargo_class)
  {
    this.cargoes = cargo_class;
  }

  function Count()
  {
    return town_list.len();
  }

  function InitialiseWithData(townData)
  {
    foreach(t in townData)
    {
      local town = Town(t.id, this.cargoes);
      town.InitialiseWithSize(t.max_population);
      this.town_list.append(town);
    }
  }

  function GetTownList()
  {
    return this.town_list;
  }

  function Initialise()
  {
    local towns = GSTownList();

    foreach(t, _ in towns)
    {
      this.AddTown(t);
    }

    // GSLog.Info("Added " + town_list.len() + " towns.");
  }

  function AddTown(town_id)
  {
    local town = Town(town_id, this.cargoes);
    town.Initialise();
    this.town_list.append(town);
  }

  function ProcessNextTown()
  {
    local town = this.town_list[current_town];
    town.Process();

    current_town = (current_town + 1) % this.town_list.len();
  }
}
