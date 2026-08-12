--幻奏の音姫プロディジー・モーツァルト
-- 效果：
-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族·光属性怪兽特殊召唤。
function c3395226.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族·光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3395226,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c3395226.spcost)
	e1:SetTarget(c3395226.sptg)
	e1:SetOperation(c3395226.spop)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合中特殊召唤的光属性怪兽数量。
	Duel.AddCustomActivityCounter(3395226,ACTIVITY_SPSUMMON,c3395226.counterfilter)
end
-- 过滤函数，判断一张卡是否为光属性。
function c3395226.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果发动时，为玩家注册一个永续效果，使其在该回合不能特殊召唤非光属性的怪兽。
function c3395226.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合是否已经进行过特殊召唤操作。
	if chk==0 then return Duel.GetCustomActivityCount(3395226,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响全场的永续效果，禁止玩家特殊召唤非光属性的怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c3395226.splimit)
	-- 将上述效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 该函数用于判断一张怪兽是否为非光属性，从而决定是否禁止其特殊召唤。
function c3395226.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetAttribute()~=ATTRIBUTE_LIGHT
end
-- 过滤函数，用于筛选手牌中可以特殊召唤的天使族·光属性怪兽。
function c3395226.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理的目标，确定效果发动时会特殊召唤的卡。
function c3395226.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c3395226.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的信息，表明本次效果将特殊召唤一张怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，选择并特殊召唤符合条件的怪兽。
function c3395226.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空间进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家手牌中选择一张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c3395226.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
