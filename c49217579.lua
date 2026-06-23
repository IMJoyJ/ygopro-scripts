--幻影の騎士－ミラージュ・ナイト－
-- 效果：
-- 这张卡不能通常召唤，用「黑炎之骑士」的效果才能特殊召唤。
-- ①：这张卡的攻击力只在和对方怪兽进行战斗的伤害计算时上升那只对方怪兽的原本攻击力数值。
-- ②：这张卡进行战斗的回合的结束阶段发动。这张卡除外。
function c49217579.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力只在和对方怪兽进行战斗的伤害计算时上升那只对方怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49217579.atkcon)
	e1:SetValue(c49217579.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的回合的结束阶段发动。这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c49217579.rmcon)
	e2:SetOperation(c49217579.rmop)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤，用「黑炎之骑士」的效果才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无效条件，使卡片无法通过通常方式特殊召唤。
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
end
-- 判断当前是否处于伤害计算阶段且己方怪兽有战斗目标。
function c49217579.atkcon(e)
	-- 当前阶段为伤害计算阶段并且存在战斗中的对方怪兽。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
end
-- 返回当前进行战斗的对方怪兽的原本攻击力数值。
function c49217579.atkval(e,c)
	return e:GetHandler():GetBattleTarget():GetBaseAttack()
end
-- 判断该卡在战斗中是否参与过战斗组（即是否进行过战斗）。
function c49217579.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 执行将自身从游戏中除外的操作。
function c49217579.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将目标卡片以正面表示形式除外，原因来自效果
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
