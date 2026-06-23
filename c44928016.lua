--にん人
-- 效果：
-- 「胡萝卜人」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把「胡萝卜人」以外的1只植物族怪兽送去墓地才能发动。这张卡从墓地特殊召唤。
function c44928016.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、适用区域、发动限制、费用、目标和效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44928016,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,44928016)
	e1:SetCost(c44928016.cost)
	e1:SetTarget(c44928016.target)
	e1:SetOperation(c44928016.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的植物族怪兽作为送去墓地的代价
function c44928016.cfilter(c,ft)
	return c:IsRace(RACE_PLANT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and not c:IsCode(44928016) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- 效果的发动费用处理，检查是否有符合条件的怪兽可以送去墓地并执行送去墓地的操作
function c44928016.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft==0 then loc=LOCATION_MZONE end
	-- 判断是否满足发动条件，即是否有满足条件的怪兽可以作为代价
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c44928016.cfilter,tp,loc,0,1,nil,ft) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡作为送去墓地的代价
	local g=Duel.SelectMatchingCard(tp,c44928016.cfilter,tp,loc,0,1,1,nil,ft)
	-- 将选中的卡送去墓地作为效果的发动费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的目标，确认该卡可以被特殊召唤
function c44928016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表明此效果将特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的处理函数，判断卡是否可以特殊召唤并执行特殊召唤
function c44928016.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
