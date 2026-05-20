--ディノインフィニティ
-- 效果：
-- ①：这张卡的原本攻击力变成除外的自己的恐龙族怪兽数量×1000。
function c83235263.initial_effect(c)
	-- ①：这张卡的原本攻击力变成除外的自己的恐龙族怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c83235263.atkval)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤出表侧表示的恐龙族怪兽
function c83235263.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 计算并返回原本攻击力的数值
function c83235263.atkval(e,c)
	-- 获取自己除外区满足过滤条件的卡片数量并乘以1000
	return Duel.GetMatchingGroupCount(c83235263.filter,c:GetControler(),LOCATION_REMOVED,0,nil)*1000
end
