--エッジインプ・シザー
-- 效果：
-- 「锋利小鬼·剪刀」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡从墓地守备表示特殊召唤。
function c30068120.initial_effect(c)
	-- 效果原文内容：「锋利小鬼·剪刀」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30068120,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,30068120)
	e1:SetCost(c30068120.cost)
	e1:SetTarget(c30068120.target)
	e1:SetOperation(c30068120.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：支付1张手卡回到卡组的代价
function c30068120.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足支付代价的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择1张手卡返回卡组最上面
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：将选中的卡送入卡组最上面作为代价
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果作用：设置效果的发动目标
function c30068120.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有特殊召唤的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 效果作用：设置将要特殊召唤的卡作为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：执行效果的处理流程
function c30068120.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 效果作用：将此卡从墓地特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
