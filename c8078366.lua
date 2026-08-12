--海皇の突撃兵
-- 效果：
-- 自己场上有这张卡以外的鱼族·海龙族·水族怪兽存在的场合，这张卡的攻击力上升800。
function c8078366.initial_effect(c)
	-- 自己场上有这张卡以外的鱼族·海龙族·水族怪兽存在的场合，这张卡的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c8078366.atkcon)
	e1:SetValue(800)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的鱼族、海龙族或水族怪兽
function c8078366.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 攻击力上升效果的判定条件：自己场上存在除这张卡以外的满足过滤条件的怪兽
function c8078366.atkcon(e)
	-- 检查自己场上是否存在至少1张除自身以外的表侧表示鱼族·海龙族·水族怪兽
	return Duel.IsExistingMatchingCard(c8078366.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
