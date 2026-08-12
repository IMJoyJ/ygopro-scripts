--裁きの光
-- 效果：
-- ①：场上有「天空的圣域」存在的场合从手卡把1只光属性怪兽丢弃去墓地才能发动。从以下效果选1个适用。
-- ●把对方手卡确认，从那之中选1张卡送去墓地。
-- ●选对方场上1张卡送去墓地。
function c44595286.initial_effect(c)
	-- 记录此卡与「天空的圣域」卡名关联
	aux.AddCodeList(c,56433456)
	-- ①：场上有「天空的圣域」存在的场合从手卡把1只光属性怪兽丢弃去墓地才能发动。从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_TOHAND+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44595286.condition)
	e1:SetCost(c44595286.cost)
	e1:SetTarget(c44595286.target)
	e1:SetOperation(c44595286.activate)
	c:RegisterEffect(e1)
end
-- 判断场地是否存在「天空的圣域」
function c44595286.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 场地卡号为56433456时效果才能发动
	return Duel.IsEnvironment(56433456)
end
-- 筛选手卡中可丢弃的光属性怪兽
function c44595286.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 支付将1只光属性怪兽丢入墓地的代价
function c44595286.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44595286.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1只光属性怪兽的操作
	Duel.DiscardHand(tp,c44595286.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果发动的条件
function c44595286.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方场上或手卡存在卡牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
end
-- 执行效果发动时的选择与处理
function c44595286.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡牌组
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 获取对方手卡的卡牌组
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local opt=0
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 让玩家选择从对方场上或手卡中送墓
		opt=Duel.SelectOption(tp,aux.Stringid(44595286,0),aux.Stringid(44595286,1))+1  --"从对方场上选择1张卡送去墓地/从对方手卡选择1张卡送去墓地"
	elseif g1:GetCount()>0 then opt=1
	elseif g2:GetCount()>0 then opt=2
	end
	if opt==1 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif opt==2 then
		-- 确认对方手卡
		Duel.ConfirmCards(tp,g2)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的卡牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 将对方手卡洗牌
		Duel.ShuffleHand(1-tp)
	end
end
