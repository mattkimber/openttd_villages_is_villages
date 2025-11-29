class Economy 
{
    last_process_year = -1;
    last_process_month = -1;
    last_economy_date = -1;
    total_tax_paid = 0;
    total_dividends = 0;
    record_dividend = 0;
    tax_last_year = 0;

    companies_list = [];

    constructor(economy_data)
    {  
        if(economy_data == null) {
            this.last_process_year = -1;
            this.last_process_month = -1;
            for(local c = GSCompany.COMPANY_FIRST; c <= GSCompany.COMPANY_LAST; c++) {
                AppendCompany(c);       
            }
        } else {
            this.last_process_year = economy_data.tax_year;
            this.last_process_month = economy_data.infrastructure_month;
            if(economy_data.rawin("total_tax_paid")) {
                this.total_tax_paid = economy_data.total_tax_paid;
            }

            if(economy_data.rawin("total_dividends")) {       
                this.total_dividends = economy_data.total_dividends;
            }

            if(economy_data.rawin("record_dividend")) {
                this.record_dividend = economy_data.record_dividend;
            }

            if(economy_data.rawin("tax_last_year")) {
                this.tax_last_year = economy_data.tax_last_year;
            }

            foreach(company in economy_data.companies) 
            {
                if(!("dividend_rate" in company)) company.dividend_rate <- 0;
                if(!("current_story_page" in company)) company.current_story_page <- null;
                if(!("current_story_page_year" in company)) company.current_story_page_year <- null;
                this.companies_list.append(Company(company.id, company.bank_bal, company.loan, company.dividend_rate, company.current_story_page, company.current_story_page_year));
            }

        }
    }

    function AddCompany(id)
    {
        RemoveCompanyIfExists(id);
        AppendCompany(id);
    }

    function RemoveCompanyIfExists(id) 
    {
        for(local i = 0; i < this.companies_list.len(); i++) {
            if(this.companies_list[i].GetID() == id) {
                this.companies_list.remove(i);
            }
        }
    }

    function AppendCompany(id)
    {
        if(GSCompany.ResolveCompanyID(id) != GSCompany.COMPANY_INVALID) {
            local mode = GSCompanyMode(id);
            this.companies_list.append(Company(id, GSCompany.GetBankBalance(id),  GSCompany.GetLoanAmount(), 0, null, null));
        }
    }

    function GetTaxYear()
    {
        return last_process_year;
    }

    function GetSaveData()
    {
        local data = {};
        data.tax_year <- this.last_process_year;
        data.infrastructure_month <- this.last_process_month;
        data.companies <- [];
        data.total_tax_paid <- this.total_tax_paid;
        data.total_dividends <- this.total_dividends;
        data.record_dividend <- this.record_dividend;
        data.tax_last_year <- this.tax_last_year;

        foreach(company in this.companies_list) {
            data.companies.append(company.GetSaveData());
        }

        return data;
    }

    function ProcessMonthly()
    {
        if(GSDate.GetMonth(GSDate.GetCurrentDate()) == last_process_month) {
            return;
        }

        if(GSGameSettings.IsValid("infrastructure_maintenance") && GSGameSettings.GetValue("infrastructure_maintenance")) {
            ProcessInfrastructureCosts();
        }

        last_process_month = GSDate.GetMonth(GSDate.GetCurrentDate());
    }

    function ProcessInfrastructureCosts()
    {
        foreach(company in this.companies_list) {
            company.ApplyInfrastructureCost();
        }
    }

    function GetMaxAdditionalWorldPopulation() 
    {
        local population_per_tax =  GSController.GetSetting("population_per_tax");
        return population_per_tax * (this.total_tax_paid / 1000);
    }

    function GetMaxCityPopulation()
    {
        local population_per_dividend =  GSController.GetSetting("population_per_dividend");
        return (population_per_dividend / 100) * (this.total_dividends / 1000);
    }
    
    function ProcessTaxAndDividends(tax_year)
    {
        local tax = 0;
        local dividends = 0;

        foreach(company in this.companies_list) {
            company.ApplyTaxAndDividends(tax_year);

            local dividendBill = company.GetLastDividendBill();
            if(dividendBill > 0 && dividendBill > this.record_dividend) {
                company.ShowCompanyNews(GSText(GSText.STR_DIVIDEND, company.GetID(), dividendBill, company.GetLastDividendRate()));
                this.record_dividend = dividendBill;
            }

            tax += company.GetLastTaxBill();
            dividends += dividendBill;
        }

        // Calculate the rolling total for tax
        // Tax paid ramps up slowly over time (but can sustain a few bad years)
        this.total_tax_paid = ((this.total_tax_paid * 4) + tax) / 5;

        // Show news articles
        if ((this.tax_last_year / 100) > 0) {
            local tax_pc_change = tax / (this.tax_last_year / 100);

            if(tax_pc_change < 80) {
                local decrease = 100 - tax_pc_change;
                GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TAX_DOWN,decrease), GSCompany.COMPANY_INVALID, GSNews.NR_NONE, 0);
            } else if (tax_pc_change > 120) {
                local increase = tax_pc_change - 100;
                GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TAX_UP,increase), GSCompany.COMPANY_INVALID, GSNews.NR_NONE, 0);
            }
        }

        this.tax_last_year = tax;

        // The rolling dividend total is a lot more responsive
        this.total_dividends = (this.total_dividends + dividends) / 2;
    }

    function GetCurrentYear()
    {
        local economy_date = GSDate.GetCurrentDate();
        local economy_year = GSDate.GetYear(economy_date);
        local adjusted_economy_date = economy_date / 10;

        if(!GSController.GetSetting("attempt_to_get_real_economy_year")) {
            return economy_year - 1919;
        }

        if (adjusted_economy_date == last_economy_date && last_economy_date != -1) {
            return last_process_year;
        }

        // GSLog.Info("Economy year: " + economy_year);
        // GSLog.Info("Economy date: " + economy_date + " (adjusted: " + adjusted_economy_date + ")");

        last_economy_date = adjusted_economy_date;

        local new_page = GSStoryPage.New(GSCompany.COMPANY_INVALID, "");
        local calendar_date = GSStoryPage.GetDate(new_page);
        GSStoryPage.Remove(new_page);

        // We need to identify the date manually as GetDate() will assume an
        // economy date with no leap year
        local current_year = 0;
        local days_in_year = 0;


        // GSLog.Info("Calendar date " + calendar_date);

        // Reuced # of iterations required for post-1700 dates
        if(calendar_date >= 620913) {
            current_year = 1700;
            calendar_date = calendar_date - 620913;
        }

        while(true) {
            if(current_year % 4 == 0 && current_year % 100 != 0) {
                days_in_year = 366;
            } else {
                days_in_year = 365;
            }

            if(calendar_date < days_in_year) {
                break;
            }

            calendar_date = calendar_date - days_in_year;
            current_year++;
        }

        // GSLog.Info("Current year " + current_year);
        return current_year;
    }

    function ProcessAnnual()
    {
        local current_year = GetCurrentYear();

        if(current_year == last_process_year) {
            return;
        }

        ProcessTaxAndDividends(current_year);
        last_process_year = current_year;
    }

    function Process()
    {
        ProcessAnnual();
    }
}