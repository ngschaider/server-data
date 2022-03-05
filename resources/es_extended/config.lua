Config = {}
Config.Locale = 'de'

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

Config.StartingAccountMoney 	= {bank = 15000}

Config.PaycheckInterval         = 1000 * 60 * 60 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?