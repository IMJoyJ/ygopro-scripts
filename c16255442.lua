--光の召集
-- 效果：
-- ①：自己手卡全部丢弃。那之后，从自己墓地选这个效果丢弃去墓地的卡数量的光属性怪兽加入手卡。
function c16255442.initial_effect(c)
	-- ①：自己手卡全部丢弃。那之后，从自己墓地选这个效果丢弃去墓地的卡数量的光属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16255442.target)
	e1:SetOperation(c16255442.operation)
	c:RegisterEffect(e1)
end
-- 过滤墓地中可以加入手卡的光属性怪兽的过滤函数
function c16255442.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果发动的合法性检查与操作信息设置
function c16255442.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己手卡数量
		local hd=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then hd=hd-1 end
		-- 检查要丢弃的手卡数量是否大于0，且墓地中是否存在至少该数量的符合条件的光属性怪兽
		return hd>0 and Duel.IsExistingMatchingCard(c16255442.filter,tp,LOCATION_GRAVE,0,hd,nil)
	end
	-- 获取自己全部手卡
	local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 设置丢弃自己手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,sg,sg:GetCount(),0,0)
	-- 设置墓地卡片加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,sg:GetCount(),tp,LOCATION_GRAVE)
end
-- 效果处理的执行
function c16255442.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前全部手卡
	local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将自己手卡全部丢弃去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 获取墓地中符合条件的光属性怪兽
	local tg=Duel.GetMatchingGroup(c16255442.filter,tp,LOCATION_GRAVE,0,nil)
	if ct>0 and tg:GetCount()>=ct then
		-- 中断当前效果处理，使之后的操作视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sel=tg:Select(tp,ct,ct,nil)
		-- 将选择的卡片加入手卡
		Duel.SendtoHand(sel,nil,REASON_EFFECT)
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,sel)
	end
end
