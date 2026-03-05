--コアキメイル・オーバードーズ
-- 效果：
-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。
-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际，把这张卡解放才能发动。那个无效，那些怪兽破坏。
function c14309486.initial_effect(c)
	-- 为卡片注册与「核成兽的钢核」相关的代码列表，用于后续效果判断
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
-- 判断是否为当前回合玩家的结束阶段
function c14309486.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可送入墓地的「核成兽的钢核」卡片
function c14309486.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的岩石族怪兽卡片
function c14309486.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 处理结束阶段效果的选择与执行逻辑
function c14309486.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c14309486.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取满足条件的岩石族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c14309486.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手卡同时存在「核成兽的钢核」和岩石族怪兽时，选择其一执行效果
		select=Duel.SelectOption(tp,aux.Stringid(14309486,0),aux.Stringid(14309486,1),aux.Stringid(14309486,2))  --"选择一张「核成兽的钢核」送去墓地"
	elseif g1:GetCount()>0 then
		-- 当仅存在「核成兽的钢核」时，选择将其送入墓地或破坏卡片
		select=Duel.SelectOption(tp,aux.Stringid(14309486,0),aux.Stringid(14309486,2))  --"选择一张「核成兽的钢核」送去墓地"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当仅存在岩石族怪兽时，选择将其展示给对方或破坏卡片
		select=Duel.SelectOption(tp,aux.Stringid(14309486,1),aux.Stringid(14309486,2))+1  --"选择一只岩石族怪物给对方观看"
	else
		-- 当手卡无符合条件的卡片时，选择直接破坏卡片
		select=Duel.SelectOption(tp,aux.Stringid(14309486,2))  --"破坏「核成过量体」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择将卡片送入墓地
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡片送入墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择确认展示的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=g2:Select(tp,1,1,nil)
		-- 向对方玩家确认展示选中的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 将玩家手牌洗切
		Duel.ShuffleHand(tp)
	else
		-- 将该卡破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判断是否为对方召唤时触发的效果
function c14309486.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方召唤且当前无连锁处理
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 定义发动效果时的费用支付函数
function c14309486.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放该卡作为发动效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义效果的目标选择函数
function c14309486.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效召唤效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 定义效果的处理函数
function c14309486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤的怪兽无效
	Duel.NegateSummon(eg)
	-- 破坏被召唤的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
