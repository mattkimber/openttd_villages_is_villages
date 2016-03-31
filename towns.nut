class Towns {
  townList = [];

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
      townList.append(town);
    }
  }

  function GetTownList()
  {
    return this.townList;
  }

  function Initialise()
  {
    local towns = GSTownList();

    foreach(t, _ in towns)
    {
      if (!GSTown.IsCity(t))
      {
        GSLog.Info("Found town");
        local town = Town(t);
        town.Initialise();
        townList.append(town);
      }
      else
      {
        GSLog.Info("Found city");
      }
    }
  }

  function AddTown()
  {

  }

  function Process()
  {
    foreach(town in townList)
    {
      town.Process();
    }
  }
}
