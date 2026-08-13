--ゾンビキャリア
-- 效果：
-- ①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c33420078.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33420078,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c33420078.cost)
	e1:SetTarget(c33420078.target)
	e1:SetOperation(c33420078.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：从手牌选择1张卡返回卡组最上面，作为发动效果的代价。
function c33420078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中是否存在至少1张可以作为代价返回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 进行选择提示：显示“请选择要返回卡组的卡”，让玩家选择要返回卡组的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择1张满足条件的卡，作为发动代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送回持有者卡组最顶端，并视为支付代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 目标与条件检查：确认自己场上主要怪兽区有空位，且自身能够被特殊召唤，才能发动。
function c33420078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本连锁即将把该怪兽特殊召唤，用于给其他卡或效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡特殊召唤，若特殊召唤成功，则给它附加离场时除外的不入连锁效果。
function c33420078.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡仍与发动效果关联且特殊召唤成功；是则继续执行后续的除外效果附加。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
