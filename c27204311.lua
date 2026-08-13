--原始生命態ニビル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把5只以上的怪兽召唤·特殊召唤的自己·对方回合的主要阶段才能发动。自己·对方场上的表侧表示怪兽尽可能解放，这张卡从手卡特殊召唤。那之后，在对方场上把1只「原始生命态衍生物」（岩石族·光·11星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成这个效果解放的怪兽的原本的攻击力·守备力各自合计数值。
function c27204311.initial_effect(c)
	-- ①：对方把5只以上的怪兽召唤·特殊召唤的自己·对方回合的主要阶段才能发动。自己·对方场上的表侧表示怪兽尽可能解放，这张卡从手卡特殊召唤。那之后，在对方场上把1只「原始生命态衍生物」（岩石族·光·11星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成这个效果解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27204311,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27204311)
	e1:SetCondition(c27204311.spcon)
	e1:SetTarget(c27204311.sptg)
	e1:SetOperation(c27204311.spop)
	c:RegisterEffect(e1)
	if not c27204311.global_check then
		c27204311.global_check=true
		-- 对方把5只以上的怪兽召唤·特殊召唤的自己·对方回合的主要阶段才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c27204311.checkop)
		-- 将监听通常召唤成功的全局持续效果注册到环境中，用于累计对方玩家本回合通常召唤的怪兽数量。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将监听特殊召唤成功的全局持续效果注册到环境中，用于累计对方玩家本回合特殊召唤的怪兽数量。
		Duel.RegisterEffect(ge2,0)
	end
end
-- checkop操作函数：当有怪兽召唤/特殊召唤成功时，遍历本次成功召唤的每只怪兽，给对应的召唤者累计一次本回合的召唤·特殊召唤计数。
function c27204311.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为本次召唤/特殊召唤怪兽的召唤玩家注册一个27204311号flag标记，持续到回合结束，每次召唤/特殊召唤增加1个标记。
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),27204311,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- spcon发动条件函数：确认对方玩家本回合召唤·特殊召唤怪兽数量≥5，且当前阶段为主要阶段1或2；如果己方适用皇帝斗技场，还需额外计算解放后双方场上怪兽数满足斗技场限制。
function c27204311.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方玩家是否受到“皇帝斗技场”效果影响，若影响则需在发动条件中额外处理解放后双方怪兽数量的比较。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_KAISER_COLOSSEUM) then
		-- 取得己方场上怪兽区的怪兽总数（用于皇帝斗技场条件下的数量比较）。
		local t1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 取得对方场上怪兽区的怪兽总数（用于皇帝斗技场条件下的数量比较）。
		local t2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 统计己方场上满足解放条件（表侧且可被效果解放）的怪兽数量。
		local c1=Duel.GetMatchingGroupCount(c27204311.relfilter,tp,LOCATION_MZONE,0,nil)
		-- 统计对方场上满足解放条件（表侧且可被效果解放）的怪兽数量。
		local c2=Duel.GetMatchingGroupCount(c27204311.relfilter,tp,0,LOCATION_MZONE,nil)
		if t1-c1 >= t2-c2 then return false end
	end
	-- 最终发动条件判定：对方玩家的召唤·特殊召唤计数≥5，且当前为主要阶段1或2；若皇帝斗技场适用，解放后己方场上剩余怪兽数必须小于对方剩余怪兽数。
	return Duel.GetFlagEffect(1-tp,27204311)>=5 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- relfilter过滤器：判定怪兽是否可被效果解放，要求表侧表示且能被效果解放。
function c27204311.relfilter(c)
	return c:IsFaceup() and c:IsReleasableByEffect()
end
-- adfilter辅助函数：将传入的攻击力/守备力数值与0取最大值，确保合计值不为负。
function c27204311.adfilter(c,f)
	return math.max(f(c),0)
end
-- sptg发动目标函数：确认发动时满足所有前提——场上存在表侧怪兽、双方怪兽区解放后有空格、己方可以解放、本回合可特殊召唤次数≥2、此卡可从手卡特殊召唤，且能够将攻守为表侧怪兽攻守合计的衍生物特殊召唤到对方场上；并设置操作信息。
function c27204311.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得双方场上全部表侧表示怪兽的集合，作为“尽可能解放”的候选对象和计算衍生物攻守的基数。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- chk==0时的合法性检查：场上存在表侧怪兽，且解放这些怪兽后自己与对方场上仍各有至少1个可用怪兽区域，用于后续特殊召唤此卡和衍生物。
	if chk==0 then return g:GetCount()>0 and Duel.GetMZoneCount(tp,g)>0 and Duel.GetMZoneCount(1-tp,g,tp)>0
		-- 确认己方玩家当前允许进行解放操作（没有被禁止解放）。
		and Duel.IsPlayerCanRelease(tp)
		-- 确认己方玩家本回合仍可进行至少2次特殊召唤（因为后续要特殊召唤此卡和衍生物）。
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认可以将衍生物（岩石族·光·11星，攻守为场上表侧怪兽攻守合计）特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27204312,0,TYPES_TOKEN_MONSTER,g:GetSum(c27204311.adfilter,Card.GetTextAttack),g:GetSum(c27204311.adfilter,Card.GetTextDefense),11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp) end
	-- 设置操作信息：本次效果处理中将包含衍生物特殊召唤（预计1只）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果处理中将包含特殊召唤此卡（共2次特殊召唤，此卡和衍生物）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),2,0,0)
end
-- spop效果处理函数：解放双方场上所有可解放的表侧怪兽，若解放成功则将此卡从手卡特殊召唤；成功后，在对方场上特殊召唤1只「原始生命态衍生物」，其攻守为被解放怪兽原本攻守的合计值。
function c27204311.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上满足解放条件（表侧且可效果解放）的所有怪兽集合，作为“尽可能解放”的实际处理对象。
	local g=Duel.GetMatchingGroup(c27204311.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 若存在可解放的怪兽，则将这些怪兽全部解放（REASON_EFFECT）；解放操作成功（返回非0）才继续后续处理。
	if g:GetCount()>0 and Duel.Release(g,REASON_EFFECT)~=0 then
		-- 获取刚才解放操作中实际被解放的怪兽组，用于计算衍生物的攻击力·守备力。
		local og=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		-- 确认此卡仍与效果相关后，将其从手卡特殊召唤到自己场上；只有特殊召唤成功才继续衍生物处理。
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			if og:GetCount()==0 then return end
			local atk=og:GetSum(c27204311.adfilter,Card.GetTextAttack)
			local def=og:GetSum(c27204311.adfilter,Card.GetTextDefense)
			-- 确认对方怪兽区仍有可用空格，以便特殊召唤衍生物。
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
				-- 确认能够将一只攻击力为atk、守备力为def的岩石族·光·11星衍生物以表侧表示特殊召唤到对方场上。
				and Duel.IsPlayerCanSpecialSummonMonster(tp,27204312,0,TYPES_TOKEN_MONSTER,atk,def,11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp) then
				-- 中断当前效果处理，使后续的衍生物特殊召唤在时点上独立处理，避免错过衍生物特殊召唤成功的时点。
				Duel.BreakEffect()
				-- 以自己的名义创建1只「原始生命态衍生物」（卡号27204312）。
				local token=Duel.CreateToken(tp,27204312)
				-- 这衍生物的攻击力变成这个效果解放的怪兽的原本的攻击力各自合计数值。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				token:RegisterEffect(e1)
				-- 这衍生物的守备力变成这个效果解放的怪兽的原本的守备力各自合计数值。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_DEFENSE)
				e2:SetValue(def)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				token:RegisterEffect(e2)
				-- 将衍生物以表侧攻击表示特殊召唤到对方场上。
				Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
