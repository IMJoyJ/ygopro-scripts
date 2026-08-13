--エクゾディア・ネクロス
-- 效果：
-- 这张卡不能通常召唤。「与艾克佐迪亚的契约」的效果才能特殊召唤。
-- ①：这张卡不会被战斗以及魔法·陷阱卡的效果破坏。
-- ②：自己准备阶段发动。这张卡的攻击力上升500。
-- ③：自己墓地是「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」的其中任意种不存在的场合这张卡破坏。
function c12600382.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗以及魔法·陷阱卡的效果破坏。——此效果实现不会被战斗破坏的部分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗以及魔法·陷阱卡的效果破坏。——此效果实现不会被魔法·陷阱卡效果破坏的部分。
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
-- 判定一个效果是否为魔法·陷阱卡效果；若为魔法·陷阱卡效果则本卡不会被该效果破坏。
function c12600382.efdes(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 触发条件：仅在效果发动者的回合（即自己的准备阶段）满足条件。
function c12600382.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果拥有者，用于限定只有自己的准备阶段才发动。
	return tp==Duel.GetTurnPlayer()
end
-- 处理攻击力上升：先确认本卡仍存在于场上且与效果相关、未变成里侧表示，然后为本卡临时注册一个攻击力上升500的效果。
function c12600382.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- ③的自坏条件：检查自己墓地中五张「被封印」部件是否任意一种不存在，只要缺任意一种就返回真，使本卡破坏。
function c12600382.descon(e)
	local p=e:GetHandlerPlayer()
	-- 检查自己墓地是否存在「被封印的艾克佐迪亚」（卡号8124921），若不存在则满足③的破坏条件之一。
	return not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,8124921)
		-- 检查自己墓地是否存在「被封印者的右腕」（卡号44519536），若不存在则满足③的破坏条件之一。
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,44519536)
		-- 检查自己墓地是否存在「被封印者的左腕」（卡号70903634），若不存在则满足③的破坏条件之一。
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,70903634)
		-- 检查自己墓地是否存在「被封印者的右足」（卡号7902349），若不存在则满足③的破坏条件之一。
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,7902349)
		-- 检查自己墓地是否存在「被封印者的左足」（卡号33396948），若不存在则满足③的破坏条件之一。
		or not Duel.IsExistingMatchingCard(Card.IsCode,p,LOCATION_GRAVE,0,1,nil,33396948)
end
