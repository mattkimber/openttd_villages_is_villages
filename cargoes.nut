class Cargoes
{
  handled_cargo = [];

  static cargo_defs = {
    BDMT = "growth_building_materials",
    GOOD = "growth_goods",
    BEER = "growth_alcohol",
    FOOD = "growth_food",
    PETR = "growth_petrol"
  }

  function GetHandledCargoes()
  {
    return this.handled_cargo;
  }

  constructor()
  {
    foreach(c, _ in GSCargoList())
    {
      local label = GSCargo.GetCargoLabel(c);

      if(Cargoes.cargo_defs.rawin(label))
      {
        this.handled_cargo.append(Cargo(c, Cargoes.cargo_defs[label]));
        GSLog.Info("Setting up cargo handling for " + label + " (cargo ID " + c + ")");
      }
    }
  }

}
