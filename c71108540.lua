--不死のデスロード
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡片、结束阶段手牌/墓地特召效果、主要阶段卡组置顶效果及全局战斗破坏监听
function s.initial_effect(c)
	-- 注册记述卡片：71344451
	aux.AddCodeList(c,71344451)
	-- ①：怪兽被战斗破坏的回合的结束阶段，这张卡在手牌·墓地存在的场合才能发动。这张卡特殊召唤。
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
	-- ②：自己主要阶段才能发动。从卡组选包含1张「71344451」在内的对方场上的卡数量+1张的卡在卡组最上面以喜欢的顺序排列。
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
		-- 全局监听：记录本回合怪兽是否被战斗破坏以及自身是否被战斗破坏
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册给玩家0
		Duel.RegisterEffect(ge1,0)
	end
end
-- 战斗破坏监听处理：若怪兽被战斗破坏则为玩家注册Flag标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历本次破坏事件中的卡片
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_BATTLE) then
			-- 注册本回合有怪兽被战斗破坏的Flag标记
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
			if tc:GetPreviousCodeOnField()==id then
				-- 注册本回合此卡被战斗破坏的Flag标记
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- ①效果发动条件检查：本回合是否有怪兽被战斗破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否有怪兽被战斗破坏的标记
	return Duel.GetFlagEffect(0,id)>0
end
-- ①效果发动准备：设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将自身特殊召唤，若此卡本回合曾被战斗破坏，则原本攻击力变成3000且获得效果破坏抗性
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与连锁关联且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将自身表侧表示特殊召唤
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查本回合此卡是否曾被战斗破坏
		and Duel.GetFlagEffect(0,id+o)>0 then
		-- 这张卡的原本攻击力变成3000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 这张卡获得效果破坏抗性
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
-- 过滤条件：卡名为71344451且可加入手牌
function s.cfilter(c)
	return c:IsCode(71344451) and c:IsAbleToHand()
end
-- ②效果发动条件检查：卡组数量大于对方场上卡片数且卡组存在71344451
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方场上的卡片数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 检查卡组剩余卡数是否大于对方场上卡片数
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct
		-- 检查卡组是否存在71344451
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 组合过滤条件：选择的卡片组中必须包含至少1张71344451
function s.gcheck(g)
	return g:IsExists(Card.IsCode,1,nil,71344451)
end
-- ②效果处理：从卡组选择包含71344451在内的卡片在卡组顶按喜好顺序排列
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上卡片数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 安全检查：卡组卡片数量不足时终止处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=ct
		-- 安全检查：不存在目标卡时终止处理
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) then
		return
	end
	-- 获取卡组全部卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要在卡组顶排列的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sg=g:SelectSubGroup(tp,s.gcheck,false,ct+1,ct+1)
	if sg:GetCount()>0 then
		-- 向对方玩家确认选择的卡片组
		Duel.ConfirmCards(1-tp,sg)
		-- 遍历选中的卡片组
		for tc in aux.Next(sg) do
			-- 将卡片移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		end
		-- 让玩家对卡组最上方的卡片按喜好进行排序
		Duel.SortDecktop(tp,tp,sg:GetCount())
	end
end
