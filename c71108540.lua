--不死のデスロード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这个回合是已有怪兽被战斗破坏的场合，结束阶段才能发动。这张卡从手卡·墓地特殊召唤。这个回合是已有「不死之死神领主」被战斗破坏的场合，这个效果特殊召唤的这张卡原本攻击力变成3000，不会被效果破坏。
-- ②：自己主要阶段才能发动。把对方场上的卡数量＋1张的包含「一击必杀！居合抽卡」的卡从卡组给对方观看，用喜欢的顺序在卡组上面放置。
local s,id,o=GetID()
-- 定义卡片「不死之死神领主」的初始效果：注册①的结束阶段诱发特召效果、②的起动效果（卡组顶放置），并注册一个全局监视效果用于记录本回合是否有怪兽被战斗破坏以及本卡名是否被战斗破坏。
function s.initial_effect(c)
	-- 将「一击必杀！居合抽卡」（71344451）登记为效果文所记载的卡名，以便在效果处理中检索和识别。
	aux.AddCodeList(c,71344451)
	-- ①：这个回合是已有怪兽被战斗破坏的场合，结束阶段才能发动。这张卡从手卡·墓地特殊召唤。这个回合是已有「不死之死神领主」被战斗破坏的场合，这个效果特殊召唤的这张卡原本攻击力变成3000，不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。把对方场上的卡数量＋1张的包含「一击必杀！居合抽卡」的卡从卡组给对方观看，用喜欢的顺序在卡组上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组放置"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- ①：这个回合是已有怪兽被战斗破坏的场合，结束阶段才能发动。这张卡从手卡·墓地特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 将全局监视效果ge1注册到环境中，使其在任意卡片被破坏时触发s.checkop，用于记录战破信息（供①效果的发动条件使用）。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历被破坏的卡片，若卡片破坏前在怪兽区且原因为战斗破坏，则记录“本回合有怪兽被战斗破坏”；若这张被战破的怪兽是本卡（不死之死神领主），则额外记录“本回合有本卡名被战斗破坏”。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历被破坏的卡片集合eg中的每张卡片，逐个进行战破判定。
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_BATTLE) then
			-- 注册一个结束阶段重置的标识（id），表示“本回合已有怪兽被战斗破坏”，用于①效果的发动条件检测。
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
			if tc:GetPreviousCodeOnField()==id then
				-- 额外注册一个结束阶段重置的标识（id+o），表示“本回合已有「不死之死神领主」被战斗破坏”，用于在特殊召唤后追加攻击力/抗性提升的条件检测。
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- ①效果的特殊召唤发动条件：检查是否存在“本回合已有怪兽被战斗破坏”的标识，存在则满足发动条件（配合结束阶段的触发时机）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回玩家0侧的“本回合已有怪兽被战斗破坏”标识数量是否大于0，以此作为发动条件的判定结果。
	return Duel.GetFlagEffect(0,id)>0
end
-- ①效果的发动目标检查：在发动确认时，需要自己场上有可用的怪兽区域，且这张卡自身可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区，用以确保这张卡能从手卡·墓地特殊召唤到场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息，标明当前效果处理包含1次特殊召唤（对象为这张卡自身），用于给其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：先将这张卡从手卡·墓地特殊召唤；若本回合已有「不死之死神领主」被战斗破坏，则进一步使其原本攻击力变成3000，并赋予“不会被效果破坏”的抗性。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与当前连锁相关（未被除外/无效等），且不受“王家长眠之谷”等墓地效果封锁的影响，才能继续特殊召唤处理。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 执行特殊召唤，将这张卡以表侧攻击表示特殊召唤到自己场上，并判断是否召唤成功（返回值非0）。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查本回合是否有“不死之死神领主”被战斗破坏的标识；若存在，则进入后续设置攻击力和效果破坏抗性的分支。
		and Duel.GetFlagEffect(0,id+o)>0 then
		-- 这个回合是已有「不死之死神领主」被战斗破坏的场合，这个效果特殊召唤的这张卡原本攻击力变成3000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 不会被效果破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))  --"自身的效果特殊召唤"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 定义过滤条件：判断一张卡是否为「一击必杀！居合抽卡」（卡号71344451），用于检索卡组中是否存在该卡以及选取包含该卡的组合。
function s.cfilter(c)
	return c:IsCode(71344451)
end
-- ②效果的目标/发动检查：计算对方场上卡数量ct；在发动时需满足自己卡组数量大于ct，且卡组中存在至少1张「一击必杀！居合抽卡」。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方场上的卡总数，记为ct；实际需要选择的张数为ct+1（对方场上的卡数量+1张）。
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 发动条件之一：自己卡组的卡片数量必须大于对方场上卡的数量，以确保能取出对方场上卡数量+1张卡片。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct
		-- 发动条件之二：卡组中存在至少1张「一击必杀！居合抽卡」，才可以选择包含它的卡片组。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义用于SelectSubGroup的子组检查函数：所选的一组卡片中至少要有1张「一击必杀！居合抽卡」。
function s.gcheck(g)
	return g:IsExists(Card.IsCode,1,nil,71344451)
end
-- ②效果处理前的再次合法性检查：如果卡组数量不足或卡组中没有「一击必杀！居合抽卡」，则直接终止效果处理。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理②效果时再次统计对方场上的卡数量ct，用于计算需要选择的卡片张数（ct+1）。
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 如果自己卡组的卡片数量不超过ct，说明无法取出ct+1张卡，不满足处理条件，终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=ct
		-- 或者卡组中不存在「一击必杀！居合抽卡」，也不满足选择要求，终止处理。
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) then
		return
	end
	-- 获取自己卡组中的所有卡片作为候选组g，供后续选择ct+1张卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	-- 向操作玩家发送选择提示，要求其从候选组中选择要放置到卡组上面的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要放置到卡组上面的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,ct+1,ct+1)
	if sg then
		Duel.ConfirmCards(1-tp,sg)
		-- 遍历选出的每一张卡片sg，逐一将其移动到卡组最上方。
		for tc in aux.Next(sg) do
			-- 将当前卡片tc移动到卡组最上方，为后续按喜爱顺序排序做准备。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		end
		-- 对卡组最上方sg:GetCount()张卡进行排序，由操作玩家决定这些卡的放置顺序，实现“用喜欢的顺序在卡组上面放置”。
		Duel.SortDecktop(tp,tp,sg:GetCount())
	end
end
