--十二獣モルモラット
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从卡组把1张「十二兽」卡送去墓地。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。从手卡·卡组把1只「十二兽 鼠骑」特殊召唤。
function c78872731.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从卡组把1张「十二兽」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78872731,0))  --"从卡组把1张「十二兽」卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c78872731.target)
	e1:SetOperation(c78872731.operation)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●1回合1次，把这张卡1个超量素材取除才能发动。从手卡·卡组把1只「十二兽 鼠骑」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78872731,1))  --"把「十二兽 鼠骑」特殊召唤（十二兽 鼠骑）"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetCondition(c78872731.spcon)
	e2:SetCost(c78872731.spcost)
	e2:SetTarget(c78872731.sptg)
	e2:SetOperation(c78872731.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中属于「十二兽」系列且能送去墓地的卡
function c78872731.tgfilter(c)
	return c:IsSetCard(0xf1) and c:IsAbleToGrave()
end
-- ①效果的发动准备与检测：检查卡组中是否存在可送去墓地的「十二兽」卡，并设置送去墓地的操作信息
function c78872731.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c78872731.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张「十二兽」卡送去墓地
function c78872731.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「十二兽」卡
	local g=Duel.SelectMatchingCard(tp,c78872731.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果发动条件：持有此卡作为素材的怪兽原本种族是兽战士族
function c78872731.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOriginalRace()==RACE_BEASTWARRIOR
end
-- 效果发动代价：取除该怪兽的1个超量素材
function c78872731.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡名为「十二兽 鼠骑」且能特殊召唤的怪兽
function c78872731.spfilter(c,e,tp)
	return c:IsCode(78872731) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 超量素材赋予效果的发动准备与检测：检查怪兽区域是否有空位，以及手卡·卡组是否存在可特殊召唤的「十二兽 鼠骑」，并设置特殊召唤的操作信息
function c78872731.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡或卡组中是否存在至少1张满足特殊召唤条件的「十二兽 鼠骑」
		and Duel.IsExistingMatchingCard(c78872731.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动的效果描述
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁处理的操作信息，表示该效果会从手卡或卡组将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 超量素材赋予效果的处理：从手卡·卡组把1只「十二兽 鼠骑」特殊召唤
function c78872731.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1张满足过滤条件的「十二兽 鼠骑」
	local g=Duel.SelectMatchingCard(tp,c78872731.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
