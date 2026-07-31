--不死のデスロード
local s,id,o=GetID()
-- 初始化卡片效果：注册关联卡名列表、结束阶段手牌/墓地特召效果、主要阶段确认并排列卡组顶效果，以及全局战斗破坏检测
function s.initial_effect(c)
	-- 注册卡片记述列表：记述卡号为71344451的卡片
	aux.AddCodeList(c,71344451)
	-- ①：有怪兽被战斗破坏的回合的结束阶段才能发动。手卡·墓地的这张卡特殊召唤。这个回合这张卡以外的自己的「[卡名]」被战斗破坏的场合，再使这个效果特殊召唤的这张卡的原本攻击力变成3000，得到效果破坏耐性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组把包含1张「[卡名]」的对方场上的卡的数量的卡确认，按喜欢的顺序回到卡组上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局战斗破坏检测效果：记录本回合怪兽及指定卡名怪兽被战斗破坏的情况
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 在系统上注册全局连续效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 战斗破坏检测处理：若有怪兽在怪兽区域被战斗破坏则注册Flag标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历被破坏的卡片组
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_BATTLE) then
			-- 注册本回合有怪兽被战斗破坏的Flag标记
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
			if tc:GetPreviousCodeOnField()==id then
				-- 注册本回合指定卡名的怪兽被战斗破坏的Flag标记
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- ①效果发动条件：本回合有怪兽被战斗破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否注册过怪兽被战斗破坏的Flag标记
	return Duel.GetFlagEffect(0,id)>0
end
-- ①效果发动准备：检查怪兽区域空位与自身特召条件，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：怪兽区域有空位且自身可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：特殊召唤手牌/墓地的自身，若本回合指定怪兽曾被战破则原本攻击力变3000并获得效果破坏耐性
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍关联连锁且不受王谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将自身表侧表示特殊召唤
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查本回合是否有指定卡名的怪兽被战斗破坏
		and Duel.GetFlagEffect(0,id+o)>0 then
		-- 原本攻击力变成3000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 得到效果破坏耐性。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 卡组过滤条件：卡号为71344451的卡且可加入手牌/检索
function s.cfilter(c)
	return c:IsCode(71344451) and c:IsAbleToHand()
end
-- ②效果发动准备：检查卡组剩余卡片数量与目标卡存在性
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 发动条件检查：己方卡组数量大于对方场上的卡片数量
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct
		-- 发动条件检查：己方卡组中存在指定卡名的卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 组合检查条件：选取的卡片组中至少包含1张指定卡名的卡
function s.gcheck(g)
	return g:IsExists(Card.IsCode,1,nil,71344451)
end
-- ②效果处理：从卡组选对方场上卡片数量的卡（必须包含指定卡），按喜欢顺序放回卡组顶
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 检查卡组数量是否仍大于对方场上卡片数量
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=ct
		-- 检查卡组中是否仍存在指定卡名的卡
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) then
		return
	end
	-- 获取己方卡组中所有的卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要放置在卡组顶的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sg=g:SelectSubGroup(tp,s.gcheck,false,ct+1,ct+1)
	if sg:GetCount()>0 then
		-- 向对方确认选中的卡片组
		Duel.ConfirmCards(1-tp,sg)
		-- 遍历选中的卡片组
		for tc in aux.Next(sg) do
			-- 将卡片移动至卡组顶
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		end
		-- 让玩家自行决定选中的卡片在卡组顶的排列顺序
		Duel.SortDecktop(tp,tp,sg:GetCount())
	end
end
