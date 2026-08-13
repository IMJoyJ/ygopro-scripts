--儀水鏡の瞑想術
-- 效果：
-- 把手卡1张仪式魔法卡给对方观看，选择自己墓地存在的2只名字带有「遗式」的怪兽发动。选择的墓地的怪兽回到手卡。
function c46337945.initial_effect(c)
	-- 把手卡1张仪式魔法卡给对方观看，选择自己墓地存在的2只名字带有「遗式」的怪兽发动。选择的墓地的怪兽回到手卡。
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
-- costfilter：筛选手牌中非公开状态且为仪式魔法卡（类型0x82）的卡，作为展示给对方的代价候选。
function c46337945.costfilter(c)
	return not c:IsPublic() and c:GetType()==0x82
end
-- cost：发动时的代价处理，检查是否存在可展示的仪式魔法卡，选择1张给对方确认，然后洗切手牌。
function c46337945.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时，检查自己手牌是否存在至少1张满足costfilter条件的仪式魔法卡，以判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c46337945.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求玩家选择1张手牌用于给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手牌中选择1张满足costfilter条件的仪式魔法卡，作为本次发动展示给对方的部分。
	local g=Duel.SelectMatchingCard(tp,c46337945.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的仪式魔法卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手牌，使手牌顺序重置，避免暴露卡片位置信息。
	Duel.ShuffleHand(tp)
end
-- filter：筛选自己墓地中满足以下条件的怪兽：字段为「遗式」（0x3a）、是怪兽卡、且可以被加入手牌。
function c46337945.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- target：发动时选择自己墓地2只「遗式」怪兽作为对象，并设置效果处理时为回手牌的操作信息。
function c46337945.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c46337945.filter(chkc) end
	-- chk==0时，检查自己墓地是否存在至少2只满足filter条件的「遗式」怪兽，以确定能否发动。
	if chk==0 then return Duel.IsExistingTarget(c46337945.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择2只满足filter条件的「遗式」怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c46337945.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：本次连锁的效果会处理2张卡回到手牌（CATEGORY_TOHAND），供相关卡进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- activate：效果处理时，取出发动时选择的对象，过滤出仍然与效果相关的卡，将其送回持有者手牌，并向对方确认。
function c46337945.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡组（即发动时选择的2张墓地怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍然与效果相关的对象卡送回其持有者手牌，原因是效果处理。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认实际回到手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
