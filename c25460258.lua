--ダークフレア・ドラゴン
-- 效果：
-- 这张卡可以把自己墓地的光属性和暗属性的怪兽各1只从游戏中除外，从手卡特殊召唤。1回合1次，可以从手卡和卡组把龙族怪兽各1只送去墓地，选择自己或者对方的墓地1张卡从游戏中除外。
function c25460258.initial_effect(c)
	-- 这张卡可以把自己墓地的光属性和暗属性的怪兽各1只从游戏中除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c25460258.spcon)
	e1:SetTarget(c25460258.sptg)
	e1:SetOperation(c25460258.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从手卡和卡组把龙族怪兽各1只送去墓地，选择自己或者对方的墓地1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25460258,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c25460258.rmcost)
	e2:SetTarget(c25460258.rmtg)
	e2:SetOperation(c25460258.rmop)
	c:RegisterEffect(e2)
end
-- 用于筛选墓地中的光属性和暗属性怪兽作为特殊召唤的除外费用。
function c25460258.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 检查是否满足特殊召唤条件：场上有空怪兽区且墓地有符合条件的光暗属性怪兽。
function c25460258.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有空怪兽区。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取玩家墓地中所有符合条件的怪兽组。
	local g=Duel.GetMatchingGroup(c25460258.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查该组中是否存在满足条件的两张怪兽（一张光属性一张暗属性）。
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 设置特殊召唤时的选择目标，选择两张符合条件的怪兽。
function c25460258.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地中所有符合条件的怪兽组。
	local g=Duel.GetMatchingGroup(c25460258.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽组中选择两张满足光暗属性条件的怪兽。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作，将选中的怪兽除外并特殊召唤。
function c25460258.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的怪兽从游戏中除外。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 用于筛选手卡或卡组中的龙族怪兽作为效果发动的费用。
function c25460258.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- 检查手卡和卡组中是否存在龙族怪兽。
function c25460258.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25460258.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查卡组中是否存在龙族怪兽。
		and Duel.IsExistingMatchingCard(c25460258.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡中选择一张龙族怪兽送去墓地。
	local g1=Duel.SelectMatchingCard(tp,c25460258.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张龙族怪兽送去墓地。
	local g2=Duel.SelectMatchingCard(tp,c25460258.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	g1:Merge(g2)
	-- 将选择的龙族怪兽送去墓地作为效果发动的费用。
	Duel.SendtoGrave(g1,REASON_COST)
end
-- 设置效果发动时的目标选择，选择墓地中的一张卡。
function c25460258.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查场上是否存在可以除外的墓地卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张墓地中的卡作为除外对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local p=g:GetFirst():GetControler()
	-- 设置效果操作信息，确定要除外的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,p,LOCATION_GRAVE)
end
-- 执行效果，将选中的墓地卡从游戏中除外。
function c25460258.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
