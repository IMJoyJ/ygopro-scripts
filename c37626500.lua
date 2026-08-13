--精霊の祝福
-- 效果：
-- 光属性仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只光属性仪式怪兽仪式召唤。
function c37626500.initial_effect(c)
	-- 为这张卡注册仪式召唤效果：进行光属性仪式怪兽的仪式召唤时，解放手卡·场上的怪兽，使解放的怪兽等级合计等于仪式召唤的怪兽的等级，然后从手卡将符合条件的仪式怪兽特殊召唤。
	aux.AddRitualProcEqual2(c,c37626500.ritual_filter)
end
-- 定义仪式召唤素材的过滤条件：仅选择光属性且为仪式怪兽的卡片作为可仪式召唤的对象。
function c37626500.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
