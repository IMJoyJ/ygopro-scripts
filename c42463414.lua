--ニードル・ギルマン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己场上的鱼族·海龙族·水族怪兽的攻击力上升400。
function c42463414.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己场上的鱼族·海龙族·水族怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c42463414.atktg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
-- 设置效果TARGET，筛选满足条件的怪兽（鱼族·海龙族·水族）
function c42463414.atktg(e,c)
	return c:IsRace(0x60040)
end
