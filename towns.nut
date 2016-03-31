class Towns {
  townList = [];

  constructor()
  {
    Initialise();
  }

  function Initialise()
  {
    local towns = GSTownList();

    foreach(t, _ in towns)
    {
      if (!GSTown.IsCity(t))
      {
        GSLog.Info("Found town");
        townList.append(Town(t));
      }
      else
      {
        GSLog.Info("Found city");
        GSTown.SetText(t, GSText(GSText.STR_CITY_NO_POP_LIMIT));
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
