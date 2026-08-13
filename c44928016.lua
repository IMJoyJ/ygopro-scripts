--にん人
-- 效果：
-- 「胡萝卜人」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把「胡萝卜人」以外的1只植物族怪兽送去墓地才能发动。这张卡从墓地特殊召唤。
function c44928016.initial_effect(c)
	-- 「胡萝卜人」的效果1回合只能使用1次。①：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把「胡萝卜人」以外的1只植物族怪兽送去墓地才能发动。这张卡从墓地特殊召唤。
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
-- 代价候选过滤条件：满足植物族、（在手牌或自己场上表侧表示）、不是胡萝卜人、可作为代价送去墓地，且当没有可用特殊召唤区域时只能选自己主要怪兽区的怪兽。
function c44928016.cfilter(c,ft)
	return c:IsRace(RACE_PLANT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and not c:IsCode(44928016) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- 发动代价处理：确定自己主要怪兽区与额外怪兽区的可用空格数；若没有空格则只能从自己场上主要怪兽区选择，否则可从手牌和自己场上表侧表示怪兽中选择；玩家选择1只符合条件的植物族怪兽送去墓地作为发动代价。
function c44928016.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上主要怪兽区域与额外怪兽区域的可用空格数，用于判断特殊召唤的可行性与代价选择范围。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft==0 then loc=LOCATION_MZONE end
	-- 代价检查阶段：确认存在符合条件的植物族怪兽可作为代价，且自己场上存在可用怪兽区域或可通过送墓场上怪兽腾出区域的余地。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c44928016.cfilter,tp,loc,0,1,nil,ft) end
	-- 显示选择提示文字“请选择要送去墓地的卡”，引导玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从符合条件的候选卡中选择1张植物族怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c44928016.cfilter,tp,loc,0,1,1,nil,ft)
	-- 将选中的卡以代价方式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤的合法性与登记：确认墓地中的这张卡能够被特殊召唤，并登记后续要特殊召唤它的操作信息。
function c44928016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将“特殊召唤这张卡”的信息写入当前连锁，供其他效果（如星尘龙、王家长眠之谷等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若这张卡仍然与当前效果关联，则将它特殊召唤。
function c44928016.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地中的这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
