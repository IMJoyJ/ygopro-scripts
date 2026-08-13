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
	-- 将该卡的特殊召唤条件值设为false，使其无法通过一般特殊召唤方式出场，只能依靠「黑炎之骑士」效果进行特殊召唤。
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升效果的适用条件：仅在伤害计算阶段且该卡此时有战斗对象时才适用。
function c49217579.atkcon(e)
	-- 判定当前阶段是否为伤害计算时，并且该卡存在战斗对象（即正在与对方怪兽战斗）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
end
-- 定义攻击力上升的具体数值：该卡当前战斗对象的原本攻击力数值。
function c49217579.atkval(e,c)
	return e:GetHandler():GetBattleTarget():GetBaseAttack()
end
-- 定义②效果的触发条件：本回合该卡进行过战斗（战斗过的怪兽数量大于0）。
function c49217579.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 定义②效果的处理流程：若该卡仍与效果保持关联，则将其除外。
function c49217579.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以表侧表示形式将该卡除外，除外原因为效果。
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
