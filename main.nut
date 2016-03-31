require("towns.nut");
require("town.nut");

import("util.superlib", "SuperLib", 38);
Helper <- SuperLib.Helper;

class VillagesIsVillages extends GSController
{
  constructor()
  {
  }
}

function VillagesIsVillages::Start()
{
  GSLog.Info("Villages Is Villages started");

  local towns = Towns();

  while (true) {
    towns.Process();
    // 2100 ticks ~= 30 days
    this.Sleep(2100);
  }
}
