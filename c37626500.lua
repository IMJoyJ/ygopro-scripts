--精霊の祝福
-- 效果：
-- 光属性仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只光属性仪式怪兽仪式召唤。
function c37626500.initial_effect(c)
	-- 为卡片添加仪式召唤效果，要求仪式怪兽的等级等于解放怪兽的等级总和
	aux.AddRitualProcEqual2(c,c37626500.ritual_filter)
end
-- 仪式怪兽必须是光属性且属于仪式类型
function c37626500.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
