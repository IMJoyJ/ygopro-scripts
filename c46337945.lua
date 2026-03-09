--儀水鏡の瞑想術
-- 效果：
-- 把手卡1张仪式魔法卡给对方观看，选择自己墓地存在的2只名字带有「遗式」的怪兽发动。选择的墓地的怪兽回到手卡。
function c46337945.initial_effect(c)
	-- 效果原文内容：把手卡1张仪式魔法卡给对方观看，选择自己墓地存在的2只名字带有「遗式」的怪兽发动。选择的墓地的怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c46337945.cost)
	e1:SetTarget(c46337945.target)
	e1:SetOperation(c46337945.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义cost过滤函数，用于检查手牌中是否包含未公开的仪式魔法卡（类型为0x82）
function c46337945.costfilter(c)
	return not c:IsPublic() and c:GetType()==0x82
end
-- 规则层面作用：处理效果发动时的费用，检查手牌是否存在符合条件的仪式魔法卡并选择给对方确认
function c46337945.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足发动条件，即手牌中存在至少一张未公开的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c46337945.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：向玩家提示“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 规则层面作用：从手牌中选择一张符合条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c46337945.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 规则层面作用：将所选卡片展示给对方玩家
	Duel.ConfirmCards(1-tp,g)
	-- 规则层面作用：将发动者的手牌进行洗切
	Duel.ShuffleHand(tp)
end
-- 规则层面作用：定义目标过滤函数，用于检查墓地中的怪兽是否为「遗式」系列且可送回手牌
function c46337945.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的目标选择逻辑，允许玩家从自己墓地中选择2只符合条件的怪兽
function c46337945.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c46337945.filter(chkc) end
	-- 规则层面作用：判断是否满足发动条件，即自己墓地中存在至少2只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c46337945.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 规则层面作用：向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：从自己墓地中选择2只符合条件的怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c46337945.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 规则层面作用：设置连锁操作信息，表明本次效果将使2张怪兽卡回到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 规则层面作用：执行效果发动后的处理逻辑，将选定的怪兽送回手牌并展示给对方
function c46337945.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中已设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 规则层面作用：将符合条件的怪兽以效果原因送回手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 规则层面作用：将送回手牌的怪兽展示给对方玩家
		Duel.ConfirmCards(1-tp,sg)
	end
end
