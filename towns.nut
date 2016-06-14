class Towns
{
  town_list = [];
  handled_towns = {};
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
      this.handled_towns[t.id] <- true;
    }
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
    local town = this.town_list[current_town];
    town.Process();

    current_town = (current_town + 1) % this.town_list.len();
  }

  function UpdateTownList()
  {
    local towns = GSTownList();

    foreach(t, _ in towns)
    {
      this.AddTown(t);
    }
  }
}
