--儀水鏡の反魂術
-- 效果：
-- 选择自己场上1只水属性怪兽回到卡组，选择自己墓地存在的2只水属性怪兽加入手卡。
function c78910579.initial_effect(c)
	-- 选择自己场上1只水属性怪兽回到卡组，选择自己墓地存在的2只水属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c78910579.target)
	e1:SetOperation(c78910579.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、水属性且能回到卡组的怪兽
function c78910579.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
-- 过滤自己墓地水属性且能加入手牌的怪兽
function c78910579.filter2(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果发动时的对象选择与合法性检测
function c78910579.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只满足条件1（表侧表示、水属性、能回卡组）的怪兽
	if chk==0 then return Duel.IsExistingTarget(c78910579.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在至少2只满足条件2（水属性、能回手牌）的怪兽
		and Duel.IsExistingTarget(c78910579.filter2,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只满足条件1的水属性怪兽作为对象
	local g1=Duel.SelectTarget(tp,c78910579.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地2只满足条件2的水属性怪兽作为对象
	local g2=Duel.SelectTarget(tp,c78910579.filter2,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息：将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	-- 设置效果处理信息：将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,2,0,0)
end
-- 效果处理的执行函数
function c78910579.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要返回卡组的卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取要加入手牌的卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	local tc1=g1:GetFirst()
	-- 检查场上的目标怪兽是否仍适应效果，并将其送回卡组并洗牌，若成功则继续处理
	if tc1:IsRelateToEffect(e) and Duel.SendtoDeck(tc1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		-- 将墓地的目标怪兽加入手牌
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,hg)
	end
end
