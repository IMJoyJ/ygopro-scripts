--無情なはたき落とし
-- 效果：
-- ①：场上的表侧表示的卡或者墓地的卡因效果加入对方手卡时才能发动。把对方手卡确认，从那之中把加入手卡的卡以及那些同名卡全部除外。
function c47439573.initial_effect(c)
	-- ①：场上的表侧表示的卡或者墓地的卡因效果加入对方手卡时才能发动。把对方手卡确认，从那之中把加入手卡的卡以及那些同名卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c47439573.condition)
	e1:SetTarget(c47439573.target)
	e1:SetOperation(c47439573.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足诱发条件的卡：卡的当前控制者为对方，且因效果加入手卡，且移动前位于对方墓地，或位于对方场上且为表侧表示。
function c47439573.cfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and (c:IsPreviousLocation(LOCATION_GRAVE) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)))
end
-- 发动条件判断：本次加入手卡的卡组中，存在至少1张符合上述条件（由对方控制、因效果从对方场上表侧表示或墓地加入手卡）的卡。
function c47439573.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47439573.cfilter,1,nil,1-tp)
end
-- 发动时的目标处理：确认可以发动；将本次加入手卡的卡组设为效果关联对象；向系统登记除外对方手卡中符合条件的卡这一操作信息。
function c47439573.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次加入手卡的卡组设置为当前效果的关联对象（使这些卡与效果建立联系，便于处理时判断是否仍相关）。
	Duel.SetTargetCard(eg)
	-- 登记操作信息：本效果将要把对方手卡中的卡除外，目标位置为对方手卡，具体张数在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 从本次加入手卡的卡组中，筛选出仍与本效果关联，且满足原始诱发条件（对方控制、效果移动、来自对方场上表侧表示或墓地）的卡。
function c47439573.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c47439573.cfilter(c,tp)
end
-- 筛选对方手卡中可被除外且与加入手卡的相关卡（或同名卡）卡名相同的卡。
function c47439573.rmfilter(c,g)
	return c:IsAbleToRemove() and g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 效果处理：从本次加入手卡的卡组中筛选出符合条件的卡作为基准；确认对方手卡；从对方手卡中选出与基准卡或其同名卡卡名相同的卡；将这些卡全部除外；最后洗切对方手卡。
function c47439573.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(c47439573.filter,nil,e,1-tp)
	-- 获取对方手卡中的全部卡牌。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 让对方玩家（发动者）确认对方手卡的全部卡牌。
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(c47439573.rmfilter,nil,dg)
		if tg:GetCount()>0 then
			-- 将筛选出的卡以表侧表示从手卡除外（除外原因：效果）。
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		-- 除外后洗切对方手卡，使手卡顺序保密。
		Duel.ShuffleHand(1-tp)
	end
end
