--光の召集
-- 效果：
-- ①：自己手卡全部丢弃。那之后，从自己墓地选这个效果丢弃去墓地的卡数量的光属性怪兽加入手卡。
function c16255442.initial_effect(c)
	-- 创建效果，设置效果分类为丢弃手牌和回手牌，效果类型为发动，时点为自由时点，设置效果目标和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16255442.target)
	e1:SetOperation(c16255442.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选光属性且可以加入手牌的怪兽
function c16255442.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果目标函数，检查是否满足发动条件并设置操作信息
function c16255442.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上的手牌数量
		local hd=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then hd=hd-1 end
		-- 判断手牌数量大于0且墓地存在满足条件的光属性怪兽数量不少于手牌数量
		return hd>0 and Duel.IsExistingMatchingCard(c16255442.filter,tp,LOCATION_GRAVE,0,hd,nil)
	end
	-- 获取自己场上的所有手牌
	local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 设置操作信息，标记将要丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,sg,sg:GetCount(),0,0)
	-- 设置操作信息，标记将要从墓地选光属性怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,sg:GetCount(),tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行丢弃手牌并从墓地选光属性怪兽加入手牌的操作
function c16255442.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有手牌
	local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 获取墓地中所有满足条件的光属性怪兽
	local tg=Duel.GetMatchingGroup(c16255442.filter,tp,LOCATION_GRAVE,0,nil)
	if ct>0 and tg:GetCount()>=ct then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sel=tg:Select(tp,ct,ct,nil)
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(sel,nil,REASON_EFFECT)
		-- 确认对方玩家看到选中的卡
		Duel.ConfirmCards(1-tp,sel)
	end
end
