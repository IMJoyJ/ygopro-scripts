--伝説の預言者マーリン
-- 效果：
-- 「传说的预言者 梅林」的①②③的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「圣骑士」怪兽特殊召唤。这个效果发动的回合，自己不是「圣骑士」怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。把1只「圣骑士」同调怪兽同调召唤。这个效果在对方回合也能发动。
-- ③：把墓地的这张卡除外才能发动。把1只「圣骑士」超量怪兽超量召唤。这个效果在对方回合也能发动。
function c3580032.initial_effect(c)
	-- 「传说的预言者 梅林」的①的效果1回合各能使用1次。①：把这张卡解放才能发动。从卡组把1只「圣骑士」怪兽特殊召唤。这个效果发动的回合，自己不是「圣骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,3580032)
	e1:SetCost(c3580032.spcost)
	e1:SetTarget(c3580032.sptg)
	e1:SetOperation(c3580032.spop)
	c:RegisterEffect(e1)
	-- 「传说的预言者 梅林」的②的效果1回合各能使用1次。②：把墓地的这张卡除外才能发动。把1只「圣骑士」同调怪兽同调召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3580032,0))  --"把1只「圣骑士」同调怪兽同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,3580033)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3580032.sctg)
	e2:SetOperation(c3580032.scop)
	c:RegisterEffect(e2)
	-- 「传说的预言者 梅林」的③的效果1回合各能使用1次。③：把墓地的这张卡除外才能发动。把1只「圣骑士」超量怪兽超量召唤。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3580032,1))  --"把1只「圣骑士」超量怪兽超量召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,3580034)
	-- 把墓地的这张卡除外作为发动代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c3580032.xyztg)
	e3:SetOperation(c3580032.xyzop)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，用来检测玩家特殊召唤的怪兽是否为「圣骑士」怪兽
	Duel.AddCustomActivityCounter(3580032,ACTIVITY_SPSUMMON,c3580032.counterfilter)
end
-- 自定义活动计数器的过滤函数：判断特殊召唤的怪兽是否为表侧表示的「圣骑士」怪兽
function c3580032.counterfilter(c)
	return c:IsSetCard(0x107a) and c:IsFaceup()
end
-- 检测是否满足发动条件：这张卡可以被解放，且本回合自己特殊召唤过的必须全是「圣骑士」怪兽
function c3580032.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检测本回合自己是否特殊召唤过「圣骑士」怪兽以外的怪兽
		and Duel.GetCustomActivityCount(3580032,tp,ACTIVITY_SPSUMMON)==0 end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 这个效果发动的回合，自己不是「圣骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c3580032.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给发动效果的玩家注册不能特殊召唤非「圣骑士」怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：不能特殊召唤非「圣骑士」怪兽
function c3580032.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x107a)
end
-- 过滤函数：卡组中可特殊召唤的「圣骑士」怪兽
function c3580032.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测是否满足发动条件：场上有可用的主要怪兽区域且卡组有符合条件的特殊召唤对象
function c3580032.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否有可用的主要怪兽区域（此处解放自身会让出1个格子，所以大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检测卡组是否存在符合条件的「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(c3580032.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤1只「圣骑士」怪兽
function c3580032.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的主要怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c3580032.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：额外卡组中可同调召唤的「圣骑士」同调怪兽
function c3580032.scfilter(c)
	return c:IsSetCard(0x107a) and c:IsSynchroSummonable(nil)
end
-- 检测额外卡组是否存在可以同调召唤的「圣骑士」同调怪兽并设置操作信息
function c3580032.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测额外卡组中是否存在可以同调召唤的「圣骑士」同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3580032.scfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将额外卡组的1只「圣骑士」同调怪兽进行同调召唤
function c3580032.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中可以进行同调召唤的「圣骑士」同调怪兽的卡群
	local g=Duel.GetMatchingGroup(c3580032.scfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 向玩家发送选择特殊召唤怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 过滤函数：额外卡组中可超量召唤的「圣骑士」超量怪兽
function c3580032.xyzfilter(c)
	return c:IsSetCard(0x107a) and c:IsXyzSummonable(nil)
end
-- 检测额外卡组是否存在可以超量召唤的「圣骑士」超量怪兽并设置操作信息
function c3580032.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测额外卡组中是否存在可以超量召唤的「圣骑士」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3580032.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将额外卡组的1只「圣骑士」超量怪兽进行超量召唤
function c3580032.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中可以进行超量召唤的「圣骑士」超量怪兽的卡群
	local g=Duel.GetMatchingGroup(c3580032.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 向玩家发送选择特殊召唤怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 对选中的怪兽进行超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
