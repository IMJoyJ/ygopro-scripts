--ヴォルカニック・チャージ
-- 效果：
-- 自己墓地存在的最多3张名字带有「火山」的怪兽卡回到卡组。
function c33725271.initial_effect(c)
	-- 效果原文：自己墓地存在的最多3张名字带有「火山」的怪兽卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33725271.target)
	e1:SetOperation(c33725271.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：名字带有「火山」的怪兽卡且可以送去卡组
function c33725271.filter(c)
	return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果作用：选择1~3张自己墓地符合条件的怪兽卡作为对象
function c33725271.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33725271.filter(chkc) end
	-- 效果作用：检查自己墓地是否存在至少1张名字带有「火山」的怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c33725271.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：向玩家提示选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择1~3张自己墓地符合条件的怪兽卡
	local g=Duel.SelectTarget(tp,c33725271.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 效果作用：设置连锁操作信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果作用：将符合条件的卡送回卡组并洗牌
function c33725271.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 效果作用：将符合条件的卡片送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
