--コアキメイル・オーバードーズ
-- 效果：
-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。
-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际，把这张卡解放才能发动。那个无效，那些怪兽破坏。
function c14309486.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「核成兽的钢核」，以便后续检索相关卡片。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c14309486.mtcon)
	e1:SetOperation(c14309486.mtop)
	c:RegisterEffect(e1)
	-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际，把这张卡解放才能发动。那个无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14309486,3))  --"召唤无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SUMMON)
	e2:SetCondition(c14309486.condition)
	e2:SetCost(c14309486.cost)
	e2:SetTarget(c14309486.target)
	e2:SetOperation(c14309486.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e4)
end
-- 结束阶段维持COST效果的触发条件：只有当前回合玩家是这张卡的控制者（即自己的结束阶段）时才进行处理。
function c14309486.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于这张卡的控制者tp，若是则条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中卡名为「核成兽的钢核」且可作为COST送去墓地的卡。
function c14309486.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手牌中未公开的岩石族怪兽，用于作为给对方观看的维持COST。
function c14309486.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 结束阶段维持处理：展示这张卡自身，根据手牌情况让控制者选择“送钢核/展示岩石族/都不做”，然后执行对应操作或破坏自身。
function c14309486.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡自身显示为当前处理对象（播放选中动画），提示玩家此卡正在处理维持COST。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取控制者手牌中可作为COST送去墓地的「核成兽的钢核」的集合。
	local g1=Duel.GetMatchingGroup(c14309486.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取控制者手牌中可供对方观看的岩石族怪兽的集合。
	local g2=Duel.GetMatchingGroup(c14309486.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 两种维持COST卡都存在时，提供三个选项：送「核成兽的钢核」、展示岩石族怪兽、破坏自身，并返回选项序号。
		select=Duel.SelectOption(tp,aux.Stringid(14309486,0),aux.Stringid(14309486,1),aux.Stringid(14309486,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只岩石族怪物给对方观看/破坏「核成过量体」"
	elseif g1:GetCount()>0 then
		-- 只有「核成兽的钢核」可选时，提供两个选项：送钢核或破坏自身；若选择破坏则把序号转换为2，统一后续分支。
		select=Duel.SelectOption(tp,aux.Stringid(14309486,0),aux.Stringid(14309486,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成过量体」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 只有岩石族怪兽可选时，提供两个选项：展示岩石族怪兽或破坏自身；将选项序号加1以匹配后续分支（展示对应1，破坏对应2）。
		select=Duel.SelectOption(tp,aux.Stringid(14309486,1),aux.Stringid(14309486,2))+1  --"选择一只岩石族怪物给对方观看/破坏「核成过量体」"
	else
		-- 两种维持COST卡都不存在时，只能选择破坏自身，固定select为2。
		select=Duel.SelectOption(tp,aux.Stringid(14309486,2))  --"破坏「核成过量体」"
		select=2
	end
	if select==0 then
		-- 显示“请选择要送去墓地的卡”的提示，用于选择「核成兽的钢核」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的「核成兽的钢核」作为COST送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 显示“请选择给对方确认的卡”的提示，用于选择要展示的岩石族怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的岩石族怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切手牌，防止对方通过确认获得手牌顺序信息。
		Duel.ShuffleHand(tp)
	else
		-- 因未进行维持COST，将这张卡自身破坏（作为不维持的代价）。
		Duel.Destroy(c,REASON_COST)
	end
end
-- ①效果的发动条件：对方玩家进行召唤·反转召唤·特殊召唤之际，且当前没有其他连锁（即直接连锁召唤时发动）。
function c14309486.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 召唤者是对方（召唤玩家ep不是控制者tp）且当前连锁数为0，此时才能满足触发条件。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- ①效果的COST：检查这张卡自身是否可以解放，若可以则作为发动代价解放。
function c14309486.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡自身解放作为发动COST。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果发动时的目标设定：以正在召唤的怪兽群为对象，并登记无效召唤与破坏的操作信息。
function c14309486.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记此操作包含“无效召唤”分类，对象为正在召唤的怪兽群，数量为怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 登记此操作包含“破坏”分类，对象为正在召唤的怪兽群，数量为怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- ①效果处理：将正在召唤的怪兽的召唤无效，并将其破坏。
function c14309486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使那组正在召唤的怪兽召唤无效（取消召唤行为）。
	Duel.NegateSummon(eg)
	-- 将召唤被无效的怪兽以效果破坏，实际使其送去墓地。
	Duel.Destroy(eg,REASON_EFFECT)
end
