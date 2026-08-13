--サテライト・キャノン
-- 效果：
-- 这张卡不会被7星以下的怪兽战斗破坏。每次的自己的结束阶段，这张卡的攻击力上升1000。这张卡进行攻击的场合，用这个效果上升的攻击力在伤害计算后回到0。
function c50400231.initial_effect(c)
	-- 这张卡不会被7星以下的怪兽战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c50400231.indval)
	c:RegisterEffect(e1)
	-- 每次的自己的结束阶段，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50400231,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c50400231.atkcon)
	e2:SetOperation(c50400231.atkop)
	c:RegisterEffect(e2)
	-- 这张卡进行攻击的场合，用这个效果上升的攻击力在伤害计算后回到0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c50400231.retop)
	c:RegisterEffect(e3)
end
-- 判定战斗对象怪兽是否7星以下：若返回真，则本卡不会被该怪兽战斗破坏。
function c50400231.indval(e,c)
	return c:IsLevelBelow(7)
end
-- 结束阶段加攻效果的发动条件：当前回合玩家必须是本卡的控制者，即仅在自己的结束阶段满足。
function c50400231.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否等于效果控制者tp，确保只在己方结束阶段触发。
	return Duel.GetTurnPlayer()==tp
end
-- 执行加攻操作：若本卡仍与效果关联且表侧表示，则给它附加一个攻击力上升1000的效果，该效果在标准重置时机（离场、无效等）后消失。
function c50400231.atkop(e,tp,eg,ep,ev,re,r,rp)
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
-- 攻击力重置操作：若本卡是进行攻击的怪兽，则将通过效果上升的攻击力重置，使攻击力回到原值。
function c50400231.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断本次战斗的攻击怪兽是否就是本卡，只有本卡进行攻击时才执行攻击力重置。
	if c==Duel.GetAttacker() then
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
end
