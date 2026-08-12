--SRバンブー・ホース
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「疾行机人」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只风属性怪兽送去墓地。这个效果在这张卡送去墓地的回合不能发动。
function c17328157.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「疾行机人」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17328157,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c17328157.sptg)
	e1:SetOperation(c17328157.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只风属性怪兽送去墓地。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17328157,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,17328157)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动这个效果
	e2:SetCondition(aux.exccon)
	-- 设置效果代价为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17328157.tgtg)
	e2:SetOperation(c17328157.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中4星以下且为疾行机人系列的怪兽，满足特殊召唤条件
function c17328157.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2016) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的判断条件，检查手卡是否存在满足条件的怪兽并判断场上是否有空位
function c17328157.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c17328157.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行特殊召唤操作
function c17328157.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c17328157.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选卡组中风属性的怪兽
function c17328157.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动时的判断条件，检查卡组中是否存在满足条件的怪兽
function c17328157.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17328157.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：将1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将怪兽送去墓地的操作
function c17328157.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c17328157.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
