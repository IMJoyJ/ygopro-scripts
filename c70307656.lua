--グラッジ
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡给与对方玩家战斗伤害的场合，下次的自己的准备阶段时这张卡的攻击力上升1000。
function c70307656.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡给与对方玩家战斗伤害的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetOperation(c70307656.regop)
	c:RegisterEffect(e2)
	-- 下次的自己的准备阶段时这张卡的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70307656,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c70307656.atkcon)
	e3:SetOperation(c70307656.atkop)
	c:RegisterEffect(e3)
end
-- 造成战斗伤害时，为自身注册一个在下次自己准备阶段结束时重置的标识效果
function c70307656.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(70307656,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
end
-- 判断当前是否为自己的回合，且自身是否带有造成过战斗伤害的标识
function c70307656.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是自己，且自身具有造成过战斗伤害的标识
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(70307656)~=0
end
-- 若自身仍在场且表侧表示，则使其攻击力上升1000
function c70307656.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
