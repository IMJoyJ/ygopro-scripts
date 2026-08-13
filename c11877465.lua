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
-- 效果发动条件：该卡通过仪式召唤特殊召唤成功（召唤类型为仪式召唤）时才满足。
function c11877465.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果发动时选择对象：从双方墓地选择1~5张可以返回卡组的卡作为效果对象，并设置本次连锁回卡组的操作信息。
function c11877465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 显示“请选择要返回卡组的卡”的提示信息，引导玩家进行目标选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 以可以返回卡组为条件，从双方墓地区域选择1~5张卡，并将它们设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置当前连锁的操作信息：将选择的对象卡返回持有者卡组（回卡组），数量为对象卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：取出连锁记录的对象卡，筛选出仍与该效果有关联的卡，将它们返回持有者卡组并洗牌。
function c11877465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象卡组，即发动时选择的目标卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡以效果原因返回持有者卡组，并执行卡组洗牌。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
