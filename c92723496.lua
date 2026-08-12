--竜宮のツガイ
-- 效果：
-- 「龙宫的双使者」的效果1回合只能使用1次。
-- ①：把手卡1只怪兽丢弃才能发动。从卡组把1只4星以下的幻龙族怪兽特殊召唤。
function c92723496.initial_effect(c)
	-- 「龙宫的双使者」的效果1回合只能使用1次。①：把手卡1只怪兽丢弃才能发动。从卡组把1只4星以下的幻龙族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,92723496)
	e3:SetCost(c92723496.spcost)
	e3:SetTarget(c92723496.sptg)
	e3:SetOperation(c92723496.spop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中可以丢弃的怪兽卡
function c92723496.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动的代价：丢弃手卡中的1只怪兽
function c92723496.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92723496.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中的1只怪兽丢弃
	Duel.DiscardHand(tp,c92723496.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中等级4以下、可以特殊召唤的幻龙族怪兽
function c92723496.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c92723496.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的幻龙族怪兽
		and Duel.IsExistingMatchingCard(c92723496.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的幻龙族怪兽特殊召唤
function c92723496.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的幻龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c92723496.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
