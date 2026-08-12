--イビリチュア・ソウルオーガ
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，可以从手卡把1只名字带有「遗式」的怪兽丢弃，选择对方场上表侧表示存在的1张卡回到持有者卡组。
function c57272170.initial_effect(c)
	c:EnableReviveLimit()
	-- 1回合1次，可以从手卡把1只名字带有「遗式」的怪兽丢弃，选择对方场上表侧表示存在的1张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57272170,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c57272170.cost)
	e1:SetTarget(c57272170.target)
	e1:SetOperation(c57272170.operation)
	c:RegisterEffect(e1)
end
-- 过滤手牌中名字带有「遗式」的怪兽且可以丢弃的卡
function c57272170.costfilter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 丢弃手牌中1只名字带有「遗式」的怪兽作为发动的代价
function c57272170.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张满足过滤条件的名字带有「遗式」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57272170.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌中满足过滤条件的名字带有「遗式」的怪兽
	Duel.DiscardHand(tp,c57272170.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上表侧表示且可以回到卡组的卡
function c57272170.filter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果发动的目标选择与操作信息设置
function c57272170.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c57272170.filter(chkc) end
	-- 检查对方场上是否存在至少1张表侧表示且可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(c57272170.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上表侧表示存在的1张卡作为效果处理的对象
	local g=Duel.SelectTarget(tp,c57272170.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理，将选中的对象卡片送回持有者卡组并洗牌
function c57272170.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
