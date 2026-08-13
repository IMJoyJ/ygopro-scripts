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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己对7星以上的怪兽的上级召唤成功的场合，把这张卡除外才能发动。对方场上的怪兽全部变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41215808,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,41215808)
	e2:SetCondition(c41215808.poscon)
	-- 为②效果设置发动代价：把墓地中的这张卡除外（作为发动COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c41215808.postg)
	e2:SetOperation(c41215808.posop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件函数：判定当前阶段是否为主要阶段1或主要阶段2，即自己·对方的主要阶段才能发动。
function c41215808.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量ph，用于后续判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 定义①效果可召唤怪兽的筛选条件：等级4以下、鸟兽族、且当前可以不使用解放进行通常召唤（忽略通常召唤次数限制）。
function c41215808.sumfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsSummonable(true,nil)
end
-- ①效果的发动时点目标处理：检查是否存在符合条件的可召唤怪兽，并设置操作信息为“召唤”。
function c41215808.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查（chk==0）时，确认手牌或我方主要怪兽区存在至少1只满足条件的4星以下鸟兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41215808.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置本次效果处理类别为“召唤”，预定处理1只怪兽的召唤（具体怪兽在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①效果的实际处理：从符合条件的怪兽中选择1只，进行无视本回合通常召唤次数限制的通常召唤。
function c41215808.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示，提示内容为“请选择要召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让当前玩家从手牌和我方主要怪兽区中选择1只满足条件的4星以下鸟兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c41215808.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以通常召唤的方式特殊处理（非里侧，且不消耗本回合通常召唤次数，不通过其他效果召唤）。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 定义②效果触发条件的怪兽判定：该怪兽由tp玩家上级召唤成功、等级7以上、且召唤方式为上级召唤。
function c41215808.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- ②效果的触发条件：这次通常召唤成功的怪兽中存在由我方上级召唤的7星以上怪兽。
function c41215808.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41215808.cfilter,1,nil,tp)
end
-- 定义②效果可变为里侧守备表示的对方怪兽筛选条件：表侧表示且当前可以被变成里侧守备表示。
function c41215808.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果发动时的目标处理：确认对方场上有至少1只满足条件的怪兽，并设置操作信息为变更表示形式。
function c41215808.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查时，确认对方场上存在表侧表示且可被变里侧守备表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41215808.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上全部满足条件的表侧表示怪兽组（不取对象，处理时确定）。
	local g=Duel.GetMatchingGroup(c41215808.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置本次效果处理类别为“变更表示形式”，目标组为对方场上符合条件的怪兽，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的实际处理：将对方场上所有符合条件的表侧表示怪兽变为里侧守备表示。
function c41215808.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上当前仍满足条件的怪兽，用于实际变更（处理时可能因连锁而有变化）。
	local g=Duel.GetMatchingGroup(c41215808.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变为里侧守备表示。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
