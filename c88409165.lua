--アビス・ウォリアー
-- 效果：
-- 1回合1次，从手卡把1只水属性怪兽丢弃去墓地，选择自己或者对方的墓地1只怪兽才能发动。选择的怪兽回到持有者卡组最上面或者最下面。
function c88409165.initial_effect(c)
	-- 1回合1次，从手卡把1只水属性怪兽丢弃去墓地，选择自己或者对方的墓地1只怪兽才能发动。选择的怪兽回到持有者卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88409165,0))  --"返回卡组"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c88409165.cost)
	e1:SetTarget(c88409165.target)
	e1:SetOperation(c88409165.operation)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可作为代价丢弃的水属性怪兽
function c88409165.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价（Cost）处理
function c88409165.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为代价丢弃的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88409165.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡将1只水属性怪兽丢弃去墓地
	Duel.DiscardHand(tp,c88409165.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤墓地中可以回到卡组的怪兽
function c88409165.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择与操作信息设置
function c88409165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c88409165.filter(chkc) end
	-- 检查双方墓地是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(c88409165.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方墓地中1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88409165.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为：将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理的执行：将对象怪兽送回卡组最上面或最下面
function c88409165.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsExtraDeckMonster()
			-- 若对象是额外卡组怪兽，或玩家选择“回到卡组最上面”
			or Duel.SelectOption(tp,aux.Stringid(88409165,1),aux.Stringid(88409165,2))==0 then  --"回到卡组最上面/回到卡组最下面"
			-- 将对象怪兽送回持有者卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将对象怪兽送回持有者卡组最下面
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
