--エクゾディア・ネクロス
-- 效果：
-- 这张卡不能通常召唤。「与艾克佐迪亚的契约」的效果才能特殊召唤。
-- ①：这张卡不会被战斗以及魔法·陷阱卡的效果破坏。
-- ②：自己准备阶段发动。这张卡的攻击力上升500。
-- ③：自己墓地是「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」的其中任意种不存在的场合这张卡破坏。
function c12600382.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗以及魔法·陷阱卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗以及魔法·陷阱卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c12600382.efdes)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。「与艾克佐迪亚的契约」的效果才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- ②：自己准备阶段发动。这张卡的攻击力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12600382,0))  --"攻击上升"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c12600382.atkcon)
	e4:SetOperation(c12600382.atkop)
	c:RegisterEffect(e4)
	-- ③：自己墓地是「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」的其中任意种不存在的场合这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_SELF_DESTROY)
	e5:SetCondition(c12600382.descon)
	c:RegisterEffect(e5)
end
-- 返回效果是否为魔法或陷阱卡的效果
function c12600382.efdes(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断是否为准备阶段
function c12600382.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 执行攻击力上升效果
function c12600382.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将攻击力上升500的效果登记到卡上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- 判断是否满足破坏条件
function c12600382.descon(e)
	local p=e:GetHandlerPlayer()
	-- 判断墓地是否不存在「被封印的艾克佐迪亚」
	return not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,8124921)
		-- 判断墓地是否不存在「被封印者的右腕」
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,44519536)
		-- 判断墓地是否不存在「被封印者的左腕」
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,70903634)
		-- 判断墓地是否不存在「被封印者的右足」
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,7902349)
		-- 判断墓地是否不存在「被封印者的左足」
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,33396948)
end
