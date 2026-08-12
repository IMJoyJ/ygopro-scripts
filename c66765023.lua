--飛行エレファント
-- 效果：
-- ①：这张卡在对方回合只有1次不会被对方的效果破坏。
-- ②：这张卡的①的效果适用的对方回合的结束阶段发动。下次的自己回合中，以下适用。
-- ●这张卡直接攻击给与对方战斗伤害时，自己决斗胜利。
function c66765023.initial_effect(c)
	-- ①：这张卡在对方回合只有1次不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetCondition(c66765023.indcon)
	e1:SetValue(c66765023.valcon)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果适用的对方回合的结束阶段发动。下次的自己回合中，以下适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c66765023.effcon)
	e2:SetOperation(c66765023.effop)
	c:RegisterEffect(e2)
end
-- 设置①效果的适用条件：当前回合不是自己回合（即对方回合）
function c66765023.indcon(e)
	-- 判断当前回合玩家是否不是这张卡的控制者（即是否为对方回合）
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 判断破坏原因是否为对方的效果，并在适用时给这张卡注册一个表示效果已适用的标记
function c66765023.valcon(e,re,r,rp)
	local res=false
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer() then
		res=true
		e:GetHandler():RegisterFlagEffect(66765023,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	return res
end
-- 设置②效果的发动条件：这张卡在对方回合适用过①的效果，且当前是对方回合的结束阶段
function c66765023.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否带有①效果适用的标记，且当前回合玩家不是自己（对方回合）
	return e:GetHandler():GetFlagEffect(66765023)~=0 and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- ②效果的处理：给这张卡注册一个持续到下个自己回合结束的特殊胜利效果
function c66765023.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- ●这张卡直接攻击给与对方战斗伤害时，自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66765023,0))  --"效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c66765023.wincon)
	e1:SetOperation(c66765023.winop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
end
-- 设置特殊胜利的条件：造成战斗伤害的对象是对方，且没有攻击目标（即直接攻击）
function c66765023.wincon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方，且攻击对象为空（表示直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 特殊胜利的效果处理：宣告自己因“飞行象”的效果决斗胜利
function c66765023.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_FLYING_ELEPHANT=0x1e
	-- 令当前效果控制者以“飞行象”的胜利原因赢得决斗
	Duel.Win(tp,WIN_REASON_FLYING_ELEPHANT)
end
