--M・HERO ダーク・ロウ
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，被送去对方墓地的卡不去墓地而除外。
-- ②：1回合1次，对方在抽卡阶段以外从卡组把卡加入手卡的场合才能发动。对方手卡随机1张除外。
function c58481572.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数，限制只能通过「假面变化」的效果进行特殊召唤
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，被送去对方墓地的卡不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_DECK)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTarget(c58481572.rmtg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方在抽卡阶段以外从卡组把卡加入手卡的场合才能发动。对方手卡随机1张除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58481572,0))  --"卡片除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c58481572.hdcon)
	e3:SetTarget(c58481572.hdtg)
	e3:SetOperation(c58481572.hdop)
	c:RegisterEffect(e3)
end
-- 重定向效果的目标过滤函数，用于筛选出持有者为对方玩家的卡片
function c58481572.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer()
end
-- 过滤函数，用于判断卡片是否由对方玩家从卡组加入手牌
function c58481572.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果②的发动条件函数，判断是否在抽卡阶段以外且对方有卡片从卡组加入手牌
function c58481572.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段不是抽卡阶段，且加入手牌的卡片中存在对方从卡组加入手牌的卡
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(c58481572.cfilter,1,nil,1-tp)
end
-- 效果②的发动准备与目标确认函数，检查对方手牌中是否存在可除外的卡并设置除外操作信息
function c58481572.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查对方手牌中是否存在至少1张可以被除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 设置连锁处理的操作信息，声明此效果将从对方手牌中除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理函数，随机选择1张对方手牌并将其除外
function c58481572.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中所有可以被除外的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		-- 将随机选出的1张对方手牌以效果原因表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
