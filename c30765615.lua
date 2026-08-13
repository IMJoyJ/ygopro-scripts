--百檎龍－リンゴブルム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有效果怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己把同调怪兽同调召唤的回合的自己主要阶段，把墓地的这张卡除外才能发动。在自己场上把1只「百檎衍生物」（幻龙族·光·2星·攻/守100）特殊召唤。自己把这衍生物作为同调素材的场合，可以当作调整使用。
function c30765615.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在，场上有效果怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30765615)
	e1:SetCondition(c30765615.spcon)
	e1:SetTarget(c30765615.sptg)
	e1:SetOperation(c30765615.spop)
	c:RegisterEffect(e1)
	-- ②：自己把同调怪兽同调召唤的回合的自己主要阶段，把墓地的这张卡除外才能发动。在自己场上把1只「百檎衍生物」（幻龙族·光·2星·攻/守100）特殊召唤。自己把这衍生物作为同调素材的场合，可以当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30765616)
	e2:SetCondition(c30765615.tkcon)
	-- 设置②效果的发动代价（COST）：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30765615.tktg)
	e2:SetOperation(c30765615.tkop)
	c:RegisterEffect(e2)
	if not c30765615.global_check then
		c30765615.global_check=true
		-- ①：这张卡在手卡存在，场上有效果怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡特殊召唤。②：自己把同调怪兽同调召唤的回合的自己主要阶段，把墓地的这张卡除外才能发动。在自己场上把1只「百檎衍生物」（幻龙族·光·2星·攻/守100）特殊召唤。自己把这衍生物作为同调素材的场合，可以当作调整使用。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c30765615.checkop)
		-- 将全局监测效果 ge1 注册到决斗环境中（player 0 表示双方），使得任意特殊召唤成功时都触发 checkop，用于记录同调召唤的玩家。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：判断怪兽是否为通过同调召唤方式出场且为同调怪兽（用于在特殊召唤成功事件中筛选同调召唤的怪兽）。
function c30765615.checkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 处理特殊召唤成功事件：从特殊召唤成功的怪兽组 eg 中筛出同调召唤的同调怪兽，逐个为其召唤玩家注册标识30765615（持续到结束阶段），表示该玩家本回合进行过同调召唤。
function c30765615.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c30765615.checkfilter,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为同调召唤的玩家注册标识30765615，重置时机为结束阶段，用于标记该玩家在本回合完成了同调召唤（②效果的发动条件）。
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),30765615,RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
end
-- 过滤函数：判断怪兽为表侧表示且不是效果怪兽（用于①效果的发动条件）。
function c30765615.spcfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- ①效果的发动条件判断：检查双方怪兽区是否存在至少1只表侧表示的非效果怪兽。
function c30765615.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 执行上述检查，返回是否存在至少1只表侧表示的非效果怪兽。
	return Duel.IsExistingMatchingCard(c30765615.spcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的发动目标与合法性判定：获取此卡自身，确认自己怪兽区有空位且手牌中的此卡可以被特殊召唤。
function c30765615.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时（chk==0）检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将特殊召唤1只怪兽（即此卡自身），用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，将其从手牌以表侧表示特殊召唤到自己场上；否则不处理。
function c30765615.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上（不检查召唤条件/苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件判断：检查自己玩家是否拥有标识30765615，即本回合是否进行过同调召唤。
function c30765615.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回玩家 tp 的标识30765615数量是否大于0，满足②效果要求的“自己把同调怪兽同调召唤的回合”。
	return Duel.GetFlagEffect(tp,30765615)>0
end
-- ②效果的发动合法判定：确认自己怪兽区有空位，且玩家能够特殊召唤百檎衍生物。
function c30765615.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家 tp 是否可以特殊召唤百檎衍生物（百檎衍生物为幻龙族·光·2星·攻/守100的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,30765616,0,TYPES_TOKEN_MONSTER,100,100,2,RACE_WYRM,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：本效果将产生1只衍生物，用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果将进行1只怪兽的特殊召唤，用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：若仍有空位且可特殊召唤衍生物，则创建并特殊召唤「百檎衍生物」，同时给该衍生物赋予可作为调整使用的效果，最后完成特殊召唤流程。
function c30765615.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认自己怪兽区仍有空位，没有空位则本次处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认玩家可以特殊召唤百檎衍生物（满足衍生物特殊召唤的合法性）。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,30765616,0,TYPES_TOKEN_MONSTER,100,100,2,RACE_WYRM,ATTRIBUTE_LIGHT) then
		-- 由玩家 tp 创建卡号30765616的衍生物「百檎衍生物」。
		local token=Duel.CreateToken(tp,30765616)
		-- 将衍生物作为特殊召唤的一步，以表侧表示特殊召唤到自己场上（后续需调用SpecialSummonComplete完成）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 自己把这衍生物作为同调素材的场合，可以当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TUNER)
		e1:SetValue(c30765615.tnval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成通过SpecialSummonStep进行的衍生物特殊召唤，使衍生物正式特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
-- 定义衍生物的调整效果判定函数：当衍生物作为同调素材时，若衍生物的控制者与素材的控制者相同（即自己使用衍生物进行同调），则衍生物当作调整使用。
function c30765615.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
