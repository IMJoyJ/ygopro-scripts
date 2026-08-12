--サテライト・キャノン
-- 效果：
-- 这张卡不会被7星以下的怪兽战斗破坏。每次的自己的结束阶段，这张卡的攻击力上升1000。这张卡进行攻击的场合，用这个效果上升的攻击力在伤害计算后回到0。
function c50400231.initial_effect(c)
	-- 这张卡不会被7星以下的怪兽战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c50400231.indval)
	c:RegisterEffect(e1)
	-- 每次的自己的结束阶段，这张卡的攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50400231,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c50400231.atkcon)
	e2:SetOperation(c50400231.atkop)
	c:RegisterEffect(e2)
	-- 这张卡进行攻击的场合，用这个效果上升的攻击力在伤害计算后回到0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c50400231.retop)
	c:RegisterEffect(e3)
end
-- 判断是否为7星或更低等级的怪兽
function c50400231.indval(e,c)
	return c:IsLevelBelow(7)
end
-- 判断是否为自己的回合
function c50400231.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 将攻击力上升1000的效果应用到自身
function c50400231.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将攻击力上升1000的效果注册到自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 在伤害计算后重置攻击力上升效果
function c50400231.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否为攻击怪兽
	if c==Duel.GetAttacker() then
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
end
