--ツインヘッド・ケルベロス
-- 效果：
-- 自己的场上有这张卡以外的其他恶魔族怪兽表侧表示存在的场合，这张卡战斗破坏的反转效果怪兽的效果无效化。
function c88132637.initial_effect(c)
	-- 自己的场上有这张卡以外的其他恶魔族怪兽表侧表示存在的场合，这张卡战斗破坏的反转效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c88132637.discon)
	e1:SetOperation(c88132637.disop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的恶魔族怪兽
function c88132637.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 判断自己场上是否存在除这张卡以外的其他表侧表示恶魔族怪兽
function c88132637.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张除自身以外的表侧表示恶魔族怪兽
	return Duel.IsExistingMatchingCard(c88132637.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 在伤害计算后，若与自身战斗的怪兽被战斗破坏且是反转怪兽，则使其效果无效化
function c88132637.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsType(TYPE_FLIP) then
		-- 这张卡战斗破坏的反转效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 这张卡战斗破坏的反转效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
