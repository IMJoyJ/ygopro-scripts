--踊りによる誘発
-- 效果：
-- 「舞蹈战士」的降临必需。若不从场地和手卡把等级直到6以上的卡作为祭品，则「舞蹈战士」不能降临。
function c43417563.initial_effect(c)
	-- 为卡片c添加仪式召唤效果，允许以等级和超过4849037号怪兽为素材进行仪式召唤
	aux.AddRitualProcGreaterCode(c,4849037)
end
