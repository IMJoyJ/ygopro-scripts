--レジェンド・デビル
-- 效果：
-- ①：自己准备阶段发动。这张卡的攻击力上升700。
function c99747800.initial_effect(c)
	-- ①：自己准备阶段发动。这张卡的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99747800,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c99747800.atkcon)
	e1:SetOperation(c99747800.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：仅在当前回合玩家为自己（即自己的准备阶段）时满足，效果才会发动。
function c99747800.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果发动方是否等于当前回合玩家，确保是在自己的准备阶段触发，而不是对方回合。
	return tp==Duel.GetTurnPlayer()
end
-- 效果处理操作：将这张卡的攻击力上升700；生成一个单次攻击力增减效果并注册到该卡，持续到标准重置条件满足。
function c99747800.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(700)
	c:RegisterEffect(e1)
end
