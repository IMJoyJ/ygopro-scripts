--農園からの配送
-- 效果：
-- ①：自己场上有通常怪兽存在的场合，以除外的最多3只自己的通常怪兽为对象才能发动。那些怪兽回到卡组。
function c27001740.initial_effect(c)
	-- 效果原文内容：①：自己场上有通常怪兽存在的场合，以除外的最多3只自己的通常怪兽为对象才能发动。那些怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c27001740.condition)
	e1:SetTarget(c27001740.target)
	e1:SetOperation(c27001740.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查怪兽是否为表侧表示的通常怪兽
function c27001740.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 效果作用：检查自己场上是否存在表侧表示的通常怪兽
function c27001740.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否存在至少1只表侧表示的通常怪兽
	return Duel.IsExistingMatchingCard(c27001740.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：检查怪兽是否为表侧表示的通常怪兽且可以送去卡组
function c27001740.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 效果作用：设置效果目标为除外区的1~3只自己的表侧表示通常怪兽
function c27001740.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c27001740.filter(chkc) end
	-- 效果作用：判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c27001740.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 效果作用：向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择1~3只除外区的自己的表侧表示通常怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c27001740.filter,tp,LOCATION_REMOVED,0,1,3,nil)
	-- 效果作用：设置效果处理信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果作用：将符合条件的目标怪兽送回卡组
function c27001740.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中已选定的目标卡组并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：将卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
