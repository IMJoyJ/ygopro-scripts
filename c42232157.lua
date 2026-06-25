--運命の盤上
local s,id,o=GetID()
-- 注册特召手牌·墓地通常怪兽，以及展示手牌通常怪兽可以在盖放回合发动的两个效果
function s.initial_effect(c)
	-- ①：可以从自己的手卡·墓地将最多5只通常怪兽以攻击表示特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 可以将手卡的1只通常怪兽给对方观看，这张卡可以在盖放的回合发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetValue(id)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
-- 过滤条件：可以以攻击表示特殊召唤的通常怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果①的Target函数：检查自己场上是否有空怪兽区域且手牌或墓地是否有可特召的通常怪兽，并设置特召的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手牌或墓地是否存在至少1只可特召的通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前效果的操作信息为从手牌或墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的Operation函数：在满足条件时从手牌·墓地选择最多5只通常怪兽以攻击表示特殊召唤，并注册本回合不能从额外卡组特殊召唤怪兽的限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己怪兽区域的空位数
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>5 then ct=5 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 如果自己场上的怪兽区域有空位且可召唤的数量大于0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0
		-- 且手牌或墓地中存在至少1只可特召的通常怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌·墓地选择最多相当于空位数（且上限为5）的通常怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ct,nil,e,tp)
		-- 将所选的通常怪兽以攻击表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡发动后，直到回合结束时自己不能从额外卡组特殊召唤怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制玩家特殊召唤的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特召限制的Target函数：限制从额外卡组进行特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 可在盖放回合发动效果的Condition条件函数：检查此卡是否处于被盖放的回合，且在场上存在
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手牌中未公开的通常怪兽
function s.costfilter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsPublic()
end
-- 盖放回合发动的Cost函数：选择手牌中1只未公开的通常怪兽给对方确认
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可以公开的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手牌中1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗涤自己的手牌
	Duel.ShuffleHand(tp)
end
