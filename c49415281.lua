--シンクロ・エマージェンシー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。只有对方场上才有怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：从手卡把1只怪兽效果无效特殊召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，可以再从卡组把1只「同调士」怪兽特殊召唤。这张卡的发动后，直到下个回合的结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。进行1只同调怪兽的同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（手卡特召且可追召「同调士」并限制额外卡组特召）、②效果（墓地除外进行同调召唤）以及手卡发动允许效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。 ①：从手卡把1只怪兽效果无效特殊召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，可以再从卡组把1只「同调士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。进行1只同调怪兽的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	-- 设置②效果的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
	-- 只有对方场上才有怪兽存在的场合，这张卡的发动从手卡也能用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"适用「同调紧急」的效果来发动"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
-- 筛选条件：检查手卡中的卡片是否可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检测：确认己方怪兽区有空位且手卡存在可特殊召唤的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方主要怪兽区有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查（后半）：确认己方手卡存在至少1只可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记连锁的特殊召唤操作信息，预计从己方手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 筛选条件：检查卡片是否为从额外卡组特殊召唤的怪兽
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 筛选条件：检查卡片是否为可特殊召唤的「同调士」怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理前半部分：从手卡选1只怪兽效果无效特殊召唤；若对方场上有额外卡组特召的怪兽，则可选再从卡组特召1只「同调士」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查己方主要怪兽区是否存在可用空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向己方提示选择要从手卡特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从己方手卡选择1只可特殊召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 执行分步特殊召唤，将所选手卡怪兽以表侧表示特殊召唤到己方场上
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成分步特殊召唤并统一触发召唤相关时点
			Duel.SpecialSummonComplete()
			-- 检查特殊召唤后己方怪兽区是否仍有空位
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查对方怪兽区是否存在从额外卡组特殊召唤的怪兽
				and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
				-- 检查己方卡组中是否存在可特殊召唤的「同调士」怪兽
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
				-- 询问己方是否再从卡组特殊召唤1只「同调士」怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再特殊召唤？"
				-- 中断效果处理，使卡组特殊召唤与前面的手卡特殊召唤视为不同时处理
				Duel.BreakEffect()
				-- 向己方提示选择要从卡组特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让己方从己方卡组选择1只「同调士」怪兽
				local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				-- 将所选「同调士」怪兽以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这张卡的发动后，直到下个回合的结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))  --"「同调紧急」效果适用中"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END,2)
	-- 为己方玩家注册持续至下个回合结束时的额外卡组特殊召唤限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制过滤函数：禁止从额外卡组特殊召唤非同调怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动检测与连锁信息设置：确认己方额外卡组存在满足当前素材可同调召唤的怪兽，并登记额外卡组特殊召唤操作信息
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方额外卡组存在可以以当前场上素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 登记连锁的特殊召唤操作信息，预计从己方额外卡组同调召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理流程：获取所有可同调召唤的额外怪兽并由己方选择1只进行同调召唤
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组当前可同调召唤的全部怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		-- 向己方提示选择要同调召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 对所选额外卡组怪兽执行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 从手卡发动条件检查：确认己方怪兽区没有怪兽且对方怪兽区存在怪兽
function s.handcon(e)
	-- 检查己方怪兽区怪兽数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
		-- 检查对方怪兽区怪兽数量是否大于0
		and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
