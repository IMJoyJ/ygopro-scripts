--サモン・ストーム
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：支付800基本分才能发动。从手卡把1只6星以下的风属性怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只4星以下的风属性怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c71459861.initial_effect(c)
	-- ①：支付800基本分才能发动。从手卡把1只6星以下的风属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71459861,0))  --"从手卡把1只6星以下的风属性怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c71459861.cost)
	e1:SetTarget(c71459861.target)
	e1:SetOperation(c71459861.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只4星以下的风属性怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71459861,1))  --"从手卡把1只4星以下的风属性怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,71459861)
	-- 设置发动条件为这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c71459861.sptg)
	e2:SetOperation(c71459861.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数：检查并支付800基本分
function c71459861.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤函数：手卡中可以特殊召唤的6星以下的风属性怪兽
function c71459861.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）函数：检查怪兽区域空位及手卡中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c71459861.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c71459861.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（Operation）函数：从手卡选择1只6星以下的风属性怪兽特殊召唤
function c71459861.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c71459861.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：手卡中可以特殊召唤的4星以下的风属性怪兽
function c71459861.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）函数：检查怪兽区域空位及手卡中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c71459861.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c71459861.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理（Operation）函数：从手卡选择1只4星以下的风属性怪兽特殊召唤
function c71459861.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c71459861.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
