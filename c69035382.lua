--奈落との契約
-- 效果：
-- 暗属性仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只暗属性仪式怪兽仪式召唤。
function c69035382.initial_effect(c)
	-- 为卡片注册仪式召唤的效果，要求解放怪兽的等级合计等于仪式怪兽的等级，且仪式怪兽需满足过滤条件
	aux.AddRitualProcEqual2(c,c69035382.ritual_filter)
end
-- 过滤出属于仪式怪兽且属性为暗属性的卡片
function c69035382.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_DARK)
end
