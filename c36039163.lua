--ペンギン・ナイト
-- 效果：
-- 这张卡被对方的效果从卡组送去墓地时，把自己墓地存在的全部卡回到卡组。
function c36039163.initial_effect(c)
	-- 效果原文内容：这张卡被对方的效果从卡组送去墓地时，把自己墓地存在的全部卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36039163,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c36039163.tdcon)
	e1:SetTarget(c36039163.tdtg)
	e1:SetOperation(c36039163.tdop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断这张卡是否从卡组被对方的效果送入墓地
function c36039163.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and bit.band(r,REASON_EFFECT)~=0 and rp==1-tp
end
-- 效果作用：设置连锁处理时的操作信息，确定将墓地的卡送回卡组
function c36039163.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：获取玩家墓地中的所有卡片组成一个组
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	-- 效果作用：设置操作信息，指定要送回卡组的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果作用：处理将墓地卡片送回卡组的逻辑
function c36039163.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家墓地中的所有卡片组成一个组
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	-- 效果作用：检查是否因王家长眠之谷而使效果无效
	if aux.NecroValleyNegateCheck(g) then return end
	-- 效果作用：将卡片送回卡组并判断是否成功
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 效果作用：如果送回卡组的卡片中有在卡组中的，则洗切该玩家卡组
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	end
end
