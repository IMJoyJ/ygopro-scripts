--ケルドウ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从对方墓地里选择2张卡回到对方卡组。
function c80441106.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，从对方墓地里选择2张卡回到对方卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80441106,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c80441106.condition)
	e1:SetTarget(c80441106.target)
	e1:SetOperation(c80441106.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否在墓地且是因为战斗被破坏
function c80441106.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤可以回到卡组且可以作为效果对象的卡片
function c80441106.filter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 效果发动时的对象选择与操作信息设置
function c80441106.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c80441106.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取对方墓地中满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c80441106.filter,tp,0,LOCATION_GRAVE,nil,e)
	if g:GetCount()>=2 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的卡片设置为效果的对象
		Duel.SetTargetCard(sg)
		-- 设置连锁操作信息为将选中的2张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
	end
end
-- 效果处理，将作为对象的卡片送回持有者卡组并洗牌
function c80441106.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的卡片送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
