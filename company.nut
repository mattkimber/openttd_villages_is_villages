class Company 
{
    bank_bal_last_year = 0;
    loan_last_year = 0;
    id = -1;

    last_tax_bill = 0;
    last_dividend_bill = 0;
    last_dividend_rate = 0;

    current_dividend_rate = 0;

    current_story_page = null;
    current_story_page_year = null;

    constructor(id, bank_bal, loan, dividend_rate, current_story_page, current_story_page_year)
    {
        this.bank_bal_last_year = bank_bal;
        this.loan_last_year = loan;
        this.id = id;
        this.current_dividend_rate = dividend_rate;
        this.current_story_page = current_story_page,
        this.current_story_page_year = current_story_page_year
    }

    function GetSaveData()
    {
        return { 
            bank_bal = this.bank_bal_last_year, 
            loan = this.loan_last_year, 
            dividend_rate = this.current_dividend_rate, 
            id = this.id 
            current_story_page = this.current_story_page,
            current_story_page_year = this.current_story_page_year
        };
    }

    function GetLastTaxBill()
    {
        return this.last_tax_bill;
    }

    function GetLastDividendBill()
    {
        return this.last_dividend_bill;
    }

        function GetLastDividendRate()
    {
        return this.last_dividend_rate;
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

        GSCompany.ChangeBankBalance(this.id, -infrastructure_addon.tointeger(), GSCompany.EXPENSES_PROPERTY);
    }

    function ApplyTax()
    {
        local bank_bal_this_year = GSCompany.GetBankBalance(this.id);
        local loan_this_year = this.GetLoan();

        local profit = (bank_bal_this_year - loan_this_year) - (bank_bal_last_year - loan_last_year);
        local tax = (profit * GSController.GetSetting("corp_tax_level")) / 100;

        if(tax > 0) {
            GSCompany.ChangeBankBalance(this.id, -tax, GSCompany.EXPENSES_OTHER);
            this.last_tax_bill = tax;
        } else {
            this.last_tax_bill = 0;
        }

        this.loan_last_year = loan_this_year;
    }

    function ApplyDividends()
    {
        if(GSController.GetSetting("dividend_max") == 0) return;

        local total_expenses = 0;
        local cash_balance = GSCompany.GetBankBalance(this.id) - this.GetLoan();
        
        for(local i = GSCompany.CURRENT_QUARTER + 1; i <= GSCompany.CURRENT_QUARTER + 4; i++) {
            if(i <= GSCompany.EARLIEST_QUARTER) {
                total_expenses -= GSCompany.GetQuarterlyExpenses(this.id, i);
            }
        }
        
        local dividend_cash_floor = GSController.GetSetting("dividend_floor") + (total_expenses * GSController.GetSetting("dividend_costs_years"));

        if(cash_balance < dividend_cash_floor) {
            this.last_dividend_bill = 0;
            this.last_dividend_rate = 0;
            this.current_dividend_rate -= GSController.GetSetting("dividend_growth");
            return;
        }

        if(this.current_dividend_rate < GSController.GetSetting("dividend_start")) this.current_dividend_rate = GSController.GetSetting("dividend_start");

        local dividend = ((cash_balance - dividend_cash_floor) * this.current_dividend_rate) / 100;

        local effective_dividend_rate = (dividend * 100) / GSCompany.GetQuarterlyCompanyValue(this.id, GSCompany.CURRENT_QUARTER);
        this.last_dividend_rate = effective_dividend_rate;

        GSCompany.ChangeBankBalance(this.id, -dividend, GSCompany.EXPENSES_OTHER);
        if(dividend > 0) {
            this.last_dividend_bill = dividend;
            this.GrowCompanyHomeTown(dividend);
        } else {
            this.last_dividend_bill = 0;
        }

        this.current_dividend_rate += GSController.GetSetting("dividend_growth");
        if(this.current_dividend_rate >= GSController.GetSetting("dividend_max")) this.current_dividend_rate = GSController.GetSetting("dividend_max");
    }

    function GrowCompanyHomeTown(dividend) {

        local houses_per_dividend =  GSController.GetSetting("houses_per_dividend");
        local houses = (((houses_per_dividend) * (dividend / 100000)) / 10);

        if (houses <= 0)
        {
            return;
        }

        // Find the company's HQ
        local hq_location = GSCompany.GetCompanyHQ(this.id);
        if(hq_location != GSMap.TILE_INVALID) {
            local town = GSTile.GetClosestTown(hq_location);
            GSTown.ExpandTown(town, houses);
        }
    }

    function ShowCompanyNews(text)
    {
        if(GSCompany.GetCompanyHQ(this.id) != GSMap.TILE_INVALID) {
            GSNews.Create(GSNews.NT_GENERAL, text, GSCompany.COMPANY_INVALID, GSNews.NR_TILE, GSCompany.GetCompanyHQ(this.id));
        } else {
            GSNews.Create(GSNews.NT_GENERAL, text, GSCompany.COMPANY_INVALID, GSNews.NR_NONE, 0);
        }
    }

    function ApplyTaxAndDividends()
    {
        if(GSCompany.ResolveCompanyID(this.id) == GSCompany.COMPANY_INVALID) {
            GSLog.Error("Attempt to resolve tax for invalid company");
            return;
        }

        ApplyTax();
        ApplyDividends();
        AddCompanyNewsPage();

        this.bank_bal_last_year = GSCompany.GetBankBalance(this.id);
    }

    function AddCompanyNewsPage()
    {
        local tax_year = GSDate.GetYear(GSDate.GetCurrentDate()) - 1;

        if(this.current_story_page == null || this.current_story_page_year  == null || tax_year > this.current_story_page_year + 9) {
            this.current_story_page_year = tax_year; 
            this.current_story_page = GSStoryPage.New(
                this.id, 
                GSText(GSText.STR_HISTORICAL_FINANCES,this.current_story_page_year,this.current_story_page_year+9));
        }


        GSStoryPage.NewElement(
            this.current_story_page, 
            GSStoryPage.SPET_TEXT, 
            0, 
            GSText(GSText.STR_HISTORY, tax_year, this.last_tax_bill, this.last_dividend_bill, this.last_dividend_rate ));
    }

}