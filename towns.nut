class Towns
{
  town_list = [];
  current_town = 0;

  constructor()
  {
  }

  function InitialiseWithData(townData)
  {
    foreach(t in townData)
    {
      GSLog.Info("Loading town");
      local town = Town(t.id);
      town.InitialiseWithSize(t.max_population);
      town_list.append(town);
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
  }

  function AddTown(town_id)
  {
    local town = Town(town_id);
    town.Initialise();
    town_list.append(town);
  }

  function ProcessNextTown()
  {
    local town = town_list[current_town];
    town.Process();

    current_town = (current_town + 1) % town_list.len();
  }
}
