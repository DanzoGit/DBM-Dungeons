if GetLocale() ~= "ruRU" then return end
local L

-----------------------
-- <<<Auchindoun>>> --
-----------------------
-----------------------
-- Protector of Auchindoun --
-----------------------
L= DBM:GetModLocalization(1185)

-----------------------
-- Soulbinder Nyami --
-----------------------
L= DBM:GetModLocalization(1186)

-----------------------
-- Azzakel, Vanguard of the Legion --
-----------------------
L= DBM:GetModLocalization(1216)

-----------------------
-- Teron'gor --
-----------------------
L= DBM:GetModLocalization(1225)

-------------
--  Auch Trash  --
-------------
L = DBM:GetModLocalization("AuchTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Аукиндон"
})

-----------------------
-- <<<Bloodmaul Slag Mines>>> --
-----------------------
-----------------------
-- Magmolatus --
-----------------------
L= DBM:GetModLocalization(893)

-----------------------
-- Slave Watcher Crushto --
-----------------------
L= DBM:GetModLocalization(888)

-----------------------
-- Roltall --
-----------------------
L= DBM:GetModLocalization(887)

-----------------------
-- Gug'rokk --
-----------------------
L= DBM:GetModLocalization(889)

-------------
--  BSM Trash  --
-------------
L = DBM:GetModLocalization("BSMTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Шлаковые шахты Кровавого Молота"
})

-----------------------
-- <<<Grimrail Depot>>> --
-----------------------
-----------------------
-- Railmaster Rocketspark and Borka the Brute --
-----------------------
L= DBM:GetModLocalization(1138)

-----------------------
-- Blackrock Assault Commander --
-----------------------
L= DBM:GetModLocalization(1163)

L:SetWarningLocalization({
	warnGrenadeDown			= "%s выпали",
	warnMortarDown			= "%s выпали"
})

-----------------------
-- Thunderlord General --
-----------------------
L= DBM:GetModLocalization(1133)

L:SetMiscLocalization({
	Rakun	= "Ракун"
})

-------------
--  GRD Trash  --
-------------
L = DBM:GetModLocalization("GRDTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Депо Мрачных Путей"
})

-----------------------
-- <<<Iron Docks>>> --
-----------------------
---------------------
-- Fleshrender Nok'gar --
---------------------
L= DBM:GetModLocalization(1235)

-------------
-- Grimrail Enforcers --
-------------
L= DBM:GetModLocalization(1236)

-----------------------
-- Oshir --
-----------------------
L= DBM:GetModLocalization(1237)

-----------------------------
-- Skulloc, Son of Gruul --
-----------------------------
L= DBM:GetModLocalization(1238)

-----------------------
-- <<<Overgrown Outpost>>> --
-----------------------
-----------------------
-- Witherbark --
-----------------------
L= DBM:GetModLocalization(1214)

-----------------------
-- Ancient Protectors --
-----------------------
L= DBM:GetModLocalization(1207)

-----------------------
-- Archmage Sol --
-----------------------
L= DBM:GetModLocalization(1208)

-----------------------
-- Xeri'tac --
-----------------------
L= DBM:GetModLocalization(1209)

L:SetMiscLocalization({
	Pull	= "Зери'так выпускает на вас ядовитых паучков!"
})

-----------------------
-- Yalnu --
-----------------------
L= DBM:GetModLocalization(1210)

-----------------------
-- Trash --
-----------------------
L = DBM:GetModLocalization("EverBloomTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Вечное Цветение"
})

-----------------------
-- <<<Shadowmoon Buriel Grounds>>> --
-----------------------
-----------------------
-- Sadana Bloodfury --
-----------------------
L= DBM:GetModLocalization(1139)

-----------------------
-- Nhallish, Feaster of Souls --
-----------------------
L= DBM:GetModLocalization(1168)

-----------------------
-- Bonemaw --
-----------------------
L= DBM:GetModLocalization(1140)

-----------------------
-- Ner'zhul --
-----------------------
L= DBM:GetModLocalization(1160)

-------------
--  SMBG Trash  --
-------------
L = DBM:GetModLocalization("SMBGTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Некрополь Призрачной Луны"
})

-----------------------
-- <<<Skyreach>>> --
-----------------------
-----------------------
-- Ranjit, Master of the Four Winds --
-----------------------
L= DBM:GetModLocalization(965)

-----------------------
-- Araknath --
-----------------------
L= DBM:GetModLocalization(966)

-----------------------
-- Rukhran --
-----------------------
L= DBM:GetModLocalization(967)

-----------------------
-- High Sage Viryx --
-----------------------
L= DBM:GetModLocalization(968)

L:SetWarningLocalization({
	warnAdd			= DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.spell:format("Голем-защитник Небесного Пути"),
	specWarnAdd		= DBM_CORE_L.AUTO_SPEC_WARN_TEXTS.switch:format("Голем-защитник Небесного Пути")
})

L:SetOptionLocalization({
	warnAdd			= "Показать предупреждение для Голем-защитник Небесного Пути",
	specWarnAdd		= "Показать спецпредупреждение о переключении целей для Голем-защитник Небесного Пути"
})

-------------
--  Skyreach Trash  --
-------------
L = DBM:GetModLocalization("SkyreachTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Небесный путь"
})

-----------------------
-- <<<Upper Blackrock Spire>>> --
-----------------------
-----------------------
-- Orebender Gor'ashan --
-----------------------
L= DBM:GetModLocalization(1226)

-----------------------
-- Kyrak --
-----------------------
L= DBM:GetModLocalization(1227)

-----------------------
-- Commander Tharbek --
-----------------------
L= DBM:GetModLocalization(1228)

-----------------------
-- Ragewind the Untamed --
-----------------------
L= DBM:GetModLocalization(1229)

-----------------------
-- Warlord Zaela --
-----------------------
L= DBM:GetModLocalization(1234)

L:SetTimerLocalization({
	timerZaelaReturns	= "Зела возвращается"
})

L:SetOptionLocalization({
	timerZaelaReturns	= "Отсчет времени до возвращения Зелы"
})

-------------
--  UBRS Trash  --
-------------
L = DBM:GetModLocalization("UBRSTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Верхняя часть пика Черной горы"
})
