class Company 
{
    bank_bal_last_year = 0;
    loan_last_year = 0;
    id = -1;
    story_page_id = -1;

    current_dividend_rate = 0;

    constructor(id, bank_bal, loan, dividend_rate, story_page_id)
    {
        this.bank_bal_last_year = bank_bal;
        this.loan_last_year = loan;
        this.id = id;
        this.current_dividend_rate = dividend_rate;
        this.story_page_id = story_page_id
    }

    function UpdateCostBreakdown(text)
    {
        if(!GSStoryPage.IsValidStoryPage(this.story_page_id)) {
            this.story_page_id = GSStoryPage.New(this.id, "Cost Breakdown")
        }
        GSStoryPage.NewElement(this.story_page_id, GSStoryPage.SPET_TEXT, 0, text);
    }

    function GetSaveData()
    {
        return {
            bank_bal = this.bank_bal_last_year,
            loan = this.loan_last_year,
            dividend_rate = this.current_dividend_rate,
            id = this.id,
            story_page_id = this.story_page_id,
        };
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
            UpdateCostBreakdown(GSText(GSText.STR_COST_BREAKDOWN_TAX, tax));

        }
        else {
            UpdateCostBreakdown(GSText(GSText.STR_COST_BREAKDOWN_TAX, 0));

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
            this.current_dividend_rate -= GSController.GetSetting("dividend_growth");
            ShowCompanyNews(GSText(GSText.STR_NO_DIVIDEND, this.id));
            UpdateCostBreakdown(GSText(GSText.STR_COST_BREAKDOWN_DIVIDEND, 0, 0 ));
            return;
        }

        if(this.current_dividend_rate < GSController.GetSetting("dividend_start")) this.current_dividend_rate = GSController.GetSetting("dividend_start");

        local dividend = ((cash_balance - dividend_cash_floor) * this.current_dividend_rate) / 100;

        local effective_dividend_rate = (dividend * 100) / GSCompany.GetQuarterlyCompanyValue(this.id, GSCompany.CURRENT_QUARTER);
        GSCompany.ChangeBankBalance(this.id, -dividend, GSCompany.EXPENSES_OTHER);
        UpdateCostBreakdown(GSText(GSText.STR_COST_BREAKDOWN_DIVIDEND, effective_dividend_rate, dividend ));
        if(dividend > 0) ShowCompanyNews(GSText(GSText.STR_DIVIDEND, this.id, effective_dividend_rate, dividend));
        
        this.current_dividend_rate += GSController.GetSetting("dividend_growth");
        if(this.current_dividend_rate >= GSController.GetSetting("dividend_max")) this.current_dividend_rate = GSController.GetSetting("dividend_max");
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
        local year = GSDate.GetYear(GSDate.GetCurrentDate()) - 1

        UpdateCostBreakdown("________"+year+"________")
        ApplyTax();
        ApplyDividends();

        this.bank_bal_last_year = GSCompany.GetBankBalance(this.id);
    }

    function ApplyDividend()
    {

    }
}