--ロー・キューピット
-- 效果：
-- ①：这张卡不会被和除持有比这张卡高的等级的怪兽以外的怪兽的战斗破坏。
-- ②：自己准备阶段才能发动。这张卡的等级上升1星。
function c69526976.initial_effect(c)
	-- ①：这张卡不会被和除持有比这张卡高的等级的怪兽以外的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c69526976.indval)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段才能发动。这张卡的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c69526976.lvcon)
	e2:SetTarget(c69526976.lvtg)
	e2:SetOperation(c69526976.lvop)
	c:RegisterEffect(e2)
end
-- 战斗破坏抗性的值函数，判断与这张卡进行战斗的怪兽等级是否不大于这张卡的等级（即不持有比这张卡高的等级），若是则不会被其战斗破坏
function c69526976.indval(e,c)
	return not c:IsLevelAbove(e:GetHandler():GetLevel()+1)
end
-- 等级上升效果的发动条件函数，限制在自己的准备阶段才能发动
function c69526976.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 等级上升效果的发动目标函数，确认这张卡在场上且具有等级
function c69526976.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(1) end
end
-- 等级上升效果的执行函数，使这张卡的等级上升1星
function c69526976.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
