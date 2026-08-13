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
-- 定义该卡作为仪式祭品时的等级计算规则：当祭品对象为暗属性仪式怪兽时，返回由自身等级和仪式怪兽等级组成的复合值，使该卡可满足该仪式召唤所需的祭品等级；否则只按自身原本等级计算。
function c34334692.rlevel(e,c)
	-- 获取效果持有者（此卡）的等级，并经过系统安全上限限制，作为仪式祭品的基础等级。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_DARK) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
