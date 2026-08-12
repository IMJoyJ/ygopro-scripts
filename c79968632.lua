--六武衆の影忍術
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只怪兽送去墓地，以除外的1只自己的「六武众」怪兽为对象才能发动。那只怪兽特殊召唤。
function c79968632.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只怪兽送去墓地，以除外的1只自己的「六武众」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,79968632+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c79968632.cost)
	e1:SetTarget(c79968632.target)
	e1:SetOperation(c79968632.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：把自己场上1只怪兽送去墓地
function c79968632.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以作为代价送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只可以作为代价送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：过滤除外状态、表侧表示的「六武众」怪兽，且该怪兽可以被特殊召唤
function c79968632.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检查
function c79968632.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c79968632.filter(chkc,e,tp) end
	-- 检查怪兽区域是否有空位（由于作为代价送去墓地1只怪兽，因此可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并检查除外区是否存在符合条件的「六武众」怪兽
		and Duel.IsExistingTarget(c79968632.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只自己的「六武众」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c79968632.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含特殊召唤的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理（特殊召唤对象怪兽）
function c79968632.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前怪兽区域没有空位，则不进行特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
