--儀式の供物
-- 效果：
-- 暗属性的仪式怪兽特殊召唤的场合，可以让这1张卡作为仪式召唤的祭品使用。
function c34334692.initial_effect(c)
	-- 暗属性的仪式怪兽特殊召唤的场合，可以让这1张卡作为仪式召唤的祭品使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(c34334692.rlevel)
	c:RegisterEffect(e1)
end
-- 设置效果值为rlevel函数，用于计算仪式召唤时的等级
function c34334692.rlevel(e,c)
	-- 获取当前卡片在系统安全阈值内的等级数值
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_DARK) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
