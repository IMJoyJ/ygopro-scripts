--褒誉の息吹
-- 效果：
-- 风属性仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只风属性仪式怪兽仪式召唤。
function c44221928.initial_effect(c)
	-- 为这张卡注册仪式召唤效果：解放自己手卡·场上的怪兽直到等级合计与仪式召唤的怪兽相同，从手卡仪式召唤1只风属性仪式怪兽；ritual_filter作为筛选可仪式召唤的怪兽的条件。
	aux.AddRitualProcEqual2(c,c44221928.ritual_filter)
end
-- 仪式召唤的过滤函数：判断怪兽是否为仪式怪兽（TYPE_RITUAL）且属性为风属性（ATTRIBUTE_WIND），用于确定可作为这次仪式召唤对象的怪兽。
function c44221928.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_WIND)
end
