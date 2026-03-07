--伝説の預言者マーリン
-- 效果：
-- 「传说的预言者 梅林」的①②③的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「圣骑士」怪兽特殊召唤。这个效果发动的回合，自己不是「圣骑士」怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。把1只「圣骑士」同调怪兽同调召唤。这个效果在对方回合也能发动。
-- ③：把墓地的这张卡除外才能发动。把1只「圣骑士」超量怪兽超量召唤。这个效果在对方回合也能发动。
function c3580032.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把1只「圣骑士」怪兽特殊召唤。这个效果发动的回合，自己不是「圣骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,3580032)
	e1:SetCost(c3580032.spcost)
	e1:SetTarget(c3580032.sptg)
	e1:SetOperation(c3580032.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。把1只「圣骑士」同调怪兽同调召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3580032,0))  --"把1只「圣骑士」同调怪兽同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,3580033)
	-- 将墓地的这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3580032.sctg)
	e2:SetOperation(c3580032.scop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。把1只「圣骑士」超量怪兽超量召唤。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3580032,1))  --"把1只「圣骑士」超量怪兽超量召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,3580034)
	-- 将墓地的这张卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c3580032.xyztg)
	e3:SetOperation(c3580032.xyzop)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于限制每回合只能发动一次效果
	Duel.AddCustomActivityCounter(3580032,ACTIVITY_SPSUMMON,c3580032.counterfilter)
end
-- 计数器的过滤函数，只统计「圣骑士」卡
function c3580032.counterfilter(c)
	return c:IsSetCard(0x107a)
end
-- 效果①的费用函数，检查是否可以解放此卡且本回合未发动过效果①
function c3580032.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查本回合是否已发动过效果①
		and Duel.GetCustomActivityCount(3580032,tp,ACTIVITY_SPSUMMON)==0 end
	-- 将此卡解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 创建一个永续效果，使自己不能特殊召唤非「圣骑士」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c3580032.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果①的限制函数，禁止召唤非「圣骑士」怪兽
function c3580032.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x107a)
end
-- 效果①的过滤函数，筛选可特殊召唤的「圣骑士」怪兽
function c3580032.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件函数，检查是否有足够的召唤位置和满足条件的卡
function c3580032.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查是否有满足条件的「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(c3580032.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，选择并特殊召唤1只「圣骑士」怪兽
function c3580032.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c3580032.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的过滤函数，筛选可同调召唤的「圣骑士」同调怪兽
function c3580032.scfilter(c)
	return c:IsSetCard(0x107a) and c:IsSynchroSummonable(nil)
end
-- 效果②的发动条件函数，检查是否有满足条件的「圣骑士」同调怪兽
function c3580032.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「圣骑士」同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3580032.scfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表示要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理函数，选择并同调召唤1只「圣骑士」同调怪兽
function c3580032.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「圣骑士」同调怪兽
	local g=Duel.GetMatchingGroup(c3580032.scfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 效果③的过滤函数，筛选可超量召唤的「圣骑士」超量怪兽
function c3580032.xyzfilter(c)
	return c:IsSetCard(0x107a) and c:IsXyzSummonable(nil)
end
-- 效果③的发动条件函数，检查是否有满足条件的「圣骑士」超量怪兽
function c3580032.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「圣骑士」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3580032.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表示要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的处理函数，选择并超量召唤1只「圣骑士」超量怪兽
function c3580032.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「圣骑士」超量怪兽
	local g=Duel.GetMatchingGroup(c3580032.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 进行超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
