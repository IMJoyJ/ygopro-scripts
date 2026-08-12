--メリアスの木霊
-- 效果：
-- 地属性3星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从卡组把1只植物族怪兽送去墓地。
-- ●从自己墓地选择1只植物族怪兽表侧守备表示特殊召唤。
function c64245689.initial_effect(c)
	-- 添加XYZ召唤手续：地属性3星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),3,2)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。●从卡组把1只植物族怪兽送去墓地。●从自己墓地选择1只植物族怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c64245689.cost)
	e1:SetTarget(c64245689.tgtg)
	e1:SetOperation(c64245689.tgop)
	c:RegisterEffect(e1)
end
-- 代价去素材处理：检查并取除这张卡的1个超量素材
function c64245689.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中可送去墓地的植物族怪兽
function c64245689.tgfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 过滤条件：墓地中可以表侧守备表示特殊召唤的植物族怪兽
function c64245689.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动阶段：检查并选择要发动的效果分支，并进行对应的取对象或操作信息设置
function c64245689.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64245689.spfilter(chkc,e,tp) end
	-- 检查卡组中是否存在可送去墓地的植物族怪兽（分支1是否可行）
	local b1=Duel.IsExistingMatchingCard(c64245689.tgfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否有空位且墓地中是否存在可特殊召唤的植物族怪兽（分支2是否可行）
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c64245689.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支均可行时，让玩家选择其中一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(64245689,0),aux.Stringid(64245689,1))  --"卡组植物族怪兽送去墓地/墓地植物族怪兽特殊召唤"
	elseif b1 then
		-- 仅分支1可行时，强制选择分支1（从卡组把植物族怪兽送去墓地）
		op=Duel.SelectOption(tp,aux.Stringid(64245689,0))  --"卡组植物族怪兽送去墓地"
	else
		-- 仅分支2可行时，强制选择分支2（从墓地特殊召唤植物族怪兽）
		op=Duel.SelectOption(tp,aux.Stringid(64245689,1))+1  --"墓地植物族怪兽特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(0)
		-- 设置操作信息：从卡组将1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地中1只满足条件的植物族怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c64245689.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置操作信息：特殊召唤选中的对象怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理阶段：根据发动的分支执行对应的送去墓地或特殊召唤处理
function c64245689.tgop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只满足条件的植物族怪兽
		local g=Duel.SelectMatchingCard(tp,c64245689.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	else
		-- 获取在发动阶段选择的特殊召唤目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
			-- 将目标怪兽表侧守备表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
