--パワー・ブレイク
-- 效果：
-- ①：自己场上有「动力工具龙」存在的场合，以自己的场上·墓地最多3张装备卡为对象才能发动。那些卡回到持有者卡组，给与对方回去数量×500伤害。
function c86821010.initial_effect(c)
	-- ①：自己场上有「动力工具龙」存在的场合，以自己的场上·墓地最多3张装备卡为对象才能发动。那些卡回到持有者卡组，给与对方回去数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c86821010.condition)
	e1:SetTarget(c86821010.target)
	e1:SetOperation(c86821010.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「动力工具龙」
function c86821010.cfilter(c)
	return c:IsFaceup() and c:IsCode(2403771)
end
-- 发动条件：自己场上有「动力工具龙」存在
function c86821010.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「动力工具龙」
	return Duel.IsExistingMatchingCard(c86821010.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：装备卡且可以回到卡组
function c86821010.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择与操作信息注册
function c86821010.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c86821010.filter(chkc) end
	-- 在发动时，检查自己场上或墓地是否存在至少1张符合条件的装备卡
	if chk==0 then return Duel.IsExistingTarget(c86821010.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上或墓地1到3张符合条件的装备卡作为效果对象
	local g=Duel.SelectTarget(tp,c86821010.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：给与对方相当于返回卡组数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 效果处理：将对象卡送回卡组，并给与对方相应数值的伤害
function c86821010.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步操作中实际移动到卡组（或额外卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 给与对方实际返回卡组数量×500的伤害
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
