--イビリチュア・マインドオーガス
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。这张卡仪式召唤成功时，选择双方墓地存在的卡合计最多5张，回到持有者卡组。
function c11877465.initial_effect(c)
	c:EnableReviveLimit()
	-- 名字带有「遗式」的仪式魔法卡降临。这张卡仪式召唤成功时，选择双方墓地存在的卡合计最多5张，回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11877465,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c11877465.condition)
	e1:SetTarget(c11877465.target)
	e1:SetOperation(c11877465.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否为仪式召唤成功
function c11877465.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 设置选择目标时的处理函数
function c11877465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 向玩家提示选择将卡送回卡组
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择双方墓地最多5张可送回卡组的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置效果处理信息，指定将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 设置效果发动时的处理函数
function c11877465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
