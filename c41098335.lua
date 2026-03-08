--ファイターズ・エイプ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，这张卡的攻击力上升300。这张卡在自己回合没有进行攻击的场合，这个效果上升的数值在那个回合的结束阶段时回到0。
function c41098335.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41098335,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c41098335.atkcon)
	e1:SetOperation(c41098335.atkop)
	c:RegisterEffect(e1)
	-- 这张卡在自己回合没有进行攻击的场合，这个效果上升的数值在那个回合的结束阶段时回到0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TURN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c41098335.retop)
	c:RegisterEffect(e2)
end
-- 判断效果是否因战斗破坏怪兽而触发，需满足怪兽表侧表示且与本次战斗相关。
function c41098335.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
-- 若满足条件则为该怪兽增加300点攻击力。
function c41098335.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 为该怪兽增加300点攻击力并设置重置条件。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否为己方回合结束阶段且该怪兽本回合未进行过攻击。
function c41098335.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若满足条件则重置该怪兽因未攻击而增加的攻击力。
	if Duel.GetTurnPlayer()==tp and c:GetAttackedCount()==0 then
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
end
