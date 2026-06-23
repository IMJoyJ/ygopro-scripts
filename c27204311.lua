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
		-- 这个卡名的效果1回合只能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c27204311.checkop)
		-- 为玩家0注册一个字段效果，用于记录召唤成功事件
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 为玩家0注册一个字段效果，用于记录特殊召唤成功事件
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当有怪兽召唤成功时，为该怪兽的召唤者注册一个标识效果
function c27204311.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为指定玩家注册一个标识效果，用于记录召唤次数
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),27204311,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 判断是否满足发动条件：对方场上有5只以上召唤或特殊召唤的怪兽，且当前处于主要阶段
function c27204311.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否受到凯撒斗技场效果影响
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_KAISER_COLOSSEUM) then
		-- 获取当前玩家己方场上的怪兽数量
		local t1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 获取当前玩家对方场上的怪兽数量
		local t2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 获取当前玩家己方场上的可解放怪兽数量
		local c1=Duel.GetMatchingGroupCount(c27204311.relfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取当前玩家对方场上的可解放怪兽数量
		local c2=Duel.GetMatchingGroupCount(c27204311.relfilter,tp,0,LOCATION_MZONE,nil)
		if t1-c1 >= t2-c2 then return false end
	end
	-- 判断对方是否已满足5次召唤或特殊召唤的条件，并且当前处于主要阶段
	return Duel.GetFlagEffect(1-tp,27204311)>=5 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤函数，返回场上表侧表示且可因效果被解放的怪兽
function c27204311.relfilter(c)
	return c:IsFaceup() and c:IsReleasableByEffect()
end
-- 过滤函数，返回怪兽的攻击力或守备力，若为负数则返回0
function c27204311.adfilter(c,f)
	return math.max(f(c),0)
end
-- 设置发动时的处理信息，包括召唤衍生物和特殊召唤自身
function c27204311.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方和对方场上的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查是否满足发动条件：场上存在可解放的怪兽，且己方和对方都有可用怪兽区
	if chk==0 then return g:GetCount()>0 and Duel.GetMZoneCount(tp,g)>0 and Duel.GetMZoneCount(1-tp,g,tp)>0
		-- 检查玩家是否可以解放怪兽
		and Duel.IsPlayerCanRelease(tp)
		-- 检查玩家是否可以进行2次特殊召唤
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27204312,0,TYPES_TOKEN_MONSTER,g:GetSum(c27204311.adfilter,Card.GetTextAttack),g:GetSum(c27204311.adfilter,Card.GetTextDefense),11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp) end
	-- 设置操作信息：将要特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),2,0,0)
end
-- 效果处理函数，执行特殊召唤和衍生物的创建
function c27204311.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方和对方场上的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(c27204311.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查是否有可解放的怪兽，并进行解放操作
	if g:GetCount()>0 and Duel.Release(g,REASON_EFFECT)~=0 then
		-- 获取实际被解放的怪兽组
		local og=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		-- 检查自身是否还在场上，并进行特殊召唤
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			if og:GetCount()==0 then return end
			local atk=og:GetSum(c27204311.adfilter,Card.GetTextAttack)
			local def=og:GetSum(c27204311.adfilter,Card.GetTextDefense)
			-- 检查对方场上是否有可用怪兽区
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
				-- 检查玩家是否可以特殊召唤衍生物
				and Duel.IsPlayerCanSpecialSummonMonster(tp,27204312,0,TYPES_TOKEN_MONSTER,atk,def,11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp) then
				-- 中断当前效果处理，使后续效果视为错时处理
				Duel.BreakEffect()
				-- 创建一张编号为27204312的衍生物
				local token=Duel.CreateToken(tp,27204312)
				-- 设置衍生物的攻击力为解放怪兽攻击力总和
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				token:RegisterEffect(e1)
				-- 设置衍生物的守备力为解放怪兽守备力总和
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_DEFENSE)
				e2:SetValue(def)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				token:RegisterEffect(e2)
				-- 将衍生物特殊召唤到对方场上
				Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
