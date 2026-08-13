--エッジインプ・シザー
-- 效果：
-- 「锋利小鬼·剪刀」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡从墓地守备表示特殊召唤。
function c30068120.initial_effect(c)
	-- 「锋利小鬼·剪刀」的效果1回合只能使用1次。①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡从墓地守备表示特殊召唤。
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
-- 定义代价函数：作为发动代价，从手卡选择1张卡返回卡组最上面。
function c30068120.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己手卡中存在1张能返回卡组的卡，以此作为能否发动效果的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 向发动玩家提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让发动玩家从手卡选择1张卡作为返回卡组的代价，存入组g。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选手卡返回其持有者卡组最顶端，并标记为代价支付。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果发动条件判定：检查自己主要怪兽区域是否有空位，且墓地的这张卡是否能够以表侧守备表示被特殊召唤。
function c30068120.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用空格，若没有空位则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设定操作信息：本次效果处理将把效果发动者自身特殊召唤，处理分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其从墓地特殊召唤到自己场上。
function c30068120.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
