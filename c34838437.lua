--アクセル・ライト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能通常召唤。
-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把4星以下的1只「光子」怪兽或者「银河」怪兽特殊召唤。
function c34838437.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34838437+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c34838437.condition)
	e1:SetCost(c34838437.cost)
	e1:SetTarget(c34838437.target)
	e1:SetOperation(c34838437.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断发动时自己场上是否没有怪兽
function c34838437.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断发动时自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果作用：设置发动时的费用，禁止发动回合内通常召唤和覆盖召唤
function c34838437.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断发动回合内是否已经进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 效果原文内容：①：自己场上没有怪兽存在的场合才能发动。从卡组把4星以下的1只「光子」怪兽或者「银河」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 效果作用：注册不能通常召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 效果作用：注册不能覆盖召唤的效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果作用：定义过滤函数，筛选4星以下的「光子」或「银河」怪兽
function c34838437.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x55,0x7b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置发动时的处理目标，检查是否满足特殊召唤条件
function c34838437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c34838437.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行效果处理，选择并特殊召唤符合条件的怪兽
function c34838437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c34838437.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
