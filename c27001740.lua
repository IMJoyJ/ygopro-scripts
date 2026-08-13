--農園からの配送
-- 效果：
-- ①：自己场上有通常怪兽存在的场合，以除外的最多3只自己的通常怪兽为对象才能发动。那些怪兽回到卡组。
function c27001740.initial_effect(c)
	-- ①：自己场上有通常怪兽存在的场合，以除外的最多3只自己的通常怪兽为对象才能发动。那些怪兽回到卡组。
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
-- 定义辅助过滤函数，用于判断卡片是否为表侧表示且为通常怪兽。
function c27001740.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 定义效果发动条件函数，检查自己场上是否存在满足条件的表侧表示通常怪兽。
function c27001740.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 通过 Duel.IsExistingMatchingCard 检查自己主要怪兽区是否存在至少1只满足 cfilter 的表侧表示通常怪兽，作为效果发动的前提条件。
	return Duel.IsExistingMatchingCard(c27001740.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义对象选择过滤函数，要求对象怪兽处于表侧表示、为通常怪兽且能够返回卡组。
function c27001740.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 定义效果发动时的目标选择处理：选择除外区中自己的最多3只表侧表示通常怪兽作为对象，并设置回卡组的操作信息。
function c27001740.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c27001740.filter(chkc) end
	-- 在效果发动合法性检查阶段，若除外区不存在任何满足条件的对象卡，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c27001740.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家展示选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 执行目标选择：从自己除外区中选1～3只满足 c27001740.filter 条件的表侧表示通常怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c27001740.filter,tp,LOCATION_REMOVED,0,1,3,nil)
	-- 设置本次效果处理的操作信息，分类为回卡组（CATEGORY_TODECK），处理对象为所选卡组 g，数量为 g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：效果结算时将所选的仍与效果关联的对象卡返回持有者卡组并洗牌。
function c27001740.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果对象卡组，并过滤出仍然与效果 e 存在关联的卡片，确保对象仍可被回卡组处理。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的对象卡返回持有者卡组，采用洗牌处理方式（SEQ_DECKSHUFFLE），原因记为效果原因（REASON_EFFECT）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
