--ワイトプリンス
-- 效果：
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：这张卡被送去墓地的场合才能发动。「白骨」「白骨夫人」各1只从手卡·卡组送去墓地。
-- ③：从自己墓地把2只其他的「白骨」和这张卡除外才能发动。从卡组把1只「白骨王」特殊召唤。
function c57473560.initial_effect(c)
	-- 设置这张卡在墓地存在时卡名当作「白骨」使用
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- ②：这张卡被送去墓地的场合才能发动。「白骨」「白骨夫人」各1只从手卡·卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57473560,0))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c57473560.tgtg)
	e2:SetOperation(c57473560.tgop)
	c:RegisterEffect(e2)
	-- ③：从自己墓地把2只其他的「白骨」和这张卡除外才能发动。从卡组把1只「白骨王」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57473560,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c57473560.spcost)
	e3:SetTarget(c57473560.sptg)
	e3:SetOperation(c57473560.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：指定卡号且可以送去墓地的卡片
function c57473560.tgfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end
-- 效果②的发动检测与效果处理目标确定函数
function c57473560.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己的手卡或卡组是否存在可以送去墓地的「白骨」
	if chk==0 then return Duel.IsExistingMatchingCard(c57473560.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,32274490)
		-- 并且自己的手卡或卡组存在可以送去墓地的「白骨夫人」
		and Duel.IsExistingMatchingCard(c57473560.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,40991587) end
	-- 设置操作信息：从手卡或卡组将2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理（送去墓地）
function c57473560.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡·卡组中所有可以送去墓地的「白骨」
	local g1=Duel.GetMatchingGroup(c57473560.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,32274490)
	-- 获取自己手卡·卡组中所有可以送去墓地的「白骨夫人」
	local g2=Duel.GetMatchingGroup(c57473560.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,40991587)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的卡片因效果送去墓地
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
-- 过滤条件：墓地中可以作为代价除外的「白骨」
function c57473560.cfilter(c)
	return c:IsCode(32274490) and c:IsAbleToRemoveAsCost()
end
-- 效果③的发动代价检测与执行函数
function c57473560.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 代价检测：检查自己墓地中是否存在除这张卡以外的2只「白骨」
		and Duel.IsExistingMatchingCard(c57473560.cfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择2张除这张卡以外的「白骨」
	local g=Duel.SelectMatchingCard(tp,c57473560.cfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡片作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的「白骨王」
function c57473560.spfilter(c,e,tp)
	return c:IsCode(36021814) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动检测与效果处理目标确定函数
function c57473560.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在可以特殊召唤的「白骨王」
		and Duel.IsExistingMatchingCard(c57473560.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（特殊召唤）
function c57473560.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理：检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1张符合特殊召唤条件的「白骨王」
	local g=Duel.SelectMatchingCard(tp,c57473560.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
