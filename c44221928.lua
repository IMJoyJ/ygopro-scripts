--褒誉の息吹
-- 效果：
-- 风属性仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只风属性仪式怪兽仪式召唤。
function c44221928.initial_effect(c)
	-- 为卡片添加仪式召唤效果，要求仪式怪兽的等级等于解放怪兽的等级总和
	aux.AddRitualProcEqual2(c,c44221928.ritual_filter)
end
-- 仪式怪兽必须是风属性的仪式怪兽
function c44221928.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_WIND)
end
