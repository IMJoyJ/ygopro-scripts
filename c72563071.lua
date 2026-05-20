--サイコ・ショックウェーブ
-- 效果：
-- ①：对方把陷阱卡发动时，从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1只机械族·暗属性·6星怪兽特殊召唤。
function c72563071.initial_effect(c)
	-- ①：对方把陷阱卡发动时，从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1只机械族·暗属性·6星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c72563071.condition)
	e1:SetCost(c72563071.cost)
	e1:SetTarget(c72563071.target)
	e1:SetOperation(c72563071.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方发动了陷阱卡（卡片的发动）。
function c72563071.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤函数：手牌中可丢弃的魔法·陷阱卡。
function c72563071.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 检查并执行发动代价：从手牌丢弃1张魔法·陷阱卡。
function c72563071.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可丢弃的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c72563071.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌丢弃1张魔法·陷阱卡作为发动代价。
	Duel.DiscardHand(tp,c72563071.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：卡组中可以特殊召唤的6星·暗属性·机械族怪兽。
function c72563071.spfilter(c,e,tp)
	return c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域空格和卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function c72563071.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c72563071.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽特殊召唤。
function c72563071.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c72563071.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
