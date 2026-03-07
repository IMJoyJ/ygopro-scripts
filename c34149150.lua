--葬角のカルノヴルス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段以及战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只恐龙族同调怪兽的同调召唤。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。从手卡把1只恐龙族怪兽无视召唤条件特殊召唤。这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤和特殊召唤效果
function s.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 设置第一个效果：在主要阶段或战斗阶段才能发动，进行恐龙族同调召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"同调召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	-- 设置第二个效果：攻击宣言时才能发动，从手卡特殊召唤恐龙族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断当前是否处于主要阶段1、战斗阶段开始到结束或主要阶段2
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤满足同调召唤条件且为恐龙族的怪兽
function s.scfilter(c,mc)
	return c:IsSynchroSummonable(mc) and c:IsRace(RACE_DINOSAUR)
end
-- 设置同调召唤效果的目标处理函数，检查是否有符合条件的怪兽
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足同调召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 提示对方玩家已选择该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 设置同调召唤效果的处理函数，执行同调召唤操作
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取满足同调召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤操作
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- 过滤满足特殊召唤条件且为恐龙族的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标处理函数，检查是否有符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 提示对方玩家已选择该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 设置特殊召唤效果的处理函数，执行特殊召唤并设置限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足特殊召唤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	-- 设置限制效果，使自己不能特殊召唤非恐龙族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判断函数，返回非恐龙族怪兽不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DINOSAUR)
end
