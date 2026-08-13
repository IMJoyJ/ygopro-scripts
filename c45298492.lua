--スカー・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的战士族怪兽作为攻击对象。此外，这张卡1回合只有1次不会被战斗破坏。
function c45298492.initial_effect(c)
	-- 为伤痕战士添加同调召唤手续：需要1只调整（任意调整）＋1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的战士族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c45298492.atlimit)
	c:RegisterEffect(e1)
	-- 此外，这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c45298492.valcon)
	c:RegisterEffect(e2)
end
-- 判定对方不可选择为攻击对象的卡的条件：该卡不是伤痕战士自身、表侧表示且为战士族怪兽。
function c45298492.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 判定是否适用1回合1次不会被战斗破坏的条件：破坏原因包含战斗破坏（REASON_BATTLE）。
function c45298492.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
