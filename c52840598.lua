--ブライ・シンクロン
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，直到这个回合的结束阶段时，这张卡为同调素材的同调怪兽攻击力上升600，效果无效化。
function c52840598.initial_effect(c)
	-- 这张卡作为同调召唤的素材送去墓地的场合，直到这个回合的结束阶段时，这张卡为同调素材的同调怪兽攻击力上升600，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c52840598.con)
	e1:SetOperation(c52840598.op)
	c:RegisterEffect(e1)
end
-- 检查触发条件：这张卡自身作为同调召唤的素材被送去墓地（位于墓地且原因为同调召唤）。
function c52840598.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 处理效果：以那只同调怪兽为对象，直到结束阶段赋予其攻击力上升600、效果无效化的效果。
function c52840598.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	-- 攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sync:RegisterEffect(e1,true)
	-- 效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sync:RegisterEffect(e2,true)
	-- 效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sync:RegisterEffect(e3,true)
end
