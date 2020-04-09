class Company 
{
    bank_bal_last_year = 0;
    loan_last_year = 0;
    id = -1;

    constructor(id, bank_bal, loan)
    {
        this.bank_bal_last_year = bank_bal;
        this.loan_last_year = loan;
        this.id = id;
    }

    function GetSaveData()
    {
        return { bank_bal = this.bank_bal_last_year, loan = this.loan_last_year, id = this.id };
    }

    function GetID()
    {
        return this.id;
    }

    function GetLoan()
    {
        local mode = GSCompanyMode(id);
        return GSCompany.GetLoanAmount();
    }

    function ApplyInfrastructureCost()
    {
        if(GSCompany.ResolveCompanyID(this.id) == GSCompany.COMPANY_INVALID) {
            GSLog.Error("Attempt to resolve infrastructure costs for invalid company");
            return;
        }

        local infrastructure_cost = 
            GSInfrastructure.GetMonthlyInfrastructureCosts(this.id, GSInfrastructure.INFRASTRUCTURE_RAIL)
            + GSInfrastructure.GetMonthlyInfrastructureCosts(this.id, GSInfrastructure.INFRASTRUCTURE_SIGNALS)
            + GSInfrastructure.GetMonthlyInfrastructureCosts(this.id, GSInfrastructure.INFRASTRUCTURE_ROAD)
            + GSInfrastructure.GetMonthlyInfrastructureCosts(this.id, GSInfrastructure.INFRASTRUCTURE_CANAL)
            + GSInfrastructure.GetMonthlyInfrastructureCosts(this.id, GSInfrastructure.INFRASTRUCTURE_STATION)
            + GSInfrastructure.GetMonthlyInfrastructureCosts(this.id, GSInfrastructure.INFRASTRUCTURE_AIRPORT);

        local infrastructure_addon = pow(infrastructure_cost, GSController.GetSetting("infrastructure_cost_exponent").tofloat() / 100) - infrastructure_cost;

        //GSLog.Info("Company " + this.id + " infrastructure_cost: " + infrastructure_cost + " addon: " + infrastructure_addon);

        GSCompany.ChangeBankBalance(this.id, -infrastructure_addon.tointeger(), GSCompany.EXPENSES_PROPERTY);
    }

    function ApplyTaxAndDividends()
    {
        if(GSCompany.ResolveCompanyID(this.id) == GSCompany.COMPANY_INVALID) {
            GSLog.Error("Attempt to resolve tax/dividends for invalid company");
            return;
        }

        local bank_bal_this_year = GSCompany.GetBankBalance(this.id);
        local loan_this_year = this.GetLoan();

        local profit = (bank_bal_this_year - loan_this_year) - (bank_bal_last_year - loan_last_year);
        local tax = (profit * GSController.GetSetting("corp_tax_level")) / 100;

        if(tax > 0) {
            GSCompany.ChangeBankBalance(this.id, -tax, GSCompany.EXPENSES_OTHER);
        }
        // GSLog.Info("Profit for company " + this.id + ": " + profit);
        // GSLog.Info("Tax    for company " + this.id + ": " + tax);

        local two_year_costs = 0
            - GSCompany.GetQuarterlyExpenses(this.id, 1)
            - GSCompany.GetQuarterlyExpenses(this.id, 2)
            - GSCompany.GetQuarterlyExpenses(this.id, 3)
            - GSCompany.GetQuarterlyExpenses(this.id, 4)
            - GSCompany.GetQuarterlyExpenses(this.id, 5)
            - GSCompany.GetQuarterlyExpenses(this.id, 6)
            - GSCompany.GetQuarterlyExpenses(this.id, 7)
            - GSCompany.GetQuarterlyExpenses(this.id, 8);
        local max_loan = GSCompany.GetMaxLoanAmount();
        local dividend_base = max(0, bank_bal_this_year - two_year_costs - max_loan);
        local dividends = (dividend_base * GSController.GetSetting("dividend_level")) / 100;
        if(dividends > 0) {
            GSCompany.ChangeBankBalance(this.id, -dividends, GSCompany.EXPENSES_OTHER);
        }
        // GSLog.Info("Two year costs for company " + this.id + ": " + two_year_costs);
        // GSLog.Info("Max loan       for company " + this.id + ": " + max_loan);
        // GSLog.Info("Dividend base  for company " + this.id + ": " + dividend_base);
        // GSLog.Info("Dividends      for company " + this.id + ": " + dividends);

        this.bank_bal_last_year = GSCompany.GetBankBalance(this.id);
        this.loan_last_year = loan_this_year;
    }
}