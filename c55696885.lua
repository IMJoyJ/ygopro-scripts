--疫病狼
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
-- ②：这张卡的①的效果发动的场合，结束阶段发动。这张卡破坏。
function c55696885.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55696885,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c55696885.atkop)
	c:RegisterEffect(e1)
end
-- ①的效果的处理：使这张卡的攻击力直到回合结束时变成原本攻击力的2倍，并注册在结束阶段发动破坏效果的延迟触发效果。
function c55696885.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c:GetBaseAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果发动的场合，结束阶段发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55696885,1))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c55696885.destg)
	e2:SetOperation(c55696885.desop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
-- 结束阶段破坏效果的发动检测：作为必发效果直接返回true，并设置破坏自身的操作信息。
function c55696885.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：在效果处理时将破坏1张卡（即这张卡自身）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 结束阶段破坏效果的处理：若这张卡仍在场上，则将其破坏。
function c55696885.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏这张卡。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
