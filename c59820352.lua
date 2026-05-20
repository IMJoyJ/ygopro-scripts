--大地讃頌
-- 效果：
-- 可以使地属性的仪式怪兽降临。特殊召唤时，必须以场上和/或手卡中合计等级与此地属性仪式怪兽等级相同的怪兽作为祭品。
function c59820352.initial_effect(c)
	-- 为卡片添加仪式召唤效果，要求解放怪兽的等级合计等于仪式怪兽的等级，并使用指定的过滤条件
	aux.AddRitualProcEqual2(c,c59820352.ritual_filter)
end
-- 定义仪式怪兽的过滤条件：必须是地属性的仪式怪兽
function c59820352.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_EARTH)
end
