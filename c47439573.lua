--無情なはたき落とし
-- 效果：
-- ①：场上的表侧表示的卡或者墓地的卡因效果加入对方手卡时才能发动。把对方手卡确认，从那之中把加入手卡的卡以及那些同名卡全部除外。
function c47439573.initial_effect(c)
	-- 效果原文内容：①：场上的表侧表示的卡或者墓地的卡因效果加入对方手卡时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c47439573.condition)
	e1:SetTarget(c47439573.target)
	e1:SetOperation(c47439573.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：筛选满足条件的卡，即控制权为1-tp、因效果离开、且之前在墓地或场上正面表示位置的卡。
function c47439573.cfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and (c:IsPreviousLocation(LOCATION_GRAVE) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)))
end
-- 规则层面作用：判断是否有至少一张满足cfilter条件的卡加入手牌。
function c47439573.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47439573.cfilter,1,nil,1-tp)
end
-- 规则层面作用：设置效果处理时的目标卡组和操作信息，准备进行除外处理。
function c47439573.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：将连锁中涉及的卡设为当前效果的目标对象。
	Duel.SetTargetCard(eg)
	-- 规则层面作用：设置本次效果操作的信息，包括类别为除外、目标玩家为1-tp、目标区域为手牌。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 规则层面作用：筛选与效果相关且满足cfilter条件的卡。
function c47439573.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c47439573.cfilter(c,tp)
end
-- 规则层面作用：判断卡是否可以除外，并且在目标组中存在同名卡。
function c47439573.rmfilter(c,g)
	return c:IsAbleToRemove() and g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 规则层面作用：处理效果发动时，确认对方手牌并除外符合条件的卡。
function c47439573.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(c47439573.filter,nil,e,1-tp)
	-- 规则层面作用：获取当前玩家对手的手牌组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 规则层面作用：确认对手手牌内容。
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(c47439573.rmfilter,nil,dg)
		if tg:GetCount()>0 then
			-- 规则层面作用：以效果原因将目标卡组除外。
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		-- 规则层面作用：将对方手牌进行洗切。
		Duel.ShuffleHand(1-tp)
	end
end
