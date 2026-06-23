--ふわんだりぃずと夢の町
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动。把1只4星以下的鸟兽族怪兽召唤。
-- ②：这张卡在墓地存在的状态，自己对7星以上的怪兽的上级召唤成功的场合，把这张卡除外才能发动。对方场上的怪兽全部变成里侧守备表示。
function c41215808.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。把1只4星以下的鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41215808,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c41215808.sumcon)
	e1:SetTarget(c41215808.sumtg)
	e1:SetOperation(c41215808.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己对7星以上的怪兽的上级召唤成功的场合，把这张卡除外才能发动。对方场上的怪兽全部变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41215808,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,41215808)
	e2:SetCondition(c41215808.poscon)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c41215808.postg)
	e2:SetOperation(c41215808.posop)
	c:RegisterEffect(e2)
end
-- 判断是否处于主要阶段1或主要阶段2
function c41215808.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 筛选4星以下的鸟兽族且可通常召唤的怪兽
function c41215808.sumfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsSummonable(true,nil)
end
-- 设置效果处理时要召唤的怪兽
function c41215808.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41215808.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理时要召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 选择并通常召唤一只满足条件的怪兽
function c41215808.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c41215808.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 筛选自己上级召唤且等级7以上的怪兽
function c41215808.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判断是否有满足条件的上级召唤怪兽
function c41215808.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41215808.cfilter,1,nil,tp)
end
-- 筛选场上表侧表示且可变为里侧守备表示的怪兽
function c41215808.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果处理时要改变表示形式的怪兽
function c41215808.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41215808.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c41215808.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理时要改变表示形式的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 将对方场上满足条件的怪兽全部变为里侧守备表示
function c41215808.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c41215808.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 改变怪兽表示形式为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
