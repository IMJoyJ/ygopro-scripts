--スカー・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的战士族怪兽作为攻击对象。此外，这张卡1回合只有1次不会被战斗破坏。
function c45298492.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的战士族怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c45298492.atlimit)
	c:RegisterEffect(e1)
	-- 此外，这张卡1回合只有1次不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c45298492.valcon)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否为表侧表示的战士族怪兽且不是自身
function c45298492.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 判断破坏原因是否为战斗破坏
function c45298492.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
