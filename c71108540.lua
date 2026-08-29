--不死のデスロード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这个回合是已有怪兽被战斗破坏的场合，结束阶段才能发动。这张卡从手卡·墓地特殊召唤。这个回合是已有「不死之死神领主」被战斗破坏的场合，这个效果特殊召唤的这张卡原本攻击力变成3000，不会被效果破坏。
-- ②：自己主要阶段才能发动。把对方场上的卡数量＋1张的包含「一击必杀！居合抽卡」的卡从卡组给对方观看，用喜欢的顺序在卡组上面放置。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 记录卡片记述的卡号（一击必杀！居合抽卡）
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
		-- ①：这个回合是已有怪兽被战斗破坏的场合，结束阶段才能发动。这张卡从手卡·墓地特殊召唤。这个回合是已有「不死之死神领主」被战斗破坏的场合，这个效果特殊召唤的这张卡原本攻击力变成3000，不会被效果破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 注册全局环境效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查并记录本回合是否有怪兽或同名卡被战斗破坏
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历被破坏的卡片组
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_BATTLE) then
			-- 为玩家注册本回合有怪兽被战斗破坏的标记
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
			if tc:GetPreviousCodeOnField()==id then
				-- 为玩家注册本回合有「不死之死神领主」被战斗破坏的标记
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
-- 特殊召唤效果的发动条件判定（本回合已有怪兽被战斗破坏）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本回合是否有怪兽被战斗破坏的标记
	return Duel.GetFlagEffect(0,id)>0
end
-- 特殊召唤效果的发动目标判定与操作信息注册
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自身怪兽区是否有空位且自身能否特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理及附加效果赋予
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否仍与效果有联系且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将自身表侧表示特殊召唤
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断本回合是否有「不死之死神领主」被战斗破坏的标记
		and Duel.GetFlagEffect(0,id+o)>0 then
		-- 这个效果特殊召唤的这张卡原本攻击力变成3000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 不会被效果破坏
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
-- 过滤卡名为「一击必杀！居合抽卡」的卡
function s.cfilter(c)
	return c:IsCode(71344451)
end
-- 卡组放置效果的发动目标判定
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 判断自己卡组数量是否大于对方场上卡数量
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct
		-- 判断卡组中是否存在「一击必杀！居合抽卡」
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 检查选取的卡片组中是否包含「一击必杀！居合抽卡」
function s.gcheck(g)
	return g:IsExists(Card.IsCode,1,nil,71344451)
end
-- 卡组放置效果处理
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 判断自己卡组数量是否小于等于对方场上卡数量
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=ct
		-- 判断卡组中是否存在「一击必杀！居合抽卡」
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) then
		return
	end
	-- 获取自己卡组的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	-- 提示选择要放置到卡组上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要放置到卡组上面的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,ct+1,ct+1)
	if sg then
		-- 向对方展示选中的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 遍历选中的卡片组
		for tc in aux.Next(sg) do
			-- 将卡片移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		end
		-- 由玩家对卡组顶部的这些卡按喜欢的顺序排序
		Duel.SortDecktop(tp,tp,sg:GetCount())
	end
end
